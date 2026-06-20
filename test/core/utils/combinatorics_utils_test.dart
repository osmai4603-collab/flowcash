import 'package:flutter_test/flutter_test.dart';
import 'package:flowcash/core/utils/combinatorics_utils.dart';

void main() {
  group('CombinatoricsUtils.cartesianProduct', () {
    test('should return correct cartesian product for a list of lists', () {
      final input = [
        ['Red', 'Blue'],
        ['S', 'M', 'L']
      ];

      final expected = [
        ['Red', 'S'],
        ['Red', 'M'],
        ['Red', 'L'],
        ['Blue', 'S'],
        ['Blue', 'M'],
        ['Blue', 'L'],
      ];

      final result = CombinatoricsUtils.cartesianProduct(input);

      expect(result, equals(expected));
    });

    test('should return [[]] if the input list is empty', () {
      final input = <List<String>>[];
      final expected = [[]];

      final result = CombinatoricsUtils.cartesianProduct(input);

      expect(result, equals(expected));
    });

    test('should return [] if any inner list is empty', () {
      final input = [
        ['Red', 'Blue'],
        <String>[],
      ];
      final expected = <List<String>>[];

      final result = CombinatoricsUtils.cartesianProduct(input);

      expect(result, equals(expected));
    });

    test('should work with single element pools', () {
      final input = [
        ['Red'],
        ['S'],
        ['Cotton']
      ];

      final expected = [
        ['Red', 'S', 'Cotton']
      ];

      final result = CombinatoricsUtils.cartesianProduct(input);

      expect(result, equals(expected));
    });
  });
}
