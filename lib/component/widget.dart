import 'dart:ui';

import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_number_picker.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
  final bool? label;
  final List<Map<String, dynamic>> items; // 修改为 Map 列表
  final dynamic value; // 修改为 dynamic 类型
  final Function(dynamic)? onChanged; // 修改为 dynamic 类型

  const DropdownField({
    Key? key,
    required this.width,
    required this.height,
    required this.hint,
    required this.items,
    this.label,
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
                    labelText: widget.label == true ? widget.hint : null,
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.grey,
                        width: 1,
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
                width: 1,
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
                side: BorderSide(width: 1, color:Colors.grey),
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

class TextInputWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onTextChanged;
  final RxString text;
  final double width; // 动态宽度
  final double height; // 动态高度
  final int maxLines; // 最大行数

  const TextInputWidget({
    Key? key,
    required this.hint,
    required this.onTextChanged,
    required this.text,
    this.width = 120, // 默认宽度为120
    this.height = 40, // 默认高度为40
    this.maxLines = 1, // 默认单行输入
  }) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text.value);
    widget.text.listen((value) {
      if (_controller.text != value) {
        _controller.text = value;
      }
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
      height: widget.height,
      width: widget.width, // 动态宽度
      child: TextField(
        key: const Key('text_input_box'),
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 12,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), // 圆角
            borderSide: const BorderSide(color: Colors.grey, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0), // 失焦状态下的边框
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: const BorderSide(color: Colors.grey, width: 1.0), // 聚焦状态下的边框
          ),
          filled: true,
          fillColor: Colors.white, // 背景填充色
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        onChanged: widget.onTextChanged, // 输入时回调
        maxLines: widget.maxLines, // 设置最大行数
      ),
    );
  }
}









class NumberInputWidget extends StatefulWidget {
  final String hint;
  final RxInt selectedValue;
  final double width; // 控件宽度
  final double height; // 控件高度
  final ValueChanged<int> onValueChanged;
  final Key key; // 添加独立 Key

  NumberInputWidget({
    required this.key, // 独立的 Key
    required this.hint,
    required this.selectedValue,
    required this.width,
    required this.height,
    required this.onValueChanged,
  });

  @override
  _NumberInputWidgetState createState() => _NumberInputWidgetState();
}

class _NumberInputWidgetState extends State<NumberInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  GlobalKey _inputKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedValue.value.toString());
    _focusNode = FocusNode();

    // 监听输入框内容变化，同步到 RxInt 和回调
    _controller.addListener(() {
      final text = _controller.text.isEmpty ? '0' : _controller.text;
      final value = int.tryParse(text) ?? 0;
      widget.selectedValue.value = value;
      widget.onValueChanged(value); // 调用回调
      _removeOverlay(); // 输入数字时关闭下拉列表
    });

    // 监听键盘事件，处理上下键调整数字
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        RawKeyboard.instance.addListener(_handleKeyEvent);
      } else {
        RawKeyboard.instance.removeListener(_handleKeyEvent);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    RawKeyboard.instance.removeListener(_handleKeyEvent);
    _removeOverlay();
    super.dispose();
  }

  void _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      final value = widget.selectedValue.value;
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        setState(() {
          widget.selectedValue.value += 1; // 按上键增加 1
        });
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        setState(() {
          widget.selectedValue.value = (value - 1).clamp(0, double.infinity).toInt(); // 按下键减少 1，不小于 0
        });
      }
      _controller.text = widget.selectedValue.value.toString();
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      ); // 将光标移动到末尾
      widget.onValueChanged(widget.selectedValue.value); // 调用回调
    }
  }

  void _showNumberPicker() {
    final RenderBox renderBox = _inputKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  _removeOverlay(); // 点击其他区域时关闭下拉列表
                },
              ),
            ),
            Positioned(
              left: offset.dx,
              top: offset.dy + size.height,
              width: 100, // 下拉列表的宽度
              child: Material(
                elevation: 8.0,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 10, // 默认显示20个选项
                  itemBuilder: (context, index) {
                    final value = index * 1; // 例如每5个数一个选项
                    return InkWell(
                      onTap: () {
                        widget.selectedValue.value = value;
                        _controller.text = value.toString();
                        _controller.selection = TextSelection.fromPosition(
                          TextPosition(offset: _controller.text.length),
                        ); // 将光标移动到末尾
                        widget.onValueChanged(value); // 调用回调
                        _removeOverlay(); // 选中后关闭下拉列表
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(value.toString(), style: TextStyle(fontSize: 14)),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width, // 设置宽度
      height: widget.height, // 设置高度
      child: TextField(
        key: _inputKey,
        controller: _controller,
        focusNode: _focusNode,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // 仅允许数字输入
        ],
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(
            color: Color(0xFF999999),
            fontSize: 12,
            fontFamily: 'PingFang SC',
            fontWeight: FontWeight.w400,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), // 圆角
            borderSide: BorderSide(color: Colors.grey, width: 1.0), // 失焦状态边框颜色
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), // 圆角
            borderSide: BorderSide(color: Colors.grey, width: 1.0), // 聚焦状态边框颜色
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          suffixIcon: IconButton(
            icon: Icon(Icons.arrow_drop_down),
            onPressed: _showNumberPicker,
          ),
        ),
        onChanged: (text) {
          if (text.isEmpty) {
            _controller.text = '0'; // 清空时显示默认值 0
            _controller.selection = TextSelection.fromPosition(
              TextPosition(offset: _controller.text.length),
            ); // 将光标移动到末尾
            widget.selectedValue.value = 0;
            widget.onValueChanged(0); // 调用回调
          }
        },
      ),
    );
  }
}


class SelectableList extends StatefulWidget {
  final RxList<Map<String, dynamic>> items;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onSelected;

  SelectableList({
    required this.items,
    required this.onDelete,
    required this.onSelected,
  });

  @override
  _SelectableListState createState() => _SelectableListState();
}

class _SelectableListState extends State<SelectableList> {
  int selectedIndex = -1; // 初始化为 -1 表示没有选中项

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2), // 减小卡片间距
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(2.0), // 增大圆角
            ),
            color: selectedIndex == index ? Colors.blueGrey[200] : Colors.white,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), // 减小内容内边距
              child: ListTile(
                enableFeedback: false, // 禁用点击动效
                dense: true, // 使 ListTile 更紧凑
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                    widget.onSelected(item); // 调用 onSelected 回调并传递 item
                  });
                },
                title: Text(item['name'] ?? ''),
                trailing: PopupMenuButton<String>(
                  onSelected: (String value) {
                    if (value == "Edit") {
                      _editItem(index);
                    } else if (value == "Delete") {
                      _deleteItem(index);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    // PopupMenuItem<String>(
                    //   value: "Edit",
                    //   child: Text("编辑"),
                    // ),
                    PopupMenuItem<String>(
                      value: "Delete",
                      child: Text("删除"),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final item = widget.items[index];
        TextEditingController _controller = TextEditingController(text: item['name']);
        return AlertDialog(
          title: Text("编辑项目"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "项目名称"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  widget.items[index]['name'] = _controller.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("保存"),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) async {
    final item = widget.items[index];
    try {
      await widget.onDelete(item); // 调用 onDelete 回调并传递 item
      setState(() {
        widget.items.removeAt(index);
        if (selectedIndex >= widget.items.length) {
          selectedIndex = -1; // 如果删除的是最后一个项，重置选中状态
        } else if (selectedIndex == index) {
          selectedIndex = -1; // 如果删除的是当前选中的项，重置选中状态
        }
      });
    } catch (error) {
      "删除失败: $error".toHint();
    }
  }
}









