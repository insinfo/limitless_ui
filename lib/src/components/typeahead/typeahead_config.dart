import 'package:ngdart/angular.dart';

/// Default configuration for [LiTypeaheadComponent].
@Injectable()
class LiTypeaheadConfig {
  LiTypeaheadConfig({
    this.autocomplete = 'off',
    this.placeholder = 'Search',
    this.container = 'body',
    this.minLength = 1,
    this.maxResults = 10,
    this.debounceMs = 150,
    this.openOnFocus = false,
    this.editable = true,
    this.focusFirst = true,
    this.selectOnExact = false,
    this.showHint = false,
    this.showLoadingIndicator = true,
    this.loadingText = 'Loading...',
    this.errorText = 'Unable to load results.',
    this.highlightClass = 'li-typeahead__highlight',
    this.highlightAccentSensitive = true,
  });

  String autocomplete;
  String placeholder;
  String container;
  int minLength;
  int maxResults;
  int debounceMs;
  bool openOnFocus;
  bool editable;
  bool focusFirst;
  bool selectOnExact;
  bool showHint;
  bool showLoadingIndicator;
  String loadingText;
  String errorText;
  String highlightClass;
  bool highlightAccentSensitive;
}
