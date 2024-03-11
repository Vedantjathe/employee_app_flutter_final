import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../logger.dart';

Future<File> loadPdfFromNetwork(String url) async {
  final response = await http.get(Uri.parse(url));
  final bytes = response.bodyBytes;
  return _storeFile(url, bytes);
}

Future<File> _storeFile(String url, List<int> bytes) async {
  final filename = path.basename(url);
  final dir = await getApplicationDocumentsDirectory();
  final file = File('${dir.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);

  logger.i('$file');

  return file;
}

Future<String> createFolder() async {
  Directory dir;
  if (Platform.isAndroid) {
    Directory directory =
        Directory((await getExternalStorageDirectory())!.path);
    String newPath = "";
    List<String> paths = directory.path.split("/");
    for (int x = 1; x < paths.length; x++) {
      String folder = paths[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }
    newPath = "$newPath/EmployeeApp";
    dir = Directory(newPath);
  } else {
    dir = Directory((await getApplicationDocumentsDirectory()).path);
  }
  PermissionStatus status = await Permission.storage.status;
  var state = await Permission.manageExternalStorage.status;
  var state2 = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
    status = await Permission.storage.status;
  }
  if (!state2.isGranted) {
    await Permission.storage.request();
  }
  if (!state.isGranted) {
    await Permission.manageExternalStorage.request();
  }
  if (status.isGranted) {
    if ((await dir.exists())) {
      return dir.path;
    } else {
      var dirt = await dir.create();
      return dirt.path;
    }
  } else {
    return "";
  }
}

Future<bool> exportExcel(
    List? dataMap, String fileName, List<String>? header) async {
  try {
    List jsonData = dataMap ?? [];

    // Convert JSON data to Excel format.
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Add headers
    final border =
        Border(borderColorHex: '#000000', borderStyle: BorderStyle.Medium);
    CellStyle cellStyle = CellStyle(
      bold: true,
      textWrapping: TextWrapping.WrapText,
      // backgroundColorHex: '#4f81bd',
      topBorder: border,
      leftBorder: border,
      rightBorder: border,
      bottomBorder: border,
    );

    CellStyle headerCellStyle = CellStyle(
      bold: true,
      textWrapping: TextWrapping.WrapText,
      backgroundColorHex: '#4f81bd',
      fontColorHex: '#FFFFFF',
      topBorder: border,
      leftBorder: border,
      rightBorder: border,
      bottomBorder: border,
    );

    if (header == null) {
      List<String> headers = jsonData[0].keys.toList();
      for (int i = 0; i < headers.length; i++) {
        var cell =
            sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i));
        cell.value = TextCellValue(capitalizeWords(headers[i]));
        cell.cellStyle = headerCellStyle;
        sheet.setColumnWidth(i, headers[i].length * 1.2);
      }
    } else {
      for (int i = 0; i < header.length; i++) {
        var cell =
            sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i));
        cell.value = TextCellValue(capitalizeWords(header[i]));
        cell.cellStyle = headerCellStyle;
        sheet.setColumnWidth(i, header[i].length * 1.2);
      }
    }

    // Add data
    for (int i = 0; i < jsonData.length; i++) {
      List<dynamic> row = jsonData[i].values.map((e) => e.toString()).toList();
      for (int j = 0; j < row.length; j++) {
        var cell = sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: i + 1, columnIndex: j));
        cell.value = TextCellValue(row[j].toString());
        cell.cellStyle = cellStyle..isBold = false;
      }
    }

    // Save Excel file
    var fileBytes = excel.save();
    var directoryPath = await createFolder();
    final String excelPath = '$directoryPath/$fileName';
    File file = File('$directoryPath/$fileName');
    int i = 1;
    while (file.existsSync()) {
      file = File(
          '$directoryPath/${fileName.split('.').first}($i).${fileName.split('.').last}');
      i++;
    }

    file
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes ?? []);
    // final Directory? directory = await getExternalStorageDirectory();
    // excel.encode().then((onValue) {
    //   File(excelPath)
    //     ..createSync(recursive: true)
    //     ..writeAsBytesSync(onValue);
    // });

    logger.i('Excel file saved at: $excelPath');
    return true;
  } catch (e) {
    return false;
  }
}

