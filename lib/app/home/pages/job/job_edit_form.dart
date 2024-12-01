// import 'package:flutter/material.dart';
// import 'package:flutter_form_builder/flutter_form_builder.dart';
// import 'package:form_builder_validators/form_builder_validators.dart';
// import 'package:admin_flutter/api/job_api.dart'; // 导入 job_api.dart
// import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import '../../../../component/widget.dart';
// import 'logic.dart';
//
// class JobEditForm extends StatefulWidget {
//   const JobEditForm({super.key});
//
//   @override
//   State<JobEditForm> createState() => _JobAddFormState();
// }
//
// class _JobAddFormState extends State<JobEditForm> {
//   final logic = Get.put(JobLogic());
//   final _formKey = GlobalKey<FormBuilderState>();
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState?.saveAndValidate() ?? false) {
//       final result = await logic.saveJob();
//       if (result) {
//         Navigator.pop(context);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: FormBuilder(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(width: 800),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('岗位代码'),
//                         Text('*', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 600,
//                     child: TextInputWidget(
//                       width: 240,
//                       height: 34,
//                       maxLines: 8,
//                       hint: "输入岗位代码",
//                       text: logic.jobTitle,
//                       onTextChanged: (value) {
//                         logic.jobTitle.value = value;
//                       },
//                       validator:
//                       FormBuilderValidators.required(errorText: '岗位代码不能为空'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('岗位名称'),
//                         Text('*', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 600,
//                     child: TextInputWidget(
//                       width: 240,
//                       height: 34,
//                       maxLines: 8,
//                       hint: "输入岗位名称",
//                       text: logic.jobTitle,
//                       onTextChanged: (value) {
//                         logic.jobTitle.value = value;
//                       },
//                       validator:
//                       FormBuilderValidators.required(errorText: '岗位名称不能为空'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('岗位类别'),
//                         Text('*', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 600,
//                     child: TextInputWidget(
//                       width: 240,
//                       height: 34,
//                       maxLines: 8,
//                       hint: "输入岗位类别",
//                       text: logic.jobTitle,
//                       onTextChanged: (value) {
//                         logic.jobTitle.value = value;
//                       },
//                       validator:
//                       FormBuilderValidators.required(errorText: '岗位类别不能为空'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('招生数量'),
//                         Text('*', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 600,
//                     child: NumberInputWidget(
//                       key: UniqueKey(),
//                       width: 90,
//                       height: 34,
//                       hint: "招生数量",
//                       selectedValue: 0.obs,
//                       onValueChanged: (value) {
//                         // logic.jobTitle.value = value;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('入围比例'),
//                         Text('*', style: TextStyle(color: Colors.red)),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 600,
//                     child: TextInputWidget(
//                       width: 240,
//                       height: 34,
//                       maxLines: 8,
//                       hint: "输入入围比例",
//                       text: logic.jobTitle,
//                       onTextChanged: (value) {
//                         logic.jobTitle.value = value;
//                       },
//                       validator:
//                       FormBuilderValidators.required(errorText: '入围比例不能为空'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Row(children: [
//                 SizedBox(
//                   width: 150,
//                   child: Row(
//                     children: const [
//                       Text('报名条件'),
//                       Text('*', style: TextStyle(color: Colors.red)),
//                     ],
//                   ),
//                 ),
//                 SingleChildScrollView(
//                   child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 70,
//                               child: Row(
//                                 children: const [
//                                   Text('来源类别'),
//                                   Text('*',
//                                       style: TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 100,
//                               child: DropdownField(
//                                 items: [
//                                   {'id': '0', 'name': '高校毕业生'},
//                                   {'id': '1', 'name': '社会人才'},
//                                   {'id': '2', 'name': '高校毕业生或社会人才'}
//                                 ],
//                                 hint: '',
//                                 label: true,
//                                 width: 120,
//                                 height: 34,
//                                 selectedValue: logic.jobSelectedQuestionCate,
//                                 onChanged: (dynamic newValue) {
//                                   logic.jobSelectedQuestionCate.value =
//                                       newValue.toString();
//                                 },
//                               ),
//                             ),
//                             SizedBox(
//                               width: 30,
//                             ),
//                             SizedBox(
//                               width: 40,
//                               child: Row(
//                                 children: const [
//                                   Text('学历'),
//                                   Text('*',
//                                       style: TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 100,
//                               child: DropdownField(
//                                 items: [
//                                   {'id': '0', 'name': '全日制本科以上'},
//                                   {'id': '1', 'name': '全日制研究生以上'},
//                                 ],
//                                 hint: '',
//                                 label: true,
//                                 width: 120,
//                                 height: 34,
//                                 selectedValue: logic.jobSelectedQuestionCate,
//                                 onChanged: (dynamic newValue) {
//                                   logic.jobSelectedQuestionCate.value =
//                                       newValue.toString();
//                                 },
//                               ),
//                             ),
//                             SizedBox(
//                               width: 30,
//                             ),
//                             SizedBox(
//                               width: 40,
//                               child: Row(
//                                 children: const [
//                                   Text('学位'),
//                                   Text('*',
//                                       style: TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 100,
//                               child: DropdownField(
//                                 items: [
//                                   {'id': '0', 'name': '学士以上'},
//                                   {'id': '1', 'name': '硕士以上'},
//                                   {'id': '2', 'name': '博士以上'},
//                                 ],
//                                 hint: '',
//                                 label: true,
//                                 width: 120,
//                                 height: 34,
//                                 selectedValue: logic.jobSelectedQuestionCate,
//                                 onChanged: (dynamic newValue) {
//                                   logic.jobSelectedQuestionCate.value =
//                                       newValue.toString();
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 150,
//                               child: Row(
//                                 children: const [
//                                   Text('所学专业'),
//                                   Text('*',
//                                       style: TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 600,
//                               child: TextInputWidget(
//                                 width: 240,
//                                 height: 34,
//                                 maxLines: 8,
//                                 hint: "输入所学专业",
//                                 text: logic.jobTitle,
//                                 onTextChanged: (value) {
//                                   logic.jobTitle.value = value;
//                                 },
//                                 validator: FormBuilderValidators.required(
//                                     errorText: '所学专业不能为空'),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 150,
//                               child: Row(
//                                 children: const [
//                                   Text('考试专业科目'),
//                                   Text('*',
//                                       style: TextStyle(color: Colors.red)),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 600,
//                               child: TextInputWidget(
//                                 width: 240,
//                                 height: 34,
//                                 maxLines: 8,
//                                 hint: "输入专业科目",
//                                 text: logic.jobTitle,
//                                 onTextChanged: (value) {
//                                   logic.jobTitle.value = value;
//                                 },
//                                 validator: FormBuilderValidators.required(
//                                     errorText: '专业科目不能为空'),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             SizedBox(
//                               width: 150,
//                               child: Row(
//                                 children: const [
//                                   Text('其它条件'),
//                                 ],
//                               ),
//                             ),
//                             SizedBox(
//                               width: 600,
//                               child: TextInputWidget(
//                                 width: 240,
//                                 height: 120,
//                                 maxLines: 8,
//                                 hint: "输入其它条件",
//                                 text: logic.jobTitle,
//                                 onTextChanged: (value) {
//                                   logic.jobTitle.value = value;
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 10),
//                       ]),
//                 ),
//               ]),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('工作地点'),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 120,
//                     child: TextInputWidget(
//                       width: 240,
//                       height: 34,
//                       maxLines: 8,
//                       hint: "输入工作地点",
//                       text: logic.jobTitle,
//                       onTextChanged: (value) {
//                         logic.jobTitle.value = value;
//                       },
//                     ),
//                   ),
//                   SizedBox(
//                     width: 150,
//                     child: Row(
//                       children: const [
//                         Text('咨询电话'),
//                       ],
//                     ),
//                   ),
//                   SizedBox(
//                     width: 120,
//                     child: TextInputWidget(
//                       width: 240,
//                       height: 34,
//                       maxLines: 8,
//                       hint: "输入咨询电话",
//                       text: logic.jobTitle,
//                       onTextChanged: (value) {
//                         logic.jobTitle.value = value;
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
