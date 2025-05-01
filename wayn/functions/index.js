/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */


const admin = require('firebase-admin');
const {onRequest} = require("firebase-functions/v2/https");
const functions = require('firebase-functions/v1');
const stripe = require('stripe')('sk_test_51P14WuItq6aPmGK6tAemSefvmkhgWTK8d0daQhGkD2SUAKnmjvfYqrtN87UYct2rAVJe8Tb9U3dJIieYR2u0gFEh00vpX2VJ5b');
const cors = require('cors')({ origin: true });

admin.initializeApp();


exports.createStripeCustomer = functions.auth.user().onCreate((userRecord) => {
    return stripe.customers.create({
        email: userRecord.email,
    })
    .then((customer) => {
        return admin.firestore().collection('users').doc(userRecord.uid).set({
            stripeCustomerId: customer.id
        }, { merge: true });
    })
    .then(() => {
        console.log(`Stripe customer created for user: ${userRecord.uid}`);
        return null;
    })
    .catch((error) => {
        console.error('Error creating Stripe customer:', error);
        return null;
    });
});

exports.attachPaymentMethod = functions.https.onCall(async (data, context) => {
  // Vérifier l'authentification
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'L\'utilisateur doit être connecté'
    );
  }

  try {
    const { paymentMethodId } = data;
    
    // Récupérer le customerId depuis Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .get();
      
    const customerId = userDoc.data().stripeCustomerId;
    
    if (!customerId) {
      throw new Error('Customer Stripe non trouvé');
    }

    // Attacher la PaymentMethod au customer
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });
    
    // Optionnellement, définir comme méthode par défaut
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    // Sauvegarder la référence dans Firestore (optionnel)
    await admin.firestore()
      .collection('users')
      .doc(context.auth.uid)
      .collection('paymentMethods')
      .doc(paymentMethodId)
      .set({
        type: 'card',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    
    return { success: true };
  } catch (error) {
    console.error('Error attaching payment method:', error);
    throw new functions.https.HttpsError('internal', error.message);
  }
});


exports.createSetupIntent = functions.https.onRequest(async (request, response) => {
  // Activer CORS
  response.set('Access-Control-Allow-Origin', '*');
  
  if (request.method === 'OPTIONS') {
    response.set('Access-Control-Allow-Methods', 'POST');
    response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    response.set('Access-Control-Max-Age', '3600');
    response.status(204).send('');
    return;
  }

  try {
    // Vérifier que c'est bien une requête POST
    if (request.method !== 'POST') {
      throw new Error('Méthode non autorisée');
    }

    // Vérifier le token d'authentification
    const authHeader = request.headers.authorization;
    if (!authHeader) {
      response.status(401).json({ error: 'Non autorisé' });
      return;
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    const uid = decodedToken.uid;

    // Récupérer le customerId depuis Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(uid)
      .get();

    const customerId = userDoc.data()?.stripeCustomerId;
    if (!customerId) {
      response.status(400).json({ error: 'Customer Stripe non trouvé' });
      return;
    }

    // Créer le SetupIntent
    const setupIntent = await stripe.setupIntents.create({
      customer: customerId,
      payment_method_types: ['card'],
      usage: 'off_session',
    });

    // Renvoyer le client secret
    response.json({
      clientSecret: setupIntent.client_secret
    });

  } catch (error) {
    console.error('Error:', error);
    response.status(500).json({ 
      error: error.message || 'Error creating SetupIntent'
    });
  }
})

exports.createPaymentIntent = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      console.log('🔍 Début de createPaymentIntent');
      const { amount, currency, paymentMethodId } = req.body;
      console.log('Données reçues:', { amount, currency, paymentMethodId });

      if (!paymentMethodId) {
        throw new Error('PaymentMethod ID est requis');
      }

      // Vérification du token
      const authHeader = req.headers.authorization;
      if (!authHeader) {
        throw new Error('Token manquant');
      }

      const token = authHeader.split('Bearer ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      console.log('User ID:', decodedToken.uid);

      // Récupération du customer Stripe depuis Firestore
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(decodedToken.uid)
        .get();

      console.log('User doc exists:', userDoc.exists);
      console.log('User data:', userDoc.data());

      if (!userDoc.exists) {
        throw new Error('Utilisateur non trouvé');
      }

      // Changement ici : utilisation de la bonne casse
      const customerId = userDoc.data().stripeCustomerId; // Correspond à la clé dans Firestore
      if (!customerId) {
        throw new Error('Customer Stripe non trouvé');
      }

      console.log('Customer ID:', customerId);

      // Création du PaymentIntent
      const paymentIntentData = {
        amount: parseInt(amount),
        currency: currency,
        customer: customerId,
        payment_method: paymentMethodId,
        off_session: true,
        confirm: true,
        payment_method_types: ['card']
      };

      console.log('Creating PaymentIntent with:', paymentIntentData);

      const paymentIntent = await stripe.paymentIntents.create(paymentIntentData);
      
      res.json({
        clientSecret: paymentIntent.client_secret,
        status: paymentIntent.status,
        id: paymentIntent.id,
        amount: paymentIntent.amount,
        currency: paymentIntent.currency,
        created: paymentIntent.created,
        livemode: paymentIntent.livemode,
        capture_method: paymentIntent.capture_method,
        confirmation_method: paymentIntent.confirmation_method
      });

    } catch (error) {
      console.error('Error in createPaymentIntent:', error);
      res.status(400).json({ 
        error: error.message,
        details: error.stack
      });
    }
  });
});

  // Dans votre index.ts de Firebase Functions
