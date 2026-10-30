import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class FoodGatekeeperResult {
  final bool isFood;
  final String? matchedLabel;
  final double confidence;
  final List<String> detectedLabels;
  final bool isFallback;

  const FoodGatekeeperResult({
    required this.isFood,
    this.matchedLabel,
    this.confidence = 0.0,
    this.detectedLabels = const [],
    this.isFallback = false,
  });

  factory FoodGatekeeperResult.food({
    required String matchedLabel,
    required double confidence,
    required List<String> detectedLabels,
  }) {
    return FoodGatekeeperResult(
      isFood: true,
      matchedLabel: matchedLabel,
      confidence: confidence,
      detectedLabels: detectedLabels,
    );
  }

  factory FoodGatekeeperResult.notFood({
    required String? topLabel,
    required double confidence,
    required List<String> detectedLabels,
  }) {
    return FoodGatekeeperResult(
      isFood: false,
      matchedLabel: topLabel,
      confidence: confidence,
      detectedLabels: detectedLabels,
    );
  }

  factory FoodGatekeeperResult.fallback() {
    return const FoodGatekeeperResult(
      isFood: true,
      matchedLabel: 'Food (Fallback)',
      confidence: 1.0,
      detectedLabels: ['Food'],
      isFallback: true,
    );
  }
}

/// Layer 2: On-Device Food Gatekeeper ด้วย Google ML Kit
/// ตรวจสอบภาพในเครื่องก่อนอัปโหลด ป้องกันภาพที่ไม่ใช่อาหาร ประหยัดโควตา AI 100%
class FoodGatekeeper {
  FoodGatekeeper._();

  static const double _confidenceThreshold = 0.45;

  static const Set<String> _foodKeywords = {
    'food',
    'dish',
    'cuisine',
    'meal',
    'snack',
    'dessert',
    'fast food',
    'comfort food',
    'junk food',
    'finger food',
    'vegetable',
    'fruit',
    'produce',
    'meat',
    'seafood',
    'poultry',
    'chicken',
    'beef',
    'pork',
    'fish',
    'egg',
    'rice',
    'noodle',
    'pasta',
    'soup',
    'salad',
    'bread',
    'baked goods',
    'pastry',
    'sandwich',
    'burger',
    'hamburger',
    'pizza',
    'beverage',
    'drink',
    'juice',
    'coffee',
    'tea',
    'dairy',
    'cheese',
    'ingredient',
    'tableware',
    'plate',
    'bowl',
    'platter',
    'culinary art',
    'recipe',
    'breakfast',
    'lunch',
    'dinner',
    'brunch',
    'supper',
  };

  static ImageLabeler? _labeler;

  static ImageLabeler _getLabeler() {
    _labeler ??= ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: _confidenceThreshold),
    );
    return _labeler!;
  }

  /// ตรวจสอบว่าภาพเป็นอาหารหรือไม่
  static Future<FoodGatekeeperResult> verifyFood(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return FoodGatekeeperResult.fallback();
      }

      final inputImage = InputImage.fromFilePath(filePath);
      final labels = await _getLabeler().processImage(inputImage);

      if (labels.isEmpty) {
        // หาก ML Kit ไม่พบ Label ใดเลยในภาพ (เช่น รูปมืดสนิท หรือเครื่อง Emulator ไม่มี Model)
        return const FoodGatekeeperResult(
          isFood: false,
          matchedLabel: 'Unrecognized',
          detectedLabels: [],
        );
      }

      final labelNames = labels.map((l) => l.label).toList();

      for (final label in labels) {
        final text = label.label.toLowerCase();
        for (final kw in _foodKeywords) {
          if (text.contains(kw) || kw.contains(text)) {
            return FoodGatekeeperResult.food(
              matchedLabel: label.label,
              confidence: label.confidence,
              detectedLabels: labelNames,
            );
          }
        }
      }

      // ไม่พบคำที่ตรงกับหมวดหมู่อาหาร
      final top = labels.first;
      return FoodGatekeeperResult.notFood(
        topLabel: top.label,
        confidence: top.confidence,
        detectedLabels: labelNames,
      );
    } catch (e) {
      debugPrint('[FoodGatekeeper] On-device ML Kit fallback: $e');
      // หากเกิดข้อยกเว้นบน Emulator หรือเครื่องที่ไม่มี Google Play Services ให้ปล่อยผ่าน (Fail-open)
      return FoodGatekeeperResult.fallback();
    }
  }

  static void dispose() {
    _labeler?.close();
    _labeler = null;
  }
}

