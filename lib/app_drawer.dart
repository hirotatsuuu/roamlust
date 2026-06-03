import 'package:flutter/material.dart';
import 'country_list_screen.dart';
import 'data_service.dart';
import 'initial_load_screen.dart';
import 'config.dart';
import 'about_screen.dart';
import 'support_screen.dart';
import 'favorite_list_screen.dart';

// 左上からスライドして出てくるメニュー（ドロワー）の部品です。
class AppDrawer extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const AppDrawer({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ドロワーの一番上のヘッダー部分（アプリ名などを表示）
          DrawerHeader(
            decoration: BoxDecoration(
              color:
                  isDark ? const Color(0xFF1A2E1C) : Colors.lightGreen.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  Config.appTitle,
                  style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  Config.appSubtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          // --- ここから各メニュー項目の設定 ---
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text(Config.menuCountryList),
            onTap: () {
              Navigator.pop(context); // メニューを閉じる
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CountryListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text(Config.menuFavorite),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const FavoriteListScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text(Config.menuTheme),
            onTap: () {
              String themeName = '';

              // 現在のテーマを反転させます（ライトならダークへ）
              if (themeNotifier.value == ThemeMode.light) {
                themeNotifier.value = ThemeMode.dark;
                themeName = 'ダークテーマ';
              } else {
                themeNotifier.value = ThemeMode.light;
                themeName = 'ライトテーマ';
              }

              // 新しく変更されたテーマの色を取得します。
              final newMode = themeNotifier.value;
              // 新しいテーマがダークなら背景を黒く、ライトなら背景を白くして、通知を目立たせます。
              final bgColor = newMode == ThemeMode.dark
                  ? const Color(0xFF333333)
                  : Colors.white;
              final textColor =
                  newMode == ThemeMode.dark ? Colors.white : Colors.black87;

              Navigator.pop(context);

              // 連続で押されたときのために、一度古い通知を消してから新しい通知を出します。
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$themeNameに変更しました',
                      style: TextStyle(
                          color: textColor, fontWeight: FontWeight.bold)),
                  backgroundColor: bgColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(), // 区切り線
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(Config.menuAbout),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text(Config.menuSupport),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SupportScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.grey),
            title: const Text(Config.menuReset,
                style: TextStyle(color: Colors.grey)),
            onTap: () async {
              // データを削除する前に「本当に消すか」の確認ダイアログを出します。
              final bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('確認'),
                      content: const Text(
                          'ダウンロードした情報をすべて削除して初期状態に戻しますか？\n(※お気に入りは保持されます)'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false), // キャンセル時はfalseを返す
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true), // 削除時はtrueを返す
                          child: const Text('削除する',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              // ユーザーが「削除する」を選んだ場合の処理
              if (confirm) {
                try {
                  await DataService.clearCache(); // スマホ内のデータを消去
                  if (context.mounted) {
                    // 全ての画面履歴を消して、強制的にロード画面（初期状態）へ戻します。
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              InitialLoadScreen(themeNotifier: themeNotifier)),
                      (route) => false,
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('削除に失敗しました: $e')));
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
