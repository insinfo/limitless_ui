import 'dart:async';
import 'dart:html' as html;

/// Assina cliques no documento para detecção de clique-fora, na fase de
/// **captura**.
///
/// A fase importa. Vários gatilhos de overlay chamam `stopPropagation()` no
/// próprio clique — o botão do menu de ações de uma linha faz isso para o
/// clique não virar clique de linha, por exemplo. Um ouvinte de *bubble* no
/// documento nunca chega a ver esses eventos, então um overlay já aberto não
/// tinha como saber que outro estava sendo aberto e os dois ficavam na tela ao
/// mesmo tempo.
///
/// A captura percorre documento → alvo antes do bubble, então o clique é visto
/// independentemente do que o alvo faça com a propagação depois. Como todo
/// handler daqui começa perguntando "o clique foi dentro de mim?", rodar antes
/// do alvo não muda mais nada: clicar no próprio gatilho continua alternando o
/// overlay em vez de fechá-lo e reabri-lo.
StreamSubscription<html.MouseEvent> listenOutsideClick(
  void Function(html.MouseEvent event) onClick,
) {
  return const html.EventStreamProvider<html.MouseEvent>('click')
      .forTarget(html.document, useCapture: true)
      .listen(onClick);
}
