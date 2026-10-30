import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/food_scanner/data/datasources/ai_remote_datasource.dart';
import 'package:health_app/features/food_scanner/data/models/food_analysis_model.dart';
import 'package:health_app/features/food_scanner/domain/utils/macro_calculator.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';

class SmartPortionState {
  final FoodAnalysisModel baseAnalysis;
  final double targetWeightGrams;
  final List<KeyIngredientItem> keyIngredients;
  final MacroCalculationResult computed;
  final String selectedMealType;
  final String customNote;
  final bool isSaving;
  final bool isReanalyzing;
  final bool saveSuccess;
  final String? errorMessage;

  const SmartPortionState({
    required this.baseAnalysis,
    required this.targetWeightGrams,
    required this.keyIngredients,
    required this.computed,
    required this.selectedMealType,
    this.customNote = '',
    this.isSaving = false,
    this.isReanalyzing = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  SmartPortionState copyWith({
    FoodAnalysisModel? baseAnalysis,
    double? targetWeightGrams,
    List<KeyIngredientItem>? keyIngredients,
    MacroCalculationResult? computed,
    String? selectedMealType,
    String? customNote,
    bool? isSaving,
    bool? isReanalyzing,
    bool? saveSuccess,
    String? errorMessage,
  }) {
    return SmartPortionState(
      baseAnalysis: baseAnalysis ?? this.baseAnalysis,
      targetWeightGrams: targetWeightGrams ?? this.targetWeightGrams,
      keyIngredients: keyIngredients ?? this.keyIngredients,
      computed: computed ?? this.computed,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      customNote: customNote ?? this.customNote,
      isSaving: isSaving ?? this.isSaving,
      isReanalyzing: isReanalyzing ?? this.isReanalyzing,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SmartPortionController extends StateNotifier<SmartPortionState> {
  final NutritionRemoteDataSource nutritionDataSource;
  final AiRemoteDataSource aiDataSource;
  final Ref ref;

  SmartPortionController({
    required FoodAnalysisModel baseAnalysis,
    required String initialMealType,
    required this.nutritionDataSource,
    required this.aiDataSource,
    required this.ref,
  }) : super(
          SmartPortionState(
            baseAnalysis: baseAnalysis,
            targetWeightGrams: baseAnalysis.portionWeightGrams,
            keyIngredients: List.of(baseAnalysis.keyIngredients),
            computed: MacroCalculator.calculateFromIngredients(
              ingredients: baseAnalysis.keyIngredients,
              baseWeightGrams: baseAnalysis.portionWeightGrams,
              baseSodiumMg: baseAnalysis.sodiumMg,
              baseSugarG: baseAnalysis.sugarG,
              baseFiberG: baseAnalysis.fiberG,
            ),
            selectedMealType: initialMealType,
          ),
        );

  /// ปรับน้ำหนักเป้าหมายโดยตรง (50g – 800g) และสเกลวัตถุดิบทั้งหมด
  void setTargetGrams(double grams) {
    final clamped = grams.clamp(50.0, 800.0);
    final ratio = state.targetWeightGrams > 0
        ? (clamped / state.targetWeightGrams)
        : 1.0;

    final updatedIngredients = state.keyIngredients
        .map((item) => item.copyWithWeight(item.weightGrams * ratio))
        .toList();

    _recalculateFromIngredients(clamped, updatedIngredients);
  }

  /// ปรับตามอัตราส่วนสัดส่วนจาน (0.5x, 1.0x, 1.5x, 2.0x)
  void setPortionRatio(double ratio) {
    final newGrams = (state.baseAnalysis.portionWeightGrams * ratio)
        .roundToDouble()
        .clamp(50.0, 800.0);

    final updatedIngredients = state.baseAnalysis.keyIngredients
        .map((item) => item.copyWithWeight(item.weightGrams * ratio))
        .toList();

    _recalculateFromIngredients(newGrams, updatedIngredients);
  }

  /// เพิ่มหรือลดน้ำหนักจานรวมทีละขั้น
  void stepGrams(double step) {
    final newGrams = (state.targetWeightGrams + step).clamp(50.0, 800.0);
    setTargetGrams(newGrams);
  }

  /// ปรับเพิ่ม/ลดกรัมของวัตถุดิบสำคัญรายตัว (เช่น ข้าวสวย -10g, เนื้อไก่ +10g)
  void stepIngredientGrams(int index, double step) {
    if (index < 0 || index >= state.keyIngredients.length) return;

    final updated = List<KeyIngredientItem>.from(state.keyIngredients);
    final current = updated[index];
    final newGrams = (current.weightGrams + step).clamp(0.0, 1000.0);

    updated[index] = current.copyWithWeight(newGrams);

    final newTotalWeight =
        updated.fold<double>(0.0, (acc, item) => acc + item.weightGrams);

    _recalculateFromIngredients(newTotalWeight, updated);
  }

  /// ตั้งค่าข้อความโน้ตเพิ่มเติมก่อนบันทึก
  void setCustomNote(String note) {
    state = state.copyWith(customNote: note);
  }

  /// เปลี่ยนประเภทมื้ออาหาร
  void setMealType(String mealType) {
    state = state.copyWith(selectedMealType: mealType);
  }

  void _recalculateFromIngredients(
    double totalGrams,
    List<KeyIngredientItem> ingredients,
  ) {
    final newComputed = MacroCalculator.calculateFromIngredients(
      ingredients: ingredients,
      baseWeightGrams: state.baseAnalysis.portionWeightGrams,
      baseSodiumMg: state.baseAnalysis.sodiumMg,
      baseSugarG: state.baseAnalysis.sugarG,
      baseFiberG: state.baseAnalysis.fiberG,
    );

    state = state.copyWith(
      targetWeightGrams: totalGrams,
      keyIngredients: ingredients,
      computed: newComputed,
    );
  }

  /// ส่งคำขอให้ AI Gemini วิเคราะห์ภาพใหม่ตามโน้ตที่เพิ่งพิมพ์
  Future<bool> reanalyzeWithNote(File? imageFile) async {
    if (imageFile == null || !imageFile.existsSync() || state.isReanalyzing) {
      return false;
    }

    state = state.copyWith(isReanalyzing: true, errorMessage: null);

    try {
      final updatedAnalysis = await aiDataSource.analyzeFoodImage(
        imageFile,
        userNotes: state.customNote.trim(),
      );

      final newIngredients = List<KeyIngredientItem>.from(
        updatedAnalysis.keyIngredients,
      );

      final newComputed = MacroCalculator.calculateFromIngredients(
        ingredients: newIngredients,
        baseWeightGrams: updatedAnalysis.portionWeightGrams,
        baseSodiumMg: updatedAnalysis.sodiumMg,
        baseSugarG: updatedAnalysis.sugarG,
        baseFiberG: updatedAnalysis.fiberG,
      );

      state = state.copyWith(
        baseAnalysis: updatedAnalysis,
        targetWeightGrams: updatedAnalysis.portionWeightGrams,
        keyIngredients: newIngredients,
        computed: newComputed,
        isReanalyzing: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isReanalyzing: false,
        errorMessage: 'Re-analysis failed: $e',
      );
      return false;
    }
  }

  /// บันทึกมื้ออาหารที่ปรับแต่งแล้วเข้าสู่ Database
  Future<bool> saveAdjustedMeal() async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final analysis = state.baseAnalysis;
    final comp = state.computed;

    final foodNameWithNotes = state.customNote.trim().isNotEmpty
        ? '${analysis.thaiName} (${state.customNote.trim()})'
        : (analysis.thaiName.isNotEmpty ? analysis.thaiName : analysis.foodName);

    try {
      final success = await nutritionDataSource.logMeal(
        userId: kDefaultUserId,
        mealType: state.selectedMealType,
        foodName: foodNameWithNotes,
        portionWeightGrams: comp.weightGrams,
        cookingMethod: analysis.cookingMethod,
        calories: comp.calories,
        proteinG: comp.proteinG,
        carbsG: comp.carbsG,
        fatG: comp.fatG,
        sodiumMg: comp.sodiumMg,
        sugarG: comp.sugarG,
        fiberG: comp.fiberG,
      );

      if (success) {
        ref.invalidate(dailySummaryProvider);
        state = state.copyWith(isSaving: false, saveSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save meal',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }
}

/// Provider Factory สำหรับ SmartPortionController แยกตาม instance ของอาหาร
final smartPortionControllerFamily = StateNotifierProvider.autoDispose
    .family<SmartPortionController, SmartPortionState,
        ({FoodAnalysisModel analysis, String mealType})>((ref, arg) {
  final dataSource = ref.watch(nutritionDataSourceProvider);
  final aiDataSource = ref.watch(aiRemoteDataSourceProvider);

  return SmartPortionController(
    baseAnalysis: arg.analysis,
    initialMealType: arg.mealType,
    nutritionDataSource: dataSource,
    aiDataSource: aiDataSource,
    ref: ref,
  );
});
