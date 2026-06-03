import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'initial_load_screen.dart';

// アプリのスタート地点となる関数です。
// async（非同期）にすることで、時間のかかる処理を待つことができます。
void main() async {
  // Flutterのエンジンが正しく動くように準備を確実に行います。
  WidgetsFlutterBinding.ensureInitialized();

  // Googleフォントがインターネットから完全に読み込まれるまで待機します。
  // これにより、アプリ起動直後の一瞬の文字化けを防ぐことができます。
  await GoogleFonts.pendingFonts([
    GoogleFonts.notoSansJpTextTheme(),
  ]);

  // 準備ができたらアプリ（MyApp）を起動します。
  runApp(const MyApp());
}

// アプリ全体の設定を管理する土台となる画面です。
// テーマ（色合い）の変更を監視するため StatefulWidget にしています。
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // テーマ（ライト/ダーク）の状態を保持し、変化を監視するための変数です。
  final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    // themeNotifier（テーマの状態）を常に監視し、変化があったらアプリ全体を描画し直します。
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          title: 'Roamlust',

          // --- ここからライトモード（通常時）のデザイン設定 ---
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
            useMaterial3: true,
            // アプリ全体の文字にNoto Sans JPフォントを適用します。
            textTheme:
                GoogleFonts.notoSansJpTextTheme(ThemeData.light().textTheme),
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

          // --- ここからダークモード（暗い画面）のデザイン設定 ---
          darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
            scaffoldBackgroundColor: const Color(0xFF1E1E1E),
            textTheme:
                GoogleFonts.notoSansJpTextTheme(ThemeData.light().textTheme),
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

          // 監視している現在のテーマをアプリに適用します。
          themeMode: currentMode,
          // 起動時に最初に表示する画面を指定します。
          home: InitialLoadScreen(themeNotifier: themeNotifier),
        );
      },
    );
  }
}
