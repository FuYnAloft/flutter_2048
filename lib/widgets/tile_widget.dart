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
class _AnimatedTileContent extends StatefulWidget {
  final TileEntity tile;
  final int displayValue;
  final GameTheme gameTheme;

  const _AnimatedTileContent({
    required this.tile,
    required this.displayValue,
    required this.gameTheme,
  });

  @override
  State<_AnimatedTileContent> createState() => _AnimatedTileContentState();
}

class _AnimatedTileContentState extends State<_AnimatedTileContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: TileWidget.totalDuration,
      vsync: this,
    );

    // 合并的方块：前200ms保持大小0，200~300ms从0变到1
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: 200),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 100,
      ),
    ]).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.gameTheme.getTileColor(widget.tile.value);
    final textColor = widget.gameTheme.getTileTextColor(widget.tile.value);

    // 根据数值大小调整字体大小
    double fontSize;
    if (widget.displayValue < 100) {
      fontSize = 40;
    } else if (widget.displayValue < 1000) {
      fontSize = 32;
    } else if (widget.displayValue < 10000) {
      fontSize = 24;
    } else {
      fontSize = 18;
    }

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            widget.displayValue.toString(),
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
