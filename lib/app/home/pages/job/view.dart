import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/theme/ui_theme.dart';
import 'logic.dart';

/// JobPage 是一个无状态小部件，用于显示岗位列表页面。
class JobPage extends StatelessWidget {
  JobPage({Key? key}) : super(key: key);

  /// 初始化 JobLogic 实例并将其放入 GetX 状态管理中。
  final logic = Get.put(JobLogic());

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 操作行
        TableEx.actions(
          children: [
            ThemeUtil.width(), // 添加一些水平间距
            const Text(
              "运行mock目录下的服务器体验",
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(), // 将按钮推到右侧
            FilledButton(
                onPressed: () {
                  logic.add(); // 调用逻辑层的 add 方法
                },
                child: const Text("新增")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () async {
                  await logic.exportCurrentPageToCSV(); // 导出当前页数据到 CSV
                },
                child: const Text("导出当前页")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () async {
                  await logic.exportAllToCSV(); // 导出全部数据到 CSV
                },
                child: const Text("导出全部")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () {
                  logic.importFromCSV(); // 从 CSV 导入数据
                },
                child: const Text("从 CSV 导入")),
            ThemeUtil.width(),
          ],
        ),
        ThemeUtil.lineH(), // 添加一条水平线
        ThemeUtil.height(),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal, // 水平滚动
            child: Obx(() { // 使用 Obx 监听逻辑层的状态变化
              return SingleChildScrollView(
                scrollDirection: Axis.vertical, // 垂直滚动
                child: TablePage(
                  loading: logic.loading.value, // 是否加载中
                  tableData: TableData(
                    isIndex: true, // 是否显示索引列
                    columns: logic.columns, // 表格列定义
                    rows: logic.list.toList(), // 表格行数据
                    theme: TableTheme(
                      headerColor: Colors.blueGrey.shade700, // 表头背景色
                      headerTextColor: Colors.white, // 表头文字颜色
                      rowColor: Colors.grey.shade200, // 偶数行背景色
                      textColor: Colors.black, // 文字颜色
                      alternateRowColor: Colors.grey.shade100, // 奇数行背景色
                      border: Border.all(color: UiTheme.primary(), width: 1), // 边框样式
                    ),
                  ),
                  logic: logic,
                ),
              );
            }),
          ),
        ),
        Obx(() { // 使用 Obx 监听逻辑层的状态变化
          return PaginationPage(
            total: logic.total.value, // 总条目数
            changed: (size, page) {
              logic.find(size, page); // 分页查询
            },
          );
        })
      ],
    );
  }

  /// 创建一个新的 SidebarTree 实例，用于导航栏。
  static SidebarTree newThis() {
    return SidebarTree(
      name: "岗位列表", // 侧边栏名称
      icon: Icons.deblur, // 侧边栏图标
      page: JobPage(), // 对应的页面
    );
  }
}

/// TablePage 是一个有状态的小部件，用于显示表格。
class TablePage extends StatefulWidget {
  final Key? key;
  final bool loading; // 是否加载中
  final TableData tableData; // 表格数据
  final JobLogic logic; // 新增逻辑层实例

  const TablePage({this.key, required this.loading, required this.tableData, required this.logic}) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

/// TablePage 的状态类。
class _TablePageState extends State<TablePage> {
  int? _hoveredRowIndex; // 记录当前悬停的行索引

  @override
  Widget build(BuildContext context) {
    return widget.loading
        ? Center(child: CircularProgressIndicator()) // 加载中显示进度指示器
        : DataTable(
      columnSpacing: 28, // 增加列间距
      dataRowMinHeight: 56, // 增加数据行最小高度
      dataRowMaxHeight: 56, // 增加数据行最大高度
      headingRowHeight: 64, // 增加表头行高度
      dividerThickness: 1, // 分隔线厚度
      showBottomBorder: true, // 显示底部边框
      columns: widget.tableData.columns.map((column) {
        return DataColumn(
          label: Text(
            column.title, // 列标题
            style: TextStyle(
              color: widget.tableData.theme.headerTextColor, // 表头文字颜色
              fontWeight: FontWeight.bold, // 加粗
            ),
          ),
        );
      }).toList(),
      rows: List.generate(widget.tableData.rows.length, (index) {
        Map<String, dynamic> row = widget.tableData.rows[index]; // 当前行数据
        bool isHovered = _hoveredRowIndex == index; // 当前行是否被悬停

        return DataRow(
          cells: widget.tableData.columns.map((column) {
            if (widget.tableData.columns.last.key == column.key) {
              // 在最后一列中添加删除和编辑按钮
              return DataCell(
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue), // 编辑按钮图标
                      onPressed: () {
                        widget.logic.modify(row, index); // 调用逻辑层的 edit 方法
                      },
                    ),
                    SizedBox(width: 8), // 添加一些间距
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red), // 删除按钮图标
                      onPressed: () {
                        widget.logic.delete(row, index); // 调用逻辑层的 delete 方法
                      },
                    ),
                  ],
                ),
              );
            } else {
              return DataCell(
                MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveredRowIndex = index; // 设置悬停行索引
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveredRowIndex = null; // 清除悬停行索引
                    });
                  },
                  child: Container(
                    width: double.infinity, // 确保整行的宽度
                    padding: const EdgeInsets.symmetric(vertical: 12), // 增加垂直内边距
                    color: isHovered
                        ? Colors.grey.shade300 // 悬停时高亮
                        : Colors.transparent, // 默认透明
                    child: SelectableText(
                      row[column.key]?.toString() ?? '', // 显示单元格内容
                      style: TextStyle(
                        color: widget.tableData.theme.textColor, // 文字颜色
                      ),
                    ),
                  ),
                ),
              );
            }
          }).toList(),
          color: MaterialStateProperty.resolveWith<Color?>(
                (Set<MaterialState> states) {
              if (isHovered) {
                return Colors.grey.shade300; // 悬停时高亮
              } else if (index % 2 == 0) {
                return widget.tableData.theme.rowColor; // 偶数行背景色
              } else {
                return widget.tableData.theme.alternateRowColor; // 奇数行背景色
              }
            },
          ),
        );
      }).toList(),
      headingRowColor:
      MaterialStateProperty.all(Colors.indigo.shade900), // 改进表头背景色
    );
  }
}
