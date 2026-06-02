import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'initial_load_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ★修正: テーマの状態を保持し続けるために StatefulWidget に変更しました
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ★ここでテーマを管理することで、画面が更新されてもリセットされなくなります
  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilderでthemeNotifierを監視し、変化があったら全体を描画し直します
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Roamlust',
          // 【ライトモードのデザイン設定】
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true,
            textTheme: GoogleFonts.notoSansJpTextTheme(
                ThemeData.light().textTheme), // Googleフォントの適用
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.lightGreen.shade100,
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 80,
              iconTheme: const IconThemeData(size: 32),
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
          // 【ダークモードのデザイン設定】
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            textTheme: GoogleFonts.notoSansJpTextTheme(
                ThemeData.light().textTheme), // Googleフォントの適用
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2E4C31),
              elevation: 0,
              scrolledUnderElevation: 0,
              toolbarHeight: 80,
              iconTheme: IconThemeData(size: 32),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF2C2C2C),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF3C3C3C)),
              ),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Color(0xFF2C2C2C),
            ),
          ),
          // 現在のテーマを適用します
          themeMode: currentMode,
          // 最初の画面
          home: InitialLoadScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}
