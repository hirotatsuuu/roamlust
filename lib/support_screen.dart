import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

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
    // お問い合わせ内容が空っぽならエラーを出して止めます
    if (_bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('お問い合わせ内容は必須です')),
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

      // 成功した場合（Google Formは通常200か、リダイレクトの302を返します）
      if (response.statusCode == 200 || response.statusCode == 302) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('送信が完了しました。ありがとうございます。')),
          );
          Navigator.pop(context); // 送信が成功したら画面を閉じます
        }
      } else {
        throw Exception('送信エラー'); // 失敗した場合はエラーを起こして下へ逃がします
      }
    } catch (e) {
      // エラーが起きた場合のメッセージ表示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('送信に失敗しました。時間をおいて再度お試しください。')),
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

  // 画面が閉じられるときにコントローラーを破棄してメモリを節約します
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
        title:
            const Text('サポート', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('お困りのことやご意見がございましたら、以下のフォームより送信してください。',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            // お名前入力欄
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'お名前 (任意)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // メールアドレス入力欄（キーボードがメールアドレス用になります）
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'メールアドレス (任意)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // お問い合わせ内容入力欄（大きめに作ります）
            TextField(
              controller: _bodyController,
              maxLines: 6,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                labelText: 'お問い合わせ内容 (必須)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            // 送信ボタン
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
          ],
        ),
      ),
    );
  }
}
