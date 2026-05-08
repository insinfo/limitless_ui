/// Utility functions for small datatable collection operations.
class DatatableCollectionUtils {
  DatatableCollectionUtils._();

  /// Returns whether two sets contain exactly the same string values.
  static bool setEquals(Set<String> left, Set<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (final value in left) {
      if (!right.contains(value)) {
        return false;
      }
    }

    return true;
  }
}
