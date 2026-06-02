import 'package:flutter/material.dart';
import 'country_list_screen.dart';
import 'data_service.dart';
import 'initial_load_screen.dart';
import 'config.dart';
import 'about_screen.dart';
import 'support_screen.dart';
import 'favorite_list_screen.dart'; // ★追加

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
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('国の一覧'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CountryListScreen()));
            },
          ),
          // ★新規追加: お気に入りメニュー
          ListTile(
            leading: const Icon(
              Icons.favorite,
            ),
            title: const Text('お気に入り'),
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
            title: const Text('テーマ切り替え'),
            onTap: () {
              themeNotifier.value = (themeNotifier.value == ThemeMode.light)
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('このアプリについて'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('サポート (お問い合わせ)'),
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
            title: const Text(
              'データの初期化(キャッシュ削除)',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () async {
              final bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('確認'),
                      content: const Text(
                          'ダウンロードした情報をすべて削除して初期状態に戻しますか？\n(※お気に入りは保持されます)'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('削除する',
                              style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  ) ??
                  false;

              if (confirm) {
                try {
                  await DataService.clearCache();
                  if (context.mounted) {
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
