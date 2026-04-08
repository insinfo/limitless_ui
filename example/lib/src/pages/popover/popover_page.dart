import 'dart:html' as html;

import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'popover-page',
  templateUrl: 'popover_page.html',
  styleUrls: ['popover_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiPopoverComponent,
    LiPopoverDirective,
  ],
)
class PopoverPageComponent {
  PopoverPageComponent(this.i18n);

  static const String componentApiSnippet = '''
<li-popover
  [popoverTitle]="'Popover com click'"
  [popover]="'Abre por click e fecha com clique externo ou ESC.'"
  trigger="click"
  placement="bottom">
  <button class="btn btn-outline-primary" type="button">Click popover</button>
</li-popover>''';

  static const String templateApiSnippet = '''
<template #richTitle let-data>
  <span>{{ data?.title }}</span>
</template>

<template #richBody let-data>
  <div>{{ data?.body }}</div>
</template>

<button
  [liPopover]="richBody"
  [popoverTitle]="richTitle"
  [popoverContext]="contextoInicial"
  container="body">
  Popover com TemplateRef
</button>''';

  static const String helperApiSnippet = '''
SimplePopover.showWarning(
  target,
  'Use este padrão para feedback curto.',
  title: 'Aviso rápido',
  timeout: const Duration(seconds: 4),
);''';

  static const String sweetAlertApiSnippet = '''
SweetAlertPopover.showPopover(
  target,
  '<strong>Popover com HTML</strong><br>Mais contexto.',
  title: 'Popover ancorado',
  timeout: const Duration(seconds: 5),
);''';

  final DemoI18nService i18n;
  List<PopoverPaletteDemo>? _palettePopoversPt;
  List<PopoverPaletteDemo>? _palettePopoversEn;
  PopoverTemplateDemoContext? _richPopoverContextPt;
  PopoverTemplateDemoContext? _richPopoverContextEn;

  @ViewChild('manualPopover')
  LiPopoverComponent? manualPopover;

