// Run this browser test from the package root with:
// dart run build_runner test -- -p chrome -j 1 test/target_alert/li_target_alert_test.dart
// ignore_for_file: uri_has_not_been_generated

@TestOn('browser')
library;

import 'dart:html' as html;

import 'package:limitless_ui/limitless_ui.dart';
import 'package:test/test.dart';

/// O painel de erro ancorado a um elemento.
///
/// Veio do SALI em 11/09/2026, onde 38 telas já o usavam: é a resposta para o
/// que uma cortina de carregamento não resolve — a carga falhou, e agora o quê.
void main() {
  late html.Element alvo;
  late LiTargetAlert alerta;

  setUp(() {
    alvo = html.DivElement()
      ..id = 'alvo-do-teste'
      ..style.position = 'relative'
      ..style.height = '300px';
    html.document.body!.append(alvo);
    alerta = LiTargetAlert();
  });

  tearDown(() {
    alerta.hide();
    alvo.remove();
  });

  html.Element? painel() =>
      html.document.querySelector('.li-target-alert-overlay');

  group('exibicao', () {
    test('desenha o painel dentro do alvo', () {
      alerta.show(target: alvo, title: 'Falhou', message: 'Tente de novo');

      final overlay = painel();
      expect(overlay, isNotNull);
      expect(alvo.contains(overlay!), isTrue,
          reason: 'o painel pertence ao alvo, não ao body');
      expect(overlay.text, contains('Falhou'));
      expect(overlay.text, contains('Tente de novo'));
    });

    test('fica acima da cortina de carregamento', () {
      // É o ponto do componente: ele substitui uma cortina que falhou. Por
      // baixo dela, o operador ficaria olhando um spinner que nunca para.
      alerta.show(target: alvo);

      expect(int.parse(painel()!.style.zIndex),
          greaterThan(LiOverlayLayers.loadingBody));
    });

    test('mostrar de novo nao empilha dois paineis', () {
      alerta.show(target: alvo, title: 'Primeiro');
      alerta.show(target: alvo, title: 'Segundo');

      final todos =
          html.document.querySelectorAll('.li-target-alert-overlay');
      expect(todos, hasLength(1));
      expect(todos.single.text, contains('Segundo'));
    });

    test('hide sem nada na tela nao quebra', () {
      expect(alerta.hide, returnsNormally);
    });
  });

  group('detalhe tecnico', () {
    test('entra recolhido quando informado', () {
      alerta.show(target: alvo, detail: 'StackTrace: linha 42');

      final detalhe = painel()!.querySelector('details');
      expect(detalhe, isNotNull,
          reason: 'a mensagem técnica fica na tela, mas não na cara');
      expect(detalhe!.text, contains('StackTrace: linha 42'));
    });

    test('nao aparece quando vazio ou so espaco', () {
      alerta.show(target: alvo, detail: '   ');
      expect(painel()!.querySelector('details'), isNull);
    });
  });

  group('botoes', () {
    test('fechar sempre existe e remove o painel', () {
      alerta.show(target: alvo, closeLabel: 'Fechar');

      final botoes = painel()!.querySelectorAll('button');
      expect(botoes, isNotEmpty);

      (botoes.last as html.ButtonElement).click();
      expect(painel(), isNull);
    });

    test('tentar novamente so aparece com callback, e fecha antes de chamar',
        () {
      var chamou = false;
      var painelAindaNaTela = true;
      alerta.show(
        target: alvo,
        retryLabel: 'Tentar novamente',
        onRetry: () {
          chamou = true;
          // Fechar antes de chamar importa: a recarga costuma abrir uma
          // cortina, e ela nasceria por baixo deste painel.
          painelAindaNaTela = painel() != null;
        },
      );

      final botao = painel()!
          .querySelectorAll('button')
          .firstWhere((b) => b.text!.contains('Tentar novamente'));
      (botao as html.ButtonElement).click();

      expect(chamou, isTrue);
      expect(painelAindaNaTela, isFalse);
    });

    test('sem onRetry o botao de tentar novamente nao existe', () {
      alerta.show(target: alvo, retryLabel: 'Tentar novamente');

      final tem = painel()!
          .querySelectorAll('button')
          .any((b) => b.text!.contains('Tentar novamente'));
      expect(tem, isFalse);
    });

    test('acao opcional exige callback e rotulo', () {
      alerta.show(target: alvo, actionLabel: 'Abrir mapeamentos');
      expect(
        painel()!
            .querySelectorAll('button')
            .any((b) => b.text!.contains('Abrir mapeamentos')),
        isFalse,
        reason: 'rótulo sem callback não vira botão que não faz nada',
      );

      alerta.hide();
      var foi = false;
      alerta.show(
        target: alvo,
        actionLabel: 'Abrir mapeamentos',
        onAction: () => foi = true,
      );
      final botao = painel()!
          .querySelectorAll('button')
          .firstWhere((b) => b.text!.contains('Abrir mapeamentos'));
      (botao as html.ButtonElement).click();
      expect(foi, isTrue);
    });
  });

  group('posicionamento', () {
    test('o alvo estatico recebe position relative, para o painel caber nele',
        () {
      final estatico = html.DivElement()..style.height = '200px';
      html.document.body!.append(estatico);
      addTearDown(estatico.remove);

      alerta.show(target: estatico);

      expect(estatico.style.position, 'relative');
    });

    test('sem alvo, cobre a pagina', () {
      alerta.show();

      final overlay = painel();
      expect(overlay, isNotNull);
      expect(overlay!.style.position, 'fixed');
    });
  });
}
