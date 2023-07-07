import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:open_meteo_api/open_meteo_api.dart';
import 'package:open_meteo_api/src/models/location.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('openMateoApiClient', () {
    late http.Client httpClient;
    late OpenMeteoApiClient apiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      apiClient = OpenMeteoApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require a httpClient', () {
        expect(OpenMeteoApiClient(), isNotNull);
      });
    });

    group('locationSearch', () {
      const query = 'most-query';
      test('makes correct http request on location', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(
            200); //When the status code is consulted, then return 200?
        when(() => response.body).thenReturn(
            '{}'); //when the response body is consulted, then return {}?
        when(() => httpClient.get(any())).thenAnswer((_) async =>
            response); //when a get request is made, then return a response?
        try {
          await apiClient.locationSearch(query);
        } catch (_) {}
        //verify: that a method on a mock object was called with the given arguments
        verify(
          () => httpClient.get(
            Uri.https(
              'geocoding-api.open-meteo.com',
              '/v1/search',
              {
                'name': query,
                'count': '1',
              },
            ),
          ),
        ).called(1);
      });

      test(
        'throws LocationRequestFailure on non-200 response',
        () async {
          final response = MockResponse();
          when(
            () => response.statusCode,
          ).thenReturn(400);
          when(
            () => httpClient.get(any()),
          ).thenAnswer((_) async => response);
          await expectLater(apiClient.locationSearch(query),
              throwsA(isA<LocationRequestFailure>()));
        },
      );

      test(
        'throws LocationNotFoundFailure on error response',
        () async {
          final response = MockResponse();
          when(
            () => httpClient.get(any()),
          ).thenAnswer((_) async => response);
          when(
            () => response.statusCode,
          ).thenReturn(200);
          when(
            () => response.body,
          ).thenReturn('{}');
          await expectLater(
            apiClient.locationSearch(query),
            throwsA(
              isA<LocationNotFoundFailure>(),
            ),
          );
        },
      );

      test('throws LocationNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(
          () => httpClient.get(any()),
        ).thenAnswer((_) async => response);
        when(
          () => response.statusCode,
        ).thenReturn(200);
        when(
          () => response.body,
        ).thenReturn('{"results":[]}');
        await expectLater(
          apiClient.locationSearch(query),
          throwsA(
            isA<LocationNotFoundFailure>(),
          ),
        );
      });

      test(
        'returns Location on valid response',
        () async {
          final response = MockResponse();
          when(
            () => httpClient.get(
              any(),
            ),
          ).thenAnswer((_) async => response);
          when(
            () => response.statusCode,
          ).thenReturn(200);
          when(
            () => response.body,
          ).thenReturn('''
{
  "results": [
    {
      "id": 4887398,
      "name": "Chicago",
      "latitude": 41.85003,
      "longitude": -87.65005
    }
  ]
}''');
          final actual = await apiClient.locationSearch(query);
          expect(
            actual,
            isA<Location>()
                .having((l) => l.name, 'name', 'Chicago')
                .having((l) => l.id, 'id', 4887398)
                .having((l) => l.latitude, 'latitude', 41.85003)
                .having((l) => l.longitude, 'longitude', -87.65005),
          );
        },
      );
    });

    group('getWeather', () {
      const latitude = 41.85003;
      const longitude = -87.6500;

      test(
        'makes correct http request on weather',
        () async {
          final response = MockResponse();
          when(() => response.statusCode).thenReturn(
              200); //When the status code is consulted, then return 200?
          when(() => response.body).thenReturn(
              '{}'); //when the response body is consulted, then return {}?
          when(() => httpClient.get(any())).thenAnswer((_) async =>
              response); //when a get request is made, then return a response?
          try {
            await apiClient.getWeather(
                latitude: latitude, longitude: longitude);
          } catch (_) {}
          verify(
            () => httpClient.get(
              Uri.https(
                'api.open-meteo.com',
                '/v1/forecast',
                {
                  'latitude': '$latitude',
                  'longitude': '$longitude',
                  'current_weather': 'true',
                },
              ),
            ),
          ).called(1);
        },
      );
      test(
        'throws WeatherRequestFailure on non-200 response',
        () async {
          final response = MockResponse();
          when(
            () => httpClient.get(any()),
          ).thenAnswer((_) async => response);
          when(
            () => response.statusCode,
          ).thenReturn(400);
          expect(
            () async => await apiClient.getWeather(
                latitude: latitude, longitude: longitude),
            throwsA(
              isA<WeatherRequestFailure>(),
            ),
          );
        },
      );
      test(
        'throws WeatherNotFoundFailure on empty response',
        () async {
          final response = MockResponse();
          when(
            () => httpClient.get(any()),
          ).thenAnswer((_) async => response);
          when(
            () => response.statusCode,
          ).thenReturn(200);
          when(
            () => response.body,
          ).thenReturn('{}');
          expect(
              () async => await apiClient.getWeather(
                  latitude: latitude, longitude: longitude),
              throwsA(isA<WeatherNotFoundFailure>()));
        },
      );

      test(
        'returns weather on valid response',
        () async {
          final response = MockResponse();
          when(
            () => response.statusCode,
          ).thenReturn(200);
          when(
            () => response.body,
          ).thenReturn('''
{
"latitude": 43,
"longitude": -87.875,
"generationtime_ms": 0.2510547637939453,
"utc_offset_seconds": 0,
"timezone": "GMT",
"timezone_abbreviation": "GMT",
"elevation": 189,
"current_weather": {
"temperature": 15.3,
"windspeed": 25.8,
"winddirection": 310,
"weathercode": 63,
"time": "2022-09-12T01:00"
}
}
''');
          when(
            () => httpClient.get(any()),
          ).thenAnswer((_) async => response);

          final actual = await apiClient.getWeather(
            latitude: latitude,
            longitude: longitude,
          );
          expect(
            actual,
            isA<Weather>()
                .having((w) => w.temperature, 'temperature', 15.3)
                .having((w) => w.weatherCode, 'weatherCode', 63.0),
          );
        },
      );
    });
  });
}
