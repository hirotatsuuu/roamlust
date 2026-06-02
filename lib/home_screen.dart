import 'package:flutter/material.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';
import 'app_drawer.dart';

class HomeScreen extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const HomeScreen({super.key, required this.themeNotifier});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // dynamic(何でもあり)ではなく、厳密な辞書型(Map)のリストとして定義します
  List<Map<String, dynamic>> masterData = [];
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 画面が開かれたときに、マスターデータを読み込みます
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // キャッシュ領域から安全にマスターデータを取得します
      final data = await DataService.loadMasterData();
      setState(() {
        // 読み込んだデータを、厳密な型のリストに変換して保存します
        masterData = List<Map<String, dynamic>>.from(data);
        isLoading = false; // 読み込みが完了したらローディングを解除します
      });
    } catch (e) {
      // 例外処理：データの読み込みに失敗した場合
      setState(() {
        isLoading = false;
        _errorMessage = 'データの読み込みに失敗しました。キャッシュを削除してやり直してください。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 現在のテーマがダークモードかどうかを判定します
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        // トップ画面のヘッダーをモダンな感じにデザイン修正
        title: Text(
          'Roamlust',
          style: TextStyle(
            fontWeight: FontWeight.w900, // より太字で存在感を出します
            letterSpacing: 1.2, // 文字の間隔を少し広げてモダンに
            // ダークモードなら白、ライトモードならテーマのメインカラー
            color:
                isDark ? Colors.white : Theme.of(context).colorScheme.primary,
          ),
        ),
        centerTitle: true,
        // 下に薄い線を引いてヘッダーとコンテンツの境界を作ります
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color:
                isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05),
            height: 1.0,
          ),
        ),
      ),
      // AppDrawerを表示します
      drawer: AppDrawer(themeNotifier: widget.themeNotifier),
      body: isLoading
          // 読み込み中は可愛いローディング（くるくる）と文字を表示します
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('準備中...'),
                ],
              ),
            )
          // エラーがある場合はエラーメッセージを表示します
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              // 読み込みが終わったら検索フォームを表示します
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'あなたの次の目的地は、どこですか？',
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                isDark ? Colors.grey.shade400 : Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Autocompleteにも、扱うデータが「Map型」であることを伝えます
                        Autocomplete<Map<String, dynamic>>(
                          // 入力された文字に一致する国を探し出します
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              // 空っぽの場合は空のリストを返します
                              return const Iterable<
                                  Map<String, dynamic>>.empty();
                            }
                            return masterData.where((country) {
                              // name_jaがない場合に備えて安全に取り出します
                              final name = country['name_ja']?.toString() ?? '';
                              return name.contains(textEditingValue.text);
                            });
                          },
                          // 候補として表示する文字を指定します
                          displayStringForOption:
                              (Map<String, dynamic> option) {
                            return option['name_ja']?.toString() ?? '不明な国';
                          },
                          // 候補が選ばれたときの処理です
                          onSelected: (Map<String, dynamic> selection) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CountryDetailScreen(
                                  iso2: selection['iso2'].toString(),
                                  nameJa: selection['name_ja'].toString(),
                                ),
                              ),
                            );
                          },
                          // 検索枠の見た目を整えます
                          fieldViewBuilder: (context, controller, focusNode,
                              onEditingComplete) {
                            return TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onEditingComplete: onEditingComplete,
                              decoration: InputDecoration(
                                hintText: '国名を入力 (例: 日本)',
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                prefixIcon: const Icon(Icons.search),
                                // 検索枠のデザインをモダンに丸くします
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? Colors.grey.shade700
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? const Color(0xFF2C2C2C)
                                    : Colors.white,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            '地図を広げるだけでは、足りないあなたへ。\n世界は、あなたの歩みを待っています。',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
