class KeyIngredientItem {
  final String name;
  final double weightGrams;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const KeyIngredientItem({
    required this.name,
    required this.weightGrams,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory KeyIngredientItem.fromJson(Map<String, dynamic> json) {
    return KeyIngredientItem(
      name: json['name']?.toString() ?? 'วัตถุดิบ',
      weightGrams:
          (json['weightGrams'] ?? json['weight_g'] as num?)?.toDouble() ??
              100.0,
      calories: (json['calories'] as num?)?.toInt() ?? 100,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 5.0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 10.0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 2.0,
    );
  }

  KeyIngredientItem copyWithWeight(double newGrams) {
    final validNewGrams = newGrams.clamp(0.0, 1000.0);
    final ratio = weightGrams > 0 ? (validNewGrams / weightGrams) : 1.0;
    return KeyIngredientItem(
      name: name,
      weightGrams: validNewGrams,
      calories: (calories * ratio).round().clamp(0, 9999),
      proteinG: (proteinG * ratio).clamp(0.0, 999.0),
      carbsG: (carbsG * ratio).clamp(0.0, 999.0),
      fatG: (fatG * ratio).clamp(0.0, 999.0),
    );
  }
}

class FoodAnalysisModel {
  final String foodName;
  final String thaiName;
  final double portionWeightGrams;
  final double confidenceScore;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double sodiumMg;
  final double sugarG;
  final double fiberG;
  final String cookingMethod;
  final List<String> ingredients;
  final List<KeyIngredientItem> keyIngredients;
  final String healthTips;
  final String? aiModelUsed;
  final bool isMock;

  const FoodAnalysisModel({
    required this.foodName,
    required this.thaiName,
    required this.portionWeightGrams,
    required this.confidenceScore,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.sodiumMg,
    required this.sugarG,
    required this.fiberG,
    required this.cookingMethod,
    required this.ingredients,
    required this.keyIngredients,
    required this.healthTips,
    this.aiModelUsed,
    this.isMock = false,
  });

  factory FoodAnalysisModel.fromJson(Map<String, dynamic> json) {
    final rawIngredients = json['ingredients'] ?? json['ingredient_list'];
    final ingredientsList = <String>[];
    if (rawIngredients is List) {
      for (final item in rawIngredients) {
        if (item != null) ingredientsList.add(item.toString());
      }
    }

    final totalWeight = (json['portionWeightGrams'] ??
            json['portion_weight_grams'] as num?)
        ?.toDouble() ??
        350.0;
    final totalCals =
        (json['calories'] ?? json['energy_kcal'] as num?)?.toInt() ?? 500;
    final totalProtein =
        (json['proteinG'] ?? json['protein'] as num?)?.toDouble() ?? 20.0;
    final totalCarbs =
        (json['carbsG'] ?? json['carbs'] as num?)?.toDouble() ?? 50.0;
    final totalFat =
        (json['fatG'] ?? json['fat'] as num?)?.toDouble() ?? 15.0;

    // Parse or generate Key Ingredients
    final rawKeyIngredients =
        json['keyIngredients'] ?? json['key_ingredients'];
    final keyItems = <KeyIngredientItem>[];

    if (rawKeyIngredients is List && rawKeyIngredients.isNotEmpty) {
      for (final item in rawKeyIngredients) {
        if (item is Map<String, dynamic>) {
          keyItems.add(KeyIngredientItem.fromJson(item));
        }
      }
    }

    if (keyItems.isEmpty) {
      // Smart Fallback: แยกวัตถุดิบสำคัญ 2-3 รายการตามประเภทอาหาร
      final thai = json['thaiName']?.toString() ?? '';
      final hasEgg =
          thai.contains('ไข่') || ingredientsList.any((e) => e.contains('ไข่'));
      final hasNoodles = thai.contains('ก๋วยเตี๋ยว') ||
          thai.contains('เส้น') ||
          thai.contains('บะหมี่');

      final carbName = hasNoodles ? 'เส้นก๋วยเตี๋ยว' : 'ข้าวสวย';
      final carbWeight = (totalWeight * (hasEgg ? 0.50 : 0.55)).roundToDouble();
      final carbCals = (totalCals * 0.42).round();

      keyItems.add(KeyIngredientItem(
        name: carbName,
        weightGrams: carbWeight,
        calories: carbCals,
        proteinG: (totalProtein * 0.15),
        carbsG: (totalCarbs * 0.85),
        fatG: 1.0,
      ));

      final meatWeight = (totalWeight * (hasEgg ? 0.35 : 0.40)).roundToDouble();
      final meatCals = (totalCals * (hasEgg ? 0.38 : 0.50)).round();

      keyItems.add(KeyIngredientItem(
        name: 'เนื้อสัตว์ / กับข้าวหลัก',
        weightGrams: meatWeight,
        calories: meatCals,
        proteinG: (totalProtein * (hasEgg ? 0.65 : 0.80)),
        carbsG: (totalCarbs * 0.12),
        fatG: (totalFat * (hasEgg ? 0.55 : 0.85)),
      ));

      if (hasEgg) {
        keyItems.add(KeyIngredientItem(
          name: 'ไข่ดาว / ไข่ต้ม',
          weightGrams: 50.0,
          calories: (totalCals * 0.20).round(),
          proteinG: (totalProtein * 0.20),
          carbsG: 0.5,
          fatG: (totalFat * 0.40),
        ));
      }
    }

    return FoodAnalysisModel(
      foodName: json['foodName']?.toString() ??
          json['name']?.toString() ??
          'Unknown Food',
      thaiName: json['thaiName']?.toString() ??
          json['thai_name']?.toString() ??
          json['foodName']?.toString() ??
          'อาหาร',
      portionWeightGrams: totalWeight,
      confidenceScore:
          (json['confidenceScore'] ?? json['confidence_score'] as num?)
                  ?.toDouble() ??
              0.90,
      calories: totalCals,
      proteinG: totalProtein,
      carbsG: totalCarbs,
      fatG: totalFat,
      sodiumMg:
          (json['sodiumMg'] ?? json['sodium_mg'] as num?)?.toDouble() ?? 0.0,
      sugarG: (json['sugarG'] ?? json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (json['fiberG'] ?? json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      cookingMethod: json['cookingMethod']?.toString() ??
          json['cooking_method']?.toString() ??
          'STIR_FRIED',
      ingredients: ingredientsList,
      keyIngredients: keyItems,
      healthTips: json['healthTips']?.toString() ??
          json['health_tips']?.toString() ??
          '',
      aiModelUsed: json['aiModelUsed']?.toString(),
      isMock: json['isMock'] as bool? ?? false,
    );
  }

  factory FoodAnalysisModel.sample() {
    return const FoodAnalysisModel(
      foodName: 'Pad Krapao Gai with Fried Egg',
      thaiName: 'ข้าวกะเพราไก่ไข่ดาว',
      portionWeightGrams: 350.0,
      confidenceScore: 0.96,
      calories: 620,
      proteinG: 32.5,
      carbsG: 65.0,
      fatG: 24.0,
      sodiumMg: 890.0,
      sugarG: 3.5,
      fiberG: 2.1,
      cookingMethod: 'STIR_FRIED',
      ingredients: [
        'อกไก่สับ',
        'ใบกะเพรา',
        'ไข่ดาว',
        'พริกขี้หนู',
        'กระเทียม',
        'ข้าวหอมมะลิ'
      ],
      keyIngredients: [
        KeyIngredientItem(
          name: 'ข้าวสวย',
          weightGrams: 180.0,
          calories: 240,
          proteinG: 4.5,
          carbsG: 52.5,
          fatG: 0.5,
        ),
        KeyIngredientItem(
          name: 'เนื้ออกไก่ผัดกะเพรา',
          weightGrams: 120.0,
          calories: 260,
          proteinG: 21.5,
          carbsG: 11.9,
          fatG: 12.5,
        ),
        KeyIngredientItem(
          name: 'ไข่ดาว',
          weightGrams: 50.0,
          calories: 120,
          proteinG: 6.5,
          carbsG: 0.6,
          fatG: 11.0,
        ),
      ],
      healthTips:
          'เมนูนี้ให้โปรตีนสูง เหมาะสำหรับการเสริมสร้างกล้ามเนื้อ หากต้องการคุมโซเดียม แนะนำลดการราดพริกน้ำปลาเพิ่ม',
      aiModelUsed: 'gemini-3.8-flash',
      isMock: true,
    );
  }
}
