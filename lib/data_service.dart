import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// アプリのデータの読み書き（保存と取得）を全て担当する裏方のクラスです。
class DataService {
  static const String _cacheCompletedKey = 'cache_completed'; // ダウンロード完了の証
  static const String _favoritesKey = 'favorites_list'; // お気に入りを保存するキー

  // ダウンロードが完了しているかを確認する処理です。
  static Future<bool> isCacheCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_cacheCompletedKey) ?? false;
    } catch (e) {
      return false;
    }
  }

  // アプリを初期化する（キャッシュをすべて削除する）処理です。
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 全削除する前に、大切なお気に入りリストだけ一時的に避難させます。
      final List<String> savedFavorites =
          prefs.getStringList(_favoritesKey) ?? [];

      await prefs.clear(); // 全データを消去

      // 避難させておいたお気に入りを元に戻します。
      await prefs.setStringList(_favoritesKey, savedFavorites);
    } catch (e) {
      debugPrint('キャッシュの削除中にエラーが発生しました: $e');
    }
  }

  // お気に入りの国コードのリストを取得します。
  static Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      throw Exception('お気に入りデータの読み込みに失敗しました');
    }
  }

  // お気に入りをON/OFF切り替える処理です。
  static Future<bool> toggleFavorite(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favs = prefs.getStringList(_favoritesKey) ?? [];
      bool isNowFavorite = false;

      if (favs.contains(iso2)) {
        favs.remove(iso2); // 既にあれば外す
      } else {
        favs.add(iso2); // なければ入れる
        isNowFavorite = true;
      }

      await prefs.setStringList(_favoritesKey, favs);
      return isNowFavorite;
    } catch (e) {
      throw Exception('お気に入りの切り替えに失敗しました');
    }
  }

  // 特定の国がお気に入りかどうかを判定します。
  static Future<bool> isFavorite(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> favs = prefs.getStringList(_favoritesKey) ?? [];
      return favs.contains(iso2);
    } catch (e) {
      return false;
    }
  }

  // JSONファイルからマスターデータを読み込む処理です。
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

  // JSONファイルから特定の国の詳細データ（RestCountry）を読み込みます。
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

  // JSONファイルから特定の国のWikipediaデータを読み込みます。
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

  // ランキングデータを読み込みます。
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

  // 初回起動時にすべてのJSONデータをスマホに保存（キャッシュ）する大掛かりな処理です。
  static Future<void> downloadAndCacheAllData(
    Function(double) onProgress,
    bool Function() shouldStop,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String masterJson =
          await rootBundle.loadString('assets/json/country_master.json');
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

      // すべての国を順番に処理していきます。
      for (var country in masterList) {
        if (shouldStop()) return;

        // 国ごとの処理全体を try-catch で囲むことで、何かの国のデータが壊れていても
        // アプリ全体が止まってしまうのを防ぎます（最強の防御です）。
        try {
          final String iso2 = country['iso2'];
          final bool isAlreadyCached = prefs.containsKey('rest_$iso2') &&
              prefs.containsKey('wiki_$iso2');

          if (isAlreadyCached) {
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

          await Future.delayed(
              const Duration(milliseconds: 10)); // 少し休んでスマホへの負荷を和らげます
        } catch (e) {
          debugPrint('予期せぬエラーでスキップしました: $e');
          continue;
        } finally {
          // エラーが起きても起きなくても、確実にカウントを増やしてプログレスバーを進めます。
          processedCount++;
          onProgress(processedCount / totalCountries);
        }
      }

      // 全て終わったら「完了の証」を保存します。
      await prefs.setBool(_cacheCompletedKey, true);
    } catch (e) {
      throw Exception('ダウンロードに失敗しました: $e');
    }
  }
}
