import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:admin_flutter/api/major_api.dart'; // 导入 major_api.dart
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class MajorAddForm extends StatefulWidget {
  const MajorAddForm({super.key});

  @override
  State<MajorAddForm> createState() => _MajorAddFormState();
}

class _MajorAddFormState extends State<MajorAddForm> {
  final logic = Get.put(MajorLogic());
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await logic.saveMajor();
      if (result) {
        Navigator.pop(context);
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
                    child: Row(
                      children: const [
                        Text('岗位代码'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 65,
                      maxLines: 8,
                      hint: "输入岗位代码",
                      text: logic.majorTitle,
                      onTextChanged: (value) {
                        logic.majorTitle.value = value;
                      },
                      validator:
                          FormBuilderValidators.required(errorText: '岗位代码不能为空'),
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
                        Text('岗位名称'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 65,
                      maxLines: 8,
                      hint: "输入岗位名称",
                      text: logic.majorTitle,
                      onTextChanged: (value) {
                        logic.majorTitle.value = value;
                      },
                      validator:
                      FormBuilderValidators.required(errorText: '岗位名称不能为空'),
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
                        Text('岗位类别'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 65,
                      maxLines: 8,
                      hint: "输入岗位类别",
                      text: logic.majorTitle,
                      onTextChanged: (value) {
                        logic.majorTitle.value = value;
                      },
                      validator:
                      FormBuilderValidators.required(errorText: '岗位类别不能为空'),
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
                        Text('岗位类别'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: NumberInputWidget(
                      key: UniqueKey(),
                      width: 90,
                      height: 34,
                      hint: "0",
                      selectedValue: 0.obs,
                      onValueChanged: (value) {
                        // logic.majorTitle.value = value;
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
                      selectedValue: logic.majorSelectedQuestionCate,
                      onChanged: (dynamic newValue) {
                        logic.majorSelectedQuestionCate.value =
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
                      selectedValue: logic.majorSelectedQuestionLevel,
                      onChanged: (dynamic newValue) {
                        logic.majorSelectedQuestionLevel.value =
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
                      selectedLevel1: logic.selectedLevel1,
                      selectedLevel2: logic.selectedLevel2,
                      selectedLevel3: logic.selectedLevel3,
                      level1Items: logic.level1Items,
                      level2Items: logic.level2Items,
                      level3Items: logic.level3Items,
                      onChanged:
                          (dynamic level1, dynamic level2, dynamic level3) {
                        logic.majorSelectedMajorId.value = level3.toString();
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
                    height: 300,
                    child: TextInputWidget(
                      width: 240,
                      height: 300,
                      maxLines: 40,
                      hint: "输入问题答案",
                      text: logic.majorAnswer,
                      onTextChanged: (value) {
                        logic.majorAnswer.value = value;
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
                        Text('作者：'),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      hint: "输入作者名称",
                      text: logic.majorAuthor,
                      onTextChanged: (value) {
                        logic.majorAuthor.value = value;
                      },
                      // validator: FormBuilderValidators.compose([
                      //   FormBuilderValidators.match(
                      //     RegExp(r'^[a-zA-Z0-9\u4e00-\u9fa5]+$'),
                      //     errorText: '作者名字只能由英文和汉字组成',
                      //   ),
                      // ]),
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
                      text: logic.majorTag,
                      onTextChanged: (value) {
                        logic.majorTag.value = value;
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
                        Text('试题状态'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 240,
                    child: SingleSelectForm(
                      // key: Key("status_select"),
                      items: RxList<Map<String, dynamic>>([
                        {'id': 1, 'name': '草稿', 'selected': false},
                        {'id': 2, 'name': '完成', 'selected': false},
                      ]),
                      onSelected: (item) => {
                        logic.majorStatus.value = item['id']
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
