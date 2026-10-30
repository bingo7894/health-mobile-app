import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class CompressedImageResult {
  final File file;
  final int originalBytes;
  final int compressedBytes;
  final double reductionPercent;

  const CompressedImageResult({
    required this.file,
    required this.originalBytes,
    required this.compressedBytes,
    required this.reductionPercent,
  });

  String get originalSizeKb => '${(originalBytes / 1024).toStringAsFixed(0)} KB';
  String get compressedSizeKb => '${(compressedBytes / 1024).toStringAsFixed(0)} KB';
}

/// Layer 3: Client-Side Image Compression
/// บีบอัดรูปภาพก่อนส่งผ่านเครือข่าย จาก 4–12 MB เหลือ ~120–220 KB
class ImageCompressorHelper {
  ImageCompressorHelper._();

  static const int _targetWidth = 1024;
  static const int _targetHeight = 1024;
  static const int _quality = 75;

  static Future<CompressedImageResult> compress(File sourceFile) async {
    final originalBytes = await sourceFile.length();

    try {
      final tempDir = Directory.systemTemp;
      final targetPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final XFile? compressedXFile =
          await FlutterImageCompress.compressAndGetFile(
        sourceFile.absolute.path,
        targetPath,
        quality: _quality,
        minWidth: _targetWidth,
        minHeight: _targetHeight,
        format: CompressFormat.jpeg,
      );

      if (compressedXFile != null) {
        final compressedFile = File(compressedXFile.path);
        final compressedBytes = await compressedFile.length();
        final reduction = originalBytes > 0
            ? ((originalBytes - compressedBytes) / originalBytes * 100)
                .clamp(0.0, 100.0)
            : 0.0;

        debugPrint(
          '[ImageCompressor] ${(originalBytes / 1024).toStringAsFixed(0)} KB '
          '➔ ${(compressedBytes / 1024).toStringAsFixed(0)} KB (-${reduction.toStringAsFixed(1)}%)',
        );

        return CompressedImageResult(
          file: compressedFile,
          originalBytes: originalBytes,
          compressedBytes: compressedBytes,
          reductionPercent: reduction,
        );
      }
    } catch (e) {
      debugPrint('[ImageCompressor] Error during compression: $e');
    }

    // หากการบีบอัดล้มเหลว ส่งไฟล์เดิมกลับไป
    return CompressedImageResult(
      file: sourceFile,
      originalBytes: originalBytes,
      compressedBytes: originalBytes,
      reductionPercent: 0.0,
    );
  }
}

