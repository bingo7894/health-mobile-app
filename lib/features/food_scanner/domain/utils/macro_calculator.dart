import 'package:health_app/features/food_scanner/data/models/food_analysis_model.dart';

/// ผลลัพธ์การคำนวณสารอาหารและพลังงานตามสัดส่วนกรัม
class MacroCalculationResult {
  final double weightGrams;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double sodiumMg;
  final double sugarG;
  final double fiberG;
  final double ratio;

  const MacroCalculationResult({
    required this.weightGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.sodiumMg,
    required this.sugarG,
    required this.fiberG,
    required this.ratio,
  });
}

/// ยูทิลิตี้คำนวณสารอาหารตามสัดส่วนน้ำหนัก (Client-Side Real-Time Math)
/// ทำงานแบบ Pure Dart ทำงานรวดเร็วระดับ Microseconds ไร้เน็ต 100%
class MacroCalculator {
  const MacroCalculator._();

  static MacroCalculationResult calculate({
    required double baseWeightGrams,
    required int baseCalories,
    required double baseProteinG,
    required double baseCarbsG,
    required double baseFatG,
    required double baseSodiumMg,
    required double baseSugarG,
    required double baseFiberG,
    required double targetWeightGrams,
  }) {
    final validBaseWeight = baseWeightGrams > 0 ? baseWeightGrams : 300.0;
    final validTargetWeight = targetWeightGrams.clamp(10.0, 2000.0);
    final ratio = validTargetWeight / validBaseWeight;

    final scaledCalories = (baseCalories * ratio).round().clamp(5, 9999);
    final scaledProtein = (baseProteinG * ratio).clamp(0.0, 999.0);
    final scaledCarbs = (baseCarbsG * ratio).clamp(0.0, 999.0);
    final scaledFat = (baseFatG * ratio).clamp(0.0, 999.0);
    final scaledSodium = (baseSodiumMg * ratio).clamp(0.0, 9999.0);
    final scaledSugar = (baseSugarG * ratio).clamp(0.0, 999.0);
    final scaledFiber = (baseFiberG * ratio).clamp(0.0, 999.0);

    return MacroCalculationResult(
      weightGrams: validTargetWeight,
      calories: scaledCalories,
      proteinG: scaledProtein,
      carbsG: scaledCarbs,
      fatG: scaledFat,
      sodiumMg: scaledSodium,
      sugarG: scaledSugar,
      fiberG: scaledFiber,
      ratio: ratio,
    );
  }

  /// คำนวณผลรวมน้ำหนัก สารอาหาร และแคลอรีจากรายการวัตถุดิบสำคัญ (Key Ingredients)
  static MacroCalculationResult calculateFromIngredients({
    required List<KeyIngredientItem> ingredients,
    required double baseWeightGrams,
    required double baseSodiumMg,
    required double baseSugarG,
    required double baseFiberG,
  }) {
    if (ingredients.isEmpty) {
      return calculate(
        baseWeightGrams: baseWeightGrams,
        baseCalories: 500,
        baseProteinG: 20.0,
        baseCarbsG: 50.0,
        baseFatG: 15.0,
        baseSodiumMg: baseSodiumMg,
        baseSugarG: baseSugarG,
        baseFiberG: baseFiberG,
        targetWeightGrams: baseWeightGrams,
      );
    }

    double totalWeight = 0.0;
    int totalCals = 0;
    double totalP = 0.0;
    double totalC = 0.0;
    double totalF = 0.0;

    for (final item in ingredients) {
      totalWeight += item.weightGrams;
      totalCals += item.calories;
      totalP += item.proteinG;
      totalC += item.carbsG;
      totalF += item.fatG;
    }

    final ratio = baseWeightGrams > 0 ? (totalWeight / baseWeightGrams) : 1.0;
    final scaledSodium = (baseSodiumMg * ratio).clamp(0.0, 9999.0);
    final scaledSugar = (baseSugarG * ratio).clamp(0.0, 999.0);
    final scaledFiber = (baseFiberG * ratio).clamp(0.0, 999.0);

    return MacroCalculationResult(
      weightGrams: totalWeight.clamp(10.0, 2000.0),
      calories: totalCals.clamp(5, 9999),
      proteinG: totalP.clamp(0.0, 999.0),
      carbsG: totalC.clamp(0.0, 999.0),
      fatG: totalF.clamp(0.0, 999.0),
      sodiumMg: scaledSodium,
      sugarG: scaledSugar,
      fiberG: scaledFiber,
      ratio: ratio,
    );
  }
}
