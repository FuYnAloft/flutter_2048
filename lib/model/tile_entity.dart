import 'dart:math';

enum AnimationState { normal, merged }

class TileEntity {
  final int id;
  final int value; // 1 -> 2, 2 -> 4, 3 -> 8, ...
  TileEntity? delegate;
  int _row;
  int _column;
  AnimationState animationState = .normal;

  int get row => delegate?._row ?? _row;

  set row(int other) => _row = other;

  int get column => delegate?._column ?? _column;

  set column(int other) => _column = other;

  TileEntity(this.id, this.value, this._row, this._column, [this.delegate]);

  TileEntity? mergeWith(TileEntity other) {
    if (value != other.value) return null;
    final merged = TileEntity(id, value + 1, row, column);
    animationState = .merged;
    other.animationState = .merged;
    delegate = merged;
    other.delegate = merged;
    return merged;
  }

  void moveTo(int newRow, int newColumn) {
    row = newRow;
    column = newColumn;
  }

  @override
  String toString() {
    return 'TileEntity{id: $id, value: ${pow(2, value)}, row: $row, column: $column}';
  }
}
