import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:intl/intl.dart'; // 确保添加这个导入

void main() {
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
        Locale('zh', 'CN'), // 支持的语言和区域
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
  // 这里是模拟从API获取的时间字符串
  String? apiProvidedTime = '2024-12-19 14:30:00';
  TextEditingController _dateTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (apiProvidedTime != null) {
      final parsedDate = DateTime.tryParse(apiProvidedTime!);
      if (parsedDate != null) {
        _dateTimeController.text = _formatDateTime(parsedDate);
      }
    }
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
            CustomDateTimePicker(initialTime: apiProvidedTime, dateTimeController: _dateTimeController), // 使用API提供的初始时间
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 模拟从API更新时间
                setState(() {
                  final currentDate = DateTime.now();
                  _dateTimeController.text = _formatDateTime(currentDate);
                });
              },
              child: Text('Update Time from API'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }
}

class CustomDateTimePicker extends StatelessWidget {
  final String? initialTime;
  final TextEditingController dateTimeController;

  CustomDateTimePicker({Key? key, this.initialTime, required this.dateTimeController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TextField(
          controller: dateTimeController,
          readOnly: true, // 禁止直接编辑文本框
          decoration: InputDecoration(
            labelText: '选择时间',
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () async {
                final DateTime? pickedDate = await showOmniDateTimePicker(
                  context: context,
                  type: OmniDateTimePickerType.dateAndTime,
                  initialDate: initialTime != null ? DateTime.parse(initialTime!) : DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                  is24HourMode: true,
                  isShowSeconds: false,
                );

                if (pickedDate != null) {
                  dateTimeController.text = _formatDateTime(pickedDate);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }
}