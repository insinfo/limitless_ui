import 'dart:html' as html;

enum DemoThemeMode { light, dark, blu, pink, orange, sali, auto }

class DemoThemeService {
  DemoThemeService() {
    _mediaQueryList = html.window.matchMedia('(prefers-color-scheme: dark)');
    _themeChangeListener = (html.Event _) {
      if (_mode == DemoThemeMode.auto) {
        _applyTheme();
      }
    };
    _mediaQueryList?.addEventListener('change', _themeChangeListener);

    final storedTheme = html.window.localStorage[_storageKey] ?? _autoValue;
    if (storedTheme == _darkValue) {
      _mode = DemoThemeMode.dark;
    } else if (storedTheme == _bluValue) {
      _mode = DemoThemeMode.blu;
    } else if (storedTheme == _pinkValue) {
      _mode = DemoThemeMode.pink;
    } else if (storedTheme == _orangeValue) {
      _mode = DemoThemeMode.orange;
    } else if (storedTheme == _saliValue) {
      _mode = DemoThemeMode.sali;
    } else if (storedTheme == _autoValue) {
      _mode = DemoThemeMode.auto;
    }

    _applyTheme();
  }

  static const _storageKey = 'limitless_ui_example.theme';
  static const _lightValue = 'light';
  static const _darkValue = 'dark';
  static const _bluValue = 'blu';
  static const _pinkValue = 'pink';
  static const _orangeValue = 'orange';
  static const _saliValue = 'sali';
  static const _autoValue = 'auto';

  DemoThemeMode _mode = DemoThemeMode.light;
  html.MediaQueryList? _mediaQueryList;
  late final void Function(html.Event) _themeChangeListener;

  DemoThemeMode get mode => _mode;
  bool get isLight => _mode == DemoThemeMode.light;
  bool get isDark => _mode == DemoThemeMode.dark;
  bool get isBlu => _mode == DemoThemeMode.blu;
  bool get isPink => _mode == DemoThemeMode.pink;
  bool get isOrange => _mode == DemoThemeMode.orange;
  bool get isSali => _mode == DemoThemeMode.sali;
  bool get isAuto => _mode == DemoThemeMode.auto;
  bool get prefersDark => _mediaQueryList?.matches ?? false;
  String get modeValue => switch (_mode) {
        DemoThemeMode.light => _lightValue,
        DemoThemeMode.dark => _darkValue,
        DemoThemeMode.blu => _bluValue,
        DemoThemeMode.pink => _pinkValue,
        DemoThemeMode.orange => _orangeValue,
        DemoThemeMode.sali => _saliValue,
        DemoThemeMode.auto => _autoValue,
      };
  String get themeValue => _resolvedThemeValue();

  void useLight() {
    _mode = DemoThemeMode.light;
    _applyTheme();
  }

  void useDark() {
    _mode = DemoThemeMode.dark;
    _applyTheme();
  }

  void useBlu() {
    _mode = DemoThemeMode.blu;
    _applyTheme();
  }

  void usePink() {
    _mode = DemoThemeMode.pink;
    _applyTheme();
  }

  void useOrange() {
    _mode = DemoThemeMode.orange;
    _applyTheme();
  }

  void useSali() {
    _mode = DemoThemeMode.sali;
    _applyTheme();
  }

  void useAuto() {
    _mode = DemoThemeMode.auto;
    _applyTheme();
  }

  void _applyTheme() {
    final value = _resolvedThemeValue();
    html.document.documentElement?.attributes['data-color-theme'] = value;
    html.window.localStorage[_storageKey] = modeValue;
  }

  String _resolvedThemeValue() {
    if (_mode == DemoThemeMode.auto) {
      return prefersDark ? _darkValue : _lightValue;
    }

    return switch (_mode) {
      DemoThemeMode.light => _lightValue,
      DemoThemeMode.dark => _darkValue,
      DemoThemeMode.blu => _bluValue,
      DemoThemeMode.pink => _pinkValue,
      DemoThemeMode.orange => _orangeValue,
      DemoThemeMode.sali => _saliValue,
      DemoThemeMode.auto => prefersDark ? _darkValue : _lightValue,
    };
  }

  void dispose() {
    _mediaQueryList?.removeEventListener('change', _themeChangeListener);
  }
}
