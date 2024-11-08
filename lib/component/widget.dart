import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
  final List<String> items;
  final String? value;
  final Function(String?)? onChanged;

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
  _DropdownFieldState createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> with WidgetsBindingObserver {
  final FocusNode _focusNode = FocusNode();
  String? selectedValue;
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
                child: DropdownButtonFormField<String>(
                  focusNode: _focusNode,
                  value: widget.items.contains(selectedValue) ? selectedValue : null,
                  hint: Text(
                    widget.hint,
                    style: const TextStyle(
                      color: Color(0xFF423F3F),
                      fontSize: 14,
                      fontFamily: 'PingFang SC',
                      fontWeight: FontWeight.w400,
                      height: 1.2,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedValue = newValue;
                      _isSelected = newValue != null;
                    });
                    if (widget.onChanged != null) {
                      widget.onChanged!(newValue);
                    }
                  },
                  items: widget.items.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        value,
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
  final List<String> level1Items;
  final Map<String, List<String>> level2Items;
  final Map<String, List<String>> level3Items;
  final Function(String?, String?, String?)? onChanged;

  const CascadingDropdownField({
    Key? key,
    required this.width,
    required this.height,
    required this.hint1,
    required this.hint2,
    required this.hint3,
    required this.level1Items,
    required this.level2Items,
    required this.level3Items,
    this.onChanged,
  }) : super(key: key);

  @override
  _CascadingDropdownFieldState createState() => _CascadingDropdownFieldState();
}

class _CascadingDropdownFieldState extends State<CascadingDropdownField> {
  String? selectedLevel1;
  String? selectedLevel2;
  String? selectedLevel3;

  void _onLevel1Changed(String? newValue) {
    setState(() {
      selectedLevel1 = newValue;
      selectedLevel2 = null; // Reset second level selection
      selectedLevel3 = null; // Reset third level selection
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  void _onLevel2Changed(String? newValue) {
    setState(() {
      selectedLevel2 = newValue;
      selectedLevel3 = null; // Reset third level selection
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  void _onLevel3Changed(String? newValue) {
    setState(() {
      selectedLevel3 = newValue;
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        DropdownField(
          width: widget.width,
          height: widget.height,
          hint: widget.hint1,
          items: widget.level1Items.toSet().toList(),
          value: selectedLevel1,
          onChanged: _onLevel1Changed,
        ),
        const SizedBox(width: 3),
        DropdownField(
          width: widget.width,
          height: widget.height,
          hint: widget.hint2,
          items: selectedLevel1 != null
              ? widget.level2Items[selectedLevel1!]!.toSet().toList()
              : [],
          value: selectedLevel2,
          onChanged: _onLevel2Changed,
        ),
        const SizedBox(width: 3),
        DropdownField(
          width: widget.width,
          height: widget.height,
          hint: widget.hint3,
          items: selectedLevel2 != null
              ? widget.level3Items[selectedLevel2!]!.toSet().toList()
              : [],
          value: selectedLevel3,
          onChanged: _onLevel3Changed,
        ),
      ],
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
            width: 180,
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












