import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linear_date_selector/linear_date_selector.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linear Date Selector',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Linear Date Selector'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<DateTime> dates = [];

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < 30; i++) {
      DateTime date = DateTime.now().add(Duration(days: i));

      if (date.weekday == 7 || date.weekday == 6) {
        dates.add(date);
      }
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              "Default (Horizontal)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            //Default (Horizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 100,
                  child: LinearDateSelector(
                    itemCount: 30,
                    axis: Axis.horizontal,
                    itemWidth: 80,
                    listPadding: EdgeInsets.all(8),
                    style: DateSelectorStyle(
                      selectedTextColor: Colors.blue,
                      selectedTileBackgroundColor: Colors.blue.shade50,
                      selectedBorderColor: Colors.blue,
                      disabledTileBackgroundColor: Colors.red.shade50,
                      disabledBorderColor: Colors.redAccent,
                      disabledTextColor: Colors.red,
                      borderColor: Colors.grey.shade400,
                      tileBackgroundColor: Colors.white,
                    ),
                    disabledDateTimes: dates,
                    onDateTimeSelected: (d) => print('selected $d'),
                    startDateTime: DateTime.now(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            //Default with Icon (Horizontal)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 100,
                  child: LinearDateSelector(
                    itemCount: 20,
                    axis: Axis.horizontal,
                    enableClickAnimation: false,
                    enableColorAnimation: true,
                    itemWidth: 120,
                    icon: Icon(Icons.calendar_month),
                    iconAlignment: LinearDateSelectorIconAlignment.left,
                    style: DateSelectorStyle(
                      selectedTextColor: Colors.blue,
                      selectedTileBackgroundColor: Colors.blue.shade50,
                      selectedBorderColor: Colors.blue,
                      disabledTileBackgroundColor: Colors.grey.shade300,
                      borderColor: Colors.grey.shade400,
                      tileBackgroundColor: Colors.white,
                    ),
                    disabledDateTimes: [
                      DateTime.now().add(const Duration(days: 2)),
                    ],
                    onDateTimeSelected: (d) => print('selected $d'),
                    startDateTime: DateTime.now(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "Default (Vertical)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Default (Vertical)
                SizedBox(
                  width: 80,
                  height: 500,
                  child: LinearDateSelector(
                    itemCount: 20,
                    enableClickAnimation: false,
                    axis: Axis.vertical,
                    itemWidth: 80,
                    itemHeight: 100,
                    style: DateSelectorStyle(
                      selectedTextColor: Colors.blue,
                      selectedTileBackgroundColor: Colors.blue.shade50,
                      selectedBorderColor: Colors.blue,
                      disabledTileBackgroundColor: Colors.grey.shade300,
                      borderColor: Colors.grey.shade400,
                      tileBackgroundColor: Colors.white,
                    ),
                    disabledDateTimes: [
                      DateTime.now(),
                      DateTime.now().add(const Duration(days: 4)),
                    ],
                    onDateTimeSelected: (d) => print('selected $d'),
                    startDateTime: DateTime.now(),
                  ),
                ),
                const SizedBox(width: 24),
                //Default with Icon (Vertical)
                SizedBox(
                  width: 100,
                  height: 500,
                  child: LinearDateSelector(
                    itemCount: 20,
                    axis: Axis.vertical,
                    itemWidth: 80,
                    itemHeight: 100,
                    enableClickAnimation: true,
                    enableColorAnimation: true,
                    // listPadding: EdgeInsets.all(8),
                    style: DateSelectorStyle(
                      selectedTextColor: Colors.blue,
                      selectedTileBackgroundColor: Colors.blue.shade50,
                      selectedBorderColor: Colors.blue,
                      disabledTileBackgroundColor: Colors.grey.shade300,
                      borderColor: Colors.grey.shade400,
                      tileBackgroundColor: Colors.white,
                    ),
                    disabledDateTimes: [
                      DateTime.now(),
                      DateTime.now().add(const Duration(days: 4)),
                    ],
                    onDateTimeSelected: (d) => print('selected $d'),
                    startDateTime: DateTime.now(),
                    iconAlignment: LinearDateSelectorIconAlignment.right,
                    icon: Icon(Icons.calendar_month),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "Custom Tiles (Horizontal)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 120,
                  child: LinearDateSelector.builder(
                    listPadding: EdgeInsets.all(8),
                    startDateTime: DateTime.now(),
                    itemCount: 10,
                    itemHeight: 120,
                    axis: Axis.horizontal,
                    disabledDateTimes: [DateTime.now().add(Duration(days: 4))],
                    onDateTimeSelected: (d) => print('selected $d'),
                    itemBuilder:
                        (context, date, isSelected, isDisabled, index, _) {
                          double _scale = 1.0;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? Colors.grey.shade200
                                  : (isSelected
                                        ? Color(0xFF1e1405)
                                        : Color(0xFFf8e9d7)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey
                                    : (isSelected
                                          ? Color(0xFF1e1405)
                                          : Color(0xFFf8e9d7)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              DateFormat('dd').format(date) +
                                              '\n',
                                          style: TextStyle(fontSize: 28),
                                        ),
                                        TextSpan(
                                          text: DateFormat(
                                            'MMM\nyyyy',
                                          ).format(date),
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDisabled
                                          ? Colors.grey
                                          : (isSelected
                                                ? Color(0xFFf8e9d7)
                                                : Color(0xFF1e1405)),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                // CircleAvatar(backgroundColor: Colors.red),
                              ],
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              "Custom Tiles (Vertical)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).height,
                  child: LinearDateSelector.builder(
                    // physics: NeverScrollableScrollPhysics(),
                    style: DateSelectorStyle(
                      tileBackgroundColor: Color(0xffcbbba2),
                      selectedTileBackgroundColor: Color(0xff3b6856),
                      selectedTextColor: Colors.white,
                      disabledTextColor: Colors.grey,
                      borderColor: Color(0xff91784e),
                      selectedBorderColor: Color(0xff194232),
                    ),
                    startDateTime: DateTime.now(),
                    itemCount: 10,
                    itemHeight: 116,
                    axis: Axis.vertical,
                    disabledDateTimes: [DateTime.now().add(Duration(days: 4))],
                    onDateTimeSelected: (d) => print('selected $d'),
                    itemBuilder:
                        (context, date, isSelected, isDisabled, index, style) {
                          double _scale = 1.0;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? Colors.grey.shade200
                                  : (isSelected
                                        ? style.selectedTileBackgroundColor
                                        : style.tileBackgroundColor),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey
                                    : (isSelected
                                          ? style.selectedBorderColor
                                          : style.borderColor),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat('dd').format(date),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          color: isDisabled
                                              ? style.disabledTextColor
                                              : isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('MMMM').format(date),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: isDisabled
                                              ? style.disabledTextColor
                                              : isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('yyyy').format(date),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isDisabled
                                              ? style.disabledTextColor
                                              : isSelected
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Text(
              "Date Range Selector",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            //Default (Horizontal) With Range
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 100,
                  child: LinearDateSelector.dateRange(
                    axis: Axis.horizontal,
                    itemWidth: 80,
                    listPadding: EdgeInsets.all(8),
                    style: DateSelectorStyle(
                      selectedTextColor: Colors.blue,
                      selectedTileBackgroundColor: Colors.blue.shade50,
                      selectedBorderColor: Colors.blue,
                      disabledTileBackgroundColor: Colors.red.shade50,
                      disabledBorderColor: Colors.redAccent,
                      disabledTextColor: Colors.red,
                      borderColor: Colors.grey.shade400,
                      tileBackgroundColor: Colors.white,
                    ),
                    disabledDateTimes: dates,
                    onDateTimeSelected: (d) => print('selected $d'),
                    startDateTime: DateTime.now(),
                    endDateTime: DateTime.now().add(Duration(days: 7)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            //Custom Tiles (Horizontal) With Range
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: 120,
                  child: LinearDateSelector.dateRangeBuilder(
                    listPadding: EdgeInsets.all(8),
                    startDateTime: DateTime.now(),
                    endDateTime: DateTime.now().add(Duration(days: 4)),
                    itemHeight: 120,
                    axis: Axis.horizontal,
                    disabledDateTimes: [DateTime.now().add(Duration(days: 4))],
                    onDateTimeSelected: (d) => print('selected $d'),
                    itemBuilder:
                        (context, date, isSelected, isDisabled, index, _) {
                          double _scale = 1.0;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDisabled
                                  ? Colors.grey.shade200
                                  : (isSelected
                                        ? Color(0xFF1e1405)
                                        : Color(0xFFf8e9d7)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey
                                    : (isSelected
                                          ? Color(0xFF1e1405)
                                          : Color(0xFFf8e9d7)),
                              ),
                            ),
                            child: Column(
                              children: [
                                Center(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              DateFormat('dd').format(date) +
                                              '\n',
                                          style: TextStyle(fontSize: 28),
                                        ),
                                        TextSpan(
                                          text: DateFormat(
                                            'MMM\nyyyy',
                                          ).format(date),
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDisabled
                                          ? Colors.grey
                                          : (isSelected
                                                ? Color(0xFFf8e9d7)
                                                : Color(0xFF1e1405)),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                // CircleAvatar(backgroundColor: Colors.red),
                              ],
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
