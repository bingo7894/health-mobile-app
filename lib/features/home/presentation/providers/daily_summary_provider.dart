import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/nutrition_remote_datasource.dart';

// Sample User ID (matches our backend test UUID)
const String kDefaultUserId = '11111111-1111-1111-1111-111111111111';

final dailySummaryProvider = FutureProvider<DailySummaryData>((ref) async {
  final dataSource = ref.watch(nutritionDataSourceProvider);
  return dataSource.getDailySummary(userId: kDefaultUserId);
});

