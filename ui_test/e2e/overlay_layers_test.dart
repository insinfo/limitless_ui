import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

import 'puppeteer_setup.dart';

/// Um overlay ancorado do kit: como abrir, o que aparece e onde cutucar.
class _Overlay {
  const _Overlay(this.nome, {
    required this.gatilho,
    required this.painel,
    this.sonda,
    this.fechar,
  });

  final String nome;

  /// Seletor do gatilho, procurado dentro do contêiner (`[data-host=...]`).
  final String gatilho;

  /// Seletor do painel aberto. Pode estar em qualquer lugar do documento —
  /// quase todos vão parar no `body`.
  final String painel;

  /// Elemento dentro do painel cujo centro é testado com `elementFromPoint`.
  /// Nulo usa o próprio painel.
  final String? sonda;

  /// Como fechar depois de medir. Nulo clica num ponto neutro do kit; um
  /// overlay que abre um modal próprio precisa fechar pelo botão do modal,
  /// porque o modal cobre o ponto neutro.
  final String? fechar;
}

/// Um contêiner que hospeda o kit e como chegar até ele.
class _Conteiner {
  const _Conteiner(this.chave, this.abrir);

  final String chave;

  /// Cliques a dar, em ordem, a partir da página recém-carregada.
  final List<String> abrir;
}

const List<_Overlay> _ancorados = <_Overlay>[
  _Overlay('li-select',
      gatilho: '[data-label="li_select_toggle"]',
      painel: '[data-label="li_select_opts"]',
      sonda: '[data-label="li_select_item_0"]'),
  _Overlay('li-multi-select',
      gatilho: '[data-label="li_ms_toggle"]',
      painel: '[data-label="li_ms_opts"]',
      sonda: '[data-label="li_ms_item_0"]'),
  _Overlay('li-typeahead',
      gatilho: '[data-label="li_ta_input"]',
      painel: '[data-label="li_ta_popup"]',
      sonda: '[data-label="li_ta_item_0"]'),
  _Overlay('li-treeview-select',
      gatilho: '[data-label="li_ts_toggle"]',
      painel: '[data-label="li_ts_panel"]',
      sonda: '[data-label="li_ts_label"]'),
  _Overlay('li-tag-filter',
      gatilho: '[data-label="li_tf_toggle"]',
      painel: '[data-label="li_tf_panel"]',
      sonda: '[data-label="li_tf_option_0"]'),
  _Overlay('li-dropdown-menu',
      gatilho: '[data-label="li_dm_btn_toggle"]',
      painel: '[data-label="li_dm_panel"]',
      sonda: '[data-label="li_dm_item"]'),
  _Overlay('liDropdown',
      gatilho: '[data-label="overlay_lab_dropdown_toggle"]',
      painel: '[data-label="overlay_lab_dropdown_menu"]',
      sonda: '[data-label="overlay_lab_dropdown_item"]'),
  _Overlay('liDropdownMenuPosition',
      gatilho: '[data-label="overlay_lab_position_toggle"]',
      painel: '[data-label="overlay_lab_position_menu"]',
      sonda: '[data-label="overlay_lab_position_item"]'),
  _Overlay('li-datatable overflow',
      gatilho: '.datatable-action-overflow-toggle',
      painel: '.datatable-action-overflow-menu',
      sonda: '.dropdown-item'),
  _Overlay('li-token-field',
      gatilho: '[data-label="li_token_menu"] [data-label="li_dm_btn_toggle"]',
      painel: '[data-label="li_dm_panel"]',
      sonda: '[data-label="li_dm_item"]'),
  // Abre um li-modal próprio: dentro de um modal vira o segundo da pilha, e
  // é o último `.modal` aberto no DOM.
  _Overlay('li-datatable-select',
      gatilho: '[data-label="li_dts_toggle"]',
      painel: '.modal[data-status="open"]',
      sonda: '[data-label="li_dt"]',
      fechar: '[data-label="li_mdl_close"]'),
  _Overlay('li-date-picker',
      gatilho: '[data-label="li_dp_trigger"]',
      painel: '[data-label="li_dp_panel"]',
      sonda: '[data-label="li_dp_day"]'),
  _Overlay('li-date-range-picker',
      gatilho: '[data-label="li_drp_trigger"]',
      painel: '[data-label="li_drp_panel"]',
      sonda: '[data-label="li_drp_day"]'),
  _Overlay('li-time-picker',
      gatilho: '[data-label="li_tp_trigger"]',
      painel: '[data-label="li_tp_panel"]',
      sonda: '[data-label="li_tp_hour_input"]'),
  // Sem sonda: o painel abre na área de gradiente, e a paleta de amostras
  // fica escondida atrás de um botão.
  _Overlay('li-color-picker',
      gatilho: '[data-label="li_cp_trigger"]',
      painel: '[data-label="li_cp_panel"]'),
  // A diretiva escreve o próprio `data-label` no host.
  _Overlay('liTooltip',
      gatilho: '[data-label="li_tooltip_trigger"]',
      painel: '.tooltip.show'),
  _Overlay('li-popover',
      gatilho: '[data-label="overlay_lab_popover"]',
      painel: '.popover.show',
      sonda: '.popover-body'),
  _Overlay('LiSimplePopover',
      gatilho: '[data-label="overlay_lab_simple_popover"]',
      painel: '#simple-popover-root',
      sonda: '.popover-body'),
  _Overlay('SweetAlertPopover',
      gatilho: '[data-label="overlay_lab_swal_popover"]',
      painel: '[data-label="li_sa_popover"]',
      sonda: '.popover-body'),
];

