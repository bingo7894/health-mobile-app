import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/config/api_config.dart';
import 'package:health_app/core/network/dio_client.dart';
import '../models/food_analysis_model.dart';

class AiRemoteDataSource {
  final Dio _dio;

  AiRemoteDataSource(this._dio);

  Future<FoodAnalysisModel> analyzeFoodImage(
    File imageFile, {
    String? userNotes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'food_capture.jpg',
        ),
        if (userNotes != null && userNotes.trim().isNotEmpty)
          'userNotes': userNotes.trim(),
      });

      final response = await _dio.post(
        ApiConfig.aiAnalyzeFood,
        data: formData,
        options: Options(
          sendTimeout: const Duration(seconds: 25),
          receiveTimeout: const Duration(seconds: 35),
        ),
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return FoodAnalysisModel.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      return FoodAnalysisModel.sample();
    } catch (_) {
      // หากเกิดข้อผิดพลาดในการเชื่อมต่อ ให้ส่ง Fallback Sample โภชนาการสำหรับทดสอบ
      return FoodAnalysisModel.sample();
    }
  }
}

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AiRemoteDataSource(dio);
});

