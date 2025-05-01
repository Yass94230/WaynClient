import 'package:get_it/get_it.dart';
import 'package:wayn/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:wayn/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';
import 'package:wayn/features/payment/domain/usecases/confirm_payment.dart';
import 'package:wayn/features/payment/domain/usecases/create_payment_intent.dart';
import 'package:wayn/features/payment/domain/usecases/get_saved_card.dart';
import 'package:wayn/features/payment/domain/usecases/save_card.dart';
import 'package:wayn/features/payment/domain/usecases/save_ride_after_payment.dart';
import 'package:wayn/features/payment/presentation/blocs/payment_bloc.dart';

final paymentInjection = GetIt.instance;

Future<void> initPaymentDependencies() async {
  // Data sources
  paymentInjection.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(
      firestore: paymentInjection(),
      dio: paymentInjection(),
      baseUrl:
          'https://us-central1-wayn-vtc.cloudfunctions.net/createPaymentIntent', // Remplacez par votre URL
    ),
  );

  // Repository
  paymentInjection.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(paymentInjection()),
  );

  // Use cases
  paymentInjection.registerLazySingleton(() => SaveCard(paymentInjection()));
  paymentInjection
      .registerLazySingleton(() => CreatePaymentIntent(paymentInjection()));
  paymentInjection
      .registerLazySingleton(() => ConfirmPayment(paymentInjection()));
  paymentInjection
      .registerLazySingleton(() => ListSavedCards(paymentInjection()));

  paymentInjection
      .registerLazySingleton(() => SaveRideAfterPayment(paymentInjection()));

  // Bloc
  paymentInjection.registerFactory(
    () => PaymentBloc(
      saveCard: paymentInjection(),
      createPaymentIntentUseCase: paymentInjection(),
      confirmPaymentUseCase: paymentInjection(),
      listSavedCards: paymentInjection(),
      saveRideAfterPayment: paymentInjection(),
    ),
  );
}
