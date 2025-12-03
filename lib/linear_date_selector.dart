import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ---------------------------------------------------------------------------
/// LinearDateSelector
/// A customizable horizontal or vertical **linear date selector** for Flutter.
///
/// This widget displays a sequential list of dates starting from a given
/// `startDateTime`. It supports:
///
/// - the built-in **default tile UI**, or
/// - a fully customizable tile via a `builder` (similar to `ListView.builder`)
///
/// giving developers complete freedom to design date tiles that match the
/// style and requirements of their apps.
///
/// ---------------------------------------------------------------------------
/// ## Features
///
/// - Auto-generated date list starting from `startDateTime`
/// - Optional **calendar date-range mode** (inclusive)
/// - Horizontal or vertical scrolling using `ListView`
/// - Customizable appearance via `DateSelectorStyle`
/// - Disable specific dates
/// - Built-in selection state management
/// - Optional icon with adjustable alignment (top / bottom / left / right)
/// - Tap-scale animation on selection
/// - Smooth background & text color animations
/// - Fully customizable tile rendering using:
///
/// ```dart
/// LinearDateSelector.builder(...)
/// ```
///
/// ---------------------------------------------------------------------------
/// ## Custom Item Builder
///
/// Pass your own `itemBuilder` for full tile customization:
///
/// ```dart
/// LinearDateSelector.builder(
///   startDateTime: DateTime.now(),
///   itemCount: 7,
///   disabledDateTimes: [...],
///   onDateTimeSelected: (date) {},
///   itemBuilder: (context, date, isSelected, isDisabled, index, style) {
///     return YourCustomTileWidget(
///       date: date,
///       isSelected: isSelected,
///       isDisabled: isDisabled,
///     );
///   },
/// );
/// ```
///
/// ### Role of `index` in `itemBuilder`
/// The `index` helps you:
/// - Know which tile is being built
/// - Apply unique styling to first/last items
/// - Add animations or staggered effects
/// - Implement special logic (weekends, markers, separators)
/// - Ease debugging & logging
///
/// ---------------------------------------------------------------------------
/// ## When to Use This Widget
///
/// Use `LinearDateSelector` when you need:
///
/// - Lightweight calendar-style pickers
/// - Appointment or delivery date selectors
/// - Horizontal or vertical date scrollers
/// - Timeline-style date UIs
/// - A customizable date strip without heavy calendar packages
///
/// ---------------------------------------------------------------------------
/// ## Constructor Options
///
/// ### 1. `LinearDateSelector` (default)
/// Build a fixed number of sequential dates using the built-in tile UI.
///
/// ### 2. `LinearDateSelector.builder`
/// Custom renderer for each tile — total control over UI.
///
/// ### 3. `LinearDateSelector.dateRange`
/// Inclusive date-range selector (default tile UI).
/// Time-of-day values are ignored; only calendar days matter.
///
/// ### 4. `LinearDateSelector.dateRangeBuilder`
/// A date-range version that also uses a custom `itemBuilder`.
///
/// ---------------------------------------------------------------------------
/// ## Author Notes
///
/// `LinearDateSelector` is designed for:
/// - flexibility
/// - clean UI
/// - easy customization
///
/// Perfect for apps needing a lightweight date picker without the overhead of
/// a full calendar widget.
///
/// ---------------------------------------------------------------------------
///
/// Below begins the actual implementation.
/// ---------------------------------------------------------------------------

/// Alignment options for the optional icon inside each date tile.
enum LinearDateSelectorIconAlignment { top, bottom, left, right }

class LinearDateSelector extends StatefulWidget {
  /// Creates a date selector with the default tile UI.
  const LinearDateSelector({
    super.key,
    this.style = const DateSelectorStyle(),
    required this.startDateTime,
    this.disabledDateTimes = const [],
    required this.onDateTimeSelected,
    this.itemCount = 4,
    this.axis = Axis.horizontal,
    this.itemWidth,
    this.itemHeight,
    this.icon,
    this.iconAlignment = LinearDateSelectorIconAlignment.bottom,
    this.listPadding = EdgeInsets.zero,
    this.enableClickAnimation = true,
    this.textColorChangeDuration = const Duration(milliseconds: 200),
    this.backgroundColorChangeDuration = const Duration(milliseconds: 200),
    this.enableColorAnimation = false,
    this.scaleAnimationDuration = const Duration(milliseconds: 120),
    this.physics,
    this.controller,
  }) : itemBuilder = null,
       endDateTime = null,
       assert(itemCount > 0, 'itemCount must be greater than 0');

