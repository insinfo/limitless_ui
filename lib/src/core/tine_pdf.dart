import 'dart:convert';
import 'dart:typed_data';

const List<int> _widths = [
  278,
  278,
  355,
  556,
  556,
  889,
  667,
  191,
  333,
  333,
  389,
  584,
  278,
  333,
  278,
  278,
  556,
  556,
  556,
  556,
  556,
  556,
  556,
  556,
  556,
  556,
  278,
  278,
  584,
  584,
  584,
  556,
  1015,
  667,
  667,
  722,
  722,
  667,
  611,
  778,
  722,
  278,
  500,
  667,
  556,
  833,
  722,
  778,
  667,
  778,
  722,
  667,
  611,
  722,
  667,
  944,
  667,
  667,
  611,
  278,
  278,
  278,
  469,
  556,
  333,
  556,
  556,
  500,
  556,
  556,
  278,
  556,
  556,
  222,
  222,
  500,
  222,
  833,
  556,
  556,
  556,
  556,
  333,
  500,
  278,
  556,
  500,
  722,
  500,
  500,
  500,
  334,
  260,
  334,
  584
];

enum TextAlign { left, center, right }

List<double>? _parseColor(String? hexStr) {
  if (hexStr == null || hexStr == 'none') {
    return null;
  }
  String hex = hexStr.replaceFirst(RegExp(r'^#'), '');
  if (hex.length == 3) {
    hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
  }
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(hex)) {
    return null;
  }
  return [
    int.parse(hex.substring(0, 2), radix: 16) / 255.0,
    int.parse(hex.substring(2, 4), radix: 16) / 255.0,
    int.parse(hex.substring(4, 6), radix: 16) / 255.0
  ];
}

String _colorOp(List<double>? rgb, String op) {
  if (rgb == null) return '';
  return '${rgb[0].toStringAsFixed(3)} ${rgb[1].toStringAsFixed(3)} ${rgb[2].toStringAsFixed(3)} $op';
}

class _JpegInfo {
  final int width;
  final int height;
  final String colorSpace;
  _JpegInfo(this.width, this.height, this.colorSpace);
}

_JpegInfo _parseJpeg(Uint8List bytes) {
  if (bytes.length < 2 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
    throw Exception('Invalid JPEG: missing SOI marker');
  }
  int i = 2;
  while (i < bytes.length - 1) {
    if (bytes[i] != 0xFF) {
      i++;
      continue;
    }
    int marker = bytes[i + 1];
    if (marker == 0xDA) break;
    if (marker == 0xC0 || marker == 0xC2) {
      if (i + 9 >= bytes.length) break;
      int height = (bytes[i + 5] << 8) | bytes[i + 6];
      int width = (bytes[i + 7] << 8) | bytes[i + 8];
      int c = bytes[i + 9];
      if (width > 0 && height > 0) {
        return _JpegInfo(
            width,
            height,
            c == 1
                ? '/DeviceGray'
                : c == 4
                    ? '/DeviceCMYK'
                    : '/DeviceRGB');
      }
    }
    if (i + 3 >= bytes.length) break;
    int len = (bytes[i + 2] << 8) | bytes[i + 3];
    i += 2 + len;
  }
  throw Exception('Invalid JPEG: no valid SOF marker found');
}

/// Helvetica advance widths (1/1000 em) for the WinAnsiEncoding bytes
/// 0x80–0xFF, taken from the standard Helvetica AFM. The slots that
/// Windows-1252 leaves undefined (0x81, 0x8D, 0x8F, 0x90, 0x9D) are never
/// produced by [TinePDF.encodeWinAnsi] and keep the generic 556 width.
const List<int> _highWidths = [
  // 0x80
  556, 556, 222, 556, 333, 1000, 556, 556,
  333, 1000, 667, 333, 1000, 556, 611, 556,
  // 0x90
  556, 222, 222, 333, 333, 350, 556, 1000,
  333, 1000, 500, 333, 944, 556, 500, 667,
  // 0xA0
  278, 333, 556, 556, 556, 556, 260, 556,
  333, 737, 370, 556, 584, 333, 737, 333,
  // 0xB0
  400, 584, 333, 333, 333, 556, 537, 278,
  333, 333, 365, 556, 834, 834, 834, 611,
  // 0xC0
  667, 667, 667, 667, 667, 667, 1000, 722,
  667, 667, 667, 667, 278, 278, 278, 278,
  // 0xD0
  722, 722, 778, 778, 778, 778, 778, 584,
  778, 722, 722, 722, 722, 667, 667, 611,
  // 0xE0
  556, 556, 556, 556, 556, 556, 889, 500,
  556, 556, 556, 556, 278, 278, 278, 278,
  // 0xF0
  556, 556, 556, 556, 556, 556, 556, 584,
  611, 556, 556, 556, 556, 500, 556, 500,
];