  bool get _isPt => i18n.isPortuguese;
  Messages get t => i18n.t;

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Popover';
  String get breadcrumb =>
      _isPt ? 'Camada de contexto expandida' : 'Expanded contextual layer';
  String get cardTitle => _isPt ? 'Exemplos de popover' : 'Popover examples';
  String get intro => _isPt
      ? 'Popovers suportam mensagens mais ricas que tooltips e funcionam bem para avisos, contexto adicional e ações rápidas.'
      : 'Popovers support richer messages than tooltips and work well for warnings, extra context, and quick actions.';
  String get descriptionTitle => _isPt ? 'Descrição' : 'Description';
  String get descriptionBody => _isPt
      ? 'Esta página documenta os dois helpers de popover já expostos pelo pacote: uma versão leve e uma versão com posicionamento ancorado via Popper.'
      : 'This page documents the two popover helpers already exposed by the package: a lightweight version and a Popper-anchored version.';
  String get featuresTitle => _isPt ? 'Recursos' : 'Features';
  List<String> get features => _isPt
      ? const <String>[
          'Abertura por clique com fechamento por clique externo ou ESC.',
          'TemplateRef com bindings ativos para header e conteúdo.',
          'Suporte real a container="body", config global e hook de popperOptions.',
        ]
      : const <String>[
          'Click-to-open with outside-click or ESC dismissal.',
          'TemplateRef with live bindings for header and content.',
          'Real container="body" support, global config, and a popperOptions hook.',
        ];
  String get limitsTitle => _isPt ? 'Limitações' : 'Limitations';
  List<String> get limits => _isPt
      ? const <String>[
          'O componente declarativo e a diretiva compartilham a mesma engine de overlay.',
          'O posicionamento disponível hoje é mais restrito do que o demo original do Limitless.',
          'Conteúdo muito extenso deve migrar para modal, drawer ou card expansível.',
        ]
      : const <String>[
          'The declarative component and directive share the same overlay engine.',
          'Available placement is more limited than the original Limitless demo.',
          'Very long content should move to a modal, drawer, or expandable card.',
        ];
  String get quickTitle =>
      _isPt ? 'Popover leve de aviso' : 'Lightweight warning popover';
  String get quickBody => _isPt
      ? 'Usa o helper DOM simples, ideal para feedback curto com timeout automático.'
      : 'Uses the simple DOM helper, ideal for short feedback with automatic timeout.';
  String get quickButton => _isPt ? 'Abrir aviso' : 'Open warning';
  String get anchoredTitle =>
      _isPt ? 'Popover ancorado com HTML' : 'Anchored HTML popover';
  String get anchoredBody => _isPt
      ? 'Usa Popper para manter o alinhamento do painel ao gatilho e aceita HTML no conteúdo.'
      : 'Uses Popper to keep the panel aligned with the trigger and accepts HTML content.';
  String get anchoredButton => _isPt ? 'Abrir popover' : 'Open popover';
  String get declarativeTitle => _isPt
      ? 'Popover declarativo AngularDart'
      : 'Declarative AngularDart popover';
  String get declarativeBody => _isPt
      ? 'Novo componente com API mais próxima do estilo ng-bootstrap: inputs declarativos, triggers, placement e métodos públicos.'
      : 'New component with an API closer to ng-bootstrap style: declarative inputs, triggers, placement, and public methods.';
  String get paletteTitle =>
      _isPt ? 'Popovers por paleta do tema' : 'Theme palette popovers';
  String get paletteBody => _isPt
      ? 'Exemplos declarativos com as cores utilitárias do Limitless, incluindo variantes escuras e tons acentuados.'
      : 'Declarative examples using Limitless utility palette colors, including dark and accent variants.';
  String get clickButton => _isPt ? 'Click popover' : 'Click popover';
  String get hoverButton => _isPt ? 'Hover popover' : 'Hover popover';
  String get manualButton => _isPt ? 'Manual popover' : 'Manual popover';
  String get clickTitle => _isPt ? 'Popover com click' : 'Click popover';
  String get clickText => _isPt
      ? 'Abre por click e fecha com clique externo ou ESC.'
      : 'Opens on click and closes on outside click or ESC.';
  String get hoverTitle => _isPt ? 'Popover por hover' : 'Hover popover';
  String get hoverText => _isPt
      ? 'Bom para contexto um pouco maior que tooltip.'
      : 'Good for slightly richer context than a tooltip.';
  String get manualTitle => _isPt ? 'Controle manual' : 'Manual control';
  String get manualText => _isPt
      ? 'Pode ser aberto e fechado por API com ViewChild.'
      : 'Can be opened and closed by API via ViewChild.';
    String get directiveTitle =>
      _isPt ? 'Diretiva [liPopover]' : '[liPopover] directive';
    String get directiveBody => _isPt
      ? 'A mesma engine do componente agora também pode ser aplicada direto no elemento hospedeiro.'
      : 'The same overlay engine can now also be attached directly to the host element.';
    String get directiveButton =>
      _isPt ? 'Popover por diretiva' : 'Directive popover';
    String get directivePopoverTitle =>
      _isPt ? 'Popover via diretiva' : 'Directive popover';
    String get directivePopoverText => _isPt
      ? 'Esta versão usa [liPopover] direto no botão, paralela ao tooltip.'
      : 'This version uses [liPopover] directly on the button, parallel to the tooltip API.';
  String get bodyContainerTitle =>
      _isPt ? 'Append popover in the body' : 'Append popover in the body';
  String get bodyContainerBody => _isPt
      ? 'Quando o gatilho vive dentro de uma área com clipping, container="body" tira o popover desse contexto local.'
      : 'When the trigger lives inside a clipped area, container="body" moves the popover outside that local context.';
  String get bodyContainerPopoverTitle =>
      _isPt ? 'Popover no body' : 'Body popover';
  String get bodyContainerPopoverText => _isPt
      ? 'Este popover foi anexado ao body para escapar do clipping local.'
      : 'This popover was appended to the body so it can escape local clipping.';
  String get richTemplateTitle =>
      _isPt ? 'HTML and bindings via TemplateRef' : 'HTML and bindings via TemplateRef';
  String get richTemplateBody => _isPt
      ? 'O popover pode receber TemplateRef no título e no conteúdo, mantendo bindings vivos do componente hospedeiro.'
      : 'The popover can receive TemplateRef in both title and content while keeping host bindings alive.';
  String get richTemplateButton =>
      _isPt ? 'Popover com template' : 'Popover with template';
  List<PopoverPaletteDemo> get palettePopovers {
    if (_isPt) {
      return _palettePopoversPt ??= _buildPalettePopovers(isPortuguese: true);
    }
    return _palettePopoversEn ??= _buildPalettePopovers(isPortuguese: false);
  }

