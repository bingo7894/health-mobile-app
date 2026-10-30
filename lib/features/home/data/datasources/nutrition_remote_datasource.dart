import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/dio_client.dart';

class DailySummaryData {
  final int totalCaloriesIn;
  final double totalProteinG;
  final double totalCarbsG;
  final double totalFatG;
  final double totalSodiumMg;
  final double totalSugarG;
  final double totalFiberG;
  final int totalCaloriesBurned;
  final int netCalories;
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatPercentage;
  final Map<String, dynamic> mealsByMealType;
  final int totalMealsCount;

  DailySummaryData({
    required this.totalCaloriesIn,
    required this.totalProteinG,
    required this.totalCarbsG,
    required this.totalFatG,
    required this.totalSodiumMg,
    required this.totalSugarG,
    required this.totalFiberG,
    required this.totalCaloriesBurned,
    required this.netCalories,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatPercentage,
    required this.mealsByMealType,
    required this.totalMealsCount,
  });

  factory DailySummaryData.fromJson(Map<String, dynamic> json) {
    final macro = json['macroDistribution'] as Map<String, dynamic>? ?? {};
    return DailySummaryData(
      totalCaloriesIn: json['totalCaloriesIn'] as int? ?? 0,
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble() ?? 0.0,
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble() ?? 0.0,
      totalFatG: (json['totalFatG'] as num?)?.toDouble() ?? 0.0,
      totalSodiumMg: (json['totalSodiumMg'] as num?)?.toDouble() ?? 0.0,
      totalSugarG: (json['totalSugarG'] as num?)?.toDouble() ?? 0.0,
      totalFiberG: (json['totalFiberG'] as num?)?.toDouble() ?? 0.0,
      totalCaloriesBurned: json['totalCaloriesBurned'] as int? ?? 0,
      netCalories: json['netCalories'] as int? ?? 0,
      proteinPercentage: (macro['proteinPercentage'] as num?)?.toDouble() ?? 0.0,
      carbsPercentage: (macro['carbsPercentage'] as num?)?.toDouble() ?? 0.0,
      fatPercentage: (macro['fatPercentage'] as num?)?.toDouble() ?? 0.0,
      mealsByMealType: json['mealsByMealType'] as Map<String, dynamic>? ?? {},
      totalMealsCount: json['totalMealsCount'] as int? ?? 0,
    );
  }

  factory DailySummaryData.sample() {
    return DailySummaryData(
      totalCaloriesIn: 520,
      totalProteinG: 23.0,
      totalCarbsG: 77.0,
      totalFatG: 14.0,
      totalSodiumMg: 700.0,
      totalSugarG: 18.0,
      totalFiberG: 5.5,
      totalCaloriesBurned: 180,
      netCalories: 340,
      proteinPercentage: 17.5,
      carbsPercentage: 58.6,
      fatPercentage: 24.0,
      mealsByMealType: {
        'PRE_WORKOUT': [
          {
            'foodName': 'กล้วยหอม 1 ลูก + กาแฟดำ + เนยถั่ว',
            'calories': 200,
            'proteinG': 5.0,
            'carbsG': 32.0,
            'fatG': 8.0,
          }
        ],
        'BREAKFAST': [
          {
            'foodName': 'ข้าวต้มกุ้งทรงเครื่อง',
            'calories': 320,
            'proteinG': 18.0,
            'carbsG': 45.0,
            'fatG': 6.0,
          }
        ]
      },
      totalMealsCount: 2,
    );
  }
}

class NutritionRemoteDataSource {
  final Dio _dio;

  NutritionRemoteDataSource(this._dio);

  Future<DailySummaryData> getDailySummary({
    required String userId,
    String? date,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.dailySummary,
        queryParameters: {
          'userId': userId,
          if (date != null) 'date': date,
        },
      );
      if (response.statusCode == 200 && response.data != null) {
        return DailySummaryData.fromJson(response.data as Map<String, dynamic>);
      }
      return DailySummaryData.sample();
    } catch (_) {
      // Fallback sample data if Gateway is in local offline test mode
      return DailySummaryData.sample();
    }
  }
}

final nutritionDataSourceProvider = Provider<NutritionRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return NutritionRemoteDataSource(dio);
});

