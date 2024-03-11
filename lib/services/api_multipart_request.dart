import 'package:dio/dio.dart';
import 'package:erp/utils/StringConstants.dart';

import '../logger.dart';

class ApiMultipartRequest {
  Future<Response<Map<String, dynamic>?>> sendRequest(
    String path, {
    required Map<String, dynamic> filePathMap,
    required Map<String, String> fieldValueMap,
    bool isPatch = false,
  }) async {
    final dio = Dio();
    String url = StringConstants.BASE_URL + path;

    Map<String, dynamic> formDataMap = {};
    for (String key in filePathMap.keys) {
      if (filePathMap[key] == null) {
        continue;
      }
      String fileName = filePathMap[key].toString().split('/').last;
      MultipartFile multipartFile = await MultipartFile.fromFile(
        filePathMap[key]!,
        filename: fileName,
        // contentType: MediaType(
        //   fileName.split('.').last,
        //   "*",
        // ),
      );

      formDataMap[key] = multipartFile;
    }
    formDataMap.addAll(fieldValueMap);

    FormData formData = FormData.fromMap(formDataMap);

    Response<Map<String, dynamic>?> response;

    try {
      if (isPatch) {
        response = await dio.patch(
          url,
          data: formData,
          // options: Options(headers: headers),
          onSendProgress: (int sent, int total) {
            logger.i('Sent: $sent / $total total');
          },
        );
      } else {
        response = await dio.post(
          url,
          data: formData,
          // options: Options(headers: headers),
          onSendProgress: (int sent, int total) {
            logger.i('Sent: $sent / $total total');
          },
        );
      }
      logger.d(response.realUri);
      logger.w(response.data);
      // Map<String, dynamic> data = response.data!;
      Response<Map<String, dynamic>?> newResponse = response;
      //
      // if (data.containsKey('data') && !data.containsKey('access')) {
      //   newResponse.data = response.data!['data'];
      // }
      return newResponse;
    } catch (e) {
      logger.e('File upload Error', error: e);
      rethrow;
    }
  }
}
