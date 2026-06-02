import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';

class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  List<Map<String, dynamic>> _favoriteCountries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // お気に入りとして保存されている国だけを抽出します
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final master = await DataService.loadMasterData();
      final favIso2List = await DataService.getFavorites();

      // マスターデータの中から、お気に入りに登録されている国だけを探します
      final List<Map<String, dynamic>> filteredList = master
          .where((country) => favIso2List.contains(country['iso2']))
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // あいうえお順に並べます
      filteredList.sort((a, b) {
        final nameA = a['name_ja']?.toString() ?? '';
        final nameB = b['name_ja']?.toString() ?? '';
        return nameA.compareTo(nameB);
      });

      setState(() {
        _favoriteCountries = filteredList;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('お気に入りデータが読み込めません。データがリセットされた可能性があります。')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // お気に入りを解除する処理（この画面で解除するとリストから消えます）
  Future<void> _removeFavorite(String iso2) async {
    await DataService.toggleFavorite(iso2);
    _loadFavorites(); // 再読み込みして画面から消します
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('お気に入りから削除しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('お気に入り', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteCountries.isEmpty
              ? Center(
                  child: Text(
                    'お気に入りに登録された国はありません\n\nハートをタップして追加してみましょう',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        height: 1.8),
                  ),
                )
              : ListView.builder(
                  itemCount: _favoriteCountries.length,
                  itemBuilder: (context, index) {
                    final country = _favoriteCountries[index];
                    final iso2 = country['iso2'];
                    final nameJa = country['name_ja'] ?? '不明';
                    final nameEn = country['name_en'] ?? '';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 45,
                            height: 30,
                            child: SvgPicture.asset(
                              'assets/flags/${iso2.toLowerCase()}.svg',
                              fit: BoxFit.cover,
                              placeholderBuilder: (_) => Container(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200),
                            ),
                          ),
                        ),
                        title: Text(nameJa,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(nameEn),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () => _removeFavorite(iso2),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.favorite,
                                    color: Colors.grey, size: 28),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          // 詳細画面から戻ってきたときにお気に入りが解除されていたらリストから消すためリロードします
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CountryDetailScreen(
                                    iso2: iso2, nameJa: nameJa)),
                          ).then((_) => _loadFavorites());
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