  PopoverTemplateDemoContext get richPopoverContext {
    if (_isPt) {
      return _richPopoverContextPt ??= const PopoverTemplateDemoContext(
        title: 'TemplateRef dentro do popover',
        body:
            'Os bindings continuam vivos porque a view AngularDart segue ativa dentro do overlay.',
      );
    }

    return _richPopoverContextEn ??= const PopoverTemplateDemoContext(
      title: 'TemplateRef inside the popover',
      body:
          'Bindings stay live because the AngularDart view remains active inside the overlay.',
    );
  }

  String get noteTitle => _isPt ? 'Quando usar' : 'When to use';
  List<String> get notes => _isPt
      ? const <String>[
          'Tooltip para hint curto.',
          'Popover para contexto mais rico ou ação pontual.',
          'Modal quando o usuário precisa decidir, preencher ou revisar bastante conteúdo.',
        ]
      : const <String>[
          'Tooltip for short hints.',
          'Popover for richer context or a focused action.',
          'Modal when the user must decide, fill, or review a lot of content.',
        ];
  String get apiIntro => _isPt
      ? 'Hoje o pacote expõe tanto helpers imperativos quanto um componente declarativo para casos mais próximos do fluxo AngularDart.'
      : 'Today the package exposes both imperative helpers and a declarative component for flows closer to AngularDart usage.';
    String get overviewTabLabel => _isPt ? 'Visão geral' : 'Overview';
    String get apiTabLabel => 'API';
  String get idleState => _isPt
      ? 'Popover: aguardando interação'
      : 'Popover: waiting for interaction';

  String popoverState = '';

  String get summaryText => popoverState.isEmpty ? idleState : popoverState;

  void showQuickPopover(html.Element target) {
    SimplePopover.showWarning(
      target,
      _isPt
          ? 'Use este padrão para chamar atenção sem abrir um modal.\nClique fora para fechar antes do timeout.'
          : 'Use this pattern to draw attention without opening a modal.\nClick outside to close before timeout.',
      title: _isPt ? 'Aviso rápido' : 'Quick warning',
      timeout: const Duration(seconds: 4),
    );
    popoverState = _isPt
        ? 'Popover: helper simples exibido'
        : 'Popover: simple helper shown';
  }

  void showAnchoredPopover(html.Element target) {
    SweetAlertPopover.showPopover(
      target,
      _isPt
          ? '<strong>Popover com HTML</strong><br>Bom para combinar título, ênfase e mais contexto sem sair do fluxo.'
          : '<strong>HTML popover</strong><br>Good for combining title, emphasis, and more context without leaving the flow.',
      title: _isPt ? 'Popover ancorado' : 'Anchored popover',
      popoverClass: 'popover-custom bg-primary text-white border-primary',
      timeout: const Duration(seconds: 5),
    );
    popoverState = _isPt
        ? 'Popover: helper com Popper exibido'
        : 'Popover: Popper helper shown';
  }

  void toggleManualPopover() {
    manualPopover?.toggle();
    popoverState = _isPt
        ? 'Popover: componente declarativo em modo manual'
        : 'Popover: declarative component in manual mode';
  }

  void onDeclarativeShown() {
    popoverState = _isPt
        ? 'Popover: componente declarativo exibido'
        : 'Popover: declarative component shown';
  }

  void onDeclarativeHidden() {
    popoverState = _isPt
        ? 'Popover: componente declarativo ocultado'
        : 'Popover: declarative component hidden';
  }

