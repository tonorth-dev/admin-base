import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../component/widget.dart';
import 'c_logic.dart';

class ClassesEditForm extends StatefulWidget {
  final int classesId;
  final String initialName;
  final String initialInstitutionId;
  final String initialTeacher;

  ClassesEditForm({
    required this.classesId,
    required this.initialName,
    required this.initialInstitutionId,
    required this.initialTeacher,
  });

  @override
  State<ClassesEditForm> createState() => _ClassesEditFormState();
}

class _ClassesEditFormState extends State<ClassesEditForm> {
  final logic = Get.find<CLogic>();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await logic.updateClasses(widget.classesId);
      if (result) {
        Navigator.pop(context);
        logic.find(logic.size.value, logic.page.value);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    logic.uName.value = widget.initialName;
    logic.uInstitutionId.value = widget.initialInstitutionId;
    logic.uTeacher.value = widget.initialTeacher;
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
                        Text('班级名称'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 1,
                      hint: "输入班级名称",
                      text: logic.uName,
                      onTextChanged: (value) {
                        logic.uName.value = value;
                      },
                      validator:
                      FormBuilderValidators.required(errorText: '班级名称不能为空'),
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
                        Text('机构选择'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 1,
                      hint: "输入机构ID",
                      text: logic.uInstitutionId,
                      onTextChanged: (value) {
                        logic.uInstitutionId.value = value;
                      },
                      validator:
                      FormBuilderValidators.required(errorText: '机构ID不能为空'),
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
                        Text('任课教师'),
                        Text('*', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 600,
                    child: TextInputWidget(
                      width: 240,
                      height: 34,
                      maxLines: 1,
                      hint: "输入任课教师姓名",
                      text: logic.uTeacher,
                      onTextChanged: (value) {
                        logic.uTeacher.value = value;
                      },
                      validator:
                      FormBuilderValidators.required(errorText: '任课教师姓名不能为空'),
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
    );
  }
}
