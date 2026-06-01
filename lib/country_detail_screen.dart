import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';

class CountryDetailScreen extends StatelessWidget {
  // 遷移元の画面から国コード(iso2)と日本語名を受け取ります
  final String iso2;
  final String nameJa;

  const CountryDetailScreen({
    super.key,
    required this.iso2,
    required this.nameJa,
  });

  // WikipediaとRestCountriesのデータを同時に取得する関数です
  Future<Map<String, dynamic>> loadDetails() async {
    final restData = await DataService.loadRestCountry(iso2);
    final wikiData = await DataService.loadWikipedia(iso2);

    // 取得した2つのデータを辞書形式にまとめて返します
    return {
      'rest': restData,
      'wiki': wikiData,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(nameJa),
      ),
      // データの読み込みを待つための部品です
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadDetails(),
        builder: (context, snapshot) {
          // 読み込み中の表示
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 読み込みが完了した場合の処理
          final data = snapshot.data;
          final rest = data?['rest'];
          final wiki = data?['wiki'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 国旗の表示
                Center(
                  child: SvgPicture.asset(
                    'assets/flags/$iso2.svg',
                    height: 120,
                    // ファイルが見つからない場合はグレーの四角を表示します
                    placeholderBuilder: (context) => Container(
                      height: 120,
                      width: 180,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.flag, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 基本情報の表示 (RestCountriesのデータがある場合のみ)
                if (rest != null) ...[
                  const Text('基本情報',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ListTile(
                    title: const Text('首都'),
                    subtitle: Text(rest['capital']?[0] ?? '不明'),
                  ),
                  ListTile(
                    title: const Text('地域'),
                    subtitle: Text('${rest['region']} / ${rest['subregion']}'),
                  ),
                  ListTile(
                    title: const Text('人口'),
                    subtitle:
                        Text('${rest['population']?.toString() ?? '不明'} 人'),
                  ),
                  const SizedBox(height: 24),
                ],

                // Wikipediaの表示 (Wikipediaのデータがある場合のみ)
                if (wiki != null && wiki['article'] != null) ...[
                  const Text('Wikipedia概要',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text(
                    wiki['article'],
                    style: const TextStyle(height: 1.6, fontSize: 16),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
