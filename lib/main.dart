import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueNotifierは、値が変わったときに画面を自動で更新してくれる便利な機能です
    // ここでライトモードかダークモードかを管理します
    final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

    // ValueListenableBuilderでthemeNotifierを監視し、変化があったら全体を描画し直します
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Roamlust',
          // 標準のライトテーマ設定
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          // ダークテーマ設定
          darkTheme: ThemeData.dark(useMaterial3: true),
          // 現在のテーマを適用します
          themeMode: currentMode,
          // 最初の画面としてHomeScreenを呼び出します
          home: HomeScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}
