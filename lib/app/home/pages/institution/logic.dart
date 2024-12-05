import 'package:admin_flutter/app/home/pages/book/book.dart';
import 'package:admin_flutter/ex/ex_list.dart';
import 'package:admin_flutter/ex/ex_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/api/institution_api.dart';
import 'package:admin_flutter/ex/ex_hint.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:admin_flutter/component/form/enum.dart';
import 'package:admin_flutter/component/form/form_data.dart';
import 'package:admin_flutter/component/dialog.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../api/config_api.dart';
import '../../../../api/institution_api.dart';
import '../../../../component/table/table_data.dart';
import '../../../../component/widget.dart';
import 'institution_add_form.dart';
import 'institution_edit_form.dart';

class InstitutionLogic extends GetxController {
  var list = <Map<String, dynamic>>[].obs;
  var total = 0.obs;
  var size = 15.obs;
  var page = 1.obs;
  var loading = false.obs;
  final searchText = ''.obs;

  final GlobalKey<CascadingDropdownFieldState> institutionDropdownKey =
      GlobalKey<CascadingDropdownFieldState>();
  final GlobalKey<DropdownFieldState> cateDropdownKey =
      GlobalKey<DropdownFieldState>();
  final GlobalKey<DropdownFieldState> levelDropdownKey =
      GlobalKey<DropdownFieldState>();
  final GlobalKey<DropdownFieldState> statusDropdownKey =
      GlobalKey<DropdownFieldState>();

  // 当前编辑的题目数据
  var currentEditInstitution = RxMap<String, dynamic>({}).obs;
  RxList<int> selectedRows = <int>[].obs;

  final ValueNotifier<dynamic> selectedLevel1 = ValueNotifier(null);
  final ValueNotifier<dynamic> selectedLevel2 = ValueNotifier(null);
  final ValueNotifier<dynamic> selectedLevel3 = ValueNotifier(null);

  // 机构列表数据
  List<Map<String, dynamic>> institutionList = [];
  Map<String, List<Map<String, dynamic>>> subInstitutionMap = {};
  Map<String, List<Map<String, dynamic>>> subSubInstitutionMap = {};
  List<Map<String, dynamic>> level1Items = [];
  Map<String, List<Map<String, dynamic>>> level2Items = {};
  Map<String, List<Map<String, dynamic>>> level3Items = {};
  Rx<String> selectedInstitutionId = "0".obs;

  final RxString name = ''.obs;
  final RxString province = ''.obs;
  final RxString city = ''.obs;
  final RxString password = ''.obs;
  final RxString leader = ''.obs;
  final RxInt status = 0.obs; // 假设状态为整数，1表示激活，0表示停用

  final uName = ''.obs;
  final uProvince = ''.obs;
  final uCity = ''.obs;
  final uPassword = ''.obs;
  final uLeader = ''.obs;
  final uStatus = 0.obs;


