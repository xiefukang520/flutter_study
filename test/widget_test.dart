import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_study/main.dart';

void main() {
  testWidgets('毒鸡汤 App 启动并显示今日页', (WidgetTester tester) async {
    await tester.pumpWidget(const PoisonSoupApp());

    expect(find.text('今日毒鸡汤'), findsNWidgets(2));
    expect(find.text('热血漫画句'), findsOneWidget);
    expect(find.text('热门网络句子'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
