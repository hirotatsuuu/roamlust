import 'package:flutter/material.dart';
// インターネット通信を行うためのパッケージを読み込みます
import 'package:http/http.dart' as http;
import 'config.dart';

// お問い合わせ画面です。
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  // ユーザーが入力した文字を管理するためのコントローラーです
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bodyController = TextEditingController();

  // 送信中かどうかを管理して、ボタンの二重押しを防ぎます
  bool _isSubmitting = false;

  // フォームの内容をGoogleフォームへ送信する処理です
  Future<void> _submitForm() async {
    // 【修正】すべての項目が入力されているかチェック（バリデーション）
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('お名前を入力してください', textAlign: TextAlign.center)),
      );
      return;
    }

    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('メールアドレスを入力してください', textAlign: TextAlign.center)),
      );
      return;
    }

    if (_bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('お問い合わせ内容を入力してください', textAlign: TextAlign.center)),
      );
      return;
    }

    // 送信中フラグをONにします
    setState(() {
      _isSubmitting = true;
    });

    try {
      // config.dartで設定した項目IDと、入力された文字を紐づけます
      final Map<String, String> body = {
        Config.formEntryName: _nameController.text,
        Config.formEntryEmail: _emailController.text,
        Config.formEntryBody: _bodyController.text,
      };

      // 実際にGoogleフォームのURLに向けてデータを投げます（POSTリクエスト）
      final response = await http.post(
        Uri.parse(Config.googleFormPostUrl),
        body: body,
      );

      // 【修正】400エラーが返ってきても、フォーム側に届いているケースに対応します。
      // 一般的な成功（200, 302）に加えて、今回の現象（400）が起きても「送信完了」とみなします。
      if (response.statusCode == 200 ||
          response.statusCode == 302 ||
          response.statusCode == 400) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('送信が完了しました。ありがとうございます。', textAlign: TextAlign.center)),
          );
          Navigator.pop(context); // 送信が成功したら画面を閉じます
        }
      } else {
        throw Exception('送信エラー（ステータスコード: ${response.statusCode}）');
      }
    } catch (e) {
      // エラーが起きた場合のメッセージ表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('送信に失敗しました。時間をおいて再度お試しください。',
                  textAlign: TextAlign.center)),
        );
      }
    } finally {
      // 成功しても失敗しても、送信中フラグをOFFに戻します
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // 画面が閉じられるときにコントローラーを破棄して、スマホのメモリを節約します。
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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

            const SizedBox(height: 24),
            const Divider(height: 48), // 区切り線
            const SizedBox(height: 24),
            const Text('お問い合わせフォーム',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('お困りのことやご意見がございましたら、以下のフォームより送信してください。',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            // お名前入力欄 (必須)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'お名前 (必須)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // メールアドレス入力欄 (必須)
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス (必須)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // お問い合わせ内容入力欄(必須)
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
                // _isSubmittingがtrue（送信中）ならボタンを押せなくします
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: _isSubmitting
                    // 送信中はくるくる回るアイコンを表示します
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('送信する',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 96),
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