const List<_Conteiner> _conteineres = <_Conteiner>[
  _Conteiner('page', <String>[]),
  _Conteiner('modal', <String>[
    '[data-label="overlay_lab_open"][data-value="modal"]',
  ]),
  _Conteiner('stacked-child', <String>[
    '[data-label="overlay_lab_open"][data-value="stacked"]',
    '[data-label="overlay_lab_open_child"]',
  ]),
  _Conteiner('offcanvas', <String>[
    '[data-label="overlay_lab_open"][data-value="offcanvas"]',
  ]),
  _Conteiner('modal-over-offcanvas', <String>[
    '[data-label="overlay_lab_open"][data-value="modal-over-offcanvas"]',
    '[data-label="overlay_lab_open_modal_over"]',
  ]),
];

/// Abre o contêiner e espera o kit dele estar medido.
Future<void> _abrirConteiner(Page page, _Conteiner conteiner) async {
  await gotoExample(page, 'overlay-layers');
  for (final seletor in conteiner.abrir) {
    await clickFirstVisible(page, seletor);
    await aguarde(400);
  }
  await waitForSelectorMatching(
    page,
    '[data-host="${conteiner.chave}"] [data-label="overlay_lab_diag"]',
  );
  // O kit mede o contêiner 350ms depois de montar.
  await aguarde(500);
}

/// Testa se o painel aberto está mesmo por cima: o centro da sonda tem de
/// devolver um elemento de dentro do painel em `elementFromPoint`.
///
/// Devolve `null` quando está tudo certo, ou a descrição do que foi achado
/// no lugar — inclusive o z-index efetivo do painel e o do intruso, para o
/// erro contar a história inteira.
Future<String?> _painelRecebeOClique(
  Page page,
  _Overlay overlay, {
  Duration timeout = const Duration(seconds: 3),
}) async {
  // Os painéis abrem com transição; a primeira medida pode pegar o meio do
  // fade. Repete até ficar bom ou o tempo acabar — e devolve o último erro.
  final stopwatch = Stopwatch()..start();
  String? ultimo;
  while (true) {
    ultimo = await _medirPainel(page, overlay);
    if (ultimo == null || stopwatch.elapsed > timeout) {
      return ultimo;
    }
    await aguarde(150);
  }
}

