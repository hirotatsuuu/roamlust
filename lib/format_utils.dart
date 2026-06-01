// 数字を整形するためのFlutter標準ライブラリです
import 'package:intl/intl.dart';

class FormatUtils {
  // 数字にカンマをつける関数です (例: 1000000 -> 1,000,000)
  static String formatNumber(dynamic number) {
    if (number == null) return '不明';

    // intlパッケージのNumberFormatを使います
    final formatter = NumberFormat('#,###');

    // 整数か小数点かによって処理を分けます
    if (number is int) {
      return formatter.format(number);
    } else if (number is double) {
      return formatter.format(number.round());
    }
    return number.toString();
  }

  // GDPなど、大きすぎる数字を「億」などで短くする関数です（今回はシンプルにカンマのみにします）
  static String formatMoney(dynamic number) {
    if (number == null || number == 0) return 'データなし';
    return '\$${formatNumber(number)}';
  }
}
