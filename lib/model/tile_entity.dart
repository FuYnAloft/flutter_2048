import 'dart:math';

import 'package:uuid/uuid.dart';

enum AnimationState { normal, merged }

class TileEntity {
  final String id;
  final int value; // 1 -> 2, 2 -> 4, 3 -> 8, ...
  TileEntity? _delegate;
  int _row;
  int _column;
  AnimationState animationState = .normal;

  int get row => _delegate?._row ?? _row;

  int get column => _delegate?._column ?? _column;

  TileEntity(this.value, this._row, this._column) : id = const Uuid().v4();

  TileEntity? mergeWith(TileEntity other) {
    if (value != other.value) return null;
    final merged = TileEntity(value + 1, row, column);
    animationState = .merged;
    other.animationState = .merged;
    _delegate = merged;
    other._delegate = merged;
    return merged;
  }

  void moveTo(int newRow, int newColumn) {
    _row = newRow;
    _column = newColumn;
  }

  @override
  String toString() {
    return 'TileEntity{id: $id, value: ${pow(2, value)}, row: $row, column: $column}';
  }
}