  /// Creates a date selector using your custom builder.
  ///
  /// Works like `ListView.builder`: you get `date`, `isSelected`,
  /// `isDisabled`, and `index` for maximum customization.
  /// /// - A custom itemBuilder **must** be provided.
  const LinearDateSelector.builder({
    super.key,
    this.style = const DateSelectorStyle(),
    required this.startDateTime,
    this.disabledDateTimes = const [],
    required this.onDateTimeSelected,
    this.itemCount = 4,
    this.axis = Axis.horizontal,
    this.itemWidth,
    this.itemHeight,
    required this.itemBuilder,
    this.listPadding = EdgeInsets.zero,
    this.enableClickAnimation = true,
    this.scaleAnimationDuration = const Duration(milliseconds: 120),
    this.controller,
    this.physics,
  }) : icon = null,
       iconAlignment = LinearDateSelectorIconAlignment.bottom,
       textColorChangeDuration = null,
       backgroundColorChangeDuration = null,
       enableColorAnimation = false,
       endDateTime = null,
       assert(itemCount > 0, 'itemCount must be greater than 0');

  /// Creates a date selector for a continuous **calendar date range**, using the
  /// widget’s **default tile UI**.
  ///
  /// This constructor is similar to `.range`, but it performs additional
  /// protections to ensure the range is based on full calendar days rather than
  /// exact timestamps.
  ///
  /// ### Key Behaviors
  /// - Time-of-day values are stripped: only **year/month/day** are used.
  /// - The `endDateTime` must represent a **later calendar day** than
  ///   `startDateTime`, otherwise an assertion fails.
  /// - The range is **inclusive**, meaning both the start and end dates
  ///   produce tiles.
  /// - `itemBuilder` is automatically set to `null`, so the widget uses the
  ///   built-in default tile UI.
  ///
  /// Example:
  /// `start = Jan 1` and `end = Jan 3` → tiles for Jan 1, Jan 2, Jan 3 (3 tiles).
  LinearDateSelector.dateRange({
    super.key,
    this.style = const DateSelectorStyle(),
    required this.startDateTime,
    required this.endDateTime,
    this.disabledDateTimes = const [],
    required this.onDateTimeSelected,
    this.axis = Axis.horizontal,
    this.itemWidth,
    this.itemHeight,
    this.icon,
    this.iconAlignment = LinearDateSelectorIconAlignment.bottom,
    this.listPadding = EdgeInsets.zero,
    this.enableClickAnimation = true,
    this.textColorChangeDuration = const Duration(milliseconds: 200),
    this.backgroundColorChangeDuration = const Duration(milliseconds: 200),
    this.enableColorAnimation = false,
    this.scaleAnimationDuration = const Duration(milliseconds: 120),
    this.physics,
    this.controller,
  }) : itemBuilder = null,
       assert(
         endDateTime != null &&
             DateTime(
               endDateTime.year,
               endDateTime.month,
               endDateTime.day,
             ).isAfter(
               DateTime(
                 startDateTime.year,
                 startDateTime.month,
                 startDateTime.day,
               ),
             ),
         'endDateTime must be after startDateTime (based on calendar date)',
       ),

       // Compute itemCount using calendar-day difference (inclusive).
       itemCount =
           DateTime(endDateTime!.year, endDateTime.month, endDateTime.day)
               .difference(
                 DateTime(
                   startDateTime.year,
                   startDateTime.month,
                   startDateTime.day,
                 ),
               )
               .inDays +
           1;

