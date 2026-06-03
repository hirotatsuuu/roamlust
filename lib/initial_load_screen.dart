import 'package:flutter/material.dart';
import 'data_service.dart';
import 'home_screen.dart';
import 'config.dart';

// アプリの初回起動時にデータをダウンロードするための画面です。
// 進捗状況（%）を動的に表示するため StatefulWidget を使用しています。
class InitialLoadScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const InitialLoadScreen({super.key, required this.themeNotifier});

  @override
  State<InitialLoadScreen> createState() => _InitialLoadScreenState();
}

class _InitialLoadScreenState extends State<InitialLoadScreen> {
  double _progress = 0.0; // ダウンロードの進み具合（0.0〜1.0）
  bool _isPaused = false; // ダウンロードが一時停止中かどうか
  bool _isDownloading = false; // ダウンロードが実行中かどうか
  String? _errorMessage; // エラーが起きたときのメッセージ

  @override
  void initState() {
    super.initState();
    // 画面が開かれた直後に、すでにデータを持っているか確認します。
    _checkCacheStatus();
  }

  // スマホ内にすでにダウンロード済みのデータ（キャッシュ）があるか確認する処理です。
  Future<void> _checkCacheStatus() async {
    try {
      final isCompleted = await DataService.isCacheCompleted();
      if (isCompleted) {
        // すでに完了していれば、ダウンロード画面を飛ばしてホーム画面へ進みます。
        _navigateToHome();
      } else {
        setState(() {
          _isDownloading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '状態の確認中にエラーが発生しました。';
      });
    }
  }

  // ホーム画面へ移動する処理です。
  // pushReplacement を使うことで、スマホの「戻る」ボタンでこの画面に戻ってこれないようにします。
  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(themeNotifier: widget.themeNotifier),
      ),
    );
  }

  // ダウンロードを開始する処理です。
  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _isPaused = false;
      _errorMessage = null;
    });

    try {
      // DataServiceにダウンロードを依頼します。
      // onProgressで進捗を受け取り、画面のバー（_progress）を更新します。
      await DataService.downloadAndCacheAllData(
        (progress) {
          setState(() {
            _progress = progress;
          });
        },
        () => _isPaused,
      );

      // 途中で停止されず、無事にすべて完了したらホーム画面へ進みます。
      if (!_isPaused && await DataService.isCacheCompleted()) {
        _navigateToHome();
      }
    } catch (e) {
      // エラーが起きた場合はメッセージを表示し、少し待ってから強制的にホーム画面へ進みます。
      setState(() {
        _errorMessage = Config.loadErrorMessage;
        _isDownloading = false;
      });

      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          _navigateToHome();
        }
      });
    }
  }

  // ダウンロードを一時停止する処理です。
  void _pauseDownload() {
    setState(() {
      _isPaused = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        // 背景をきれいなグラデーションで塗りつぶします。
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [Colors.lightGreen.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        // スマホのノッチ（カメラの出っ張りなど）に被らないようにSafeAreaで囲みます。
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 画面上部にアプリのタイトルを配置するための余白（Expanded）です。
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Text(
                    Config.appTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Icon(
                Icons.travel_explore,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              const Text(
                Config.loadTitle,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                Config.loadSubtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // 状況に合わせて、画面中央の表示を切り替えます。
              if (_errorMessage != null) ...[
                // エラー時
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        height: 1.5),
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ] else if (_isPaused) ...[
                // 一時停止時
                const Text(
                  Config.loadPaused,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('再開する'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ] else if (!_isDownloading && _progress == 0.0) ...[
                // ダウンロード開始前
                const Text(
                  Config.loadReady,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _startDownload,
                  icon: const Icon(Icons.download),
                  label: const Text('ダウンロードを開始する'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ] else ...[
                // ダウンロード中（プログレスバーの表示）
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
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
                OutlinedButton.icon(
                  onPressed: _pauseDownload,
                  icon: const Icon(Icons.pause),
                  label: const Text('中断する'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ],

              // 画面下部のバランスを整えるための余白です。
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
