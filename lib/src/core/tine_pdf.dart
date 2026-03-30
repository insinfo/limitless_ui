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

String _pdfString(String str) {
  final buffer = StringBuffer('(');
  for (final byte in latin1.encode(str)) {
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
    _links.add(_LinkEntry(url, [x, y, x + w, y + h]));
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

  static double measureText(String str, double size) {
    int width = 0;
    for (int i = 0; i < str.length; i++) {
      int code = str.codeUnitAt(i);
      width += (code >= 32 && code <= 126) ? _widths[code - 32] : 556;
    }
    return (width * size) / 1000.0;
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
              'A': {'Type': '/Action', 'S': '/URI', 'URI': lnk.url}
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
