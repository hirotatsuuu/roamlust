// 数字をきれいに整形するためのFlutter標準ライブラリ（intl）を読み込みます。
import 'package:intl/intl.dart';

// 数字に関する便利ツールをまとめたクラスです。
class FormatUtils {
  // 数字にカンマをつける処理です (例: 1000000 -> 1,000,000)
  static String formatNumber(dynamic number) {
    if (number == null) {
      return '不明';
    }

    // NumberFormatを使って、3桁ごとにカンマを打つ設定を作ります。
    final formatter = NumberFormat('#,###');

    // 整数か小数点かによって処理を分けます。
    if (number is int) {
      return formatter.format(number);
    } else if (number is double) {
      return formatter.format(number.round()); // 小数点は四捨五入して整数にしてからカンマをつけます。
    }
    return number.toString();
  }

  // お金の表記（GDPなど）の頭に「$」をつける処理です。
  static String formatMoney(dynamic number) {
    if (number == null || number == 0) {
      return 'データなし';
    }
    return '\$${formatNumber(number)}';
  }
}
