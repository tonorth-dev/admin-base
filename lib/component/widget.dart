import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../api/config_api.dart';

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

class DropdownFieldState extends State<DropdownField>
    with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _isHovered = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
    widget.selectedValue
        .addListener(_updateSelectedValue); // 监听 selectedValue 的变化
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
            final hasSelectedValue = widget.items
                .any((item) => item['id'] == widget.selectedValue.value);
            final effectiveValue =
                hasSelectedValue ? widget.selectedValue.value : null;

            return SizedBox(
              width: widget.width,
              height: widget.height,
              child: DropdownButtonFormField<String>(
                focusNode: _focusNode,
                value: effectiveValue,
                // 使用 effectiveValue 而不是直接使用 selectedValue
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
                        height: 1,
                      ),
                    ),
                  );
                }).toList(),
                style: const TextStyle(
                  color: Color(0xFF423F3F),
                  fontSize: 14,
                  fontFamily: 'PingFang SC',
                  fontWeight: FontWeight.w400,
                  height: 1,
                ),
                dropdownColor: Colors.white,
                decoration: InputDecoration(
                  labelText: widget.label == true ? widget.hint : null,
                  border: OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: _focusNode.hasFocus
                          ? const Color(0xFF25B7E8)
                          : Colors.grey,
                      width: _focusNode.hasFocus ? 1 : 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  hoverColor:
                      isHovered ? const Color(0xFF25B7E8) : Colors.transparent,
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

class CascadingDropdownField extends StatefulWidget {
  final List<Map<String, dynamic>> level1Items;
  final Map<String, List<Map<String, dynamic>>> level2Items;
  final Map<String, List<Map<String, dynamic>>> level3Items;
  final String hint1;
  final String hint2;
  final String hint3;
  final double width;
  final double height;
  final ValueNotifier<dynamic> selectedLevel1;
  final ValueNotifier<dynamic> selectedLevel2;
  final ValueNotifier<dynamic> selectedLevel3;
  final void Function(dynamic, dynamic, dynamic)? onChanged;

  const CascadingDropdownField({
    Key? key,
    required this.level1Items,
    required this.level2Items,
    required this.level3Items,
    required this.hint1,
    required this.hint2,
    required this.hint3,
    this.width = 160,
    this.height = 34,
    required this.selectedLevel1,
    required this.selectedLevel2,
    required this.selectedLevel3,
    this.onChanged,
  }) : super(key: key);

  @override
  CascadingDropdownFieldState createState() => CascadingDropdownFieldState();
}

class CascadingDropdownFieldState extends State<CascadingDropdownField> {
  late TextEditingController _level1Controller;
  late TextEditingController _level2Controller;
  late TextEditingController _level3Controller;

  late FocusNode _level1FocusNode;
  late FocusNode _level2FocusNode;
  late FocusNode _level3FocusNode;

  @override
  void initState() {
    super.initState();
    _level1Controller = TextEditingController();
    _level2Controller = TextEditingController();
    _level3Controller = TextEditingController();

    _level1FocusNode = FocusNode();
    _level2FocusNode = FocusNode();
    _level3FocusNode = FocusNode();

    _updateControllers();
    widget.selectedLevel1.addListener(_updateControllers);
    widget.selectedLevel2.addListener(_updateControllers);
    widget.selectedLevel3.addListener(_updateControllers);
  }

  void _updateControllers() {
    setState(() {
      _level1Controller.text =
          _getNameById(widget.level1Items, widget.selectedLevel1.value);
      _level2Controller.text = _getNameById(
          widget.level2Items[widget.selectedLevel1.value.toString()] ?? [],
          widget.selectedLevel2.value);
      _level3Controller.text = _getNameById(
          widget.level3Items[widget.selectedLevel2.value.toString()] ?? [],
          widget.selectedLevel3.value);
    });
  }

  String _getNameById(List<Map<String, dynamic>> items, dynamic id) {
    final item =
        items.firstWhere((element) => element['id'] == id, orElse: () => {});
    return item['name'] ?? '';
  }

  void reset() {
    widget.selectedLevel1.value = null;
    widget.selectedLevel2.value = null;
    widget.selectedLevel3.value = null;
    _level1Controller.clear();
    _level2Controller.clear();
    _level3Controller.clear();
    widget.onChanged?.call(null, null, null);
  }

  void _onLevel1Changed(Map<String, dynamic> newValue) {
    widget.selectedLevel1.value = newValue['id'];
    _level1Controller.text = newValue['name'];
    widget.selectedLevel2.value = null;
    widget.selectedLevel3.value = null;
    _level2Controller.clear();
    _level3Controller.clear();
    widget.onChanged?.call(widget.selectedLevel1.value,
        widget.selectedLevel2.value, widget.selectedLevel3.value);
  }

  void _onLevel2Changed(Map<String, dynamic> newValue) {
    widget.selectedLevel2.value = newValue['id'];
    _level2Controller.text = newValue['name'];
    widget.selectedLevel3.value = null;
    _level3Controller.clear();
    widget.onChanged?.call(widget.selectedLevel1.value,
        widget.selectedLevel2.value, widget.selectedLevel3.value);
  }

  void _onLevel3Changed(Map<String, dynamic> newValue) {
    widget.selectedLevel3.value = newValue['id'];
    _level3Controller.text = newValue['name'];
    widget.onChanged?.call(widget.selectedLevel1.value,
        widget.selectedLevel2.value, widget.selectedLevel3.value);
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
          items: widget.selectedLevel1.value != null
              ? widget.level2Items[widget.selectedLevel1.value.toString()] ?? []
              : [],
          onSuggestionSelected: _onLevel2Changed,
        ),
        SizedBox(width: 8),
        _buildTypeAheadField(
          controller: _level3Controller,
          focusNode: _level3FocusNode,
          hint: widget.hint3,
          items: widget.selectedLevel2.value != null
              ? widget.level3Items[widget.selectedLevel2.value.toString()] ?? []
              : [],
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
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: hint,
            border: OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        suggestionsCallback: (pattern) {
          if (pattern.isEmpty) return items;
          return items
              .where((item) =>
                  item['name'].toLowerCase().contains(pattern.toLowerCase()))
              .toList();
        },
        itemBuilder: (context, suggestion) {
          return ListTile(title: Text(suggestion['name']));
        },
        onSuggestionSelected: onSuggestionSelected,
        noItemsFoundBuilder: (context) => Center(child: Text('No items found')),
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
    widget.selectedLevel1.removeListener(_updateControllers);
    widget.selectedLevel2.removeListener(_updateControllers);
    widget.selectedLevel3.removeListener(_updateControllers);
    super.dispose();
  }
}

class SearchBoxWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onTextChanged;
  final RxString searchText;
  final String buttonText; // 按钮文字
  final double width; // 搜索框宽度
  final double height; // 搜索框高度

  const SearchBoxWidget({
    Key? key,
    required this.hint,
    required this.onTextChanged,
    required this.searchText,
    this.buttonText = "查询", // 默认按钮文字
    this.width = 200, // 默认宽度
    this.height = 34, // 默认高度
  }) : super(key: key);

  @override
  _SearchBoxWidgetState createState() => _SearchBoxWidgetState();
}

