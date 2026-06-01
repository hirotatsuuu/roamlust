import 'dart:convert';
import 'package:flutter/services.dart';

class DataService {
  // すべての国データ（マスターデータ）を読み込みます
  static Future<List<dynamic>> loadMasterData() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/countries_master.json');
      return jsonDecode(jsonString);
    } catch (e) {
      return [];
    }
  }

  // 特定の国のRestCountriesデータを読み込みます
  static Future<Map<String, dynamic>?> loadRestCountry(String iso2) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/restcountries/$iso2.json');
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // 特定の国のWikipediaデータを読み込みます
  static Future<Map<String, dynamic>?> loadWikipedia(String iso2) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/wikipedia/$iso2.json');
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // 指定された名前のランキングファイル（例: 'population'）を読み込みます
  static Future<Map<String, dynamic>> loadRanking(String rankingName) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/rankings/$rankingName.json');
      return jsonDecode(jsonString);
    } catch (e) {
      // ファイルが存在しない場合は空のデータを返します
      return {};
    }
  }
}
