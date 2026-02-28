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
  static const Duration mergeDuration = Duration(milliseconds: 150);

  /// 总动画时长 = 移动 + 等待 + 合并
  static const Duration totalDuration = Duration(milliseconds: 350);

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

    // 借助 Offset 的 lerp 方法补间，乘大数以增强动画效果
    final position = Offset(tile.column.toDouble(), tile.row.toDouble());

    return TweenAnimationBuilder(
      tween: Tween<Offset>(begin: position, end: position),
      duration: moveDuration,
      curve: Curves.easeOutBack,
      builder: (_, value, _) {
        final left = value.dx * (tileSize + spacing) + spacing;
        final top = value.dy * (tileSize + spacing) + spacing;

        return Positioned(
          left: left,
          top: top,
          width: tileSize,
          height: tileSize,
          child: _AnimatedTileContent(
            tile: tile,
            tileSize: tileSize,
            displayValue: displayValue,
            gameTheme: gameTheme,
          ),
        );
      },
    );
  }
}

/// 方块内容，处理合并动画（缩放效果）
class _AnimatedTileContent extends StatelessWidget {
  final TileEntity tile;
  final double tileSize;
  final int displayValue;
  final GameTheme gameTheme;

  const _AnimatedTileContent({
    required this.tile,
    required this.tileSize,
    required this.displayValue,
    required this.gameTheme,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = gameTheme.getTileColor(tile.value);
    final textColor = gameTheme.getTileTextColor(tile.value);

    // 根据数值大小调整字体大小
    final double fontSize = tileSize * 0.5;

    // 计算缩放动画前时长在总时长中所占的比例
    final double beginRatio =
        1.0 -
        TileWidget.mergeDuration.inMilliseconds /
            TileWidget.totalDuration.inMilliseconds;

    return TweenAnimationBuilder<double>(
      duration: TileWidget.totalDuration,
      curve: tile.animationState == .normal
          ? Interval(beginRatio, 1.0, curve: Curves.easeOutBack)
          : Interval(beginRatio * 0.25, 1.0),
      tween: Tween<double>(
        begin: 0.0,
        end: tile.animationState == .normal
            ? 1.0
            : 0.8 + tile.value * 0.01, // 合并后放小一点，以免侧边溢出
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
              height: 1.0,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
