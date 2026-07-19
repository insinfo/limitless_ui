import 'dart:html';
import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

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

  final Element rootElement;

  LiMultiOptionComponent(this.rootElement);

  LiMultiSelectComponent? parent;

  @HostListener('click')
  void handleOnClick(Event e) {
    e.stopPropagation();
  }

  String get text {
    return (rootElement.text ?? '').trim();
  }

  set text(String inputText) {
    rootElement.text = inputText;
  }

  String? get innerHtml {
    return rootElement.innerHtml;
  }

  set innerHtml(String? inputText) {
    rootElement.innerHtml = inputText;
  }
}
