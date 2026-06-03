// lib/config.dart
class Config {
  // ===========================================================================
  // 1. アプリの基本情報 (main.dart, app_drawer.dart, initial_load_screen.dart 等)
  // ===========================================================================
  static const String appTitle = 'Roamlust';
  static const String appSubtitle = 'Roam (放浪する) + Lust (強い欲求)';
  static const String appOneWord =
      '日常を抜け出して、新しい世界へ'; // 旅に出たくなるような一言に変更しました by Gemini
  static const String appVersion = 'Version 1.0.0'; // about_screen.dart で使用

  // ===========================================================================
  // 2. 外部サイトのURL (about_screen.dart 等)
  // ===========================================================================
  static const String wikipediaUrl = 'https://ja.wikipedia.org/';
  static const String restCountriesUrl = 'https://restcountries.com/';
  static const String worldBankUrl = 'https://data.worldbank.org/';
  static const String worldHappinessUrl = 'https://www.worldhappiness.report';

  // ===========================================================================
  // 3. お問い合わせ関連 (support_screen.dart で使用)
  // ===========================================================================
  // ★ここにあなた自身のメールアドレスを設定してください（ユーザーからのメールの宛先になります）
  static const String supportEmail = 'otatsu1522@gmail.com';
  static const String supportSubject = 'Roamlust お問い合わせ'; // メールの件名

  // ===========================================================================
  // 4. ホーム画面のテキスト (home_screen.dart)
  // ===========================================================================
  static const String homeQuestion = 'あなたの次の目的地は、どこですか？';
  static const String homeSearchHint = '国名を入力 (例: 日本)';
  static const String homePoetry =
      'まだ見ぬ景色の記憶をたどり、\n僕らは果てしない旅路を夢見る。\n胸の奥に灯る小さな憧れは、\n未知なる世界へ飛び出すための確かな道標。\n地図の余白を埋めるのはあなた自身。\n\nさぁ、旅の準備を始めましょう。';
  static const String homeClosing = '世界は、あなたの最初の一歩を待っている。';

  // ===========================================================================
  // 5. ロード画面のテキスト (initial_load_screen.dart)
  // ===========================================================================
  static const String loadTitle = '世界の情報を集めています';
  static const String loadSubtitle = '初回のみ少し時間がかかります';
  static const String loadReady = 'ダウンロードの準備ができました';
  static const String loadPaused = 'ダウンロードが一時停止中です';
  static const String loadErrorMessage =
      '一部の国情報が取得できませんでしたが、\n取得できたデータでアプリを開始します。';

  // ===========================================================================
  // 6. メニュー（ドロワー）のテキスト (app_drawer.dart)
  // ===========================================================================
  static const String menuCountryList = '国一覧';
  static const String menuRegion = '地域別';
  static const String menuFavorite = 'お気に入り';
  static const String menuTheme = 'テーマ切り替え';
  static const String menuAbout = 'アプリについて';
  static const String menuSupport = 'お問い合わせ';
  static const String menuReset = 'データの初期化';

  // ===========================================================================
  // 7. このアプリについて (about_screen.dart)
  // ===========================================================================
  static const String aboutDataTitle = 'データ出典';
  static const String aboutDataDescription =
      '本アプリは、以下のオープンデータを利用して作成されています。各データの詳細は公式サイトをご確認ください。';
  static const String creatorVoiceTitle = '製作者の声';
  static const String creatorVoice =
      '「Roamlust（放浪する強い欲求）」という名前には、単なるデータ検索ではなく、見知らぬ国への好奇心を掻き立てるアプリにしたいという思いを込めました。私たちが暮らす世界には、数え切れないほどの文化や歴史、壮大な自然が存在していますが、その多くは日常の中で意識されることはありません。\n\nこのアプリを通じて、ふとした瞬間に遠く離れた国の名前を検索し、まだ見ぬ景色に思いを馳せるきっかけを作れたら嬉しいです。国旗のデザイン、人口の規模、そして歴史の1ページ。それらの情報が、あなたの日常に少しでも「旅のワクワク感」を届けてくれることを心から願っています。';

  // ===========================================================================
  // 8. お気に入り画面のテキスト (favorite_list_screen.dart)
  // ===========================================================================
  static const String favoriteEmptyMessage =
      'お気に入りに登録された国はありません\n\nハートをタップして追加してみましょう';
}
