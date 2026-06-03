import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';

// 世界の国を「地域（region）」ごとにグループ分けして表示する画面です。
class RegionListScreen extends StatefulWidget {
  const RegionListScreen({super.key});

  @override
  State<RegionListScreen> createState() => _RegionListScreenState();
}

class _RegionListScreenState extends State<RegionListScreen> {
  // 地域名（Asiaなど）をキーにして、その地域に属する国のリストを値として持つ辞書（Map）を作ります。
  Map<String, List<Map<String, dynamic>>> _groupedCountries = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroupedData();
  }

  // マスターデータと詳細データを組み合わせて、地域ごとに振り分ける処理です。
  Future<void> _loadGroupedData() async {
    try {
      final master = await DataService.loadMasterData();
      Map<String, List<Map<String, dynamic>>> grouped = {};

      // すべての国の情報を一つずつ確認していきます。
      for (var country in master) {
        final iso2 = country['iso2'];
        // 地域情報（region）は詳細データ（RestCountry）の中に入っているため、都度読み込みます。
        final restData = await DataService.loadRestCountry(iso2);

        // もし地域情報が見つからなければ「その他 (Other)」に振り分けます。
        final String region = restData?['region']?.toString() ?? 'Other';

        // 辞書の中にまだその地域の箱がなければ作ります。
        if (!grouped.containsKey(region)) {
          grouped[region] = [];
        }

        // 振り分け用のデータ（国名とコードだけ）を作って箱に入れます。
        grouped[region]!.add({
          'iso2': iso2,
          'name_ja': country['name_ja'],
        });
      }

      // 各地域の中の国々を、見やすいようにあいうえお順に並び替えます。
      grouped.forEach((key, list) {
        list.sort((a, b) {
          final nameA = a['name_ja']?.toString() ?? '';
          final nameB = b['name_ja']?.toString() ?? '';
          return nameA.compareTo(nameB);
        });
      });

      setState(() {
        _groupedCountries = grouped;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('読み込みエラー: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  // 英語の地域名を「日本語 (英語)」の形に変換する便利な関数です。
  String _translateRegion(String regionEn) {
    switch (regionEn) {
      case 'Asia':
        return 'アジア (Asia)';
      case 'Europe':
        return 'ヨーロッパ (Europe)';
      case 'Africa':
        return 'アフリカ (Africa)';
      case 'Americas':
        return 'アメリカ (Americas)';
      case 'Oceania':
        return 'オセアニア (Oceania)';
      case 'Antarctic':
        return '南極 (Antarctic)';
      case 'Other':
        return 'その他 (Other)';
      default:
        return '$regionEn (Other)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('地域別', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          // ListView.builderで、地域（Asia, Europeなど）の数だけリストを作ります。
          : ListView.builder(
              itemCount: _groupedCountries.keys.length,
              itemBuilder: (context, index) {
                // 地域名を一つ取り出します（例: 'Asia'）
                final regionName = _groupedCountries.keys.elementAt(index);
                // その地域に属する国のリストを取り出します
                final countries = _groupedCountries[regionName]!;

                // ExpansionTileを使うと、タップして「アコーディオンのようにパカッと開く」メニューが作れます。
                return ExpansionTile(
                  title: Text(
                    // 翻訳関数を通してから表示します
                    '${_translateRegion(regionName)} (${countries.length} か国)',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // パカッと開いた中身（children）に、所属する国をすべて並べます。
                  children: countries.map((country) {
                    final iso2 = country['iso2'];
                    final nameJa = country['name_ja']?.toString() ?? '不明な国';

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 0),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min, // 必要な幅だけを占有します
                        children: [
                          // SVG画像の読み込みエラーを防ぎ、きれいに表示するための枠を作ります
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: SizedBox(
                              width: 45, // 一覧画面と同じ幅に合わせました
                              height: 30, // 一覧画面と同じ高さに合わせました
                              child: SvgPicture.asset(
                                'assets/flags/${iso2.toLowerCase()}.svg',
                                fit: BoxFit.cover,
                                // 画像の読み込み中や、エラーが起きたときの代わりの表示（グレーの箱）です
                                placeholderBuilder: (_) => Container(
                                    color: isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade200),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // 長い国名でも見切れないように、少し文字を小さくして表示します。
                      title: Text(nameJa, style: const TextStyle(fontSize: 14)),
                      trailing: const Icon(Icons.chevron_right,
                          size: 16, color: Colors.grey),
                      // タップすると詳細画面へ移動します。
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CountryDetailScreen(
                                  iso2: iso2, nameJa: nameJa)),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
