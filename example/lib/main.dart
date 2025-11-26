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
                    listPadding: EdgeInsets.all(8),
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
              "Custom Tiles",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  height: MediaQuery.sizeOf(context).height,
                  child: LinearDateSelector.builder(
                    startDateTime: DateTime.now(),
                    itemCount: 10,
                    itemHeight: 100,
                    axis: Axis.vertical,
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
                                  : (isSelected ? Colors.green : Colors.white),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey
                                    : (isSelected
                                          ? Colors.green
                                          : Colors.black12),
                              ),
                            ),
                            child: Column(
                              children: [
                                Center(
                                  child: Text(
                                    DateFormat('E dd').format(date),
                                    style: TextStyle(
                                      color: isDisabled
                                          ? Colors.grey
                                          : (isSelected
                                                ? Colors.white
                                                : Colors.black87),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                                CircleAvatar(backgroundColor: Colors.red),
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
