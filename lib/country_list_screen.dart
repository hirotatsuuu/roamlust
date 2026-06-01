import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'data_service.dart';
import 'country_detail_screen.dart';

class CountryListScreen extends StatelessWidget {
  const CountryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('国の一覧'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: DataService.loadMasterData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final countries = snapshot.data ?? [];

          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              final iso2 = country['iso2'];
              final nameJa = country['name_ja'] ?? '不明';
              final nameEn = country['name_en'] ?? '';

              return ListTile(
                leading: SizedBox(
                  width: 40,
                  height: 30,
                  // リストの中に小さな国旗を表示します
                  child: SvgPicture.asset(
                    'assets/flags/$iso2.svg',
                    fit: BoxFit.cover,
                    placeholderBuilder: (_) => const Icon(Icons.flag),
                  ),
                ),
                title: Text(nameJa),
                subtitle: Text(nameEn),
                onTap: () {
                  // タップしたら詳細画面へ移動します
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CountryDetailScreen(iso2: iso2, nameJa: nameJa),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
