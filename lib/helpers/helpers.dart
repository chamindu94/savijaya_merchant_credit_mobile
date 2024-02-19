import 'package:intl/intl.dart';

class MyHelpers {
  static String capitalizefirst(String text) {
    return text.replaceFirst(text[0], text[0].toUpperCase());
  }

  static String formatNumber(dynamic num) {
    NumberFormat formatter = NumberFormat.decimalPatternDigits(
      locale: 'en_us',
      decimalDigits: 2,
    );

    return formatter.format(num);
  }
}
