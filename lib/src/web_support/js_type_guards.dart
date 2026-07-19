import 'dart:js_interop';

import 'package:web/web.dart';

/// Returns [value] as a DOM [Element] without assuming that every Dart object
/// has a JavaScript representation.
///
/// The representation cast itself may throw under dart2wasm, so it is kept at
/// this narrow interop boundary.
Element? elementOrNull(Object? value) {
  if (value == null) return null;
  try {
    final jsValue = value as JSAny;
    return jsValue.isA<Element>() ? jsValue as Element : null;
  } on TypeError {
    return null;
  }
}
