import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class InstitutionEditForm extends StatefulWidget {
  final int institutionId;
  final String initialName;
  final String initialProvince;
  final String initialCity;
  final String initialPassword;
  final String initialLeader;
  final String initialStatus;

  InstitutionEditForm({
    required this.institutionId,
    required this.initialName,
    required this.initialProvince,
    required this.initialCity,
    required this.initialPassword,
    required this.initialLeader,
    required this.initialStatus,
  });

  @override
  State<InstitutionEditForm> createState() => _EditInstitutionDialogState();
}

class _EditInstitutionDialogState extends State<InstitutionEditForm> {
  final logic = Get.find<InstitutionLogic>();
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await logic.updateInstitution(widget.institutionId);
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
    logic.uProvince.value = widget.initialProvince;
    logic.uCity.value = widget.initialCity;
    logic.uPassword.value = widget.initialPassword;
    logic.uLeader.value = widget.initialLeader;
    logic.uStatus.value = widget.initialStatus;
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
                        text: widget.initialName.obs,
                        onTextChanged: (value) {
                          logic.uName.value = value;
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
                          Text('省份'),
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
                        hint: "输入省份",
                        text: widget.initialProvince.obs,
                        onTextChanged: (value) {
                          logic.uProvince.value = value;
                        },
                        validator:
                        FormBuilderValidators.required(errorText: '省份不能为空'),
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
                          Text('城市'),
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
                        hint: "输入城市",
                        text: widget.initialCity.obs,
                        onTextChanged: (value) {
                          logic.uCity.value = value;
                        },
                        validator:
                        FormBuilderValidators.required(errorText: '城市不能为空'),
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
                        text: widget.initialPassword.obs,
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
                          Text('负责人'),
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
                        hint: "输入负责人",
                        text: widget.initialLeader.obs,
                        onTextChanged: (value) {
                          logic.uLeader.value = value;
                        },
                        validator:
                        FormBuilderValidators.required(errorText: '负责人不能为空'),
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
                          {'id': '3', 'name': '已过期'},
                        ],
                        hint: '',
                        label: true,
                        width: 100,
                        height: 34,
                        selectedValue: ValueNotifier<String?>(widget.initialLeader),
                        onChanged: (dynamic newValue) {
                          print(newValue);
                          logic.uStatus.value = newValue.toInt();
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
          ),
        ),
      ),
    );
  }
}
