
import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/typed_data_patch.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../sidebar/logic.dart';

class BookManagerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book File Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FileManagerPage(),
    );
  }

  static SidebarTree newThis() {
    return SidebarTree(
      name: "讲义管理",
      icon: Icons.deblur,
      page: BookManagerPage(),
    );
  }
}

class FileManagerPage extends StatefulWidget {
  @override
  _FileManagerPageState createState() => _FileManagerPageState();
}

class _FileManagerPageState extends State<FileManagerPage> {
  File? _pdfFile;

  Future<void> _pickFileAndConvertToPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'docx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      if (file.path.endsWith('.jpg') || file.path.endsWith('.png')) {
        await _convertImageToPDF(file);
      } else if (file.path.endsWith('.docx')) {
        // 使用cloud API来将Word转为PDF
        // 假设我们已经实现了_convertWordToPDF的具体逻辑
        await _convertWordToPDF(file);
      }
    }
  }

  Future<void> _convertImageToPDF(File imageFile) async {
    final PdfDocument document = PdfDocument();
    final PdfPage page = document.pages.add();

    // 加载图像数据并将其转换为PDF
    final Uint8List imageData = (await imageFile.readAsBytes()) as Uint8List;
    final PdfBitmap image = PdfBitmap(imageData as List<int>);
    page.graphics.drawImage(image, Rect.fromLTWH(0, 0, page.size.width, page.size.height));

    // 保存PDF文件
    await _saveAndOpenPDF(document);
  }

  Future<void> _convertWordToPDF(File wordFile) async {
    // 实际应用中建议使用cloud API来转换Word为PDF
    // 假设使用Google Drive API或其他第三方服务实现word文件转换
    // 这里只是展示结构
  }

  Future<void> _saveAndOpenPDF(PdfDocument document) async {
    // 获取临时目录并保存文件
    final Directory directory = await getTemporaryDirectory();
    final String filePath = '${directory.path}/converted_document.pdf';
    File pdfFile = File(filePath);
    await pdfFile.writeAsBytes(await document.save());

    // 更新UI和打开PDF文件
    setState(() {
      _pdfFile = pdfFile;
    });
    document.dispose();
    await OpenFilex.open(_pdfFile!.path);
  }

  Widget _buildFilePreview() {
    return _pdfFile != null
        ? SfPdfViewer.file(_pdfFile!)
        : Center(child: Text('请选择文件上传并预览'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book File Manager'),
      ),
      body: Row(
        children: [
          // 左侧文件管理和上传部分
          Expanded(
            flex: 1,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _pickFileAndConvertToPDF,
                  child: Text('上传文件并转换为PDF'),
                ),
                // 展示文件的树状结构
                Expanded(
                  child: ListView(
                    children: [
                      ExpansionTile(
                        title: Text('Book 1'),
                        children: [
                          ListTile(
                            title: Text('Chapter 1'),
                            subtitle: Text('Page 1'),
                          ),
                          ListTile(
                            title: Text('Chapter 2'),
                            subtitle: Text('Page 3'),
                          ),
                        ],
                      ),
                      ListTile(
                        title: Text('Book 2'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 右侧预览部分
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey[200],
              child: _buildFilePreview(),
            ),
          ),
        ],
      ),
    );
  }
}