Future<String?> _medirPainel(Page page, _Overlay overlay) async {
  final resultado = await page.evaluate<dynamic>(
    r'''(painelCss, sondaCss) => {
      const visivel = (el) => {
        if (!el) return false;
        const rect = el.getBoundingClientRect();
        const style = window.getComputedStyle(el);
        return rect.width > 0 && rect.height > 0 &&
          style.display !== 'none' && style.visibility !== 'hidden' &&
          style.opacity !== '0';
      };
      const descreve = (el) => {
        if (!el) return 'null';
        const id = el.id ? '#' + el.id : '';
        const classes = el.className && typeof el.className === 'string'
          ? '.' + el.className.trim().split(/\s+/).slice(0, 3).join('.')
          : '';
        const label = el.getAttribute && el.getAttribute('data-label');
        return el.tagName.toLowerCase() + id + classes +
          (label ? '[data-label=' + label + ']' : '');
      };
      // O z-index que conta para empilhar contra o contêiner é o do ancestral
      // posicionado mais perto do body — o host do portal, quase sempre.
      const zEfetivo = (el) => {
        let z = null;
        let atual = el;
        while (atual && atual !== document.body) {
          const style = window.getComputedStyle(atual);
          const valor = parseInt(style.zIndex, 10);
          if (!Number.isNaN(valor) && style.position !== 'static') {
            z = valor;
          }
          atual = atual.parentElement;
        }
        return z;
      };

      const paineis = [...document.querySelectorAll(painelCss)].filter(visivel);
      if (paineis.length === 0) {
        return 'painel nao esta visivel: ' + painelCss;
      }
      const painel = paineis[paineis.length - 1];
      let sonda = painel;
      if (sondaCss) {
        const sondas = [...painel.querySelectorAll(sondaCss)].filter(visivel);
        if (sondas.length === 0) {
          return 'sonda nao esta visivel dentro do painel: ' + sondaCss;
        }
        sonda = sondas[0];
      }
      const rect = sonda.getBoundingClientRect();
      const x = rect.left + rect.width / 2;
      const y = rect.top + rect.height / 2;
      const alvo = document.elementFromPoint(x, y);
      if (alvo && painel.contains(alvo)) {
        return null;
      }
      return 'elementFromPoint devolveu ' + descreve(alvo) +
        ' (z efetivo ' + zEfetivo(alvo) + ') em vez de algo dentro de ' +
        descreve(painel) + ' (z efetivo ' + zEfetivo(painel) + ')';
    }''',
    args: <dynamic>[overlay.painel, overlay.sonda],
  );
  return resultado?.toString();
}

/// Fecha o que estiver aberto clicando num ponto neutro do próprio kit —
/// dentro do contêiner, para não fechar o contêiner junto. Com [fechar], usa
/// esse botão no último painel aberto (o modal de cima da pilha).
Future<void> _fecharOQueEstiverAberto(
  Page page,
  String chave, {
  _Overlay? overlay,
}) async {
  final fechar = overlay?.fechar;
  if (fechar != null) {
    await page.evaluate(
      r'''(painelCss, botaoCss) => {
        const visivel = (el) => { const r = el.getBoundingClientRect(); return r.width > 0 && r.height > 0; };
        const paineis = [...document.querySelectorAll(painelCss)].filter(visivel);
        const painel = paineis[paineis.length - 1];
        const botao = painel && painel.querySelector(botaoCss);
        if (botao) botao.click();
      }''',
      args: <dynamic>[overlay!.painel, fechar],
    );
    await aguarde(400);
    return;
  }
  await clickFirstVisible(
    page,
    '[data-host="$chave"] [data-label="overlay_lab_diag"]',
  );
  await aguarde(300);
}

