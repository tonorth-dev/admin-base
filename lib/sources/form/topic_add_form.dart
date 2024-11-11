import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:admin_flutter/api/topic_api.dart'; // 导入 topic_api.dart

class TopicAddForm extends StatefulWidget {
  const TopicAddForm({super.key});

  @override
  State<TopicAddForm> createState() => _TopicAddFormState();
}

class _TopicAddFormState extends State<TopicAddForm> {
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
                    child: FormBuilderTextField(
                      name: 'title',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '题干不能为空'),
                      ]),
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
                    child: FormBuilderDropdown<int>(
                      name: 'cate',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '请选择题型'),
                      ]),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text('专业知识')),
                        DropdownMenuItem(value: 2, child: Text('适岗能力')),
                        DropdownMenuItem(value: 3, child: Text('求职动机')),
                        // Add more categories as needed
                      ],
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
                    child: FormBuilderTextField(
                      name: 'answer',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 6,
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '答案不能为空'),
                      ]),
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
                    child: FormBuilderTextField(
                      name: 'author',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '作者不能为空'),
                            (value) {
                          if (value != null && value.length > 10) {
                            return '作者名称不能超过10个字符';
                          }
                          return null;
                        },
                      ]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: const Text('专业名称：'),
                  ),
                  SizedBox(
                    width: 600,
                    child: FormBuilderTextField(
                      name: 'major_name',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '专业名称不能为空'),
                      ]),
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
                    child: FormBuilderTextField(
                      name: 'tag',
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
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