Future<bool> exportIndividualExcel(
    List? dataMap, String fileName, List<String>? header) async {
  try {
    List jsonData = dataMap ?? [];

    // Convert JSON data to Excel format.
    Excel excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    // Add headers
    final border =
        Border(borderColorHex: '#000000', borderStyle: BorderStyle.Medium);
    CellStyle cellStyle = CellStyle(
      bold: true,
      textWrapping: TextWrapping.WrapText,
      // backgroundColorHex: '#4f81bd',
      topBorder: border,
      leftBorder: border,
      rightBorder: border,
      bottomBorder: border,
    );

    CellStyle headerCellStyle = CellStyle(
      bold: true,
      textWrapping: TextWrapping.WrapText,
      backgroundColorHex: '#4f81bd',
      fontColorHex: '#FFFFFF',
      topBorder: border,
      leftBorder: border,
      rightBorder: border,
      bottomBorder: border,
    );

    if (header == null) {
      List<String> headers = jsonData[0].keys.toList();
      for (int i = 0; i < headers.length; i++) {
        var cell =
            sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i));
        cell.value = TextCellValue(capitalizeWords(headers[i]));
        cell.cellStyle = headerCellStyle;
        sheet.setColumnWidth(i, headers[i].length * 1.2);
      }
    } else {
      for (int i = 0; i < header.length; i++) {
        var cell =
            sheet.cell(CellIndex.indexByColumnRow(rowIndex: 0, columnIndex: i));
        cell.value = TextCellValue(capitalizeWords(header[i]));
        cell.cellStyle = headerCellStyle;
        sheet.setColumnWidth(i, header[i].length * 1.2);
      }
    }

    // Add data
    for (int i = 0; i < jsonData.length; i++) {
      List<dynamic> row = jsonData[i].values.map((e) => e.toString()).toList();
      for (int j = 0; j < row.length; j++) {
        var cell = sheet
            .cell(CellIndex.indexByColumnRow(rowIndex: i + 1, columnIndex: j));
        cell.value = TextCellValue(row[j].toString());
        cell.cellStyle = cellStyle..isBold = false;
      }
    }

    // Save Excel file
    var fileBytes = excel.save();
    var directoryPath = await createFolder();
    final String excelPath = '$directoryPath/$fileName';
    File file = File('$directoryPath/$fileName');
    int i = 1;
    while (file.existsSync()) {
      file = File(
          '$directoryPath/${fileName.split('.').first}($i).${fileName.split('.').last}');
      i++;
    }

    file
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes ?? []);
    // final Directory? directory = await getExternalStorageDirectory();
    // excel.encode().then((onValue) {
    //   File(excelPath)
    //     ..createSync(recursive: true)
    //     ..writeAsBytesSync(onValue);
    // });

    logger.i('Excel file saved at: $excelPath');
    return true;
  } catch (e) {
    return false;
  }
}

String capitalizeWords(String input) {
  if (input.isEmpty) {
    return '';
  }
  List<String> words = input.split(' ');
  List<String> capitalizedWords =
      words.map((word) => word[0].toUpperCase() + word.substring(1)).toList();
  return capitalizedWords.join(' ');
}

Future<String> downloadFile(String uri, String fileName) async {
  var url = Uri.parse(uri);

  try {
    final response = await http.get(
      url,
    );

    if (response.contentLength == 0) {
      throw Exception('File did not download .\nTry again later.');
    }
    String tempPath = await createFolder();
    if (tempPath == "") {
      throw Exception(
          'Storage permission needed to download file . Go to setting and turn on permission storage.');
    } else {
      File file = File('$tempPath/$fileName');
      int i = 1;
      while (file.existsSync()) {
        file = File(
            '$tempPath/${fileName.split('.').first}($i).${fileName.split('.').last}');
        i++;
      }
      await file.writeAsBytes(response.bodyBytes);
      // OpenFile.open(file.path);
      return 'File download successfully in EmployeeApp';
    }
  } catch (e) {
    rethrow;
  }
}
