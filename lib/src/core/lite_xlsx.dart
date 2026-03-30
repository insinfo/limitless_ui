import 'dart:typed_data';
import 'dart:convert';

/// Biblioteca minimalista e otimizada para gerar XLSX. Compatível com dart2js.
class LiteXlsx {
  static final DateTime _excelEpoch = DateTime(1899, 12, 30);
  
  static String _toCol(int num) {
    String res = '';
    while (num >= 0) {
      res = String.fromCharCode(65 + (num % 26)) + res;
      num = (num ~/ 26) - 1;
    }
    return res;
  }

  static String _escape(String val) {
    return val.replaceAll('&', '&amp;').replaceAll('<', '&lt;');
  }

  static String _toXml(String name,[Map<String, dynamic>? attrs, String? content]) {
    final sb = StringBuffer('<$name');
    if (attrs != null) {
      attrs.forEach((k, v) {
        if (v != null) sb.write(' $k="$v"');
      });
    }
    if (content != null && content.isNotEmpty) {
      sb.write('>$content</$name>');
    } else {
      sb.write('/>');
    }
    return sb.toString();
  }

  /// Cria o arquivo XLSX compactado retornando os bytes.
  static Uint8List create(Map<String, dynamic> workbook) {
    const xmlHead = '<?xml version="1.0" encoding="UTF-8"?>';
    final zip = MinimalZip();

    // Relações básicas
    final types =[
      {'Extension': 'rels', 'ContentType': 'application/vnd.openxmlformats-package.relationships+xml'},
      {'Extension': 'xml', 'ContentType': 'application/xml'},
      {'PartName': '/xl/styles.xml', 'ContentType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml'},
      {'PartName': '/xl/workbook.xml', 'ContentType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml'}
    ];
    
    final rels =[
      {'Id': 'rId0', 'Type': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles', 'Target': 'styles.xml'}
    ];

    final sheets = workbook['sheets'] as List<dynamic>;
    final sheetsXml = StringBuffer();

    // Estilos fixos mínimos 
    const stylesXml = '''<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
      <numFmts count="2">
        <numFmt numFmtId="164" formatCode="yyyy-mm-dd"/>
        <numFmt numFmtId="165" formatCode="yyyy-mm-dd hh:mm:ss"/>
      </numFmts>
      <fonts count="2"><font><sz val="11"/><name val="Calibri"/></font><font><sz val="11"/><name val="Calibri"/><b/></font></fonts>
      <fills count="2"><fill><patternFill patternType="none"/></fill><fill><patternFill patternType="gray125"/></fill></fills>
      <borders count="1"><border/></borders>
      <cellXfs count="4">
        <xf fontId="0" applyFont="1"/>
        <xf numFmtId="164" applyNumberFormat="1"/>
        <xf numFmtId="165" applyNumberFormat="1"/>
        <xf numFmtId="0" fontId="1" applyFont="1"/>
      </cellXfs>
    </styleSheet>''';

    for (int i = 0; i < sheets.length; i++) {
      final int sheetId = i + 1;
      final sheet = sheets[i] as Map<String, dynamic>;
      final String sheetName = sheet['name'] ?? 'Sheet$sheetId';
      final List<List<dynamic>> data = (sheet['data'] as List<dynamic>).cast<List<dynamic>>();
      
      final partName = '/xl/worksheets/sheet$sheetId.xml';
      types.add({'PartName': partName, 'ContentType': 'application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml'});
      rels.add({'Id': 'rId$sheetId', 'Type': 'http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet', 'Target': 'worksheets/sheet$sheetId.xml'});
      
      sheetsXml.write(_toXml('sheet', {'name': sheetName, 'sheetId': sheetId, 'r:id': 'rId$sheetId'}));

      final sheetDataXml = StringBuffer();
      int rowIndex = 1;

      for (var row in data) {
        final rowXml = StringBuffer();
        for (int col = 0; col < row.length; col++) {
          final val = row[col];
          if (val == null) continue;

          final ref = '${_toCol(col)}$rowIndex';
          
          if (val is String) {
            rowXml.write('<c r="$ref" t="inlineStr"><is><t>${_escape(val)}</t></is></c>');
          } else if (val is num) {
            rowXml.write('<c r="$ref"><v>$val</v></c>');
          } else if (val is bool) {
            rowXml.write('<c r="$ref" t="b"><v>${val ? 1 : 0}</v></c>');
          } else if (val is DateTime) {
            final double excelDate = val.difference(_excelEpoch).inMilliseconds / 86400000.0;
            // s="1" aponta para o formato de data yyyy-mm-dd
            rowXml.write('<c r="$ref" s="1"><v>${excelDate.toStringAsFixed(6)}</v></c>');
          }
        }
        if (rowXml.isNotEmpty) {
          sheetDataXml.write('<row r="$rowIndex">$rowXml</row>');
        }
        rowIndex++;
      }

      final content = StringBuffer()
        ..write(xmlHead)
        ..write('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">')
        ..write('<sheetData>$sheetDataXml</sheetData>')
        ..write('</worksheet>');

      zip.addFile('xl/worksheets/sheet$sheetId.xml', utf8.encode(content.toString()));
    }

    // [Content_Types].xml
    final typesXml = StringBuffer();
    for (var t in types) {
      if (t.containsKey('Extension')) {
        typesXml.write(_toXml('Default', t));
      } else {
        typesXml.write(_toXml('Override', t));
      }
    }
    zip.addFile('[Content_Types].xml', utf8.encode('$xmlHead<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">$typesXml</Types>'));

    // _rels/.rels
    zip.addFile('_rels/.rels', utf8.encode('$xmlHead<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'));

    // xl/_rels/workbook.xml.rels
    final relsXml = StringBuffer();
    for (var r in rels) {
      relsXml.write(_toXml('Relationship', r));
    }
    zip.addFile('xl/_rels/workbook.xml.rels', utf8.encode('$xmlHead<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">$relsXml</Relationships>'));

    // xl/styles.xml
    zip.addFile('xl/styles.xml', utf8.encode(xmlHead + stylesXml));

    // xl/workbook.xml
    zip.addFile('xl/workbook.xml', utf8.encode('$xmlHead<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>$sheetsXml</sheets></workbook>'));

    return zip.finish();
  }
}

/// Implementação ultra compacta de um criador de ZIP 
/// Utiliza 'Store' (sem compressão) para máxima performance web sem usar libs extras.
class MinimalZip {
  final BytesBuilder _out = BytesBuilder();
  final BytesBuilder _cd = BytesBuilder();
  int _offset = 0;
  int _count = 0;
  static final Uint32List _crcTable = _makeCrcTable();

