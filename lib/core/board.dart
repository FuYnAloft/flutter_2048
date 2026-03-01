import 'dart:math';

import '../models/tile_entity.dart';

class BoardChange {
  /// 因合成而消失的方块实体列表（参与合并的两个原始方块）
  final List<TileEntity> mergedTiles;

  /// 新产生的方块实体列表（合成生成的新方块 + 随机生成的方块）
  final List<TileEntity> newTiles;

  BoardChange({required this.mergedTiles, required this.newTiles});
}

/// 2048游戏的棋盘类
class Board {
  final int size;
  final List<List<TileEntity?>> tiles;
  final Random _random = Random();

  /// 当前分数
  int _score = 0;

  int get score => _score;

  Board(this.size)
    : tiles = List.generate(size, (_) => List.filled(size, null));

  /// 初始化棋盘，放置两个初始方块
  BoardChange init() {
    final newTiles = <TileEntity>[];
    final tile1 = randomAdd();
    if (tile1 != null) newTiles.add(tile1);
    final tile2 = randomAdd();
    if (tile2 != null) newTiles.add(tile2);
    return BoardChange(mergedTiles: [], newTiles: newTiles);
  }

  /// 在棋盘上随机添加一个新的方块，值为 2 (90%) 或 4 (10%)
  TileEntity? randomAdd() {
    final emptyCells = <Point<int>>[];

    // 找出所有空位置
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (tiles[i][j] == null) {
          emptyCells.add(Point(i, j));
        }
      }
    }

    if (emptyCells.isEmpty) return null;

    // 随机选择一个空位置
    final position = emptyCells[_random.nextInt(emptyCells.length)];

    // 90% 概率生成 2 (value=1), 10% 概率生成 4 (value=2)
    final value = _random.nextDouble() < 0.9 ? 1 : 2;

    final newTile = TileEntity(value, position.x, position.y);
    tiles[position.x][position.y] = newTile;
    return newTile;
  }

  /// 向右移动棋盘上的所有方块，返回 BoardChange，如果无法移动返回 null
  BoardChange? moveRight() => _move(0, 1);

  /// 向左移动棋盘上的所有方块，返回 BoardChange，如果无法移动返回 null
  BoardChange? moveLeft() => _move(0, -1);

  /// 向上移动棋盘上的所有方块，返回 BoardChange，如果无法移动返回 null
  BoardChange? moveUp() => _move(1, -1);

  /// 向下移动棋盘上的所有方块，返回 BoardChange，如果无法移动返回 null
  BoardChange? moveDown() => _move(1, 1);

  /// 通用移动方法
  /// [axis] - 0: 横向移动, 1: 纵向移动
  /// [direction] - 1: 向右/下, -1: 向左/上
  BoardChange? _move(int axis, int direction) {
    bool moved = false;
    final List<TileEntity> disappearedTiles = []; // 参与合并而消失的原始方块
    final List<TileEntity> newTiles = []; // 合并产生的新方块

    for (int line = 0; line < size; line++) {
      // 收集当前行/列的所有非空方块
      final List<TileEntity> lineTiles = [];
      for (int pos = 0; pos < size; pos++) {
        final tile = axis == 0 ? tiles[line][pos] : tiles[pos][line];
        if (tile != null) {
          lineTiles.add(tile);
          if (axis == 0) {
            tiles[line][pos] = null;
          } else {
            tiles[pos][line] = null;
          }
        }
      }

      if (lineTiles.isEmpty) continue;

      // 根据方向选择起始位置和索引
      int targetPos = direction == 1 ? size - 1 : 0;
      int i = direction == 1 ? lineTiles.length - 1 : 0;

      while ((direction == 1 && i >= 0) ||
          (direction == -1 && i < lineTiles.length)) {
        final current = lineTiles[i];
        int nextIndex = i + (direction == 1 ? -1 : 1);

        // 尝试与下一个方块合并
        if ((direction == 1 && nextIndex >= 0) ||
            (direction == -1 && nextIndex < lineTiles.length)) {
          if (current.value == lineTiles[nextIndex].value) {
            final other = lineTiles[nextIndex];
            final merged = current.mergeWith(other)!;

            // 设置合并后方块的位置
            if (axis == 0) {
              merged.moveTo(line, targetPos);
              tiles[line][targetPos] = merged;
            } else {
              merged.moveTo(targetPos, line);
              tiles[targetPos][line] = merged;
            }

            disappearedTiles.add(current);
            disappearedTiles.add(other);
            newTiles.add(merged);
            // 计分：每个消失的原始方块贡献 pow(2, value)
            _score += pow(2, current.value).toInt();
            _score += pow(2, other.value).toInt();
            moved = true;

            // 跳过已合并的两个方块
            i += direction == 1 ? -2 : 2;
            targetPos += direction == 1 ? -1 : 1;
            continue;
          }
        }

        // 不合并，直接移动
        final newRow = axis == 0 ? line : targetPos;
        final newCol = axis == 0 ? targetPos : line;

        if (current.row != newRow || current.column != newCol) {
          moved = true;
        }

        current.moveTo(newRow, newCol);
        tiles[newRow][newCol] = current;

        i += direction == 1 ? -1 : 1;
        targetPos += direction == 1 ? -1 : 1;
      }
    }

    if (!moved) return null;
    final spawned = randomAdd()!;
    return BoardChange(
      mergedTiles: disappearedTiles,
      newTiles: [...newTiles, spawned],
    );
  }

  /// 返回是否还可以移动
  bool canMove() {
    // 检查是否有空格
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (tiles[i][j] == null) return true;
      }
    }

    // 检查是否有相邻的相同方块可以合并
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        final current = tiles[i][j];
        if (current == null) continue;

        // 检查右边
        if (j < size - 1 && tiles[i][j + 1]?.value == current.value) {
          return true;
        }

        // 检查下边
        if (i < size - 1 && tiles[i + 1][j]?.value == current.value) {
          return true;
        }
      }
    }

    return false;
  }

  /// 重置棋盘，清空所有方块并重新初始化
  BoardChange reset() {
    _score = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        tiles[i][j] = null;
      }
    }
    return init();
  }

  /// 获取当前棋盘上的最高分数（最大方块的值）
  int getMaxTileValue() {
    int maxValue = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (tiles[i][j] != null && tiles[i][j]!.value > maxValue) {
          maxValue = tiles[i][j]!.value;
        }
      }
    }
    return maxValue > 0 ? pow(2, maxValue).toInt() : 0;
  }

  /// 获取所有方块的列表
  List<TileEntity> getAllTiles() {
    final List<TileEntity> allTiles = [];
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (tiles[i][j] != null) {
          allTiles.add(tiles[i][j]!);
        }
      }
    }
    return allTiles;
  }

  /// 检查是否达到2048（或更高）
  bool hasWon([int targetValue = 2048]) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (tiles[i][j] != null) {
          final tileValue = pow(2, tiles[i][j]!.value).toInt();
          if (tileValue >= targetValue) {
            return true;
          }
        }
      }
    }
    return false;
  }

  /// 获取空格数量
  int getEmptyCellCount() {
    int count = 0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (tiles[i][j] == null) count++;
      }
    }
    return count;
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        buffer.write(
          tiles[i][j]?.value != null
              ? pow(2, tiles[i][j]!.value).toString().padLeft(4)
              : '   .',
        );
        if (j < size - 1) buffer.write(' ');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }
}
