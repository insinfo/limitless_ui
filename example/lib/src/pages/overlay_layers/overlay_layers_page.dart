import 'package:limitless_ui_example/limitless_ui_example.dart';

import 'overlay_lab_kit_component.dart';

/// Uma camada da escala, do jeito que a página mostra.
class CamadaDeEmpilhamento {
  const CamadaDeEmpilhamento(this.nome, this.valor, this.motivo);

  final String nome;
  final int valor;
  final String motivo;
}

/// Um contêiner que hospeda o kit de overlays.
class ConteinerDoLaboratorio {
  const ConteinerDoLaboratorio({
    required this.chave,
    required this.titulo,
    required this.descricao,
    required this.rotuloDoBotao,
    required this.classeDoBotao,
    required this.camada,
  });

  final String chave;
  final String titulo;
  final String descricao;
  final String rotuloDoBotao;
  final String classeDoBotao;
  final String camada;
}

/// Demonstração viva da escala de empilhamento dos overlays.
///
/// A página existe porque a ordem entre overlays é o tipo de coisa que só se
/// enxerga com os dois na tela ao mesmo tempo. A tabela é lida de
/// `LiOverlayLayers` em tempo de execução, então ela não envelhece: se alguém
/// mudar a escala, a página passa a mostrar a escala nova.
///
/// O laboratório monta o mesmo kit — todos os overlays ancorados e os
/// bloqueantes que se disparam de dentro de um contêiner — na página, num
/// modal, num segundo modal empilhado, num offcanvas e num modal aberto sobre
/// um offcanvas. É a matriz "componente × contêiner" inteira, para conferir a
/// olho e por teste de navegador que cada um renderiza acima de quem o contém.
@Component(
  selector: 'overlay-layers-page',
  templateUrl: 'overlay_layers_page.html',
  styleUrls: ['overlay_layers_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiModalComponent,
    LiNotificationOutletComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiToastStackComponent,
    OverlayLabKitComponent,
    liOffcanvasDirectives,
  ],
)
class OverlayLayersPageComponent {
  OverlayLayersPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;
  bool get _isPt => i18n.isPortuguese;

  final LiToastService toastService = LiToastService();
  final LiNotificationToastService notificationService =
      LiNotificationToastService();

  @ViewChild('modalKit')
  LiModalComponent? modalKit;

  @ViewChild('modalPai')
  LiModalComponent? modalPai;

  @ViewChild('modalFilho')
  LiModalComponent? modalFilho;

  @ViewChild('offcanvasKit')
  LiOffcanvasComponent? offcanvasKit;

  @ViewChild('offcanvasComModal')
  LiOffcanvasComponent? offcanvasComModal;

  @ViewChild('modalSobreOffcanvas')
  LiModalComponent? modalSobreOffcanvas;

  @ViewChild('offcanvasSobOModal')
  LiOffcanvasComponent? offcanvasSobOModal;

  @ViewChild('kitModal')
  OverlayLabKitComponent? kitModal;

  @ViewChild('kitModalPai')
  OverlayLabKitComponent? kitModalPai;

  @ViewChild('kitModalFilho')
  OverlayLabKitComponent? kitModalFilho;

  @ViewChild('kitOffcanvas')
  OverlayLabKitComponent? kitOffcanvas;

  @ViewChild('kitOffcanvasComModal')
  OverlayLabKitComponent? kitOffcanvasComModal;

  @ViewChild('kitModalSobreOffcanvas')
  OverlayLabKitComponent? kitModalSobreOffcanvas;

  /// As últimas coisas que aconteceram, da mais recente para a mais antiga.
  final List<String> registro = <String>[];

  static const int _tamanhoDoRegistro = 6;

  void registrar(String mensagem) {
    registro.insert(0, mensagem);
    if (registro.length > _tamanhoDoRegistro) {
      registro.removeRange(_tamanhoDoRegistro, registro.length);
    }
  }

  // ---------------------------------------------------------------------------
  // Cabeçalho
  // ---------------------------------------------------------------------------

  String get pageTitle => _isPt ? 'Componentes' : 'Components';
  String get pageSubtitle => 'Overlay layers';
  String get breadcrumb => _isPt
      ? 'Escala de empilhamento e overlays aninhados'
      : 'Stacking scale and nested overlays';

