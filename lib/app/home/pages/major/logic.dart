import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/api/major_api.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:admin_flutter/component/form/enum.dart';
import 'package:admin_flutter/component/form/form_data.dart';
import 'package:admin_flutter/component/table/ex.dart';

class MajorLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 0;
  var page = 0;
  var loading = false.obs;

  void find(int size, int page) {
    this.size = size;
    this.page = page;
    list.clear();
    loading.value = true;
    MajorApi.majorList(params: {
      "size": size,
      "page": page,
    }).then((value) async {
      total.value = value["total"];
      list.addAll((value["list"] as List<dynamic>).toListMap());
      list.refresh();
      // 休眠 300 毫秒
      await Future.delayed(const Duration(milliseconds: 100));
      loading.value = false;
    });
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "岗位名称", key: "job_ame"),
      ColumnData(title: "岗位类别", key: "job_cate"),
      ColumnData(title: "从事工作", key: "job_desc"),
      ColumnData(title: "所学专业", key: "majors"),
      ColumnData(title: "创建时间", key: "create_time"),
      TableEx.edit(edit: (d, index) {
        form.data = d;
        form.edit(
            submit: (data) => {
              MajorApi.majorUpdate(params: data).then((value) {
                "更新成功!".toHint();
                list.removeAt(index);
                list.insert(index, data);
                Get.back();
              })
            });
      }, delete: (d, index) {
        MajorApi.majorDelete(params: {"ID": d["ID"]}).then((value) {
          list.removeAt(index);
        });
      }),
    ];
  }

  var form = FormDto(labelWidth: 80, columns: [
    FormColumnDto(
      label: "岗位名称",
      key: "JobName",
      placeholder: "请输入岗位名称",
    ),
    FormColumnDto(
        label: "岗位类别",
        key: "JobCate",
        placeholder: "请输入岗位类别",
        type: FormColumnEnum.text),
    FormColumnDto(
      label: "从事工作",
      key: "JobDesc",
      placeholder: "请输入从事工作",
    ),
    FormColumnDto(
      label: "所学专业",
      key: "Majors",
      placeholder: "请输入所学专业",
    ),
  ]);

  List<int> get selectedRows => [];

  void add() {
    form.add(
        reset: true,
        submit: (data) => {
          MajorApi.majorInsert(params: data).then((value) {
            "插入成功!".toHint();
            find(size, page);
            Get.back();
          })
        });
  }

  void modify(Map<String, dynamic> d, int index) {
    form.data = d;
    form.edit(
        submit: (data) => {
          MajorApi.majorUpdate(params: data).then((value) {
            "更新成功!".toHint();
            list.removeAt(index);
            list.insert(index, data);
            Get.back();
          })
        });
  }

  void delete(Map<String, dynamic> d, int index) {
    MajorApi.majorDelete(params: {"ID": d["ID"]}).then((value) {
      list.removeAt(index);
    });
  }

  void batchDelete(List<int> d) {
    print(List);
  }

  void search(String key) {
    MajorApi.majorSearch(params: {"key": key}).then((value) {
      refresh();
    });
  }

  // 刷新功能
  void refresh() {
    find(size, page);
  }

  // 导出当前页功能
  Future<void> exportCurrentPageToCSV() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) return;

    List<List<dynamic>> rows = [];
    rows.add(columns.map((column) => column.title).toList());

    for (var item in list) {
      rows.add(columns.map((column) => item[column.key]).toList());
    }

    String csv = const ListToCsvConverter().convert(rows);
    File('$directory/majors_current_page.csv').writeAsStringSync(csv);
    "导出当前页成功!".toHint();
  }

  // 导出全部功能
  Future<void> exportAllToCSV() async {
    final directory = await FilePicker.platform.getDirectoryPath();
    if (directory == null) return;

    List<Map<String, dynamic>> allItems = [];
    int currentPage = 1;
    int pageSize = 100;

    while (true) {
      var response = await MajorApi.majorList(params: {
        "size": pageSize,
        "page": currentPage,
      });

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
    File('$directory/majors_all_pages.csv').writeAsStringSync(csv);
    "导出全部成功!".toHint();
  }

  // 加入导入功能
  void importFromCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
    if (result != null) {
      PlatformFile file = result.files.first;
      String content = utf8.decode(file.bytes!);

      List<List<dynamic>> rows = const CsvToListConverter().convert(content);
      rows.removeAt(0); // 移除表头

      for (var row in rows) {
        Map<String, dynamic> data = {};
        for (int i = 0; i < columns.length; i++) {
          data[columns[i].key] = row[i];
        }
        MajorApi.majorInsert(params: data).then((value) {
          "导入成功!".toHint();
          find(size, page);
        }).catchError((error) {
          "导入失败: $error".toHint();
        });
      }
    }
  }

  void toggleSelect(int rowIndex) {
    final id = list[rowIndex]['id'];
    if (selectedRows.contains(id)) {
      selectedRows.remove(id);
    } else {
      selectedRows.add(id);
    }
    update(); // 更新视图
  }

  void toggleSelectAll() {
    if (selectedRows.length == list.length) {
      selectedRows.clear();
    } else {
      selectedRows.assignAll(list.map((item) => item['id']));
    }
    update(); // 更新 UI
  }
}
