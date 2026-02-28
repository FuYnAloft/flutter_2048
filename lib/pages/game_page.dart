import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_2048/providers/board_provider.dart';
import 'package:flutter_2048/widgets/board_widget.dart';
import 'package:provider/provider.dart';

/// 2048游戏主页面
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8EF),
      body: SafeArea(
        child: Padding(
          padding: const .symmetric(vertical: 16.0),
          child: Column(
            spacing: 16.0,
            children: [
              // 标题和分数显示和控制栏
              Padding(
                padding: const .symmetric(horizontal: 16),
                child: _buildScoreBoard(context),
              ),
              // 游戏区域
              Expanded(child: _GameBoard()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBoard(BuildContext context) {
    return Row(
      spacing: 8.0,
      mainAxisAlignment: .center,
      children: [
        // 标题
        Expanded(
          child: Align(
            alignment: .centerLeft,
            child: const Text(
              '2048',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF776E65),
              ),
            ),
          ),
        ),
        // 计分板
        Consumer<BoardProvider>(
          builder: (context, provider, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ScoreBox(label: '分数', value: provider.score),
                const SizedBox(width: 12),
                _ScoreBox(label: '最高分', value: provider.bestScore),
              ],
            );
          },
        ),
        // 重新开始按钮
        Expanded(
          child: Align(
            alignment: .centerRight,
            child: ElevatedButton(
              onPressed: () {
                context.read<BoardProvider>().reset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8F7A66),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '新游戏',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 分数显示盒子
class _ScoreBox extends StatelessWidget {
  final String label;
  final int value;

  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEEE4DA),
            ),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// 游戏棋盘区域，处理手势和键盘输入
class _GameBoard extends StatefulWidget {
  @override
  State<_GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<_GameBoard> {
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: GestureDetector(
        onPanStart: (details) => _dragStart = details.localPosition,
        onPanEnd: _handlePanEnd,
        child: Stack(
          children: [
            const BoardWidget(),
            // 游戏结束遮罩
            Positioned.fill(
              child: Consumer<BoardProvider>(
                builder: (context, provider, child) {
                  if (provider.isGameOver) {
                    return _GameOverOverlay();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return .ignored;

    final provider = context.read<BoardProvider>();

    switch (event.logicalKey) {
      case .arrowRight || .keyD:
        provider.moveRight();
      case .arrowLeft || .keyA:
        provider.moveLeft();
      case .arrowUp || .keyW:
        provider.moveUp();
      case .arrowDown || .keyS:
        provider.moveDown();
      default:
        return .ignored;
    }
    return .handled;
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_dragStart == null) return;

    final provider = context.read<BoardProvider>();
    final velocity = details.velocity.pixelsPerSecond;

    // 判断滑动方向
    if (velocity.dx.abs() > velocity.dy.abs()) {
      // 水平滑动
      if (velocity.dx > 0) {
        provider.moveRight();
      } else {
        provider.moveLeft();
      }
    } else {
      // 垂直滑动
      if (velocity.dy > 0) {
        provider.moveDown();
      } else {
        provider.moveUp();
      }
    }

    _dragStart = null;
  }
}

/// 游戏结束遮罩
class _GameOverOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 1000),
      curve: Interval(0.5, 1.0),
      builder: (_, value, _) => Opacity(
        opacity: value,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFAF8EF).withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '游戏结束!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF776E65),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<BoardProvider>().reset();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F7A66),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '再来一局',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
