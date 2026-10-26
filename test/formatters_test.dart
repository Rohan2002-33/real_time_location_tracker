import 'package:flutter_test/flutter_test.dart';
import 'package:real_time_location_tracker/core/formatters.dart';

void main() {
  group('Formatters', () {
    test('distance uses metres below 1 km', () {
      expect(Formatters.distance(250.4), '250 m');
    });

    test('distance uses km from 1 km', () {
      expect(Formatters.distance(1500), '1.50 km');
    });

    test('time is zero padded', () {
      expect(Formatters.time(DateTime(2026, 1, 1, 9, 5, 7)), '09:05:07');
    });

    test('coordinate keeps six decimals', () {
      expect(Formatters.coordinate(23.7216771), '23.721677');
    });

    test('accuracy is rounded', () {
      expect(Formatters.accuracy(4.4), '±4 m');
    });

    test('duration formats minutes and seconds', () {
      expect(Formatters.duration(const Duration(minutes: 2, seconds: 5)), '2m 5s');
    });
  });
}