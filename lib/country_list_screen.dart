import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';
import 'format_utils.dart';

enum SortType { alphabetical, population, area, gdp }

class CountryListScreen extends StatefulWidget {
  const CountryListScreen({super.key});

  @override
  State<CountryListScreen> createState() => _CountryListScreenState();
}

class _CountryListScreenState extends State<CountryListScreen> {
  List<Map<String, dynamic>> _countries = [];
  Map<String, dynamic> _currentRankingData = {};
  List<String> _favorites = []; // お気に入りリストを保持する変数
  bool _isLoading = true;
  SortType _currentSort = SortType.alphabetical;

  @override
  void initState() {
    super.initState();
    _loadData(SortType.alphabetical);
  }

  Future<void> _loadData(SortType sortType) async {
    setState(() {
      _isLoading = true;
      _currentSort = sortType;
    });

    try {
      if (_countries.isEmpty) {
        final master = await DataService.loadMasterData();
        _countries = List<Map<String, dynamic>>.from(master);
      }

      if (sortType == SortType.population) {
        _currentRankingData = await DataService.loadRanking('population');
      } else if (sortType == SortType.area) {
        _currentRankingData = await DataService.loadRanking('area');
      } else if (sortType == SortType.gdp) {
        _currentRankingData = await DataService.loadRanking('gdp');
      } else {
        _currentRankingData = {};
      }

      await _refreshFavorites(); // お気に入りの状態を取得
      _sortCountries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('読み込みエラー: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // お気に入り情報を取得する関数
  Future<void> _refreshFavorites() async {
    try {
      final favs = await DataService.getFavorites();
      setState(() {
        _favorites = favs;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('お気に入りデータが読み込めません。データがリセットされた可能性があります。')),
        );
      }
    }
  }

  // お気に入りボタンが押されたときの処理
  Future<void> _toggleFavorite(String iso2) async {
    try {
      // 画面の見た目を先に変えてサクサク動かします
      setState(() {
        if (_favorites.contains(iso2)) {
          _favorites.remove(iso2);
        } else {
          _favorites.add(iso2);
        }
      });
      // 裏で保存処理を実行
      await DataService.toggleFavorite(iso2);
    } catch (e) {
      _refreshFavorites(); // エラー時は元の状態に戻す
    }
  }

  void _sortCountries() {
    _countries.sort((a, b) {
      if (_currentSort == SortType.alphabetical) {
        final nameA = a['name_ja']?.toString() ?? '';
        final nameB = b['name_ja']?.toString() ?? '';
        return nameA.compareTo(nameB);
      } else {
        final iso3A = a['iso3'];
        final iso3B = b['iso3'];
        final valA = _currentRankingData[iso3A];
        final valB = _currentRankingData[iso3B];

        if (valA == null && valB == null) {
          final nameA = a['name_ja']?.toString() ?? '';
          final nameB = b['name_ja']?.toString() ?? '';
          return nameA.compareTo(nameB);
        }
        if (valA == null) return 1;
        if (valB == null) return -1;
        return (valB as num).compareTo(valA as num);
      }
    });
  }

  String _getRankString(int index, Map<String, dynamic> country) {
    if (_currentSort == SortType.alphabetical) return '${index + 1}';
    final val = _currentRankingData[country['iso3']];
    return val == null ? '-' : '${index + 1}';
  }

  Color _getRankColor(int index, bool isDark, String rankStr) {
    if (rankStr == '-' || _currentSort == SortType.alphabetical) {
      return isDark ? Colors.grey.shade500 : Colors.grey.shade400;
    }
    return (index + 1) <= 10
        ? (isDark ? Colors.white : Colors.black87)
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade700);
  }

  Color? _getRankCardColor(int index, bool isDark, String rankStr) {
    if (rankStr == '-' || _currentSort == SortType.alphabetical) return null;
    final rank = index + 1;
    if (isDark) {
      switch (rank) {
        case 1:
          return const Color(0xFF333300);
        case 2:
          return const Color(0xFF3B2F00);
        case 3:
          return const Color(0xFF3B1F00);
        case 4:
          return const Color(0xFF3B1000);
        case 5:
          return const Color(0xFF3B0000);
        case 6:
          return const Color(0xFF3B001F);
        case 7:
          return const Color(0xFF2F003B);
        case 8:
          return const Color(0xFF10003B);
        case 9:
          return const Color(0xFF00153B);
        case 10:
          return const Color(0xFF002B3B);
        default:
          return null;
      }
    } else {
      switch (rank) {
        case 1:
          return Colors.yellow.shade50;
        case 2:
          return Colors.amber.shade50;
        case 3:
          return Colors.orange.shade50;
        case 4:
          return Colors.deepOrange.shade50;
        case 5:
          return Colors.red.shade50;
        case 6:
          return Colors.pink.shade50;
        case 7:
          return Colors.purple.shade50;
        case 8:
          return Colors.indigo.shade50;
        case 9:
          return Colors.blue.shade50;
        case 10:
          return Colors.cyan.shade50;
        default:
          return null;
      }
    }
  }

  String _getSubtitleText(Map<String, dynamic> country) {
    if (_currentSort == SortType.alphabetical) return country['name_en'] ?? '';
    final val = _currentRankingData[country['iso3']];
    if (val == null) return 'データなし';
    if (_currentSort == SortType.population) {
      return '人口: ${FormatUtils.formatNumber(val)}人';
    }
    if (_currentSort == SortType.area) {
      return '面積: ${FormatUtils.formatNumber(val)} km²';
    }
    if (_currentSort == SortType.gdp) {
      return 'GDP: ${FormatUtils.formatMoney(val)}';
    }
    return '';
  }

  void _showSortBottomSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                    child: Text('並び替え',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold))),
                const SizedBox(height: 24),
                Text('ランキング順',
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _buildSortOption(context, SortType.alphabetical, 'あいうえお順',
                    Icons.sort_by_alpha),
                _buildSortOption(
                    context, SortType.population, '人口順', Icons.people),
                _buildSortOption(context, SortType.area, '面積順', Icons.map),
                _buildSortOption(
                    context, SortType.gdp, 'GDP順', Icons.attach_money),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
      BuildContext context, SortType type, String title, IconData icon) {
    final isSelected = _currentSort == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return ListTile(
      leading: Icon(icon,
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.grey : Colors.black54)),
      title: Text(title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? primaryColor : null)),
      trailing: isSelected ? Icon(Icons.check, color: primaryColor) : null,
      onTap: () {
        Navigator.pop(context);
        if (_currentSort != type) _loadData(type);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('国の一覧', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon:
                Icon(Icons.sort, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => _showSortBottomSheet(context),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _countries.length,
              itemBuilder: (context, index) {
                final country = _countries[index];
                final iso2 = country['iso2'];
                final nameJa = country['name_ja'] ?? '不明';
                final isFav = _favorites.contains(iso2); // お気に入り判定

                final rankStr = _getRankString(index, country);
                final subtitleStr = _getSubtitleText(country);
                final rankColor = _getRankColor(index, isDark, rankStr);
                final cardColor = _getRankCardColor(index, isDark, rankStr);

                return Card(
                  color: cardColor,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            rankStr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: rankColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            width: 45,
                            height: 30,
                            child: SvgPicture.asset(
                              'assets/flags/$iso2.svg',
                              fit: BoxFit.cover,
                              placeholderBuilder: (_) => Container(
                                  color: isDark
                                      ? Colors.grey.shade800
                                      : Colors.grey.shade200),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(nameJa,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitleStr),
                    // 右側にハートマークと矢印を並べます
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => _toggleFavorite(iso2),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.grey : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    onTap: () {
                      // 詳細画面から戻ってきたときに、お気に入りの状態を更新します（thenを使用）
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CountryDetailScreen(
                                iso2: iso2, nameJa: nameJa)),
                      ).then((_) => _refreshFavorites());
                    },
                  ),
                );
              },
            ),
    );
  }
}
