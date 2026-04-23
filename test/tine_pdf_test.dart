import 'dart:convert';
import 'dart:typed_data';

import 'package:limitless_ui/core.dart';
import 'package:test/test.dart';

void main() {
  group('pdf', () {
    test('creates a valid PDF with header', () {
      final bytes = _docWithEmptyPage().build();

      expect(
          utf8.decode(bytes.sublist(0, 8), allowMalformed: true), '%PDF-1.4');
    });

    test('creates a valid PDF with trailer', () {
      final bytes = _docWithEmptyPage().build();

      expect(_content(bytes), contains('%%EOF'));
    });

    test('returns non-empty bytes', () {
      final bytes = _docWithEmptyPage().build();

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('contains core PDF structure', () {
      final content = _content(_docWithEmptyPage().build());

      expect(content, contains('/Type /Catalog'));
      expect(content, contains('/Type /Pages'));
      expect(content, contains('/Type /Page'));
      expect(content, contains('/BaseFont /Helvetica'));
      expect(content, contains('xref'));
      expect(content, contains('trailer'));
      expect(content, contains('startxref'));
    });
  });

  group('page', () {
    test('uses default page size', () {
      final content = _content(_docWithEmptyPage().build());

      expect(content, contains('/MediaBox [0 0 612 792]'));
    });

    test('accepts custom page size', () {
      final doc = TinePDF()..page(width: 400, height: 600, build: (_) {});

      expect(_content(doc.build()), contains('/MediaBox [0 0 400 600]'));
    });

    test('supports multiple pages', () {
      final doc = TinePDF()
        ..page(build: (_) {})
        ..page(build: (_) {})
        ..page(build: (_) {});

      expect(_content(doc.build()), contains('/Count 3'));
    });

    test('callback receives drawing context', () {
      PageContext? context;
      final doc = TinePDF()
        ..page(build: (ctx) {
          context = ctx;
        });

      doc.build();

      expect(context, isNotNull);
    });
  });

  group('text', () {
    test('renders text with font and position', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Hello', 100, 500, 24);
        });

      final content = _content(doc.build());

      expect(content, contains('(Hello) Tj'));
      expect(content, contains(RegExp(r'/F1 24(?:\.0)? Tf')));
      expect(content, contains('100.00 500.00 Td'));
    });

    test('applies explicit color and defaults invalid color to black', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Red', 50, 700, 12, color: '#ff0000');
          ctx.text('Fallback', 50, 680, 12, color: 'notacolor');
        });

      final content = _content(doc.build());

      expect(content, contains('1.000 0.000 0.000 rg'));
      expect(content, contains('0.000 0.000 0.000 rg'));
      expect(content, contains('(Fallback) Tj'));
    });

    test('escapes parentheses, backslashes, carriage return and newline', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.text(r'path\to(file)', 50, 700, 12);
          ctx.text('line\rnext\nend', 50, 680, 12);
        });

      final content = _content(doc.build());

      expect(content, contains(r'(path\\to\(file\)) Tj'));
      expect(content, contains(r'(line\rnext\nend) Tj'));
    });

    test('center and right alignment shift x position when width is provided',
        () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Hi', 50, 700, 12, align: TextAlign.center, width: 100);
          ctx.text('Hi', 50, 680, 12, align: TextAlign.right, width: 100);
        });

      final content = _content(doc.build());

      expect(content, isNot(contains('50.00 700.00 Td')));
      expect(content, isNot(contains('50.00 680.00 Td')));
    });

    test('alignment without width keeps original x position', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Hi', 50, 700, 12, align: TextAlign.center);
          ctx.text('Hi', 50, 680, 12, align: TextAlign.right);
        });

      final content = _content(doc.build());

      expect(content, contains('50.00 700.00 Td'));
      expect(content, contains('50.00 680.00 Td'));
    });
  });

  group('shapes', () {
    test('renders filled rectangle with parsed color', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.rect(50, 700, 200, 100, '#abc');
        });

      final content = _content(doc.build());

      expect(content, contains('50.00 700.00 200.00 100.00 re'));
      expect(content, contains('0.667 0.733 0.800 rg'));
      expect(content, contains('\nf\n'));
    });

    test('ignores rectangle with invalid or none color', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.rect(0, 0, 100, 100, 'none');
          ctx.rect(0, 0, 100, 100, 'xyz');
        });

      final content = _content(doc.build());

      expect(content, isNot(contains(' re')));
      expect(content, isNot(contains('NaN')));
    });

    test('renders line with stroke, width and color', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.line(50, 700, 250, 700, '#ff0000', 2.5);
        });

      final content = _content(doc.build());

      expect(content, contains('2.50 w'));
      expect(content, contains('1.000 0.000 0.000 RG'));
      expect(content, contains('50.00 700.00 m'));
      expect(content, contains('250.00 700.00 l'));
      expect(content, contains('\nS\n'));
    });

    test('ignores line with invalid or none stroke', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.line(0, 0, 100, 100, 'none');
          ctx.line(0, 0, 100, 100, 'garbage');
        });

      final content = _content(doc.build());

      expect(content, isNot(contains(' 0.00 0.00 m')));
      expect(content, isNot(contains('NaN')));
    });
  });

  group('links', () {
    test('creates link annotations with URI, rect and invisible border', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.link('https://example.com', 50, 700, 100, 20);
          ctx.link('https://github.com', 50, 650, 100, 20);
        });

      final content = _content(doc.build());

      expect(content, contains('/Type /Annot'));
      expect(content, contains('/Subtype /Link'));
      expect(content, contains('/S /URI'));
      expect(content, contains('/URI (https://example.com)'));
      expect(content, contains('/URI (https://github.com)'));
      expect(content, contains('/Rect [50 700 150 720]'));
      expect(content, contains('/Border [0 0 0]'));
      expect(content, contains('/Annots'));
    });

    test('draws underline only when a valid underline color is provided', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.link('https://example.com', 50, 700, 100, 20,
              underline: '#0000ff');
          ctx.link('https://example.com/path?a=1&b=(2)', 50, 650, 100, 20,
              underline: 'notacolor');
        });

      final content = _content(doc.build());

      expect(content, contains('0.000 0.000 1.000 RG'));
      expect(content, contains('50.00 702.00 m'));
      expect(content, contains('150.00 702.00 l'));
      expect(content, contains(r'/URI (https://example.com/path?a=1&b=\(2\))'));
      expect(content, isNot(contains('652.00 m')));
    });
  });

  group('images', () {
    test('creates image xobject with JPEG metadata and drawing operators', () {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.image(_minimalJpeg, 50, 700, 100, 80);
        });

      final content = _content(doc.build());

      expect(content, contains('/Type /XObject'));
      expect(content, contains('/Subtype /Image'));
      expect(content, contains('/Filter /DCTDecode'));
      expect(content, contains('/ColorSpace /DeviceGray'));
      expect(content, contains('/Width 1'));
      expect(content, contains('/Height 1'));
      expect(content, contains('100.00 0 0 80.00 50.00 700.00 cm'));
      expect(content, contains('/Im0 Do'));
      expect(content, contains('\nq\n'));
      expect(content, contains('\nQ\n'));
    });

    test('uses unique names for multiple images on one page', () {
      final sof = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xC0,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x10,
        0x00,
        0x20,
        0x03,
        0x01,
        0x22,
        0x00,
      ]);

      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.image(sof, 50, 600, 100, 50);
          ctx.image(sof, 50, 500, 100, 50);
        });

      final content = _content(doc.build());

      expect(content, contains('/Im0 Do'));
      expect(content, contains('/Im1 Do'));
      expect(content, contains('/Width 32'));
      expect(content, contains('/Height 16'));
      expect(content, contains('/ColorSpace /DeviceRGB'));
    });

    test('supports grayscale, cmyk and progressive JPEG markers', () {
      final gray = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xC0,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x01,
        0x00,
        0x01,
        0x01,
        0x01,
        0x11,
        0x00,
      ]);
      final cmyk = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xC0,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x01,
        0x00,
        0x01,
        0x04,
        0x01,
        0x11,
        0x00,
      ]);
      final progressive = Uint8List.fromList([
        0xFF,
        0xD8,
        0xFF,
        0xC2,
        0x00,
        0x0B,
        0x08,
        0x00,
        0x10,
        0x00,
        0x20,
        0x03,
        0x01,
        0x22,
        0x00,
      ]);

      final grayDoc = TinePDF()
        ..page(build: (ctx) {
          ctx.image(gray, 0, 0, 10, 10);
        });
      final cmykDoc = TinePDF()
        ..page(build: (ctx) {
          ctx.image(cmyk, 0, 0, 10, 10);
        });
      final progressiveDoc = TinePDF()
        ..page(build: (ctx) {
          ctx.image(progressive, 0, 0, 10, 10);
        });

      expect(_content(grayDoc.build()), contains('/ColorSpace /DeviceGray'));
      expect(_content(cmykDoc.build()), contains('/ColorSpace /DeviceCMYK'));
      expect(
          _content(progressiveDoc.build()), contains('/ColorSpace /DeviceRGB'));
    });

    test('throws for invalid JPEG inputs', () {
      final missingSoi = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47]);
      final noSof =
          Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x02, 0x00, 0x00]);
      final truncated = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xC0, 0x00]);
      final sosFirst = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xDA, 0x00, 0x02]);

      final doc = TinePDF()
        ..page(build: (ctx) {
          expect(
            () => ctx.image(missingSoi, 0, 0, 100, 100),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                contains('missing SOI marker'))),
          );
          expect(
            () => ctx.image(Uint8List(0), 0, 0, 100, 100),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                contains('missing SOI marker'))),
          );
          expect(
            () => ctx.image(noSof, 0, 0, 100, 100),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                contains('no valid SOF marker'))),
          );
          expect(
            () => ctx.image(truncated, 0, 0, 100, 100),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                contains('no valid SOF marker'))),
          );
          expect(
            () => ctx.image(sosFirst, 0, 0, 100, 100),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                contains('no valid SOF marker'))),
          );
        });

      doc.build();
    });
  });

  group('measureText', () {
    test('builder exposes measureText', () {
      expect(TinePDF.measureText, isA<double Function(String, double)>());
      expect(TinePDF.measureText('Hi', 12), 11.328);
    });

    test('returns 0 for empty string', () {
      expect(TinePDF.measureText('', 12), 0);
    });

    test('scales with font size and character count', () {
      final width12 = TinePDF.measureText('Hello', 12);
      final width24 = TinePDF.measureText('Hello', 24);

      expect(width12, greaterThan(0));
      expect(width24, closeTo(width12 * 2, 0.00001));
      expect(TinePDF.measureText('Hello World', 12),
          greaterThan(TinePDF.measureText('Hi', 12)));
      expect(TinePDF.measureText('a b', 12),
          greaterThan(TinePDF.measureText('ab', 12)));
    });

    test('uses fallback width for non-ascii and known width for Hello', () {
      expect(TinePDF.measureText('中', 12), closeTo(556 * 12 / 1000, 0.00001));
      expect(TinePDF.measureText('Hello', 12), closeTo(27.336, 0.01));
    });
  });

  group('markdown', () {
    test('creates valid PDF with headings, lists, paragraph and rule', () {
      final bytes = markdown('''
# Title
## Subtitle
### Section

Paragraph line.

- item one
* item two
1. item three

---
''');

      final content = _content(bytes);

      expect(bytes, isA<Uint8List>());
      expect(content, contains('%PDF-1.4'));
      expect(content, contains('(Title) Tj'));
      expect(content, contains(RegExp(r'/F1 22(?:\.0)? Tf')));
      expect(content, contains('(Subtitle) Tj'));
      expect(content, contains(RegExp(r'/F1 16(?:\.0)? Tf')));
      expect(content, contains('(Section) Tj'));
      expect(content, contains(RegExp(r'/F1 13(?:\.0)? Tf')));
      expect(content, contains('(Paragraph line.) Tj'));
      expect(content, contains('(- item one) Tj'));
      expect(content, contains('(- item two) Tj'));
      expect(content, contains('(1. item three) Tj'));
      expect(content, contains(' m'));
      expect(content, contains(' l'));
    });

    test('supports deeper headings, wrapping and custom page size', () {
      final bytes = markdown(
        '#### Subsection\n##### Deep\n###### Deepest\n\n${'word ' * 60}',
        width: 400,
        height: 600,
        margin: 50,
      );

      final content = _content(bytes);
      final textOps = RegExp(r'\) Tj').allMatches(content).length;

      expect(content, contains('/MediaBox [0 0 400 600]'));
      expect(content, contains('(Subsection) Tj'));
      expect(content, contains('(Deep) Tj'));
      expect(content, contains('(Deepest) Tj'));
      expect(content, contains(RegExp(r'/F1 13(?:\.0)? Tf')));
      expect(textOps, greaterThan(3));
      expect(content, isNot(contains('NaN')));
    });

    test('creates multiple pages for long content', () {
      final source =
          List.generate(120, (index) => 'Paragraph $index').join('\n\n');

      final content = _content(markdown(source, height: 200, margin: 24));
      final pageCount = RegExp(r'/Type /Page\b').allMatches(content).length;

      expect(pageCount, greaterThan(1));
    });

    test('handles empty and whitespace-only input without blank leading page',
        () {
      final empty = _content(markdown(''));
      final whitespace = _content(markdown('   \n   \n   '));
      final tiny = _content(markdown('Hello world', height: 80, margin: 35));
      final tinyPages = RegExp(r'/Type /Page\b').allMatches(tiny).length;

      expect(empty, contains('%PDF-1.4'));
      expect(whitespace, contains('%%EOF'));
      expect(tiny, contains('(Hello world) Tj'));
      expect(tinyPages, 1);
    });

    test('wraps long words and collapses multiple blank lines', () {
      final longWordContent = _content(markdown('a' * 200));
      final blankLinesContent = _content(markdown('Hello\n\n\n\nWorld'));

      expect(
          RegExp(r'\) Tj').allMatches(longWordContent).length, greaterThan(1));
      expect(RegExp(r'\) Tj').allMatches(blankLinesContent).length, 2);
    });
  });

  group('build guards and streams', () {
    test('build throws when called with no pages', () {
      expect(
        () => TinePDF().build(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('PDF must have at least one page'))),
      );
    });

    test('build cannot be called twice', () {
      final doc = _docWithEmptyPage();

      doc.build();

      expect(
        doc.build,
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('build() can only be called once'))),
      );
    });

    test('buildStream matches build output', () async {
      final fromBuild = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Hello World', 50, 700, 12);
          ctx.rect(50, 650, 200, 30, '#ff0000');
        });
      final fromStream = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Hello World', 50, 700, 12);
          ctx.rect(50, 650, 200, 30, '#ff0000');
        });

      final builtBytes = fromBuild.build();
      final streamedBytes = await _collectStream(fromStream.buildStream());

      expect(streamedBytes, orderedEquals(builtBytes));
    });

    test('buildStream emits multiple chunks and supports multiple pages',
        () async {
      final doc = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Page 1', 50, 700, 12);
        })
        ..page(build: (ctx) {
          ctx.text('Page 2', 50, 700, 12);
        })
        ..page(build: (ctx) {
          ctx.text('Page 3', 50, 700, 12);
        });

      final chunks = <Uint8List>[];
      await for (final chunk in doc.buildStream()) {
        chunks.add(chunk);
      }

      final content = _content(
          Uint8List.fromList(chunks.expand((chunk) => chunk).toList()));

      expect(chunks.length, greaterThan(1));
      expect(content, contains('(Page 1) Tj'));
      expect(content, contains('(Page 2) Tj'));
      expect(content, contains('(Page 3) Tj'));
      expect(content, contains('/Count 3'));
    });

    test('buildStream surfaces the same guards as build', () async {
      expect(
        () => TinePDF().buildStream(),
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('PDF must have at least one page'))),
      );

      final built = _docWithEmptyPage();
      built.build();
      expect(
        built.buildStream,
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('build() can only be called once'))),
      );

      final streamed = _docWithEmptyPage();
      await streamed.buildStream().drain<void>();
      expect(
        streamed.build,
        throwsA(isA<Exception>().having((e) => e.toString(), 'message',
            contains('build() can only be called once'))),
      );
    });
  });

  group('xref table', () {
    test('xref entries are numeric and point to object headers', () {
      final bytes = TinePDF()
        ..page(build: (ctx) {
          ctx.text('Test', 50, 700, 12);
        });

      final built = bytes.build();
      final content = _content(built);
      final xrefSection = content.substring(content.indexOf('xref'));
      final entryLines = xrefSection
          .split('\n')
          .where((line) => RegExp(r'^\d{10} \d{5} n $').hasMatch(line))
          .toList();

      expect(entryLines, isNotEmpty);
      for (final line in entryLines) {
        final offset = int.parse(line.substring(0, 10));
        final chunk = utf8.decode(built.sublist(offset, offset + 10),
            allowMalformed: true);
        expect(offset, greaterThanOrEqualTo(0));
        expect(chunk, matches(RegExp(r'^\d+ 0 obj')));
      }
    });
  });
}

TinePDF _docWithEmptyPage() => TinePDF()..page(build: (_) {});

String _content(Uint8List bytes) => utf8.decode(bytes, allowMalformed: true);

Future<Uint8List> _collectStream(Stream<Uint8List> stream) async {
  final chunks = await stream.toList();
  return Uint8List.fromList(chunks.expand((chunk) => chunk).toList());
}

final Uint8List _minimalJpeg = Uint8List.fromList([
  0xFF,
  0xD8,
  0xFF,
  0xC0,
  0x00,
  0x0B,
  0x08,
  0x00,
  0x01,
  0x00,
  0x01,
  0x01,
  0x01,
  0x11,
  0x00,
]);
