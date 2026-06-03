import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';
import 'config.dart';

// お気に入りに追加した国だけを表示する画面です。
class FavoriteListScreen extends StatefulWidget {
  const FavoriteListScreen({super.key});

  @override
  State<FavoriteListScreen> createState() => _FavoriteListScreenState();
}

class _FavoriteListScreenState extends State<FavoriteListScreen> {
  List<Map<String, dynamic>> _favoriteCountries = []; // お気に入りの国のデータを入れる箱
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // 保存されているお気に入りリストを読み込む処理です。
  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);

    try {
      final master = await DataService.loadMasterData(); // すべての国データ
      final favIso2List = await DataService.getFavorites(); // お気に入りの国コード一覧

      // マスターデータの中から、お気に入りに入っている国だけを抽出（フィルター）します。
      final List<Map<String, dynamic>> filteredList = master
          .where((country) => favIso2List.contains(country['iso2']))
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      // 見やすいようにあいうえお順に並べ替えます。
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
          const SnackBar(content: Text('お気に入りデータが読み込めません。')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // リストのハートを押して、お気に入りから削除する処理です。
  Future<void> _removeFavorite(String iso2) async {
    await DataService.toggleFavorite(iso2);
    _loadFavorites(); // 削除したら、リストから消すために再読み込みします。
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('お気に入りから削除しました', textAlign: TextAlign.center),
          duration: Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(Config.menuFavorite,
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favoriteCountries.isEmpty
              // ひとつもお気に入りがない場合は案内メッセージを表示します。
              ? Center(
                  child: Text(
                    Config.favoriteEmptyMessage,
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
                                    color: Color.fromARGB(
                                        255, 248, 187, 208), // かわいいピンク色
                                    size: 28),
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        onTap: () {
                          // 詳細画面へ移動し、戻ってきたときに（詳細画面で外されているかもしれないので）リストを更新します。
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
