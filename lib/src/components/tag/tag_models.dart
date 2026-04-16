const String liDefaultTagColor = '#6c757d';

const List<String> liDefaultTagPalette = <String>[
  '#e53935',
  '#d81b60',
  '#8e24aa',
  '#5e35b1',
  '#3949ab',
  '#1e88e5',
  '#039be5',
  '#00acc1',
  '#00897b',
  '#43a047',
  '#7cb342',
  '#c0ca33',
  '#fdd835',
  '#ffb300',
  '#fb8c00',
  '#f4511e',
  '#6d4c41',
  '#757575',
  '#546e7a',
];

class LiTagSelectionChange {
  const LiTagSelectionChange({
    required this.values,
    required this.models,
  });

  final List<dynamic> values;
  final List<dynamic> models;
}

class LiTagSaveRequest {
  const LiTagSaveRequest({
    required this.value,
    this.originalValue,
    required this.isEditing,
  });

  final Map<String, dynamic> value;
  final dynamic originalValue;
  final bool isEditing;
}

class LiTagDeleteRequest {
  const LiTagDeleteRequest({
    required this.value,
    this.originalValue,
  });

  final Map<String, dynamic> value;
  final dynamic originalValue;
}
