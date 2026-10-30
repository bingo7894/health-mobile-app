import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/home/data/datasources/nutrition_remote_datasource.dart';
import 'package:health_app/features/home/presentation/providers/daily_summary_provider.dart';

final weeklyStatsProvider = FutureProvider<WeeklySummaryData>((ref) async {
  final dataSource = ref.watch(nutritionDataSourceProvider);
  return dataSource.getWeeklySummary(userId: kDefaultUserId);
});

