import 'package:circular_buffer/circular_buffer.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_2048/core/board.dart';
import 'package:flutter_2048/models/tile_entity.dart';

/// 为动画提供完整的状态管理，持有一个循环缓冲区，用于存储 “可见” 的方块实体
class BoardProvider extends ChangeNotifier {
  final Board board;

  /// 一个循环缓冲区，用于存储 “可见” 的方块实体
  final CircularBuffer<TileEntity> _buffer;

  /// 缓冲区中的方块实体按渲染顺序排序后的结果，对应 Stack 中的顺序
  Iterable<TileEntity> stackSorted;

  /// 记录上一次移动的方向和轴，用于动画的方向判断
  /// [axis] - 0: 横向移动, 1: 纵向移动
  /// [direction] - 1: 向右/下, -1: 向左/上
  ({int axis, int direction}) lastMove = (axis: 0, direction: 1);

  BoardProvider(this.board, {int bufferSize = 32})
    : _buffer = CircularBuffer(bufferSize),
      stackSorted = [] {
    // 初始化棋盘并将初始方块添加到缓冲区
    final initialTiles = board.init();
    _buffer.addAll(initialTiles);
    stackSorted = initialTiles;
  }

  @override
  void notifyListeners() {
    // 更新 stackOrder，使其反映当前缓冲区中的方块实体的渲染顺序
    // 正常的块应该放到上面，横向移动时根据列排序，纵向移动时根据行排序
    stackSorted = _buffer.sortedBy((tile) {
      final stateFactor = tile.animationState == AnimationState.normal
          ? 100
          : 0;
      final positionFactor = lastMove.axis == 0
          ? lastMove.direction * tile.column
          : lastMove.direction * tile.row;
      return stateFactor + positionFactor;
    });
    super.notifyListeners();
  }

  void moveRight() {
    final newTiles = board.moveRight();
    if (newTiles == null) return;
    lastMove = (axis: 0, direction: 1);
    _buffer.addAll(newTiles);
    notifyListeners();
  }

  void moveLeft() {
    final newTiles = board.moveLeft();
    if (newTiles == null) return;
    lastMove = (axis: 0, direction: -1);
    _buffer.addAll(newTiles);
    notifyListeners();
  }

  void moveUp() {
    final newTiles = board.moveUp();
    if (newTiles == null) return;
    lastMove = (axis: 1, direction: -1);
    _buffer.addAll(newTiles);
    notifyListeners();
  }

  void moveDown() {
    final newTiles = board.moveDown();
    if (newTiles == null) return;
    lastMove = (axis: 1, direction: 1);
    _buffer.addAll(newTiles);
    notifyListeners();
  }

  void reset() {
    final newTiles = board.reset();
    _buffer.clear();
    _buffer.addAll(newTiles);
    notifyListeners();
  }
}
