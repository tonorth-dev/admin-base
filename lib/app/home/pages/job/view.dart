import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'logic.dart';
import 'package:admin_flutter/theme/theme_util.dart';

// JobPage是一个无状态小部件，用于显示岗位列表页面
class JobPage extends StatelessWidget {
  // 初始化JobLogic实例并将其放入GetX状态管理中
  final logic = Get.put(JobLogic());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 操作行
        TableEx.actions(
          children: [
            // 添加一些水平间距
            ThemeUtil.width(width: 50),
            SizedBox(
              width: 260,
              child: TextField(
                // 为搜索框设置一个键，用于在测试或查找时识别
                key: Key('search_box'),
                decoration: InputDecoration(
                  // 搜索框的提示文本
                  hintText: '搜索',
                  // 搜索框的前缀图标
                  prefixIcon: Icon(Icons.search),
                  // 设置搜索框的边框样式为全框边框
                  border: OutlineInputBorder(),
                ),
                // 当用户在搜索框中按下回车键时调用logic.search方法并传递输入的值
                onSubmitted: (value) => logic.search(value),
              ),
            ),
            ThemeUtil.width(),
            ElevatedButton(
              // 当按钮被按下时调用logic.search方法并传递空字符串
              onPressed: () => logic.search(""),
              child: Text("搜索"),
            ),
            Spacer(),
            FilledButton(
              // 当按钮被按下时调用logic.add方法
                onPressed: logic.add,
                child: Text("新增")),
            FilledButton(
              // 当按钮被按下时调用logic.batchDelete方法并传递logic.selectedRows
                onPressed: () => logic.batchDelete(logic.selectedRows),
                child: Text("批量删除")),
            FilledButton(
              // 当按钮被按下时调用logic.exportCurrentPageToCSV方法
                onPressed: logic.exportCurrentPageToCSV,
                child: Text("导出当前页")),
            FilledButton(
              // 当按钮被按下时调用logic.exportAllToCSV方法
                onPressed: logic.exportAllToCSV,
                child: Text("导出全部")),
            FilledButton(
              // 当按钮被按下时调用logic.importFromCSV方法
                onPressed: logic.importFromCSV,
                child: Text("从CSV导入")),
            ThemeUtil.width(width: 100),
          ],
        ),
        // 添加一条水平线
        ThemeUtil.lineH(),
        ThemeUtil.height(),
        Expanded(
          child: Obx(() => logic.loading.value
              ? Center(child: CircularProgressIndicator())
              : SfDataGrid(
            // 设置SfDataGrid的数据源为JobDataSource，并传入logic实例
            source: JobDataSource(logic: logic),
            columns: [
              GridColumn(
                columnName: 'Select',
                label: GestureDetector(
                  // 设置行为为不透明，以防止不必要的点击穿透或其他问题
                  behavior: HitTestBehavior.opaque,
                  // 当点击该区域时调用logic.toggleSelectAll方法
                  onTap: () => logic.toggleSelectAll(),
                  child: Checkbox(
                    value: logic.selectedRows.length == logic.list.length,
                    onChanged: (value) => logic.toggleSelectAll(),
                  ),
                ),
              ),
              ...logic.columns.map((column) => GridColumn(
                columnName: column.key,
                label: Container(
                  // 设置容器的水平内边距
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  // 设置对齐方式为居中
                  alignment: Alignment.center,
                  // 设置容器的背景颜色为浅灰色，无悬停效果
                  color: Colors.grey.shade200,
                  child: Text(
                    column.title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800]),
                  ),
                ),
              )),
              GridColumn(
                columnName: 'Actions',
                label: Container(
                  color: Colors.grey.shade200,
                  child: Text('操作',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800])),
                ),
              ),
            ],
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

  static SidebarTree newThis() {
    return SidebarTree(
      name: "岗位列表",
      icon: Icons.deblur,
      page: JobPage(),
    );
  }
}

// JobDataSource是SfDataGrid的数据源类，用于提供表格数据
class JobDataSource extends DataGridSource {
  final JobLogic logic;
  List<DataGridRow> _rows = [];

  JobDataSource({required this.logic}) {
    // 调用_buildRows方法来初始化数据行
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
          value: item[
          column.key],
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
      cells: [
        GestureDetector(
          // 当点击该区域时调用logic.toggleSelect方法并传入行索引
          onTap: () => logic.toggleSelect(rowIndex),
          child: Checkbox(
            value: isSelected,
            onChanged: (value) => logic.toggleSelect(rowIndex),
          ),
        ),
        ...row.getCells().skip(1).take(row.getCells().length - 2).map(
              (cell) => Container(
            // 设置容器的垂直内边距
            padding: EdgeInsets.symmetric(vertical: 8),
            // 设置文本在容器内的对齐方式为左对齐
            alignment: Alignment.centerLeft,
            child: IgnorePointer(
              // 禁止文本被选中
              child: Text(cell.value?.toString()?? '',
                style: TextStyle(
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.black54),
              // 当按钮被按下时调用logic.modify方法并传入该行的数据和行索引
              onPressed: () => logic.modify(row.getCells().last.value, rowIndex),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.orange),
              // 当按钮被按下时调用logic.delete方法并传入该行的数据和行索引
              onPressed: () => logic.delete(row.getCells().last.value, rowIndex),
            ),
          ],
        ),
      ],
    );
  }
}