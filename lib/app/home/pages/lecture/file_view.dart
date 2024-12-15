import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_treeview/flutter_treeview.dart' as treeview;
import 'package:file_picker/file_picker.dart';
import '../../../../component/table/ex.dart';
import '../../../../theme/theme_util.dart';
import 'logic.dart';

class LectureFileView extends StatelessWidget {
  final String title;
  final LectureLogic logic;

  const LectureFileView({Key? key, required this.title, required this.logic})
      : super(key: key);

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
              return Center(child: Text("点击讲义列表的管理按钮，进行文件管理"));
            } else {
              return _buildTreeView(context);
            }
          }),
        ),
      ],
    );
  }

  treeview.TreeView _buildTreeView(BuildContext context) {
    final List<treeview.Node<DirectoryNode>> treeNodes = _buildTreeNodes(logic.directoryTree);
    final treeController = treeview.TreeViewController(
      children: treeNodes,
      selectedKey: logic.selectedKey.value,
    );

    // 手动展开所有父节点
    _expandAllParentNodes(treeController, treeNodes);

    return treeview.TreeView(
      controller: treeController,
      nodeBuilder: (BuildContext context, treeview.Node<dynamic> node) {
        return _buildTreeNode(context, node as treeview.Node<DirectoryNode>);
      },
      onExpansionChanged: (key, expanded) {
        _toggleExpansion(key, expanded);
      },
    );
  }

  void _expandAllParentNodes(treeview.TreeViewController controller, List<treeview.Node<DirectoryNode>> nodes) {
    for (final node in nodes) {
      if (node.children.isNotEmpty) {
        controller.expandToNode(node.key);
        _expandAllParentNodes(controller, node.children.cast<treeview.Node<DirectoryNode>>());
      }
    }
  }

  // 确保节点点击逻辑不会影响到按钮的行为
  Widget _buildTreeNode(BuildContext context, treeview.Node<DirectoryNode> node) {
    final DirectoryNode dirNode = node.data!;
    final bool isFileNode = dirNode.filePath != null && dirNode.filePath!.isNotEmpty;
    final bool isLeafNode = node.children.isEmpty;
    final bool isExpanded = node.expanded ?? false;

    return GestureDetector(
      onTap: () {
        if (isFileNode && isLeafNode) {
          // 如果是叶子节点并且文件路径不为空，则调用 logic.updatePdfUrl
          logic.updatePdfUrl(dirNode.filePath!);
        } else {
          // 否则展开/收起节点
          _toggleExpansion(node.key, !isExpanded);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: (isFileNode && isLeafNode)
                  ? SizedBox(width: 16) // 叶子文件节点不显示 +/-
                  : Text(
                isExpanded ? '-' : '+',
                style: TextStyle(fontSize: 14),
              ),
            ),
            Expanded(
              child: Text(dirNode.name),
            ),
            // 将按钮区域隔离开来
            SizedBox(width: 16), // 添加一些间距
            _buildOperationButtons(context, dirNode),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationButtons(BuildContext context, DirectoryNode dirNode) {
    bool isFilePathEmpty = dirNode.filePath == null || dirNode.filePath!.isEmpty;
    // 检查当前节点是否为叶子节点
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

  // 确保 _buildIconButton 正确处理禁用状态
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
          onTap: isEnabled ? onPressed : null, // 如果按钮禁用，则不绑定点击事件
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.transparent,
            ),
            child: Icon(icon, size: 16, color: isEnabled ? (color ?? Colors.black) : Colors.grey),
          ),
        ),
      ),
    );
  }

  void _toggleExpansion(String key, bool expanded) {
    if (expanded) {
      logic.expandedKeys.value.add(key);
    } else {
      logic.expandedKeys.value.remove(key);
    }
    logic.expandedKeys.refresh();
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

  List<treeview.Node<DirectoryNode>> _buildTreeNodes(List<DirectoryNode> nodes) {
    return nodes.map((node) {
      return treeview.Node<DirectoryNode>(
        key: node.id.toString(),
        label: node.name,
        children: _buildTreeNodes(node.children),
        data: node,
        expanded: logic.expandedKeys.value.contains(node.id.toString()),
      );
    }).toList();
  }

  void _addSubdirectory(BuildContext context, DirectoryNode parent) {
    String? newDirName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("添加目录"),
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

  void _updateDir(BuildContext context, DirectoryNode node) async {
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
}
