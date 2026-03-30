import 'package:ngdart/angular.dart';

import '../../core/tiny_highlight.dart';

@Component(
  selector: 'li-highlight',
  changeDetection: ChangeDetectionStrategy.onPush,
  template: '''
    <div class="li-highlight-container">
      <pre><code [innerHtml]="highlightedCode"></code></pre>
    </div>
  ''',
  styles: [
    '''
    .li-highlight-container {
      background-color: #282c34;
      border-radius: 6px;
      padding: 16px;
      overflow-x: auto;
      font-family: 'Fira Code', 'Courier New', Courier, monospace;
      font-size: 14px;
      line-height: 1.5;
    }

    .li-highlight-container pre {
      margin: 0;
      color: #abb2bf;
    }

    .th-keyword { color: #c678dd; }
    .th-type    { color: #e5c07b; }
    .th-string  { color: #98c379; }
    .th-number  { color: #d19a66; }
    .th-comment { color: #5c6370; font-style: italic; }
    .th-tag     { color: #e06c75; }
    .th-attr    { color: #d19a66; }
    .th-prop    { color: #56b6c2; }
    '''
  ],
)
class LiHighlightComponent {
  String _code = '';
  String _language = 'dart';
  String highlightedCode = '';

  @Input()
  set code(String value) {
    if (_code == value) {
      return;
    }

    _code = value;
    _refreshHighlight();
  }

  String get code => _code;

  @Input()
  set language(String value) {
    final normalizedValue = value.isEmpty ? 'dart' : value;
    if (_language == normalizedValue) {
      return;
    }

    _language = normalizedValue;
    _refreshHighlight();
  }

  String get language => _language;

  void _refreshHighlight() {
    if (_code.isEmpty) {
      highlightedCode = '';
      return;
    }

    highlightedCode = TinyHighlight.highlight(_code, _language);
  }
}
