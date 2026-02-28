import 'package:flutter/material.dart';

/// 2048游戏的主题扩展
class GameTheme extends ThemeExtension<GameTheme> {
  /// 棋盘背景色
  final Color boardBackground;

  /// 空格子背景色
  final Color emptyTileBackground;

  /// 不同数值方块的背景色映射 (value -> color)
  /// value 是 2^n 形式的指数，例如 1 对应 2, 2 对应 4
  final Map<int, Color> tileColors;

  /// 不同数值方块的文字颜色映射
  final Map<int, Color> tileTextColors;

  /// 默认方块背景色（超出映射范围时使用）
  final Color defaultTileColor;

  /// 默认方块文字颜色
  final Color defaultTileTextColor;

  const GameTheme({
    required this.boardBackground,
    required this.emptyTileBackground,
    required this.tileColors,
    required this.tileTextColors,
    required this.defaultTileColor,
    required this.defaultTileTextColor,
  });

  /// 经典2048配色
  factory GameTheme.classic() {
    return GameTheme(
      boardBackground: const Color(0xFFBBADA0),
      emptyTileBackground: const Color(0xFFCDC1B4),
      tileColors: const {
        1: Color(0xFFEEE4DA), // 2
        2: Color(0xFFEDE0C8), // 4
        3: Color(0xFFF2B179), // 8
        4: Color(0xFFF59563), // 16
        5: Color(0xFFF67C5F), // 32
        6: Color(0xFFF65E3B), // 64
        7: Color(0xFFEDCF72), // 128
        8: Color(0xFFEDCC61), // 256
        9: Color(0xFFEDC850), // 512
        10: Color(0xFFEDC53F), // 1024
        11: Color(0xFFEDC22E), // 2048
      },
      tileTextColors: const {
        1: Color(0xFF776E65), // 2
        2: Color(0xFF776E65), // 4
        3: Color(0xFFF9F6F2), // 8
        4: Color(0xFFF9F6F2), // 16
        5: Color(0xFFF9F6F2), // 32
        6: Color(0xFFF9F6F2), // 64
        7: Color(0xFFF9F6F2), // 128
        8: Color(0xFFF9F6F2), // 256
        9: Color(0xFFF9F6F2), // 512
        10: Color(0xFFF9F6F2), // 1024
        11: Color(0xFFF9F6F2), // 2048
      },
      defaultTileColor: const Color(0xFF3C3A32),
      defaultTileTextColor: const Color(0xFFF9F6F2),
    );
  }

  /// 获取方块背景色
  Color getTileColor(int value) {
    return tileColors[value] ?? defaultTileColor;
  }

  /// 获取方块文字颜色
  Color getTileTextColor(int value) {
    return tileTextColors[value] ?? defaultTileTextColor;
  }

  @override
  GameTheme copyWith({
    Color? boardBackground,
    Color? emptyTileBackground,
    Map<int, Color>? tileColors,
    Map<int, Color>? tileTextColors,
    Color? defaultTileColor,
    Color? defaultTileTextColor,
  }) {
    return GameTheme(
      boardBackground: boardBackground ?? this.boardBackground,
      emptyTileBackground: emptyTileBackground ?? this.emptyTileBackground,
      tileColors: tileColors ?? this.tileColors,
      tileTextColors: tileTextColors ?? this.tileTextColors,
      defaultTileColor: defaultTileColor ?? this.defaultTileColor,
      defaultTileTextColor: defaultTileTextColor ?? this.defaultTileTextColor,
    );
  }

  @override
  GameTheme lerp(ThemeExtension<GameTheme>? other, double t) {
    if (other is! GameTheme) return this;
    return GameTheme(
      boardBackground: Color.lerp(boardBackground, other.boardBackground, t)!,
      emptyTileBackground: Color.lerp(
        emptyTileBackground,
        other.emptyTileBackground,
        t,
      )!,
      tileColors: t < 0.5 ? tileColors : other.tileColors,
      tileTextColors: t < 0.5 ? tileTextColors : other.tileTextColors,
      defaultTileColor: Color.lerp(
        defaultTileColor,
        other.defaultTileColor,
        t,
      )!,
      defaultTileTextColor: Color.lerp(
        defaultTileTextColor,
        other.defaultTileTextColor,
        t,
      )!,
    );
  }
}