/// Width of one WinAnsiEncoding byte in Helvetica, in 1/1000 em.
int _byteWidth(int byte) {
  if (byte >= 32 && byte <= 126) return _widths[byte - 32];
  if (byte >= 0x80) return _highWidths[byte - 0x80];
  return 556;
}

/// Unicode code points that Windows-1252 places in 0x80–0x9F, the range
/// where it differs from ISO-8859-1.
const Map<int, int> _cp1252HighBytes = {
  0x20AC: 0x80, // €
  0x201A: 0x82, // ‚
  0x0192: 0x83, // ƒ
  0x201E: 0x84, // „
  0x2026: 0x85, // …
  0x2020: 0x86, // †
  0x2021: 0x87, // ‡
  0x02C6: 0x88, // ˆ
  0x2030: 0x89, // ‰
  0x0160: 0x8A, // Š
  0x2039: 0x8B, // ‹
  0x0152: 0x8C, // Œ
  0x017D: 0x8E, // Ž
  0x2018: 0x91, // ‘
  0x2019: 0x92, // ’
  0x201C: 0x93, // “
  0x201D: 0x94, // ”
  0x2022: 0x95, // •
  0x2013: 0x96, // –
  0x2014: 0x97, // —
  0x02DC: 0x98, // ˜
  0x2122: 0x99, // ™
  0x0161: 0x9A, // š
  0x203A: 0x9B, // ›
  0x0153: 0x9C, // œ
  0x017E: 0x9E, // ž
  0x0178: 0x9F, // Ÿ
};

/// Base letters for Latin Extended-A (U+0100–U+017F), one per code point.
/// The few code points that Windows-1252 can encode (Œ œ Š š Ÿ Ž ž) are
/// resolved by [_cp1252HighBytes] before this table is consulted; Ĳ and ĳ
/// are expanded by [_winAnsiSubstitutes].
const String _latinExtendedABase = 'AaAaAaCcCcCcCcDd'
    'DdEeEeEeEeEeGgGg'
    'GgGgHhHhIiIiIiIi'
    'IiIiJjKkkLlLlLlL'
    'lLlNnNnNnnNnOoOo'
    'OoOoRrRrRrSsSsSs'
    'SsTtTtTtUuUuUuUu'
    'UuUuWwYyYZzZzZzs';

/// Combining diacritical marks that can merge with the preceding ASCII
/// letter into a character Windows-1252 can encode (text in NFD form).
/// Each entry maps a mark to `[bases, composed]`, position by position.
const Map<int, List<String>> _combiningCompositions = {
  0x0300: ['AEIOUaeiou', 'ÀÈÌÒÙàèìòù'],
  0x0301: ['AEIOUYaeiouy', 'ÁÉÍÓÚÝáéíóúý'],
  0x0302: ['AEIOUaeiou', 'ÂÊÎÔÛâêîôû'],
  0x0303: ['ANOano', 'ÃÑÕãñõ'],
  0x0308: ['AEIOUYaeiouy', 'ÄËÏÖÜŸäëïöüÿ'],
  0x030A: ['Aa', 'Åå'],
  0x030C: ['SZsz', 'ŠŽšž'],
  0x0327: ['Cc', 'Çç'],
};