  String get intro => _isPt
      ? 'Uma biblioteca com mais de dez tipos de overlay precisa de uma resposta só para "quem fica por cima". LiOverlayLayers é essa resposta, e esta página existe para vê-la acontecendo: a tabela é lida da biblioteca em tempo de execução e o laboratório monta todos os overlays ancorados dentro de cada contêiner que pode bloqueá-los.'
      : 'A library with more than ten kinds of overlay needs a single answer to "what sits on top". LiOverlayLayers is that answer, and this page exists to watch it happen: the table is read from the library at runtime and the lab mounts every anchored overlay inside each container that could block it.';

  String get descriptionBody => _isPt
      ? 'LiOverlayLayers é a escala única de empilhamento: cada overlay da biblioteca nasce numa camada com nome, e os ancorados resolvem o z-index na hora de abrir para subir pelo modal, diálogo ou alerta que os contém.'
      : 'LiOverlayLayers is the single stacking scale: every overlay in the library is born on a named layer, and anchored ones resolve their z-index at open time to clear the modal, dialog or alert that contains them.';

  List<String> get features => _isPt
      ? const <String>[
          'Camadas nomeadas e mutáveis, alinháveis à escala da aplicação a partir do main().',
          'LiOverlayStack.resolve sobe um overlay ancorado pelo contêiner bloqueante que o envolve.',
          'A lista de seletores bloqueantes é extensível pela aplicação.',
          'Kit com todos os overlays montado em cada contêiner, para testar a matriz completa.',
        ]
      : const <String>[
          'Named, mutable layers that an application aligns to its own scale from main().',
          'LiOverlayStack.resolve lifts an anchored overlay above the blocking container around it.',
          'The list of blocking selectors is extensible by the application.',
          'A kit with every overlay mounted in each container, to test the whole matrix.',
        ];

  List<String> get limits => _isPt
      ? const <String>[
          'A cortina de carregamento fica acima de tudo por decisão: um diálogo aberto com ela no ar nasce por baixo.',
          'Um overlay ancorado resolve o z-index na primeira abertura; um modal que aparecer depois em volta dele só é superado por uma instância nova.',
          'O offcanvas nasce sob o modal (1150 < 1200); só sobe por ele quando é aberto com o modal já no ar.',
        ]
      : const <String>[
          'The loading curtain is above everything by design: a dialog opened while it is up is born underneath.',
          'An anchored overlay resolves its z-index on first open; a modal that shows up around it later is only cleared by a fresh instance.',
          'The offcanvas is born under the modal (1150 < 1200); it only clears one that is already up when it opens.',
        ];

  // ---------------------------------------------------------------------------
  // A escala, lida da biblioteca — nunca digitada aqui.
  // ---------------------------------------------------------------------------

  String get tituloDaEscala => _isPt ? 'A escala' : 'The scale';
  String get textoDaEscala => _isPt
      ? 'Os valores abaixo vêm de LiOverlayLayers no momento em que a página desenha. Se a aplicação mudar a escala no main(), esta tabela muda junto.'
      : 'The values below come from LiOverlayLayers at the moment the page draws. If the application changes the scale in main(), this table changes with it.';
  String get colunaCamada => _isPt ? 'Camada' : 'Layer';
  String get colunaMotivo => _isPt ? 'Por que ali' : 'Why there';

  // As listas de objetos são memorizadas por idioma: um getter que devolve
  // instâncias novas a cada change detection faz o `ngFor` recriar as linhas
  // e os botões a cada ciclo — e um botão recriado entre o `mousedown` e o
  // `mouseup` nunca recebe o `click`.
  bool? _idiomaDasCamadas;
  List<CamadaDeEmpilhamento>? _camadas;

  List<CamadaDeEmpilhamento> get camadas {
    if (_camadas == null || _idiomaDasCamadas != _isPt) {
      _idiomaDasCamadas = _isPt;
      _camadas = _montarCamadas();
    }
    return _camadas!;
  }

