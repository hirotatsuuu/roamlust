import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

// アプリの情報を表示する画面です。状態が変わらないため StatelessWidget にしています。
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // URLを開く共通処理です。
  Future<void> _launchURL(String urlString, BuildContext context) async {
    final Uri url = Uri.parse(urlString);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('リンクを開けませんでした')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Config.menuAbout,
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // アプリのロゴとバージョン情報を中央に表示します。
            Center(
              child: Column(
                children: [
                  Icon(Icons.travel_explore,
                      size: 80, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  const Text(
                    Config.appTitle,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const Text(Config.appVersion,
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // データ出典（Wikipedia等）についての表示です。
            const Text(Config.aboutDataTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(Config.aboutDataDescription),
            const SizedBox(height: 16),

            // タップすると公式サイトに飛べるボタン（ListTile）です。
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Wikipedia (CC BY-SA 4.0)'),
              subtitle: const Text('各国の概要テキスト等'),
              trailing: const Icon(Icons.open_in_new),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              onTap: () => _launchURL(Config.wikipediaUrl, context),
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.api),
              title: const Text('Rest Countries API'),
              subtitle: const Text('各国の基本・統計データ等'),
              trailing: const Icon(Icons.open_in_new),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              onTap: () => _launchURL(Config.restCountriesUrl, context),
            ),

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 32),

            // config.dartから読み込んだ製作者のメッセージを表示します。
            const Text(Config.creatorVoiceTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text(
              Config.creatorVoice,
              style: TextStyle(height: 1.8, fontSize: 15),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
