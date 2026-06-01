import 'dart:convert';
import 'package:flutter/services.dart';

class DataService {
  // すべての国データ（マスターデータ）を読み込む関数です
  static Future<List<dynamic>> loadMasterData() async {
    try {
      // ファイルを文字列として読み込みます
      final String jsonString =
          await rootBundle.loadString('assets/json/countries_master.json');
      // 文字列をプログラムで扱えるリスト形式に変換して返します
      return jsonDecode(jsonString);
    } catch (e) {
      // 万が一読み込めなかった場合は空のリストを返します
      return [];
    }
  }

  // 特定の国のRestCountriesデータを読み込む関数です
  static Future<Map<String, dynamic>?> loadRestCountry(String iso2) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/restcountries/$iso2.json');
      return jsonDecode(jsonString);
    } catch (e) {
      // ファイルが存在しないなどのエラー時は、何も返しません（null）
      return null;
    }
  }

  // 特定の国のWikipediaデータを読み込む関数です
  static Future<Map<String, dynamic>?> loadWikipedia(String iso2) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/json/wikipedia/$iso2.json');
      return jsonDecode(jsonString);
    } catch (e) {
      // Wikipediaのデータがない国もあるため、その場合はnullを返します
      return null;
    }
  }
}
