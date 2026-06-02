import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';
import 'format_utils.dart';

class CountryDetailScreen extends StatelessWidget {
  final String iso2;
  final String nameJa;

  const CountryDetailScreen({
    super.key,
    required this.iso2,
    required this.nameJa,
  });

  Future<Map<String, dynamic>> loadDetails() async {
    // 例外処理はDataService側で行っているため、ここでは単に待ち受けます
    final restData = await DataService.loadRestCountry(iso2);
    final wikiData = await DataService.loadWikipedia(iso2);
    return {'rest': restData, 'wiki': wikiData};
  }

  // 複雑なJSONの中から、カンマ区切りで言語名などを取り出す便利関数です
  String _extractMapValues(Map<String, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return 'データなし';
    }
    return data.values.join(', ');
  }

  // 通貨情報を取り出す専用関数です
  String _extractCurrency(Map<String, dynamic>? currencies) {
    if (currencies == null || currencies.isEmpty) {
      return 'データなし';
    }
    final firstKey = currencies.keys.first;
    final currency = currencies[firstKey];
    final name = currency['name'] ?? '';
    final symbol = currency['symbol'] ?? '';
    return '$firstKey - $name ($symbol)';
  }

  @override
  Widget build(BuildContext context) {
    // ダークモードかどうかを判定します
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(nameJa, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadDetails(),
        builder: (context, snapshot) {
          // エラーが発生した場合の例外処理表示
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
                // 国旗
                Center(
                  child: Hero(
                    tag: 'flag_$iso2',
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            // ダークモード時は影の色を調整します
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
                          'assets/flags/$iso2.svg',
                          height: 140,
                          placeholderBuilder: (_) => Container(
                            height: 140,
                            width: 210,
                            color: isDark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // セクションごとにカードで整理します
                _buildSectionTitle('基本情報', Icons.badge, isDark, context),
                _buildInfoCard([
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

                if (wiki != null && wiki['article'] != null) ...[
                  _buildSectionTitle(
                      '概要 (Wikipedia)', Icons.menu_book, isDark, context),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        wiki['article'],
                        style: TextStyle(
                            height: 1.8,
                            fontSize: 15,
                            color:
                                isDark ? Colors.grey.shade300 : Colors.black87),
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

  // --- 見た目を整えるための部品化（ヘルパーメソッド） ---

  // 見出しを作る部品（引数にisDarkとcontextを追加）
  Widget _buildSectionTitle(
      String title, IconData icon, bool isDark, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 16.0),
      child: Row(
        children: [
          Icon(icon,
              color: isDark
                  ? Theme.of(context).colorScheme.primary
                  : Colors.blue.shade700,
              size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                // ダークモード対応の色
                color: isDark ? Colors.white : Colors.black87),
          ),
        ],
      ),
    );
  }

  // 情報をまとめるカードの部品（引数にcontextを追加）
  Widget _buildInfoCard(List<Widget> children, BuildContext context) {
    return Card(
      // main.dartで一括設定したデザインが適用されます
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: children),
      ),
    );
  }

  // 1行分の「項目名：値」を作る部品（引数にisDarkを追加）
  Widget _buildRow(String label, dynamic value, bool isDark) {
    final textValue = value?.toString() ?? '情報なし';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                  // ダークモード時は文字色を明るめにします
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              textValue,
              style: TextStyle(
                  fontSize: 15,
                  color: isDark ? Colors.grey.shade200 : Colors.black87,
                  height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
