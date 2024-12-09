import 'package:flutter/material.dart';

class TagInputField extends StatefulWidget {
  final List<String> defaultTags;
  final ValueChanged<String> onChange;
  final ValueChanged<List<String>>? onTagsUpdated; // 回调：获取全部标签
  final String? Function(String)? onTagModify;

  const TagInputField({
    Key? key,
    this.defaultTags = const [],
    required this.onChange,
    this.onTagsUpdated,
    this.onTagModify,
  }) : super(key: key);

  @override
  _TagInputFieldState createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _tags;

  @override
  void initState() {
    super.initState();
    _tags = List.from(widget.defaultTags);
    _updateTags();
  }

  void _addTag(String value) {
    final trimmedValue = value.trim();
    if (trimmedValue.isEmpty) return;

    try {
      // 调用回调修改标签内容
      final modifiedTag = widget.onTagModify != null
          ? widget.onTagModify!(trimmedValue)
          : trimmedValue;

      if (modifiedTag == null) {
        // 如果返回 null，中断操作
        _showErrorMessage("标签不符合预期");
        return;
      }

      if (!_tags.contains(modifiedTag)) {
        setState(() {
          _tags.add(modifiedTag);
        });
        _updateTags();
      }
      _controller.clear();
    } catch (e) {
      _showErrorMessage(e.toString());
    }
  }

// 显示错误信息的方法
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    _updateTags();
  }

  void _updateTags() {
    if (widget.onTagsUpdated != null) {
      widget.onTagsUpdated!(_tags);
    }
  }

  List<String> get tags => _tags; // Getter: 获取所有标签

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Enter tags',
            hintText: 'Type and press comma or Enter',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onChange(value); // 实时回调当前输入值
            if (value.contains(',')) {
              final parts = value.split(',');
              parts.forEach(_addTag);
            }
          },
          onSubmitted: _addTag,
        ),
        SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: _tags.map((tag) {
            return Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              deleteIcon: Icon(Icons.close, size: 18),
            );
          }).toList(),
        ),
      ],
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text('Tag Input Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TagInputField(
          defaultTags: ['Flutter', 'Dart'],
          onChange: (value) {
            print('Current input: $value');
          },
          onTagsUpdated: (tags) {
            print('All tags: $tags');
          },
          onTagModify: (tag) {
            // 示例：限制标签长度为 10，并要求只包含字母
            if (tag.length > 10) {
              return null; // 或抛出异常：throw Exception('标签长度不能超过10个字符');
            }
            if (!RegExp(r'^[a-zA-Z]+$').hasMatch(tag)) {
              throw Exception('标签只能包含字母');
            }
            return tag.toUpperCase(); // 修改为大写
          },
        ),
      ),
    ),
  ));
}
