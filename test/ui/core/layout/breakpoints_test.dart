import 'package:devfest_agenda/ui/core/layout/breakpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('sessionColumnsFor', () {
    test('angosto: 1 columna por debajo de Breakpoints.medium', () {
      expect(sessionColumnsFor(Breakpoints.medium - 1), 1);
    });

    test('medio: 2 columnas desde Breakpoints.medium', () {
      expect(sessionColumnsFor(Breakpoints.medium), 2);
      expect(sessionColumnsFor(Breakpoints.expanded - 1), 2);
    });

    test('ancho: 3 columnas desde Breakpoints.expanded', () {
      expect(sessionColumnsFor(Breakpoints.expanded), 3);
    });
  });
}
