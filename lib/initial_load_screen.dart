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
  double _progress = 0.0;
  bool _isPaused = false;
  bool _isDownloading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkCacheStatus();
  }

  Future<void> _checkCacheStatus() async {
    try {
      final isCompleted = await DataService.isCacheCompleted();
      if (isCompleted) {
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

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(themeNotifier: widget.themeNotifier),
      ),
    );
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _isPaused = false;
      _errorMessage = null;
    });

    try {
      await DataService.downloadAndCacheAllData(
        (progress) {
          setState(() {
            _progress = progress;
          });
        },
        () => _isPaused,
      );

      if (!_isPaused && await DataService.isCacheCompleted()) {
        _navigateToHome();
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'ダウンロード中にエラーが発生しました。\nネットワークやストレージを確認してください。';
      });
    }
  }

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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
                : [Colors.lightGreen.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
            ] else if (_isPaused) ...[
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
            ] else if (!_isDownloading && _progress == 0.0) ...[
              const Text(
                'ダウンロードの準備ができました',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download),
                label: const Text('ダウンロードを開始する'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ] else ...[
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
              // ★変更: TextButton を OutlinedButton に変更し、枠線をつけました
              OutlinedButton.icon(
                onPressed: _pauseDownload,
                icon: const Icon(Icons.pause),
                label: const Text('中断する'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent), // ★枠線の設定
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
