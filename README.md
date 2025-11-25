# linear_date_selector

A lightweight, customizable horizontal/vertical date selector widget for Flutter.

`linear_date_selector` provides a simple, robust UI for showing a linear sequence of dates (for example: today + next N days) with built-in selection and disabled-date support — while also allowing a fully custom tile builder similar to `ListView.builder`.

---

## Features

- Auto-generated date list starting from a provided `todaysDateTime`.
- Horizontal or vertical scrolling.
- Default, polished tile UI out of the box.
- Fully-customizable tile rendering with `LinearDateSelector.builder(...)`.
- Disable specific dates to make them non-selectable.
- Optional icon with flexible alignment: `top`, `bottom`, `left`, `right`.
- Simple API and small footprint — no heavy calendar dependency.

---

## Getting started

Add the package to your `pubspec.yaml` (when published on pub.dev):

```yaml
dependencies:
  linear_date_selector: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## Usage

### Default tiles (quick start)

```dart
import 'package:flutter/material.dart';
import 'package:linear_date_selector/linear_date_selector.dart';

// inside a widget build
LinearDateSelector(
  todaysDateTime: DateTime.now(),
  itemCount: 7,
  onDateTimeSelected: (selected) {
    print('selected: $selected');
  },
  // optional
  icon: Icon(Icons.event),
  iconAlignment: LinearDateSelectorIconAlignment.bottom,
);
```

### Custom builder (full control)

```dart
LinearDateSelector.builder(
  todaysDateTime: DateTime.now(),
  itemCount: 7,
  disabledDateTimes: [DateTime.now().add(Duration(days: 2))],
  onDateTimeSelected: (selected) {
    // handle selection
  },
  itemBuilder: (context, date, isSelected, isDisabled, index, style) {
    // return any widget; here's an example:
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDisabled
            ? Colors.grey.shade300
            : isSelected
                ? Colors.blue
                : Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(DateFormat('E').format(date)),
          Text(DateFormat('dd').format(date)),
        ],
      ),
    );
  },
);
```

> **Note:** The `index` parameter corresponds to the tile's position (0 is `todaysDateTime`). Use it for special styling (e.g., first/last tile) or animations.

---

## API

### `LinearDateSelector`

Constructors:

- `LinearDateSelector(...)` — defaults with built-in tile UI.
- `LinearDateSelector.builder(...)` — use a custom `itemBuilder`.

Important properties:

- `todaysDateTime` — `DateTime` where the list starts (index 0).
- `onDateTimeSelected` — `Function(DateTime)` callback when a date is chosen.
- `disabledDateTimes` — `List<DateTime>` of dates that should be rendered disabled.
- `itemCount` — number of tiles to show (must be > 0).
- `axis` — `Axis.horizontal` (default) or `Axis.vertical`.
- `itemWidth`, `itemHeight` — optional size of each tile.
- `icon`, `iconAlignment` — optional icon and position.
- `itemBuilder` — `Widget Function(BuildContext context, DateTime date, bool isSelected, bool isDisabled, int index, DateSelectorStyle style)?` for fully-custom tile rendering.

### `DateSelectorStyle`

A simple style holder to customize tile colors, border colors and icon padding. Pass it into the widget's `style:` parameter to tweak the default tile appearance.

---

## Example: disabling dates

```dart
final today = DateTime.now();
final disabled = [
  DateTime(today.year, today.month, today.day + 2),
];

LinearDateSelector(
  todaysDateTime: today,
  itemCount: 7,
  disabledDateTimes: disabled,
  onDateTimeSelected: (date) {
    // will not be fired for disabled dates
  },
);
```

---

## Tips & Gotchas

- `itemCount` must be > 0 — otherwise an assert will fail.
- `disabledDateTimes` is matched by day/month/year. Time components are ignored.
- `selectedIndex` is stored locally in the widget state. If you need external control of selection, wrap the selector and use the `onDateTimeSelected` callback to synchronize selection state.

---

## Contributing

Contributions, bug reports, and feature requests are welcome. Open an issue or submit a PR.

When contributing, please:

- Follow the repository's `analysis_options.dart` and formatting conventions.
- Add tests for behavior-critical changes (selection, disabled logic, and builder behavior).

---

## Changelog

- 0.0.1 — Initial release: default tiles, builder API, disabled-date support.

---

## License

This project is provided under the BSD-3-Clause / MIT style license (replace with your preferred license). Please update the license file in the repository accordingly.

---

## Author

Created by the package author. Feel free to open issues or PRs for improvements.
