import 'package:puppeteer/puppeteer.dart';
import 'package:test/test.dart';

import 'puppeteer_setup.dart';

/// E2E do loop infinito de layout do `li-datatable`.
///
/// A tela `datatable-layout-loop` replica o "Protocolo > Acompanhamento
/// Especial" do SALI e fecha o mesmo ciclo que travava lá: o auto-hide esconde
/// uma coluna, a tabela encurta, a barra de rolagem da página some e o
/// container devolve ~16px -- espaço suficiente para as colunas voltarem, a
/// barra reaparecer e o ciclo recomeçar. Com zoom em 110% a página caía
/// exatamente nesse limiar e o navegador redesenhava a tabela para sempre.
///
/// Medido nessa mesma tela antes da correção: 90 redesenhos em 3s. Depois: 0.
///
/// Os testes olham para os contadores que o próprio datatable alimenta pelo
/// stream de instrumentação, e a pergunta que fazem é "o contador **para** de
/// subir?", não "quantos em N segundos" -- um layout que converge estabiliza em
/// poucas leituras, um em loop nunca estabiliza, e nenhum dos dois depende de
/// quanto CPU a máquina tinha sobrando na hora.
void main() {
  group('datatable layout loop Puppeteer E2E', () {
    late Page page;

    setUp(() async {
      page = await setupExampleBrowser();
    });

    tearDown(() async {
      await page.browser.close();
    });

    /// Reproduz o zoom de 110% do relato: o device pixel ratio fracionário faz
    /// `getBoundingClientRect` devolver larguras com casas decimais que mudam
    /// entre frames, e a janela menor aperta as colunas até o limiar.
    Future<void> aplicarZoomDe110() {
      return page.setViewport(
        DeviceViewport(width: 1745, height: 912, deviceScaleFactor: 1.1),
      );
    }

    /// Abre a tela e prende a tabela na fresta onde o ciclo se fecha.
    ///
    /// Por padrão ela ocupa a largura toda, como a tela real do SALI; o limite
    /// é o que reproduz o aperto do zoom em 110%.
    Future<void> abrirTela() async {
      await aplicarZoomDe110();
      await gotoExample(page, 'datatable-layout-loop');
      await waitForSelectorMatching(
        page,
        '[data-id="datatableAcompanhamentoEspecial"]',
      );
      await clickFirstVisible(page, '[data-id="chkLimitarLargura"]');
      // O auto-hide precisa de alguns frames para medir, esconder e ser medido
      // de novo.
      await aguarde(1500);
    }

    Future<String?> lerTexto(String dataId) {
      return attributeValue(page, '[data-id="$dataId"]', 'data-value');
    }

    Future<int> lerContador(String dataId) async {
      final valor = await waitForAttributeMatching(
        page,
        '[data-id="$dataId"]',
        'data-value',
        (value) => value != null && int.tryParse(value) != null,
      );
      return int.parse(valor!);
    }

    /// Espera o contador parar de subir e devolve quantas leituras precisou.
    ///
    /// Falha se ele nunca parar dentro de [tentativas] -- que é exatamente o
    /// sintoma do bug, e o único jeito de medi-lo sem depender da velocidade da
    /// máquina.
    Future<int> esperarContadorParar(
      String dataId, {
      int tentativas = 20,
      int intervaloMs = 500,
    }) async {
      var anterior = await lerContador(dataId);
      for (var leitura = 1; leitura <= tentativas; leitura++) {
        await aguarde(intervaloMs);
        final atual = await lerContador(dataId);
        if (atual == anterior) {
          return leitura;
        }
        anterior = atual;
      }

      fail(
        '$dataId nunca parou de subir: chegou a $anterior depois de '
        '$tentativas leituras de ${intervaloMs}ms -- a tabela está em loop',
      );
    }

    Future<void> mudarLargura(String largura) {
      return page.evaluate(
        '''(w) => {
          const input = document.querySelector('[data-id="inpLarguraContainer"]');
          input.value = w;
          input.dispatchEvent(new Event('input', { bubbles: true }));
          input.dispatchEvent(new Event('change', { bubbles: true }));
        }''',
        args: [largura],
      );
    }

    test('a tabela para de se redesenhar com zoom em 110%', () async {
      await abrirTela();

      // A largura padrão da tela cai dentro da faixa em que o ciclo se fecha.
      // Se nenhuma coluna foi escondida o teste não exercitou nada, e a
      // estabilidade medida abaixo não valeria de prova.
      expect(
        await lerTexto('vlrColunasEscondidas'),
        isNot('nenhuma'),
        reason: 'o auto-hide nem chegou a rodar nesta largura',
      );

      await esperarContadorParar('vlrRedesenhosTotais');

      expect(await lerTexto('msgEstadoDoLayout'), 'estavel');
    }, skip: skipExampleE2eReason());

    test('o auto-hide para de alternar as colunas', () async {
      await abrirTela();
      expect(
        await lerTexto('vlrColunasEscondidas'),
        isNot('nenhuma'),
        reason: 'o auto-hide nem chegou a rodar nesta largura',
      );

      await esperarContadorParar('vlrMudancasAutoHide');

      // E o conjunto escondido continua o mesmo depois disso.
      final colunas = await lerTexto('vlrColunasEscondidas');
      await aguarde(1000);
      expect(await lerTexto('vlrColunasEscondidas'), colunas);
    }, skip: skipExampleE2eReason());

    test('estreitar o container esconde coluna e a tela volta a estabilizar',
        () async {
      await abrirTela();

      // Um container bem largo cabe todas as colunas.
      await mudarLargura('1400');
      await waitForAttributeMatching(
        page,
        '[data-id="vlrColunasEscondidas"]',
        'data-value',
        (value) => value == 'nenhuma',
      );

      // Estreitar tem que esconder alguma -- a responsividade continua
      // funcionando, a correção não a desligou.
      await mudarLargura('520');
      await waitForAttributeMatching(
        page,
        '[data-id="vlrColunasEscondidas"]',
        'data-value',
        (value) => value != null && value != 'nenhuma',
      );

      // E depois de esconder, estabiliza de novo.
      await esperarContadorParar('vlrRedesenhosTotais');
    }, skip: skipExampleE2eReason());
  });
}
