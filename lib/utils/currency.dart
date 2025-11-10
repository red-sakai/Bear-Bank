import 'package:intl/intl.dart';

final NumberFormat pesoFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

String formatPeso(num amount) => pesoFormat.format(amount);
