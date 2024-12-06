import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomePage(),
      theme: ThemeData.light(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<_SuggestionTextFieldState> suggestionTextFieldKey =
  GlobalKey<_SuggestionTextFieldState>();

  void _onResetButtonPressed() {
    suggestionTextFieldKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Custom FieldSuggestion')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SuggestionTextField(
              key: suggestionTextFieldKey,
              suggestions: ['Alice', 'Bob', 'Charlie', 'David', 'Eve'],
              defaultValue: 'Alice', // 设置默认选中项
              onSelected: (String selectedText) {
                print('Selected: $selectedText');
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onResetButtonPressed,
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}

class SuggestionTextField extends StatefulWidget {
  final List<String> suggestions;
  final String? defaultValue; // 默认选中项
  final ValueChanged<String>? onSelected; // 当选择建议项时触发

  const SuggestionTextField({
    Key? key,
    required this.suggestions,
    this.defaultValue,
    this.onSelected,
  }) : super(key: key);

  @override
  _SuggestionTextFieldState createState() => _SuggestionTextFieldState();
}

class _SuggestionTextFieldState extends State<SuggestionTextField> {
  final textController = TextEditingController();
  OverlayEntry? _overlayEntry;
  List<String> currentSuggestions = [];
  bool hasValidSelection = false;
  GlobalKey textFieldKey = GlobalKey(); // 用于获取TextField的位置
  FocusNode focusNode = FocusNode();

  void _showOverlay(BuildContext context) {
    final RenderBox renderBox = textFieldKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position.dy + renderBox.size.height, // 输入框下方
          left: position.dx,
          width: renderBox.size.width,
          child: Material(
            elevation: 4.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: currentSuggestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        textController.text = currentSuggestions[index];
                        textController.selection = TextSelection.fromPosition(
                          TextPosition(offset: textController.text.length),
                        );
                        hasValidSelection = true;
                      });
                      widget.onSelected?.call(currentSuggestions[index]);
                      _hideOverlay();
                      FocusScope.of(context).requestFocus(focusNode); // 保持输入框聚焦
                    },
                    child: Card(
                      margin: EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(currentSuggestions[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void reset() {
    setState(() {
      textController.clear();
      currentSuggestions.clear();
      hasValidSelection = false;
    });
    if (widget.defaultValue != null && widget.defaultValue!.isNotEmpty) {
      textController.text = widget.defaultValue!;
      widget.onSelected?.call(widget.defaultValue!);
    }
    _hideOverlay();
  }

  void _setDefaultValueIfEmpty() {
    if (widget.defaultValue != null &&
        widget.defaultValue!.isNotEmpty &&
        textController.text.isEmpty) {
      setState(() {
        textController.text = widget.defaultValue!;
        hasValidSelection = true;
      });
      widget.onSelected?.call(widget.defaultValue!);
    }
  }

  @override
  void initState() {
    super.initState();
    _setDefaultValueIfEmpty(); // 在初始化时设置默认值
    focusNode.addListener(() {
      if (!focusNode.hasFocus && !hasValidSelection) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (textController.text.isNotEmpty) {
            setState(() {
              textController.clear();
            });
          } else {
            _setDefaultValueIfEmpty(); // 如果没有选择且文本为空，则设置默认值
          }
        });
      } else if (!focusNode.hasFocus) {
        hasValidSelection = false; // 重置选中状态
      }
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(() {});
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 点击空白区域时隐藏下拉菜单
        _hideOverlay();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              key: textFieldKey, // 使用key来定位TextField
              controller: textController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Enter a name",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                // 清空输入框时立即隐藏下拉菜单
                if (value.isEmpty) {
                  _hideOverlay();
                  setState(() {
                    currentSuggestions.clear();
                  });
                  return;
                }

                currentSuggestions = widget.suggestions
                    .where((item) => item.toLowerCase().contains(value.toLowerCase()))
                    .toList();
                if (currentSuggestions.isNotEmpty) {
                  if (_overlayEntry == null) {
                    _showOverlay(context);
                  } else {
                    _overlayEntry?.markNeedsBuild();
                  }
                } else {
                  _hideOverlay();
                }
                setState(() {
                  hasValidSelection = false; // 当输入框内容改变时，重置选择标志
                });
              },
              onTap: () {
                if (currentSuggestions.isNotEmpty) {
                  _showOverlay(context);
                }
              },
              onEditingComplete: () {
                if (!hasValidSelection) {
                  _setDefaultValueIfEmpty(); // 如果没有选择则设置默认值
                }
                _hideOverlay();
              },
            ),
          ],
        ),
      ),
    );
  }
}