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
  bool _isLoading = true;
  SortType _currentSort = SortType.alphabetical;

  @override
  void initState() {
    super.initState();
    // 最初の起動時はあいうえお順のデータを読み込みます
    _loadData(SortType.alphabetical);
  }

  // 選択された並び替えの種類に応じて、必要なJSONを読み込む関数です
  Future<void> _loadData(SortType sortType) async {
    setState(() {
      _isLoading = true;
      _currentSort = sortType;
    });

    // 国の基本リストは常に必要なので読み込みます
    if (_countries.isEmpty) {
      final master = await DataService.loadMasterData();
      _countries = List<Map<String, dynamic>>.from(master);
    }

    // 選ばれたランキングの種類に応じて、対象のJSONファイルを読み込みます
    if (sortType == SortType.population) {
      _currentRankingData = await DataService.loadRanking('population');
    } else if (sortType == SortType.area) {
      _currentRankingData = await DataService.loadRanking('area');
    } else if (sortType == SortType.gdp) {
      _currentRankingData = await DataService.loadRanking('gdp');
    } else {
      _currentRankingData = {}; // あいうえお順の場合はランキングデータは不要です
    }

    _sortCountries();

    setState(() {
      _isLoading = false;
    });
  }

  // リストの順番を並び替える関数です
  void _sortCountries() {
    _countries.sort((a, b) {
      if (_currentSort == SortType.alphabetical) {
        // あいうえお順の比較
        final nameA = a['name_ja']?.toString() ?? '';
        final nameB = b['name_ja']?.toString() ?? '';
        return nameA.compareTo(nameB);
      } else {
        // ランキング順の比較
        final iso3A = a['iso3'];
        final iso3B = b['iso3'];
        final valA = _currentRankingData[iso3A];
        final valB = _currentRankingData[iso3B];

        // どちらもデータがない場合は、名前順で並べます
        if (valA == null && valB == null) {
          final nameA = a['name_ja']?.toString() ?? '';
          final nameB = b['name_ja']?.toString() ?? '';
          return nameA.compareTo(nameB);
        }

        // データがない国は、リストの最後（下）に移動させます
        if (valA == null) return 1;
        if (valB == null) return -1;

        // 数値が大きい順（降順）に並べ替えます
        return (valB as num).compareTo(valA as num);
      }
    });
  }

  // リストの左側に表示する「順位（またはハイフン）」を決定する関数です
  String _getRankString(int index, Map<String, dynamic> country) {
    if (_currentSort == SortType.alphabetical) {
      return '${index + 1}'; // あいうえお順なら全員に番号を振ります
    } else {
      final iso3 = country['iso3'];
      final val = _currentRankingData[iso3];
      // ランキングデータが存在しない場合はハイフンを返します
      if (val == null) {
        return '-';
      }
      return '${index + 1}';
    }
  }

  // リストの下段に表示する「テキスト（人口などの数値）」を作成する関数です
  String _getSubtitleText(Map<String, dynamic> country) {
    if (_currentSort == SortType.alphabetical) {
      return country['name_en'] ?? '';
    }

    final iso3 = country['iso3'];
    final val = _currentRankingData[iso3];

    if (val == null) return 'データなし';

    if (_currentSort == SortType.population) {
      return '人口: ${FormatUtils.formatNumber(val)}人';
    } else if (_currentSort == SortType.area) {
      return '面積: ${FormatUtils.formatNumber(val)} km²';
    } else if (_currentSort == SortType.gdp) {
      return 'GDP: ${FormatUtils.formatMoney(val)}';
    }

    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text('国の一覧', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<SortType>(
            icon: const Icon(Icons.sort, color: Colors.black87),
            onSelected: (SortType result) {
              // 選択されたらデータを再読み込みします
              _loadData(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortType>>[
              const PopupMenuItem<SortType>(
                  value: SortType.alphabetical, child: Text('あいうえお順')),
              const PopupMenuItem<SortType>(
                  value: SortType.population, child: Text('人口順')),
              const PopupMenuItem<SortType>(
                  value: SortType.area, child: Text('面積順')),
              const PopupMenuItem<SortType>(
                  value: SortType.gdp, child: Text('GDP順')),
            ],
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

                final rankStr = _getRankString(index, country);
                final subtitleStr = _getSubtitleText(country);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 順位またはハイフンの表示
                        SizedBox(
                          width: 30, // 桁数が増えてもズレないように幅を固定します
                          child: Text(
                            rankStr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              // ハイフンの場合は色を薄くします
                              color: rankStr == '-'
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade700,
                            ),
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
                              placeholderBuilder: (_) =>
                                  Container(color: Colors.grey.shade200),
                            ),
                          ),
                        ),
                      ],
                    ),
                    title: Text(nameJa,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(subtitleStr),
                    trailing:
                        const Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CountryDetailScreen(iso2: iso2, nameJa: nameJa),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
