import 'package:flutter/material.dart';
import 'country_list_screen.dart';

class AppDrawer extends StatelessWidget {
  // テーマを切り替えるための変数を受け取ります
  final ValueNotifier<ThemeMode> themeNotifier;

  const AppDrawer({super.key, required this.themeNotifier});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueAccent),
            child: Text(
              'Roamlust',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('国の一覧'),
            onTap: () {
              // メニューを閉じてから一覧画面へ移動します
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CountryListScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: const Text('テーマ切り替え'),
            onTap: () {
              // ライトモードとダークモードを反転させます
              if (themeNotifier.value == ThemeMode.light) {
                themeNotifier.value = ThemeMode.dark;
              } else {
                themeNotifier.value = ThemeMode.light;
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('このアプリについて'),
            onTap: () {
              // Flutterに標準で用意されているライセンス表示画面を呼び出します
              showAboutDialog(
                context: context,
                applicationName: 'Roamlust',
                applicationVersion: '1.0.0',
                applicationLegalese:
                    'データ出典: Wikipedia (CC BY-SA 4.0)\nRest Countries API',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text('サポート (お問い合わせ)'),
            onTap: () {
              // ここにお問い合わせフォーム等を開く処理を追加できます
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('サポートページは準備中です')),
              );
            },
          ),
        ],
      ),
    );
  }
}
