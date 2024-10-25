import 'package:admin_flutter/app/home/sidebar/logic.dart';
import 'package:admin_flutter/component/pagination/view.dart';
import 'package:admin_flutter/component/table/ex.dart';
import 'package:admin_flutter/component/table/table_data.dart';
import 'package:admin_flutter/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:admin_flutter/theme/ui_theme.dart';
import 'logic.dart';

/// MajorPage 是一个无状态小部件，用于显示岗位列表页面。
class MajorPage extends StatelessWidget {
  MajorPage({Key? key}) : super(key: key);

  /// 初始化 MajorLogic 实例并将其放入 GetX 状态管理中。
  final logic = Get.put(MajorLogic());
  final List<int> selectedRows = []; // 定义 selectedRows 变量

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 操作行
        TableEx.actions(
          children: [
            ThemeUtil.width(width: 50), // 添加一些水平间距
            // Add search box and search button here
            SizedBox(
              width: 260,
              child: TextField(
                key: const Key('search_box'),
                decoration: const InputDecoration(
                  hintText: '搜索',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(), // 设置全框边框
                ),
                onSubmitted: (value) {
                  logic.search(value); // 调用逻辑层的 search 方法
                },
              ),
            ),
            ThemeUtil.width(), // 添加一些水平间距
            ElevatedButton(
              style: ButtonStyle(
                minimumSize: WidgetStateProperty.all(const Size(100, 80)),
                // 设置最小尺寸
                fixedSize: WidgetStateProperty.all(const Size(100, 80)),
                // 设置固定尺寸
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // 设置圆角
                  ),
                ),
              ),
              onPressed: () {
                logic.search(""); // 调用逻辑层的 search 方法并传递当前搜索值
              },
              child: const Text("搜索"),
            ),
            ThemeUtil.width(),
            const Spacer(), // 将按钮推到右侧
            FilledButton(
                onPressed: () {
                  logic.add(); // 调用逻辑层的 add 方法
                },
                child: const Text("新增")),
            ThemeUtil.width(),
            FilledButton(
                onPressed: () {
                  logic.batchDelete(selectedRows); // 调用逻辑层的批量删除方法
                },
                child: const Text("批量删除")),
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
            child: Obx(() {
              // 使用 Obx 监听逻辑层的状态变化
              return SingleChildScrollView(
                scrollDirection: Axis.vertical, // 垂直滚动
                child: Container(
                  width: 1700, // 设置表格宽度
                  // 边框样式
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey[300] ?? Colors.white,
                      width: 1,
                    ),
                  ),
                  child: TablePage(
                    loading: logic.loading.value, // 是否加载中
                    tableData: TableData(
                      isIndex: true, // 是否显示索引列
                      columns: logic.columns, // 表格列定义
                      rows: logic.list.toList(), // 表格行数据
                      theme: TableTheme(
                        headerColor: Colors.grey[50] ?? Colors.white,
                        // Header background color
                        headerTextColor: Colors.grey[800] ?? Colors.white,
                        // Header text color
                        rowColor: Colors.white,
                        // Even row background
                        alternateRowColor: Colors.blue[50] ?? Colors.white,
                        // Odd row background
                        textColor: Colors.grey[900] ?? Colors.white,
                        // Cell text color
                        border: Border.all(
                            color: Colors.grey[300] ?? Colors.white,
                            width: 1), // Table border
                      ),
                    ),
                    logic: logic,
                  ),
                ),
              );
            }),
          ),
        ),
        Obx(() {
          // 使用 Obx 监听逻辑层的状态变化
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
      name: "专业列表", // 侧边栏名称
      icon: Icons.deblur, // 侧边栏图标
      page: MajorPage(), // 对应的页面
    );
  }
}

/// TablePage 是一个有状态的小部件，用于显示表格。
class TablePage extends StatefulWidget {
  final Key? key;
  final bool loading; // 是否加载中
  final TableData tableData; // 表格数据
  final MajorLogic logic; // 新增逻辑层实例

  const TablePage({
    this.key,
    required this.loading,
    required this.tableData,
    required this.logic,
  }) : super(key: key);

  @override
  _TablePageState createState() => _TablePageState();
}

class _TablePageState extends State<TablePage> {
  int? _hoveredRowIndex; // 记录当前悬停的行索引
  List<int> selectedRows = []; // 记录选中的行索引

  void toggleSelectAll() {
    if (selectedRows.length == widget.tableData.rows.length) {
      setState(() {
        selectedRows.clear();
      });
    } else {
      setState(() {
        selectedRows =
            List.generate(widget.tableData.rows.length, (index) => index);
      });
    }
  }

  void toggleSelect(int index) {
    if (selectedRows.contains(index)) {
      setState(() {
        selectedRows.remove(index);
      });
    } else {
      setState(() {
        selectedRows.add(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.loading
        ? Center(child: CircularProgressIndicator()) // 加载中显示进度指示器
        : DataTable(
      columnSpacing: 28,
      // 增加列间距
      dataRowMinHeight: 56,
      // 增加数据行最小高度
      dataRowMaxHeight: 56,
      // 增加数据行最大高度
      headingRowHeight: 64,
      // 增加表头行高度
      dividerThickness: 1,
      // 分隔线厚度
      showBottomBorder: true,
      // 显示底部边框
      columns: [
        DataColumn(
          label: Checkbox(
            value: selectedRows.length == widget.tableData.rows.length,
            onChanged: (bool? value) {
              toggleSelectAll();
            },
          ),
        ),
        ...widget.tableData.columns.map((column) {
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
      ],
      rows: List.generate(widget.tableData.rows.length, (index) {
        Map<String, dynamic> row = widget.tableData.rows[index]; // 当前行数据
        bool isHovered = _hoveredRowIndex == index; // 当前行是否被悬停
        bool isSelected = selectedRows.contains(index); // 当前行是否被选中

        return DataRow(
          cells: [
            DataCell(
              Checkbox(
                value: isSelected,
                onChanged: (bool? value) {
                  toggleSelect(index);
                },
              ),
            ),
            ...widget.tableData.columns.map((column) {
              if (widget.tableData.columns.last.key == column.key) {
                // 在最后一列中添加删除和编辑按钮
                return DataCell(
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit,
                            color: Colors.black54), // 编辑按钮图标
                        onPressed: () {
                          widget.logic
                              .modify(row, index); // 调用逻辑层的 edit 方法
                        },
                      ),
                      SizedBox(width: 8), // 添加一些间距
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.orange), // 删除按钮图标
                        onPressed: () {
                          widget.logic
                              .delete(row, index); // 调用逻辑层的 delete 方法
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
                      width: double.infinity,
                      // 确保整行的宽度
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      // 增加垂直内边距
                      color: isHovered
                          ? Colors.grey.shade200 // 悬停时高亮
                          : Colors.transparent,
                      // 默认透明
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
          ],
          color: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              if (isHovered) {
                return Colors.grey.shade200; // 悬停时高亮
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
      WidgetStateProperty.all(Colors.grey.shade200), // 改进表头背景色
    );
  }
}
