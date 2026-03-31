import 'package:ngdart/angular.dart';

class LiTypeaheadHighlightPart {
  const LiTypeaheadHighlightPart(this.text, this.highlighted);

  final String text;
  final bool highlighted;
}

@Component(
  selector: 'li-typeahead-highlight',
  changeDetection: ChangeDetectionStrategy.onPush,
  template: '''
    <ng-container *ngFor="let part of parts">
      <span *ngIf="part.highlighted" [class]="highlightClass">{{ part.text }}</span>
      <ng-container *ngIf="!part.highlighted">{{ part.text }}</ng-container>
    </ng-container>
  ''',
  directives: [coreDirectives],
)
class LiTypeaheadHighlightComponent implements AfterChanges {
  static const Map<String, String> _accentMap = <String, String>{
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'Á': 'A',
    'À': 'A',
    'Â': 'A',
    'Ã': 'A',
    'Ä': 'A',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'É': 'E',
    'È': 'E',
    'Ê': 'E',
    'Ë': 'E',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'Í': 'I',
    'Ì': 'I',
    'Î': 'I',
    'Ï': 'I',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'Ó': 'O',
    'Ò': 'O',
    'Ô': 'O',
    'Õ': 'O',
    'Ö': 'O',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'Ú': 'U',
    'Ù': 'U',
    'Û': 'U',
    'Ü': 'U',
    'ç': 'c',
    'Ç': 'C',
    'ñ': 'n',
    'Ñ': 'N',
  };

  @Input()
  String highlightClass = 'li-typeahead__highlight';

  @Input()
  String? result;

  @Input()
  dynamic term;

  @Input()
  bool accentSensitive = true;

  List<LiTypeaheadHighlightPart> parts = const <LiTypeaheadHighlightPart>[];

  @override
  void ngAfterChanges() {
    final text = result ?? '';
    final terms = _normalizedTerms(term);
    if (text.isEmpty || terms.isEmpty) {
      parts = <LiTypeaheadHighlightPart>[
        LiTypeaheadHighlightPart(text, false),
      ];
      return;
    }

    final lowerText = accentSensitive
        ? text.toLowerCase()
        : _stripAccents(text.toLowerCase());
    final normalizedTerms = terms
        .map((value) => accentSensitive
            ? value.toLowerCase()
            : _stripAccents(value.toLowerCase()))
        .where((value) => value.isNotEmpty)
        .toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    if (normalizedTerms.isEmpty) {
      parts = <LiTypeaheadHighlightPart>[
        LiTypeaheadHighlightPart(text, false),
      ];
      return;
    }

    final nextParts = <LiTypeaheadHighlightPart>[];
    var index = 0;
    while (index < text.length) {
      String? matchedTerm;
      for (final candidate in normalizedTerms) {
        if (lowerText.startsWith(candidate, index)) {
          matchedTerm = candidate;
          break;
        }
      }

      if (matchedTerm != null) {
        nextParts.add(
          LiTypeaheadHighlightPart(
            text.substring(index, index + matchedTerm.length),
            true,
          ),
        );
        index += matchedTerm.length;
        continue;
      }

      final start = index;
      index++;
      while (index < text.length) {
        var found = false;
        for (final candidate in normalizedTerms) {
          if (lowerText.startsWith(candidate, index)) {
            found = true;
            break;
          }
        }
        if (found) {
          break;
        }
        index++;
      }

      nextParts.add(
        LiTypeaheadHighlightPart(text.substring(start, index), false),
      );
    }

    parts = nextParts;
  }

  List<String> _normalizedTerms(dynamic value) {
    if (value == null) {
      return const <String>[];
    }
    if (value is Iterable) {
      return value.map((item) => item?.toString() ?? '').toList();
    }
    return <String>[value.toString()];
  }

  String _stripAccents(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer.toString();
  }
}
