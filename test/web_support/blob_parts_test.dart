@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:limitless_ui/src/web_support/blob_parts.dart';
import 'package:test/test.dart';

void main() {
  test('preserves binary List<int> blob parts', () async {
    final blob = blobFromDartParts(
      <Object>[
        <int>[0, 1, 127, 128, 255],
      ],
      type: 'application/octet-stream',
    );

    final buffer = (await blob.arrayBuffer().toDart).toDart;

    expect(buffer.asUint8List(), <int>[0, 1, 127, 128, 255]);
    expect(blob.size, 5);
    expect(blob.type, 'application/octet-stream');
  });
}
