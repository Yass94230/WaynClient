import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

class FirebaseSaveRide {
  final FirebaseFirestore _firestore;
  FirebaseSaveRide(this._firestore);
  Future<void> createRide(RideRequest rideRequest) async {
    try {
      await _firestore
          .collection('rides')
          .doc(rideRequest.id.toString())
          .set({});
    } catch (e) {
      throw Exception(
          'Erreur lors de la création de la course : ${e.toString()}');
    }
  }
}
