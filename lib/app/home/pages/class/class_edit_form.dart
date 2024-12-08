import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class ClassesEditForm extends StatefulWidget {
  final int classesId;
  final String initialName;
  final String initialProvince;
  final String initialCity;
  final String initialPassword;
  final String initialLeader;
  final String initialStatus;
  final String initialPhone;
  final String initialInstitutionId;
  final String initialInstitutionName;
  final String initialClassId;
  final String initialClassName;
  final String initialReferrer;
  final String initialJobCode;
  final String initialJobName;
  final String initialJobDesc;
  final String initialMajorIds;
  final String initialMajorNames;
  final DateTime? initialExpireTime;

  ClassesEditForm({
    required this.classesId,
    required this.initialName,
    required this.initialProvince,
    required this.initialCity,
    required this.initialPassword,
    required this.initialLeader,
    required this.initialStatus,
    required this.initialPhone,
    required this.initialInstitutionId,
    required this.initialInstitutionName,
    required this.initialClassId,
    required this.initialClassName,
    required this.initialReferrer,
    required this.initialJobCode,
    required this.initialJobName,
    required this.initialJobDesc,
    required this.initialMajorIds,
    required this.initialMajorNames,
    this.initialExpireTime,
  });

  @override
  State<ClassesEditForm> createState() => _ClassesEditFormState();
}

class _ClassesEditFormState extends State<ClassesEditForm> {
  final logic = Get.find<ClassesLogic>();
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
    logic.uPassword.value = widget.initialPassword;
    logic.uStatus.value = widget.initialStatus;
    logic.uPhone.value = widget.initialPhone;
    logic.uInstitutionId.value = widget.initialInstitutionId;
    logic.uInstitutionName.value = widget.initialInstitutionName;
    logic.uClassId.value = widget.initialClassId;
    logic.uClassName.value = widget.initialClassName;
    logic.uReferrer.value = widget.initialReferrer;
    logic.uJobCode.value = widget.initialJobCode;
    logic.uJobName.value = widget.initialJobName;
    logic.uJobDesc.value = widget.initialJobDesc;
    logic.uMajorIds.value = widget.initialMajorIds;
    logic.uMajorNames.value = widget.initialMajorNames;
    logic.uStatus.value = widget.initialStatus;
    logic.uExpireTime.value = widget.initialExpireTime as String;
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
                  selectedValue: ValueNotifier<String?>(
                      logic.uStatus.value.toString()),
                  onChanged: (dynamic newValue) {
                    print(newValue);
                    logic.uStatus.value = newValue;
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
                    Text('密码'),
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
                  hint: "输入密码",
                  text: logic.uPassword,
                  onTextChanged: (value) {
                    logic.uPassword.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '密码不能为空'),
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
                  maxLines: 1,
                  hint: "输入手机号",
                  text: logic.uPhone,
                  onTextChanged: (value) {
                    logic.uPhone.value = value;
                  },
                  validator:
                  FormBuilderValidators.compose([
                    FormBuilderValidators.required(errorText: '手机号不能为空'),
                    FormBuilderValidators.numeric(
                        errorText: '请输入有效的手机号'),
                    FormBuilderValidators.minLength(
                        11, errorText: '手机号至少11位'),
                    FormBuilderValidators.maxLength(
                        11, errorText: '手机号最多11位'),
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
                    Text('机构名称'),
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
                  hint: "输入机构名称",
                  text: logic.uInstitutionName,
                  onTextChanged: (value) {
                    logic.uInstitutionName.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '机构名称不能为空'),
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
                  maxLines: 1,
                  hint: "输入班级ID",
                  text: logic.uClassId,
                  onTextChanged: (value) {
                    logic.uClassId.value = value;
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
                  text: logic.uClassName,
                  onTextChanged: (value) {
                    logic.uClassName.value = value;
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
                  maxLines: 1,
                  hint: "输入推荐人",
                  text: logic.uReferrer,
                  onTextChanged: (value) {
                    logic.uReferrer.value = value;
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
                    Text('职位编码'),
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
                  hint: "输入职位编码",
                  text: logic.uJobCode,
                  onTextChanged: (value) {
                    logic.uJobCode.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '职位编码不能为空'),
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
                    Text('职位名称'),
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
                  hint: "输入职位名称",
                  text: logic.uJobName,
                  onTextChanged: (value) {
                    logic.uJobName.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '职位名称不能为空'),
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
                    Text('职位描述'),
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
                  hint: "输入职位描述",
                  text: logic.uJobDesc,
                  onTextChanged: (value) {
                    logic.uJobDesc.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '职位描述不能为空'),
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
                    Text('专业ID'),
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
                  hint: "输入专业ID",
                  text: logic.uMajorIds,
                  onTextChanged: (value) {
                    logic.uMajorIds.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '专业ID不能为空'),
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
                    Text('专业名称'),
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
                  hint: "输入专业名称",
                  text: logic.uMajorNames,
                  onTextChanged: (value) {
                    logic.uMajorNames.value = value;
                  },
                  validator:
                  FormBuilderValidators.required(errorText: '专业名称不能为空'),
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
                    Text('状态名称'),
                    Text('*', style: TextStyle(color: Colors.red)),
                  ],
                ),
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
                      selectedValue: ValueNotifier<String?>(
                          logic.uStatus.value.toString()),
                      onChanged: (dynamic newValue) {
                        print(newValue);
                        logic.uStatus.value = newValue;
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
                    style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700]),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25B7E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('保存'),
                  ),
                ],
              ),
            ],
          ),
        ]),
      ),
    ));
  }
}
