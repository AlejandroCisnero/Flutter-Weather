import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/models/location.dart';

/// Exception thrown when locationSearch fails.
class LocationRequestFailure implements Exception {}

/// Exception thrown when the provided location is not found.
class LocationNotFoundFailure implements Exception {}

/// Exception thrown when getWeather fails.
class WeatherRequestFailure implements Exception {}

/// Exception thrown when the weather for the provided location is not found.
class WeatherNotFoundFailure implements Exception {}

class OpenMeteoApiClient {
  OpenMeteoApiClient({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  static const _urlBaseGeocoding = 'geocoding-api.open-meteo.com';
  static const _urlBaseWeather = 'api.open-meteo.com';

  final http.Client _httpClient;

  /// Finds a [Location] `/v1/search/?name=(query)&count=1`.
  Future<Location> locationSearch(String query) async {
    //Prepare the request path and parameters
    final locationRequest = Uri.https(
      _urlBaseGeocoding,
      '/v1/search',
      {'name': query, 'count': '1'},
    );
    //Perform a request with the provided reques setup
    final locationResponse = await _httpClient.get(locationRequest);

    //Check if the http status code of the response is not equal to 200
    if (locationResponse.statusCode != 200) {
      throw LocationRequestFailure();
    }

    //Map the response body into a Map object
    final locationJson = jsonDecode(locationResponse.body) as Map;

    //Check if the body of the response comes with the property 'results'
    if (!locationJson.containsKey('results')) throw LocationNotFoundFailure();

    //Map the list of properties in the results property into a dart List
    final results = locationJson['results'] as List;

    //Check if the results are empty to throw a LocationNotFoundFailure exception
    if (results.isEmpty) throw LocationNotFoundFailure();

    //Return a Location object made with the response body["results"]
    return Location.fromJson(results.first as Map<String, dynamic>);
  }

  /// /// Fetches [Weather] for a given [latitude] and [longitude].
  Future<Weather> getWeather(
      {required double latitude, required double longitude}) async {
    //Setting up the request details (path, body, etc)
    final weatherRequest = Uri.https(
      _urlBaseWeather,
      '/v1/forecast',
      {
        'latitude': '$latitude',
        'longitude': '$longitude',
        'current_weather': 'true',
      },
    );

    //Execute the request
    final weatherResponse = await _httpClient.get(weatherRequest);

    //Check if the response is OK
    if (weatherResponse.statusCode != 200) throw WeatherRequestFailure();

    //Converting the response into a dart Map object
    final weatherJson =
        jsonDecode(weatherResponse.body) as Map<String, dynamic>;

    //Check if the response contains the property 'current_weather'
    if (!weatherJson.containsKey('current_weather')) {
      throw WeatherNotFoundFailure();
    }

    //Converting the property 'current_weather' into a Dart List
    final result = weatherJson['current_weather'] as Map<String, dynamic>;

    //Check if the result is not empty
    if (result.isEmpty) throw WeatherNotFoundFailure();

    return Weather.fromJson(result);
  }
}