/// Replacements for characters that Windows-1252 cannot encode but that
/// have an obvious readable equivalent. Every replacement is itself
/// encodable without further substitution.
const Map<int, String> _winAnsiSubstitutes = {
  // Ligatures and letters outside Latin Extended-A.
  0x0132: 'IJ', 0x0133: 'ij',
  0x0218: 'S', 0x0219: 's', 0x021A: 'T', 0x021B: 't',
  0x03BC: 'µ', // Greek mu -> micro sign
  // Hyphens and dashes.
  0x2010: '-', 0x2011: '-', 0x2012: '-', 0x2043: '-', 0x2212: '-',
  0x2015: '—', // horizontal bar -> em dash
  // Quotes, apostrophes and primes.
  0x02B9: "'", 0x02BA: '"', 0x02BC: "'",
  0x201B: "'", 0x201F: '"',
  0x2032: "'", 0x2033: '"', 0x2035: "'", 0x2036: '"',
  0x275B: "'", 0x275C: "'", 0x275D: '"', 0x275E: '"',
  // Other punctuation and symbols.
  0x2023: '•', // triangular bullet -> bullet
  0x2024: '.', 0x2025: '..',
  0x2027: '·', 0x2219: '·',
  0x2044: '/', 0x2215: '/', 0x2216: r'\', 0x2217: '*',
  0x2116: 'No',
  0x2190: '<-', 0x2192: '->', 0x2194: '<->', 0x21D2: '=>',
  0x2248: '~', 0x2260: '!=', 0x2264: '<=', 0x2265: '>=',
};

/// Returns the Windows-1252 byte for [codePoint] when it has a direct
/// representation, or `null` otherwise. The C1 control range U+0080–U+009F
/// has no representation: those bytes mean other characters in 1252.
int? _directWinAnsiByte(int codePoint) {
  if (codePoint < 0x80 || (codePoint >= 0xA0 && codePoint <= 0xFF)) {
    return codePoint;
  }
  return _cp1252HighBytes[codePoint];
}

bool _isSpaceVariant(int c) =>
    (c >= 0x2000 && c <= 0x200A) ||
    c == 0x2028 ||
    c == 0x2029 ||
    c == 0x202F ||
    c == 0x205F ||
    c == 0x3000;

bool _isIgnorable(int c) =>
    (c >= 0x200B && c <= 0x200D) ||
    c == 0x2060 ||
    c == 0xFEFF ||
    (c >= 0xFE00 && c <= 0xFE0F) ||
    (c >= 0x0300 && c <= 0x036F);

void _appendWinAnsi(String text, List<int> out) {
  for (final c in text.runes) {
    final direct = _directWinAnsiByte(c);
    if (direct != null) {
      out.add(direct);
      continue;
    }

    final composition = _combiningCompositions[c];
    if (composition != null && out.isNotEmpty) {
      final index = composition[0].indexOf(String.fromCharCode(out.last));
      if (index >= 0) {
        out[out.length - 1] =
            _directWinAnsiByte(composition[1].codeUnitAt(index))!;
        continue;
      }
    }
    if (_isIgnorable(c)) continue;
    if (_isSpaceVariant(c)) {
      out.add(0x20);
      continue;
    }

    final substitute = _winAnsiSubstitutes[c];
    if (substitute != null) {
      for (final unit in substitute.codeUnits) {
        out.add(_directWinAnsiByte(unit)!);
      }
      continue;
    }
    if (c >= 0x0100 && c <= 0x017F) {
      out.add(_latinExtendedABase.codeUnitAt(c - 0x0100));
      continue;
    }
    if (c >= 0xFF01 && c <= 0xFF5E) {
      // Fullwidth ASCII forms.
      out.add(c - 0xFEE0);
      continue;
    }
    out.add(0x3F); // '?'
  }
}

String _pdfString(String str) =>
    _pdfStringFromBytes(TinePDF.encodeWinAnsi(str));

String _pdfStringFromBytes(List<int> bytes) {
  final buffer = StringBuffer('(');
  for (final byte in bytes) {
    switch (byte) {
      case 0x5C:
        buffer.write(r'\\');
        break;
      case 0x28:
        buffer.write(r'\(');
        break;
      case 0x29:
        buffer.write(r'\)');
        break;
      case 0x0D:
        buffer.write(r'\r');
        break;
      case 0x0A:
        buffer.write(r'\n');
        break;
      default:
        if (byte < 32 || byte > 126) {
          buffer.write('\\${byte.toRadixString(8).padLeft(3, '0')}');
        } else {
          buffer.writeCharCode(byte);
        }
    }
  }
  buffer.write(')');
  return buffer.toString();
}

