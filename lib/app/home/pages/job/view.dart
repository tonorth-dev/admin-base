import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/component/table/view.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../state.dart';
import '../../../../state.dart';
import '../../../../theme/ui_theme.dart';
import 'logic.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:csv/csv.dart';

class JobPage extends StatelessWidget {
  JobPage({Key? key}) : super(key: key);

  final logic = Get.put(JobLogic());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            ThemeUtil.width(),
            const Text(
              "运行mock目录下的服务器体验",
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            FilledButton(
                onPressed: () {
                  logic.add();
                },
                child: const Text("新增")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () async {
                  await logic.exportCurrentPageToCSV();
                },
                child: const Text("导出当前页")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () async {
                  await logic.exportAllToCSV();
                },
                child: const Text("导出全部")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () {
                  logic.importFromCSV();
                },
                child: const Text("从 CSV 导入")),
            ThemeUtil.width(),
          ],
        ),
        ThemeUtil.lineH(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: TablePage(
                  loading: logic.loading.value,
                  tableData: TableData(
                    isIndex: true,
                    columns: logic.columns,
                    rows: logic.list.toList(),
                    theme: TableTheme(
                      headerColor: Colors.blueGrey.shade700,
                      headerTextColor: Colors.white,
                      rowColor: Colors.grey.shade200,
                      textColor: Colors.black,
                      alternateRowColor: Colors.grey.shade100,
                      border: Border.all(color: UiTheme.primary(), width: 1),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Obx(() {
          return PaginationPage(
            total: logic.total.value,
            changed: (size, page) {
              logic.find(size, page);
            },
          );
        })
      ],
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "岗位列表",
      icon: Icons.deblur,
      page: JobPage(),
    );
  }
}


class TablePage extends StatelessWidget {
  final bool loading;
  final TableData tableData;

  TablePage({required this.loading, required this.tableData});

  @override
  Widget build(BuildContext context) {
    return loading
        ? Center(child: CircularProgressIndicator())
        : DataTable(
      columnSpacing: 16,
      dataRowHeight: 56,
      headingRowHeight: 56,
      dividerThickness: 1,
      showBottomBorder: true,
      columns: tableData.columns.map((column) {
        return DataColumn(
          label: Text(
            column.title, // 修改这里，使用 column.title
            style: TextStyle(
              color: tableData.theme.headerTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      rows: tableData.rows.asMap().entries.map((entry) {
        int index = entry.key;
        Map<String, dynamic> row = entry.value;
        return DataRow(
          cells: tableData.columns.map((column) {
            return DataCell(
              Text(
                row[column.key]?.toString() ?? '', // 修改这里，使用 column.key
                style: TextStyle(
                  color: tableData.theme.textColor,
                ),
              ),
            );
          }).toList(),
          color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (index % 2 == 0) {
                return tableData.theme.rowColor;
              } else {
                return tableData.theme.alternateRowColor;
              }
            },
          ),
        );
      }).toList(),
      headingRowColor: MaterialStateProperty.all(tableData.theme.headerColor),
    );
  }
}

