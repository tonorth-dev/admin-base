import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class EditTopicDialog extends StatefulWidget {
  final int topicId;
  final String initialTitle;
  final String initialAnswer;
  final String initialQuestionCate;
  final String initialQuestionLevel;
  final String initialMajorId;
  final String initialAuthor;
  final String initialTag;
  final int initialStatus;

  EditTopicDialog({
    required this.topicId,
    required this.initialTitle,
    required this.initialAnswer,
    required this.initialQuestionCate,
    required this.initialQuestionLevel,
    required this.initialMajorId,
    required this.initialAuthor,
    required this.initialTag,
    required this.initialStatus,
  });

  @override
  State<EditTopicDialog> createState() => _EditTopicDialogState();
}

class _EditTopicDialogState extends State<EditTopicDialog> {
  final logic = Get.find<TopicLogic>();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await logic.updateTopic();
      if (result) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    logic.uTopicTitle.value = widget.initialTitle;
    logic.uTopicAnswer.value = widget.initialAnswer;
    logic.uTopicSelectedQuestionCate.value = widget.initialQuestionCate;
    logic.uTopicSelectedQuestionLevel.value = widget.initialQuestionLevel;
    logic.uTopicSelectedMajorId.value = widget.initialMajorId;
    logic.uTopicAnswer.value = widget.initialAnswer;
    logic.uTopicAuthor.value = widget.initialAuthor;
    logic.uTopicTag.value = widget.initialTag;
    logic.uTopicStatus.value = widget.initialStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('标题'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: FormBuilderTextField(
                        name: 'title',
                        initialValue: widget.initialTitle,
                        decoration: const InputDecoration(hintText: "输入标题"),
                        validator: FormBuilderValidators.required(errorText: '标题不能为空'),
                        onChanged: (value) {
                          logic.uTopicTitle.value = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('题型'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: DropdownField(
                        items: logic.questionCate.toList(),
                        hint: '',
                        label: true,
                        width: 120,
                        height: 34,
                        value: widget.initialQuestionCate,
                        onChanged: (dynamic newValue) {
                          logic.topicSelectedQuestionCate.value =
                              newValue.toString();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('难度'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: DropdownField(
                        items: logic.questionLevel.toList(),
                        hint: '',
                        label: true,
                        width: 120,
                        height: 34,
                        value: widget.initialQuestionLevel,
                        onChanged: (dynamic newValue) {
                          logic.topicSelectedQuestionLevel.value =
                              newValue.toString();
                          logic.applyFilters();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('专业'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 500,
                      child: CascadingDropdownField(
                        width: 160,
                        height: 34,
                        hint1: '专业类目一',
                        hint2: '专业类目二',
                        hint3: '专业名称',
                        level1Items: logic.level1Items,
                        level2Items: logic.level2Items,
                        level3Items: logic.level3Items,
                        selectedLevel1: "0",
                        selectedLevel2: "0",
                        selectedLevel3: "1",
                        onChanged:
                            (dynamic level1, dynamic level2, dynamic level3) {
                          logic.topicSelectedMajorId.value = level3.toString();
                          // 这里可以处理选择的 id
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('答案'),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: FormBuilderTextField(
                        name: 'answer',
                        initialValue: widget.initialAnswer,
                        decoration: const InputDecoration(hintText: "输入答案"),
                        maxLines: 8,
                        onChanged: (value) {
                          logic.uTopicAnswer.value = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('作者'),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: FormBuilderTextField(
                        name: 'author',
                        initialValue: widget.initialAuthor,
                        decoration: const InputDecoration(hintText: "输入作者名称"),
                        onChanged: (value) {
                          logic.uTopicAuthor.value = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: const Text('标签'),
                    ),
                    SizedBox(
                      width: 600,
                      child: FormBuilderTextField(
                        name: 'tag',
                        initialValue: widget.initialTag,
                        decoration: const InputDecoration(hintText: "输入标签"),
                        onChanged: (value) {
                          logic.uTopicTag.value = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: Row(
                        children: const [
                          Text('状态'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 600,
                      child: FormBuilderRadioGroup(
                        name: 'status',
                        initialValue: widget.initialStatus,
                        options: [
                          FormBuilderFieldOption(value: 1, child: const Text('草稿')),
                          FormBuilderFieldOption(value: 2, child: const Text('完成')),
                        ],
                        onChanged: (value) {
                          logic.uTopicStatus.value = value!;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                      child: const Text('取消'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25B7E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('保存'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}