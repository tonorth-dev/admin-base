import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/api/job_api.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:admin_flutter/component/form/enum.dart';
import 'package:admin_flutter/component/form/form_data.dart';

class JobLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 0;
  var page = 0;
  var loading = false.obs;
  RxList<int> selectedRows = <int>[].obs;
  Map<int, List<int>> majorToJobMap = {}; // 本地存储专业与岗位关系

  void find(int size, int page) {
    this.size = size;
    this.page = page;
    list.clear();
    loading.value = true;
    JobApi.jobList(params: {
      "size": size,
      "page": page,
    }).then((value) async {
      total.value = value["total"];
      list.addAll((value["list"] as List<dynamic>).toListMap());
      list.refresh();
      print('job Data loaded: ${list}');
      // 休眠 300 毫秒
      await Future.delayed(const Duration(milliseconds: 300));
      loading.value = false;
    });
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "岗位名称", key: "name"),
      ColumnData(title: "岗位类别", key: "cate"),
      ColumnData(title: "用人单位代码", key: "company_code"),
      ColumnData(title: "用人单位名称", key: "company_name"),
      ColumnData(title: "从事工作", key: "job_desc"),
      ColumnData(title: "所学专业", key: "majors"),
      ColumnData(title: "创建时间", key: "create_time"),
    ];
  }

  var form = FormDto(labelWidth: 80, columns: [
    FormColumnDto(
      label: "岗位名称",
      key: "name",
      placeholder: "请输入岗位名称",
    ),
    FormColumnDto(
        label: "岗位类别",
        key: "cate",
        placeholder: "请输入岗位类别",
        type: FormColumnEnum.text),
    FormColumnDto(
      label: "用人单位代码",
      key: "company_code",
      placeholder: "请输入用人单位代码",
    ),
    FormColumnDto(
      label: "用人单位名称",
      key: "company_name",
      placeholder: "请输入用人单位名称",
    ),
    FormColumnDto(
      label: "从事工作",
      key: "job_desc",
      placeholder: "请输入从事工作",
    ),
    FormColumnDto(
      label: "所学专业",
      key: "majors",
      placeholder: "请输入所学专业",
    ),
  ]);

  void add() {
    form.add(
        reset: true,
        submit: (data) => {
          JobApi.jobInsert(params: data).then((value) {
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
              JobApi.jobUpdate(params: data).then((value) {
                "更新成功!".toHint();
                list.removeAt(index);
                list.insert(index, data);
                Get.back();
              })
            });
  }

  void delete(Map<String, dynamic> d, int index) {
    JobApi.jobDelete(params: {"id": d["id"]}).then((value) {
      list.removeAt(index);
    });
  }

  void batchDelete(List<int> d) {
    print(List);
  }

  void search(String key) {
    JobApi.jobSearch(params: {"key": key}).then((value) {
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
    File('$directory/jobs_current_page.csv').writeAsStringSync(csv);
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
      var response = await JobApi.jobList(params: {
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
    File('$directory/jobs_all_pages.csv').writeAsStringSync(csv);
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
        JobApi.jobInsert(params: data).then((value) {
          "导入成功!".toHint();
          find(size, page);
        }).catchError((error) {
          "导入失败: $error".toHint();
        });
      }
    }
  }

  void toggleSelectAll() {
    selectedRows.length == list.length ? selectedRows.clear() : selectedRows.addAll(list.map((item) => item['id']));
  }

  void toggleSelect(int index) {
    selectedRows.contains(index) ? selectedRows.remove(index) : selectedRows.add(index);
  }

  void updateJobSelection(List<int> majorIds) {
    selectedRows.clear();
    for (var majorId in majorIds) {
      selectedRows.addAll(majorToJobMap[majorId] ?? []);
    }
    update();
  }

}
