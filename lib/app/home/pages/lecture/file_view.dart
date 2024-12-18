import 'dart:io';

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
        TableEx.actions(
          children: [
            SizedBox(width: 30), // 添加一些间距
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade300],
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
          ],
        ),
        ThemeUtil.lineH(),
        ThemeUtil.height(),
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
    treeController.expandAll();

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
              () => _addSubdirectory(context, dirNode),
          color: Colors.blueAccent,
          isEnabled: isFilePathEmpty,
        ),
        _buildIconButton(
          Icons.file_upload,
          "上传文件",
              () => _importFile(context, dirNode),
          color: Colors.blueAccent,
          isEnabled: isLeafNode, // 仅当是叶子节点时启用
        ),
        _buildIconButton(
          Icons.upload_file,
          "导入目录",
              () => _importDir(context, dirNode),
          color: Colors.blueAccent,
          isEnabled: isFilePathEmpty,
        ),
        _buildIconButton(
          Icons.edit,
          "编辑",
              () => _updateDir(context, dirNode),
          color: Colors.greenAccent,
          isEnabled: true, // 编辑按钮总是启用
        ),
        _buildIconButton(
          Icons.delete,
          "删除",
              () => _confirmDelete(context, dirNode),
          color: Colors.orangeAccent,
          isEnabled: true, // 删除按钮总是启用
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

  void _confirmDelete(BuildContext context, DirectoryNode node) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("确认删除"),
        content: Text("您确定要删除 '${node.name}' 吗？"),
        actions: [
          TextButton(
            child: Text("取消"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("删除", style: TextStyle(color: Colors.red)),
            onPressed: () {
              logic.deleteDirectory(node.id);
              logic.loadDirectoryTree(logic.selectedLectureId.value, true);
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  void _addSubdirectory(BuildContext context, DirectoryNode parent) {
    String? newDirName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("添加节点"),
        content: TextField(
          onChanged: (value) => newDirName = value,
          decoration: InputDecoration(hintText: "目录名称"),
        ),
        actions: [
          TextButton(
            child: Text("取消"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text("添加"),
            onPressed: () {
              if (newDirName != null && newDirName!.isNotEmpty) {
                logic.addNewDirectory(newDirName!, parent.id);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _importFile(BuildContext context, DirectoryNode node) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      logic.importFileToNode(file, node.id);
    }
  }

  void _importDir(BuildContext context, DirectoryNode node) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      File file = File(result.files.single.path!);
      logic.importFileToDir(
          file, int.parse(logic.selectedLectureId.value), node.id);
    }
  }

  void _updateDir(BuildContext context, DirectoryNode node) {
    TextEditingController controller = TextEditingController(text: node.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("修改节点名称"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: "节点名称"),
        ),
        actions: [
          TextButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
              controller.dispose(); // 释放控制器
            },
          ),
          TextButton(
            child: Text("更新"),
            onPressed: () {
              final newDirName = controller.text;
              if (newDirName.isNotEmpty) {
                logic.updateDirectory(newDirName, node.id);
                Navigator.of(context).pop();
                controller.dispose(); // 释放控制器
              }
            },
          ),
        ],
      ),
    );
  }
}
