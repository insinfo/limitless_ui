import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

File? fileOrNull(Object? value) {
  if (value == null) return null;
  try {
    final jsValue = value as JSAny;
    return jsValue.isA<File>() ? jsValue as File : null;
  } on TypeError {
    return null;
  }
}

File fileFromDartParts(
  List<Object> parts,
  String name, {
  String? type,
}) =>
    File(
      <BlobPart>[
        for (final part in parts)
          switch (part) {
            final String value => value.toJS,
            final List<int> bytes => Uint8List.fromList(bytes).toJS,
            _ => part.jsify()!,
          },
      ].toJS,
      name,
      type == null ? FilePropertyBag() : FilePropertyBag(type: type),
    );