  /// Creates a date selector for a calendar range **with a custom itemBuilder**.
  ///
  /// This constructor is similar to `.builder`, except that you specify
  /// both `startDateTime` and `endDateTime`, and the widget automatically
  /// computes the number of calendar days in the range.
  ///
  /// Notes:
  /// - Time-of-day values are ignored. Only **calendar dates** matter.
  /// - The range is **inclusive** of both start and end dates.
  ///   Example: Jan 1 → Jan 3 produces 3 tiles.
  /// - A custom itemBuilder **must** be provided.
  LinearDateSelector.dateRangeBuilder({
    super.key,
    this.style = const DateSelectorStyle(),
    required this.startDateTime,
    required this.endDateTime,
    this.disabledDateTimes = const [],
    required this.onDateTimeSelected,
    this.axis = Axis.horizontal,
    this.itemWidth,
    this.itemHeight,
    this.icon,
    this.iconAlignment = LinearDateSelectorIconAlignment.bottom,
    this.listPadding = EdgeInsets.zero,
    this.enableClickAnimation = true,
    this.textColorChangeDuration = const Duration(milliseconds: 200),
    this.backgroundColorChangeDuration = const Duration(milliseconds: 200),
    this.enableColorAnimation = false,
    this.scaleAnimationDuration = const Duration(milliseconds: 120),
    this.physics,
    this.controller,
    required this.itemBuilder,
  }) : assert(
         endDateTime != null &&
             DateTime(
               endDateTime.year,
               endDateTime.month,
               endDateTime.day,
             ).isAfter(
               DateTime(
                 startDateTime.year,
                 startDateTime.month,
                 startDateTime.day,
               ),
             ),
         'endDateTime must be after startDateTime (based on calendar date)',
       ),

       // Compute itemCount using calendar-day difference (inclusive).
       itemCount =
           DateTime(endDateTime!.year, endDateTime.month, endDateTime.day)
               .difference(
                 DateTime(
                   startDateTime.year,
                   startDateTime.month,
                   startDateTime.day,
                 ),
               )
               .inDays +
           1;

  /// Starting date from where the list begins.
  ///
  /// Item at index `0` will be this date.
  final DateTime startDateTime;

  /// Ending date from where the list ends. (Optional)
  final DateTime? endDateTime;

  /// Callback triggered when any date is tapped.
  ///
  /// Provides the selected `DateTime` back to the parent widget.
  final Function(DateTime) onDateTimeSelected;

  /// List of dates that should appear disabled
  /// (non-selectable and styled differently).
  final List<DateTime> disabledDateTimes;

  /// Number of date tiles to generate.
  ///
  /// Example: `7` → next 7 days including today.
  final int itemCount;

  /// Layout direction for the date list.
  ///
  /// `Axis.horizontal` for row scrolling (default),
  /// `Axis.vertical` for column scrolling.
  final Axis axis;

  /// Custom width of each date tile.
  ///
  /// If null, defaults to 64px.
  final double? itemWidth;

  /// Custom height of each date tile.
  ///
  /// If null, defaults to 65px.
  final double? itemHeight;

  /// Style configuration for tile colors, padding, and border appearance.
  final DateSelectorStyle style;

  /// Optional icon to display inside each tile.
  ///
  /// Example: a calendar icon, dot marker, etc.
  final Icon? icon;

  /// Controls where the optional icon appears:
  /// top, bottom, left, or right of the text.
  final LinearDateSelectorIconAlignment iconAlignment;

  /// Padding applied around the scrollable list.
  final EdgeInsets listPadding;

  /// Enables the tap animation (scale-in → scale-out).
  ///
  /// Set to false for instant selection without animation.
  final bool enableClickAnimation;

  /// Duration for the background color animation of each tile.
  ///
  /// Applies only when using the default tile UI.
  /// When a tile becomes selected/unselected/disabled, its background color
  /// transitions smoothly over this duration.
  ///
  /// If you use the `.builder` constructor, this value is `null` because
  /// background animation becomes the responsibility of your custom builder.
  final Duration? backgroundColorChangeDuration;

