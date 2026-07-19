import 'package:web/web.dart' as web;

/// Converts the Web IDL collection returned by `querySelectorAll` into the
/// Dart list shape required by test matchers and collection operations.
extension TestNodeListConversion on web.NodeList {
  List<web.Element> toElementList() =>
      web.JSImmutableListWrapper<web.NodeList, web.Element>(this);
}