class _SearchBoxWidgetState extends State<SearchBoxWidget> {
  late TextEditingController _controller;
  late Worker _worker; // 用于监听 RxString 的变化

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchText.value);

    // Worker 只在 searchText 真正发生变化时更新 controller
    _worker = ever(widget.searchText, (String value) {
      if (_controller.text != value) {
        _controller.text = value;
        _controller.selection = TextSelection.collapsed(offset: value.length);
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: (event) {
        widget.searchText.value = _controller.text;
      },
      child: Row(
        children: [
          SizedBox(
            height: widget.height,
            width: widget.width,
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
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onEditingComplete: () {
                widget.searchText.value = _controller.text;
              },
              onSubmitted: (value) {
                widget.onTextChanged(value);
                widget.searchText.value = value;
              },
            ),
          )
        ],
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

  const SearchAndButtonWidget(
      {Key? key, required this.onSearch, required this.hint})
      : super(key: key);

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
                hintText: hint,
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
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                side: BorderSide(width: 1, color: Colors.grey),
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
  final String hint; // 提示文本
  final ValueChanged<String> onTextChanged; // 输入变化时的回调
  final RxString text; // 用于绑定和监听的文本
  final double width; // 动态宽度
  final double height; // 动态高度
  final int maxLines; // 最大行数
  final FormFieldValidator<String>? validator; // 验证器

  const TextInputWidget({
    Key? key,
    required this.hint,
    required this.onTextChanged,
    required this.text,
    this.width = 120, // 默认宽度为120
    this.height = 40, // 默认高度为40
    this.maxLines = 1, // 默认单行输入
    this.validator, // 验证器
  }) : super(key: key);

  @override
  _TextInputWidgetState createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
  late TextEditingController _controller;
  String? _errorText; // 用于存储错误信息

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text.value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 手动触发验证
  void validate() {
    setState(() {
      _errorText = widget.validator?.call(_controller.text); // 更新错误信息
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height, // 动态高度
      width: widget.width, // 动态宽度
      child: Obx(() {
        // 同步 RxString 和 TextEditingController 的内容
        if (_controller.text != widget.text.value) {
          _controller.text = widget.text.value;
          _controller.selection =
              TextSelection.collapsed(offset: _controller.text.length);
        }

        return TextFormField(
          key: const Key('text_input_box'),
          // 唯一Key
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            // 提示文本
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
              borderSide:
                  const BorderSide(color: Colors.grey, width: 1.0), // 非聚焦边框
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(3),
              borderSide:
                  const BorderSide(color: Colors.grey, width: 1.0), // 聚焦边框
            ),
            filled: true,
            fillColor: Colors.white,
            // 背景填充色
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            suffix: _errorText != null && _errorText!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0), // 左侧间距
                    child: Text(
                      _errorText!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              _errorText = widget.validator?.call(value); // 更新错误信息
            });

            if (widget.text.value != value) {
              widget.text.value = value; // 更新 RxString
              widget.onTextChanged(value); // 输入变化时回调
            }
          },
          maxLines: widget.maxLines, // 设置最大行数
        );
      }),
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
    _controller =
        TextEditingController(text: widget.selectedValue.value.toString());
    _focusNode = FocusNode();

    // 监听 selectedValue 的变化
    widget.selectedValue.listen((value) {
      if (_controller.text != value.toString()) {
        _controller.text = value.toString();
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
      }
    });

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
          widget.selectedValue.value =
              (value - 1).clamp(0, double.infinity).toInt(); // 按下键减少 1，不小于 0
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
    final RenderBox renderBox =
        _inputKey.currentContext!.findRenderObject() as RenderBox;
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
                  itemCount: 20, // 显示20个选项
                  itemBuilder: (context, index) {
                    final value = index * 5; // 例如每5个数一个选项
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
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Text(value.toString(),
                            style: TextStyle(fontSize: 14)),
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
  final Key key;
  final RxList<Map<String, dynamic>> items;
  final Future<void> Function(Map<String, dynamic>) onDelete;
  final Function(Map<String, dynamic>) onSelected;

  SelectableList({
    required this.key,
    required this.items,
    required this.onDelete,
    required this.onSelected,
  }) : super(key: key);

  @override
  SelectableListState createState() => SelectableListState();
}

class SelectableListState extends State<SelectableList> {
  int selectedIndex = -1; // 初始化为 -1 表示没有选中项

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        return ListView.builder(
          itemCount: widget.items.length,
          itemBuilder: (context, index) {
            final item = widget.items[index];
            return InkWell(
              // 使用 InkWell 包裹整个 Card
              onTap: () {
                setState(() {
                  selectedIndex = index;
                  widget.onSelected(item); // 调用 onSelected 回调并传递 item
                });
                refresh(); // 强制刷新列表
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0), // 增大圆角
                ),
                color: selectedIndex == index
                    ? Colors.blueGrey[200]
                    : Colors.white,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ListTile(
                    enableFeedback: false, // 禁用点击动效
                    dense: true, // 使 ListTile 更紧凑
                    title: Text(item['name'] ?? ''),
                    trailing: PopupMenuButton<String>(
                      onSelected: (String value) {
                        if (value == "Edit") {
                          _editItem(index);
                        } else if (value == "Delete") {
                          _confirmDelete(index);
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: "Edit",
                          child: Text("编辑"),
                        ),
                        PopupMenuItem<String>(
                          value: "Delete",
                          child: Text("删除"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _editItem(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final item = widget.items[index];
        TextEditingController _controller =
            TextEditingController(text: item['name']);
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
                refresh(); // 编辑完成后刷新列表
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("删除成功")));
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("删除失败: $error")));
    }
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("确认删除"),
          content: Text("确定要删除这个项目吗？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteItem(index);
              },
              child: Text("删除"),
            ),
          ],
        );
      },
    );
  }
}