  List<CamadaDeEmpilhamento> _montarCamadas() => <CamadaDeEmpilhamento>[
        CamadaDeEmpilhamento(
          'anchored',
          LiOverlayLayers.anchored,
          _isPt
              ? 'preso a um campo: acima da página, abaixo do que bloqueia'
              : 'attached to a field: above the page, below anything blocking',
        ),
        CamadaDeEmpilhamento(
          'anchoredMenu',
          LiOverlayLayers.anchoredMenu,
          _isPt
              ? 'um acima do modal do tema, para menu dentro de modal funcionar'
              : "one above the theme's modal, so a menu inside a modal is usable",
        ),
        CamadaDeEmpilhamento(
          'anchoredTooltip',
          LiOverlayLayers.anchoredTooltip,
          _isPt
              ? 'o nível que o próprio tema usa'
              : "the theme's own tooltip level",
        ),
        CamadaDeEmpilhamento(
          'anchoredPicker',
          LiOverlayLayers.anchoredPicker,
          _isPt
              ? 'acima do tooltip, porque picker recebe clique e tooltip não'
              : 'above the tooltip, because a picker takes clicks and a tooltip does not',
        ),
        CamadaDeEmpilhamento(
          'offcanvas',
          LiOverlayLayers.offcanvas,
          _isPt
              ? 'passa sobre a página, vai sob o modal'
              : 'slides over the page, goes under a modal',
        ),
        CamadaDeEmpilhamento(
          'modal',
          LiOverlayLayers.modal,
          _isPt
              ? 'mais ${LiOverlayLayers.modalStep} por modal empilhado'
              : 'plus ${LiOverlayLayers.modalStep} for each stacked modal',
        ),
        CamadaDeEmpilhamento(
          'dialog',
          LiOverlayLayers.dialog,
          _isPt
              ? 'é uma pergunta, então vem sobre qualquer modal'
              : 'a question, so it comes over any modal',
        ),
        CamadaDeEmpilhamento(
          'toastStack',
          LiOverlayLayers.toastStack,
          _isPt
              ? 'um aviso precisa ser legível sobre o diálogo a que se refere'
              : 'a notice has to be readable over the dialog it refers to',
        ),
        CamadaDeEmpilhamento(
          'alert',
          LiOverlayLayers.alert,
          _isPt
              ? 'interrompe tudo abaixo para ser respondido'
              : 'interrupts everything below to be answered',
        ),
        CamadaDeEmpilhamento(
          'notificationToast',
          LiOverlayLayers.notificationToast,
          _isPt
              ? 'mesma razão do toastStack, um nível acima'
              : 'same reasoning as toastStack, one level up',
        ),
        CamadaDeEmpilhamento(
          'loadingTarget',
          LiOverlayLayers.loadingTarget,
          _isPt
              ? 'cobre só o próprio contêiner'
              : 'covers its own container only',
        ),
        CamadaDeEmpilhamento(
          'loadingBody',
          LiOverlayLayers.loadingBody,
          _isPt
              ? 'cobre a página, acima de tudo, de propósito'
              : 'covers the page, above everything, on purpose',
        ),
        CamadaDeEmpilhamento(
          'targetAlert',
          LiOverlayLayers.targetAlert,
          _isPt
              ? 'substitui uma cortina que falhou; precisa aparecer sobre ela'
              : 'replaces a curtain that failed; has to show over it',
        ),
      ];

  // ---------------------------------------------------------------------------
  // Laboratório: o mesmo kit em cada contêiner
  // ---------------------------------------------------------------------------

  String get tituloDoLaboratorio =>
      _isPt ? 'Laboratório de combinações' : 'Combination lab';
  String get textoDoLaboratorio => _isPt
      ? 'O kit abaixo reúne todos os overlays ancorados da biblioteca — select, multi-select, typeahead, treeview, tag filter, os três dropdowns, os menus do datatable, o menu do token field, o datatable-select (que abre um modal próprio), os quatro pickers, tooltip e os três popovers — e os bloqueantes que se disparam de dentro de um contêiner. Cada botão abre um contêiner com o mesmo kit dentro. Abra cada overlay e confira: ele tem de ficar acima do que o contém e receber o clique.'
      : 'The kit below gathers every anchored overlay in the library — select, multi-select, typeahead, treeview, tag filter, the three dropdowns, the datatable menus, the token field menu, the datatable-select (which opens a modal of its own), the four pickers, tooltip and the three popovers — plus the blocking overlays fired from inside a container. Each button opens a container with the same kit inside. Open each overlay and check: it has to sit above its container and take the click.';
  String get tituloDoKitNaPagina => _isPt
      ? 'Na página, sem contêiner bloqueante'
      : 'On the page, with no blocking container';
  String get textoDoKitNaPagina => _isPt
      ? 'Referência: aqui cada overlay nasce na própria camada base da tabela acima.'
      : 'Baseline: here each overlay is born on its own base layer from the table above.';
  String get tituloDoRegistro => _isPt ? 'Registro' : 'Log';
  String get registroVazio => _isPt
      ? 'Abra um overlay de dentro de qualquer contêiner: o kit registra aqui o que abriu, onde e em que camada.'
      : 'Open an overlay from inside any container: the kit logs here what opened, where and on which layer.';

