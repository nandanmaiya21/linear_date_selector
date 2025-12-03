## 0.0.1

- Initial release of linear_date_selector 🎉
- Added default date selector with built-in tile UI.
- Added fully customizable builder API (`LinearDateSelector.builder`).
- Added disabled-date support (calendar-day based).
- Added optional icon with flexible alignment (top, bottom, left, right).
- Added tap-scale animation with configurable duration.
- Added optional background & text color animations for default tiles.
- Added scroll physics, controller support, customizable tile size, padding.
- Added tests for selection, disabled behavior, animations, custom builder.
- Added documentation, examples, README, screenshots, and API guide.

---

## 0.0.2

- Added **date-range selector**: `LinearDateSelector.dateRange` (inclusive range).
- Added **date-range custom builder**: `LinearDateSelector.dateRangeBuilder`.
- Normalized date-range logic to ignore time-of-day (fixes partial-day bug).
- Added new widget tests for date-range behavior and range reconstruction.
- Improved README with range examples, API docs, and usage guidelines.
- Updated inline Dartdoc comments for constructors + behavior clarity.
