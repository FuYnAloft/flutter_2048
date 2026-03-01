import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_2048/core/board.dart';
import 'package:flutter_2048/models/tile_entity.dart';

/// 为动画提供完整的状态管理，持有一个循环缓冲区，用于存储 "可见" 的方块实体
class BoardProvider extends ChangeNotifier {
  final Board board;
  final int bufferSize;

  /// 一个缓冲区，用于存储 "可见" 的方块实体，应当消失的块应该在左边
  final Map<String, TileEntity> _buffer;

  /// 缓冲区中的方块实体按渲染顺序排序后的结果，对应 Stack 中的顺序
  Iterable<TileEntity> stackSorted = [];

  /// 记录上一次移动的方向和轴，用于动画的方向判断
  /// [axis] - 0: 横向移动, 1: 纵向移动
  /// [direction] - 1: 向右/下, -1: 向左/上
  ({int axis, int direction}) lastMove = (axis: 0, direction: 1);

  /// 当前分数
  int _score = 0;

  int get score => _score;

  /// 最高分
  int _bestScore = 0;

  int get bestScore => _bestScore;

  /// 游戏是否结束
  bool get isGameOver => !board.canMove();

  /// 是否已经达成2048
  bool get hasWon => board.hasWon();

  BoardProvider(this.board, {this.bufferSize = 64}) : _buffer = {} {
    // 初始化棋盘并将初始方块添加到缓冲区
    final initialTiles = board.init();
    _addAllToBuffer(initialTiles);
  }

  void _addAllToBuffer(Iterable<TileEntity> tiles) {
    for (final tile in tiles) {
      _buffer[tile.id] = tile;
    }
  }

  void _updateBuffer(BoardChange change) {
    for (final tile in change.newTiles) {
      _buffer[tile.id] = tile;
    }
    Future.delayed(Duration(milliseconds: 500), () {
      for (final tile in change.mergedTiles) {
        _buffer.remove(tile.id);
      }
    });
  }

  void _sortBuffer() {
    // 更新 stackSorted，使其反映方块实体的渲染顺序
    // 正常的块应该放到上面；横向移动时根据列排序，纵向移动时根据行排序；最后value越小放列表左边，方便覆盖
    stackSorted = _buffer.values.sortedBy((tile) {
      final stateFactor = tile.animationState == AnimationState.normal ? 1 : 0;
      final positionFactor = lastMove.axis == 0
          ? lastMove.direction * tile.column
          : lastMove.direction * tile.row;
      return 10000 * stateFactor + 100 * positionFactor + tile.value;
    });
  }

  @override
  void notifyListeners() {
    _sortBuffer();
    super.notifyListeners();
  }

  void _addScore(List<TileEntity> mergedTiles) {
    // 计算合成的方块分数
    for (final tile in mergedTiles) {
      if (tile.animationState != AnimationState.merged) {
        // 只计算新合成的方块（不是被合并消失的方块）
        _score += pow(2, tile.value).toInt();
      }
    }
    if (_score > _bestScore) {
      _bestScore = _score;
    }
  }

  void moveRight() {
    final newTiles = board.moveRight();
    if (newTiles == null) return;
    lastMove = (axis: 0, direction: 1);
    _addScore(newTiles);
    _addAllToBuffer(newTiles);
    notifyListeners();
  }

  void moveLeft() {
    final newTiles = board.moveLeft();
    if (newTiles == null) return;
    lastMove = (axis: 0, direction: -1);
    _addScore(newTiles);
    _addAllToBuffer(newTiles);
    notifyListeners();
  }

  void moveUp() {
    final newTiles = board.moveUp();
    if (newTiles == null) return;
    lastMove = (axis: 1, direction: -1);
    _addScore(newTiles);
    _addAllToBuffer(newTiles);
    notifyListeners();
  }

  void moveDown() {
    final newTiles = board.moveDown();
    if (newTiles == null) return;
    lastMove = (axis: 1, direction: 1);
    _addScore(newTiles);
    _addAllToBuffer(newTiles);
    notifyListeners();
  }

  void reset() {
    _score = 0;
    final newTiles = board.reset();
    _buffer.clear();
    _addAllToBuffer(newTiles);
    notifyListeners();
  }
}
