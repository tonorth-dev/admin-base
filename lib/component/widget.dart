import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

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

  // TextEditingControllers for each TypeAheadField
  final TextEditingController _level1Controller = TextEditingController();
  final TextEditingController _level2Controller = TextEditingController();
  final TextEditingController _level3Controller = TextEditingController();

  void _onLevel1Changed(String newValue) {
    setState(() {
      selectedLevel1 = newValue;
      selectedLevel2 = null;
      selectedLevel3 = null;
      _level1Controller.text = newValue;
      _level2Controller.clear();
      _level3Controller.clear();
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  void _onLevel2Changed(String newValue) {
    setState(() {
      selectedLevel2 = newValue;
      selectedLevel3 = null;
      _level2Controller.text = newValue;
      _level3Controller.clear();
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  void _onLevel3Changed(String newValue) {
    setState(() {
      selectedLevel3 = newValue;
      _level3Controller.text = newValue;
    });
    widget.onChanged?.call(selectedLevel1, selectedLevel2, selectedLevel3);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _level1Controller,
              decoration: InputDecoration(
                labelText: widget.hint1,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16.0),
            ),
            suggestionsCallback: (pattern) {
              return widget.level1Items
                  .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _onLevel1Changed(suggestion);
            },
            noItemsFoundBuilder: (context) => SizedBox(
              height: 50,
              child: Center(child: Text('No items found')),
            ),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _level2Controller,
              decoration: InputDecoration(
                labelText: widget.hint2,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16.0),
            ),
            suggestionsCallback: (pattern) {
              if (selectedLevel1 == null) return [];
              return widget.level2Items[selectedLevel1]!
                  .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _onLevel2Changed(suggestion);
            },
            noItemsFoundBuilder: (context) => SizedBox(
              height: 50,
              child: Center(child: Text('No items found')),
            ),
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: TypeAheadField(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _level3Controller,
              decoration: InputDecoration(
                labelText: widget.hint3,
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: 16.0),
            ),
            suggestionsCallback: (pattern) {
              if (selectedLevel2 == null) return [];
              return widget.level3Items[selectedLevel2]!
                  .where((item) => item.toLowerCase().contains(pattern.toLowerCase()))
                  .toList();
            },
            itemBuilder: (context, suggestion) {
              return ListTile(
                title: Text(suggestion),
              );
            },
            onSuggestionSelected: (suggestion) {
              _onLevel3Changed(suggestion);
            },
            noItemsFoundBuilder: (context) => SizedBox(
              height: 50,
              child: Center(child: Text('No items found')),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _level1Controller.dispose();
    _level2Controller.dispose();
    _level3Controller.dispose();
    super.dispose();
  }
}


class SearchBoxWidget extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onTextChanged;

  const SearchBoxWidget({Key? key, required this.hint, required this.onTextChanged}) : super(key: key);

  @override
  _SearchBoxWidgetState createState() => _SearchBoxWidgetState();
}

class _SearchBoxWidgetState extends State<SearchBoxWidget> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
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

  const SearchButtonWidget({Key? key, required this.onPressed}) : super(key: key);

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












