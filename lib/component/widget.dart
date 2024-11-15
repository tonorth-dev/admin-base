import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;

  const CustomButton({
    Key? key,
    required this.onPressed,
    required this.text,
    this.width = 90, // 默认宽度
    this.height = 32, // 默认高度
  }) : super(key: key);

  @override
  _CustomButtonState createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _isHovered.value = true,
      onExit: (_) => _isHovered.value = false,
      child: ValueListenableBuilder<bool>(
        valueListenable: _isHovered,
        builder: (context, isHovered, _) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100),
            width: widget.width,
            height: widget.height,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isHovered ? Color(0xFF25B7E8) : Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                  spreadRadius: 0,
                )
              ],
            ),
            child: TextButton(
              onPressed: widget.onPressed,
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                foregroundColor: MaterialStateProperty.all(Colors.transparent),
                backgroundColor: MaterialStateProperty.all(Colors.transparent),
              ),
              child: Center(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    color: isHovered ? Colors.white : Color(0xFF423F3F),
                    fontSize: 14,
                    fontFamily: 'PingFang SC',
                    fontWeight: FontWeight.w400,
                    height: 1.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _isHovered.dispose();
    super.dispose();
  }
}

class ButtonState with ChangeNotifier {
  bool _isHovered = false;

  bool get isHovered => _isHovered;

  void setHovered(bool value) {
    _isHovered = value;
    notifyListeners();
  }
}

class DropdownField extends StatefulWidget {
  final double width;
  final double height;
  final String hint;
  final List<Map<String, dynamic>> items; // 修改为 Map 列表
  final dynamic value; // 修改为 dynamic 类型
  final Function(dynamic)? onChanged; // 修改为 dynamic 类型

  const DropdownField({
    Key? key,
    required this.width,
    required this.height,
    required this.hint,
    required this.items,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  DropdownFieldState createState() => DropdownFieldState();
}

class DropdownFieldState extends State<DropdownField> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  dynamic selectedValue; // 修改为 dynamic 类型
  bool _isSelected = false;
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
    selectedValue = widget.value;
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _isHovered.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _isHovered.value = false;
      _isSelected = false;
      selectedValue = null;
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_focusNode.hasFocus) {
        setState(() {
          selectedValue = null;
          _isSelected = false;
        });
      }
    }
  }

  void reset() {
    setState(() {
      selectedValue = null;
      _isSelected = false;
    });
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: FocusScope(
        node: FocusScopeNode(),
        child: MouseRegion(
          onEnter: (_) => _isHovered.value = true,
          onExit: (_) => _isHovered.value = false,
          child: ValueListenableBuilder<bool>(
            valueListenable: _isHovered,
            builder: (context, isHovered, _) {
              return SizedBox(
                width: widget.width,
                height: widget.height,
                child: DropdownButtonFormField<dynamic>(
                  focusNode: _focusNode,
                  value: selectedValue,
                  hint: selectedValue == null ? Text(widget.hint) : null,
                  onChanged: (dynamic newValue) {
                    setState(() {
                      selectedValue = newValue;
                      _isSelected = newValue != null;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(newValue);
                    }
                  },
                  items: widget.items.map((item) {
                    return DropdownMenuItem<dynamic>(
                      value: item['id'], // 选择的值是 id
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
                    labelText: widget.hint,
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
                        color: _focusNode.hasFocus ? const Color(0xFF25B7E8) : Colors.grey,
                        width: _focusNode.hasFocus ? 1 : 0.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    focusColor: _focusNode.hasFocus ? const Color(0xFF25B7E8) : Colors.transparent,
                    hoverColor: isHovered ? const Color(0xFF25B7E8) : Colors.transparent,
                    fillColor: _isSelected ? Colors.white : Colors.transparent,
                    filled: true,
                  ),
                  icon: const Icon(Icons.arrow_drop_down_outlined),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
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

class SearchBoxWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onTextChanged;
  final RxString searchText;

  const SearchBoxWidget({
    Key? key,
    required this.hint,
    required this.onTextChanged,
    required this.searchText,
  }) : super(key: key);

  @override
  _SearchBoxWidgetState createState() => _SearchBoxWidgetState();
}

class _SearchBoxWidgetState extends State<SearchBoxWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchText.value);
    widget.searchText.listen((value) {
      _controller.text = value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      width: 120,
      child: TextField(
        key: const Key('search_box'),
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 12,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: widget.onTextChanged,
        onSubmitted: (value) => widget.onTextChanged(value),
      ),
    );
  }
}

class SearchButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const SearchButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 34,
      decoration: ShapeDecoration(
        color: Color(0xFFD43030),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          '查询',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
            height: 0.09,
          ),
        ),
      ),
    );
  }
}

class ResetButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;

  const ResetButtonWidget({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 34,
      decoration: ShapeDecoration(
        color: Color(0x80706f6d),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          '重置',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
            height: 0.09,
          ),
        ),
      ),
    );
  }
}


class SearchAndButtonWidget extends StatelessWidget {
  final String hint;
  final VoidCallback onSearch;

  const SearchAndButtonWidget({Key? key, required this.onSearch, required this.hint}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(width: 6),
          SizedBox(
            height: 34,
            width: 120,
            child: TextField(
              key: const Key('search_box'),
              decoration: InputDecoration(
                hintText: hint, hintStyle: const TextStyle(
                  color: Color(0xFF999999),
                  fontSize: 12,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onSubmitted: (value) => onSearch(),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 80,
            height: 34,
            decoration: ShapeDecoration(
              color: Color(0xFFD43030),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: TextButton(
              onPressed: onSearch,
              child: Text(
                '搜索',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 0.09,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}












