import 'package:limitless_ui_example/limitless_ui_example.dart';

@Component(
  selector: 'tooltip-global-config-demo',
  template: '''
    <div class="d-flex flex-wrap gap-2 align-items-center">
      <button
          class="btn btn-outline-secondary"
          type="button"
          [liTooltip]="defaultMessage">
        {{ triggerLabel }}
      </button>
      <span class="text-muted small">
        {{ helperText }}
      </span>
    </div>
  ''',
  directives: [coreDirectives, LiTooltipDirective],
  providers: [ClassProvider(LiTooltipConfig)],
)
class TooltipGlobalConfigDemoComponent {
  TooltipGlobalConfigDemoComponent(this.i18n, this.config) {
    config.triggers = 'click';
    config.placement = 'right';
    config.autoClose = 'outside';
    config.tooltipClass = 'tooltip-config-demo';
  }

  final DemoI18nService i18n;
  final LiTooltipConfig config;
  bool get _isPt => i18n.isPortuguese;

  String get defaultMessage => _isPt
      ? 'Este tooltip herdou seus defaults de um LiTooltipConfig local.'
      : 'This tooltip inherited its defaults from a local LiTooltipConfig.';
    String get triggerLabel => _isPt
      ? 'Tooltip com defaults injetados'
      : 'Tooltip with injected defaults';
    String get helperText => _isPt
      ? 'Neste bloco, os tooltips herdam click, placement="right", autoClose="outside" e uma classe visual própria.'
      : 'In this block, tooltips inherit click, placement="right", autoClose="outside", and a custom visual class.';
}

@Component(
  selector: 'tooltip-page',
  templateUrl: 'tooltip_page.html',
  styleUrls: ['tooltip_page.css'],
  encapsulation: ViewEncapsulation.none,
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
    LiTooltipComponent,
    LiTooltipDirective,
    TooltipGlobalConfigDemoComponent,
  ],
)
class TooltipPageComponent {
  TooltipPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  @ViewChild('manualTooltip')
  LiTooltipDirective? manualTooltip;

  @ViewChild('targetedTooltip')
  LiTooltipDirective? targetedTooltip;

  String tooltipEventLog = '';

