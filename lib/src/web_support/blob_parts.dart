import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart';

/// Creates a browser [Blob] from Dart strings, byte lists, typed data or other
/// JS-convertible values.
Blob blobFromDartParts(List<Object> parts, {String? type}) => Blob(
      _toBlobParts(parts),
      type == null ? BlobPropertyBag() : BlobPropertyBag(type: type),
    );

/// Creates a browser [File] from Dart values using the same explicit interop
/// conversion as [blobFromDartParts].
File fileFromDartParts(
  List<Object> parts,
  String name, {
  String? type,
}) =>
    File(
      _toBlobParts(parts),
      name,
      type == null ? FilePropertyBag() : FilePropertyBag(type: type),
    );

JSArray<BlobPart> _toBlobParts(List<Object> parts) => [
      for (final part in parts)
        switch (part) {
          final String value => value.toJS,
          final List<int> bytes => Uint8List.fromList(bytes).toJS,
          _ => part.jsify()!,
        },
    ].toJS;