  bool? _idiomaDosConteineres;
  List<ConteinerDoLaboratorio>? _conteineres;

  List<ConteinerDoLaboratorio> get conteineres {
    if (_conteineres == null || _idiomaDosConteineres != _isPt) {
      _idiomaDosConteineres = _isPt;
      _conteineres = _montarConteineres();
    }
    return _conteineres!;
  }

  List<ConteinerDoLaboratorio> _montarConteineres() => <ConteinerDoLaboratorio>[
        ConteinerDoLaboratorio(
          chave: 'modal',
          titulo: _isPt ? 'Dentro de um modal' : 'Inside a modal',
          descricao: _isPt
              ? 'Cada overlay ancorado tem de subir acima do modal (${LiOverlayLayers.modal}).'
              : 'Every anchored overlay has to rise above the modal (${LiOverlayLayers.modal}).',
          rotuloDoBotao: _isPt ? 'Abrir modal' : 'Open modal',
          classeDoBotao: 'btn btn-primary',
          camada: 'modal',
        ),
        ConteinerDoLaboratorio(
          chave: 'stacked',
          titulo: _isPt ? 'Modal empilhado' : 'Stacked modal',
          descricao: _isPt
              ? 'Kit no primeiro modal e no segundo (${LiOverlayLayers.modal + LiOverlayLayers.modalStep}); o segundo é quem manda.'
              : 'Kit in the first modal and in the second one (${LiOverlayLayers.modal + LiOverlayLayers.modalStep}); the second is the one that counts.',
          rotuloDoBotao: _isPt ? 'Abrir modais' : 'Open modals',
          classeDoBotao: 'btn btn-outline-primary',
          camada: 'modal + modalStep',
        ),
        ConteinerDoLaboratorio(
          chave: 'offcanvas',
          titulo: _isPt ? 'Dentro de um offcanvas' : 'Inside an offcanvas',
          descricao: _isPt
              ? 'O offcanvas (${LiOverlayLayers.offcanvas}) é anexado ao body em tempo de execução; o kit vai junto.'
              : 'The offcanvas (${LiOverlayLayers.offcanvas}) is appended to the body at runtime; the kit goes with it.',
          rotuloDoBotao: _isPt ? 'Abrir offcanvas' : 'Open offcanvas',
          classeDoBotao: 'btn btn-outline-indigo',
          camada: 'offcanvas',
        ),
        ConteinerDoLaboratorio(
          chave: 'modal-over-offcanvas',
          titulo: _isPt ? 'Modal sobre offcanvas' : 'Modal over offcanvas',
          descricao: _isPt
              ? 'Um offcanvas com o kit e um botão que abre um modal por cima, também com o kit.'
              : 'An offcanvas with the kit and a button that opens a modal on top, also with the kit.',
          rotuloDoBotao: _isPt ? 'Abrir offcanvas' : 'Open offcanvas',
          classeDoBotao: 'btn btn-outline-dark',
          camada: 'offcanvas → modal',
        ),
      ];

  void abrirConteiner(String chave) {
    switch (chave) {
      case 'modal':
        modalKit?.open();
        break;
      case 'stacked':
        modalPai?.open();
        break;
      case 'offcanvas':
        offcanvasKit?.open();
        break;
      case 'modal-over-offcanvas':
        offcanvasComModal?.open();
        break;
    }
    registrar(_isPt
        ? 'Contêiner "$chave" aberto. A faixa no topo do kit diz o que o envolve e a que z-index cada overlay vai subir.'
        : 'Container "$chave" opened. The strip at the top of the kit says what surrounds it and what z-index each overlay will rise to.');
  }

  void abrirModalFilho() {
    modalFilho?.open();
  }

  void abrirModalSobreOffcanvas() {
    modalSobreOffcanvas?.open();
  }

