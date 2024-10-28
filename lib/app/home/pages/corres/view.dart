import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/app/home/pages/job/logic.dart';
import 'package:admin_flutter/app/home/pages/major/logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';

class CorresPage extends StatelessWidget {
  final jobLogic = Get.put(JobLogic());
  final majorLogic = Get.put(MajorLogic());
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 添加外边距
            child: MajorTableView(title: "专业", logic: majorLogic),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 添加外边距
            child: JobTableView(title: "岗位", logic: jobLogic),
          ),
        ),
      ],
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "专业对应岗位",
      icon: Icons.deblur,
      page: CorresPage(),
    );
  }
}

class JobTableView extends StatelessWidget {
  final String title;
  final JobLogic logic;

  const JobTableView({super.key, required this.title, required this.logic});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            ThemeUtil.width(width: 50),
            SizedBox(
              width: 260,
              child: TextField(
                key: const Key('search_box'),
                decoration: const InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => logic.search(value),
              ),
            ),
            ThemeUtil.width(),
            ElevatedButton(
              onPressed: () => logic.search(""),
              child: const Text("搜索"),
            ),
            const Spacer(),
            FilledButton(
              onPressed: logic.add,
              child: const Text("新增"),
            ),
            FilledButton(
              onPressed: () => logic.batchDelete(logic.selectedRows),
              child: const Text("批量删除"),
            ),
            FilledButton(
              onPressed: logic.exportCurrentPageToCSV,
              child: const Text("导出当前页"),
            ),
            FilledButton(
              onPressed: logic.exportAllToCSV,
              child: const Text("导出全部"),
            ),
            FilledButton(
              onPressed: logic.importFromCSV,
              child: const Text("从 CSV 导入"),
            ),
            ThemeUtil.width(width: 30),
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Expanded(
          child: Obx(() => logic.loading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 1000,
              height: Get.height,
              child: SfDataGrid(
                source: JobDataSource(logic: logic),
                headerGridLinesVisibility: GridLinesVisibility.values[1],
                columnWidthMode: ColumnWidthMode.fill,
                headerRowHeight: 50,
                columns: [
                  GridColumn(
                    columnName: 'Select',
                    label: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                      ),
                      child: Center(
                        child: Checkbox(
                          value: logic.selectedRows.length == logic.list.length,
                          onChanged: (value) => logic.toggleSelectAll(),
                        ),
                      ),
                    ),
                  ),
                  ...logic.columns.map((column) => GridColumn(
                    columnName: column.key,
                    label: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                      ),
                      child: Center(
                        child: Text(
                          column.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          )),
        ),
        Obx(() {
          return PaginationPage(
            total: logic.total.value,
            changed: (size, page) => logic.find(size, page),
          );
        })
      ],
    );
  }
}

class JobDataSource extends DataGridSource {
  final JobLogic logic;
  List<DataGridRow> _rows = [];

  JobDataSource({required this.logic}) {
    _buildRows();
  }

  void _buildRows() {
    _rows = logic.list
        .map((item) => DataGridRow(
      cells: [
        DataGridCell(
            columnName: 'Select',
            value: logic.selectedRows.contains(item['id'])),
        ...logic.columns.map((column) => DataGridCell(
          columnName: column.key,
          value: item[column.key],
        )),
        DataGridCell(columnName: 'Actions', value: item),
      ],
    ))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isSelected = row.getCells().first.value as bool;
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.blueGrey[50] : Colors.white,
      cells: [
        Checkbox(
          value: isSelected,
          onChanged: (value) => logic.toggleSelect(rowIndex),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map(
              (cell) => Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              cell.value?.toString() ?? '',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MajorTableView extends StatelessWidget {
  final String title;
  final MajorLogic logic;

  const MajorTableView({super.key, required this.title, required this.logic});


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            ThemeUtil.width(width: 50),
            SizedBox(
              width: 260,
              child: TextField(
                key: const Key('search_box'),
                decoration: const InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) => logic.search(value),
              ),
            ),
            ThemeUtil.width(),
            ElevatedButton(
              onPressed: () => logic.search(""),
              child: const Text("搜索"),
            ),
            const Spacer(),
            FilledButton(
              onPressed: logic.add,
              child: const Text("新增"),
            ),
            FilledButton(
              onPressed: () => logic.batchDelete(logic.selectedRows),
              child: const Text("批量删除"),
            ),
            FilledButton(
              onPressed: logic.exportCurrentPageToCSV,
              child: const Text("导出当前页"),
            ),
            FilledButton(
              onPressed: logic.exportAllToCSV,
              child: const Text("导出全部"),
            ),
            FilledButton(
              onPressed: logic.importFromCSV,
              child: const Text("从 CSV 导入"),
            ),
            ThemeUtil.width(width: 30),
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Expanded(
          child: Obx(() => logic.loading.value
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: 800,
              height: Get.height,
              child: SfDataGrid(
                source: MajorDataSource(logic: logic),
                headerGridLinesVisibility: GridLinesVisibility.values[1],
                columnWidthMode: ColumnWidthMode.fill,
                headerRowHeight: 50,
                columns: [
                  GridColumn(
                    columnName: 'Select',
                    label: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                      ),
                      child: Center(
                        child: Checkbox(
                          value: logic.selectedRows.length == logic.list.length,
                          onChanged: (value) => logic.toggleSelectAll(),
                        ),
                      ),
                    ),
                  ),
                  ...logic.columns.map((column) => GridColumn(
                    columnName: column.key,
                    label: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                      ),
                      child: Center(
                        child: Text(
                          column.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  )),
                  GridColumn(
                    columnName: 'Actions',
                    label: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                      ),
                      child: Center(
                        child: Text(
                          '操作',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ),
        Obx(() {
          return PaginationPage(
            total: logic.total.value,
            changed: (size, page) => logic.find(size, page),
          );
        })
      ],
    );
  }
}

class MajorDataSource extends DataGridSource {
  final MajorLogic logic;
  List<DataGridRow> _rows = [];

  MajorDataSource({required this.logic}) {
    _buildRows();
  }

  void _buildRows() {
    _rows = logic.list
        .map((item) => DataGridRow(
      cells: [
        DataGridCell(
            columnName: 'Select',
            value: logic.selectedRows.contains(item['id'])),
        ...logic.columns.map((column) => DataGridCell(
          columnName: column.key,
          value: item[column.key],
        )),
        DataGridCell(columnName: 'Actions', value: item),
      ],
    ))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final isSelected = row.getCells().first.value as bool;
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: rowIndex.isEven ? Colors.blueGrey[50] : Colors.white,
      cells: [
        Checkbox(
          value: isSelected,
          onChanged: (value) => logic.toggleSelect(rowIndex),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map(
              (cell) => Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: Alignment.centerLeft,
            child: Text(
              cell.value?.toString() ?? '',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black54),
              onPressed: () => logic.modify(row.getCells().last.value, rowIndex),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.orange),
              onPressed: () => logic.delete(row.getCells().last.value, rowIndex),
            ),
          ],
        ),
      ],
    );
  }
}
