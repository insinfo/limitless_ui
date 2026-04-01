// ignore_for_file: prefer_is_not_operator

import 'package:ngdart/angular.dart';

@Pipe('cpfHidden', pure: true)
class CpfHiddenPipe {
  String? transform(dynamic value, [String pattern = 'asteriskEnd']) {
    if (value == null) return null;
    if (!(value is String)) return null;
    if (value.length < 11) return null;

    final cpf = value;

    if (pattern == 'asteriskEnd') {
      return cpf.substring(0, 4).padRight(11, '*');
    } else if (pattern == 'asteriskStart') {
      return value.toString().substring(cpf.length - 4).padLeft(11, '*');
    } else {
      return cpf.substring(0, 4).padRight(11, '*');
    }
  }

  const CpfHiddenPipe();
}
