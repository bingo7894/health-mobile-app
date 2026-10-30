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

    return FoodAnalysisModel(
      foodName: json['foodName']?.toString() ??
          json['name']?.toString() ??
          'Unknown Food',
      thaiName: json['thaiName']?.toString() ??
          json['thai_name']?.toString() ??
          json['foodName']?.toString() ??
          'อาหาร',
      portionWeightGrams:
          (json['portionWeightGrams'] ?? json['portion_weight_grams'] as num?)
                  ?.toDouble() ??
              300.0,
      confidenceScore:
          (json['confidenceScore'] ?? json['confidence_score'] as num?)
                  ?.toDouble() ??
              0.90,
      calories: (json['calories'] ?? json['energy_kcal'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] ?? json['protein'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbsG'] ?? json['carbs'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fatG'] ?? json['fat'] as num?)?.toDouble() ?? 0.0,
      sodiumMg:
          (json['sodiumMg'] ?? json['sodium_mg'] as num?)?.toDouble() ?? 0.0,
      sugarG: (json['sugarG'] ?? json['sugar_g'] as num?)?.toDouble() ?? 0.0,
      fiberG: (json['fiberG'] ?? json['fiber_g'] as num?)?.toDouble() ?? 0.0,
      cookingMethod: json['cookingMethod']?.toString() ??
          json['cooking_method']?.toString() ??
          'STIR_FRIED',
      ingredients: ingredientsList,
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
      healthTips:
          'เมนูนี้ให้โปรตีนสูง เหมาะสำหรับการเสริมสร้างกล้ามเนื้อ หากต้องการคุมโซเดียม แนะนำลดการราดพริกน้ำปลาเพิ่ม',
      aiModelUsed: 'gemini-3.8-flash',
      isMock: true,
    );
  }
}

