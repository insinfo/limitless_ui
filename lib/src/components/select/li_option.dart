import 'package:web/web.dart' as web;

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

import '../../web_support/html_sinks.dart';
import 'li_select.dart';

@Component(
  selector: 'li-option',
  templateUrl: 'li_option.html',
  directives: [
    coreDirectives,
    formDirectives,
  ],
)
class LiOptionComponent {
  @Input('value')
  dynamic value;

  final web.Element rootElement;

  LiOptionComponent(this.rootElement);

  LiSelectComponent? parent;

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
