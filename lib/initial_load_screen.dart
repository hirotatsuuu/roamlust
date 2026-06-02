import 'package:flutter/material.dart';
import 'data_service.dart';
import 'home_screen.dart';

class InitialLoadScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const InitialLoadScreen({super.key, required this.themeNotifier});

  @override
  State<InitialLoadScreen> createState() => _InitialLoadScreenState();
}

class _InitialLoadScreenState extends State<InitialLoadScreen> {
  // ダウンロードの進捗率（0.0 〜 1.0）
  double _progress = 0.0;
  // 中断されたかどうかの状態を管理するフラグ
  bool _isPaused = false;
  // エラーが発生した場合のメッセージ
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 画面起動時にキャッシュの状態をチェックします
    _checkCacheStatus();
  }

  // キャッシュがすでにあるか確認し、あればホーム画面へ、なければダウンロードを開始します
  Future<void> _checkCacheStatus() async {
    try {
      final isCompleted = await DataService.isCacheCompleted();
      if (isCompleted) {
        // すでにダウンロード済みなら、すぐにホーム画面へ移動します
        _navigateToHome();
      } else {
        // ダウンロードが必要な場合、自動で開始します
        _startDownload();
      }
    } catch (e) {
      setState(() {
        _errorMessage = '状態の確認中にエラーが発生しました。';
      });
    }
  }

  // ホーム画面へ移動する処理（戻るボタンでこの画面に戻れないようにします）
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(themeNotifier: widget.themeNotifier),
      ),
    );
  }

  // ダウンロード処理を開始（または再開）します
  Future<void> _startDownload() async {
    setState(() {
      _isPaused = false;
      _errorMessage = null; // エラー表示をリセット
    });

    try {
      // DataServiceにダウンロードを依頼します
      await DataService.downloadAndCacheAllData(
        // 進捗が更新されたら画面を再描画します
        (progress) {
          setState(() {
            _progress = progress;
          });
        },
        // 常に現在の中断フラグの状態を渡すことで、DataService側で中断を検知させます
        () => _isPaused,
      );

      // 中断されずに完了フラグが立っているか確認
      if (!_isPaused && await DataService.isCacheCompleted()) {
        _navigateToHome();
      }
    } catch (e) {
      // ダウンロード中にエラーが発生した場合の例外処理
      setState(() {
        _errorMessage = 'ダウンロード中にエラーが発生しました。\nネットワークやストレージを確認してください。';
      });
    }
  }

  // ダウンロードを中断します
  void _pauseDownload() {
    setState(() {
      _isPaused = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面のデザイン（モダンで可愛い感じ）を構築します
    return Scaffold(
      body: Container(
        width: double.infinity,
        // 背景に薄いグラデーションをかけてモダンに演出します
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // アプリのロゴ的なアイコンを表示
            Icon(
              Icons.travel_explore,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            const Text(
              '世界の情報を集めています',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '初回のみ少し時間がかかります',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 48),

            // エラーがある場合はエラーメッセージと再試行ボタンを表示
            if (_errorMessage != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.refresh),
                label: const Text('もう一度試す'),
              ),
            ]
            // 中断中の表示
            else if (_isPaused) ...[
              const Text(
                'ダウンロードが一時停止中です',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.play_arrow),
                label: const Text('再開する'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ]
            // ダウンロード進行中の表示
            else ...[
              // くるくる回るプログレスバー
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progress, // 現在の進捗率を反映
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  // 中央にパーセンテージを表示
                  Text(
                    '${(_progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // 中断ボタン
              TextButton.icon(
                onPressed: _pauseDownload,
                icon: const Icon(Icons.pause),
                label: const Text('中断する'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
