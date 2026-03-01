import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_2048/providers/board_provider.dart';
import 'package:flutter_2048/theme/game_theme.dart';
import 'package:flutter_2048/widgets/tile_widget.dart';
import 'package:provider/provider.dart';

/// 棋盘Widget
class BoardWidget extends StatelessWidget {
  final int gridSize;
  final double spacingFactor;

  const BoardWidget({super.key, this.gridSize = 4, this.spacingFactor = 0.125});

  @override
  Widget build(BuildContext context) {
    final gameTheme = Theme.of(context).extension<GameTheme>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算棋盘大小，取宽高中较小的值
        final boardSize = min(constraints.maxWidth, constraints.maxHeight);

        // 计算单个方块大小
        final tileSize = boardSize * (1 - spacingFactor) / gridSize;
        final spacing = boardSize * spacingFactor / (gridSize + 1);

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: gameTheme.boardBackground,
            borderRadius: .circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: .none,
            children: [
              // 底层：空格子背景
              _buildEmptyGrid(gameTheme, tileSize, spacing),
              // 上层：方块
              _buildTiles(context, tileSize, spacing),
            ],
          ),
        );
      },
    );
  }

  /// 构建空格子背景网格
  Widget _buildEmptyGrid(GameTheme gameTheme, double tileSize, double spacing) {
    return Stack(
      children: [
        for (int row = 0; row < gridSize; row++)
          for (int col = 0; col < gridSize; col++)
            Positioned(
              left: col * (tileSize + spacing) + spacing,
              top: row * (tileSize + spacing) + spacing,
              width: tileSize,
              height: tileSize,
              child: Container(
                decoration: BoxDecoration(
                  color: gameTheme.emptyTileBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
      ],
    );
  }

  /// 构建方块层
  Widget _buildTiles(BuildContext context, double tileSize, double spacing) {
    return Consumer<BoardProvider>(
      builder: (context, provider, child) {
        return Stack(
          clipBehavior: .none,
          children: [
            for (final tile in provider.stackSorted)
              TileWidget(
                key: ValueKey(tile.id),
                tile: tile,
                tileSize: tileSize,
                spacing: spacing,
              ),
          ],
        );
      },
    );
  }
}
