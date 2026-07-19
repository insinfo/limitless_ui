import 'package:web/web.dart';

/// Adds Dart class-name collections to the Web IDL [DOMTokenList].
///
/// `package:web` exposes the native single-token `add` operation, so this
/// small adapter keeps the Dart iteration explicit without recreating the old
/// `CssClassSet` facade.
T addClassTokens<T extends Element>(T element, Iterable<String> tokens) {
  for (final token in tokens) {
    element.classList.add(token);
  }
  return element;
}

T removeClassTokens<T extends Element>(T element, Iterable<String> tokens) {
  for (final token in tokens) {
    element.classList.remove(token);
  }
  return element;
}

extension DartDomTokenListOperations on DOMTokenList {
  void addAllTokens(Iterable<String> tokens) {
    for (final token in tokens) {
      add(token);
    }
  }

  void removeAllTokens(Iterable<String> tokens) {
    for (final token in tokens) {
      remove(token);
    }
  }

  Set<String> toDartSet() => {
        for (var index = 0; index < length; index++) item(index)!,
      };
}
