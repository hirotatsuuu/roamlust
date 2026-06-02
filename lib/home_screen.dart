import 'package:flutter/material.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';
import 'app_drawer.dart';
import 'config.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> masterData = [];
  bool isLoading = true;
  TextEditingController? _searchController;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // _errorMessageを取り除き、元のシンプルなデータ読み込みに修正
    final data = await DataService.loadMasterData();
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
        title: const Text('Roamlust',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. サブタイトル（Roam + Lust）
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

                        // 2. ロゴ（ロード画面と同じIconを使用）
                        Icon(
                          Icons.travel_explore, // ロード画面と同じアイコン
                          size: 100, // 大きすぎず小さすぎないサイズ
                          color: isDark
                              ? Colors.blueGrey.shade300.withValues(alpha: 0.3)
                              : Colors.blueGrey.shade500.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 32),

                        // 3. 問いかけ
                        Text(
                          'あなたの次の目的地は、どこですか？',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.grey.shade300
                                : Colors.blueGrey.shade700,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 4. 検索フォーム（中央）
                        Autocomplete<Map<String, dynamic>>(
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<
                                  Map<String, dynamic>>.empty();
                            }
                            return masterData.where((country) {
                              final name = country['name_ja']?.toString() ?? '';
                              return name.contains(textEditingValue.text);
                            });
                          },
                          displayStringForOption:
                              (Map<String, dynamic> option) {
                            return option['name_ja']?.toString() ?? '不明な国';
                          },
                          onSelected: (Map<String, dynamic> selection) async {
                            FocusScope.of(context).unfocus();
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CountryDetailScreen(
                                  iso2: selection['iso2'].toString(),
                                  nameJa: selection['name_ja'].toString(),
                                ),
                              ),
                            );
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
                                hintText: '国名を入力 (例: 日本)',
                                hintStyle: const TextStyle(color: Colors.grey),
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
                        ),
                        const SizedBox(height: 32),

                        // 5. 旅に出たくなる詩的な文章（結合＆アップデート）
                        Text(
                          'まだ見ぬ景色の記憶をたどり、\n僕らは果てしない旅路を夢見る。\n胸の奥に灯る小さな憧れは、\n未知なる世界へ飛び出すための確かな道標。\n地図の余白を埋めるのはあなた自身。\n\nさぁ、旅の準備を始めましょう。',
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

                        // 6. 最後の一文（太字）
                        Text(
                          '世界は、あなたの最初の一歩を待っている。',
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