  /// O offcanvas nasce em 1150, sob o modal; aberto com o modal no ar, ele
  /// resolve o z-index na hora e sobe por ele, como todo overlay ancorado.
  void abrirOffcanvasSobOModal() {
    offcanvasSobOModal?.open();
    registrar(_isPt
        ? 'Offcanvas aberto de dentro do modal (${LiOverlayLayers.modal}): a base dele é ${LiOverlayLayers.offcanvas}, mas com o modal no ar ele resolve o z-index na hora e sobe por ele.'
        : 'Offcanvas opened from inside the modal (${LiOverlayLayers.modal}): its base is ${LiOverlayLayers.offcanvas}, but with the modal up it resolves the z-index on the spot and clears it.');
  }

  String get tituloModalKit => _isPt ? 'Kit dentro do modal' : 'Kit inside the modal';
  String get tituloModalPai => _isPt ? 'Primeiro modal' : 'First modal';
  String get tituloModalFilho => _isPt ? 'Segundo modal' : 'Second modal';
  String get tituloOffcanvasKit =>
      _isPt ? 'Kit dentro do offcanvas' : 'Kit inside the offcanvas';
  String get tituloOffcanvasComModal =>
      _isPt ? 'Offcanvas com modal por cima' : 'Offcanvas with a modal on top';
  String get tituloModalSobreOffcanvas =>
      _isPt ? 'Modal sobre o offcanvas' : 'Modal over the offcanvas';
  String get tituloOffcanvasSobOModal =>
      _isPt ? 'Offcanvas aberto do modal' : 'Offcanvas opened from the modal';
  String get textoOffcanvasSobOModal => _isPt
      ? 'Na escala o offcanvas (${LiOverlayLayers.offcanvas}) fica sob o modal (${LiOverlayLayers.modal}): um offcanvas é navegação, um modal é uma tarefa. Mas este foi aberto de dentro de um modal, e aí ele resolve o z-index na hora de abrir e sobe pelo modal — quem abre por último fica por cima, como no PrimeNG e no CDK. No Bootstrap puro ele nasceria atrás.'
      : 'On the scale the offcanvas (${LiOverlayLayers.offcanvas}) sits under the modal (${LiOverlayLayers.modal}): an offcanvas is navigation, a modal is a task. But this one was opened from inside a modal, so it resolves its z-index at open time and clears the modal — whoever opens last is on top, as in PrimeNG and the CDK. In plain Bootstrap it would be born behind.';
  String get rotuloAbrirSegundoModal =>
      _isPt ? 'Abrir o segundo modal' : 'Open the second modal';
  String get rotuloAbrirModalSobreOffcanvas =>
      _isPt ? 'Abrir modal por cima' : 'Open a modal on top';
  String get rotuloAbrirOffcanvasSobOModal => _isPt
      ? 'Abrir offcanvas daqui (sobe pelo modal)'
      : 'Open an offcanvas from here (clears the modal)';
  String get rotuloFechar => _isPt ? 'Fechar' : 'Close';
  String get rotuloHostPagina => _isPt ? 'Página' : 'Page';
  String get rotuloHostModal => 'Modal';
  String get rotuloHostModalPai => _isPt ? '1º modal' : '1st modal';
  String get rotuloHostModalFilho => _isPt ? '2º modal' : '2nd modal';
  String get rotuloHostOffcanvas => 'Offcanvas';
  String get rotuloHostOffcanvasComModal =>
      _isPt ? 'Offcanvas (base)' : 'Offcanvas (base)';
  String get rotuloHostModalSobreOffcanvas =>
      _isPt ? 'Modal sobre offcanvas' : 'Modal over offcanvas';
  String get textoModalPai => _isPt
      ? 'Este é o primeiro modal (${LiOverlayLayers.modal}). Abra o segundo: ele desenha em ${LiOverlayLayers.modal + LiOverlayLayers.modalStep}, e os overlays abertos de dentro dele têm de subir por ele, não pelo primeiro.'
      : 'This is the first modal (${LiOverlayLayers.modal}). Open the second one: it draws at ${LiOverlayLayers.modal + LiOverlayLayers.modalStep}, and overlays opened from inside it have to rise above it, not above the first.';
  String get textoOffcanvasComModal => _isPt
      ? 'Este offcanvas está em ${LiOverlayLayers.offcanvas}. Abra o modal por cima: ele desenha em ${LiOverlayLayers.modal} e os overlays de dentro dele têm de subir pelo modal, não pelo offcanvas.'
      : 'This offcanvas is at ${LiOverlayLayers.offcanvas}. Open the modal on top: it draws at ${LiOverlayLayers.modal} and overlays from inside it have to rise above the modal, not the offcanvas.';

