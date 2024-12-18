import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_fancy_tree_view/flutter_fancy_tree_view.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../component/table/ex.dart';
import '../../../../theme/theme_util.dart';
import 'logic.dart';

class LectureFileView extends StatelessWidget {
  final String title;
  final LectureLogic logic;
  TreeController<DirectoryNode> treeController;

  LectureFileView({Key? key, required this.title, required this.logic})
      : treeController = TreeController<DirectoryNode>(
          roots: logic.directoryTree,
          childrenProvider: (DirectoryNode node) => node.children.toList(),
        ),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ... 省略部分代码 ...
        Expanded(
          child: Obx(() {
            if (logic.directoryTree.isEmpty) {
              return _buildEmptyState(context);
            } else {
              return _buildTreeView(context);
            }
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.grey.shade100),
      child: Center(
        child: Text(
          "点击讲义列表的管理按钮，进行文件管理",
          style: TextStyle(
              fontSize: 16.0,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  TreeView<DirectoryNode> _buildTreeView(BuildContext context) {
    // 如果需要自动展开所有父节点，可以在这里调用 treeController.expandAll() 或其他逻辑
    // treeController.expandAll();

    return TreeView<DirectoryNode>(
      treeController: treeController,
      nodeBuilder: (BuildContext context, TreeEntry<DirectoryNode> entry) {
        return _buildTreeNode(context, entry);
      },
    );
  }

  Widget _buildTreeNode(BuildContext context, TreeEntry<DirectoryNode> entry) {
    final DirectoryNode dirNode = entry.node;
    final bool isFileNode =
        dirNode.filePath != null && dirNode.filePath!.isNotEmpty;
    final bool isLeafNode = dirNode.children.isEmpty;
    final bool isExpanded =
        entry.isExpanded; // 使用entry.isExpanded代替原来的node.expanded

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (isFileNode && isLeafNode) {
          logic.updatePdfUrl(dirNode.filePath!);
        } else {
          treeController.toggleExpansion(entry.node); // 使用controller的方法来切换展开状态
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: (isFileNode && isLeafNode)
                  ? SizedBox(width: 16)
                  : Text(isExpanded ? '-' : '+',
                      style: TextStyle(fontSize: 14)),
            ),
            Expanded(child: Text(dirNode.name)),
            SizedBox(width: 16),
            _buildOperationButtons(context, dirNode), // 确保此方法已定义
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButtons(BuildContext context, DirectoryNode dirNode) {
    bool isFilePathEmpty =
        dirNode.filePath == null || dirNode.filePath!.isEmpty;
    bool isLeafNode = dirNode.children.isEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(
          Icons.add,
          "添加",
          () {
            // 如果需要添加子目录，请确保已经定义了 _addSubdirectory 方法
            // _addSubdirectory(context, dirNode);
          },
          color: Colors.blueAccent,
          isEnabled: isFilePathEmpty,
        ),
      ],
    );
  }

  Widget _buildIconButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed, {
    Color? color,
    bool isEnabled = true,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: isEnabled ? onPressed : null,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 16,
              color: isEnabled ? (color ?? Colors.black) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