void main() {
  group('overlay layers Puppeteer E2E', () {
    late Page page;

    setUp(() async {
      page = await setupExampleBrowser();
    });

    tearDown(() async {
      await page.browser.close();
    });

    test('a tabela da escala lista as camadas em ordem crescente', () async {
      await gotoExample(page, 'overlay-layers');
      await waitForSelectorMatching(page, '[data-label="overlay_layers_scale"]');
      final valores = await page.evaluate<dynamic>(
        r'''() => [...document.querySelectorAll('[data-label="overlay_layers_row"]')]
          .map((tr) => parseInt(tr.children[1].textContent.trim(), 10))''',
      );
      final lista = (valores as List<dynamic>).cast<num>();
      expect(lista.length, greaterThanOrEqualTo(12));
      for (var i = 1; i < lista.length; i++) {
        expect(lista[i], greaterThan(lista[i - 1]),
            reason: 'a escala tem de ser crescente: $lista');
      }
    }, skip: skipExampleE2eReason());

    for (final conteiner in _conteineres) {
      test('cada overlay ancorado recebe o clique dentro de "${conteiner.chave}"',
          () async {
        await _abrirConteiner(page, conteiner);

        final falhas = <String>[];
        for (final overlay in _ancorados) {
          final gatilho = '[data-host="${conteiner.chave}"] ${overlay.gatilho}';
          try {
            await clickFirstVisible(page, gatilho);
          } catch (e) {
            falhas.add('${overlay.nome}: gatilho nao clicavel ($gatilho): $e');
            continue;
          }
          await aguarde(450);

          final problema = await _painelRecebeOClique(page, overlay);
          if (problema != null) {
            falhas.add('${overlay.nome}: $problema');
          }

          await _fecharOQueEstiverAberto(page, conteiner.chave, overlay: overlay);
        }

        expect(falhas, isEmpty,
            reason: 'Dentro de "${conteiner.chave}":\n  ${falhas.join('\n  ')}');
      }, skip: skipExampleE2eReason(), timeout: const Timeout(Duration(minutes: 3)));
    }

    test('dialogo e alerta ficam acima do modal empilhado', () async {
      await _abrirConteiner(page, _conteineres[2]);

      await clickFirstVisible(
        page,
        '[data-host="stacked-child"] [data-label="overlay_lab_dialog"]',
      );
      await aguarde(400);
      expect(
        await _painelRecebeOClique(
          page,
          const _Overlay('LiSimpleDialog',
              gatilho: '',
              painel: '[data-label="li_sd_modal"]',
              sonda: '[data-label="li_sd_confirm"]'),
        ),
        isNull,
      );
      await clickFirstVisible(page, '[data-label="li_sd_confirm"]');
      await waitForSelectorGone(page, '[data-label="li_sd_modal"]');

      await clickFirstVisible(
        page,
        '[data-host="stacked-child"] [data-label="overlay_lab_alert"]',
      );
      await aguarde(600);
      expect(
        await _painelRecebeOClique(
          page,
          const _Overlay('SweetAlert',
              gatilho: '',
              painel: '.swal2-container',
              sonda: '.swal2-confirm'),
        ),
        isNull,
      );
      await clickFirstVisible(page, '.swal2-confirm');
      await waitForSelectorGone(page, '.swal2-container');
    }, skip: skipExampleE2eReason());

    test('offcanvas aberto de dentro do modal sobe pelo modal', () async {
      await _abrirConteiner(page, _conteineres[1]);

      await clickFirstVisible(
        page,
        '[data-label="overlay_lab_open_offcanvas_under"]',
      );
      await aguarde(600);

      // O painel do offcanvas tem de receber o clique mesmo com o modal
      // (1200) no ar: a base dele é 1150, mas ele resolve na hora de abrir.
      expect(
        await _painelRecebeOClique(
          page,
          const _Overlay('li-offcanvas',
              gatilho: '',
              painel: '.li-offcanvas-shell[data-status="open"]',
              sonda: '.offcanvas-title'),
        ),
        isNull,
      );

      final zDoShell = await page.evaluate<dynamic>(
        r'''() => {
          const shell = [...document.querySelectorAll('.li-offcanvas-shell[data-status="open"]')].pop();
          return shell ? parseInt(window.getComputedStyle(shell).zIndex, 10) : null;
        }''',
      );
      expect(zDoShell, greaterThan(1200));
    }, skip: skipExampleE2eReason());

    test('toasts ficam acima do dialogo aberto sobre o modal', () async {
      await _abrirConteiner(page, _conteineres[1]);

      // Um toast de cada vez: os dois nascem no mesmo canto e o de
      // notificação (3100) cobriria o da pilha (2100).
      await clickFirstVisible(
        page,
        '[data-host="modal"] [data-label="overlay_lab_toast"]',
      );
      await clickFirstVisible(
        page,
        '[data-host="modal"] [data-label="overlay_lab_dialog"]',
      );
      await aguarde(500);
      expect(
        await _painelRecebeOClique(
          page,
          const _Overlay('li-toast-stack',
              gatilho: '', painel: '[data-label="li_toast_stack_item"]'),
        ),
        isNull,
      );
      await clickFirstVisible(page, '[data-label="li_sd_cancel"]');
      await waitForSelectorGone(page, '[data-label="li_sd_modal"]');
      await waitForSelectorGone(
        page,
        '[data-label="li_toast_stack_item"]',
        timeout: const Duration(seconds: 8),
      );

      await clickFirstVisible(
        page,
        '[data-host="modal"] [data-label="overlay_lab_notification"]',
      );
      await clickFirstVisible(
        page,
        '[data-host="modal"] [data-label="overlay_lab_dialog"]',
      );
      await aguarde(500);
      expect(
        await _painelRecebeOClique(
          page,
          const _Overlay('li-notification-toast',
              gatilho: '', painel: '[data-label="li_ntf"] .toast.show'),
        ),
        isNull,
      );
      await clickFirstVisible(page, '[data-label="li_sd_cancel"]');
      await waitForSelectorGone(page, '[data-label="li_sd_modal"]');
    }, skip: skipExampleE2eReason());
  });
}
