import 'package:flutter/material.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';
import 'app_drawer.dart';
import 'config.dart';
import 'initial_load_screen.dart';

// アプリのメインとなるホーム画面です。
class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;
  // ダウンロード直後かどうかを判定するフラグを追加（初期値はfalse）
  final bool isJustDownloaded;

  const HomeScreen(
      {super.key, required this.themeNotifier, this.isJustDownloaded = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 国の基本情報（マスターデータ）を入れておくリストです。
  List<Map<String, dynamic>> masterData = [];
  bool isLoading = true; // データを読み込み中かどうかのフラグ
  TextEditingController? _searchController; // 検索フォームの文字を操作するためのコントローラー

  @override
  void initState() {
    super.initState();
    _loadData();
    // もしダウンロード直後なら、画面が描画された直後にダイアログを表示します
    if (widget.isJustDownloaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            // タイトルと本文を中央揃えにします
            title: const Text('WELCOME', textAlign: TextAlign.center),
            content: const Text('Roamlustへようこそ！\n世界を探索する準備が整いました。',
                textAlign: TextAlign.center),
            actionsAlignment: MainAxisAlignment.center, // ボタンも中央に配置
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // 閉じる処理
                child: const Text('閉じる',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      });
    }
  }

  // マスターデータを読み込む処理です。
  Future<void> _loadData() async {
    final data = await DataService.loadMasterData();

    // スマホの容量不足等でデータが完全に消えてしまっていた場合の安全装置です。
    // エラーで止めるのではなく、もう一度ダウンロード画面に戻してあげます。
    if (data.isEmpty) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  InitialLoadScreen(themeNotifier: widget.themeNotifier)),
        );
      }
      return;
    }

    setState(() {
      masterData = List<Map<String, dynamic>>.from(data);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Config.appTitle,
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      // 左上からスライドして出てくるメニュー（ドロワー）を設定します。
      drawer: AppDrawer(themeNotifier: widget.themeNotifier),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('データを準備中...'),
                ],
              ),
            )
          : SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0), // 画面全体の左右の余白
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start, // 上詰めに設定
                  children: [
                    const SizedBox(height: 16),
                    Text(
                      Config.homeOpening,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.blueGrey.shade700,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Config.appSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      Config.homeOpening2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.blueGrey.shade700,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      Config.homeQuestion,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.blueGrey.shade700,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 文字を入力すると、一番シンプルな標準の形（下に垂れ下がる）で予測リストを出します。
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<Map<String, dynamic>>.empty();
                        }
                        // 入力された文字が含まれる国を探し、多すぎないように最大5件までに絞ります。
                        // 入力された文字（ひらがなをカタカナに変換）
                        final query = _toKatakana(textEditingValue.text);

                        return masterData.where((country) {
                          final nameJa = country['name_ja']?.toString() ?? '';

                          // ★もしJSONデータに「name_kana」（例: にほん、かんこく）が含まれている場合
                          final nameKana =
                              country['name_kana']?.toString() ?? '';

                          // 日本語名にヒットするか、または読み仮名にヒットするかを判定
                          return nameJa.contains(query) ||
                              nameKana.contains(textEditingValue.text);
                        }).take(5);
                      },
                      // 予測リストに表示する文字（日本語の国名）を指定します。
                      displayStringForOption: (Map<String, dynamic> option) {
                        return option['name_ja']?.toString() ?? '不明な国';
                      },
                      // 予測リストの中から国が1つ選ばれたときの処理です。
                      onSelected: (Map<String, dynamic> selection) async {
                        FocusScope.of(context).unfocus(); // キーボードを閉じます

                        // 詳細画面へ移動し、ユーザーが戻ってくるまでここで処理を一時停止して待ちます。
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CountryDetailScreen(
                              iso2: selection['iso2'].toString(),
                              nameJa: selection['name_ja'].toString(),
                            ),
                          ),
                        );

                        // 詳細画面から戻ってきた「直後」に検索窓の文字を消すことで、確実に空っぽにします。
                        _searchController?.clear();
                      },
                      // 検索入力欄（テキストボックス）自体のデザインを設定します。
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        // 文字を消す処理で使えるように、コントローラーを変数に保存しておきます。
                        _searchController = controller;
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            hintText: Config.homeSearchHint,
                            hintStyle: const TextStyle(color: Colors.grey),
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            filled: true,
                            fillColor:
                                isDark ? const Color(0xFF2C2C2C) : Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                    Text(
                      Config.homePoetry,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.blueGrey.shade600,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      Config.homeClosing,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.grey.shade300
                            : Colors.blueGrey.shade700,
                        height: 1.8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Icon(
                      Icons.travel_explore,
                      size: 100,
                      // ダークモードかライトモードかで、ロゴの透明度を少し変えて馴染ませます。
                      color: isDark
                          ? Colors.blueGrey.shade300.withValues(alpha: 0.3)
                          : Colors.blueGrey.shade500.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // 入力された文字の中にある「ひらがな」を「カタカナ」に自動変換する関数です
  String _toKatakana(String input) {
    return input.replaceAllMapped(RegExp(r'[\u3041-\u3096]'), (match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) + 0x60);
    });
  }
}
