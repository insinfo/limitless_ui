import 'dart:async';
import 'dart:html' as html;

import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

/// Demonstração viva do [LiTargetAlert].
///
/// A página existe porque o componente só se entende com ele na tela: é um
/// painel que **cobre** a área que deveria ter carregado, e o ponto dele —
/// ficar acima da cortina de carregamento — só se enxerga com as duas coisas
/// acontecendo juntas.
@Component(
  selector: 'target-alert-page',
  templateUrl: 'target_alert_page.html',
  styleUrls: ['target_alert_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    RouterLink,
  ],
  exports: [DemoRoutePaths],
)
class TargetAlertPageComponent implements OnDestroy {
  TargetAlertPageComponent(this.i18n);

  final DemoI18nService i18n;

  /// Uma instância por tela, viva enquanto a tela viver — é o contrato do
  /// componente, e o oposto do [LiSimpleLoading], que é por operação.
  final LiTargetAlert _erroDaLista = LiTargetAlert();

  @ViewChild('areaDaLista')
  html.Element? areaDaLista;

  /// O que aconteceu por último, para a página se explicar sozinha.
  String registro = '';

  /// Lidos da biblioteca, nunca digitados aqui: se a escala mudar, o texto muda.
  int get targetAlertZIndex => LiOverlayLayers.targetAlert;

  int get loadingBodyZIndex => LiOverlayLayers.loadingBody;

  static const String snippetDoUso = '''
class MinhaTelaComponent implements OnDestroy {
  // Uma instância por TELA. `show` chama `hide` antes, então a mesma
  // instância atende todas as tentativas que falharem aqui.
  final LiTargetAlert _erroDaLista = LiTargetAlert();

  @ViewChild('areaDaLista')
  html.Element? areaDaLista;

  Future<void> carregar() async {
    final cortina = LiSimpleLoading()..showOnBody();
    try {
      _erroDaLista.hide();          // a tentativa anterior sai de cena
      itens = await servico.listar();
    } catch (e) {
      cortina.hide();               // some a cortina, entra o painel
      _erroDaLista.show(
        target: areaDaLista,
        title: 'Não foi possível carregar a lista',
        message: 'Verifique a conexão e tente de novo.',
        detail: e.toString(),       // vai recolhido: é o que se cola no chamado
        onRetry: carregar,
      );
    } finally {
      cortina.hide();               // idempotente
    }
  }

  @override
  void ngOnDestroy() => _erroDaLista.hide();
}
''';

  /// O caso comum: a carga falhou e o painel diz o que fazer.
  void falhaSimples() {
    _erroDaLista.show(
      target: areaDaLista,
      title: 'Não foi possível carregar a lista',
      message: 'O servidor não respondeu a tempo. Tente novamente em instantes.',
      onRetry: () {
        registro = 'O operador clicou em "Tentar novamente". O painel se fechou '
            'antes de o callback rodar — senão a cortina da nova carga nasceria '
            'por baixo dele.';
      },
    );
    registro = 'Painel preso à área da lista, em '
        'z-index ${LiOverlayLayers.targetAlert}.';
  }

  /// A mensagem técnica fica na tela, mas não na cara.
  void falhaComDetalhe() {
    _erroDaLista.show(
      target: areaDaLista,
      title: 'Erro ao carregar dados',
      message: 'A consulta terminou com erro. O detalhe técnico está abaixo.',
      detail: 'FormatException: Unexpected end of input (at character 1)\n'
          '    at ListaService.listar (lista_service.dart:88)\n'
          '    at MinhaTelaComponent.carregar (minha_tela.dart:142)',
      onRetry: () => registro = 'Nova tentativa pedida.',
    );
    registro = 'O detalhe entra recolhido: é o que o operador cola no chamado, '
        'e não o que ele precisa ler para entender o que houve.';
  }

  /// Quando o erro tem uma saída conhecida, e ela mora em outro lugar.
  void falhaComSaida() {
    _erroDaLista.show(
      target: areaDaLista,
      title: 'Nenhum mapeamento configurado',
      message: 'Esta lista depende de mapeamentos que ainda não existem. '
          'Cadastre um e volte.',
      actionLabel: 'Abrir Mapeamentos',
      onAction: () => registro = 'Navegaria para a tela de Mapeamentos. Sem '
          'este botão, o operador lê o que fazer e tem de achar sozinho onde.',
      onRetry: () => registro = 'Nova tentativa pedida.',
    );
    registro = 'Com [onAction], o painel deixa de ser só um aviso e passa a '
        'levar o operador até a saída.';
  }

  /// Em área alta, o centro fica fora da tela — daí o `top`.
  void falhaNoTopo() {
    _erroDaLista.show(
      target: areaDaLista,
      title: 'Painel ancorado no topo',
      message: 'Com [placement] em top, o painel acompanha a parte visível da '
          'área. Numa lista longa, o centro geométrico fica fora da tela.',
      placement: LiTargetAlertPlacement.top,
      onRetry: () => registro = 'Nova tentativa pedida.',
    );
    registro = 'placement: LiTargetAlertPlacement.top.';
  }

  /// O motivo de o componente existir: ele **substitui** uma cortina que falhou.
  Future<void> cortinaQueTerminaEmErro() async {
    final cortina = LiSimpleLoading()..showOnBody();
    try {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      throw const FormatException('resposta vazia');
    } catch (e) {
      // A cortina sai e o painel entra. Note que, mesmo se alguém esquecesse
      // este `hide()`, o painel apareceria: targetAlert é o único nível acima
      // de loadingBody, e é assim de propósito.
      cortina.hide();
      _erroDaLista.show(
        target: areaDaLista,
        title: 'A carga terminou em erro',
        message: 'O spinner parou porque deu errado — e o painel diz isso. Sem '
            'ele, o operador ficaria olhando um carregamento que nunca volta.',
        detail: e.toString(),
        onRetry: cortinaQueTerminaEmErro,
      );
    } finally {
      cortina.hide();
    }
    registro = 'targetAlert (${LiOverlayLayers.targetAlert}) fica acima de '
        'loadingBody (${LiOverlayLayers.loadingBody}) justamente por isto.';
  }

  /// Sem alvo, o painel cobre a página — para falha que não é de um pedaço só.
  void falhaDaPaginaInteira() {
    _erroDaLista.show(
      title: 'Sessão expirada',
      message: 'Sem [target] o painel cobre a página inteira, com position '
          'fixed. Serve para a falha que não pertence a nenhuma área.',
      closeLabel: 'Entendi',
    );
    registro = 'Painel em tela cheia. O rótulo do botão de fechar também é '
        'parâmetro — closeLabel.';
  }

  void esconder() {
    _erroDaLista.hide();
    registro = 'hide(): o painel sai e toda assinatura de scroll/resize que '
        'ele criou é cancelada.';
  }

  /// A tela morre, o painel vai junto.
  @override
  void ngOnDestroy() => _erroDaLista.hide();
}