  void find(int newSize, int newPage) {
    size.value = newSize;
    page.value = newPage;
    list.clear();
    selectedRows.clear();
    loading.value = true;
    // 打印调用堆栈
    try {
      InstitutionApi.institutionList(params: {
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
          "未获取到机构数据".toHint();
        }
      }).catchError((error) {
        loading.value = false;
        print("获取机构列表失败: $error");
        "获取机构列表失败: $error".toHint();
      });
    } catch (e) {
      loading.value = false;
      print("获取机构列表失败: $e");
      "获取机构列表失败: $e".toHint();
    }
  }

  var columns = <ColumnData>[];

  @override
  void onInit() {
    super.onInit();
    find(size.value, page.value);// Fetch and populate institution data on initialization

    columns = [
      ColumnData(title: "ID", key: "id", width: 80),
      ColumnData(title: "名称", key: "name", width: 200),
      ColumnData(title: "省份", key: "province", width: 200),
      ColumnData(title: "城市", key: "city", width: 200),
      ColumnData(title: "密码", key: "password", width: 200),
      ColumnData(title: "负责人", key: "leader", width: 200),
      ColumnData(title: "状态", key: "status_name", width: 100),
      ColumnData(title: "入驻时间", key: "create_time", width: 200),
    ];
  }

  void add(BuildContext context) {
    DynamicInputDialog.show(
      context: context,
      title: '录入机构',
      child: InstitutionAddForm(),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }

  void edit(BuildContext context, Map<String, dynamic> institution) {
    currentEditInstitution.value = RxMap<String, dynamic>(institution);

    DynamicInputDialog.show(
      context: context,
      title: '录入机构',
      child: InstitutionEditForm(
        institutionId: institution["id"],
        initialName: institution["name"],
        initialProvince: institution["province"],
        initialCity: institution["city"],
        initialPassword: institution["password"],
        initialLeader: institution["leader"],
        initialStatus: institution["status"],
      ),
      onSubmit: (formData) {
        print('提交的数据: $formData');
      },
    );
  }


  Future<bool> saveInstitution() async {
    final nameSubmit = name.value;
    final provinceSubmit = province.value;
    final citySubmit = city.value;
    final passwordSubmit = password.value;
    final leaderSubmit = leader.value;
    final statusSubmit = status.value;

    bool isValid = true;
    String errorMessage = "";

    if (nameSubmit.isEmpty) {
      isValid = false;
      errorMessage += "机构名称不能为空\n";
    }
    if (provinceSubmit.isEmpty) {
      isValid = false;
      errorMessage += "省份不能为空\n";
    }
    if (citySubmit.isEmpty) {
      isValid = false;
      errorMessage += "城市不能为空\n";
    }
    if (passwordSubmit.isEmpty) {
      isValid = false;
      errorMessage += "密码不能为空\n";
    }
    if (leaderSubmit.isEmpty) {
      isValid = false;
      errorMessage += "负责人不能为空\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "name": nameSubmit,
          "province": provinceSubmit,
          "city": citySubmit,
          "password": passwordSubmit,
          "leader": leaderSubmit,
          "status": statusSubmit,
        };

        dynamic result = await InstitutionApi.institutionCreate(params);
        if (result['id'] > 0) {
          "创建机构成功".toHint();
          return true;
        } else {
          "创建机构失败".toHint();
          return false;
        }
      } catch (e) {
        print('Error: $e');
        "创建机构时发生错误：$e".toHint();
        return false;
      }
    } else {
      // 显示错误提示
      errorMessage.toHint();
      return false;
    }
  }



  Future<bool> updateInstitution(int institutionId) async {
    // 生成题本的逻辑
    final uNameSubmit = uName.value;
    final uProvinceSubmit = uProvince.value;
    final uCitySubmit = uCity.value;
    final uPasswordSubmit = uPassword.value;
    final uLeaderSubmit = uLeader.value;
    final uStatusSubmit = uStatus.value;

    bool isValid = true;
    String errorMessage = "";

    if (uNameSubmit.isEmpty) {
      isValid = false;
      errorMessage += "机构名称不能为空\n";
    }
    if (uProvinceSubmit.isEmpty) {
      isValid = false;
      errorMessage += "省份不能为空\n";
    }
    if (uCitySubmit.isEmpty) {
      isValid = false;
      errorMessage += "城市不能为空\n";
    }
    if (uPasswordSubmit.isEmpty) {
      isValid = false;
      errorMessage += "密码不能为空\n";
    }
    if (uLeaderSubmit.isEmpty) {
      isValid = false;
      errorMessage += "负责人不能为空\n";
    }
    if (uStatusSubmit == null) {
      isValid = false;
      errorMessage += "状态不能为空\n";
    }

    if (isValid) {
      try {
        Map<String, dynamic> params = {
          "name": uNameSubmit,
          "province": uProvinceSubmit,
          "city": uCitySubmit,
          "password": uPasswordSubmit,
          "leader": uLeaderSubmit,
          "status": uStatusSubmit,
        };

        dynamic result = await InstitutionApi.institutionUpdate(institutionId, params);
        "更新机构成功".toHint();
        return true;
      } catch (e) {
        print('Error: $e');
        "更新机构时发生错误：$e".toHint();
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
      InstitutionApi.institutionDelete(d["id"].toString()).then((value) {
        list.removeAt(index);
      }).catchError((error) {
        "删除失败: $error".toHint();
      });
    } catch (e) {
      "删除失败: $e".toHint();
    }
  }

  Future<void> audit(int institutionId, int status) async {
    try {
      await InstitutionApi.auditInstitution(institutionId, status);
      "审核完成".toHint();
      find(size.value, page.value);
    } catch (e) {
      "审核失败: $e".toHint();
    }
  }

  void generateAndOpenLink(
      BuildContext context, Map<String, dynamic> item) async {
    final url =
        Uri.parse('http://localhost:8888/static/h5/?institutionId=${item['id']}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('无法打开链接')));
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
      File('$directory/institutions_selected_$formattedDate.csv')
          .writeAsStringSync(csv);
      "导出选中项成功!".toHint();
    } catch (e) {
      "导出选中项失败: $e".toHint();
    }
  }

  Future<void> exportAllToCSV() async {
    try {
      final directory = await FilePicker.platform.getDirectoryPath();
      if (directory == null) return;

      List<Map<String, dynamic>> allItems = [];
      int currentPage = 1;
      int pageSize = 100;

      while (true) {
        var response = await InstitutionApi.institutionList();

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
      File('$directory/institutions_all_pages.csv').writeAsStringSync(csv);
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
          await InstitutionApi.institutionBatchImport(File(file.path!)).then((value) {
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
        "请先选择要删除的机构".toHint();
        return;
      }
      InstitutionApi.institutionDelete(idsStr.join(",")).then((value) {
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
    if (selectedRows.length == list.length) {
      // 当前所有行都被选中，清空选中状态
      selectedRows.clear();
    } else {
      // 当前不是所有行都被选中，选择所有行
      selectedRows.assignAll(list.map((item) => item['id']));
    }
  }

  void toggleSelect(int id) {
    if (selectedRows.contains(id)) {
      // 当前行已被选中，取消选中
      selectedRows.remove(id);
    } else {
      // 当前行未被选中，选中
      selectedRows.add(id);
    }
  }

  void reset() {
    institutionDropdownKey.currentState?.reset();
    cateDropdownKey.currentState?.reset();
    levelDropdownKey.currentState?.reset();
    statusDropdownKey.currentState?.reset();
    searchText.value = '';
    selectedRows.clear();

    // 重新初始化数据
    find(size.value, page.value);
  }
}
