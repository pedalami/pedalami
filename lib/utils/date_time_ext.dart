import 'package:date_format/date_format.dart';

extension DateTimeExt on DateTime {
  String get formatIT =>
      formatDate(this, [dd, "/", MM.substring(1,2), "/" , yyyy , " " , hh , ":" , nn],
          locale: EnglishDateLocale()).toUpperCase();
}
