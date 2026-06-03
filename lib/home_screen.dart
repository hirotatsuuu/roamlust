import 'package:flutter/material.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';
import 'app_drawer.dart';
import 'config.dart';
import 'initial_load_screen.dart';

// アプリのメインとなるホーム画面です。
class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

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
              child: Center(
                // 画面が小さいスマホでもはみ出さないようにスクロール可能にします。
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
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

                        // LayoutBuilderを使うと、画面上の「今使える横幅（constraints）」を取得できます。
                        // これを利用して、検索の予測リストを検索フォームとぴったり同じ幅にします。
                        LayoutBuilder(builder: (context, constraints) {
                          // 文字を入力すると候補が出てくる便利な部品（Autocomplete）です。
                          return Autocomplete<Map<String, dynamic>>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                              if (textEditingValue.text.isEmpty) {
                                return const Iterable<
                                    Map<String, dynamic>>.empty();
                              }
                              // 入力された文字が含まれる国だけを絞り込みます。
                              return masterData.where((country) {
                                final name =
                                    country['name_ja']?.toString() ?? '';
                                return name.contains(textEditingValue.text);
                              });
                            },
                            displayStringForOption:
                                (Map<String, dynamic> option) {
                              return option['name_ja']?.toString() ?? '不明な国';
                            },
                            // 検索の予測リストの「見た目」と「表示位置」をカスタマイズする処理です。
                            optionsViewBuilder: (context, onSelected, options) {
                              // ★修正: 候補の数(options.length)に合わせて高さを計算します。
                              // 1個あたり約50pxとして計算し、最大で200pxを超えないように制御します。
                              final double listHeight =
                                  (options.length * 50.0).clamp(0.0, 200.0);

                              return Align(
                                alignment: Alignment.topLeft,
                                child: Transform.translate(
                                  // リストの高さが変わっても、常に入力欄の「すぐ上」に来るように
                                  // 移動させる距離（Y軸マイナス方向）を高さに合わせて計算します。
                                  offset: Offset(0,
                                      -(listHeight + 10)), // 高さ + 少しの隙間(10px)
                                  child: Material(
                                    elevation: 8.0,
                                    borderRadius: BorderRadius.circular(16),
                                    clipBehavior: Clip.antiAlias,
                                    child: SizedBox(
                                      width: constraints.maxWidth,
                                      height: listHeight, // 固定ではなく計算した高さをセットします
                                      child: ListView.builder(
                                        padding: EdgeInsets.zero,
                                        itemCount: options.length,
                                        itemBuilder: (context, index) {
                                          final option =
                                              options.elementAt(index);
                                          return ListTile(
                                            title: Text(
                                                option['name_ja']?.toString() ??
                                                    ''),
                                            onTap: () => onSelected(option),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                            // 国が選ばれたときの処理です。
                            onSelected: (Map<String, dynamic> selection) async {
                              // 画面遷移前にキーボードを閉じます（画面のチラつき防止）。
                              FocusScope.of(context).unfocus();

                              // 詳細画面へ移動し、戻ってくるまで待機します。
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CountryDetailScreen(
                                    iso2: selection['iso2'].toString(),
                                    nameJa: selection['name_ja'].toString(),
                                  ),
                                ),
                              );
                              // 戻ってきたら検索フォームの文字をきれいに消します。
                              _searchController?.clear();
                              _searchController?.text = '';
                            },
                            fieldViewBuilder: (context, controller, focusNode,
                                onEditingComplete) {
                              _searchController = controller;
                              return TextField(
                                controller: controller,
                                focusNode: focusNode,
                                onEditingComplete: onEditingComplete,
                                decoration: InputDecoration(
                                  hintText: Config.homeSearchHint,
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  prefixIcon: const Icon(Icons.search),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  filled: true,
                                  fillColor: isDark
                                      ? const Color(0xFF2C2C2C)
                                      : Colors.white,
                                ),
                              );
                            },
                          );
                        }),
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
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
