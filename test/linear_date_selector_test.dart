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
              startDateTime: baseDate,
              itemCount: 5,
              itemWidth: 80,
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
              startDateTime: baseDate,
              itemCount: 3,
              itemWidth: 80,
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
              startDateTime: baseDate,
              itemCount: 4,
              itemWidth: 80,
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
              startDateTime: baseDate,
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
                startDateTime: baseDate,
                itemCount: 1,
                itemWidth: 80,
                listPadding: EdgeInsets.all(8),
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
    test('throws assertion error when itemCount is 0', () {
      expect(
        () => LinearDateSelector(
          startDateTime: DateTime(2025, 1, 1),
          itemCount: 0,
          onDateTimeSelected: (_) {},
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    testWidgets('click animation triggers scale animation when enabled', (
      WidgetTester tester,
    ) async {
      // Build widget with a reasonable tile width so layout is stable.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              startDateTime: baseDate,
              itemCount: 1,
              itemWidth: 80,
              enableClickAnimation: true,
              scaleAnimationDuration: const Duration(milliseconds: 120),
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      final tileText = DateFormat('dd').format(baseDate);

      // Helper: finds the nearest Transform ancestor to the tile text.
      Transform? findNearestTransform() {
        final Element textElement = tester.element(find.text(tileText));
        Transform? nearest;
        textElement.visitAncestorElements((ancestor) {
          if (ancestor.widget is Transform) {
            nearest = ancestor.widget as Transform;
            return false; // stop walking — nearest found
          }
          return true; // continue walking
        });
        return nearest;
      }

      // Before tap — scale should be ~1.0
      final before = findNearestTransform();
      expect(
        before,
        isNotNull,
        reason: 'Expected a Transform ancestor before tap',
      );
      expect((before!.transform.storage[0] - 1.0).abs() < 1e-6, isTrue);

      // Tap to start the scale animation
      await tester.tap(find.text(tileText));
      await tester.pump(); // kick off animation

      // Poll for a short period (frame by frame) to observe any intermediate scale > 1.0
      final duration = const Duration(
        milliseconds: 120,
      ); // matches widget scaleAnimationDuration
      final int stepMs = 16;
      int elapsed = 0;
      bool sawScaled = false;
      while (elapsed <= duration.inMilliseconds) {
        await tester.pump(Duration(milliseconds: stepMs));
        elapsed += stepMs;

        final t = findNearestTransform();
        if (t != null) {
          final currentScale = t.transform.storage[0];
          if (currentScale > 1.0 + 1e-6) {
            sawScaled = true;
            break;
          }
        }
      }

      // We must have observed the tile scale > 1.0 at least once.
      expect(
        sawScaled,
        isTrue,
        reason:
            'Expected to observe a scale > 1.0 during the forward animation but did not.',
      );

      // Let animation finish and verify it returned to 1.0
      await tester.pumpAndSettle();
      final finalT = findNearestTransform();
      expect(finalT, isNotNull);
      final finalScale = finalT!.transform.storage[0];
      expect(
        (finalScale - 1.0).abs() < 1e-6,
        isTrue,
        reason: 'Expected final scale to return to 1.0, got $finalScale',
      );
    });

    testWidgets(
      'click animation does not trigger when enableClickAnimation=false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LinearDateSelector(
                startDateTime: baseDate,
                itemCount: 1,
                itemWidth: 80,
                enableClickAnimation: false,
                onDateTimeSelected: (_) {},
              ),
            ),
          ),
        );

        final tileText = DateFormat('dd').format(baseDate);

        await tester.tap(find.text(tileText));
        await tester.pump(); // no animation should start

        // Verify there is NO Transform.scale animation happening
        final transform = tester.widget<Transform>(
          find.byType(Transform).first,
        );
        expect((transform.transform.storage[0]).toStringAsFixed(2), '1.00');
      },
    );

    testWidgets('color animation is used when enableColorAnimation=true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              startDateTime: baseDate,
              itemCount: 1,
              itemWidth: 80,
              enableColorAnimation: true,
              textColorChangeDuration: Duration(milliseconds: 300),
              backgroundColorChangeDuration: Duration(milliseconds: 300),
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      final tileText = DateFormat('dd').format(baseDate);

      // Tap start
      await tester.tap(find.text(tileText));
      await tester.pump();

      // AnimatedContainer should still be mid-animation at shorter pump
      final animatedContainer = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );
      expect(animatedContainer.duration, Duration(milliseconds: 300));
    });
    testWidgets(
      'color animation duration becomes zero when enableColorAnimation=false',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LinearDateSelector(
                startDateTime: baseDate,
                itemCount: 1,
                itemWidth: 80,
                enableColorAnimation: false,
                // durations are ignored when flag is OFF
                textColorChangeDuration: Duration(milliseconds: 500),
                backgroundColorChangeDuration: Duration(milliseconds: 500),
                onDateTimeSelected: (_) {},
              ),
            ),
          ),
        );

        final animatedContainer = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer).first,
        );

        // Duration should be zero
        expect(animatedContainer.duration, Duration.zero);
      },
    );
    testWidgets('disabled tile applies disabled colors', (
      WidgetTester tester,
    ) async {
      final disabledDate = baseDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              startDateTime: baseDate,
              itemCount: 1,
              itemWidth: 80,
              disabledDateTimes: [disabledDate],
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer).first,
      );

      expect(container.decoration, isA<BoxDecoration>());

      final box = container.decoration as BoxDecoration;

      // Should use disabledTileBackgroundColor
      expect(
        box.color,
        equals(const DateSelectorStyle().disabledTileBackgroundColor),
      );
    });

    testWidgets('scaleAnimationDuration controls animation speed', (
      WidgetTester tester,
    ) async {
      final duration = Duration(milliseconds: 800);
      const double targetScale = 1.12;
      const double epsilon = 1e-6;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector(
              startDateTime: baseDate,
              itemCount: 1,
              itemWidth: 80,
              listPadding: EdgeInsets.all(8),
              scaleAnimationDuration: duration,
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      final tile = DateFormat('dd').format(baseDate);

      // Start the tap (animation starts)
      await tester.tap(find.text(tile));
      await tester.pump(); // start animation

      // Find nearest Transform ancestor helper (closure)
      Transform? findNearestTransform() {
        final Element textElement = tester.element(find.text(tile));
        Transform? nearest;
        textElement.visitAncestorElements((ancestor) {
          if (ancestor.widget is Transform) {
            nearest = ancestor.widget as Transform;
            return false;
          }
          return true;
        });
        return nearest;
      }

      bool sawScaled = false;
      final int stepMs = 16; // approx one frame at 60Hz
      int elapsed = 0;

      // Poll in small steps until duration; check if scale ever moves > 1.0
      while (elapsed <= duration.inMilliseconds) {
        await tester.pump(Duration(milliseconds: stepMs));
        elapsed += stepMs;

        final t = findNearestTransform();
        if (t != null) {
          final currentScale = t.transform.storage[0];
          if (currentScale > 1.0 + epsilon &&
              currentScale < targetScale - epsilon) {
            sawScaled = true;
            break;
          }
        }
      }

      // assert we saw the forward animation at some point
      expect(
        sawScaled,
        isTrue,
        reason:
            'Expected to observe a scale > 1.0 during the forward animation but did not.',
      );

      // Now let animation finish and verify it returned to 1.0
      await tester.pumpAndSettle();
      final finalTransform = findNearestTransform();
      expect(finalTransform, isNotNull);
      final finalScale = finalTransform!.transform.storage[0];
      expect(
        (finalScale - 1.0).abs() < 1e-6,
        isTrue,
        reason:
            'Expected scale to return to 1.0 after animation, got $finalScale',
      );
    });
    testWidgets('dateRange is inclusive (start..end both included)', (
      WidgetTester tester,
    ) async {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 3); // inclusive → 3 tiles: 01,02,03

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector.dateRange(
              startDateTime: start,
              endDateTime: end,
              itemWidth: 80,
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      // Expect 3 date tiles with dd texts 01,02,03
      for (var i = 0; i <= end.difference(start).inDays; i++) {
        final dateString = DateFormat(
          'dd',
        ).format(start.add(Duration(days: i)));
        expect(find.text(dateString), findsOneWidget);
      }
    });

    testWidgets('dateRange normalizes time-of-day (partial-day case)', (
      WidgetTester tester,
    ) async {
      // start at 23:00 and end at 01:00 next day — should yield two calendar days
      final start = DateTime(2025, 12, 1, 23, 0);
      final end = DateTime(2025, 12, 2, 1, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector.dateRange(
              startDateTime: start,
              endDateTime: end,
              itemWidth: 80,
              onDateTimeSelected: (_) {},
            ),
          ),
        ),
      );

      // Expect two tiles: 01 and 02
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
    });

    testWidgets('dateRangeBuilder uses custom itemBuilder across the range', (
      WidgetTester tester,
    ) async {
      final start = DateTime(2025, 6, 10);
      final end = DateTime(2025, 6, 12); // inclusive -> 3 tiles

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector.dateRangeBuilder(
              startDateTime: start,
              endDateTime: end,

              onDateTimeSelected: (_) {},
              itemBuilder:
                  (context, date, isSelected, isDisabled, index, style) {
                    return Container(
                      key: Key('range_custom_$index'),
                      child: Text('RANGE ${DateFormat('dd').format(date)}'),
                    );
                  },
            ),
          ),
        ),
      );

      // Should find three custom keys and three custom texts
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(Key('range_custom_$i')), findsOneWidget);
      }
      expect(find.textContaining('RANGE'), findsNWidgets(3));
    });

    testWidgets(
      'dateRange regenerates when widget is rebuilt with new start/end (smoke)',
      (WidgetTester tester) async {
        // Start with 1..3
        final startA = DateTime(2025, 4, 1);
        final endA = DateTime(2025, 4, 3);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LinearDateSelector.dateRange(
                startDateTime: startA,
                endDateTime: endA,
                itemWidth: 80,
                onDateTimeSelected: (_) {},
              ),
            ),
          ),
        );

        // Ensure initial date '01' exists
        expect(find.text('01'), findsOneWidget);
        expect(find.text('03'), findsOneWidget);

        // Rebuild with shifted range 2025-04-05 .. 2025-04-06
        final startB = DateTime(2025, 4, 5);
        final endB = DateTime(2025, 4, 6);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LinearDateSelector.dateRange(
                startDateTime: startB,
                endDateTime: endB,
                itemWidth: 80,
                onDateTimeSelected: (_) {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Old dates should no longer be present; new dates should be present
        expect(find.text('01'), findsNothing);
        expect(find.text('05'), findsOneWidget);
        expect(find.text('06'), findsOneWidget);
      },
    );

    test(
      'dateRange constructor asserts when end is before start (calendar day)',
      () {
        // end before start on calendar day -> should assert
        final start = DateTime(2025, 7, 10, 10);
        final end = DateTime(2025, 7, 9, 23);

        expect(
          () => LinearDateSelector.dateRange(
            startDateTime: start,
            endDateTime: end,
            onDateTimeSelected: (_) {},
          ),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    testWidgets('dateRange respects disabledDateTimes in the range', (
      WidgetTester tester,
    ) async {
      final start = DateTime(2025, 9, 1);
      final end = DateTime(2025, 9, 3); // 3 tiles total
      final disabled = [DateTime(2025, 9, 2)];

      final selected = <DateTime>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LinearDateSelector.dateRange(
              startDateTime: start,
              endDateTime: end,
              itemWidth: 80,
              disabledDateTimes: disabled,
              onDateTimeSelected: (dt) => selected.add(dt),
            ),
          ),
        ),
      );

      // Tap the disabled middle tile (02)
      final disabledText = DateFormat('dd').format(disabled.first);
      expect(find.text(disabledText), findsOneWidget);

      await tester.tap(find.text(disabledText));
      await tester.pumpAndSettle();

      expect(
        selected,
        isEmpty,
        reason: 'Tapping a disabled tile must not trigger the callback.',
      );
    });
  });
}
