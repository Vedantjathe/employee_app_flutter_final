import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FileDownloadButton extends StatelessWidget {
  final String fileUrl;
  final String fileName;

  FileDownloadButton({required this.fileUrl, required this.fileName});

  Future<void> downloadFile() async {
    final response = await http.get(Uri.parse(fileUrl));

    if (response.statusCode == 200) {
      final Uint8List bytes = response.bodyBytes;
      final directory = await getExternalStorageDirectory();
      final String filePath = join(directory!.path, fileName);
      final File file = File(filePath);

      await file.writeAsBytes(bytes);
      // You can now use the file as needed (e.g., open with a PDF viewer or share it).
    } else {
      throw Exception('Failed to download file');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        downloadFile();
      },
      child: Text('Download $fileName'),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('File Download Example'),
        ),
        body: Center(
          child: FileDownloadButton(
            fileUrl:
                'https://example.com/your_file_url.pdf', // Replace with your actual file URL
            fileName: 'example.pdf', // Replace with your desired file name
          ),
        ),
      ),
    ),
  );
}