  // ---------------------------------------------------------------------------
  // A cortina fica acima de tudo — e o que isso custa
  // ---------------------------------------------------------------------------

  String get tituloDaCortina => _isPt
      ? 'A cortina fica acima de tudo — e o que isso custa'
      : 'The curtain is above everything — and what that costs';
  String get textoDaCortina1 => _isPt
      ? 'loadingBody supera todo diálogo por decisão: a cortina existe para impedir que o operador navegue, clique de novo no botão que grava ou abra outro modal enquanto a operação corre. O preço é que um diálogo levantado com ela no ar nasce por baixo — ilegível e sem receber clique. Com await isso vira tela morta, porque o finally que fecharia a cortina só roda depois de o operador responder.'
      : 'loadingBody outranks every dialog by design: the curtain exists to keep the operator from navigating, clicking the save button twice or opening another modal while the operation runs. The price is that a dialog raised while it is up is born underneath — unreadable and taking no clicks. With await that freezes the page, because the finally that would hide the curtain only runs once the operator answers.';
  String get textoDaCortina2 => _isPt
      ? 'A biblioteca não resolve isso no lugar de quem chama: componente que derruba o estado de outro produz efeito colateral que ninguém pediu. Fechar a cortina onde a operação termina é decisão da aplicação; LiSimpleLoading.hideAll() existe para quem quiser concentrar isso num lugar só.'
      : 'The library does not resolve this for the caller: a component knocking down another component\'s state is a side effect nobody asked for. Hiding the curtain where the operation ends is the application\'s call; LiSimpleLoading.hideAll() is there for whoever wants to enforce that in one place.';
  String get rotuloCortinaFeitaDireito =>
      _isPt ? 'Cortina fechada antes de falar' : 'Curtain hidden before speaking';
  String get rotuloCortinaResgatada => _isPt
      ? 'hideAll() como rede de proteção'
      : 'hideAll() as the safety net';

