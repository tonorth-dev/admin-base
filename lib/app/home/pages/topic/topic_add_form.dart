import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:admin_flutter/api/topic_api.dart'; // 导入 topic_api.dart
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class TopicAddForm extends StatefulWidget {
  const TopicAddForm({super.key});

  @override
  State<TopicAddForm> createState() => _TopicAddFormState();
}

class _TopicAddFormState extends State<TopicAddForm> {
  final logic = Get.put(TopicLogic());
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formValue = _formKey.currentState?.value;
      try {
        bool result = await TopicApi.topicCreate(formValue!);
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('题目创建成功')),
          );
          Navigator.pop(context); // 关闭弹窗
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('题目创建失败')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建题目时发生错误: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 800),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: const Text('题干：'),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 50,
                      maxLines: 8,
                      hint: "输入问题题干",
                      text: ''.obs,
                      onTextChanged: (value) {
                        print('title changed: $value');
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
                    child: const Text('题型：'),
                  ),
                  SizedBox(
                    width: 600,
                    child: DropdownField(
                      items: logic.questionCate.toList(),
                      hint: '',
                      label: true,
                      width: 120,
                      height: 34,
                      onChanged: (dynamic newValue) {
                        logic.selectedQuestionCate.value = newValue.toString();
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
                    child: const Text('难度：'),
                  ),
                  SizedBox(
                    width: 600,
                    child: DropdownField(
                      items: logic.questionLevel.toList(),
                      hint: '',
                      label: true,
                      width: 120,
                      height: 34,
                      onChanged: (dynamic newValue) {
                        logic.selectedQuestionLevel.value = newValue.toString();
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
                    child: const Text('专业：'),
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
                      onChanged: (dynamic level1, dynamic level2, dynamic level3) {
                        logic.selectedMajorId.value = level3.toString();
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
                    child: const Text('答案：'),
                  ),
                  SizedBox(
                    width: 600,
                    child:TextInputWidget(
                      width: 240,
                      height: 120,
                      maxLines: 30,
                      hint: "输入问题答案",
                      text: ''.obs,
                      onTextChanged: (value) {
                        print('answer changed: $value');
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
                    child: const Text('作者：'),
                  ),
                  SizedBox(
                    width: 600,
                    child:
                    TextInputWidget(
                      width: 240,
                      height: 34,
                      hint: "输入作者名称",
                      text: ''.obs,
                      onTextChanged: (value) {
                        print('author changed: $value');
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
                    child: const Text('标签：'),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      hint: "可以给问题打一个标签",
                      text: ''.obs,
                      onTextChanged: (value) {
                        print('author changed: $value');
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
                    onPressed: () {
                      Navigator.pop(context); // 关闭弹窗
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF25B7E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('提交'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
