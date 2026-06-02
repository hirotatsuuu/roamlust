import 'package:flutter/material.dart';
import 'country_list_screen.dart';
import 'data_service.dart';
import 'initial_load_screen.dart';

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
          const Divider(),
          // ここから新規追加：キャッシュを削除してリセットする機能
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              'データの初期化(キャッシュ削除)',
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              // 誤操作を防ぐため、確認のダイアログを出します
              final bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('確認'),
                      content: const Text('ダウンロードした情報をすべて削除して初期状態に戻しますか？'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false), // キャンセル
                          child: const Text('キャンセル'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), // 実行
                          child: const Text(
                            '削除する',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                      ],
                    ),
                  ) ??
                  false; // 画面外タップで閉じられた場合はfalse

              if (confirm) {
                try {
                  // キャッシュの削除処理を実行します
                  await DataService.clearCache();

                  // これまでの画面遷移の履歴をすべて消し、強制的に初期画面に戻します
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            InitialLoadScreen(themeNotifier: themeNotifier),
                      ),
                      (route) => false, // 全てのルート（画面履歴）を削除
                    );
                  }
                } catch (e) {
                  // 例外処理：削除に失敗した場合
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('削除に失敗しました: $e')),
                    );
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
