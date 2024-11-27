import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropdown Field Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ValueNotifier<String?> selectedValue = ValueNotifier<String?>(null);

  final List<Map<String, dynamic>> items = [
    {'id': '1', 'name': 'Option 1'},
    {'id': '2', 'name': 'Option 2'},
    {'id': '3', 'name': 'Option 3'},
  ];

  void changeDropdownValue(String? newValue) {
    // 在这里你可以通过任何逻辑来改变 selectedValue 的值
    selectedValue.value = newValue;
  }

  void resetDropdownValue() {
    // 重置下拉框的值
    dropdownFieldKey.currentState?.reset();
  }

  final GlobalKey<DropdownFieldState> dropdownFieldKey = GlobalKey<DropdownFieldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dropdown Field Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            DropdownField(
              key: dropdownFieldKey,
              width: 200,
              height: 48,
              hint: 'Select an option',
              label: true,
              items: items,
              selectedValue: selectedValue,
              onChanged: (String? newValue) {
                // 当用户选择了新的值时触发
                print('Selected value: $newValue');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // 改变下拉框的值为下一个选项
                // int currentIndex = items.indexWhere((item) => item['id'] == selectedValue.value);
                // int nextIndex = (currentIndex + 1) % items.length;
                // changeDropdownValue(items[nextIndex]['id']);
                selectedValue.value = '1';
              },
              child: Text('Change Value'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resetDropdownValue,
              child: Text('Reset Value'),
            ),
          ],
        ),
      ),
    );
  }
}

class DropdownField extends StatefulWidget {
  final double width;
  final double height;
  final String hint;
  final bool? label;
  final List<Map<String, dynamic>> items; // 修改为 Map 列表
  final ValueNotifier<String?> selectedValue; // 使用 ValueNotifier 来管理选中的值
  final void Function(String?)? onChanged; // 修改为 String? 类型

  const DropdownField({
    Key? key,
    required this.width,
    required this.height,
    required this.hint,
    required this.items,
    required this.selectedValue, // 必须传入一个 ValueNotifier
    this.label,
    this.onChanged,
  }) : super(key: key);

  @override
  DropdownFieldState createState() => DropdownFieldState();
}

class DropdownFieldState extends State<DropdownField> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.selectedValue.addListener(_updateSelectedValue); // 监听 selectedValue 的变化
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _isHovered.value = false;
    }
    setState(() {});
  }

  void _updateSelectedValue() {
    // 当 selectedValue 变化时更新 UI
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _isHovered.dispose();
    widget.selectedValue.removeListener(_updateSelectedValue); // 移除监听
    super.dispose();
  }

  void reset() {
    setState(() {
      widget.selectedValue.value = null;
    });
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: MouseRegion(
        onEnter: (_) => _isHovered.value = true,
        onExit: (_) => _isHovered.value = false,
        child: ValueListenableBuilder<bool>(
          valueListenable: _isHovered,
          builder: (context, isHovered, _) {
            // 确保 selectedValue 存在于 items 中
            final hasSelectedValue = widget.items.any((item) => item['id'] == widget.selectedValue.value);
            final effectiveValue = hasSelectedValue ? widget.selectedValue.value : null;

            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: DropdownButtonFormField<String>(
                focusNode: _focusNode,
                value: effectiveValue, // 使用 effectiveValue 而不是直接使用 selectedValue
                hint: effectiveValue == null ? Text(widget.hint) : null,
                onChanged: (String? newValue) {
                  widget.selectedValue.value = newValue; // 更新 selectedValue
                  if (widget.onChanged != null) {
                    widget.onChanged!(newValue);
                  }
                },
                items: widget.items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['id'],
                    child: Text(
                      item['name'], // 显示的值是 name
                      style: const TextStyle(
                        color: Color(0xFF423F3F),
                        fontSize: 14,
                        fontFamily: 'PingFang SC',
                        fontWeight: FontWeight.w400,
                        height: 1.2,
                      ),
                    ),
                  );
                }).toList(),
                style: const TextStyle(
                  color: Color(0xFF423F3F),
                  fontSize: 14,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  labelText: widget.label == true ? widget.hint : null,
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _focusNode.hasFocus ? const Color(0xFF25B7E8) : Colors.grey,
                      width: _focusNode.hasFocus ? 1 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  hoverColor: isHovered ? const Color(0xFF25B7E8) : Colors.transparent,
                  filled: true,
                ),
                icon: const Icon(Icons.arrow_drop_down_outlined),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
      ),
    );
  }
}