exports.listPaymentMethods = functions.https.onRequest(async (request, response) => {
  // Activer CORS
  response.set('Access-Control-Allow-Origin', '*');
  
  if (request.method === 'OPTIONS') {
    response.set('Access-Control-Allow-Methods', 'GET');
    response.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    response.set('Access-Control-Max-Age', '3600');
    response.status(204).send('');
    return;
  }

  try {
    // Vérifier que c'est bien une requête GET
    if (request.method !== 'GET') {
      throw new Error('Méthode non autorisée');
    }

    // Vérifier le token d'authentification
    const authHeader = request.headers.authorization;
    if (!authHeader) {
      response.status(401).json({ error: 'Non autorisé' });
      return;
    }

    const token = authHeader.split('Bearer ')[1];
    const decodedToken = await admin.auth().verifyIdToken(token);
    const uid = decodedToken.uid;

    // Récupérer le customerId depuis Firestore
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(uid)
      .get();

    const customerId = userDoc.data()?.stripeCustomerId;
    if (!customerId) {
      response.status(400).json({ error: 'Customer Stripe non trouvé' });
      return;
    }

    // Récupérer les PaymentMethods via l'API Stripe
    const paymentMethods = await stripe.paymentMethods.list({
      customer: customerId,
      type: 'card',
    });

    // Renvoyer les PaymentMethods
    response.json({
      paymentMethods: paymentMethods.data
    });

  } catch (error) {
    console.error('Error:', error);
    response.status(500).json({ 
      error: error.message || 'Error listing payment methods'
    });
  }
});

exports.sendRideRequestNotification = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      console.log('Received request body:', JSON.stringify(req.body, null, 2));
      const { token, data, notification } = req.body;
      
      if (!token || !data) {
        console.log('Missing required fields:', { token, data });
        return res.status(400).send('Missing required fields');
      }

      // Vérification et formatage des coordonnées
      let origin, destination;
      if (Array.isArray(data.origin) && data.origin.length === 2) {
        origin = `${data.origin[1]},${data.origin[0]}`; // Latitude,Longitude
      } else {
        console.error('Unexpected origin format:', data.origin);
        throw new Error(`Invalid origin format: ${JSON.stringify(data.origin)}`);
      }

      if (Array.isArray(data.destination) && data.destination.length === 2) {
        destination = `${data.destination[1]},${data.destination[0]}`;
      } else {
        console.error('Unexpected destination format:', data.destination);
        throw new Error(`Invalid destination format: ${JSON.stringify(data.destination)}`);
      }

      // Récupération de l'ID
      // L'ID sera déjà une string car RideIdGenerator.toString() est appelé lors de la sérialisation
      const rideId = data.rideId ? data.rideId.toString() : '';
      console.log('Processing ride ID:', rideId);

      // Formatage des données utilisateur
      const message = {
        token: token,
        data: {
          rideId: rideId, // Utilisation de l'ID formaté
          pickupAddress: String(data.pickupAddress || ''),
          destinationAddress: String(data.destinationAddress || ''),
          grossPrice: String(Number(data.grossPrice).toFixed(2)),
          netPrice: String(Number(data.netPrice).toFixed(2)),
          timeToPickup: String(Math.round(Number(data.timeToPickup || 0))),
          totalRideTime: String(Math.round(Number(data.totalRideTime || 0))),
          distance: String(Number(data.distance || 0).toFixed(2)),
          status: String(data.status || 'created'),
          origin: origin,
          destination: destination,
          createdAt: String(Date.now()),
          // Données utilisateur
          email: String(data.email || ''),
          phoneNumber: String(data.phoneNumber || ''),
          firstName: String(data.firstName || ''),
          lastName: String(data.lastName || ''),
          sexe: String(data.sexe || ''),
          choices: JSON.stringify(data.choices || []),
          firebaseToken: String(data.firebaseToken || ''),
          stripeId: String(data.stripeId || '')
        },
        notification: {
          title: notification?.title || 'Nouvelle course disponible',
          body: notification?.body || 'Une nouvelle course est disponible'
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'ride_requests',
            sound: 'default'
          }
        },
        apns: {
          payload: {
            aps: {
              sound: 'default',
              badge: 1
            }
          }
        }
      };

      console.log('Formatted message to send:', JSON.stringify(message, null, 2));
      const response = await admin.messaging().send(message);
      console.log('Successfully sent message:', response);
      return res.status(200).json({ success: true, messageId: response });

    } catch (error) {
      console.error('Full error details:', {
        message: error.message,
        stack: error.stack,
        data: req.body.data
      });
      return res.status(500).send('Error sending notification: ' + error.message);
    }
  });
});

