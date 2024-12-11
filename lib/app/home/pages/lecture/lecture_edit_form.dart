import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:admin_flutter/api/lecture_api.dart';
import 'package:get/get.dart';
import '../../../../component/widget.dart';
import 'logic.dart';

class LectureEditForm extends StatefulWidget {
  final int lectureId;
  final String lectureName;
  final int majorId;
  final int jobCode;
  final int sort;
  final String creator;
  final String lectureCategory;
  final int pageCount;
  final int status;

  LectureEditForm({
    required this.lectureId,
    required this.lectureName,
    required this.majorId,
    required this.jobCode,
    required this.sort,
    required this.creator,
    required this.lectureCategory,
    required this.pageCount,
    required this.status,
  });

  @override
  State<LectureEditForm> createState() => _LectureEditFormState();
}


class _LectureEditFormState extends State<LectureEditForm> {
  final logic = Get.put(LectureLogic());
  final _formKey = GlobalKey<FormBuilderState>();

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final result = await logic.updateLecture(widget.lectureId);
      if (result) {
        Navigator.pop(context);
        logic.find(logic.size.value, logic.page.value); // 刷新列表
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // 设置初始值
    logic.uLectureId.value = widget.lectureId;
    logic.uLectureName.value = widget.lectureName;
    logic.uMajorId.value = widget.majorId;
    logic.uJobCode.value = widget.jobCode;
    logic.uSort.value = widget.sort;
    logic.uCreator.value = widget.creator;
    logic.uLectureCategory.value = widget.lectureCategory;
    logic.uPageCount.value = widget.pageCount;
    logic.uStatus.value = widget.status;
  }

  @override
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
                          Text('讲义名称'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 620,
                      child: TextInputWidget(
                        width: 240,
                        height: 34,
                        maxLines: 8,
                        hint: "输入讲义名称",
                        text: logic.uLectureName,
                        onTextChanged: (value) {
                          logic.uLectureName.value = value;
                        },
                        validator: FormBuilderValidators.required(
                            errorText: '讲义名称不能为空'),
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
                          Text('讲义类别'),
                          Text('*', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 620,
                      child: TextInputWidget(
                        width: 240,
                        height: 34,
                        maxLines: 8,
                        hint: "输入讲义类别",
                        text: logic.uLectureCategory,
                        onTextChanged: (value) {
                          logic.uLectureCategory.value = value;
                        },
                        validator: FormBuilderValidators.required(
                            errorText: '讲义类别不能为空'),
                      ),
                    ),
                  ],
                ),
                // 添加其他需要的表单项...
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