  /// Duration for animating text (and icon) color changes.
  ///
  /// Used by `AnimatedDefaultTextStyle` and icon color animation inside the
  /// default tile UI. Ensures that text color fades smoothly when the tile's
  /// state changes (normal → selected → disabled).
  ///
  /// This value is `null` in the `.builder` constructor because custom tiles
  /// are expected to manage their own text animations.
  final Duration? textColorChangeDuration;

  /// When true, text & icon color changes (and background color) animate
  /// using the configured durations. When false, color changes are instant.
  ///
  /// Defaults to `false` in your current constructors.
  final bool enableColorAnimation;

  /// Duration used for the scale (tap) animation when a tile is pressed.
  ///
  /// Controls how quickly the tile grows/shrinks during the click animation.
  /// Only used when `enableClickAnimation` is true.
  final Duration? scaleAnimationDuration;

  /// Optional physics for ListView.
  final ScrollPhysics? physics;

  /// Optional scroll controller for ListView.
  final ScrollController? controller;

  /// Custom tile builder provided by the developer.
  ///
  /// Parameters give complete control:
  /// - `date` → current tile date
  /// - `isSelected` → highlighted or not
  /// - `isDisabled` → non-selectable state
  /// - `index` → tile index in the list
  /// - `style` → style configuration
  ///
  /// If null, the widget uses its own default tile.
  final Widget Function(
    BuildContext context,
    DateTime date,
    bool isSelected,
    bool isDisabled,
    int index,
    DateSelectorStyle style,
  )?
  itemBuilder;

  @override
  State<LinearDateSelector> createState() => _LinearDateSelectorState();
}

class _LinearDateSelectorState extends State<LinearDateSelector> {
  /// Stores the index currently selected by the user.
  ///
  /// Defaults to -1 (meaning nothing selected yet).
  int selectedIndex = -1;

  static final DateFormat _dayFmt = DateFormat('E');
  static final DateFormat _dateFmt = DateFormat('dd');
  static final DateFormat _monthFmt = DateFormat('MMM');

  /// Precomputed list of consecutive date-only DateTimes shown by the selector.
  /// Regenerated in initState and didUpdateWidget when inputs change.
  late List<DateTime> _dates;

  /// Set of string keys for fast disabled-date lookup.
  ///
  /// Each key is `'yyyy-M-d'`. Using a Set makes `isDisabled` checks O(1).
  late Set<String> _disabledDateKeys;

