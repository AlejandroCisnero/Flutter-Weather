import 'package:flutter_test/flutter_test.dart';
import 'package:open_meteo_api/src/models/location.dart';

void main() {
  group('Location', () {
    group('fromJson', () {
      test('returns correct Location object', () {
        expect(
            Location.fromJson(<String, dynamic>{
              'id': 4887398,
              'name': 'Chicago',
              'latitude': 41.85003,
              'longitude': -87.65005,
            }),
            isA<Location>()
                .having((l) => l.id, 'id', 4887398)
                .having((l) => l.name, 'name', 'Chicago')
                .having((l) => l.latitude, 'latitude', 41.85003)
                .having((l) => l.longitude, 'longitude', -87.65005));
      });
    });
  });
}
