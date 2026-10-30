import 'package:flutter/material.dart';

enum FluentEmojiName {
  salad('assets/emojis/salad.png', '🥗'),
  apple('assets/emojis/apple.png', '🍎'),
  avocado('assets/emojis/avocado.png', '🥑'),
  carrot('assets/emojis/carrot.png', '🥕'),
  banana('assets/emojis/banana.png', '🍌'),
  broccoli('assets/emojis/broccoli.png', '🥦'),
  strawberry('assets/emojis/strawberry.png', '🍓'),
  cooking('assets/emojis/cooking.png', '🍳'),
  bento('assets/emojis/bento.png', '🍱'),
  potOfFood('assets/emojis/pot_of_food.png', '🍲'),
  fish('assets/emojis/fish.png', '🐟'),
  rice('assets/emojis/rice.png', '🌾'),
  lightning('assets/emojis/lightning.png', '⚡'),
  sun('assets/emojis/sun.png', '☀️'),
  fire('assets/emojis/fire.png', '🔥');

  final String assetPath;
  final String fallbackChar;
  const FluentEmojiName(this.assetPath, this.fallbackChar);
}

/// คอมโพเนนต์แสดงผลไอคอน 3D Microsoft Fluent Emoji (fluentemoji.com)
/// สไตล์ Claymorphism สีสดใส มีแสงเงาและความลึก
class FluentEmoji extends StatelessWidget {
  final FluentEmojiName name;
  final double size;

  const FluentEmoji(this.name, {super.key, this.size = 24});

  /// Factory เลือก Fluent Emoji ตามประเภทมื้ออาหาร
  factory FluentEmoji.forMealType(String mealType, {double size = 24}) {
    switch (mealType.toUpperCase()) {
      case 'BREAKFAST':
        return FluentEmoji(FluentEmojiName.cooking, size: size);
      case 'LUNCH':
        return FluentEmoji(FluentEmojiName.bento, size: size);
      case 'DINNER':
        return FluentEmoji(FluentEmojiName.potOfFood, size: size);
      case 'PRE_WORKOUT':
      case 'POST_WORKOUT':
        return FluentEmoji(FluentEmojiName.lightning, size: size);
      case 'SNACK':
      default:
        return FluentEmoji(FluentEmojiName.apple, size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      name.assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          name.fallbackChar,
          style: TextStyle(fontSize: size * 0.78, height: 1.0),
        ),
      ),
    );
  }
}

