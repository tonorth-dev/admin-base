import 'package:flutter/material.dart';

class CustomFieldSuggestion extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        }
        final suggestions = await fetchSuggestions(textEditingValue.text);
        return suggestions;
      },
      displayStringForOption: (String option) => option,
      onSelected: (String selection) {
        // 回填逻辑由 Autocomplete 内部处理，这里可以监听用户选择
        debugPrint('Selected: $selection');
      },
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: OutlineInputBorder(),
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
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
    );
  }
}

// 示例应用
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
      appBar: AppBar(title: Text('CustomFieldSuggestion Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomFieldSuggestion(
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
      ),
    );
  }
}
