import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ---------------------------------------------------------------------------
/// LinearDateSelector
/// A customizable horizontal/vertical date selector widget for Flutter.
///
/// This widget displays a sequential list of dates starting from a given
/// `todaysDateTime`. It supports both **default UI tiles** and a
/// **fully customizable builder** (similar to `ListView.builder`), allowing
/// developers to design their own date tiles.
///
/// ## Features
/// - Auto-generated date list starting from `todaysDateTime`
/// - Horizontal or vertical scrolling using ListView
/// - Customizable appearance via `DateSelectorStyle`
/// - Ability to disable specific dates
/// - Built-in selection state management
/// - Optional icon with adjustable alignment (top, bottom, left, right)
/// - Fully customizable tile rendering using:
///   ```dart
///   LinearDateSelector.builder(...)
///   ```
///
/// ## Custom Item Builder
/// Pass your own `itemBuilder` to fully control each tile:
///
/// ```dart
/// LinearDateSelector.builder(
///   todaysDateTime: DateTime.now(),
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
/// ### Role of `index` in itemBuilder
/// The `index` tells you:
/// - Which item is being built
/// - Helps you apply custom styling for first/last items
/// - Lets you add animation or unique layout patterns
/// - Helps with debugging or logging
///
/// ## When to Use This Widget
/// - Calendar pickers
/// - Appointment selectors
/// - Delivery date options
/// - Horizontal date scrollers
/// - Any UI that needs simple or fully-customizable date selection
///
/// ## Author Notes
/// Designed for flexibility, easy customization, and clean UI.
/// Perfect for apps needing lightweight date selection without heavy calendar packages.
///
/// ---------------------------------------------------------------------------
///
/// Below starts the actual implementation.
/// ---------------------------------------------------------------------------

/// Alignment options for the optional icon inside each date tile.
enum LinearDateSelectorIconAlignment { top, bottom, left, right }

class LinearDateSelector extends StatefulWidget {
  /// Creates a date selector with the default tile UI.
  const LinearDateSelector({
    super.key,
    this.style = const DateSelectorStyle(),
    required this.todaysDateTime,
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
  }) : itemBuilder = null,
       assert(itemCount > 0, 'itemCount must be greater than 0');

  /// Creates a date selector using your custom builder.
  ///
  /// Works like `ListView.builder`: you get `date`, `isSelected`,
  /// `isDisabled`, and `index` for maximum customization.
  const LinearDateSelector.builder({
    super.key,
    this.style = const DateSelectorStyle(),
    required this.todaysDateTime,
    this.disabledDateTimes = const [],
    required this.onDateTimeSelected,
    this.itemCount = 4,
    this.axis = Axis.horizontal,
    this.itemWidth,
    this.itemHeight,
    this.itemBuilder,
    this.listPadding = EdgeInsets.zero,
    this.enableClickAnimation = true,
    this.scaleAnimationDuration = const Duration(milliseconds: 120),
  }) : icon = null,
       iconAlignment = LinearDateSelectorIconAlignment.bottom,
       textColorChangeDuration = null,
       backgroundColorChangeDuration = null,
       enableColorAnimation = false,
       assert(itemCount > 0, 'itemCount must be greater than 0');

  /// Starting date from where the list begins.
  ///
  /// Item at index `0` will be this date.
  final DateTime todaysDateTime;

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

  /// Precomputed list of consecutive dates shown by the selector.
  ///
  /// Built in `initState` (and refreshed in `didUpdateWidget` when inputs
  /// change). Avoids recreating DateTime instances on every build.
  late final List<DateTime> _dates;

  /// Set of string keys for fast disabled-date lookup.
  ///
  /// Each key is `'yyyy-M-d'`. Using a Set makes `isDisabled` checks O(1).
  late final Set<String> _disabledDateKeys;

  @override
  void initState() {
    super.initState();

    _dates = List.generate(
      widget.itemCount,
      (i) => widget.todaysDateTime.add(Duration(days: i)),
    );
    _disabledDateKeys = widget.disabledDateTimes
        .map((d) => '${d.year}-${d.month}-${d.day}')
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: widget.listPadding,
      shrinkWrap: true,
      itemCount: widget.itemCount,
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

        return _TapScale(
          enabled: widget.enableClickAnimation,
          scaleDuration: widget.scaleAnimationDuration!,
          onTap: () {
            if (isDisabled) return;
            setState(() {
              selectedIndex = index;
            });
            widget.onDateTimeSelected(
              widget.todaysDateTime.add(Duration(days: index)),
            );
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

    return AnimatedContainer(
      duration: widget.enableColorAnimation
          ? widget.backgroundColorChangeDuration!
          : Duration.zero,
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
                duration: widget.enableColorAnimation
                    ? widget.textColorChangeDuration!
                    : Duration.zero,
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
                duration: widget.enableColorAnimation
                    ? widget.textColorChangeDuration!
                    : Duration.zero,
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
                duration: widget.enableColorAnimation
                    ? widget.textColorChangeDuration!
                    : Duration.zero,
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
