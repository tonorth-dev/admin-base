import 'package:admin_flutter/ex/ex_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/classes_api.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../api/institution_api.dart';
import '../../../../api/student_api.dart';
import '../../../../component/dialog.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';
import '../student/student_add_form.dart';
import '../student/student_edit_form.dart';
import 'class_add_form.dart';
import 'class_edit_form.dart';
import 's_logic.dart';

class CLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 15.obs;
  var page = 1.obs;
  var loading = false.obs;
  final searchText = ''.obs;
  final sLogic = Get.put(SLogic());

  final GlobalKey<SuggestionTextFieldState> institutionTextFieldKey =
      GlobalKey<SuggestionTextFieldState>();

  // 当前编辑的题目数据
  var currentEditClasses = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;

  Rx<String> selectedInstitutionId = "0".obs;

  final name = ''.obs;
  final institutionId = ''.obs;
  final teacher = ''.obs;
  final createTime = ''.obs;

  final uName = ''.obs;
  final uInstitutionId = ''.obs;
  final uInstitutionName = ''.obs;
  final uTeacher = ''.obs;
  final uCreateTime = ''.obs;

  void find(int newSize, int newPage) {
    size.value = newSize;
    page.value = newPage;
    list.clear();
    selectedRows.clear();
    loading.value = true;
    sLogic.selectedClassesId.value = "0";
    sLogic.findForClasses(newSize, newPage);
    sLogic.enableRowSelection();
    // 打印调用堆栈
    try {
      ClassesApi.classesList(params: {
        "pageSize": size.value.toString(),
        "page": page.value.toString(),
        "keyword": searchText.value.toString() ?? "",
        "institution_id": (selectedInstitutionId.value.toString() ?? ""),
      }).then((value) async {
        if (value != null && value["list"] != null) {
          total.value = value["total"] ?? 0;
          list.assignAll((value["list"] as List<dynamic>).toListMap());
          await Future.delayed(const Duration(milliseconds: 300));
          loading.value = false;
        } else {
          loading.value = false;
          "未获取到班级数据".toHint();
        }
      }).catchError((error) {
        loading.value = false;
        print("获取班级列表失败: $error");
        "获取班级列表失败: $error".toHint();
      });
    } catch (e) {
      loading.value = false;
      print("获取班级列表失败: $e");
      "获取班级列表失败: $e".toHint();
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    find(size.value,
        page.value); // Fetch and populate classes data on initialization

    columns = [
      ColumnData(title: "ID", key: "id", width: 60),
      ColumnData(title: "班级名称", key: "class_name", width: 120),
      ColumnData(title: "机构名称", key: "institution_name", width: 120),
      ColumnData(title: "教师", key: "teacher", width: 100),
      ColumnData(title: "创建时间", key: "create_time", width: 100),
    ];
  }

  Future<List<String>> fetchInstructions(String query) async {
    print("query:$query");
    try {
      final response = await InstitutionApi.institutionList(params: {
        "pageSize": 10,
        "page": 1,
        "keyword": query ?? "",
      });
      var data = response['list'];
      print("response: $data");
      // 检查数据是否为 List
      if (data is List) {
        final List<String> suggestions = data.map((item) {
          // 检查每个 item 是否包含 'name' 和 'id' 字段
          if (item is Map &&
              item.containsKey('name') &&
              item.containsKey('id')) {
            return "${item['name']}（ID：${item['id']}）";
          } else {
            throw FormatException('Invalid item format: $item');
          }
        }).toList();
        print("suggestions： $suggestions");
        return suggestions;
      } else {
        // Handle the case where data is not a List
        return [];
      }
    } catch (e) {
      // Handle any exceptions that are thrown
      print('Error fetching instructions: $e');
      return [];
    }
  }

  Future<bool> saveClasses() async {
    final classNameSubmit = name.value;
    final institutionIdSubmit = institutionId.value;
    final teacherSubmit = teacher.value;

    bool isValid = true;
    String errorMessage = "";

    if (classNameSubmit.isEmpty) {
      isValid = false;
      errorMessage += "班级名称不能为空\n";
    }
    if (institutionIdSubmit.isEmpty) {
      isValid = false;
      errorMessage += "机构名称不能为空\n";
    }
    if (teacherSubmit.isEmpty) {
      isValid = false;
      errorMessage += "教师不能为空\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "class_name": classNameSubmit,
          "institution_id": int.parse(institutionIdSubmit),
          "teacher": teacherSubmit,
        };

        dynamic result = await ClassesApi.classesCreate(params);
        if (result['id'] > 0) {
          "创建班级成功".toHint();
          return true;
        } else {
          "创建班级失败".toHint();
          return false;
        }
      } catch (e) {
        print('Error: $e');
        "创建班级时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }

  Future<bool> updateClasses(int classesId) async {
    final uClassNameSubmit = uName.value;
    final uInstitutionIdSubmit = uInstitutionId.value;
    final uTeacherSubmit = uTeacher.value;

    bool isValid = true;
    String errorMessage = "";

    if (uClassNameSubmit.isEmpty) {
      isValid = false;
      errorMessage += "班级名称不能为空\n";
    }
    if (uInstitutionIdSubmit.isEmpty) {
      isValid = false;
      errorMessage += "机构名称不能为空\n";
    }
    if (uTeacherSubmit.isEmpty) {
      isValid = false;
      errorMessage += "教师不能为空\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "class_name": uClassNameSubmit,
          "institution_id": int.parse(uInstitutionIdSubmit),
          "teacher": uTeacherSubmit,
        };

        dynamic result = await ClassesApi.classesUpdate(classesId, params);
        "更新班级成功".toHint();
        return true;
      } catch (e) {
        print('Error: $e');
        "更新班级时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }

  void delete(Map<String, dynamic> d, int index) {
    try {
      ClassesApi.classesDelete(d["id"].toString()).then((value) {
        list.removeAt(index);
      }).catchError((error) {
        "删除失败: $error".toHint();
      });
    } catch (e) {
      "删除失败: $e".toHint();
    }
  }

  Future<void> audit(int classesId, int status) async {
    try {
      await ClassesApi.auditClasses(classesId, status);
      "审核完成".toHint();
      find(size.value, page.value);
    } catch (e) {
      "审核失败: $e".toHint();
    }
  }

  @override
  void refresh() {
    find(size.value, page.value);
  }

  // 导出选中项到 CSV 文件
  Future<void> exportSelectedItemsToCSV() async {
    try {
      if (selectedRows.isEmpty) {
        "请选择要导出的数据".toHint();
        return;
      }

      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      List<List<dynamic>> rows = [];
      rows.add(columns.map((column) => column.title).toList());

      for (var item in list) {
        if (selectedRows.contains(item['id'])) {
          rows.add(columns.map((column) => item[column.key]).toList());
        }
      }

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyyMMdd_HHmmss').format(now);
      String csv = const ListToCsvConverter().convert(rows);
      File('$directory/classess_selected_$formattedDate.csv')
          .writeAsStringSync(csv);
      "导出选中项成功!".toHint();
    } catch (e) {
      "导出选中项失败: $e".toHint();
    }
  }

  void add(BuildContext context) {
    DynamicInputDialog.show(
      context: context,
      title: '录入考生',
      child: ClassesAddForm(),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  void edit(BuildContext context, Map<String, dynamic> classes) {
    DynamicInputDialog.show(
      context: context,
      title: '录入考生',
      child: ClassesEditForm(
        classesId: classes["id"],
        initialName: classes["class_name"],
        initialInstitutionId: classes["institution_id"].toString(),
        initialInstitutionName: classes["institution_name"].toString(),
        initialTeacher: classes["teacher"],
      ),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  Future<void> exportAllToCSV() async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      List<Map<String, dynamic>> allItems = [];
      int currentPage = 1;
      int pageSize = 100;

      while (true) {
        var response = await ClassesApi.classesList();

        allItems.addAll((response["list"] as List<dynamic>).toListMap());

        if (allItems.length >= response["total"]) break;
        currentPage++;
      }

      List<List<dynamic>> rows = [];
      rows.add(columns.map((column) => column.title).toList());

      for (var item in allItems) {
        rows.add(columns.map((column) => item[column.key]).toList());
      }

      String csv = const ListToCsvConverter().convert(rows);
      File('$directory/classess_all_pages.csv').writeAsStringSync(csv);
      "导出全部成功!".toHint();
    } catch (e) {
      "导出全部失败: $e".toHint();
    }
  }

  void importFromCSV() async {
    try {
      FilePickerResult? result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result != null) {
        PlatformFile file = result.files.first;
        String content;

        // 使用文件路径读取内容
        if (file.path != null) {
          content = await File(file.path!).readAsString(encoding: utf8);

          // 检查文件内容是否为空
          if (content.isEmpty) {
            "文件内容为空".toHint();
            return;
          }

          // 检查 BOM 并移除
          if (content.startsWith('\uFEFF')) {
            content = content.substring(1);
          }

          // 解析 CSV 内容
          List<List<dynamic>> rows =
              const CsvToListConverter().convert(content);
          rows.removeAt(0); // 移除表头

          // 调用 API 执行批量导入
          await ClassesApi.classesBatchImport(File(file.path!)).then((value) {
            "导入成功!".toHint();
            refresh();
          }).catchError((error) {
            "导入失败: $error".toHint();
          });
        } else {
          "文件路径为空，无法读取文件".toHint();
        }
      } else {
        "没有选择文件".toHint();
      }
    } catch (e) {
      "导入失败: $e".toHint();
    }
  }

  void batchDelete(List<int> ids) {
    try {
      List<String> idsStr = ids.map((id) => id.toString()).toList();
      if (idsStr.isEmpty) {
        "请先选择要删除的班级".toHint();
        return;
      }
      ClassesApi.classesDelete(idsStr.join(",")).then((value) {
        "批量删除成功!".toHint();
        selectedRows.clear();
        refresh();
      }).catchError((error) {
        "批量删除失败: $error".toHint();
      });
    } catch (e) {
      "批量删除失败: $e".toHint();
    }
  }

  void toggleSelectAll() {
    selectedRows.clear();
  }

  Future<void> toggleSelect(int id) async {
    if (selectedRows.contains(id)) {
      // 当前行已被选中，取消选中
      selectedRows.remove(id);
      selectedRows.clear();
      sLogic.selectedRows.clear();
      sLogic.selectedClassesId.value = "0";
      sLogic.enableRowSelection();
    } else {
      // 当前行未被选中，选中
      selectedRows.clear();
      selectedRows.add(id);
      sLogic.selectedClassesId.value = id.toString();
      await sLogic.findForClasses(sLogic.size.value, sLogic.page.value);
      sLogic.disableRowSelection();
    }
  }

  void reset() {
    institutionTextFieldKey.currentState?.reset();
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    find(size.value, page.value);
  }

  final Map<int, ValueNotifier<bool>> blueButtonStates = {};
  final Map<int, ValueNotifier<bool>> grayButtonStates = {};
  final Map<int, ValueNotifier<bool>> redButtonStates = {};

  void blueButtonAction(int id) {
    if (!blueButtonStates[id]!.value) {
      return;
    }
    print("蓝色按钮点击");
    if (selectedRows.contains(id)) {
      blueButtonStates[id]!.value = false;
      sLogic.enableRowSelection();
      grayButtonStates[id]!.value = true;
      redButtonStates[id]!.value = true;
    } else {
      "请先选择要操作的班级".toHint();
    }
  }

  void grayButtonAction(int classesId) {
    if (!grayButtonStates[classesId]!.value) {
      return;
    }
    print("灰色按钮点击");
    sLogic.findForClasses(sLogic.size.value, sLogic.page.value);
    sLogic.disableRowSelection();
    blueButtonStates[classesId]!.value = true;
    grayButtonStates[classesId]!.value = false;
    redButtonStates[classesId]!.value = false;
  }

  Future<void> redButtonAction(int classId) async {
    if (!grayButtonStates[classId]!.value) {
      return;
    }
    print("红色按钮点击");
    List<String> hasClassesStudents = [];
    for (var id in sLogic.selectedRows) {
      // 找到与 id 匹配的岗位数据
      var student = sLogic.list
          .firstWhere((student) => student['id'] == id, orElse: () => {});
      if (student.isNotEmpty &&
          student['class_id'] > 0 &&
          student['class_id'] != classId) {
        hasClassesStudents.add(
            "学生姓名：${student['name']}，学生ID：${student['id']}"); // 记录classes_id > 0的数据
      }
    }

    if (hasClassesStudents.isNotEmpty) {
      // 生成确认弹窗
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Container(
            width: 800, // 设置你想要的宽度
            padding: EdgeInsets.all(16.0),
            child: AlertDialog(
              title: Text("确认"),
              content:
                  Text("${hasClassesStudents.join("，")}，已经绑定在其它班级上，是否继续执行？"),
              actions: <Widget>[
                TextButton(
                  child: Text("取消"),
                  onPressed: () {
                    Get.back(); // 关闭对话框
                  },
                ),
                TextButton(
                  child: Text("确认"),
                  onPressed: () async {
                    // 用户确认后执行的操作
                    try {
                      await StudentApi.studentUpdateClasses(
                          sLogic.selectedRows, classId);
                      "绑定成功".toHint();
                      sLogic.disableRowSelection();
                      blueButtonStates[classId]!.value = true;
                      grayButtonStates[classId]!.value = false;
                      redButtonStates[classId]!.value = false;
                      sLogic.findForClasses(
                          sLogic.size.value, sLogic.page.value);
                    } catch (e) {
                      print('Error: $e');
                      "绑定时发生错误：$e".toHint();
                    } finally {
                      Get.back(); // 确保对话框关闭
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // 如果没有符合条件的数据，则直接执行后续操作
      try {
        await StudentApi.studentUpdateClasses(sLogic.selectedRows, classId);
        "绑定成功".toHint();
        sLogic.disableRowSelection();
        blueButtonStates[classId]!.value = true;
        grayButtonStates[classId]!.value = false;
        redButtonStates[classId]!.value = false;
        sLogic.findForClasses(sLogic.size.value, sLogic.page.value);
      } catch (e) {
        print('Error: $e');
        "绑定时发生错误：$e".toHint();
      }
      sLogic.disableRowSelection();
    }
  }
}
