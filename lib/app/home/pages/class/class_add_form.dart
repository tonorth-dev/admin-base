import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:admin_flutter/api/classes_api.dart'; // 导入 classes_api.dart
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class ClassesAddForm extends StatefulWidget {
  const ClassesAddForm({super.key});

  @override
  State<ClassesAddForm> createState() => _ClassesAddFormState();
}

class _ClassesAddFormState extends State<ClassesAddForm> {
  final logic = Get.put(ClassesLogic());
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await logic.saveClasses();
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
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: Row(
                      children: const [
                        Text('班级姓名'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 8,
                      hint: "输入姓名",
                      text: logic.name,
                      onTextChanged: (value) {
                        logic.name.value = value;
                      },
                      validator:
                          FormBuilderValidators.required(errorText: '姓名不能为空'),
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
                        Text('手机号'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 8,
                      hint: "输入手机号",
                      text: logic.phone,
                      onTextChanged: (value) {
                        logic.phone.value = value;
                      },
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '手机号不能为空'),
                        FormBuilderValidators.phoneNumber(errorText: '请输入有效的手机号')
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
                    child: Row(
                      children: const [
                        Text('机构ID'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: SuggestionTextField(
                    width: 600,
                    height: 34,
                    labelText: '机构选择',
                    hintText: '输入机构名称',
                    key: Key("add_classes_institution_id"),
                    fetchSuggestions: logic.fetchInstructions,
                    initialValue: '',
                    onSelected: (value) {
                      if (value == '') {
                        logic.institutionId.value = "";
                        return;
                      }
                      RegExp regExp = RegExp(r'ID：(\d+)');
                      Match? match = regExp.firstMatch(value);
                      if (match != null) {
                        String id = match.group(1)!;
                        logic.institutionId.value = id;
                      } else {
                        logic.institutionId.value = "";
                      }
                      print("selectedInstitutionId value: ${logic.selectedInstitutionId.value}");
                    },
                    onChanged: (value) {
                      if (value == null || value.isEmpty) {
                        logic.institutionId.value = ""; // 确保清空
                      }
                      print("onChanged selectedInstitutionId value: ${logic.selectedInstitutionId.value}");
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
                        Text('班级ID'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 8,
                      hint: "输入班级ID",
                      text: logic.classId,
                      onTextChanged: (value) {
                        logic.classId.value = value;
                      },
                      validator:
                          FormBuilderValidators.required(errorText: '班级ID不能为空'),
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
                        Text('推荐人'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 8,
                      hint: "输入推荐人",
                      text: logic.referrer,
                      onTextChanged: (value) {
                        logic.referrer.value = value;
                      },
                      validator:
                          FormBuilderValidators.required(errorText: '推荐人不能为空'),
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
                        Text('职位代码'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 8,
                      hint: "输入职位代码",
                      text: logic.jobCode,
                      onTextChanged: (value) {
                        logic.jobCode.value = value;
                      },
                      validator:
                          FormBuilderValidators.required(errorText: '职位代码不能为空'),
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
                    width: 120,
                    child: DropdownField(
                      key: UniqueKey(),
                      items: [
                        {'id': '1', 'name': '未生效'},
                        {'id': '2', 'name': '生效中'},
                        {'id': '5', 'name': '已过期'},
                      ],
                      hint: '',
                      label: true,
                      width: 100,
                      height: 34,
                      selectedValue:
                          ValueNotifier<String?>(logic.status.value.toString()),
                      onChanged: (dynamic newValue) {
                        print(newValue);
                        logic.status.value = newValue;
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