  /// A armadilha, e a saída.
  ///
  /// Mostra a cortina, espera, e **fecha antes** de falar. Sem o `hide()` o
  /// diálogo nasceria por baixo e o `await` nunca voltaria.
  Future<void> cortinaFeitaDireito() async {
    final cortina = LiSimpleLoading()..showOnBody();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    } finally {
      // Antes de falar. `hide()` é idempotente, então repetir não custa nada.
      cortina.hide();
    }
    await LiSimpleDialogComponent.showConfirm(
      _isPt
          ? 'A cortina saiu antes deste diálogo aparecer — por isso dá para ler e clicar. Com ela no ar, este botão não receberia o clique.'
          : 'The curtain left before this dialog appeared — which is why it can be read and clicked. With it up, this button would take no click.',
      title: _isPt ? 'Operação concluída' : 'Operation complete',
    );
    registrar(_isPt
        ? 'Cortina fechada antes do diálogo. É a regra.'
        : 'Curtain hidden before the dialog. That is the rule.');
  }

  /// A rede de proteção, para quem centraliza a decisão num lugar só.
  Future<void> cortinaEsquecidaMasResgatada() async {
    LiSimpleLoading().showOnBody();
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Ninguém guardou a instância — é exatamente o caso em que `hide()` não
    // tem como ser chamado. `hideAll()` fecha o que estiver no ar.
    final fechadas = LiSimpleLoading.hideAll();
    registrar(_isPt
        ? 'hideAll() fechou $fechadas cortina(s). A biblioteca não faz isso sozinha ao abrir um diálogo: derrubar a cortina de quem não pediu destravaria a página no meio da operação que ela protege.'
        : 'hideAll() closed $fechadas curtain(s). The library does not do this on its own when a dialog opens: knocking down a curtain nobody asked to remove would unblock the page in the middle of the very operation it protects.');
  }

  // ---------------------------------------------------------------------------
  // API
  // ---------------------------------------------------------------------------

  String get apiIntro => _isPt
      ? 'LiOverlayLayers guarda a escala; LiOverlayStack aplica a regra do overlay ancorado; resolveModalAwarePortalOptions é a mesma regra no formato que os portais do popper consomem. Nada disso precisa ser chamado por quem só usa os componentes — é para quem escreve um overlay novo ou precisa alinhar a biblioteca à escala da aplicação.'
      : 'LiOverlayLayers holds the scale; LiOverlayStack applies the anchored-overlay rule; resolveModalAwarePortalOptions is the same rule in the shape the popper portals consume. None of it has to be called by whoever just uses the components — it is for whoever writes a new overlay or has to align the library to the application\'s scale.';

  List<String> get apiItems => _isPt
      ? const <String>[
          'LiOverlayLayers.* — um campo estático mutável por camada; os componentes leem na hora de abrir.',
          'LiOverlayLayers.modalStep — distância entre dois modais empilhados; stackOffset — distância de um overlay ancorado ao contêiner que ele precisa superar.',
          'LiOverlayStack.resolve(referenceElement:, baseZIndex:) — nunca abaixo da base; acima do contêiner bloqueante que contém a referência, ou do mais alto na tela.',
          'LiOverlayStack.blockingSelectors — lista mutável do que conta como bloqueante (li-modal, LiSimpleDialog, SweetAlert, li-offcanvas). Acrescente o seletor da sua camada.',
          'LiOverlayStack.owningBlockingContainer(element) e topmostBlockingZIndex() — as duas metades da regra, expostas para diagnóstico.',
          'resolveModalAwarePortalOptions(...) — PopperPortalOptions com host e painel já resolvidos; o nome fala em "modal" por compatibilidade.',
          'LiSimpleLoading.hideAll() e mountedCount — fecham e contam as cortinas no ar.',
        ]
      : const <String>[
          'LiOverlayLayers.* — one mutable static field per layer; components read it at open time.',
          'LiOverlayLayers.modalStep — distance between two stacked modals; stackOffset — distance from an anchored overlay to the container it has to clear.',
          'LiOverlayStack.resolve(referenceElement:, baseZIndex:) — never below the base; above the blocking container that owns the reference, or the topmost one on screen.',
          'LiOverlayStack.blockingSelectors — mutable list of what counts as blocking (li-modal, LiSimpleDialog, SweetAlert, li-offcanvas). Add the selector of your own layer.',
          'LiOverlayStack.owningBlockingContainer(element) and topmostBlockingZIndex() — the two halves of the rule, exposed for diagnostics.',
          'resolveModalAwarePortalOptions(...) — PopperPortalOptions with host and panel already resolved; the name says "modal" for compatibility.',
          'LiSimpleLoading.hideAll() and mountedCount — hide and count the curtains on screen.',
        ];

  String get tituloSnippetDaEscala =>
      _isPt ? 'Alinhando a biblioteca à sua escala' : 'Aligning the library to your scale';
  String get tituloSnippetDaRegra =>
      _isPt ? 'A regra, para um overlay novo' : 'The rule, for a new overlay';
  String get tituloSnippetDaCortina =>
      _isPt ? 'A cortina, feita direito' : 'The curtain, done right';

  static const String snippetDaEscala = '''
// Alinhe a biblioteca à escala que a sua aplicação já tem, do main():
void main() {
  LiOverlayLayers.modal = 3200;
  LiOverlayLayers.dialog = 3400;
  runApp(...);
}

// Faça os overlays da biblioteca subirem pela SUA camada bloqueante:
LiOverlayStack.blockingSelectors.add('.minha-cortina-de-assinatura');
''';

  static const String snippetDaRegra = '''
// Um overlay ancorado novo pede o z-index na hora de abrir:
final zIndex = LiOverlayStack.resolve(
  referenceElement: trigger,               // o elemento a que ele se prende
  baseZIndex: LiOverlayLayers.anchoredMenu, // a camada em que ele nasce
);

// Ou, se ele usa um portal do popper, tudo de uma vez:
final portal = resolveModalAwarePortalOptions(
  hostClassName: 'MeuOverlayPortal',
  referenceElement: trigger,
  baseHostZIndex: LiOverlayLayers.anchoredMenu,
);
''';

  static const String snippetDaCortina = '''
// A cortina fica acima de tudo de propósito: é ela que impede um segundo
// clique enquanto a operação corre. Por isso, feche-a ANTES de falar.
final loading = LiSimpleLoading()..showOnBody();
try {
  await servico.gravar();
} catch (e) {
  loading.hide();            // <- antes do diálogo, sempre
  await LiSimpleDialogComponent.showConfirm('Tentar de novo?');
} finally {
  loading.hide();            // idempotente
}
''';
}