class SingleSelectForm extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final Function(Map<String, dynamic>) onSelected;
  final int? defaultSelectedId; // 默认选中的 ID

  const SingleSelectForm({
    Key? key,
    required this.items,
    required this.onSelected,
    this.defaultSelectedId, // 可选参数
  }) : super(key: key);

  @override
  _SingleSelectFormState createState() => _SingleSelectFormState();
}

class _SingleSelectFormState extends State<SingleSelectForm> {
  int? selectedId; // 当前选中的 ID

  @override
  void initState() {
    super.initState();
    // 根据默认选中的 ID 初始化
    selectedId = widget.defaultSelectedId;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widget.items.map((item) {
        final itemId = item['id'];

        return Expanded(
          child: RadioListTile<int>(
            value: itemId,
            groupValue: selectedId,
            onChanged: (int? value) {
              if (value != null) {
                setState(() {
                  selectedId = value;
                  widget.onSelected(item);
                  print("选中值: ${item['name']}"); // 调试日志
                });
              }
            },
            title: Text(
              item['name'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),
            dense: true, // 紧凑布局
          ),
        );
      }).toList(),
    );
  }
}

class HoverTextButton extends StatefulWidget {
  final String text;
  final Function() onTap;

  HoverTextButton({required this.text, required this.onTap});

