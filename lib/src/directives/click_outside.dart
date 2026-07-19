import 'dart:js_interop';
import 'dart:async';

import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';

///
/// uma diretiva angular para detectar cliques fora de um objeto
/// baseada em https://javascript.plainenglish.io/creating-an-angular-directive-to-detect-clicking-outside-an-object-afd6c07212ef
///
@Directive(selector: '[liClickOutside]')
class LiClickOutsideDirective implements OnDestroy, OnInit {
  web.Element nativeElement;
  LiClickOutsideDirective(this.nativeElement);

  StreamSubscription? documentClickStreamSubscription;

  StreamController<web.MouseEvent> liClickOutsideSC =
      StreamController<web.MouseEvent>();

  @Output('liClickOutside')
  Stream<web.MouseEvent> get liClickOutside => liClickOutsideSC.stream;

  void onClick(web.MouseEvent event) {
    final target = event.target;
    if (!(target?.isA<web.Node>() ?? false)) {
      return;
    }

    var clickedInside = nativeElement.contains(target as web.Node?);
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
    documentClickStreamSubscription = web.EventStreamProviders.clickEvent
        .forTarget(web.document)
        .listen(onClick);
  }
}
