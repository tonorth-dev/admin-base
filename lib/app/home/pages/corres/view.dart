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
            padding: const EdgeInsets.all(16.0),
            child: MajorTableView(key: const Key("major_table"), title: "专业", logic: majorLogic),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: JobTableView(key: const Key("job_table"), title: "岗位", logic: jobLogic),
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
                decoration: InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search, color: Colors.teal),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal, width: 2),
                  ),
                ),
                onSubmitted: (value) => logic.search(value),
              ),
            ),
            ThemeUtil.width(),
            ElevatedButton(
              onPressed: () => logic.search(""),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              child: const Text("搜索"),
            ),
            ThemeUtil.width(width: 30),
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Expanded(
          child: Obx(() => logic.loading.value
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                ))
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
                      gridLinesVisibility: GridLinesVisibility.both,
                      columns: [
                        GridColumn(
                          width: 80,
                          columnName: 'Select',
                          label: Container(
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                            ),
                            child: Center(
                              child: Checkbox(
                                value: logic.selectedRows.length == logic.list.length,
                                onChanged: (value) => logic.toggleSelectAll(),
                                activeColor: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        ...logic.columns.map((column) => GridColumn(
                          width: _getColumnWidth(column.key),
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
                                  color: Colors.indigo[800],
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

  double _getColumnWidth(String key) {
    switch (key) {
      case 'id':
        return 60;
      case 'name':
        return 100;
      case 'job_desc':
        return 200;
    // 添加其他列的case
      default:
        return 100;  // 默认宽度
    }
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
              ],
            ))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    final rowId = row.getCells()[1].value; // 假设 ID 在第二列
    final isSelected = logic.selectedRows.contains(rowId);
    final rowIndex = _rows.indexOf(row);

    return DataGridRowAdapter(
      color: isSelected ? Colors.teal[100] : (rowIndex.isEven ? Colors.teal[50] : Colors.white),
      cells: row.getCells().map((cell) {
        if (cell.columnName == 'Select') {
          return Container(
            alignment: Alignment.center,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleRowSelection(rowId),
              activeColor: Colors.teal,
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => _toggleRowSelection(rowId),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              alignment: cell.columnName == 'id' ? Alignment.center : Alignment.centerLeft,
              child: Text(
                cell.value?.toString() ?? '',
                style: TextStyle(
                  color: Colors.teal[800],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  void _toggleRowSelection(dynamic rowId) {
    logic.toggleSelect(rowId);
    notifyListeners();
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
              onPressed: logic.saveSelectionLocally, // 新增按钮用于保存关系
              child: const Text("保存关系"),
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
            child: SizedBox(
              width: 800,
              height: Get.height,
              child: SfDataGrid(
                source: MajorDataSource(logic: logic),
                headerGridLinesVisibility: GridLinesVisibility.values[1],
                columnWidthMode: ColumnWidthMode.fill,
                headerRowHeight: 50,
                columns: [
                  GridColumn(
                    width: 0,
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
                    width: _getColumnWidth(column.key),
                    columnName: column.key,
                    label: Container(
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
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

  double _getColumnWidth(String key) {
    switch (key) {
      case 'id':
        return 60;
      case 'job_name':
        return 150;
      case 'job_desc':
        return 100;
    // 添加其他列的case
      default:
        return 100;  // 默认宽度
    }
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
    final rowIndex = _rows.indexOf(row);
    final isSelected = logic.selectedRowIndex.value == rowIndex;

    return DataGridRowAdapter(
      color: isSelected ? Colors.blue[100] : (rowIndex.isEven ? Colors.blueGrey[50] : Colors.white),
      cells: [
        Checkbox(
          value: logic.selectedRows.contains(row.getCells()[1].value),
          onChanged: (value) => logic.toggleSelect(rowIndex),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map(
              (cell) => Container(
            padding: EdgeInsets.symmetric(vertical: 8),
            alignment: cell.columnName == 'id' ? Alignment.center : Alignment.centerLeft,
            child: Text(
              cell.value?.toString() ?? '',
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        Obx(() {
          final isRowSelected = logic.selectedRowIndex.value == rowIndex;
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                isRowSelected ? '确认关联' : '关联岗位',
                style: TextStyle(
                  color: isRowSelected ? Colors.deepOrange : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  isRowSelected ? Icons.check : Icons.double_arrow,
                  color: isRowSelected ? Colors.deepOrange : Colors.blueGrey,
                ),
                onPressed: () {
                  if (isRowSelected) {
                    logic.confirmAssociation(row.getCells().last.value);
                  } else {
                    logic.selectRow(rowIndex);
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          );
        }),
      ],
    );
  }
}