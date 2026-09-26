import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'document_models.dart';

class DocumentApi {
  DocumentApi(this._dio);

  final Dio _dio;

  Future<List<RhDocument>> forOwner(String ownerId) async {
    final response = await _dio.get<List<dynamic>>('/api/documents/owner/$ownerId');
    return response.data!.map((e) => RhDocument.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Downloads the document and saves it under the app's documents directory.
  /// Returns the local file path.
  Future<String> download(RhDocument document) async {
    final response = await _dio.get<List<int>>(
      '/api/documents/${document.id}/download',
      options: Options(responseType: ResponseType.bytes),
    );
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${document.fileName}');
    await file.writeAsBytes(response.data!);
    return file.path;
  }
}