    String get overviewIntro => _isPt
      ? 'Tooltips exibem informação contextual breve sem deslocar o usuário para outro bloco da tela.'
      : 'Tooltips show brief contextual information without moving the user to another part of the screen.';
    String get descriptionBody => _isPt
      ? 'Tooltips exibem informação contextual breve sem deslocar o usuário para outro bloco da tela.'
      : 'Tooltips show brief contextual information without moving the user to another part of the screen.';
    List<String> get features => _isPt
      ? const <String>[
        'Triggers por hover, click e modo manual.',
        'Posicionamento em múltiplas direções.',
        'Suporte a HTML e eventos de ciclo de vida.',
      ]
      : const <String>[
        'Triggers through hover, click, and manual mode.',
        'Placement in multiple directions.',
        'Support for HTML and lifecycle events.',
      ];
    List<String> get limits => _isPt
      ? const <String>[
        'Tooltips não devem carregar conteúdo extenso.',
        'Uso excessivo gera ruído e dependência de hover.',
        'Fluxos mobile pedem cuidado com trigger e leitura.',
      ]
      : const <String>[
        'Tooltips should not carry extensive content.',
        'Overuse creates noise and hover dependency.',
        'Mobile flows require care with trigger and readability.',
      ];
    String get autoCloseTitle => _isPt ? 'Fechamento automático' : 'Automatic closing';
    String get autoCloseBody => _isPt
      ? 'Os exemplos abaixo continuam fechando com Escape e variam apenas o clique que dispara o fechamento.'
      : 'The examples below still close with Escape and only vary the click that triggers closing.';
    String get insideTooltipText => _isPt
      ? 'Fecha ao clicar dentro do próprio tooltip.'
      : 'Closes when clicking inside the tooltip itself.';
    String get insideButton => _isPt ? 'clique interno' : 'click inside';
    String get outsideTooltipText => _isPt
      ? 'Fecha ao clicar fora do tooltip.'
      : 'Closes when clicking outside the tooltip.';
    String get outsideButton => _isPt ? 'clique externo' : 'click outside';
    String get allClicksTooltipText => _isPt
      ? 'Fecha em qualquer clique.'
      : 'Closes on any click.';
    String get allClicksButton => _isPt ? 'qualquer clique' : 'all clicks';
    String get containerBodyTitle => _isPt ? 'Anexado ao body' : 'Append tooltip in the body';
    String get containerBodyText => _isPt
      ? 'Quando o gatilho vive dentro de uma área com clipping, container="body" tira o balão desse contexto local.'
      : 'When the trigger lives inside a clipped area, container="body" moves the bubble out of that local context.';
    String get bodyTooltipText => _isPt
      ? 'Este tooltip foi anexado ao body para escapar do clipping local.'
      : 'This tooltip was appended to the body to escape local clipping.';
    String get bodyTooltipButton => _isPt ? 'Tooltip no body' : 'Tooltip in body';
    String get customTargetTitle => _isPt ? 'Alvo customizado' : 'Custom target';
    String get customTargetBody => _isPt
      ? 'O gatilho continua neste botão, mas o balão é posicionado em outro elemento do layout.'
      : 'The trigger stays on this button, but the bubble is positioned on another layout element.';
    String get targetedTooltipText => _isPt
      ? 'O tooltip está ancorado no chip à direita.'
      : 'The tooltip is anchored to the chip on the right.';
    String get targetedTooltipButton => _isPt ? 'Abrir target customizado' : 'Open custom target';
    String get targetedAnchorLabel => _isPt ? 'Âncora visual do tooltip' : 'Tooltip visual anchor';
    String get templateTitle => _isPt ? 'HTML e bindings via TemplateRef' : 'HTML and bindings through TemplateRef';
    String get templateBody => _isPt
      ? 'O tooltip também pode receber um TemplateRef com bindings do componente hospedeiro.'
      : 'The tooltip can also receive a TemplateRef with bindings from the host component.';
    String get templateHeader => _isPt ? 'TemplateRef dentro do tooltip' : 'TemplateRef inside the tooltip';
    String get templateSubtext => _isPt
      ? 'Os bindings continuam vivos porque a view AngularDart segue ativa.'
      : 'Bindings remain alive because the AngularDart view stays active.';
    String get templateButton => _isPt ? 'Tooltip com template' : 'Tooltip with template';
    String get delayTitle => _isPt ? 'Abertura e fechamento com delay' : 'Open and close delays';
    String get delayBody => _isPt
      ? 'O hover pode esperar um pouco para abrir e continuar disponível enquanto o ponteiro entra no próprio balão.'
      : 'Hover can wait a bit before opening and remain available while the pointer enters the bubble itself.';
    String get delayTooltipText => _isPt
      ? 'openDelay 300ms e closeDelay 600ms.'
      : 'openDelay 300ms and closeDelay 600ms.';
    String get delayButton => _isPt ? 'Tooltip com delay' : 'Tooltip with delay';
    String get customClassTitle => _isPt ? 'Classe customizada' : 'Custom class';
    String get customClassBody => _isPt
      ? 'Uma classe adicional permite trocar o tratamento visual sem criar outro componente.'
      : 'An extra class lets you change the visual treatment without creating another component.';
    String get customClassTooltipText => _isPt
      ? 'Tooltip com classe visual própria.'
      : 'Tooltip with its own visual class.';
    String get customClassButton => _isPt ? 'Tooltip customizado' : 'Custom tooltip';
    String get globalConfigTitle => _isPt ? 'Configuração global' : 'Global configuration';
    String get globalConfigBody => _isPt
      ? 'Os defaults podem ser escopados por subtree usando LiTooltipConfig como provider local.'
      : 'Defaults can be scoped by subtree using LiTooltipConfig as a local provider.';
    String get apiIntro => _isPt
      ? 'O componente envolve qualquer gatilho visual e adiciona exibição contextual com configuração declarativa.'
      : 'The component wraps any visual trigger and adds contextual display with declarative configuration.';
    List<String> get apiItems => _isPt
      ? const <String>[
        '[liTooltip] aplica a API por diretiva diretamente no elemento gatilho.',
        '[text] define o conteúdo do tooltip.',
        'placement aceita topo, direita, base e esquerda.',
        'trigger ou triggers aceitam hover, click e manual.',
        'autoClose aceita true, false, inside e outside.',
        'container="body" tira o balão do contexto local e evita clipping por overflow.',
        'positionTarget permite posicionar o tooltip contra outro seletor ou elemento.',
        'tooltipClass aplica uma classe extra ao balão renderizado.',
        '[liTooltip] também aceita TemplateRef para conteúdo rico com bindings.',
        '[html] habilita renderização rica quando necessário.',
        '[showDelayMs], [hideDelayMs], [openDelay] e [closeDelay] refinam o timing.',
        'LiTooltipConfig fornece defaults injetáveis para uma subtree inteira.',
        '(show), (shown), (hide) e (hidden) expõem o ciclo de vida.',
      ]
      : const <String>[
        '[liTooltip] applies the API through a directive directly on the trigger element.',
        '[text] defines the tooltip content.',
        'placement accepts top, right, bottom, and left.',
        'trigger or triggers accept hover, click, and manual.',
        'autoClose accepts true, false, inside, and outside.',
        'container="body" removes the bubble from the local context and avoids overflow clipping.',
        'positionTarget allows positioning the tooltip against another selector or element.',
        'tooltipClass applies an extra class to the rendered bubble.',
        '[liTooltip] also accepts TemplateRef for rich content with bindings.',
        '[html] enables rich rendering when needed.',
        '[showDelayMs], [hideDelayMs], [openDelay], and [closeDelay] refine timing.',
        'LiTooltipConfig provides injectable defaults for an entire subtree.',
        '(show), (shown), (hide), and (hidden) expose the lifecycle.',
      ];
    String get configDemoButton => _isPt
      ? 'Tooltip com defaults injetados'
      : 'Tooltip with injected defaults';
    String get configDemoBody => _isPt
      ? 'Neste bloco, os tooltips herdam click, placement="right", autoClose="outside" e uma classe visual própria.'
      : 'In this block, tooltips inherit click, placement="right", autoClose="outside", and a custom visual class.';
    String get configDemoTitle => _isPt ? 'Demo de config global' : 'Global config demo';
    String get configDemoIntro => _isPt
      ? 'Este bloco injeta LiTooltipConfig localmente com click, placement="right", autoClose="outside" e classe visual própria.'
      : 'This block injects LiTooltipConfig locally with click, placement="right", autoClose="outside", and a custom visual class.';

  void toggleManualTooltip() {
    manualTooltip?.toggle();
  }

  void toggleTargetedTooltip() {
    targetedTooltip?.toggle();
  }

  void onTooltipEvent(String label) {
    tooltipEventLog = t.pages.tooltip.event(label);
  }
}