  List<PopoverPaletteDemo> _buildPalettePopovers({
    required bool isPortuguese,
  }) {
    return <PopoverPaletteDemo>[
      PopoverPaletteDemo(
        label: 'Primary',
        title: 'Primary popover',
        message: isPortuguese
            ? 'Mantém a leitura forte com fundo principal e texto branco.'
            : 'Keeps strong emphasis with a primary background and white text.',
        buttonClass: 'btn btn-primary',
        popoverClass: 'popover-custom bg-primary text-white border-primary',
        placement: 'bottom',
      ),
      PopoverPaletteDemo(
        label: 'Secondary',
        title: 'Secondary popover',
        message: isPortuguese
            ? 'Útil para contexto neutro sem perder contraste.'
            : 'Useful for neutral context without losing contrast.',
        buttonClass: 'btn btn-secondary',
        popoverClass: 'popover-custom bg-secondary text-white border-secondary',
        placement: 'bottom',
      ),
      PopoverPaletteDemo(
        label: 'Danger',
        title: 'Danger popover',
        message: isPortuguese
            ? 'Bom para ações destrutivas ou alertas críticos.'
            : 'Good for destructive actions or critical alerts.',
        buttonClass: 'btn btn-danger',
        popoverClass: 'popover-custom bg-danger text-white border-danger',
      ),
      PopoverPaletteDemo(
        label: 'Success',
        title: 'Success popover',
        message: isPortuguese
            ? 'Comunica confirmação mantendo o mesmo padrão visual.'
            : 'Communicates confirmation while keeping the same visual pattern.',
        buttonClass: 'btn btn-success',
        popoverClass: 'popover-custom bg-success text-white border-success',
      ),
      PopoverPaletteDemo(
        label: 'Warning',
        title: 'Warning popover',
        message: isPortuguese
            ? 'Destaca cautela em blocos mais chamativos.'
            : 'Highlights caution in more eye-catching blocks.',
        buttonClass: 'btn btn-warning text-white',
        popoverClass: 'popover-custom bg-warning text-white border-warning',
      ),
      PopoverPaletteDemo(
        label: 'Info',
        title: 'Info popover',
        message: isPortuguese
            ? 'Perfeito para contexto informativo e explicações curtas.'
            : 'Perfect for informative context and short explanations.',
        buttonClass: 'btn btn-info text-white',
        popoverClass: 'popover-custom bg-info text-white border-info',
      ),
      PopoverPaletteDemo(
        label: 'Pink',
        title: 'Pink popover',
        message: isPortuguese
            ? 'Mostra que os tons acentuados também seguem o tema.'
            : 'Shows that accent tones also follow the theme.',
        buttonClass: 'btn btn-pink',
        popoverClass: 'popover-custom bg-pink text-white border-pink',
      ),
      PopoverPaletteDemo(
        label: 'Purple',
        title: 'Purple popover',
        message: isPortuguese
            ? 'Útil para destacar grupos temáticos ou categorias.'
            : 'Useful for highlighting thematic groups or categories.',
        buttonClass: 'btn btn-purple',
        popoverClass: 'popover-custom bg-purple text-white border-purple',
      ),
      PopoverPaletteDemo(
        label: 'Indigo',
        title: 'Indigo popover',
        message: isPortuguese
            ? 'Combina bem com ações técnicas ou estados de navegação.'
            : 'Works well with technical actions or navigation states.',
        buttonClass: 'btn btn-indigo',
        popoverClass: 'popover-custom bg-indigo text-white border-indigo',
      ),
      PopoverPaletteDemo(
        label: 'Teal',
        title: 'Teal popover',
        message: isPortuguese
            ? 'Equilibra bem estados positivos com um tom menos comum.'
            : 'Balances positive states with a less common tone.',
        buttonClass: 'btn btn-teal',
        popoverClass: 'popover-custom bg-teal text-white border-teal',
      ),
      PopoverPaletteDemo(
        label: 'Yellow',
        title: 'Yellow popover',
        message: isPortuguese
            ? 'Mantém contraste usando texto escuro e divisor preto suave.'
            : 'Keeps contrast with dark text and a soft black divider.',
        buttonClass: 'btn btn-yellow text-black',
        popoverClass: 'popover-custom bg-yellow text-black border-yellow',
      ),
    ];
  }
}

class PopoverPaletteDemo {
  const PopoverPaletteDemo({
    required this.label,
    required this.title,
    required this.message,
    required this.buttonClass,
    required this.popoverClass,
    this.placement = 'top',
  });

  final String label;
  final String title;
  final String message;
  final String buttonClass;
  final String popoverClass;
  final String placement;
}

class PopoverTemplateDemoContext {
  const PopoverTemplateDemoContext({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}
