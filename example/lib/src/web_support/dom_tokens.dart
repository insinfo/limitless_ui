import 'package:web/web.dart';

extension ExampleDomTokenListOperations on DOMTokenList {
  void addAllTokens(Iterable<String> tokens) {
    for (final token in tokens) {
      add(token);
    }
  }
}
