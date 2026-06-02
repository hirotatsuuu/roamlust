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
  List<Map<String, dynamic>> masterData = [];
  bool isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await DataService.loadMasterData();
      setState(() {
        masterData = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _errorMessage = 'データの読み込みに失敗しました。キャッシュを削除してやり直してください。';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roamlust',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
                color: isDark
                    ? Colors.white12
                    : Colors.black.withValues(alpha: 0.05),
                height: 1.0)),
      ),
      drawer: AppDrawer(themeNotifier: widget.themeNotifier),
      body: isLoading
          ? const Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('準備中...')
                ]))
          : _errorMessage != null
              ? Center(
                  child: Text(_errorMessage!,
                      style: const TextStyle(color: Colors.red)))
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 70,
                      child: Icon(Icons.travel_explore,
                          size: 150, // ホーム画面のロゴのサイズ
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.03)
                              : Colors.black.withValues(alpha: 0.03)),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('あなたの次の目的地は、どこですか？',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: isDark
                                        ? Colors.grey.shade400
                                        : Colors.grey.shade800)),
                            const SizedBox(height: 24),
                            Autocomplete<Map<String, dynamic>>(
                              optionsBuilder:
                                  (TextEditingValue textEditingValue) {
                                if (textEditingValue.text.isEmpty) {
                                  return const Iterable<
                                      Map<String, dynamic>>.empty();
                                }
                                return masterData.where((country) =>
                                    (country['name_ja']?.toString() ?? '')
                                        .contains(textEditingValue.text));
                              },
                              displayStringForOption:
                                  (Map<String, dynamic> option) =>
                                      option['name_ja']?.toString() ?? '不明な国',
                              onSelected: (Map<String, dynamic> selection) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CountryDetailScreen(
                                                iso2: selection['iso2']
                                                    .toString(),
                                                nameJa: selection['name_ja']
                                                    .toString())));
                              },
                              fieldViewBuilder: (context, controller, focusNode,
                                  onEditingComplete) {
                                return TextField(
                                  keyboardType: TextInputType.text,
                                  controller: controller,
                                  focusNode: focusNode,
                                  onEditingComplete: onEditingComplete,
                                  decoration: InputDecoration(
                                    hintText: '国名を入力 (例: 日本)',
                                    hintStyle:
                                        const TextStyle(color: Colors.grey),
                                    prefixIcon: const Icon(Icons.search),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                            color: isDark
                                                ? Colors.grey.shade700
                                                : Colors.grey.shade300)),
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                  '地図を広げるだけでは、足りないあなたへ。\n世界は、あなたの歩みを待っています。',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.grey.shade500
                                          : Colors.grey.shade600,
                                      height: 1.5)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
