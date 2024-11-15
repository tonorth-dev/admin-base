import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Cascading Dropdown Field')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CascadingDropdownField(
            width: 160,
            height: 34,
            hint1: 'Level 1',
            hint2: 'Level 2',
            hint3: 'Level 3',
            level1Items: [
              {'id': 1, 'name': 'Item 1'},
              {'id': 2, 'name': 'Item 2'},
            ],
            level2Items: {
              '1': [
                {'id': 11, 'name': 'Subitem 1-1'},
                {'id': 12, 'name': 'Subitem 1-2'},
              ],
              '2': [
                {'id': 21, 'name': 'Subitem 2-1'},
                {'id': 22, 'name': 'Subitem 2-2'},
              ],
            },
            level3Items: {
              '11': [
                {'id': 111, 'name': 'Subsubitem 1-1-1'},
                {'id': 112, 'name': 'Subsubitem 1-1-2'},
              ],
              '12': [
                {'id': 121, 'name': 'Subsubitem 1-2-1'},
                {'id': 122, 'name': 'Subsubitem 1-2-2'},
              ],
              '21': [
                {'id': 211, 'name': 'Subsubitem 2-1-1'},
                {'id': 212, 'name': 'Subsubitem 2-1-2'},
              ],
              '22': [
                {'id': 221, 'name': 'Subsubitem 2-2-1'},
                {'id': 222, 'name': 'Subsubitem 2-2-2'},
              ],
            },
            onChanged: (level1, level2, level3) {
              print('Selected: Level 1: $level1, Level 2: $level2, Level 3: $level3');
            },
          ),
        ),
      ),
    );
  }
}

class CascadingDropdownField extends StatefulWidget {
  final double width;
  final double height;
  final String hint1;
  final String hint2;
  final String hint3;
  final List<Map<String, dynamic>> level1Items;
  final Map<String, List<Map<String, dynamic>>> level2Items;
  final Map<String, List<Map<String, dynamic>>> level3Items;
  final Function(dynamic, dynamic, dynamic)? onChanged;

  const CascadingDropdownField({
    Key? key,
    required this.width,
    required this.height,
    this.hint1 = '',
    this.hint2 = '',
    this.hint3 = '',
    required this.level1Items,
    required this.level2Items,
    required this.level3Items,
    this.onChanged,
  }) : super(key: key);

  @override
  CascadingDropdownFieldState createState() => CascadingDropdownFieldState();
}

class CascadingDropdownFieldState extends State<CascadingDropdownField> {
  dynamic selectedLevel1;
  dynamic selectedLevel2;
  dynamic selectedLevel3;

  final TextEditingController _level1Controller = TextEditingController();
  final TextEditingController _level2Controller = TextEditingController();
  final TextEditingController _level3Controller = TextEditingController();

  final FocusNode _level1FocusNode = FocusNode();
  final FocusNode _level2FocusNode = FocusNode();
  final FocusNode _level3FocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void reset() {
    setState(() {
      selectedLevel1 = null;
      selectedLevel2 = null;
      selectedLevel3 = null;
      _level1Controller.clear();
      _level2Controller.clear();
      _level3Controller.clear();
    });
    widget.onChanged?.call(null, null, null);
  }

  void _onLevel1Changed(Map<String, dynamic> newValue) {
    setState(() {
      selectedLevel1 = newValue['id'];
      _level1Controller.text = newValue['name'];
      selectedLevel2 = null;
      selectedLevel3 = null;
      _level2Controller.clear();
      _level3Controller.clear();
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  void _onLevel2Changed(Map<String, dynamic> newValue) {
    setState(() {
      selectedLevel2 = newValue['id'];
      _level2Controller.text = newValue['name'];
      selectedLevel3 = null;
      _level3Controller.clear();
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  void _onLevel3Changed(Map<String, dynamic> newValue) {
    setState(() {
      selectedLevel3 = newValue['id'];
      _level3Controller.text = newValue['name'];
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildTypeAheadField(
          controller: _level1Controller,
          focusNode: _level1FocusNode,
          hint: widget.hint1,
          items: widget.level1Items,
          onSuggestionSelected: _onLevel1Changed,
        ),
        SizedBox(width: 8),
        _buildTypeAheadField(
          controller: _level2Controller,
          focusNode: _level2FocusNode,
          hint: widget.hint2,
          items: selectedLevel1 != null ? widget.level2Items[selectedLevel1.toString()] ?? [] : [],
          onSuggestionSelected: _onLevel2Changed,
        ),
        SizedBox(width: 8),
        _buildTypeAheadField(
          controller: _level3Controller,
          focusNode: _level3FocusNode,
          hint: widget.hint3,
          items: selectedLevel2 != null ? widget.level3Items[selectedLevel2.toString()] ?? [] : [],
          onSuggestionSelected: _onLevel3Changed,
        ),
      ],
    );
  }

  Widget _buildTypeAheadField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required List<Map<String, dynamic>> items,
    required Function(Map<String, dynamic>) onSuggestionSelected,
  }) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: TypeAheadField<Map<String, dynamic>>(
        textFieldConfiguration: TextFieldConfiguration(
        // builder: (context, controller, focusNode) => TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: focusNode.hasFocus ? const Color(0xFF25B7E8) : Colors.grey,
                width: focusNode.hasFocus ? 1 : 0.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF423F3F),
              fontSize: 14,
              fontFamily: 'PingFang SC',
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
            fillColor: Colors.white,
            filled: true,
          ),
          style: const TextStyle(
            color: Color(0xFF423F3F),
            fontSize: 14,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
            height: 1.2,
          ),
        ),
        suggestionsCallback: (pattern) {
          if (pattern.isEmpty) {
            // Display all items when only clicked, without filtering
            return items;
          } else {
            // Filter items when user types
            return items.where((item) => item['name'].toLowerCase().contains(pattern.toLowerCase())).toList();
          }
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(
              suggestion['name'],
              style: const TextStyle(
                color: Color(0xFF423F3F),
                fontSize: 14,
                fontFamily: 'PingFang SC',
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
            ),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            controller.text = suggestion['name']; // 更新控制器的文本
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length)); // 设置选区到文本末尾
          });
          onSuggestionSelected(suggestion);
        },
        noItemsFoundBuilder: (context) => SizedBox(
          height: 50,
          child: Center(child: Text('No items found', style: const TextStyle(color: Color(0xFF423F3F)))),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _level1Controller.dispose();
    _level2Controller.dispose();
    _level3Controller.dispose();
    _level1FocusNode.dispose();
    _level2FocusNode.dispose();
    _level3FocusNode.dispose();
    super.dispose();
  }
}