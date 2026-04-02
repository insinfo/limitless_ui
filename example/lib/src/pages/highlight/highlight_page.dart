import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'highlight-page',
  templateUrl: 'highlight_page.html',
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiHighlightComponent,
  ],
)
class HighlightPageComponent {
  HighlightPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  bool get _isPt => i18n.isPortuguese;

  String selectedSnippet = 'dart';

  final String dartSnippet = '''@Component(
  selector: 'review-card',
  template: '<button (click)="approve()">Approve</button>',
)
class ReviewCardComponent {
  ReviewCardComponent(this.sweetAlertService);

  final SweetAlertService sweetAlertService;

  Future<void> approve() async {
    await sweetAlertService.show(
      title: 'Deploy concluído',
      message: 'A revisão pode continuar.',
      type: SweetAlertType.success,
    );
  }
}''';

  final String htmlSnippet = '''<div class="card card-body">
  <h6 class="mb-2">API</h6>
  <li-highlight
      [code]="dartSnippet"
      language="dart">
  </li-highlight>
</div>''';

  final String cssSnippet = '''.review-shell {
  display: grid;
  gap: 1rem;
  padding: 1.5rem;
  border: 1px solid #dfe3eb;
}

.review-shell__title {
  color: #1f2937;
  font-weight: 600;
}''';

  final String componentSnippet = '''<li-highlight
    [code]="snippet"
    language="html">
</li-highlight>''';

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Highlight';
  String get breadcrumb => _isPt
      ? 'Realce leve de código para documentação'
      : 'Lightweight code highlighting for documentation';
  String get intro => _isPt
      ? 'LiHighlightComponent é um bloco visual simples para documentação interna, exemplos de API e snippets de integração sem depender de bibliotecas pesadas no browser.'
      : 'LiHighlightComponent is a simple visual block for internal documentation, API examples, and integration snippets without depending on heavy browser-side libraries.';
  String get descriptionTitle => _isPt ? 'Escopo' : 'Scope';
  String get descriptionBody => _isPt
      ? 'Hoje o componente cobre Dart, HTML e CSS com um highlighter pequeno e cacheado.'
      : 'Today the component covers Dart, HTML, and CSS with a small cached highlighter.';
  String get strengthsTitle => _isPt ? 'Onde ele ajuda' : 'Where it helps';
  String get strengthsBody => _isPt
      ? 'É adequado para páginas de demo, documentação embutida e exemplos rápidos ao lado do componente real.'
      : 'It is suitable for demo pages, embedded documentation, and quick examples next to the real component.';
  String get limitsTitle => _isPt ? 'Limitações' : 'Limitations';
  String get limitsBody => _isPt
      ? 'Não é um editor nem um highlighter universal. Para dezenas de linguagens ou edição interativa, o pacote precisa de outra solução.'
      : 'It is not an editor or a universal highlighter. For dozens of languages or interactive editing, the package needs another solution.';
  String get pickerTitle => _isPt ? 'Snippets disponíveis' : 'Available snippets';
  String get pickerBody => _isPt
      ? 'Troque entre os exemplos para verificar a saída visual do highlighter.'
      : 'Switch between examples to inspect the highlighter visual output.';
    String get templateTitle => _isPt ? 'Template' : 'Template';
    String get componentTitle => _isPt ? 'Componente' : 'Component';
  String get apiIntro => _isPt
      ? 'A API é deliberadamente curta: `code` recebe a string e `language` controla o parser leve disponível.'
      : 'The API is intentionally short: `code` receives the string and `language` controls the available lightweight parser.';

  String get activeSnippetTitle {
    switch (selectedSnippet) {
      case 'html':
        return _isPt ? 'Template HTML' : 'HTML template';
      case 'css':
        return _isPt ? 'Bloco CSS' : 'CSS block';
      case 'dart':
      default:
        return _isPt ? 'Componente Dart' : 'Dart component';
    }
  }

  String get activeSnippetLanguage {
    switch (selectedSnippet) {
      case 'html':
        return 'html';
      case 'css':
        return 'css';
      case 'dart':
      default:
        return 'dart';
    }
  }

  String get activeSnippetCode {
    switch (selectedSnippet) {
      case 'html':
        return htmlSnippet;
      case 'css':
        return cssSnippet;
      case 'dart':
      default:
        return dartSnippet;
    }
  }

  String get summaryText => _isPt
      ? 'Snippet atual: $activeSnippetTitle'
      : 'Current snippet: $activeSnippetTitle';

  void selectSnippet(String value) {
    selectedSnippet = value;
  }
}