  @override
  _HoverTextButtonState createState() => _HoverTextButtonState();
}

class _HoverTextButtonState extends State<HoverTextButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.grey[200] : Colors.transparent,
            borderRadius: BorderRadius.circular(10.0), // 可以根据需要调整圆角
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              color: _isHovered ? Colors.red : Color(0xFFFD941D),
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class ProvinceCityDistrictSelector extends StatefulWidget {
  final String? defaultProvince;
  final String? defaultCity;
  final String? defaultDistrict;
  final Function(String?, String?, String?)? onChanged;

  ProvinceCityDistrictSelector({
    this.defaultProvince,
    this.defaultCity,
    this.defaultDistrict,
    this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  ProvinceCityDistrictSelectorState createState() =>
      ProvinceCityDistrictSelectorState();
}

class ProvinceCityDistrictSelectorState
    extends State<ProvinceCityDistrictSelector> {
  final ValueNotifier<String?> selectedProvince = ValueNotifier(null);
  final ValueNotifier<String?> selectedCity = ValueNotifier(null);
  final ValueNotifier<String?> selectedDistrict = ValueNotifier(null);

  List<Map<String, dynamic>>? provinces;
  Map<String, List<Map<String, dynamic>>> cities = {};
  Map<String, List<Map<String, dynamic>>> counties = {};

  Future<List<Map<String, dynamic>>> fetchDivisions({
    required String level,
    String? parentId,
  }) async {
    try {
      var areaData = await ConfigApi.configArea("area", level, parentId);

      List<Map<String, dynamic>> divisions = (areaData as List)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      return divisions;
    } catch (e) {
      print('Error fetching divisions: $e');
      rethrow;
    }
    return [];
  }

  Future<void> fetchProvinces() async {
    try {
      provinces = await fetchDivisions(level: "province");
      setState(() {});
    } catch (e) {
      print('Failed to load provinces: $e');
    }
  }

  Future<void> fetchCities(String provinceId) async {
    try {
      cities[provinceId] =
          await fetchDivisions(level: "city", parentId: provinceId);
      setState(() {});
    } catch (e) {
      print('Failed to load cities: $e');
    }
  }

  Future<void> fetchCounties(String cityId) async {
    try {
      counties[cityId] =
          await fetchDivisions(level: "county", parentId: cityId);
      setState(() {});
    } catch (e) {
      print('Failed to load counties: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProvinces();
    if (widget.defaultProvince != null) {
      selectedProvince.value = widget.defaultProvince;
      fetchCities(widget.defaultProvince!);
      if (widget.defaultCity != null) {
        selectedCity.value = widget.defaultCity;
        fetchCounties(widget.defaultCity!);
        if (widget.defaultDistrict != null) {
          selectedDistrict.value = widget.defaultDistrict;
        }
      }
    }
  }

  void reset() {
    if (!mounted) return; // 避免组件未初始化时调用
    setState(() {
      selectedProvince.value = null;
      selectedCity.value = null;
      selectedDistrict.value = null;
      cities.clear();
      counties.clear();
      fetchProvinces();
    });
    // 显式调用 onChanged 通知外部
    widget.onChanged?.call(null, null, null);
  }

  Widget buildDropdown({
    required ValueNotifier<String?> valueNotifier,
    required List<Map<String, dynamic>>? items,
    required void Function(String?)? onChanged,
    required String hintText,
    bool isEnabled = true,
  }) {
    return ValueListenableBuilder<String?>(
      valueListenable: valueNotifier,
      builder: (context, value, child) {
        return Container(
          width: 140,
          height: 34,
          decoration: BoxDecoration(
            border: Border.all(
              color: isEnabled ? Colors.grey : Colors.grey[300]!,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: DropdownButtonHideUnderline(
            child: Padding(
              padding: EdgeInsets.only(left: 0.0),
              child: DropdownButton<String>(
                value: value,
                items: items?.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['id'],
                    child: Text(
                      item['name'],
                      softWrap: true,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, color: Colors.grey[900]),
                    ),
                  );
                }).toList(),
                onChanged: isEnabled
                    ? (newValue) {
                        onChanged?.call(newValue); // 内部更新
                        widget.onChanged?.call(
                          selectedProvince.value,
                          selectedCity.value,
                          selectedDistrict.value,
                        ); // 通知外部
                      }
                    : null,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down),
                hint: Text(hintText,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700])),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildDropdown(
          valueNotifier: selectedProvince,
          items: provinces,
          onChanged: (newValue) {
            setState(() {
              selectedProvince.value = newValue;
              selectedCity.value = null;
              selectedDistrict.value = null;
              cities.clear();
              counties.clear();
              if (newValue != null) fetchCities(newValue);
            });
          },
          hintText: '请选择省份',
          isEnabled: provinces != null,
        ),
        SizedBox(width: 1),
        buildDropdown(
          valueNotifier: selectedCity,
          items: selectedProvince.value != null
              ? cities[selectedProvince.value!]
              : null,
          onChanged: (newValue) {
            setState(() {
              selectedCity.value = newValue;
              selectedDistrict.value = null;
              counties.clear();
              if (newValue != null) fetchCounties(newValue);
            });
          },
          hintText: '请选择城市',
          isEnabled: selectedProvince.value != null,
        ),
        SizedBox(width: 1),
        // buildDropdown(
        //   valueNotifier: selectedDistrict,
        //   items: selectedCity.value != null
        //       ? counties[selectedCity.value!]
        //       : null,
        //   onChanged: (newValue) {
        //     setState(() {
        //       selectedDistrict.value = newValue;
        //     });
        //   },
        //   hintText: '请选择区县',
        //   isEnabled: selectedCity.value != null,
        // ),
      ],
    );
  }
}

class SuggestionTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final double width; // 输入框宽度
  final double height; // 输入框高度
  final String? initialValue; // 默认值
  final Future<List<String>> Function(String query) fetchSuggestions;
  final ValueChanged<String>? onSelected; // 选择后的回调
  final ValueChanged<String?>? onChanged; // 输入或重置后的回调

  SuggestionTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.width, // 必须提供宽度
    required this.height, // 必须提供高度
    required this.fetchSuggestions,
    this.initialValue, // 初始化默认值
    this.onSelected, // 可选的 onSelected 回调
    this.onChanged, // 可选的 onChanged 回调
  }) : super(key: key);

  @override
  SuggestionTextFieldState createState() => SuggestionTextFieldState();
}

