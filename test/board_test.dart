import 'package:flutter_2048/core/board.dart';
import 'package:flutter_2048/model/tile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Board Tests', () {
    test('Board初始化测试', () {
      final board = Board(4);
      expect(board.size, 4);
      expect(board.getEmptyCellCount(), 14); // init()会添加2个方块
      expect(board.getAllTiles().length, 2);
    });

    test('randomAdd方法测试', () {
      final board = Board(4);
      final initialCount = board.getAllTiles().length; // 应该是2
      board.randomAdd();
      expect(board.getAllTiles().length, initialCount + 1);
    });

    test('moveRight方法测试 - 使用mergeWith', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      // 创建测试场景: [2, 2, _, _]
      board.tiles[0][0] = TileEntity(1, 0, 0); // value=1 代表 2
      board.tiles[0][1] = TileEntity(1, 0, 1); // value=1 代表 2

      final mergedTiles = board.moveRight();

      // 验证移动和合并
      expect(mergedTiles, isNotNull);
      expect(mergedTiles!.length, 1);
      expect(board.tiles[0][3]?.value, 2); // value=2 代表 4
    });

    test('moveLeft方法测试 - 使用mergeWith', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      // 创建测试场景: [_, _, 4, 4]
      board.tiles[0][2] = TileEntity(2, 0, 2); // value=2 代表 4
      board.tiles[0][3] = TileEntity(2, 0, 3); // value=2 代表 4

      final mergedTiles = board.moveLeft();

      // 验证移动和合并
      expect(mergedTiles, isNotNull);
      expect(mergedTiles!.length, 1);
      expect(board.tiles[0][0]?.value, 3); // value=3 代表 8
    });

    test('moveUp方法测试 - 使用mergeWith', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      // 创建测试场景: 垂直方向 [2, 2, _, _]
      board.tiles[2][0] = TileEntity(1, 2, 0);
      board.tiles[3][0] = TileEntity(1, 3, 0);

      final mergedTiles = board.moveUp();

      expect(mergedTiles, isNotNull);
      expect(mergedTiles!.length, 1);
      expect(board.tiles[0][0]?.value, 2);
    });

    test('moveDown方法测试 - 使用mergeWith', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      // 创建测试场景: 垂直方向 [2, 2, _, _]
      board.tiles[0][0] = TileEntity(1, 0, 0);
      board.tiles[1][0] = TileEntity(1, 1, 0);

      final mergedTiles = board.moveDown();

      expect(mergedTiles, isNotNull);
      expect(mergedTiles!.length, 1);
      expect(board.tiles[3][0]?.value, 2);
    });

    test('canMove方法测试 - 有空格', () {
      final board = Board(4);
      board.tiles[0][0] = TileEntity(1, 0, 0);

      expect(board.canMove(), true);
    });

    test('canMove方法测试 - 可以合并', () {
      final board = Board(2);
      board.tiles[0][0] = TileEntity(1, 0, 0);
      board.tiles[0][1] = TileEntity(1, 0, 1);
      board.tiles[1][0] = TileEntity(2, 1, 0);
      board.tiles[1][1] = TileEntity(3, 1, 1);

      expect(board.canMove(), true);
    });

    test('canMove方法测试 - 无法移动', () {
      final board = Board(2);
      board.tiles[0][0] = TileEntity(1, 0, 0);
      board.tiles[0][1] = TileEntity(2, 0, 1);
      board.tiles[1][0] = TileEntity(3, 1, 0);
      board.tiles[1][1] = TileEntity(4, 1, 1);

      expect(board.canMove(), false);
    });

    test('getMaxTileValue方法测试', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      board.tiles[0][0] = TileEntity(1, 0, 0); // 2
      board.tiles[0][1] = TileEntity(5, 0, 1); // 32
      board.tiles[0][2] = TileEntity(3, 0, 2); // 8

      expect(board.getMaxTileValue(), 32);
    });

    test('hasWon方法测试', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      board.tiles[0][0] = TileEntity(11, 0, 0); // 2^11 = 2048

      expect(board.hasWon(), true);
      expect(board.hasWon(4096), false);
    });

    test('reset方法测试', () {
      final board = Board(4);
      board.randomAdd();
      board.randomAdd();

      expect(board.getAllTiles().length, 4); // 初始2个 + 添加2个

      board.reset();

      expect(board.getAllTiles().length, 2); // reset后重新init，又有2个
      expect(board.getEmptyCellCount(), 14);
    });

    test('getAllTiles方法测试', () {
      final board = Board(4);
      // 清空棋盘
      for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
          board.tiles[i][j] = null;
        }
      }
      board.tiles[0][0] = TileEntity(1, 0, 0);
      board.tiles[1][1] = TileEntity(2, 1, 1);
      board.tiles[2][2] = TileEntity(3, 2, 2);

      final allTiles = board.getAllTiles();
      expect(allTiles.length, 3);
    });
  });
}
