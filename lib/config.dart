// lib/config.dart
class Config {
  // アプリの名前とサブタイトルです
  static const String appTitle = 'Roamlust';
  static const String appSubtitle = 'Roam (放浪する) + Lust (強い欲求)';

  // 外部サイトのURLです
  static const String wikipediaUrl = 'https://ja.wikipedia.org/';
  static const String restCountriesUrl = 'https://restcountries.com/';

  // Googleフォームへデータを送信するための設定です
  static const String googleFormPostUrl =
      'https://docs.google.com/forms/d/e/あなたのフォームID/formResponse';
  static const String formEntryName = 'entry.123456789';
  static const String formEntryEmail = 'entry.987654321';
  static const String formEntryBody = 'entry.111111111';

  // ★新規追加: 製作者の声をここに切り出しました
  static const String creatorVoice =
      '「Roamlust（放浪する強い欲求）」という名前には、単なるデータ検索ではなく、見知らぬ国への好奇心を掻き立てるアプリにしたいという思いを込めました。私たちが暮らす世界には、数え切れないほどの文化や歴史、壮大な自然が存在していますが、その多くは日常の中で意識されることはありません。\n\nこのアプリを通じて、ふとした瞬間に遠く離れた国の名前を検索し、まだ見ぬ景色に思いを馳せるきっかけを作れたら嬉しいです。国旗のデザイン、人口の規模、そして歴史の1ページ。それらの情報が、あなたの日常に少しでも「旅のワクワク感」を届けてくれることを心から願っています。';
}
