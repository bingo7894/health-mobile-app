import 'dart:io';
import 'package:flutter/material.dart';
import 'package:health_app/core/constants/app_colors.dart';
import 'package:health_app/core/localization/app_translations.dart';
import 'package:health_app/core/widgets/fluent_emoji.dart';

class FoodPhotoReviewSheet extends StatefulWidget {
  final File imageFile;
  final AppTranslations tr;

  const FoodPhotoReviewSheet({
    super.key,
    required this.imageFile,
    required this.tr,
  });

  /// แสดงแผ่นพรีวิวภาพถ่าย และให้ผู้ใช้กรอกข้อความระบุรายละเอียดเพิ่มเติม
  /// คืนค่า `String` ข้อความที่กรอก (หรือข้อความว่างเปล่าถ้าไม่ได้กรอก)
  /// หรือคืนค่า `null` หากผู้ใช้กดยกเลิก / ต้องการถ่ายใหม่
  static Future<String?> show(
    BuildContext context, {
    required File imageFile,
    required AppTranslations tr,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FoodPhotoReviewSheet(
        imageFile: imageFile,
        tr: tr,
      ),
    );
  }

  @override
  State<FoodPhotoReviewSheet> createState() => _FoodPhotoReviewSheetState();
}

class _FoodPhotoReviewSheetState extends State<FoodPhotoReviewSheet> {
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _addSuggestion(String text) {
    final current = _notesController.text.trim();
    if (current.isEmpty) {
      _notesController.text = text;
    } else {
      _notesController.text = '$current, $text';
    }
    _notesController.selection = TextSelection.fromPosition(
      TextPosition(offset: _notesController.text.length),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final tr = widget.tr;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final quickChips = [
      (label: tr.text('chip_fried_egg_1'), emoji: FluentEmojiName.cooking),
      (label: tr.text('chip_fried_egg_2'), emoji: FluentEmojiName.cooking),
      (label: tr.text('chip_fried_egg_3'), emoji: FluentEmojiName.cooking),
      (label: tr.text('chip_less_rice'), emoji: FluentEmojiName.rice),
      (label: tr.text('chip_less_sweet'), emoji: FluentEmojiName.apple),
      (label: tr.text('chip_no_oil'), emoji: FluentEmojiName.avocado),
      (label: tr.text('chip_extra_meat'), emoji: FluentEmojiName.fish),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top drag bar
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      tr.text('photo_review_title'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () => Navigator.of(context).pop(null),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Image Thumbnail with 3D Frame
              Center(
                child: Container(
                  height: 175,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: AppColors.clayShadow,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input Field
              Text(
                tr.text('add_notes_title'),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0DB4783C),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _notesController,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: tr.text('add_notes_hint'),
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: InputBorder.none,
                    suffixIcon: _notesController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _notesController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Suggestion Chips (1-Tap to add)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickChips.map((chip) {
                  return Material(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _addSuggestion(chip.label),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FluentEmoji(chip.emoji, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              chip.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),

              // Action Buttons
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(null),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(tr.text('retake_photo')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(_notesController.text.trim());
                      },
                      icon: const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(tr.text('send_to_ai')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
