import 'package:flutter/material.dart';
import 'package:flutter_2048/providers/board_provider.dart';
import 'package:flutter_2048/theme/game_theme.dart';
import 'package:flutter_2048/widgets/tile_widget.dart';
import 'package:provider/provider.dart';

/// 棋盘Widget
class BoardWidget extends StatelessWidget {
  final int gridSize;
  final double spacing;

  const BoardWidget({super.key, this.gridSize = 4, this.spacing = 12});

  @override
  Widget build(BuildContext context) {
    final gameTheme = Theme.of(context).extension<GameTheme>()!;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 计算棋盘大小，取宽高中较小的值
        final boardSize = constraints.maxWidth < constraints.maxHeight
            ? constraints.maxWidth
            : constraints.maxHeight;

        // 计算单个方块大小
        final tileSize = (boardSize - spacing * (gridSize + 1)) / gridSize;

        return Container(
          width: boardSize,
          height: boardSize,
          decoration: BoxDecoration(
            color: gameTheme.boardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // 底层：空格子背景
              _buildEmptyGrid(gameTheme, tileSize),
              // 上层：方块
              _buildTiles(context, tileSize),
            ],
          ),
        );
      },
    );
  }

  /// 构建空格子背景网格
  Widget _buildEmptyGrid(GameTheme gameTheme, double tileSize) {
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
      ],
    );
  }

  /// 构建方块层
  Widget _buildTiles(BuildContext context, double tileSize) {
    return Consumer<BoardProvider>(
      builder: (context, provider, child) {
        return Stack(
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
