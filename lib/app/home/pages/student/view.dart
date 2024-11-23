import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'logic.dart';
import 'package:admin_flutter/app/home/pages/institution/logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';

class StudentPage extends StatelessWidget {
  final logic = Get.put(StudentLogic());
  final institutionLogic = Get.find<InstitutionLogic>();

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
              width: 1700,
              height: Get.height,
              child: SfDataGrid(
                source: StudentDataSource(logic: logic),
                headerGridLinesVisibility: GridLinesVisibility.values[1],
                columnWidthMode: ColumnWidthMode.fill,
                headerRowHeight: 50,
                columns: [
                  GridColumn(
                    columnName: 'Select',
                    label: Container(
                      child: Container(
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
                  ),
                  ...logic.columns.map((column) => GridColumn(
                    width: 150,
                    columnName: column.key,
                    label: Container(
                      child: Container(
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
                    ),
                  )),
                  GridColumn(
                    columnName: 'Actions',
                    label: Container(
                      child: Container(
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
                  ),
                ],
              ),
            ),
          )),
        ),
        Obx(() {
          return PaginationPage(
            uniqueId: 'student_pagination',
            total: logic.total.value,
            changed: (size, page) => logic.find(size, page),
          );
        })
      ],
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "考生列表",
      icon: Icons.deblur,
      page: StudentPage(),
    );
  }
}

class StudentDataSource extends DataGridSource {
  final StudentLogic logic;
  final InstitutionLogic institutionLogic = Get.find<InstitutionLogic>();
  List<DataGridRow> _rows = [];

  StudentDataSource({required this.logic}) {
    _buildRows();
  }

  void _buildRows() {
    _rows = logic.list.map<DataGridRow>((data) {
      return DataGridRow(
        cells: [
          DataGridCell<bool>(columnName: 'Select', value: logic.selectedRows.contains(data['id'])),
          ...logic.columns.map<DataGridCell>((column) {
            // 确保所有值都被转换为字符串
            return DataGridCell<String>(columnName: column.key, value: data[column.key]?.toString() ?? '');
          }),
          DataGridCell<String>(columnName: 'Actions', value: data['id'].toString()),
        ],
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _rows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        if (dataGridCell.columnName == 'Select') {
          return Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(8.0),
            child: Checkbox(
              value: dataGridCell.value,
              onChanged: (bool? value) {
                final rowIndex = _rows.indexOf(row);
                logic.toggleSelect(rowIndex);
                notifyListeners();
              },
            ),
          );
        } else if (dataGridCell.columnName == 'institution_name') {
          final currentValue = dataGridCell.value?.toString() ?? '';
          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: currentValue,
              items: [
                DropdownMenuItem<String>(
                  value: currentValue,
                  child: Text(currentValue),
                ),
                ...institutionLogic.list
                    .where((institution) => institution['name'].toString() != currentValue)
                    .take(5)
                    .map((institution) {
                  return DropdownMenuItem<String>(
                    value: institution['name'].toString(),
                    child: Text(institution['name'].toString()),
                  );
                }).toList(),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  final rowIndex = _rows.indexOf(row);
                  final institutionId = institutionLogic.list
                      .firstWhere((institution) => institution['name'] == newValue)['id'];
                  logic.list[rowIndex]['institution_name'] = newValue;
                  logic.list[rowIndex]['institution_id'] = institutionId;
                  _buildRows();
                  notifyListeners();
                  // 如果需要，这里可以添加一个API调用来更新后端数据
                  // logic.updateStudentInstitution(logic.list[rowIndex]['id'], institutionId);
                }
              },
            ),
          );
        } else if (dataGridCell.columnName == 'Actions') {
          return Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => logic.modify(dataGridCell.value, 1),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => logic.delete(dataGridCell.value, 1),
                ),
              ],
            ),
          );
        } else {
          return Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(dataGridCell.value.toString()),
          );
        }
      }).toList(),
    );
  }

  void updateDataSource() {
    _buildRows();
    notifyListeners();
  }
}