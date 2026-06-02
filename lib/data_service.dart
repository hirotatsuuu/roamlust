import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'; // debugPrintを使うために追加
import 'package:shared_preferences/shared_preferences.dart';

class DataService {
  // キャッシュが完了しているかを判定するためのキー（合言葉）です
  static const String _cacheCompletedKey = 'cache_completed';

  // ダウンロード（キャッシュ構築）が完了しているかを確認する関数です
  static Future<bool> isCacheCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 保存されているブール値（true または false）を返します。無い場合はfalseを返します。
      return prefs.getBool(_cacheCompletedKey) ?? false;
    } catch (e) {
      // エラーが起きた場合は安全のために未完了(false)として扱います
      return false;
    }
  }

  // キャッシュをすべて削除し、未完了状態に戻す関数です
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // SharedPreferencesに保存されている全データを消去します
      await prefs.clear();
    } catch (e) {
      // 例外が発生した場合の処理（アプリのクラッシュを防ぎます）
      debugPrint('キャッシュの削除中にエラーが発生しました: $e');
    }
  }

  // マスターデータを取得する関数です。キャッシュがあればそこから、なければ空を返します。
  static Future<List<dynamic>> loadMasterData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('master_data');
      if (cachedData != null) {
        // キャッシュに保存された文字列をJSONとして解析して返します
        return jsonDecode(cachedData);
      }
      return [];
    } catch (e) {
      debugPrint('マスターデータの読み込み中にエラーが発生しました: $e');
      return [];
    }
  }

  // 特定の国のRestCountriesデータを読み込みます（キャッシュから取得）
  static Future<Map<String, dynamic>?> loadRestCountry(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('rest_$iso2');
      if (cachedData != null) {
        return jsonDecode(cachedData);
      }
      return null;
    } catch (e) {
      debugPrint('$iso2 の詳細データの読み込みに失敗しました: $e');
      return null;
    }
  }

  // 特定の国のWikipediaデータを読み込みます（キャッシュから取得）
  static Future<Map<String, dynamic>?> loadWikipedia(String iso2) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('wiki_$iso2');
      if (cachedData != null) {
        return jsonDecode(cachedData);
      }
      return null;
    } catch (e) {
      debugPrint('$iso2 のWikipediaデータの読み込みに失敗しました: $e');
      return null;
    }
  }

  // 指定された名前のランキングファイルを読み込みます（キャッシュから取得）
  static Future<Map<String, dynamic>> loadRanking(String rankingName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString('rank_$rankingName');
      if (cachedData != null) {
        return jsonDecode(cachedData);
      }
      return {};
    } catch (e) {
      debugPrint('$rankingName のランキングデータの読み込みに失敗しました: $e');
      // ファイルが存在しない、またはエラーの場合は空のデータを返します
      return {};
    }
  }

  // --- 以下は初期化（ダウンロード）用の特別な関数群です ---

  // アセットからデータを読み込み、SharedPreferencesに保存する処理（ダウンロードの代わり）
  // onProgress: 進捗率（0.0 〜 1.0）を画面に伝えるための関数
  // shouldStop: ユーザーが中断ボタンを押したかを確認するための関数
  static Future<void> downloadAndCacheAllData(
    Function(double) onProgress,
    bool Function() shouldStop,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. マスターデータの読み込みと保存
      final String masterJson =
          await rootBundle.loadString('assets/json/countries_master.json');
      await prefs.setString('master_data', masterJson);
      final List<dynamic> masterList = jsonDecode(masterJson);

      // 2. ランキングデータの読み込みと保存
      final List<String> rankings = ['population', 'area', 'gdp'];
      for (String rank in rankings) {
        try {
          final String rankJson =
              await rootBundle.loadString('assets/json/rankings/$rank.json');
          await prefs.setString('rank_$rank', rankJson);
        } catch (e) {
          // 該当するランキングファイルが無い場合はスキップします
          debugPrint('ランキング $rank のファイルが見つかりませんでした');
        }
      }

      // 進捗計算の準備（全ファイル数 = 国の数 * 2）
      final int totalCountries = masterList.length;
      int processedCount = 0;

      // 3. 各国のデータを読み込んで保存
      for (var country in masterList) {
        // 中断判定：画面側から「止めて」と言われたらループを抜けます
        if (shouldStop()) {
          debugPrint('ダウンロードが中断されました。');
          return;
        }

        final String iso2 = country['iso2'];

        // RestCountriesデータの処理
        try {
          final String restJson = await rootBundle
              .loadString('assets/json/restcountries/$iso2.json');
          await prefs.setString('rest_$iso2', restJson);
        } catch (e) {
          debugPrint('RestCountryデータが見つかりません: $iso2');
        }

        // Wikipediaデータの処理
        try {
          final String wikiJson =
              await rootBundle.loadString('assets/json/wikipedia/$iso2.json');
          await prefs.setString('wiki_$iso2', wikiJson);
        } catch (e) {
          debugPrint('Wikipediaデータが見つかりません: $iso2');
        }

        // 処理が終わった分だけカウントを増やし、進捗率を計算して画面に伝えます
        processedCount++;
        double progress = processedCount / totalCountries;
        onProgress(progress);

        // 少しだけ待機を入れることで、画面の描画（くるくるやパーセントの更新）をスムーズにします
        await Future.delayed(const Duration(milliseconds: 10));
      }

      // 全て完了したら、完了フラグを保存します
      await prefs.setBool(_cacheCompletedKey, true);
    } catch (e) {
      // 予期せぬエラーが発生した場合の例外処理
      throw Exception('データのダウンロード（キャッシュ構築）に失敗しました: $e');
    }
  }
}
