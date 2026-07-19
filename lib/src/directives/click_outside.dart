import 'dart:async';

import 'dart:html';

import 'package:ngx_dart/angular.dart';

///
/// uma diretiva angular para detectar cliques fora de um objeto
/// baseada em https://javascript.plainenglish.io/creating-an-angular-directive-to-detect-clicking-outside-an-object-afd6c07212ef
///
@Directive(selector: '[liClickOutside]')
class LiClickOutsideDirective implements OnDestroy, OnInit {
  Element nativeElement;
  LiClickOutsideDirective(this.nativeElement);

  StreamSubscription? documentClickStreamSubscription;

  StreamController<MouseEvent> liClickOutsideSC =
      StreamController<MouseEvent>();

  @Output('liClickOutside')
  Stream<MouseEvent> get liClickOutside => liClickOutsideSC.stream;

  void onClick(MouseEvent event) {
    final target = event.target;
    if (target is! Node) {
      return;
    }

    var clickedInside = nativeElement.contains(target);
    if (!clickedInside) {
      liClickOutsideSC.add(event);
    }
  }

  @override
  void ngOnDestroy() {
    documentClickStreamSubscription?.cancel();
  }

  @override
  void ngOnInit() {
    documentClickStreamSubscription = document.onClick.listen(onClick);
  }
}
