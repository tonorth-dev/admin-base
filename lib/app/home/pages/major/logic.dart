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

class MajorLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 0.obs;
  var page = 0.obs;
  var key = ''.obs;
  var loading = false.obs;
  RxList<int> selectedRows = <int>[].obs;
  Function(List<int>)? onMajorRowSelected;

  void find(int size, int page, String search) {
    // 更新 size、page 和 search
    this.size.value = size;
    this.page.value = page;
    this.key.value = search;

    // 清空列表
    list.clear();

    // 设置加载状态
    loading.value = true;

    // 构建参数
    final params = {
      'size': size.toString(),
      'page': page.toString(),
      'search': search,
    };

    // 调用 API 并处理响应
    MajorApi.majorList(params: params).then((value) async {
      total.value = value["total"];
      list.addAll((value["list"] as List<dynamic>).cast<Map<String, dynamic>>());
      list.refresh();
      print('major Data loaded: ${list}');

      // 休眠 300 毫秒
      await Future.delayed(const Duration(milliseconds: 300));

      // 关闭加载状态
      loading.value = false;
    }).catchError((error) {
      print('Error in find: $error');
      loading.value = false;
    });
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "第一分类", key: "first_level_category"),
      ColumnData(title: "第二分类", key: "second_level_category"),
      ColumnData(title: "专业名称", key: "major_name"),
      ColumnData(title: "创建时间", key: "create_time"),
    ];
  }

  var form = FormDto(labelWidth: 80, columns: [
    FormColumnDto(
      label: "岗位名称",
      key: "job_cate",
      placeholder: "请输入岗位名称",
    ),
    FormColumnDto(
        label: "岗位类别",
        key: "job_cate",
        placeholder: "请输入岗位类别",
        type: FormColumnEnum.text),
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
          MajorApi.majorInsert(params: data).then((value) {
            "插入成功!".toHint();
            find(size as int, page as int, '');
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
    MajorApi.majorDelete(params: {"id": d["id"]}).then((value) {
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
    find(size as int, page as int, '');
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
          find(size as int, page as int, '');
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

  RxInt selectedRowIndex = RxInt(-1);

  void selectRow(int index) {
    selectedRowIndex.value = index;
    selectedRows.clear();
    if (index >= 0 && index < list.length) {
      selectedRows.add(list[index]['id']);
    }
  }

  void confirmAssociation(Map<String, dynamic> rowData) {
    // 在这里实现确认关联的逻辑
    // 例如：发送请求到后端保存关联关系
    print('Confirming association for: ${rowData}');
    // 操作完成后，重置选中状态
    selectRow(-1);
  }

  void saveSelectionLocally() {
    for (var majorId in selectedRows) {
      // majorToJobMap[majorId] = selectedRows.toList();
    }
  }
}
