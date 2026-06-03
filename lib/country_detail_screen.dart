import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'data_service.dart';
import 'format_utils.dart';

// 選択された国のすべての情報を表示する画面です。
class CountryDetailScreen extends StatefulWidget {
  final String iso2; // 国のコード（例: JP）
  final String nameJa; // 日本語の国名

  const CountryDetailScreen({
    super.key,
    required this.iso2,
    required this.nameJa,
  });

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  // この国がすでにお気に入りに登録されているかチェックします。
  Future<void> _checkFavorite() async {
    final isFav = await DataService.isFavorite(widget.iso2);
    setState(() {
      _isFavorite = isFav;
    });
  }

  // ヘッダーのハートを押したときの処理です。
  Future<void> _toggleFavorite() async {
    try {
      final isNowFav = await DataService.toggleFavorite(widget.iso2);
      setState(() {
        _isFavorite = isNowFav;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(isNowFav ? 'お気に入りに追加しました' : 'お気に入りから削除しました'),
              duration: const Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('お気に入りの操作に失敗しました')));
      }
    }
  }

  // 渡されたURL（文字列）を、スマホの標準ブラウザ（SafariやChromeなど）で開く処理です。
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      // 外部アプリとして開くように指定します。
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('リンクを開けませんでした')));
      }
    }
  }

  // 英語の曜日データを日本語に翻訳する処理です。
  String _translateDay(String? day) {
    switch (day?.toLowerCase()) {
      case 'monday':
        return '月曜日';
      case 'tuesday':
        return '火曜日';
      case 'wednesday':
        return '水曜日';
      case 'thursday':
        return '木曜日';
      case 'friday':
        return '金曜日';
      case 'saturday':
        return '土曜日';
      case 'sunday':
        return '日曜日';
      default:
        return '情報なし';
    }
  }

  // 2つの異なるデータ（RestCountryとWikipedia）を同時に読み込む処理です。
  Future<Map<String, dynamic>> loadDetails() async {
    final restData = await DataService.loadRestCountry(widget.iso2);
    final wikiData = await DataService.loadWikipedia(widget.iso2);
    return {'rest': restData, 'wiki': wikiData};
  }

  // 辞書データの中から値だけを取り出してカンマ区切りの文字列にする処理です（言語などに使用）。
  String _extractMapValues(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) return 'データなし';
    return data.values.join(', ');
  }

  // 通貨データを見やすく整形する処理です。
  String _extractCurrency(Map<String, dynamic>? currencies) {
    if (currencies == null || currencies.isEmpty) return 'データなし';
    final firstKey = currencies.keys.first;
    final currency = currencies[firstKey];
    final name = currency['name'] ?? '';
    final symbol = currency['symbol'] ?? '';
    return '$firstKey - $name ($symbol)';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('詳細情報', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite
                  ? Colors.pink.shade100
                  : (isDark ? Colors.white : Colors.black87),
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      // FutureBuilderは、非同期処理（データの読み込み）が終わるまで待機し、終わったら画面を描画する便利な仕組みです。
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadDetails(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('データの読み込み中にエラーが発生しました。\n${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rest = snapshot.data?['rest'];
          final wiki = snapshot.data?['wiki'];

          if (rest == null) {
            return const Center(child: Text('詳細データが見つかりませんでした'));
          }

          return SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('国旗', Icons.flag, isDark, context),
                const SizedBox(height: 12),
                Center(
                  // Heroアニメーションを使って、リスト画面から滑らかに画像が飛んでくるようにします。
                  child: Hero(
                    tag: 'flag_${widget.iso2}',
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SvgPicture.asset(
                          'assets/flags/${widget.iso2.toLowerCase()}.svg',
                          height: 140,
                          placeholderBuilder: (_) => Container(
                              height: 140,
                              width: 210,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _buildSectionTitle('基本情報', Icons.badge, isDark, context),
                _buildInfoCard([
                  _buildRow('国名 (日本語)', widget.nameJa, isDark),
                  _buildRow('正式名称', rest['name']?['official'], isDark),
                  _buildRow('通称', rest['name']?['common'], isDark),
                  _buildRow(
                      'コード',
                      'cca2: ${rest['cca2']} / cca3: ${rest['cca3']} / ccn3: ${rest['ccn3']}',
                      isDark),
                ], context),

                _buildSectionTitle('地理・位置情報', Icons.public, isDark, context),
                _buildInfoCard([
                  _buildRow(
                      '首都', (rest['capital'] as List?)?.join(', '), isDark),
                  _buildRow(
                      '地域',
                      '${rest['continents']?[0]} > ${rest['region']} > ${rest['subregion']}',
                      isDark),
                  _buildRow('面積',
                      '${FormatUtils.formatNumber(rest['area'])} km²', isDark),
                  _buildRow(
                      '緯度・経度', (rest['latlng'] as List?)?.join(', '), isDark),
                  _buildRow(
                      '隣接国',
                      (rest['borders'] as List?)?.join(', ') ?? '島国・陸続きなし',
                      isDark),
                  _buildLinkRow('地図', rest['maps']?['googleMaps'],
                      'Google Mapsを開く', isDark),
                ], context),

                _buildSectionTitle('社会・人口情報', Icons.people, isDark, context),
                _buildInfoCard([
                  _buildRow(
                      '人口',
                      '${FormatUtils.formatNumber(rest['population'])} 人',
                      isDark),
                  _buildRow('住民の呼称', rest['demonyms']?['eng']?['m'], isDark),
                  _buildRow('独立状況',
                      rest['independent'] == true ? '独立国' : '非独立領域', isDark),
                  _buildRow(
                      '国連加盟', rest['unMember'] == true ? '加盟' : '非加盟', isDark),
                ], context),

                _buildSectionTitle(
                    '経済・文化・インフラ', Icons.account_balance, isDark, context),
                _buildInfoCard([
                  _buildRow('通貨', _extractCurrency(rest['currencies']), isDark),
                  _buildRow('言語', _extractMapValues(rest['languages']), isDark),
                  _buildRow(
                      '週の始まり', _translateDay(rest['startOfWeek']), isDark),
                  _buildRow(
                      'ドメイン (TLD)', (rest['tld'] as List?)?.join(', '), isDark),
                  _buildRow('タイムゾーン', (rest['timezones'] as List?)?.join(', '),
                      isDark),
                  _buildRow(
                      '電話番号',
                      '${rest['idd']?['root']}${rest['idd']?['suffixes']?[0] ?? ''}',
                      isDark),
                  _buildRow(
                      '自動車通行帯',
                      rest['car']?['side'] == 'right' ? '右側通行' : '左側通行',
                      isDark),
                  if (rest['gini'] != null)
                    _buildRow(
                        'ジニ係数', rest['gini'].values.first.toString(), isDark),
                ], context),

                // Wikipediaの情報が存在する場合のみ表示します。
                if (wiki != null && wiki['article'] != null) ...[
                  _buildSectionTitle(
                      '概要 (Wikipedia)', Icons.menu_book, isDark, context),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '本文の文字数: ${FormatUtils.formatNumber(wiki['article_length'] ?? 0)} 文字',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            wiki['article'],
                            style: TextStyle(
                                height: 1.8,
                                fontSize: 15,
                                color: isDark
                                    ? Colors.grey.shade300
                                    : Colors.black87),
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 8),
                          // InkWellを使うと、タップしたときに波紋のようなアニメーションを出せます。
                          InkWell(
                            onTap: () => _launchURL(wiki['url']),
                            child: Row(
                              children: [
                                Icon(Icons.open_in_browser,
                                    size: 18,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 8),
                                Text(
                                  'Wikipediaのサイトで続きを読む',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // 見出しを作るための共通部品（関数）です。
  Widget _buildSectionTitle(
      String title, IconData icon, bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
      child: Row(
        children: [
          Icon(icon,
              color: isDark
                  ? Theme.of(context).colorScheme.primary
                  : Colors.lightGreen.shade700,
              size: 22),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87)),
        ],
      ),
    );
  }

  // 情報をまとめるカードを作るための共通部品です。
  Widget _buildInfoCard(List<Widget> children, BuildContext context) {
    return Card(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(children: children)),
    );
  }

  // カードの中の「ラベル: 値」の1行分を作る共通部品です。
  Widget _buildRow(String label, dynamic value, bool isDark) {
    final textValue = value?.toString() ?? '情報なし';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            // 右側の文字が長くなった場合、自動で折り返します。
            child: Text(textValue,
                style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.grey.shade200 : Colors.black87,
                    height: 1.4)),
          ),
        ],
      ),
    );
  }

  // Google Mapsのような、タップできるリンクの行を作る共通部品です。
  Widget _buildLinkRow(
      String label, String? url, String displayText, bool isDark) {
    if (url == null || url.isEmpty) return _buildRow(label, '情報なし', isDark);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontSize: 13,
                    fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: InkWell(
              onTap: () => _launchURL(url),
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
