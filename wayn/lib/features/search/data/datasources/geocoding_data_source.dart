// lib/features/search/data/datasources/geocoding_data_source.dart
import 'package:dio/dio.dart';
import '../../../core/config/mapbox_config.dart';

class GeocodingDataSource {
  final Dio _dio;
  static const String baseUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places';

  GeocodingDataSource(this._dio);

  Future<List<Map<String, dynamic>>> searchAddresses(
      String query, double? userLat, double? userLng) async {
    final response = await _dio
        .get('${MapboxConfig.geocodingUrl}/$query.json', queryParameters: {
      'access_token': MapboxConfig.accessToken,
      'country': 'fr',
      'language': 'fr',
      'types': 'address,place,poi',
      'autocomplete': true,
      'limit': '5',
      if (userLat != null && userLng != null) 'proximity': '$userLng,$userLat',
    });

    if (response.statusCode == 200) {
      final features = response.data['features'] as List;
      return features.map((f) => f as Map<String, dynamic>).toList();
    }
    throw Exception('Erreur lors de la recherche d\'adresses');
  }

  Future<Map<String, dynamic>> geocodeAddress(String address) async {
    try {
      final response = await _dio.get(
        '${MapboxConfig.geocodingUrl}/${Uri.encodeComponent(address)}.json',
        queryParameters: {
          'access_token': MapboxConfig.accessToken,
          'country': 'fr',
          'language': 'fr',
          'limit': 1,
          'types': 'address',
        },
      );

      if (response.statusCode == 200 &&
          response.data['features'] != null &&
          response.data['features'].isNotEmpty) {
        return response.data['features'][0];
      } else {
        throw Exception('Aucune coordonnée trouvée pour cette adresse');
      }
    } catch (e) {
      throw Exception('Erreur lors de la géolocalisation: $e');
    }
  }
}