  static Uint32List _makeCrcTable() {
    final table = Uint32List(256);
    for (int i = 0; i < 256; i++) {
      int c = i;
      for (int j = 0; j < 8; j++) {
        c = (c & 1) != 0 ? (0xEDB88320 ^ (c >> 1)) : (c >> 1);
      }
      table[i] = c;
    }
    return table;
  }

  int _getCrc32(List<int> bytes) {
    int crc = 0xFFFFFFFF;
    for (int b in bytes) {
      crc = _crcTable[(crc ^ b) & 0xFF] ^ (crc >> 8);
    }
    return crc ^ 0xFFFFFFFF;
  }

  int _dosDate(DateTime date) {
    return ((date.year - 1980) << 25) | (date.month << 21) | (date.day << 16) | 
           (date.hour << 11) | (date.minute << 5) | (date.second >> 1);
  }

  Uint8List _le16(int n) => Uint8List.fromList([n & 0xFF, (n >> 8) & 0xFF]);
  Uint8List _le32(int n) => Uint8List.fromList([n & 0xFF, (n >> 8) & 0xFF, (n >> 16) & 0xFF, (n >> 24) & 0xFF]);

  void addFile(String name, List<int> content) {
    final nameBytes = utf8.encode(name);
    final crc = _getCrc32(content);
    final len = content.length;
    final time = _dosDate(DateTime.now());

    // Local File Header
    _out.add([80, 75, 3, 4]); // PK\3\4
    _out.add(_le16(20)); // version
    _out.add(_le16(1 << 11)); // flags (UTF-8)
    _out.add(_le16(0)); // compression (0 = store)
    _out.add(_le32(time));
    _out.add(_le32(crc));
    _out.add(_le32(len));
    _out.add(_le32(len));
    _out.add(_le16(nameBytes.length));
    _out.add(_le16(0)); // extra
    _out.add(nameBytes);
    _out.add(content);

    // Central Directory
    _cd.add([80, 75, 1, 2]); // PK\1\2
    _cd.add(_le16(20)); // version made by
    _cd.add(_le16(20)); // version needed
    _cd.add(_le16(1 << 11)); // flags
    _cd.add(_le16(0)); // compression
    _cd.add(_le32(time));
    _cd.add(_le32(crc));
    _cd.add(_le32(len));
    _cd.add(_le32(len));
    _cd.add(_le16(nameBytes.length));
    _cd.add(_le16(0)); // extra
    _cd.add(_le16(0)); // comment
    _cd.add(_le16(0)); // disk
    _cd.add(_le16(0)); // attr
    _cd.add(_le32(0)); // ext attr
    _cd.add(_le32(_offset));
    _cd.add(nameBytes);

    _offset += 30 + nameBytes.length + len;
    _count++;
  }

  Uint8List finish() {
    final cdBytes = _cd.toBytes();
    _out.add(cdBytes);
    // End of Central Directory
    _out.add([80, 75, 5, 6]); // PK\5\6
    _out.add(_le16(0));
    _out.add(_le16(0));
    _out.add(_le16(_count));
    _out.add(_le16(_count));
    _out.add(_le32(cdBytes.length));
    _out.add(_le32(_offset));
    _out.add(_le16(0));
    return _out.toBytes();
  }
}