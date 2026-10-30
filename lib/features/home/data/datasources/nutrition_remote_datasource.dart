import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:health_app/core/config/api_config.dart';
import 'package:health_app/core/network/dio_client.dart';

class MealEntryItem {
  final String? id;
  final String foodName;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const MealEntryItem({
    this.id,
    required this.foodName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory MealEntryItem.fromJson(Map<String, dynamic> json) {
    return MealEntryItem(
      id: json['id']?.toString(),
      foodName: json['foodName']?.toString() ?? '-',
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

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
  final Map<String, List<MealEntryItem>> mealsByMealType;
  final int totalMealsCount;
  final bool isOfflineSample;

  const DailySummaryData({
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
    this.isOfflineSample = false,
  });

  factory DailySummaryData.fromJson(Map<String, dynamic> json) {
    final macro = json['macroDistribution'] as Map<String, dynamic>? ?? {};
    final rawMeals = json['mealsByMealType'] as Map<String, dynamic>? ?? {};
    final parsedMeals = <String, List<MealEntryItem>>{};

    for (final entry in rawMeals.entries) {
      final list = entry.value;
      if (list is List) {
        parsedMeals[entry.key] = list
            .whereType<Map<String, dynamic>>()
            .map(MealEntryItem.fromJson)
            .toList();
      }
    }

    return DailySummaryData(
      totalCaloriesIn: (json['totalCaloriesIn'] as num?)?.toInt() ?? 0,
      totalProteinG: (json['totalProteinG'] as num?)?.toDouble() ?? 0.0,
      totalCarbsG: (json['totalCarbsG'] as num?)?.toDouble() ?? 0.0,
      totalFatG: (json['totalFatG'] as num?)?.toDouble() ?? 0.0,
      totalSodiumMg: (json['totalSodiumMg'] as num?)?.toDouble() ?? 0.0,
      totalSugarG: (json['totalSugarG'] as num?)?.toDouble() ?? 0.0,
      totalFiberG: (json['totalFiberG'] as num?)?.toDouble() ?? 0.0,
      totalCaloriesBurned: (json['totalCaloriesBurned'] as num?)?.toInt() ?? 0,
      netCalories: (json['netCalories'] as num?)?.toInt() ?? 0,
      proteinPercentage: (macro['proteinPercentage'] as num?)?.toDouble() ?? 0.0,
      carbsPercentage: (macro['carbsPercentage'] as num?)?.toDouble() ?? 0.0,
      fatPercentage: (macro['fatPercentage'] as num?)?.toDouble() ?? 0.0,
      mealsByMealType: parsedMeals,
      totalMealsCount: (json['totalMealsCount'] as num?)?.toInt() ?? 0,
    );
  }

  factory DailySummaryData.sample() {
    return const DailySummaryData(
      totalCaloriesIn: 840,
      totalProteinG: 52.0,
      totalCarbsG: 108.0,
      totalFatG: 22.0,
      totalSodiumMg: 680.0,
      totalSugarG: 14.0,
      totalFiberG: 7.5,
      totalCaloriesBurned: 210,
      netCalories: 630,
      proteinPercentage: 25.0,
      carbsPercentage: 51.5,
      fatPercentage: 23.5,
      mealsByMealType: {
        'BREAKFAST': [
          MealEntryItem(
            foodName: 'ข้าวต้มกุ้งทรงเครื่อง',
            calories: 320,
            proteinG: 20.0,
            carbsG: 44.0,
            fatG: 6.0,
          ),
        ],
        'LUNCH': [
          MealEntryItem(
            foodName: 'อกไก่ย่างสลัดอะโวคาโด & ควินัว',
            calories: 520,
            proteinG: 32.0,
            carbsG: 64.0,
            fatG: 16.0,
          ),
        ],
      },
      totalMealsCount: 2,
      isOfflineSample: true,
    );
  }
}

class DailyCaloriePoint {
  final DateTime date;
  final int calories;

  const DailyCaloriePoint({required this.date, required this.calories});
}

class WeeklySummaryData {
  final int totalDaysLogged;
  final double averageCaloriesPerDay;
  final int highestCalories;
  final List<DailyCaloriePoint> points;
  final bool isOfflineSample;

  const WeeklySummaryData({
    required this.totalDaysLogged,
    required this.averageCaloriesPerDay,
    required this.highestCalories,
    required this.points,
    this.isOfflineSample = false,
  });

  factory WeeklySummaryData.sample() {
    final today = DateTime.now();
    final sampleKcal = [1760, 1920, 1680, 2050, 1840, 1950, 840];
    final pts = List.generate(7, (i) {
      final d = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i));
      return DailyCaloriePoint(date: d, calories: sampleKcal[i]);
    });
    return WeeklySummaryData(
      totalDaysLogged: 7,
      averageCaloriesPerDay: 1720,
      highestCalories: 2050,
      points: pts,
      isOfflineSample: true,
    );
  }
}

class NutritionRemoteDataSource {
  final Dio _dio;
  static final DateFormat _isoDate = DateFormat('yyyy-MM-dd');

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
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return DailySummaryData.fromJson(response.data as Map<String, dynamic>);
      }
      return DailySummaryData.sample();
    } catch (_) {
      return DailySummaryData.sample();
    }
  }

  Future<WeeklySummaryData> getWeeklySummary({required String userId}) async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(const Duration(days: 6));

    try {
      final response = await _dio.get(
        ApiConfig.rangeSummary,
        queryParameters: {
          'userId': userId,
          'startDate': _isoDate.format(start),
          'endDate': _isoDate.format(end),
        },
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final json = response.data as Map<String, dynamic>;
        final rawRecords = json['dailyRecords'] as List? ?? const [];
        final byDate = <String, int>{};

        for (final item in rawRecords) {
          if (item is Map<String, dynamic>) {
            final dStr = item['logDate']?.toString();
            final kcal = (item['totalCaloriesIn'] as num?)?.toInt() ?? 0;
            if (dStr != null) {
              byDate[dStr] = kcal;
            }
          }
        }

        final pts = List.generate(7, (i) {
          final d = start.add(Duration(days: i));
          final key = _isoDate.format(d);
          return DailyCaloriePoint(date: d, calories: byDate[key] ?? 0);
        });

        return WeeklySummaryData(
          totalDaysLogged: (json['totalDaysLogged'] as num?)?.toInt() ?? 0,
          averageCaloriesPerDay:
              (json['averageCaloriesPerDay'] as num?)?.toDouble() ?? 0.0,
          highestCalories: (json['highestCalories'] as num?)?.toInt() ?? 0,
          points: pts,
        );
      }
      return WeeklySummaryData.sample();
    } catch (_) {
      return WeeklySummaryData.sample();
    }
  }
}

final nutritionDataSourceProvider = Provider<NutritionRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return NutritionRemoteDataSource(dio);
});
