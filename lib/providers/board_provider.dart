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

  /// 最高分
  int _bestScore = 0;

  int get bestScore => _bestScore;

  /// 当前分数（从棋盘获取）
  int get score => board.score;

  /// 游戏是否结束
  bool get isGameOver => !board.canMove();

  /// 是否已经达成2048
  bool get hasWon => board.hasWon();

  BoardProvider(this.board, {this.bufferSize = 64}) : _buffer = {} {
    final change = board.init();
    _updateBuffer(change);
  }

  void _updateBuffer(BoardChange change) {
    for (final tile in change.newTiles) {
      _buffer[tile.id] = tile;
    }
    if (change.mergedTiles.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        for (final tile in change.mergedTiles) {
          _buffer.remove(tile.id);
        }
      });
    }
    _sortBuffer(); // 更新_buffer的时候直接重新排序
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
    // 同步最高分
    if (score > _bestScore) {
      _bestScore = score;
    }
    super.notifyListeners();
  }

  void moveRight() {
    final change = board.moveRight();
    if (change == null) return;
    lastMove = (axis: 0, direction: 1);
    _updateBuffer(change);
    notifyListeners();
  }

  void moveLeft() {
    final change = board.moveLeft();
    if (change == null) return;
    lastMove = (axis: 0, direction: -1);
    _updateBuffer(change);
    notifyListeners();
  }

  void moveUp() {
    final change = board.moveUp();
    if (change == null) return;
    lastMove = (axis: 1, direction: -1);
    _updateBuffer(change);
    notifyListeners();
  }

  void moveDown() {
    final change = board.moveDown();
    if (change == null) return;
    lastMove = (axis: 1, direction: 1);
    _updateBuffer(change);
    notifyListeners();
  }

  void reset() {
    final change = board.reset();
    _buffer.clear();
    _updateBuffer(change);
    notifyListeners();
  }
}
