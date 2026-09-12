// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/core/overlay_layers_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

/// The stacking order, as one thing instead of fifteen.
///
/// Until `1.0.0-dev.42` the scale lived as literals spread across the
/// components, and two pairs had already collided: the toast stack and the
/// dialog both drew at 2000, the notification toast and the alert both at 3000,
/// so which one won was decided by the order of the nodes in the DOM. Anchored
/// overlays ran in two regimes — seven of them rose above an open modal, seven
/// others sat at a fixed 10000 and never did.
void main() {
  tearDown(() {
    for (final node in html.document.querySelectorAll(
        '.modal, [data-li-simple-dialog], .swal2-container, .li-offcanvas-shell')) {
      node.remove();
    }
    LiSimpleLoading.hideAll();
  });

  /// Puts a fake blocking container on screen, the way the real one looks to
  /// [LiOverlayStack].
  html.Element montarBloqueante(String html_, int zIndex) {
    final node = html.Element.html(html_, treeSanitizer: html.NodeTreeSanitizer.trusted);
    node.style.zIndex = '$zIndex';
    html.document.body!.append(node);
    return node;
  }

  group('a escala tem uma ordem, e ela e explicita', () {
    test('cada camada fica acima da anterior', () {
      // Escrito como uma lista para a ordem ser lida de uma vez, e não
      // deduzida de comparações soltas.
      final ordem = <String, int>{
        'anchored': LiOverlayLayers.anchored,
        'anchoredMenu': LiOverlayLayers.anchoredMenu,
        'anchoredTooltip': LiOverlayLayers.anchoredTooltip,
        'anchoredPicker': LiOverlayLayers.anchoredPicker,
        'offcanvas': LiOverlayLayers.offcanvas,
        'modal': LiOverlayLayers.modal,
        'dialog': LiOverlayLayers.dialog,
        'toastStack': LiOverlayLayers.toastStack,
        'alert': LiOverlayLayers.alert,
        'notificationToast': LiOverlayLayers.notificationToast,
        'loadingTarget': LiOverlayLayers.loadingTarget,
        'loadingBody': LiOverlayLayers.loadingBody,
      };

      final nomes = ordem.keys.toList();
      for (var i = 1; i < nomes.length; i++) {
        expect(ordem[nomes[i]], greaterThan(ordem[nomes[i - 1]]!),
            reason: '${nomes[i]} tem de ficar acima de ${nomes[i - 1]}');
      }
    });

    test('os dois empates de antes acabaram', () {
      // Decididos pela ordem no DOM até a dev.42.
      expect(LiOverlayLayers.toastStack, isNot(LiOverlayLayers.dialog));
      expect(LiOverlayLayers.notificationToast, isNot(LiOverlayLayers.alert));
    });

    test('o offcanvas passa por baixo de qualquer modal empilhado', () {
      // Ficava em 1201 fixo: acima do primeiro modal (1200) e abaixo do
      // segundo (1210), uma ordem que ninguém escolheu.
      expect(LiOverlayLayers.offcanvas, lessThan(LiOverlayLayers.modal));
    });
  });

  group('LiOverlayStack', () {
    test('sem nada bloqueando, devolve a base', () {
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.anchoredMenu,
      );
    });

    test('sobe acima do modal que contem a referencia', () {
      final modal = montarBloqueante(
          '<div class="modal" data-status="open"><span id="dentro"></span></div>',
          LiOverlayLayers.modal);
      final alvo = modal.querySelector('#dentro')!;

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.modal + LiOverlayLayers.stackOffset,
      );
    });

    test('sobe acima do dialogo, que antes a varredura nao enxergava', () {
      // O diálogo carrega `.modal` na raiz, mas não tem `data-status` — então o
      // seletor de modal aberto passava direto por ele.
      montarBloqueante(
          '<div class="modal li-simple-dialog__modal" data-li-simple-dialog="true"></div>',
          LiOverlayLayers.dialog);
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.dialog + LiOverlayLayers.stackOffset,
      );
    });

    test('sobe acima do offcanvas, que o primeiro seletor nao enxergava', () {
      // O offcanvas anexa ao body um `.li-offcanvas-shell`, e é ele que leva
      // o z-index. O seletor escrito primeiro, `.li-offcanvas[data-status]`,
      // nomeava uma classe que o componente nunca teve — um select aberto
      // dentro do offcanvas ficava embaixo dele.
      final shell = montarBloqueante(
          '<div class="li-offcanvas-shell" data-status="open"><div class="offcanvas"></div></div>',
          LiOverlayLayers.offcanvas);
      final alvo = html.DivElement();
      shell.querySelector('.offcanvas')!.append(alvo);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.offcanvas + LiOverlayLayers.stackOffset,
      );
      expect(LiOverlayStack.owningBlockingContainer(alvo), same(shell));
    });

    test('um offcanvas fechado nao bloqueia', () {
      montarBloqueante(
          '<div class="li-offcanvas-shell" data-status="closed"></div>',
          LiOverlayLayers.offcanvas);
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.anchoredMenu,
      );
    });

    test('sobe acima do alerta', () {
      montarBloqueante(
          '<div class="swal2-container"></div>', LiOverlayLayers.alert);
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.alert + LiOverlayLayers.stackOffset,
      );
    });

    test('com varios no ar, vale o mais alto', () {
      montarBloqueante(
          '<div class="modal" data-status="open"></div>', LiOverlayLayers.modal);
      montarBloqueante(
          '<div class="swal2-container"></div>', LiOverlayLayers.alert);
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.alert + LiOverlayLayers.stackOffset,
      );
    });

    test('a cortina nao entra na conta', () {
      // Ela fica acima de tudo de propósito, e enquanto está no ar nada abaixo
      // recebe clique — não há o que ultrapassar.
      LiSimpleLoading().showOnBody();
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        LiOverlayLayers.anchoredMenu,
      );
    });

    test('a aplicacao pode acrescentar a propria camada bloqueante', () {
      LiOverlayStack.blockingSelectors.add('.minha-cortina');
      addTearDown(
          () => LiOverlayStack.blockingSelectors.remove('.minha-cortina'));

      montarBloqueante('<div class="minha-cortina"></div>', 4200);
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredMenu),
        4201,
      );
    });

    test('nunca desce abaixo da base pedida', () {
      montarBloqueante('<div class="modal" data-status="open"></div>', 5);
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      expect(
        LiOverlayStack.resolve(
            referenceElement: alvo, baseZIndex: LiOverlayLayers.anchoredPicker),
        LiOverlayLayers.anchoredPicker,
      );
    });
  });

  group('resolveModalAwarePortalOptions', () {
    test('o painel guarda a distancia do host, para os dois lados', () {
      // O delta negativo era descartado: o menu de coluna do datatable pedia
      // host 10000 e painel 1080 e recebia 10000 nos dois.
      final alvo = html.DivElement();
      html.document.body!.append(alvo);
      addTearDown(alvo.remove);

      final opcoes = resolveModalAwarePortalOptions(
        hostClassName: 'Teste',
        referenceElement: alvo,
        baseHostZIndex: 2000,
        baseFloatingZIndex: 1900,
      );

      expect(opcoes.hostZIndex, '2000');
      expect(opcoes.floatingZIndex, '1900');
    });
  });
}
