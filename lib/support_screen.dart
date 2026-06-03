import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'config.dart';

// お問い合わせ画面です。
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // ユーザーが入力した文字を管理するためのコントローラーです。
  final _nameController = TextEditingController();
  final _bodyController = TextEditingController();

  // メールアプリを起動する際、日本語などの文字が文字化けしないように変換（エンコード）する処理です。
  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  // 送信ボタンが押されたときの処理（メールアプリを起動します）
  Future<void> _sendEmail() async {
    // お問い合わせ内容が空っぽならエラーを出して処理を止めます。
    if (_bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('お問い合わせ内容は必須です', textAlign: TextAlign.center),
            duration: Duration(seconds: 2)),
      );
      return;
    }

    // 入力された名前と本文を合体させて、メールの本文を作ります。
    final String emailBody =
        'お名前: ${_nameController.text}\n\nお問い合わせ内容:\n${_bodyController.text}';

    // mailto: という特殊なURL形式を作ることで、スマホが「これはメール送信だ！」と認識してくれます。
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: Config.supportEmail, // config.dartからメールアドレスを読み込み
      query: _encodeQueryParameters(<String, String>{
        'subject': Config.supportSubject, // config.dartから件名を読み込み
        'body': emailBody,
      }),
    );

    // 準備した設定を使ってメールアプリを立ち上げます。
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('メールアプリを起動できませんでした。設定をご確認ください。',
                  textAlign: TextAlign.center),
              duration: Duration(seconds: 2)),
        );
      }
    }
  }

  // 画面が閉じられるときにコントローラーを破棄して、スマホのメモリを節約します。
  @override
  void dispose() {
    _nameController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Config.menuSupport,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ここからQ&Aセクション ---
            const Text('よくある質問',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildQAItem('Q. オフラインでも使えますか？',
                'A. はい。初回起動時にデータをダウンロードした後は、完全にインターネット通信なしでご利用いただけます。'),
            _buildQAItem(
                'Q. アプリの容量はどれくらいですか？', 'A. 国旗の画像やデータを含め、約数MB〜十数MBを使用します。'),
            _buildQAItem(
                'Q. 不要になったデータを消すには？', 'A. 左上のメニューにある「データの初期化」からいつでも削除できます。'),
            _buildQAItem(
                'Q. ダークモードに対応していますか？', 'A. はい。メニューの「テーマ切り替え」からいつでも変更可能です。'),
            _buildQAItem('Q. 新しい機能の要望はできますか？', 'A. はい！ぜひ下のフォームからアイデアをお送りください。'),

            const Divider(height: 48), // 区切り線

            const Text('お問い合わせフォーム',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('その他のご意見・ご要望は、以下のフォームより送信してください。\n※お使いのメールアプリが起動します。',
                style: TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            // --- ここまで ---
            TextField(
              controller: _bodyController,
              maxLines: 6, // 本文を長く書けるように入力欄を広げます
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                labelText: 'お問い合わせ内容 (必須)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _sendEmail,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('メールアプリを起動する',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Q&Aの1セットを綺麗に表示するための専用部品です。
  Widget _buildQAItem(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.blueGrey)),
          const SizedBox(height: 4),
          Text(answer, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}
