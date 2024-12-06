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
  final TextEditingController textController = TextEditingController();
  OverlayEntry? _overlayEntry;
  List<String> currentSuggestions = [];
  final FocusNode focusNode = FocusNode();
  bool _isSelecting = false;

  void _showOverlay(BuildContext context) {
    if (_overlayEntry != null) return;

    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: position.dy + renderBox.size.height,
          left: position.dx,
          width: renderBox.size.width,
          child: Material(
            elevation: 4.0,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: currentSuggestions.isEmpty
                  ? ListTile(
                title: Text("无匹配选项", style: TextStyle(color: Colors.grey)),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: currentSuggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(currentSuggestions[index]),
                    onTap: () {
                      setState(() {
                        _isSelecting = true;
                        textController.text = currentSuggestions[index];
                      });
                      _hideOverlay();
                      // 阻止 onChanged 回调，因为我们是通过程序更改了文本框的内容
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _isSelecting = false;
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context)?.insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void reset() {
    setState(() {
      textController.clear();
      currentSuggestions.clear();
      _hideOverlay();
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus && !_isSelecting) {
        _hideOverlay();
      }
    });
  }

  @override
  void dispose() {
    focusNode.removeListener(() {});
    focusNode.dispose();
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_overlayEntry != null) {
          _hideOverlay();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Column(
        children: [
          TextField(
            controller: textController,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) async {
              if (_isSelecting) return; // 忽略选择时的改变

              if (value.isEmpty) {
                _hideOverlay();
                setState(() {
                  currentSuggestions.clear();
                });
                return;
              }

              currentSuggestions = await widget.fetchSuggestions(value);
              if (!mounted) return;

              setState(() {});

              if (currentSuggestions.isNotEmpty) {
                _showOverlay(context);
              } else {
                _hideOverlay();
              }
            },
            onTap: () {
              if (currentSuggestions.isNotEmpty) {
                _showOverlay(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

// 使用示例
void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom FieldSuggestion',
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
  final GlobalKey<_CustomFieldSuggestionState> _suggestionKey = GlobalKey<_CustomFieldSuggestionState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Custom FieldSuggestion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomFieldSuggestion(
              key: _suggestionKey,
              labelText: "Search",
              hintText: "Enter a name",
              fetchSuggestions: (query) async {
                await Future.delayed(Duration(milliseconds: 300));
                final allSuggestions = ['Alice', 'Bob', 'Charlie', 'David', 'Eve'];
                return allSuggestions
                    .where((item) => item.toLowerCase().contains(query.toLowerCase()))
                    .toList();
              },
            ),
            ElevatedButton(
              onPressed: () {
                _suggestionKey.currentState?.reset();
              },
              child: Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }
}