// 2048游戏Widget测试

import 'package:flutter_2048/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('2048游戏启动测试', (WidgetTester tester) async {
    // 构建应用并触发一帧
    await tester.pumpWidget(const MyApp());

    // 验证标题显示
    expect(find.text('2048'), findsOneWidget);

    // 验证新游戏按钮存在
    expect(find.text('新游戏'), findsOneWidget);
  });

  testWidgets('点击新游戏按钮测试', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    // 点击新游戏按钮
    await tester.tap(find.text('新游戏'));
    await tester.pump();

    // 验证游戏仍然显示
    expect(find.text('2048'), findsOneWidget);
  });
}
