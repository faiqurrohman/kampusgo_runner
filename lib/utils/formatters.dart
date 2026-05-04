import 'package:intl/intl.dart';

class Formatters {
  static final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  static final date = DateFormat('dd MMM yyyy', 'id_ID');
}
