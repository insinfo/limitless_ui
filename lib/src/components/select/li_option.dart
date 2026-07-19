import 'dart:html';

import 'package:ngx_dart/angular.dart';
import 'package:ngx_forms/ngx_forms.dart';

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

  final Element rootElement;

  LiOptionComponent(this.rootElement);

  LiSelectComponent? parent;

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
