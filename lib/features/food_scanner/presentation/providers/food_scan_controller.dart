import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/core/utils/food_gatekeeper.dart';
import 'package:health_app/core/utils/image_compressor_helper.dart';
import 'package:health_app/features/food_scanner/data/datasources/ai_remote_datasource.dart';
import 'package:health_app/features/food_scanner/data/models/food_analysis_model.dart';

enum FoodScanStatus {
  idle,
  verifying,
  notFood,
  compressing,
  analyzing,
  success,
  error,
}

class FoodScanState {
  final FoodScanStatus status;
  final File? capturedFile;
  final FoodGatekeeperResult? gatekeeperResult;
  final CompressedImageResult? compressedResult;
  final FoodAnalysisModel? analysisResult;
  final String? errorMessage;

  const FoodScanState({
    this.status = FoodScanStatus.idle,
    this.capturedFile,
    this.gatekeeperResult,
    this.compressedResult,
    this.analysisResult,
    this.errorMessage,
  });

  FoodScanState copyWith({
    FoodScanStatus? status,
    File? capturedFile,
    FoodGatekeeperResult? gatekeeperResult,
    CompressedImageResult? compressedResult,
    FoodAnalysisModel? analysisResult,
    String? errorMessage,
  }) {
    return FoodScanState(
      status: status ?? this.status,
      capturedFile: capturedFile ?? this.capturedFile,
      gatekeeperResult: gatekeeperResult ?? this.gatekeeperResult,
      compressedResult: compressedResult ?? this.compressedResult,
      analysisResult: analysisResult ?? this.analysisResult,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class FoodScanController extends StateNotifier<FoodScanState> {
  final AiRemoteDataSource _aiDataSource;

  FoodScanController(this._aiDataSource) : super(const FoodScanState());

  Future<void> processImage(File sourceFile, {String? userNotes}) async {
    if (!mounted) return;

    // 1. Stage: Verifying with On-Device ML Kit (Layer 2)
    state = state.copyWith(
      status: FoodScanStatus.verifying,
      capturedFile: sourceFile,
    );

    final gatekeeper = await FoodGatekeeper.verifyFood(sourceFile.path);

    if (!mounted) return;

    if (!gatekeeper.isFood) {
      // ดักจับสิ่งที่ไม่ใช่อาหาร ประหยัดค่า AI 100%
      state = state.copyWith(
        status: FoodScanStatus.notFood,
        gatekeeperResult: gatekeeper,
      );
      return;
    }

    // 2. Stage: Image Compression (Layer 3)
    state = state.copyWith(
      status: FoodScanStatus.compressing,
      gatekeeperResult: gatekeeper,
    );

    final compressed = await ImageCompressorHelper.compress(sourceFile);

    if (!mounted) return;

    // 3. Stage: Analyzing with Gemini Flash via Gateway (Layer 4)
    state = state.copyWith(
      status: FoodScanStatus.analyzing,
      compressedResult: compressed,
    );

    try {
      final analysis = await _aiDataSource.analyzeFoodImage(
        compressed.file,
        userNotes: userNotes,
      );

      if (!mounted) return;
      state = state.copyWith(
        status: FoodScanStatus.success,
        analysisResult: analysis,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        status: FoodScanStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {
    if (mounted) {
      state = const FoodScanState();
    }
  }
}

final foodScanControllerProvider =
    StateNotifierProvider<FoodScanController, FoodScanState>((ref) {
  final aiDataSource = ref.watch(aiRemoteDataSourceProvider);
  return FoodScanController(aiDataSource);
});
