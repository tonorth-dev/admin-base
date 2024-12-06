import 'package:flutter/material.dart';
import 'component/widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final GlobalKey<ProvinceCityDistrictSelectorState> selectorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('省市区选择器')),
        body: Column(
          children: [
            ProvinceCityDistrictSelector(
              key: selectorKey,
              onChanged: (province, city, district) {
                print("Selected: $province, $city, $district");
              },
            ),
            ElevatedButton(
              onPressed: () {
                selectorKey.currentState?.reset();
              },
              child: Text('重置选择'),
            ),
          ],
        ),
      ),
    );
  }
}
