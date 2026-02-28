import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_2048/models/tile_entity.dart';
import 'package:flutter_2048/theme/game_theme.dart';

/// 单个方块的Widget，使用隐式动画
class TileWidget extends StatelessWidget {
  final TileEntity tile;
  final double tileSize;
  final double spacing;

  /// 移动动画时长
  static const Duration moveDuration = Duration(milliseconds: 200);

  /// 合并动画时长
  static const Duration mergeDuration = Duration(milliseconds: 100);

  /// 总动画时长 = 移动 + 合并
  static const Duration totalDuration = Duration(milliseconds: 300);

  const TileWidget({
    super.key,
    required this.tile,
    required this.tileSize,
    required this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    final gameTheme = Theme.of(context).extension<GameTheme>()!;
    final displayValue = pow(2, tile.value).toInt();

    // 计算位置
    final left = tile.column * (tileSize + spacing) + spacing;
    final top = tile.row * (tileSize + spacing) + spacing;

    return AnimatedPositioned(
      duration: moveDuration,
      curve: Curves.easeInOut,
      left: left,
      top: top,
      width: tileSize,
      height: tileSize,
      child: _AnimatedTileContent(
        tile: tile,
        displayValue: displayValue,
        gameTheme: gameTheme,
      ),
    );
  }
}

/// 方块内容，处理合并动画（缩放效果）
class _AnimatedTileContent extends StatelessWidget {
  final TileEntity tile;
  final int displayValue;
  final GameTheme gameTheme;

  const _AnimatedTileContent({
    required this.tile,
    required this.displayValue,
    required this.gameTheme,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = gameTheme.getTileColor(tile.value);
    final textColor = gameTheme.getTileTextColor(tile.value);

    // 根据数值大小调整字体大小
    double fontSize;
    if (displayValue < 100) {
      fontSize = 40;
    } else if (displayValue < 1000) {
      fontSize = 32;
    } else if (displayValue < 10000) {
      fontSize = 24;
    } else {
      fontSize = 18;
    }

    return TweenAnimationBuilder<double>(
      duration: TileWidget.totalDuration,
      curve: Curves.linear,
      tween: Tween<double>(
        begin: -2.0,
        end: tile.animationState == .normal ? 1.0 : 0.95, // 合并后放小一点，以免侧边溢出
      ),
      builder: (context, value, child) {
        // 将value clamp到0~1范围
        final scale = value.clamp(0.0, 1.0);
        return Transform.scale(scale: scale, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            displayValue.toString(),
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
