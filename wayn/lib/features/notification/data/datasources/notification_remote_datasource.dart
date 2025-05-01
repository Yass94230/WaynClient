// lib/features/notification/data/datasources/notification_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

abstract class INotificationRemoteDataSource {
  Future<void> sendRideRequestNotification({
    required String driverToken,
    required RideRequest rideRequest,
  });
}

class NotificationRemoteDataSource implements INotificationRemoteDataSource {
  final Dio _dio;
  final String _baseUrl;

  NotificationRemoteDataSource(this._dio, {String? baseUrl})
      : _baseUrl = baseUrl ?? 'https://us-central1-wayn-vtc.cloudfunctions.net';

  @override
  Future<void> sendRideRequestNotification({
    required String driverToken,
    required RideRequest rideRequest,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/sendRideRequestNotification',
        data: {
          'token': driverToken,
          'data': {
            'type': 'ride_request',
            'rideId': rideRequest.id.toString(),
            'pickupAddress': rideRequest.pickupAddress,
            'destinationAddress': rideRequest.destinationAddress,
            'grossPrice': rideRequest.grossPrice,
            'netPrice': rideRequest.netPrice,
            'timeToPickup': rideRequest.timeToPickup.inMinutes,
            'totalRideTime': rideRequest.totalRideTime.inMinutes,
            'status': rideRequest.status.toString(),
            'origin': rideRequest.origin,
            'destination': rideRequest.destination,
            // Ajout des informations du client
            'id': rideRequest.user.id,
            'email': rideRequest.user.email,
            'phoneNumber': rideRequest.user.phoneNumber,
            'firstName': rideRequest.user.firstName,
            'lastName': rideRequest.user.lastName,
            'sexe': rideRequest.user.sexe,
            'choices': rideRequest.user.choices,
            'firebaseToken': rideRequest.user.firebaseToken,
            'stripeId': rideRequest.user.stripeId,
          },
          'notification': {
            'title': 'Nouvelle course disponible',
            'body':
                'Course à ${rideRequest.netPrice}€ - ${rideRequest.timeToPickup.inMinutes}min',
          }
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status == 200,
        ),
      );

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Erreur serveur: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Erreur d\'envoi de notification: ${e.message}');
    }
  }
}