  /// Helper: convert a DateTime to date-only (local calendar day).
  DateTime _dateOnly(DateTime d) {
    final local = d.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  /// Compute total calendar days for the range (inclusive).
  /// If [end] is null, return [fallbackItemCount].
  int _computeTotalDays(DateTime start, DateTime? end, int fallbackItemCount) {
    if (end == null) return fallbackItemCount;
    final startDateOnly = _dateOnly(start);
    final endDateOnly = _dateOnly(end);
    final days = endDateOnly.difference(startDateOnly).inDays + 1; // inclusive
    return days > 0 ? days : 0;
  }

  /// Generate the `_dates` list and `_disabledDateKeys` based on current widget.
  void _generateDates() {
    final totalDays = _computeTotalDays(
      widget.startDateTime,
      widget.endDateTime,
      widget.itemCount,
    );
    final base = _dateOnly(widget.startDateTime);

    _dates = List.generate(totalDays, (i) => base.add(Duration(days: i)));

    _disabledDateKeys = widget.disabledDateTimes
        .map((d) => _dateOnly(d))
        .map((dd) => '${dd.year}-${dd.month}-${dd.day}')
        .toSet();

    // If previously selected index is now out of range, reset it.
    if (selectedIndex >= _dates.length) {
      selectedIndex = -1;
    }
  }

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  @override
  void didUpdateWidget(covariant LinearDateSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Regenerate dates when relevant inputs change.
    // Compare the raw objects — this is sufficient for most cases.
    if (oldWidget.startDateTime != widget.startDateTime ||
        oldWidget.endDateTime != widget.endDateTime ||
        oldWidget.itemCount != widget.itemCount ||
        oldWidget.disabledDateTimes != widget.disabledDateTimes) {
      _generateDates();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: widget.listPadding,
      shrinkWrap: true,
      // Use the generated list as the single source of truth.
      itemCount: _dates.length,
      physics: widget.physics,
      controller: widget.controller,
      scrollDirection: widget.axis,
      itemBuilder: (context, index) {
        final DateTime currElement = _dates[index];

        /// Check if this date exists in the disabled list.
        final bool isDisabled = _disabledDateKeys.contains(
          '${currElement.year}-${currElement.month}-${currElement.day}',
        );

        /// Whether this tile is currently selected.
        final bool isSelected = selectedIndex == index;

        Widget tile;

        // If the user provides a custom tile builder,
        // use it instead of the default tile.
        if (widget.itemBuilder != null) {
          // Use custom builder provided by user
          tile = widget.itemBuilder!(
            context,
            currElement,
            isSelected,
            isDisabled,
            index,
            widget.style,
          );
        } else {
          tile = _defaultTileBuilder(
            context,
            currElement,
            isSelected,
            isDisabled,
            index,
          );
        }

        final scaleDuration =
            widget.scaleAnimationDuration ?? const Duration(milliseconds: 120);

        return _TapScale(
          enabled: widget.enableClickAnimation,
          scaleDuration: scaleDuration,
          onTap: () {
            if (isDisabled) return;
            setState(() {
              selectedIndex = index;
            });
            // Use normalized date (from _dates) so callback gets date-only values.
            widget.onDateTimeSelected(_dates[index]);
          },
          child: SizedBox(
            width: widget.itemWidth ?? 64,
            height: widget.itemHeight ?? 65,
            child: tile,
          ),
        );
      },
    );
  }

  /// Default tile UI used when no custom builder is provided.
  Widget _defaultTileBuilder(
    BuildContext context,
    DateTime currElement,
    bool isSelected,
    bool isDisabled,
    int index,
  ) {
    final String date = _dayFmt.format(currElement);
    final String day = _dateFmt.format(currElement);
    final String month = _monthFmt.format(currElement);

    final bgDuration = widget.enableColorAnimation
        ? (widget.backgroundColorChangeDuration ??
              const Duration(milliseconds: 200))
        : Duration.zero;
    final textDuration = widget.enableColorAnimation
        ? (widget.textColorChangeDuration ?? const Duration(milliseconds: 200))
        : Duration.zero;

    return AnimatedContainer(
      duration: bgDuration,
      margin: EdgeInsets.symmetric(
        horizontal: widget.axis == Axis.horizontal ? 8 : 0,
        vertical: widget.axis == Axis.horizontal ? 0 : 8,
      ),
      decoration: BoxDecoration(
        color: isDisabled
            ? widget.style.disabledTileBackgroundColor
            : isSelected
            ? widget.style.selectedTileBackgroundColor
            : widget.style.tileBackgroundColor,
        border: Border.all(
          color: isDisabled
              ? widget.style.disabledBorderColor
              : isSelected
              ? widget.style.selectedBorderColor
              : widget.style.borderColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (widget.iconAlignment == LinearDateSelectorIconAlignment.left &&
              widget.icon != null)
            Container(
              padding: widget.style.iconPadding,
              child: IconTheme(
                data: IconThemeData(
                  color: isDisabled
                      ? widget.style.disabledTextColor
                      : isSelected
                      ? widget.style.selectedTextColor
                      : Colors.black,
                ),
                child: widget.icon!,
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (widget.iconAlignment == LinearDateSelectorIconAlignment.top &&
                  widget.icon != null)
                Container(
                  padding: widget.style.iconPadding,
                  child: IconTheme(
                    data: IconThemeData(
                      color: isDisabled
                          ? widget.style.disabledTextColor
                          : isSelected
                          ? widget.style.selectedTextColor
                          : Colors.black,
                    ),
                    child: widget.icon!,
                  ),
                ),
              //day text
              AnimatedDefaultTextStyle(
                duration: textDuration,
                style: TextStyle(
                  fontSize: 14,
                  color: isDisabled
                      ? widget.style.disabledTextColor
                      : isSelected
                      ? widget.style.selectedTextColor
                      : Colors.black,
                ),
                child: Text(day),
              ),
              const SizedBox(height: 2),
              //date text
              AnimatedDefaultTextStyle(
                duration: textDuration,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: isDisabled
                      ? widget.style.disabledTextColor
                      : isSelected
                      ? widget.style.selectedTextColor
                      : Colors.black,
                ),
                child: Text(date),
              ),
              const SizedBox(height: 2),
              //month text
              AnimatedDefaultTextStyle(
                duration: textDuration,
                style: TextStyle(
                  fontSize: 12,
                  color: isDisabled
                      ? widget.style.disabledTextColor
                      : isSelected
                      ? widget.style.selectedTextColor
                      : Colors.black,
                ),
                child: Text(month),
              ),
              if (widget.iconAlignment ==
                      LinearDateSelectorIconAlignment.bottom &&
                  widget.icon != null)
                Container(
                  padding: widget.style.iconPadding,
                  child: IconTheme(
                    data: IconThemeData(
                      color: isDisabled
                          ? widget.style.disabledTextColor
                          : isSelected
                          ? widget.style.selectedTextColor
                          : Colors.black,
                    ),
                    child: widget.icon!,
                  ),
                ),
            ],
          ),
          if (widget.iconAlignment == LinearDateSelectorIconAlignment.right &&
              widget.icon != null)
            Container(
              padding: widget.style.iconPadding,
              child: IconTheme(
                data: IconThemeData(
                  color: isDisabled
                      ? widget.style.disabledTextColor
                      : isSelected
                      ? widget.style.selectedTextColor
                      : Colors.black,
                ),
                child: widget.icon!,
              ),
            ),
        ],
      ),
    );
  }
}