exports.onNewChatMessage = functions.firestore
  .document('rides/{rideId}/chat/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    try {
      const messageData = snap.data();
      const rideId = context.params.rideId;

      // Récupérer les informations de la course
      const rideDoc = await admin.firestore()
        .collection('rides')
        .doc(rideId)
        .get();

      if (!rideDoc.exists) {
        console.log('Course non trouvée:', rideId);
        return null;
      }

      const rideData = rideDoc.data();
      const senderId = messageData.senderId;

      // Déterminer le destinataire
      let recipientId;
      if (senderId === rideData.driverId) {
        recipientId = rideData.clientId;
      } else if (senderId === rideData.clientId) {
        recipientId = rideData.driverId;
      } else {
        console.log('Expéditeur non reconnu:', senderId);
        return null;
      }

      // Récupérer le token FCM du destinataire
      const userDoc = await admin.firestore()
        .collection('users')
        .doc(recipientId)
        .get();

      if (!userDoc.exists) {
        console.log('Utilisateur non trouvé:', recipientId);
        return null;
      }

      const userData = userDoc.data();
      const fcmToken = userData.fcmToken;

      if (!fcmToken) {
        console.log('Token FCM non trouvé pour:', recipientId);
        return null;
      }

      // Construire la notification
      const message = {
        notification: {
          title: 'Nouveau message',
          body: messageData.content
        },
        data: {
          rideId: rideId,
          chatId: context.params.chatId, // Ajout du chatId
          type: 'chat_message',
          senderId: senderId,
        },
        token: fcmToken
      };

      // Envoyer la notification
      const response = await admin.messaging().send(message);
      console.log('Notification envoyée avec succès:', response);
      return null;
    } catch (error) {
      console.error('Erreur lors de l\'envoi de la notification:', error);
      return null;
    }
  });

  exports.sendCallNotification = functions.https.onCall(async (data, context) => {
    // Vérifier si l'utilisateur est authentifié
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }
  
    const { fcmToken, callId, channelName, callerId } = data;
  
    // Vérifier que tous les paramètres requis sont présents
    if (!fcmToken || !callId || !channelName || !callerId) {
      throw new functions.https.HttpsError('invalid-argument', 'Missing required parameters');
    }
  
    try {
      const message = {
        token: fcmToken,
        data: {
          type: 'call',
          callId: callId,
          channelName: channelName,
          callerId: callerId
        },
        notification: {
          title: 'Appel entrant',
          body: 'Quelqu\'un vous appelle...'
        },
        android: {
          priority: 'high',
          notification: {
            channelId: 'calls'
          }
        }
      };
  
      // Envoyer la notification
      const response = await admin.messaging().send(message);
      return { success: true, result: response };
  
    } catch (error) {
      console.error('Error sending notification:', error);
      throw new functions.https.HttpsError('internal', 'Error sending notification', error);
    }
  });