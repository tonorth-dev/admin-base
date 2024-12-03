import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/app/home/pages/corres/m_logic.dart';
import 'package:admin_flutter/app/home/pages/corres/j_logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import '../../../../component/widget.dart';

class CorresPage extends StatelessWidget {
  final mLogic = Get.put(MLogic());
  final jLogic = Get.put(JLogic());

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: MajorTableView(key: const Key("major_table"), title: "专业列表", logic: mLogic),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: JobTableView(key: const Key("job_table"), title: "岗位列表", logic: jLogic),
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
  final JLogic logic;

  const JobTableView({super.key, required this.title, required this.logic});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            SizedBox(width: 30),
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // 假设这里有一个按钮来切换是否允许选择
                  ElevatedButton(
                    onPressed: () => logic.isRowsSelectable.value ? logic.disableRowSelection() : logic.enableRowSelection(),
                    child: Text(logic.isRowsSelectable.value ? '禁用选择' : '启用选择'),
                  ),
                  SizedBox(width: 10),
                  SearchBoxWidget(
                    key: Key('keywords'),
                    hint: '岗位代码、岗位名称、单位序号、单位名称',
                    onTextChanged: (String value) {
                      logic.searchText.value = value;
                      logic.applyFilters();
                    },
                    searchText: logic.searchText,
                  ),
                  SizedBox(width: 10),
                  SearchButtonWidget(
                    key: Key('search'),
                    onPressed: () {
                      logic.selectedRows.clear();
                      logic.find(logic.size.value, logic.page.value);
                    },
                  ),
                  SizedBox(width: 8),
                  ResetButtonWidget(
                    key: Key('reset'),
                    onPressed: () {
                      logic.reset();
                      logic.find(logic.size.value, logic.page.value);
                    },
                  ),
                  ThemeUtil.width(width: 30),
                ],
              ),
            ),
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Expanded(
          child: Obx(() => logic.loading.value
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          )
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
                        child: Obx(() => Checkbox(
                          value: logic.isRowsSelectable.value && logic.selectedRows.length == logic.list.length,
                          onChanged: (value) {
                            if (logic.isRowsSelectable.value) {
                              logic.toggleSelectAll();
                            }
                          },
                          activeColor: Colors.teal,
                        )),
                      ),
                    ),
                  ),
                  ...logic.columns.map((column) => GridColumn(
                    width: column.width,
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
            uniqueId: 'corres_pagination',
            total: logic.total.value,
            changed: (size, page) => logic.find(size, page),
          );
        })
      ],
    );
  }
}

class JobDataSource extends DataGridSource {
  final JLogic logic;
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
      color: logic.isRowsSelectable.value
          ? (isSelected
          ? Colors.teal.withOpacity(0.6) // 选中颜色
          : (rowIndex.isEven ? Colors.teal.withOpacity(0.05) : Colors.white)) // 交替行颜色
          : Colors.grey.withOpacity(0.1), // 禁用选择时的浅色蒙层
      cells: [
        Obx(() => MouseRegion(
          cursor: logic.isRowsSelectable.value ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Checkbox(
              value: isSelected,
              onChanged: logic.isRowsSelectable.value
                  ? (value) => logic.toggleSelect(rowId) // 点击行时触发选择
                  : null,
              activeColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        )),
        ...row.getCells().skip(1).map((cell) {
          final columnName = cell.columnName;
          final value = cell.value.toString();
          return Obx(() => MouseRegion(
            cursor: logic.isRowsSelectable.value ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: logic.isRowsSelectable.value ? () => logic.toggleSelect(rowId) : null, // 点击行时触发选择
              behavior: HitTestBehavior.opaque, // 确保点击整个区域都能响应
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                width: double.infinity, // 确保单元格充满整个宽度
                child: Text(
                  value,
                  textAlign: TextAlign.center, // 文字居中
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ));
        }),
      ],
    );
  }
}

class MajorTableView extends StatelessWidget {
  final String title;
  final MLogic logic;

