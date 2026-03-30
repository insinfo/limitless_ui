import 'dart:convert';
import 'dart:typed_data';

import 'package:limitless_ui/core.dart';
import 'package:test/test.dart';

void main() {
  group('MinimalZip', () {
    test('creates a valid zip archive with stored entries', () {
      final zip = MinimalZip();
      zip.addFile('a.txt', utf8.encode('alpha'));
      zip.addFile('dir/b.txt', Uint8List.fromList([1, 2, 3]));

      final bytes = zip.finish();
      final entries = _parseStoredZip(bytes);

      expect(bytes, isNotEmpty);
      expect(bytes.sublist(0, 4), orderedEquals([80, 75, 3, 4]));
      expect(bytes.sublist(bytes.length - 22, bytes.length - 18), orderedEquals([80, 75, 5, 6]));
      expect(entries.keys, containsAll(['a.txt', 'dir/b.txt']));
      expect(utf8.decode(entries['a.txt']!), 'alpha');
      expect(entries['dir/b.txt'], orderedEquals([1, 2, 3]));
    });

    test('preserves utf8 file names', () {
      final zip = MinimalZip();
      zip.addFile('õöü.txt', utf8.encode('utf8'));

      final entries = _parseStoredZip(zip.finish());

      expect(entries.keys.single, 'õöü.txt');
      expect(utf8.decode(entries['õöü.txt']!), 'utf8');
    });
  });

  group('LiteXlsx.create', () {
    test('creates a non-empty xlsx zip with required parts', () {
      final bytes = LiteXlsx.create({
        'sheets': [
          {
            'name': 'Products',
            'data': [
              ['Apple', 1.99, true],
            ],
          },
        ],
      });

      final entries = _parseStoredZip(bytes);

      expect(bytes, isNotEmpty);
      expect(entries.keys, containsAll([
        '[Content_Types].xml',
        '_rels/.rels',
        'xl/workbook.xml',
        'xl/_rels/workbook.xml.rels',
        'xl/styles.xml',
        'xl/worksheets/sheet1.xml',
      ]));
    });

    test('writes workbook and worksheet metadata for multiple sheets', () {
      final bytes = LiteXlsx.create({
        'sheets': [
          {
            'name': 'First',
            'data': [
              ['A1'],
            ],
          },
          {
            'data': [
              ['B1'],
            ],
          },
        ],
      });

      final entries = _parseStoredZip(bytes);
      final workbookXml = utf8.decode(entries['xl/workbook.xml']!);
      final relsXml = utf8.decode(entries['xl/_rels/workbook.xml.rels']!);
      final contentTypesXml = utf8.decode(entries['[Content_Types].xml']!);

      expect(workbookXml, contains('name="First"'));
      expect(workbookXml, contains('name="Sheet2"'));
      expect(workbookXml, contains('sheetId="1"'));
      expect(workbookXml, contains('sheetId="2"'));
      expect(relsXml, contains('Target="styles.xml"'));
      expect(relsXml, contains('Target="worksheets/sheet1.xml"'));
      expect(relsXml, contains('Target="worksheets/sheet2.xml"'));
      expect(contentTypesXml, contains('PartName="/xl/worksheets/sheet1.xml"'));
      expect(contentTypesXml, contains('PartName="/xl/worksheets/sheet2.xml"'));
    });

    test('serializes string, number, bool and DateTime cells', () {
      final date = DateTime(2024, 1, 2, 3, 4, 5);
      final bytes = LiteXlsx.create({
        'sheets': [
          {
            'name': 'Types',
            'data': [
              ['Text & <tag>', 42, true, date, null],
              [false, 3.5, 'next'],
            ],
          },
        ],
      });

      final entries = _parseStoredZip(bytes);
      final sheetXml = utf8.decode(entries['xl/worksheets/sheet1.xml']!);
      final excelEpoch = DateTime(1899, 12, 30);
      final excelDate = date.difference(excelEpoch).inMilliseconds / 86400000.0;

      expect(sheetXml, contains('r="A1" t="inlineStr"'));
      expect(sheetXml, contains('Text &amp; &lt;tag>'));
      expect(sheetXml, contains('<c r="B1"><v>42</v></c>'));
      expect(sheetXml, contains('<c r="C1" t="b"><v>1</v></c>'));
      expect(sheetXml, contains('<c r="D1" s="1"><v>${excelDate.toStringAsFixed(6)}</v></c>'));
      expect(sheetXml, isNot(contains('E1')));
      expect(sheetXml, contains('<c r="A2" t="b"><v>0</v></c>'));
      expect(sheetXml, contains('<c r="B2"><v>3.5</v></c>'));
      expect(sheetXml, contains('<c r="C2" t="inlineStr"><is><t>next</t></is></c>'));
    });

    test('skips empty rows and converts column indexes beyond Z', () {
      final row = List<dynamic>.filled(27, null);
      row[0] = 'A';
      row[26] = 'AA';

      final bytes = LiteXlsx.create({
        'sheets': [
          {
            'data': [
              row,
              <dynamic>[null, null],
              ['tail'],
            ],
          },
        ],
      });

      final entries = _parseStoredZip(bytes);
      final sheetXml = utf8.decode(entries['xl/worksheets/sheet1.xml']!);

      expect(sheetXml, contains('r="A1"'));
      expect(sheetXml, contains('r="AA1"'));
      expect(sheetXml, isNot(contains('<row r="2">')));
      expect(sheetXml, contains('<row r="3"><c r="A3" t="inlineStr"><is><t>tail</t></is></c></row>'));
    });

    test('includes styles and root relationships', () {
      final bytes = LiteXlsx.create({
        'sheets': [
          {
            'data': [
              ['x'],
            ],
          },
        ],
      });

      final entries = _parseStoredZip(bytes);
      final stylesXml = utf8.decode(entries['xl/styles.xml']!);
      final rootRels = utf8.decode(entries['_rels/.rels']!);

      expect(stylesXml, contains('numFmtId="164"'));
      expect(stylesXml, contains('numFmtId="165"'));
      expect(stylesXml, contains('<b/>'));
      expect(rootRels, contains('Target="xl/workbook.xml"'));
    });
  });
}

Map<String, Uint8List> _parseStoredZip(Uint8List bytes) {
  final files = <String, Uint8List>{};
  int offset = 0;

  while (offset + 4 <= bytes.length) {
    final signature = _readUint32(bytes, offset);
    if (signature == 0x04034b50) {
      final compressedSize = _readUint32(bytes, offset + 18);
      final nameLength = _readUint16(bytes, offset + 26);
      final extraLength = _readUint16(bytes, offset + 28);
      final nameStart = offset + 30;
      final dataStart = nameStart + nameLength + extraLength;
      final dataEnd = dataStart + compressedSize;
      final name = utf8.decode(bytes.sublist(nameStart, nameStart + nameLength));
      files[name] = Uint8List.fromList(bytes.sublist(dataStart, dataEnd));
      offset = dataEnd;
      continue;
    }
    if (signature == 0x02014b50 || signature == 0x06054b50) {
      break;
    }
    fail('Unexpected ZIP signature 0x${signature.toRadixString(16)} at offset $offset');
  }

  return files;
}

int _readUint16(Uint8List bytes, int offset) {
  return bytes[offset] | (bytes[offset + 1] << 8);
}

int _readUint32(Uint8List bytes, int offset) {
  return bytes[offset] |
      (bytes[offset + 1] << 8) |
      (bytes[offset + 2] << 16) |
      (bytes[offset + 3] << 24);
}
