import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  static const String _cacheCompletedKey = 'cache_completed';
  static const String _favoritesKey = 'favorites_list'; // お気に入りを保存するキー

  // ダウンロードが完了しているかを確認する関数
  static Future<bool> isCacheCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cacheCompletedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // キャッシュをすべて削除します（★お気に入りは保護します）
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 削除前にお気に入りのリストだけ避難させます
      final List<String> savedFavorites =
          prefs.getStringList(_favoritesKey) ?? [];

      await prefs.clear(); // 全データを消去

      // 避難させておいたお気に入りを元に戻します（消えない設計）
      await prefs.setStringList(_favoritesKey, savedFavorites);
    } catch (e) {
      debugPrint('キャッシュの削除中にエラーが発生しました: $e');
    }
  }

  // --- お気に入り専用の関数群 ---

  // お気に入りのリスト（国コードの配列）を取得します
  static Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      // エラーを投げて、画面側で「消えた」ことを通知できるようにします
      throw Exception('お気に入りデータの読み込みに失敗しました');
    }
  }

  // お気に入りをON/OFF切り替える関数です（現在の状態を返します）
  static Future<bool> toggleFavorite(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favs = prefs.getStringList(_favoritesKey) ?? [];
      bool isNowFavorite = false;

      if (favs.contains(iso2)) {
        favs.remove(iso2); // あれば削除（OFF）
      } else {
        favs.add(iso2); // なければ追加（ON）
        isNowFavorite = true;
      }

      await prefs.setStringList(_favoritesKey, favs);
      return isNowFavorite;
    } catch (e) {
      throw Exception('お気に入りの切り替えに失敗しました');
    }
  }

  // 特定の国がお気に入りかどうかを判定します
  static Future<bool> isFavorite(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favs = prefs.getStringList(_favoritesKey) ?? [];
      return favs.contains(iso2);
    } catch (e) {
      return false;
    }
  }

  // --- データ読み込み用の関数群 ---

  static Future<List<dynamic>> loadMasterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('master_data');
      if (cachedData != null) return jsonDecode(cachedData);
      return [];
    } catch (e) {
      debugPrint('マスターデータの読み込みエラー: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> loadRestCountry(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('rest_$iso2');
      if (cachedData != null) return jsonDecode(cachedData);
      return null;
    } catch (e) {
      debugPrint('$iso2 の詳細データ読み込みエラー: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> loadWikipedia(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('wiki_$iso2');
      if (cachedData != null) return jsonDecode(cachedData);
      return null;
    } catch (e) {
      debugPrint('$iso2 のWikipedia読み込みエラー: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> loadRanking(String rankingName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('rank_$rankingName');
      if (cachedData != null) return jsonDecode(cachedData);
      return {};
    } catch (e) {
      return {};
    }
  }

  // 初期化用の関数（ダウンロード）
  static Future<void> downloadAndCacheAllData(
    Function(double) onProgress,
    bool Function() shouldStop,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String masterJson =
          await rootBundle.loadString('assets/json/countries_master.json');
      await prefs.setString('master_data', masterJson);
      final List<dynamic> masterList = jsonDecode(masterJson);

      final List<String> rankings = ['population', 'area', 'gdp'];
      for (String rank in rankings) {
        try {
          final String rankJson =
              await rootBundle.loadString('assets/json/rankings/$rank.json');
          await prefs.setString('rank_$rank', rankJson);
        } catch (e) {
          debugPrint('ランキング $rank ファイルなし');
        }
      }

      final int totalCountries = masterList.length;
      int processedCount = 0;

      for (var country in masterList) {
        if (shouldStop()) return;

        final String iso2 = country['iso2'];
        final bool isAlreadyCached =
            prefs.containsKey('rest_$iso2') && prefs.containsKey('wiki_$iso2');

        if (isAlreadyCached) {
          processedCount++;
          onProgress(processedCount / totalCountries);
          if (processedCount % 10 == 0) await Future.delayed(Duration.zero);
          continue;
        }

        try {
          final String restJson = await rootBundle
              .loadString('assets/json/restcountries/$iso2.json');
          await prefs.setString('rest_$iso2', restJson);
        } catch (e) {
          debugPrint('RestCountryなし: $iso2');
        }

        try {
          final String wikiJson =
              await rootBundle.loadString('assets/json/wikipedia/$iso2.json');
          await prefs.setString('wiki_$iso2', wikiJson);
        } catch (e) {
          debugPrint('Wikipediaなし: $iso2');
        }

        processedCount++;
        onProgress(processedCount / totalCountries);
        await Future.delayed(const Duration(milliseconds: 10));
      }

      await prefs.setBool(_cacheCompletedKey, true);
    } catch (e) {
      throw Exception('ダウンロードに失敗しました: $e');
    }
  }
}
