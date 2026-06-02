import 'package:flutter/material.dart';
import 'initial_load_screen.dart';

void main() {
  // アプリ実行時にエラーをキャッチできるようにFlutterの初期化を確実に行います
  WidgetsFlutterBinding.ensureInitialized();
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
          // 標準のライトテーマ設定（モダンで可愛い感じに調整）
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF8FAFC), // 少しだけ青みがかった綺麗な白
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0, // 影をなくしてフラットでモダンに
              scrolledUnderElevation: 0,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
          // ダークテーマ設定（黒すぎないようにグレーベースに調整）
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            // Scaffoldの背景色を、真っ黒ではなく濃いグレーにします
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1E1E1E), // 背景と同じ色にして一体感を出す
              elevation: 0,
              scrolledUnderElevation: 0,
            ),
            // カードなどの表面の色を少し明るいグレーにして浮き出させます
            cardTheme: CardThemeData(
              color: const Color(0xFF2C2C2C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF3C3C3C)), // 境界線もダーク用に
              ),
            ),
            // 旧式の dialogBackgroundColor から、新しい書き方に修正
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF2C2C2C),
            ),
          ),
          // 現在のテーマを適用します
          themeMode: currentMode,
          // 最初の画面として、ロード画面（InitialLoadScreen）を呼び出します
          home: InitialLoadScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}
