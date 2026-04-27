import 'package:limitless_ui/src/core/tiny_highlight.dart';
import 'package:test/test.dart';

void main() {
  group('TinyHighlight SQL', () {
    test('destaca tokens basicos de SQL', () {
      final result = TinyHighlight.highlight(
        "SELECT id, name FROM users WHERE age >= 18 AND status = 'active'; -- comment",
        'sql',
      );

      expect(result, contains('<span class="th-keyword">SELECT</span>'));
      expect(result, contains('<span class="th-keyword">FROM</span>'));
      expect(result, contains('<span class="th-keyword">WHERE</span>'));
      expect(result, contains('<span class="th-number">18</span>'));
      expect(result, contains('<span class="th-string">&#39;active&#39;</span>'));
      expect(result, contains('<span class="th-comment">-- comment</span>'));
    });

    test('aceita aliases comuns de SQL', () {
      final result = TinyHighlight.highlight('select 1', 'postgresql');

      expect(result, contains('<span class="th-keyword">select</span>'));
      expect(result, contains('<span class="th-number">1</span>'));
    });
  });
}