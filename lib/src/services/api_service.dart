import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/analysis_result.dart';

class ApiService {
  static final String baseUrl = dotenv.env['STATGENIE_API_URL'] ??
      'https://statgenie-163827097277.asia-south1.run.app';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
  ));

  Future<AnalysisResult> uploadAndAnalyze(File file) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });
    final res = await _dio.post('/clean_and_analyze', data: form);
    return AnalysisResult.fromJson(res.data);
  }

  Future<List<int>> downloadReport(String reportId) async {
    final res = await _dio.get('/download_report',
        queryParameters: {'report_id': reportId},
        options: Options(responseType: ResponseType.bytes));
    return res.data;
  }

  Future<bool> health() async {
    try {
      final res = await _dio.get('/health');
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}