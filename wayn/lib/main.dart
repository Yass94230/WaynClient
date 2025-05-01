import 'dart:developer';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/agora/presentation/blocs/call_bloc.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/authentification/presentation/pages/welcome_screen.dart';
import 'package:wayn/features/chat/presentation/blocs/chat_bloc.dart';
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/core/depencyInjection/injection_agora.dart';
import 'package:wayn/features/core/depencyInjection/injection_chat.dart';
import 'package:wayn/features/core/depencyInjection/injection_confirmation.dart';
import 'package:wayn/features/core/depencyInjection/injection_container.dart';
import 'package:wayn/features/core/depencyInjection/injection_map.dart';
import 'package:wayn/features/core/depencyInjection/injection_payment.dart';
import 'package:wayn/features/core/depencyInjection/injection_search.dart';
import 'package:wayn/features/home/bloc/navigation_bloc.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/notification/data/datasources/notification_local_datesource_impl.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_event.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_state.dart';
import 'package:wayn/features/payment/presentation/blocs/payment_bloc.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_bloc.dart';
import 'package:wayn/features/search/presentation/blocs/search_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onMessage.listen(
    (RemoteMessage message) {
      log("=== MESSAGE REÇU (GLOBAL LISTENER) ===");
      log("Message data: ${message.data}");
    },
    onError: (error) {
      log("=== ERREUR DANS LE LISTENER GLOBAL ===");
      log(error.toString());
    },
    cancelOnError: false,
  );

  final NotificationLocalDataSourceImpl notificationDataSource =
      NotificationLocalDataSourceImpl(
    localNotifications: FlutterLocalNotificationsPlugin(),
    firebaseMessaging: FirebaseMessaging.instance,
  );
  await notificationDataSource.initialize();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(UserAdapter());
  }

  String ACCESS_TOKEN =
      "sk.eyJ1Ijoid2F5bnZ0YyIsImEiOiJjbTRrOHByaHgwZDF1MnFwbDlmYjVib3F6In0.33Pm11cQyFSr2IsJHR73Ag";

  Stripe.publishableKey =
      "pk_test_51P14WuItq6aPmGK6MTnKjk2cuQGkvGr5GfLCFePhfyaaHbIlSaqljfIb7LJJjdKh8KZsTkDywR9X36jHoc3j03UW00msaFhbsF";
      //pk_live_51Jz7byDaCirvfBHex75Yh1i6hA9yTbsG7qsQAXmtu5aQoqAKnby03706E5HoG77a5FXUlG3UXDFar9z1BFmgSpin00GUb6U7kz
  await Stripe.instance.applySettings();
  MapboxOptions.setAccessToken(ACCESS_TOKEN);
  await init(); // injection_container.dart
  await initMapDependencies(); // injection_map.dart
  await initSearchDependencies();
  await initPaymentDependencies();
  await initConfirmationDependencies();
  await injectionChatDepency();
  await injectionAgora();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<NavigationBloc>(
            create: (context) => NavigationBloc(),
          ),
          BlocProvider<UserCubit>(
            create: (context) => sl<UserCubit>(),
          ),
          BlocProvider<NotificationBloc>(
            create: (context) {
              final bloc = sl<NotificationBloc>();
              // Initialisation des notifications au démarrage
              bloc.add(InitializeNotifications());
              return bloc;
            },
          ),
          BlocProvider(create: (context) => sl<AuthBloc>()),
          BlocProvider(create: (context) => sl<MapBloc>()),
          BlocProvider<SearchBloc>(
            create: (context) => sl<SearchBloc>(),
          ),
          BlocProvider<PaymentBloc>(
            create: (context) => sl<PaymentBloc>(),
          ),
          BlocProvider<RideConfirmationBloc>(
            create: (context) => sl<RideConfirmationBloc>(),
          ),
          BlocProvider<ChatBloc>(
            create: (context) => sl<ChatBloc>(),
          ),
          BlocProvider<CallBloc>(
            create: (context) => sl<CallBloc>(),
          ),
        ],
        child: Platform.isAndroid
            ? MaterialApp(
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  MobileAdaptive.init(context);
                  return child!;
                },
                title: 'Wayn',
                theme: ThemeData(
                  colorScheme: const ColorScheme.light(
                    primary: Colors.white,
                    secondary: Colors.white,
                  ),
                  primaryColor: Colors.black,
                  useMaterial3: false,
                  appBarTheme: const AppBarTheme(
                      elevation: 0,
                      centerTitle: true,
                      titleTextStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                home: BlocListener<NotificationBloc, NotificationState>(
                  listener: (context, state) {
                    if (state is NotificationReceived) {
                      log('Notification received');
                    }
                  },
                  child: const WelcomeScreen(),
                ))
            : CupertinoApp(
                debugShowCheckedModeBanner: false,
                builder: (context, child) {
                  MobileAdaptive.init(context);
                  return child!;
                },
                home: BlocListener<NotificationBloc, NotificationState>(
                  listener: (context, state) {
                    if (state is NotificationReceived) {
                      log('Notification received');
                    }
                  },
                  child: const WelcomeScreen(),
                ),
              ));
  }
}