/// Styling options for customizing tile appearance.
///
/// Includes colors, paddings, borders, and text styles.
class DateSelectorStyle {
  /// Background color for normal (unselected) tiles.
  final Color tileBackgroundColor;

  /// Background color for the selected tile.
  final Color selectedTileBackgroundColor;

  /// Border color for normal tiles.
  final Color borderColor;

  /// Border color for the selected tile.
  final Color selectedBorderColor;

  /// Text and icon color when selected.
  final Color selectedTextColor;

  /// Background color for disabled tiles.
  final Color disabledTileBackgroundColor;

  /// Text and icon color for disabled tiles.
  final Color disabledTextColor;

  /// Border color for disabled tiles.
  final Color disabledBorderColor;

  /// Space around the optional icon inside the tile.
  final EdgeInsets? iconPadding;

  const DateSelectorStyle({
    this.tileBackgroundColor = Colors.white,
    this.selectedBorderColor = Colors.grey,
    this.selectedTextColor = Colors.white,
    this.borderColor = Colors.grey,
    this.selectedTileBackgroundColor = Colors.blue,
    this.disabledTileBackgroundColor = Colors.blueGrey,
    this.disabledTextColor = Colors.black,
    this.disabledBorderColor = Colors.grey,
    this.iconPadding = const EdgeInsets.all(8),
  });
}

class _TapScale extends StatefulWidget {
  /// The child widget to display and animate (usually the date tile).
  final Widget child;

  /// Whether the tap-to-scale animation is enabled.
  ///
  /// If false, the wrapper simply calls `onTap` without playing the scale.
  final bool enabled;

  /// Callback invoked after the tap (and after animation completes when
  /// `enabled` is true).
  final VoidCallback? onTap;

  /// Duration of the scale animation (forward + reverse use this controller's duration).
  final Duration scaleDuration;
  const _TapScale({
    required this.child,
    this.enabled = true,
    this.onTap,
    required this.scaleDuration,
  });

  @override
  State<_TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<_TapScale>
    with SingleTickerProviderStateMixin {
  /// Animation controller that drives the scale animation.
  late final AnimationController _c;

  /// Scale animation from 1.0 → 1.12 (or configured tween).
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.scaleDuration);
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  Future<void> _play() async {
    if (!widget.enabled) return widget.onTap?.call();
    await _c.forward();
    await _c.reverse();
    widget.onTap?.call();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: _play,
    child: AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: widget.child,
    ),
  );
}
