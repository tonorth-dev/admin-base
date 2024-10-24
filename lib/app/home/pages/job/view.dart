import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/theme/ui_theme.dart';
import 'logic.dart';

class JobPage extends StatelessWidget {
  JobPage({Key? key}) : super(key: key);

  final logic = Get.put(JobLogic());

  @override
  /// Builds the widget tree for the JobPage.
  ///
  /// This method returns a `Column` containing an actions row and two main sections:
  /// a horizontally and vertically scrollable `TablePage` and a `PaginationPage`.
  /// The actions row includes several `FilledButton` widgets for adding entries,
  /// exporting data to CSV (current page and all), and importing data from CSV.
  /// The table displays data using the `TableData` with specified styling.
  ///
  /// - [context]: The `BuildContext` in which the widget tree is built.
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

class TablePage extends StatefulWidget {
  final Key? key;
  final bool loading;
  final TableData tableData;

  const TablePage({this.key, required this.loading, required this.tableData}) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  int? _hoveredRowIndex; // 用于记录当前悬停的行索引

  @override
  Widget build(BuildContext context) {
    return widget.loading
        ? Center(child: CircularProgressIndicator())
        : DataTable(
      columnSpacing: 16,
      dataRowMinHeight: 56,
      dataRowMaxHeight: 56,
      headingRowHeight: 56,
      dividerThickness: 1,
      showBottomBorder: true,
      columns: widget.tableData.columns.map((column) {
        return DataColumn(
          label: Text(
            column.title,
            style: TextStyle(
              color: widget.tableData.theme.headerTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
      rows: List.generate(widget.tableData.rows.length, (index) {
        Map<String, dynamic> row = widget.tableData.rows[index];
        bool isHovered = _hoveredRowIndex == index;
        return DataRow(
          cells: widget.tableData.columns.map((column) {
            return DataCell(
              MouseRegion(
                onEnter: (_) {
                  setState(() {
                    _hoveredRowIndex = index;
                  });
                },
                onExit: (_) {
                  setState(() {
                    _hoveredRowIndex = null;
                  });
                },
                child: Container(
                  width: double.infinity, // 确保整行的宽度
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  color: isHovered
                      ? Colors.grey.shade300
                      : Colors.transparent, // 确保整行悬停高亮
                  child: SelectableText(
                    row[column.key]?.toString() ?? '',
                    style: TextStyle(
                      color: widget.tableData.theme.textColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (isHovered) {
                return Colors.grey.shade300; // 整行悬停高亮
              } else if (index % 2 == 0) {
                return widget.tableData.theme.rowColor;
              } else {
                return widget.tableData.theme.alternateRowColor;
              }
            },
          ),
        );
      }).toList(),
      headingRowColor:
      MaterialStateProperty.all(widget.tableData.theme.headerColor),
    );
  }
}








