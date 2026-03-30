// tiny_highlight.dart
class TinyHighlight {
  static final Map<String, String> _cache = <String, String>{};

  static final RegExp _dartRegex = RegExp(
    r'(//.*|/\*[\s\S]*?\*/)|'
    r"('(?:\\.|[^'\\])*'|"
    r'"(?:\\.|[^"\\])*")|'
    r'\b(class|import|void|bool|dynamic|var|final|const|if|else|for|while|return|new|true|false|null|await|async|extends|implements|with|switch|case|default|get|set|factory|static|throw|try|catch|rethrow)\b|'
    r'\b([A-Z][a-zA-Z0-9_]*)\b|'
    r'\b(\d+(?:\.\d+)?)\b',
  );

  static final RegExp _htmlRegex = RegExp(
    r'(<!--[\s\S]*?-->)|'
    r'(<\/?[\w-]+)|'
    r'(>)|'
    r'(\b[\w-]+(?=\s*=))|'
    r"('[^']*'|"
    r'"[^"]*")',
  );

  static final RegExp _cssRegex = RegExp(
    r'(/\*[\s\S]*?\*/)|'
    r"('[^']*'|"
    r'"[^"]*")|'
    r'([\w-]+(?=\s*:))|'
    r'(#[0-9a-fA-F]{3,6}\b|\b\d+(?:px|em|rem|%|vh|vw|s|ms)\b)',
  );

  /// Retorna o código formatado com as tags <span> de highlight.
  static String highlight(String code, String language) {
    if (code.isEmpty) return '';

    final normalizedLanguage = language.toLowerCase();
    final cacheKey = '$normalizedLanguage\n$code';
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    late final String highlighted;

    switch (normalizedLanguage) {
      case 'dart':
        highlighted = _highlightDart(code);
        break;
      case 'html':
        highlighted = _highlightHtml(code);
        break;
      case 'css':
        highlighted = _highlightCss(code);
        break;
      default:
        highlighted = _escapeHtml(code);
    }

    _cache[cacheKey] = highlighted;
    return highlighted;
  }

  static String _highlightDart(String code) {
    return _processMatches(code, _dartRegex, (match) {
      if (match.group(1) != null) return 'th-comment';
      if (match.group(2) != null) return 'th-string';
      if (match.group(3) != null) return 'th-keyword';
      if (match.group(4) != null) return 'th-type';
      if (match.group(5) != null) return 'th-number';
      return '';
    });
  }

  static String _highlightHtml(String code) {
    return _processMatches(code, _htmlRegex, (match) {
      if (match.group(1) != null) return 'th-comment';
      if (match.group(2) != null || match.group(3) != null) return 'th-tag';
      if (match.group(4) != null) return 'th-attr';
      if (match.group(5) != null) return 'th-string';
      return '';
    });
  }

  static String _highlightCss(String code) {
    return _processMatches(code, _cssRegex, (match) {
      if (match.group(1) != null) return 'th-comment';
      if (match.group(2) != null) return 'th-string';
      if (match.group(3) != null) return 'th-prop';
      if (match.group(4) != null) return 'th-number';
      return '';
    });
  }

  /// Processa a string sequencialmente escapando o texto não correspondente.
  static String _processMatches(
      String code, RegExp regex, String Function(RegExpMatch) getClass) {
    var lastEnd = 0;
    final buffer = StringBuffer();

    for (final match in regex.allMatches(code)) {
      // Adiciona o texto entre os matches com o devido escape de HTML
      buffer.write(_escapeHtml(code.substring(lastEnd, match.start)));

      final cssClass = getClass(match);
      final matchText = _escapeHtml(match.group(0)!);

      if (cssClass.isNotEmpty) {
        buffer.write('<span class="$cssClass">$matchText</span>');
      } else {
        buffer.write(matchText);
      }
      lastEnd = match.end;
    }
    buffer.write(_escapeHtml(code.substring(lastEnd)));
    return buffer.toString();
  }

  static String _escapeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
