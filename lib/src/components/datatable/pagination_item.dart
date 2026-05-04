enum PaginationButtonType { prev, next, page }

enum PaginationType { carousel, cube }

class PaginationItem {
  void Function() action;
  String label;
  String get cssClass => cssClasses.join(' ');
  final List<String> cssClasses;
  String? id;

  void addClass(String className) {
    cssClasses.add(className);
  }

  void removeClass(String className) {
    cssClasses.remove(className);
  }

  bool isActive;
  PaginationButtonType paginationButtonType;
  PaginationItem({
    required this.action,
    required this.label,
    List<String>? cssClasses,
    this.isActive = false,
    this.id,
    this.paginationButtonType = PaginationButtonType.page,
  }) : cssClasses = cssClasses ?? <String>[];
}
