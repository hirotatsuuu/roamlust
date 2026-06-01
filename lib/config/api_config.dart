/// 【API設定ファイル】
/// アプリ内で使用する外部通信（API）のURLをまとめて管理する場所です。
class ApiConfig {
  // REST Countries API のURL（世界の基本情報をJSON形式で取得）
  static const String restCountriesUrl = 'https://restcountries.com/v3.1/all';

  // 外務省 海外安全情報のURL（危険度情報をXML形式で取得）
  static const String mofaWarningUrl =
      'https://www.ezairyu.mofa.go.jp/opendata/warning.xml';
}
