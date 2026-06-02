# Roamlust

「Roamlust（放浪する強い欲求）」は、世界中の国々の情報を検索し、自分の「行ってみたい国リスト」を管理できる、旅好きのための探索型アプリです。

## 特徴
- 国検索: 国名を検索してヒットした国の詳細情報を表示。（日本語名のみ）
- 国の一覧: 最初あいうえお順で表示され、ランキング（人口、面積、GDP）で国を並び替え可能。
- 詳細情報: 各国の基本情報（首都、言語、通貨）やWikipediaの概要をオフライン環境でも閲覧可能。
- お気に入り機能: 気になる国をお気に入り（ハート）に登録して自分だけのリストを作成可能。
- オフライン対応: 初回ダウンロード後はキャッシュにより通信なしで情報を閲覧可能。
- ダークモード対応: 目の疲れを抑えるダークテーマをサポート。

## インストール方法
このプロジェクトはFlutterで構築されています。以下の手順でローカル環境で動作させることができます。

1. リポジトリのクローン
```Bash
git clone https://github.com/your-username/roamlust.git
cd roamlust
```
2. 依存関係のインストール
```Bash
flutter pub get
```
3. アプリの実行
```Bash
flutter run
```

## Flutter環境構築
Flutterの開発には、PC上に開発環境を整える必要があります。

- ステップ1: Flutter SDKのダウンロード
Flutter公式サイトへアクセス。

OS（Windows/macOS）を選択し、SDKのzipファイルをダウンロードして解凍。

- 解凍した flutter フォルダを、PCのわかりやすい場所（例: C:\src\flutter や ~/development/flutter）に配置します。

- ステップ2: パス（Path）の通し方
「環境変数の編集」を開き、システム環境変数の Path に C:\src\flutter\bin を追加します。


- ステップ3: 依存ツールのインストール
ターミナルで以下のコマンドを実行し、環境が整っているか確認します。

```Bash
flutter doctor
```

※不足しているツール（Android StudioやXcodeなど）が表示される場合は、メッセージに従ってインストールしてください。

## プロジェクト構成
```text
roamlust
    └── lib/                            # ソースコードフォルダ
        ├── main.dart                   # アプリの起動・テーマ管理
        ├── initial_load_screen.dart    # 初回ダウンロード画面
        ├── home_screen.dart            # ホーム画面・検索ロジック
        ├── country_list_screen.dart    # 一覧・並び替え
        ├── country_detail_screen.dart  # 詳細表示・お気に入り
        ├── favorite_list_screen.dart   # お気に入り一覧
        ├── app_drawer.dart             # ナビゲーションメニュー
        ├── about_screen.dart           # このアプリについて(ライセンス)画面
        ├── support_screen.dart         # お問い合わせ画面
        ├── data_service.dart           # キャッシュ保存・API取得管理
        ├── format_utils.dart           # 数字整形ユーティリティ
        └── config.dart                 # 定数管理
    └── assets/                         # データフォルダ
    ├── flags/                          # 国旗データフォルダ
        └── json/                       # JSON形式のフォルダ
            ├── rankings                # ランキングに関するファイル
            ├── restcountries           # RestCountriesから取得したデータ
            ├── wikipedia               # Wikipediaから取得したデータ
            └── countries_master.json   # 国を紐づけるファイル
```

## ライセンス
本アプリは以下のオープンデータを利用しています。

**Wikipedia: CC BY-SA 4.0**
**Rest Countries API: Rest Countries**
Google公式Material Symbols & Icons**https://fonts.google.com/icons**