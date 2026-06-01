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

  @override
  void initState() {
    super.initState();
    // 画面が開かれたときに、マスターデータを読み込みます
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DataService.loadMasterData();
    setState(() {
      // 読み込んだデータを、厳密な型のリストに変換して保存します
      masterData = List<Map<String, dynamic>>.from(data);
      isLoading = false; // 読み込みが完了したらローディングを解除します
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roamlust',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
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
                  Text('データを準備中...'),
                ],
              ),
            )
          // 読み込みが終わったら検索フォームを表示します
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '旅する国を探そう',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    // Autocompleteにも、扱うデータが「Map型」であることを伝えます
                    Autocomplete<Map<String, dynamic>>(
                      // 入力された文字に一致する国を探し出します
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          // 空っぽの場合は空のリストを返します
                          return const Iterable<Map<String, dynamic>>.empty();
                        }
                        return masterData.where((country) {
                          // name_jaがない場合に備えて安全に取り出します
                          final name = country['name_ja']?.toString() ?? '';
                          return name.contains(textEditingValue.text);
                        });
                      },
                      // 候補として表示する文字を指定します
                      displayStringForOption: (Map<String, dynamic> option) {
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
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          onEditingComplete: onEditingComplete,
                          decoration: InputDecoration(
                            hintText: '国名を入力 (例: アンドラ)',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