/// PDF URI actions must be 7-bit ASCII: anything else (spaces included) is
/// percent-encoded as UTF-8; existing `%XX` escapes are kept as they are.
String _asciiUri(String url) {
  final buffer = StringBuffer();
  for (final c in url.runes) {
    if (c > 0x20 && c < 0x7F) {
      buffer.writeCharCode(c);
    } else {
      for (final byte in utf8.encode(String.fromCharCode(c))) {
        buffer
            .write('%${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
  }
  return buffer.toString();
}

class Ref {
  final int id;
  const Ref(this.id);
  @override
  String toString() => '$id 0 R';
}

String _serialize(Object? val) {
  if (val == null) {
    return 'null';
  }
  if (val is bool) {
    return val ? 'true' : 'false';
  }
  if (val is num) {
    if (val is int || val.truncateToDouble() == val) {
      return val.toInt().toString();
    }
    String s = val.toStringAsFixed(4);
    if (s.contains('.')) {
      s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }
  if (val is String) {
    if (val.startsWith('/') || val.startsWith('(')) {
      return val;
    }
    return _pdfString(val);
  }
  if (val is List) {
    return '[${val.map(_serialize).join(' ')}]';
  }
  if (val is Ref) {
    return val.toString();
  }
  if (val is Map) {
    final pairs = val.entries
        .where((e) => e.value != null)
        .map((e) => '/${e.key} ${_serialize(e.value)}');
    return '<<\n${pairs.join('\n')}\n>>';
  }
  return val.toString();
}

class _PdfObject {
  final int id;
  final Map<String, Object?> dict;
  Uint8List? stream;
  _PdfObject(this.id, this.dict, this.stream);
}

class _ImageEntry {
  final String name;
  final Ref ref;
  _ImageEntry(this.name, this.ref);
}

class _LinkEntry {
  final String url;
  final List<double> rect;
  _LinkEntry(this.url, this.rect);
}

class PageContext {
  final List<String> _ops;
  final List<_ImageEntry> _images;
  final List<_LinkEntry> _links;
  final Ref Function(Map<String, Object?>, [Uint8List?]) _addRef;
  int _imageCount;

  PageContext._(this._ops, this._images, this._links, this._addRef)
      : _imageCount = 0;

  void text(String str, double x, double y, double size,
      {TextAlign align = TextAlign.left,
      double? width,
      String color = '#000000'}) {
    double tx = x;
    if (align != TextAlign.left && width != null) {
      double tw = TinePDF.measureText(str, size);
      if (align == TextAlign.center) tx = x + (width - tw) / 2;
      if (align == TextAlign.right) tx = x + width - tw;
    }
    String c = _colorOp(_parseColor(color), 'rg');
    if (c.isEmpty) c = '0.000 0.000 0.000 rg';
    _ops.addAll([
      c,
      'BT',
      '/F1 $size Tf',
      '${tx.toStringAsFixed(2)} ${y.toStringAsFixed(2)} Td',
      '${_pdfString(str)} Tj',
      'ET'
    ]);
  }

  void rect(double x, double y, double w, double h, String fill) {
    String c = _colorOp(_parseColor(fill), 'rg');
    if (c.isNotEmpty) {
      _ops.addAll([
        c,
        '${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} ${w.toStringAsFixed(2)} ${h.toStringAsFixed(2)} re',
        'f'
      ]);
    }
  }

  void line(double x1, double y1, double x2, double y2, String stroke,
      [double lineWidth = 1.0]) {
    String c = _colorOp(_parseColor(stroke), 'RG');
    if (c.isNotEmpty) {
      _ops.addAll([
        '${lineWidth.toStringAsFixed(2)} w',
        c,
        '${x1.toStringAsFixed(2)} ${y1.toStringAsFixed(2)} m',
        '${x2.toStringAsFixed(2)} ${y2.toStringAsFixed(2)} l',
        'S'
      ]);
    }
  }

  void image(Uint8List jpegBytes, double x, double y, double w, double h) {
    var info = _parseJpeg(jpegBytes);
    String imgName = '/Im${_imageCount++}';
    Ref imgRef = _addRef({
      'Type': '/XObject',
      'Subtype': '/Image',
      'Width': info.width,
      'Height': info.height,
      'ColorSpace': info.colorSpace,
      'BitsPerComponent': 8,
      'Filter': '/DCTDecode',
      'Length': jpegBytes.length
    }, jpegBytes);
    _images.add(_ImageEntry(imgName, imgRef));
    _ops.addAll([
      'q',
      '${w.toStringAsFixed(2)} 0 0 ${h.toStringAsFixed(2)} ${x.toStringAsFixed(2)} ${y.toStringAsFixed(2)} cm',
      '$imgName Do',
      'Q'
    ]);
  }

  void link(String url, double x, double y, double w, double h,
      {String? underline}) {
    _links.add(_LinkEntry(_asciiUri(url), [x, y, x + w, y + h]));
    if (underline != null) {
      String c = _colorOp(_parseColor(underline), 'RG');
      if (c.isNotEmpty) {
        _ops.addAll([
          '0.75 w',
          c,
          '${x.toStringAsFixed(2)} ${(y + 2).toStringAsFixed(2)} m',
          '${(x + w).toStringAsFixed(2)} ${(y + 2).toStringAsFixed(2)} l',
          'S'
        ]);
      }
    }
  }
}

class TinePDF {
  final List<_PdfObject> _objects = [];
  final List<Ref> _pages = [];
  int _nextId = 1;
  bool _built = false;

  /// Width of [str] in points when drawn with Helvetica at [size].
  ///
  /// The text is measured exactly as [PageContext.text] writes it: after
  /// [encodeWinAnsi], so a substituted character takes the width of its
  /// replacement and a dropped one takes none.
  static double measureText(String str, double size) {
    int width = 0;
    for (final byte in encodeWinAnsi(str)) {
      width += _byteWidth(byte);
    }
    return (width * size) / 1000.0;
  }

  /// Encodes [text] as WinAnsiEncoding (Windows-1252), the encoding the
  /// built-in Helvetica font is declared with.
  ///
  /// Never throws because of the content. Characters without a 1252 byte
  /// are replaced predictably:
  ///
  /// * letters with diacritics outside 1252 become the base letter
  ///   (`ă` → `a`, `ł` → `l`, `ș` → `s`); combining marks merge with the
  ///   preceding letter when the result exists in 1252 (`e` + U+0301 → `é`)
  ///   and are dropped otherwise;
  /// * typographic variants become their plain form: `‐ ‑ ‒ −` → `-`,
  ///   thin, narrow and ideographic spaces → space, `‛ ′ ʼ` → `'`,
  ///   `‟ ″` → `"`, `→` → `->`, `≤` → `<=`, fullwidth forms → ASCII;
  /// * zero-width characters and variation selectors are dropped;
  /// * everything else (emoji, CJK, C1 controls...) becomes `?`.
  static Uint8List encodeWinAnsi(String text) {
    final out = <int>[];
    _appendWinAnsi(text, out);
    return Uint8List.fromList(out);
  }

  Ref _addObject(Map<String, Object?> dict, [Uint8List? streamBytes]) {
    int id = _nextId++;
    _objects.add(_PdfObject(id, dict, streamBytes));
    return Ref(id);
  }

  void page(
      {double width = 612.0,
      double height = 792.0,
      required void Function(PageContext ctx) build}) {
    final ops = <String>[];
    final images = <_ImageEntry>[];
    final links = <_LinkEntry>[];

    final ctx = PageContext._(ops, images, links, _addObject);
    build(ctx);

    Uint8List contentBytes = Uint8List.fromList(utf8.encode(ops.join('\n')));
    Ref contentRef = _addObject({'Length': contentBytes.length}, contentBytes);

    final xobjects = <String, Ref>{};
    for (var img in images) {
      xobjects[img.name.substring(1)] = img.ref;
    }

    final annots = links
        .map((lnk) => _addObject({
              'Type': '/Annot',
              'Subtype': '/Link',
              'Rect': lnk.rect,
              'Border': [0, 0, 0],
              // Serialized up front so a relative URL starting with "/" or
              // "(" is not emitted as a PDF name or as raw string syntax.
              'A': {
                'Type': '/Action',
                'S': '/URI',
                'URI': _pdfStringFromBytes(lnk.url.codeUnits)
              }
            }))
        .toList();

    _pages.add(_addObject({
      'Type': '/Page',
      'Parent': null,
      'MediaBox': [0, 0, width, height],
      'Contents': contentRef,
      'Resources': <String, Object?>{
        'Font': <String, Object?>{'F1': null},
        if (xobjects.isNotEmpty) 'XObject': xobjects,
      },
      if (annots.isNotEmpty) 'Annots': annots
    }));
  }

  Ref _finalize() {
    if (_pages.isEmpty) throw Exception('PDF must have at least one page');
    if (_built) throw Exception('build() can only be called once');
    _built = true;

    Ref fontRef = _addObject({
      'Type': '/Font',
      'Subtype': '/Type1',
      'BaseFont': '/Helvetica',
      'Encoding': '/WinAnsiEncoding'
    });
    Ref pagesRef =
        _addObject({'Type': '/Pages', 'Kids': _pages, 'Count': _pages.length});

    for (var obj in _objects) {
      if (obj.dict['Type'] == '/Page') {
        obj.dict['Parent'] = pagesRef;
        var resources = obj.dict['Resources'] as Map<String, Object?>?;
        if (resources != null && resources['Font'] != null) {
          (resources['Font'] as Map<String, Object?>)['F1'] = fontRef;
        }
      }
    }
    return _addObject({'Type': '/Catalog', 'Pages': pagesRef});
  }

  Iterable<Uint8List> _emitChunks(Ref catalogRef) sync* {
    final offsets = List<int>.filled(_objects.length + 1, 0);
    int byteOffset = 0;

    final header =
        Uint8List.fromList(utf8.encode('%PDF-1.4\n%\xFF\xFF\xFF\xFF\n'));
    byteOffset += header.length;
    yield header;

    for (var obj in _objects) {
      offsets[obj.id] = byteOffset;
      String head = '${obj.id} 0 obj\n${_serialize(obj.dict)}\n';
      if (obj.stream != null) {
        var a = Uint8List.fromList(utf8.encode('${head}stream\n'));
        var b = obj.stream!;
        var c = Uint8List.fromList(utf8.encode('\nendstream\nendobj\n'));
        var chunk = Uint8List(a.length + b.length + c.length);
        chunk.setAll(0, a);
        chunk.setAll(a.length, b);
        chunk.setAll(a.length + b.length, c);
        byteOffset += chunk.length;
        obj.stream = null; // free memory
        yield chunk;
      } else {
        var bytes = Uint8List.fromList(utf8.encode('${head}endobj\n'));
        byteOffset += bytes.length;
        yield bytes;
      }
    }

    int xrefOffset = byteOffset;
    var xref = StringBuffer();
    xref.write('xref\n0 ${_objects.length + 1}\n0000000000 65535 f \n');
    for (int i = 1; i <= _objects.length; i++) {
      xref.write('${offsets[i].toString().padLeft(10, '0')} 00000 n \n');
    }
    xref.write('trailer\n${_serialize({
          'Size': _objects.length + 1,
          'Root': catalogRef
        })}\n');
    xref.write('startxref\n$xrefOffset\n%%EOF\n');
    yield Uint8List.fromList(utf8.encode(xref.toString()));
  }

  Uint8List build() {
    final catalogRef = _finalize();
    final chunks = _emitChunks(catalogRef).toList();
    int len = chunks.fold(0, (sum, chunk) => sum + chunk.length);
    final result = Uint8List(len);
    int offset = 0;
    for (var chunk in chunks) {
      result.setAll(offset, chunk);
      offset += chunk.length;
    }
    return result;
  }

  Stream<Uint8List> buildStream() {
    final catalogRef = _finalize();
    return Stream<Uint8List>.fromIterable(_emitChunks(catalogRef));
  }
}

class _MdItem {
  final String text;
  final double size;
  final double indent;
  final double spaceBefore;
  final double spaceAfter;
  final bool rule;
  final String? color;

  _MdItem(
      {required this.text,
      required this.size,
      required this.indent,
      required this.spaceBefore,
      required this.spaceAfter,
      this.rule = false,
      this.color});
}

class _MdPage {
  final List<_MdItem> items;
  final List<double> ys;
  _MdPage(this.items, this.ys);
}

Uint8List markdown(String md,
    {double width = 612.0, double height = 792.0, double margin = 72.0}) {
  final doc = TinePDF();
  final textW = width - margin * 2;
  const double bodySize = 11.0;
  final items = <_MdItem>[];

  List<String> wrap(String text, double size, double maxW) {
    final words = text.split(' ');
    final lines = <String>[];
    String line = '';

    for (var word in words) {
      if (TinePDF.measureText(word, size) > maxW) {
        if (line.isNotEmpty) {
          lines.add(line);
          line = '';
        }
        String chunk = '';
        for (int i = 0; i < word.length; i++) {
          String ch = word[i];
          if (TinePDF.measureText(chunk + ch, size) > maxW &&
              chunk.isNotEmpty) {
            lines.add(chunk);
            chunk = '';
          }
          chunk += ch;
        }
        line = chunk;
        continue;
      }
      String test = line.isNotEmpty ? '$line $word' : word;
      if (TinePDF.measureText(test, size) <= maxW) {
        line = test;
      } else {
        if (line.isNotEmpty) {
          lines.add(line);
        }
        line = word;
      }
    }
    if (line.isNotEmpty) {
      lines.add(line);
    }
    return lines.isNotEmpty ? lines : [''];
  }

  String prevType = 'start';
  for (var raw in md.split('\n')) {
    var line = raw.trimRight();
    if (RegExp(r'^#{1,6}\s').hasMatch(line)) {
      int rawLvl = RegExp(r'^#+').firstMatch(line)![0]!.length;
      int lvl = rawLvl < 3 ? rawLvl : 3;
      double size = [22.0, 16.0, 13.0][lvl - 1];
      double before = prevType == 'start' ? 0.0 : [14.0, 12.0, 10.0][lvl - 1];
      var lines = wrap(line.substring(rawLvl + 1), size, textW);
      for (int i = 0; i < lines.length; i++) {
        items.add(_MdItem(
            text: lines[i],
            size: size,
            indent: 0,
            spaceBefore: i == 0 ? before : 0,
            spaceAfter: 4,
            color: '#111111'));
      }
      prevType = 'header';
    } else if (RegExp(r'^[-*]\s').hasMatch(line)) {
      var lines = wrap(line.substring(2), bodySize, textW - 18);
      for (int i = 0; i < lines.length; i++) {
        items.add(_MdItem(
            text: (i == 0 ? '- ' : '  ') + lines[i],
            size: bodySize,
            indent: 12,
            spaceBefore: 0,
            spaceAfter: 2));
      }
      prevType = 'list';
    } else if (RegExp(r'^\d+\.\s').hasMatch(line)) {
      String numStr = RegExp(r'^\d+').firstMatch(line)![0]!;
      var lines = wrap(line.substring(numStr.length + 2), bodySize, textW - 18);
      for (int i = 0; i < lines.length; i++) {
        items.add(_MdItem(
            text: (i == 0 ? '$numStr. ' : '   ') + lines[i],
            size: bodySize,
            indent: 12,
            spaceBefore: 0,
            spaceAfter: 2));
      }
      prevType = 'list';
    } else if (RegExp(r'^(-{3,}|\*{3,}|_{3,})$').hasMatch(line)) {
      items.add(_MdItem(
          text: '',
          size: bodySize,
          indent: 0,
          spaceBefore: 8,
          spaceAfter: 8,
          rule: true));
      prevType = 'rule';
    } else if (line.trim().isEmpty) {
      if (prevType != 'start' && prevType != 'blank') {
        items.add(_MdItem(
            text: '',
            size: bodySize,
            indent: 0,
            spaceBefore: 0,
            spaceAfter: 4));
      }
      prevType = 'blank';
    } else {
      var lines = wrap(line, bodySize, textW);
      for (var l in lines) {
        items.add(_MdItem(
            text: l,
            size: bodySize,
            indent: 0,
            spaceBefore: 0,
            spaceAfter: 4,
            color: '#111111'));
      }
      prevType = 'para';
    }
  }

  final pages = <_MdPage>[];
  double y = height - margin;
  var pg = <_MdItem>[];
  var ys = <double>[];

  for (var item in items) {
    double needed = item.spaceBefore + item.size + item.spaceAfter;
    if (y - needed < margin) {
      if (pg.isNotEmpty) {
        pages.add(_MdPage(pg, ys));
        pg = [];
        ys = [];
        y = height - margin;
      }
    }
    y -= item.spaceBefore;
    ys.add(y);
    pg.add(item);
    y -= item.size + item.spaceAfter;
  }
  if (pg.isNotEmpty) pages.add(_MdPage(pg, ys));
  if (pages.isEmpty) pages.add(_MdPage([], []));

  for (var page in pages) {
    doc.page(
        width: width,
        height: height,
        build: (ctx) {
          for (int i = 0; i < page.items.length; i++) {
            var it = page.items[i];
            if (it.rule) {
              ctx.line(margin, page.ys[i], width - margin, page.ys[i],
                  '#e0e0e0', 0.5);
            } else if (it.text.isNotEmpty) {
              ctx.text(it.text, margin + it.indent, page.ys[i], it.size,
                  color: it.color ?? '#000000');
            }
          }
        });
  }
  return doc.build();
}
