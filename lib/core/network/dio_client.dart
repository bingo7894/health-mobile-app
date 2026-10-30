import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Auto-switch interceptor between 10.0.2.2 (Emulator) and localhost (Physical USB / Web)
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options.baseUrl = ApiConfig.baseUrl;
        return handler.next(options);
      },
      onError: (DioException err, handler) async {
        final currentUrl = err.requestOptions.baseUrl;
        final isAndroid = defaultTargetPlatform == TargetPlatform.android;

        // ถ้าต่อ 10.0.2.2 ไม่ติด (เช่น เป็นเครื่องจริงที่ต่อสาย USB) ลองสลับไป localhost:8080
        if (isAndroid &&
            (err.type == DioExceptionType.connectionTimeout ||
                err.type == DioExceptionType.connectionError)) {
          final fallbackUrl = currentUrl.contains('10.0.2.2')
              ? 'http://localhost:8080'
              : 'http://10.0.2.2:8080';

          if (ApiConfig.dynamicBaseUrl != fallbackUrl) {
            debugPrint(
              '[DIO] Retrying with fallback host: $fallbackUrl (due to: ${err.message})',
            );
            ApiConfig.dynamicBaseUrl = fallbackUrl;
            err.requestOptions.baseUrl = fallbackUrl;

            try {
              final response = await dio.fetch(err.requestOptions);
              return handler.resolve(response);
            } catch (_) {
              // ปล่อย error ต่อไปตามปกติหากทั้งสอง host เชื่อมต่อไม่ได้
            }
          }
        }
        return handler.next(err);
      },
    ),
  );

  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        logPrint: (obj) => debugPrint('[DIO] $obj'),
      ),
    );
  }

  return dio;
});
