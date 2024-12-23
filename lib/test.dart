import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = WindowOptions(
    size: Size(1600, 900),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter DateTime Picker Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter DateTime Picker Home Page'),
      locale: Locale('zh', 'CN'), // 设置应用程序的默认语言为中文
      supportedLocales: [
        Locale('zh', 'CN'), // 支持的语言和地区
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CustomDateTimePickerController _dateTimeController = CustomDateTimePickerController(initialTime: '2024-12-19 14:30:00');

  @override
  void dispose() {
    _dateTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomDateTimePicker(controller: _dateTimeController), // 使用API提供的初始时间
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _dateTimeController.updateTime('2025-01-01 01:02:00');
                });
              },
              child: Text('Update Time from API'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _dateTimeController.updateTime(null); // 重置为空
                });
              },
              child: Text('Reset Time'),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDateTimePickerController {
  ValueNotifier<String?> _timeNotifier = ValueNotifier<String?>(null);

  CustomDateTimePickerController({String? initialTime}) {
    _timeNotifier.value = initialTime;
  }

  String? get time => _timeNotifier.value;

  Future<void> showPicker(BuildContext context) async {
    final pickedDate = await DateTimePickerWidget.show(
      context: context,
      initialTime: _timeNotifier.value,
    );

    if (pickedDate != null) {
      _timeNotifier.value = _formatDateTime(pickedDate);
    }
  }

  void updateTime(String? newTime) {
    _timeNotifier.value = newTime;
  }

  void dispose() {
    _timeNotifier.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }
}

class CustomDateTimePicker extends StatelessWidget {
  final CustomDateTimePickerController controller;

  CustomDateTimePicker({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: controller._timeNotifier,
      builder: (context, time, child) {
        return Container(
          width: 200,
          height: 40,
          child:
            TextField(
              onTap: () async {
                await controller.showPicker(context);
              },
              readOnly: true, // 禁止直接编辑文本框
              style: const TextStyle(
                color: Color(0xFF505050),
                fontSize: 14,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                labelText: '选择时间',
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide:
                  const BorderSide(color: Colors.black87, width: 1.0), // 非聚焦边框
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(3),
                  borderSide:
                  const BorderSide(color: Colors.black87, width: 1.0), // 聚焦边框
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    await controller.showPicker(context);
                  },
                ),
              ),
              controller: TextEditingController(text: time ?? ''), // 使用controller设置TextField的值
            ),
        );
      },
    );
  }
}

class DateTimePickerWidget {
  static Future<DateTime?> show({
    required BuildContext context,
    String? initialTime,
  }) async {
    final DateTime? initialDate = initialTime != null ? DateTime.parse(initialTime) : DateTime.now();
    final DateTime? pickedDate = await showOmniDateTimePicker(
      context: context,
      type: OmniDateTimePickerType.dateAndTime,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      is24HourMode: true,
      isShowSeconds: false,
      constraints: BoxConstraints(maxWidth: 300), // 限制弹窗的最大宽度
      theme: ThemeData(
        buttonTheme: ButtonThemeData(
          height: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
      ),
    );

    return pickedDate;
  }
}