  const MajorTableView({super.key, required this.title, required this.logic});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableEx.actions(
          children: [
            SizedBox(width: 30),
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade700, Colors.red.shade300],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ThemeUtil.width(width: 20),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: FutureBuilder<void>(
                      future: logic.fetchMajors(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('加载失败: ${snapshot.error}');
                        } else {
                          return CascadingDropdownField(
                            key: logic.majorDropdownKey,
                            width: 110,
                            height: 34,
                            hint1: '专业类目一',
                            hint2: '专业类目二',
                            hint3: '专业名称',
                            level1Items: logic.level1Items,
                            level2Items: logic.level2Items,
                            level3Items: logic.level3Items,
                            selectedLevel1: logic.selectedLevel1,
                            selectedLevel2: logic.selectedLevel2,
                            selectedLevel3: logic.selectedLevel3,
                            onChanged: (dynamic level1, dynamic level2, dynamic level3) {
                              logic.selectedMajorId.value = level3.toString();
                            },
                          );
                        }
                      },
                    ),
                  ),
                  SearchBoxWidget(
                    key: Key('keywords'),
                    hint: '类目名称、专业名称',
                    onTextChanged: (String value) {
                      logic.searchText.value = value;
                    },
                    searchText: logic.searchText,
                  ),
                  SizedBox(width: 10),
                  SearchButtonWidget(
                    key: Key('search'),
                    onPressed: () {
                      logic.selectedRows.clear();
                      logic.find(logic.size.value, logic.page.value);
                    },
                  ),
                  SizedBox(width: 8),
                  ResetButtonWidget(
                    key: Key('reset'),
                    onPressed: () {
                      logic.reset();
                      logic.find(logic.size.value, logic.page.value);
                    },
                  ),
                  ThemeUtil.width(width: 30),
                ],
              ),
            ),
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
              width: 900,
              height: Get.height,
              child: SfDataGrid(
                source: MajorDataSource(logic: logic),
                headerGridLinesVisibility: GridLinesVisibility.values[1],
                columnWidthMode: ColumnWidthMode.fill,
                headerRowHeight: 50,
                columns: [
                  GridColumn(
                    width: 80,
                    columnName: 'Select',
                    label: Container(
                      decoration: BoxDecoration(
                        color: Color(0xfff8e6dd),
                      ),
                      child: Center(
                        child: Checkbox(
                          value: logic.selectedRows.isNotEmpty,
                          onChanged: (value) => logic.toggleSelectAll(),
                        ),
                      ),
                    ),
                  ),
                  ...logic.columns.map((column) => GridColumn(
                    width: column.width,
                    columnName: column.key,
                    label: Container(
                      decoration: BoxDecoration(
                        color: Color(0xfff8e6dd),
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
                        color: Color(0xfff8e6dd),
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
            uniqueId: 'major_pagination',
            total: logic.total.value,
            changed: (size, page) => logic.find(size, page),
          );
        })
      ],
    );
  }
}


class MajorDataSource extends DataGridSource {
  final MLogic logic;
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
    final item = row.getCells().last.value;
    print("deitem:$item");

    return DataGridRowAdapter(
      color: isSelected
          ? Colors.red.shade100 // 选中颜色
          : (rowIndex.isEven ? Color(0x06FF5733) : Colors.white), // 交替行颜色
      cells: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => logic.toggleSelect(item['id']),
              fillColor: MaterialStateProperty.resolveWith<Color>((states) {
                return states.contains(MaterialState.selected)
                    ? Color(0xFFD43030)
                    : Colors.white;
              }),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map((cell) {
          final columnName = cell.columnName;
          final value = cell.value.toString();
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => logic.toggleSelect(item['id']), // 点击行时触发选择
              behavior: HitTestBehavior.opaque, // 确保点击整个区域都能响应
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8.0),
                width: double.infinity, // 确保单元格充满整个宽度
                child: Text(
                  value,
                  textAlign: TextAlign.center, // 文字居中
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          );
        }),
        if (item['status'] != 4)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HoverTextButton(
                  text: "编辑",
                  onTap: () => logic.find(1, 2),
                ),
                SizedBox(width: 5),
                HoverTextButton(
                  text: "删除",
                  onTap: () => logic.find(1, 2),
                ),
              ],
            ),
          )
      ],
    );
  }

}





