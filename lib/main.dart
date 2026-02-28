import 'package:flutter/material.dart';
import 'package:flutter_2048/core/board.dart';
import 'package:flutter_2048/pages/game_page.dart';
import 'package:flutter_2048/providers/board_provider.dart';
import 'package:flutter_2048/theme/game_theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BoardProvider(Board(4)),
      child: MaterialApp(
        title: '2048',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          extensions: [GameTheme.classic()],
        ),
        home: const GamePage(),
      ),
    );
  }
}
