import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/food_scanner/data/models/food_analysis_model.dart';
import 'package:health_app/features/food_scanner/domain/utils/macro_calculator.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';

class SmartPortionState {
  final FoodAnalysisModel baseAnalysis;
  final double targetWeightGrams;
  final MacroCalculationResult computed;
  final String selectedMealType;
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const SmartPortionState({
    required this.baseAnalysis,
    required this.targetWeightGrams,
    required this.computed,
    required this.selectedMealType,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  SmartPortionState copyWith({
    FoodAnalysisModel? baseAnalysis,
    double? targetWeightGrams,
    MacroCalculationResult? computed,
    String? selectedMealType,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
  }) {
    return SmartPortionState(
      baseAnalysis: baseAnalysis ?? this.baseAnalysis,
      targetWeightGrams: targetWeightGrams ?? this.targetWeightGrams,
      computed: computed ?? this.computed,
      selectedMealType: selectedMealType ?? this.selectedMealType,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class SmartPortionController extends StateNotifier<SmartPortionState> {
  final NutritionRemoteDataSource nutritionDataSource;
  final Ref ref;

  SmartPortionController({
    required FoodAnalysisModel baseAnalysis,
    required String initialMealType,
    required this.nutritionDataSource,
    required this.ref,
  }) : super(
          SmartPortionState(
            baseAnalysis: baseAnalysis,
            targetWeightGrams: baseAnalysis.portionWeightGrams,
            computed: MacroCalculator.calculate(
              baseWeightGrams: baseAnalysis.portionWeightGrams,
              baseCalories: baseAnalysis.calories,
              baseProteinG: baseAnalysis.proteinG,
              baseCarbsG: baseAnalysis.carbsG,
              baseFatG: baseAnalysis.fatG,
              baseSodiumMg: baseAnalysis.sodiumMg,
              baseSugarG: baseAnalysis.sugarG,
              baseFiberG: baseAnalysis.fiberG,
              targetWeightGrams: baseAnalysis.portionWeightGrams,
            ),
            selectedMealType: initialMealType,
          ),
        );

  /// ปรับน้ำหนักเป้าหมายโดยตรง (50g – 800g)
  void setTargetGrams(double grams) {
    final clamped = grams.clamp(50.0, 800.0);
    _recalculate(clamped);
  }

  /// ปรับตามอัตราส่วนสัดส่วนจาน (0.5x, 1.0x, 1.5x, 2.0x)
  void setPortionRatio(double ratio) {
    final newGrams = (state.baseAnalysis.portionWeightGrams * ratio)
        .roundToDouble()
        .clamp(50.0, 800.0);
    _recalculate(newGrams);
  }

  /// เพิ่มหรือลดน้ำหนักทีละขั้น (เช่น +10g, -10g)
  void stepGrams(double step) {
    final newGrams = (state.targetWeightGrams + step).clamp(50.0, 800.0);
    _recalculate(newGrams);
  }

  /// เปลี่ยนประเภทมื้ออาหาร
  void setMealType(String mealType) {
    state = state.copyWith(selectedMealType: mealType);
  }

  void _recalculate(double grams) {
    final newComputed = MacroCalculator.calculate(
      baseWeightGrams: state.baseAnalysis.portionWeightGrams,
      baseCalories: state.baseAnalysis.calories,
      baseProteinG: state.baseAnalysis.proteinG,
      baseCarbsG: state.baseAnalysis.carbsG,
      baseFatG: state.baseAnalysis.fatG,
      baseSodiumMg: state.baseAnalysis.sodiumMg,
      baseSugarG: state.baseAnalysis.sugarG,
      baseFiberG: state.baseAnalysis.fiberG,
      targetWeightGrams: grams,
    );

    state = state.copyWith(
      targetWeightGrams: grams,
      computed: newComputed,
    );
  }

  /// บันทึกมื้ออาหารที่ปรับแต่งแล้วเข้าสู่ Database
  Future<bool> saveAdjustedMeal() async {
    if (state.isSaving) return false;

    state = state.copyWith(isSaving: true, errorMessage: null);

    final analysis = state.baseAnalysis;
    final comp = state.computed;

    try {
      final success = await nutritionDataSource.logMeal(
        userId: kDefaultUserId,
        mealType: state.selectedMealType,
        foodName: analysis.thaiName.isNotEmpty
            ? analysis.thaiName
            : analysis.foodName,
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
  return SmartPortionController(
    baseAnalysis: arg.analysis,
    initialMealType: arg.mealType,
    nutritionDataSource: dataSource,
    ref: ref,
  );
});
