import 'package:flutter/material.dart';

class CustomFieldSuggestion extends StatefulWidget {
  final String labelText;
  final String hintText;
  final Future<List<String>> Function(String query) fetchSuggestions;

  CustomFieldSuggestion({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.fetchSuggestions,
  }) : super(key: key);

  @override
  _CustomFieldSuggestionState createState() => _CustomFieldSuggestionState();
}

class _CustomFieldSuggestionState extends State<CustomFieldSuggestion> {
  final TextEditingController _textController = TextEditingController();

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
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            // 将传入的 textEditingController 同步到自定义的 _textController
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

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<_CustomFieldSuggestionState> _suggestionKey = GlobalKey<_CustomFieldSuggestionState>();

  void _reset() {
    _suggestionKey.currentState?._reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('CustomFieldSuggestion Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomFieldSuggestion(
              key: _suggestionKey,
              labelText: 'Search',
              hintText: 'Enter a name',
              fetchSuggestions: (query) async {
                await Future.delayed(Duration(milliseconds: 300));
                final allSuggestions = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
                return allSuggestions
                    .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _reset,
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}
