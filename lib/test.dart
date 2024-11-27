import 'package:flutter/material.dart';
import 'component/widget.dart'; // 导入 CascadingDropdownField

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<dynamic> selectedLevel1 = ValueNotifier(null);
  final ValueNotifier<dynamic> selectedLevel2 = ValueNotifier(null);
  final ValueNotifier<dynamic> selectedLevel3 = ValueNotifier(null);

  final List<Map<String, dynamic>> level1Items = [
    {'id': 1, 'name': 'Level 1-1'},
    {'id': 2, 'name': 'Level 1-2'},
  ];
  final Map<String, List<Map<String, dynamic>>> level2Items = {
    '1': [
      {'id': 11, 'name': 'Level 2-1-1'},
      {'id': 12, 'name': 'Level 2-1-2'},
    ],
    '2': [
      {'id': 21, 'name': 'Level 2-2-1'},
      {'id': 22, 'name': 'Level 2-2-2'},
    ],
  };
  final Map<String, List<Map<String, dynamic>>> level3Items = {
    '11': [
      {'id': 111, 'name': 'Level 3-1-1-1'},
      {'id': 112, 'name': 'Level 3-1-1-2'},
    ],
    '12': [
      {'id': 121, 'name': 'Level 3-1-2-1'},
      {'id': 122, 'name': 'Level 3-1-2-2'},
    ],
    '21': [
      {'id': 211, 'name': 'Level 3-2-1-1'},
      {'id': 212, 'name': 'Level 3-2-1-2'},
    ],
    '22': [
      {'id': 221, 'name': 'Level 3-2-2-1'},
      {'id': 222, 'name': 'Level 3-2-2-2'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Cascading Dropdown Field Example')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CascadingDropdownField(
                width: 160,
                height: 34,
                hint1: '专业类目一',
                hint2: '专业类目二',
                hint3: '专业名称',
                level1Items: level1Items,
                level2Items: level2Items,
                level3Items: level3Items,
                selectedLevel1: selectedLevel1,
                selectedLevel2: selectedLevel2,
                selectedLevel3: selectedLevel3,
                onChanged: (dynamic level1, dynamic level2, dynamic level3) {
                  print('Selected: $level1, $level2, $level3');
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  selectedLevel1.value = 1; // 更新 selectedLevel1
                },
                child: Text('Set Level 1 to 1'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  selectedLevel2.value = 11; // 更新 selectedLevel2
                },
                child: Text('Set Level 2 to 11'),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  selectedLevel3.value = 111; // 更新 selectedLevel3
                },
                child: Text('Set Level 3 to 111'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}