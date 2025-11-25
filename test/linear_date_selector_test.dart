import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:linear_date_selector/linear_date_selector.dart';

void main() {
  group('LinearDateSelector widget tests', () {
    final baseDate = DateTime(
      2025,
      01,
      01,
    ); // deterministic base date for tests

    testWidgets('renders correct number of tiles', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              todaysDateTime: baseDate,
              itemCount: 5,
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      // The widget shows the date (day or dd). We check for the day text or date text:
      for (var i = 0; i < 5; i++) {
        final dateString = DateFormat(
          'dd',
        ).format(baseDate.add(Duration(days: i)));
        expect(
          find.text(dateString),
          findsOneWidget,
          reason: 'Tile for day index $i (date=$dateString) should be present.',
        );
      }
    });

    testWidgets('tapping enabled tile triggers callback and selects', (
      WidgetTester tester,
    ) async {
      final List<DateTime> selected = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              todaysDateTime: baseDate,
              itemCount: 3,
              onDateTimeSelected: (dt) => selected.add(dt),
            ),
          ),
        ),
      );

      // Tap the second tile (index 1)
      final dateIndex = 1;
      final dateText = DateFormat(
        'dd',
      ).format(baseDate.add(Duration(days: dateIndex)));
      expect(find.text(dateText), findsOneWidget);

      await tester.tap(find.text(dateText));
      await tester.pumpAndSettle();

      // Callback invoked with expected DateTime
      expect(selected.length, 1);
      expect(selected[0].year, baseDate.add(Duration(days: dateIndex)).year);
      expect(
        DateFormat('yyyy-MM-dd').format(selected[0]),
        DateFormat(
          'yyyy-MM-dd',
        ).format(baseDate.add(Duration(days: dateIndex))),
      );
    });

    testWidgets('tapping disabled tile does not trigger callback', (
      WidgetTester tester,
    ) async {
      final List<DateTime> selected = [];
      final disabled = [baseDate.add(const Duration(days: 2))];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              todaysDateTime: baseDate,
              itemCount: 4,
              disabledDateTimes: disabled,
              onDateTimeSelected: (dt) => selected.add(dt),
            ),
          ),
        ),
      );

      final disabledText = DateFormat('dd').format(disabled.first);
      expect(find.text(disabledText), findsOneWidget);

      await tester.tap(find.text(disabledText));
      await tester.pumpAndSettle();

      // Callback should not be called for disabled tile
      expect(selected, isEmpty);
    });

    testWidgets('uses custom itemBuilder when provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector.builder(
              todaysDateTime: baseDate,
              itemCount: 3,
              onDateTimeSelected: (_) {},
              itemBuilder:
                  (context, date, isSelected, isDisabled, index, style) {
                    // Return a widget with a unique Key we can find in tests
                    return Container(
                      key: Key('custom_tile_$index'),
                      child: Text('CUSTOM ${DateFormat('dd').format(date)}'),
                    );
                  },
            ),
          ),
        ),
      );

      // Assert our custom widgets are used
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(Key('custom_tile_$i')), findsOneWidget);
        expect(find.textContaining('CUSTOM'), findsNWidgets(3));
      }
    });

    testWidgets(
      'icon alignment displays icon in expected place when provided (smoke test)',
      (WidgetTester tester) async {
        // This is a smoke test verifying the icon widget is present when passed.
        final icon = const Icon(Icons.star);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LinearDateSelector(
                todaysDateTime: baseDate,
                itemCount: 1,
                icon: icon,
                iconAlignment: LinearDateSelectorIconAlignment.top,
                onDateTimeSelected: (_) {},
              ),
            ),
          ),
        );

        // There should be an Icon widget in the tree
        expect(find.byIcon(Icons.star), findsOneWidget);
      },
    );
  });
  test('throws assertion error when itemCount is 0', () {
    expect(
      () => LinearDateSelector(
        todaysDateTime: DateTime(2025, 1, 1),
        itemCount: 0,
        onDateTimeSelected: (_) {},
      ),
      throwsA(isA<AssertionError>()),
    );
  });
}
