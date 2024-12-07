import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class SuggestionTextField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final String? initialValue; // 默认值
  final Future<List<String>> Function(String query) fetchSuggestions;
  final ValueChanged<String>? onSelected; // 选择后的回调

  SuggestionTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.fetchSuggestions,
    this.initialValue, // 初始化默认值
    this.onSelected, // 可选的 onSelected 回调
  }) : super(key: key);

  @override
  SuggestionTextFieldState createState() => SuggestionTextFieldState();
}

class SuggestionTextFieldState extends State<SuggestionTextField> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    // 初始化 TextEditingController 并设置默认值
    _textController = TextEditingController(text: widget.initialValue ?? '');
  }

  void _reset() {
    setState(() {
      _textController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            if (widget.onSelected != null) {
              widget.onSelected!(selection);
            }
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            // 同步传入的 textEditingController
            textEditingController.text = _textController.text;
            textEditingController.addListener(() {
              if (textEditingController.text != _textController.text) {
                _textController.text = textEditingController.text;
                _textController.selection =
                    TextSelection.collapsed(offset: _textController.text.length);
              }
            });

            // 在 reset 时同步清空 textEditingController
            _textController.addListener(() {
              if (textEditingController.text != _textController.text) {
                textEditingController.text = _textController.text;
              }
            });

            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: widget.hintText,
                border: OutlineInputBorder(),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            if (options.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '无匹配选项',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4.0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(option),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}


void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomFieldSuggestion Demo',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SuggestionTextField Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SuggestionTextField(
              labelText: 'Search',
              hintText: 'Enter a name',
              initialValue: 'Alice', // 设置默认值
              fetchSuggestions: (query) async {
                await Future.delayed(Duration(milliseconds: 300));
                final allSuggestions = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
                return allSuggestions
                    .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              },
              onSelected: (value) {
                debugPrint('User selected: $value');
              },
            ),
          ],
        ),
      ),
    );
  }
}

