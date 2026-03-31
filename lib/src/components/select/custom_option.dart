import 'dart:html';

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart';

import 'custom_select.dart';

@Component(
  selector: 'li-option',
  templateUrl: 'custom_option.html',
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
