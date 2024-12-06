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
  List<String> _suggestions = [];
  bool _noOptions = false;

  Future<void> _updateSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _suggestions = [];
        _noOptions = false;
      });
      return;
    }

    final suggestions = await widget.fetchSuggestions(query);
    setState(() {
      _suggestions = suggestions;
      _noOptions = suggestions.isEmpty;
    });
  }

  void _reset() {
    setState(() {
      _textController.clear();
      _suggestions = [];
      _noOptions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _textController,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            border: OutlineInputBorder(),
          ),
          onChanged: (value) async {
            await _updateSuggestions(value);
          },
        ),
        const SizedBox(height: 8.0),
        _suggestions.isNotEmpty
            ? ListView.builder(
          shrinkWrap: true,
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            final suggestion = _suggestions[index];
            return ListTile(
              title: Text(suggestion),
              onTap: () {
                _textController.text = suggestion;
                setState(() {
                  _suggestions = [];
                });
              },
            );
          },
        )
            : _noOptions
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '无匹配选项',
            style: TextStyle(color: Colors.grey),
          ),
        )
            : SizedBox.shrink(),
        const SizedBox(height: 8.0),
        ElevatedButton(
          onPressed: _reset,
          child: Text('Reset'),
        ),
      ],
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