class SuggestionTextFieldState extends State<SuggestionTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialValue ?? '');
    _textController.addListener(_onTextFieldChange);
  }

  /// 监听文本框变化
  void _onTextFieldChange() {
    final currentText = _textController.text;
    // 如果内容被清空，确保调用 onChanged(null)
    widget.onChanged?.call(currentText.isEmpty ? null : currentText);
  }

  /// 重置输入框内容并通知父组件
  void reset() {
    setState(() {
      _textController.clear();
    });

    // 调用 onChanged 回调，传递 null 表示已重置
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0), // 确保组件与其他表单项垂直对齐
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) async {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              final suggestions = await widget.fetchSuggestions(textEditingValue.text);
              return suggestions;
            },
            displayStringForOption: (String option) => option,
            onSelected: (String selection) {
              debugPrint('Selected: $selection');
              _textController.text = selection;
              // 调用父组件提供的回调
              widget.onSelected?.call(selection);
              // 同样地，调用 onChanged 回调来通知父组件新的值
              widget.onChanged?.call(selection);
            },
            fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
              // 同步外部的 _textController 和内部的 textEditingController
              textEditingController.text = _textController.text;
              textEditingController.addListener(() {
                if (textEditingController.text != _textController.text) {
                  _textController.text = textEditingController.text;
                  _textController.selection =
                      TextSelection.collapsed(offset: _textController.text.length);
                }
              });

              _textController.addListener(() {
                if (textEditingController.text != _textController.text) {
                  textEditingController.text = _textController.text;
                }
              });

              return Container(
                width: widget.width, // 使用传入的宽度
                height: widget.height, // 使用传入的高度
                child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    labelText: widget.labelText,
                    hintText: widget.hintText,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2),
                      borderSide: BorderSide(color: Colors.grey, width: focusNode.hasFocus ? 1 : 0.5),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  color: Colors.transparent, // 确保 Material 不覆盖自定义背景色
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 80),
                    child: Container(
                      width: widget.width > 200 ? widget.width : widget.width+100, // 设置下拉选项宽度
                      decoration: BoxDecoration(
                        color: Colors.white, // 下拉选项背景颜色
                        borderRadius: BorderRadius.circular(2), // 设置圆角
                        border: Border.all(color: Colors.grey), // 设置边框颜色
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: options.isNotEmpty ? options.length : 1,
                        itemBuilder: (context, index) {
                          if (options.isNotEmpty) {
                            final option = options.elementAt(index);
                            return ListTile(
                              title: Text(option, style: TextStyle(fontSize: 14)), // 设置选项文字大小
                              onTap: () {
                                onSelected(option);
                              },
                              dense: true, // 减少 ListTile 内部的默认间距
                              visualDensity: VisualDensity.compact, // 减少垂直间距
                            );
                          } else {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '无匹配选项',
                                style: TextStyle(color: Colors.grey, fontSize: 14), // 设置提示文字大小
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

