import 'package:web/web.dart' as web;
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

import '../../web_support/html_sinks.dart';
import 'li_multi_select.dart';

@Component(
  selector: 'li-multi-option',
  templateUrl: 'li_multi_option.html',
  directives: [
    coreDirectives,
    formDirectives,
  ],
)
class LiMultiOptionComponent {
  @Input('value')
  dynamic value;

  final web.Element rootElement;

  LiMultiOptionComponent(this.rootElement);

  LiMultiSelectComponent? parent;

  @HostListener('click')
  void handleOnClick(web.Event e) {
    e.stopPropagation();
  }

  String get text {
    return (rootElement.textContent ?? '').trim();
  }

  set text(String inputText) {
    rootElement.textContent = inputText;
  }

  String? get innerHtml {
    return readHtml(rootElement);
  }

  set innerHtml(String? inputText) {
    setSanitizedHtml(rootElement, inputText ?? '');
  }
}
