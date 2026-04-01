import 'dart:async';
import 'dart:html' as html;

enum SweetAlertType { success, error, warning, info, question }

enum SweetAlertPosition {
  center,
  centerStart,
  centerEnd,
  top,
  topStart,
  topEnd,
  bottom,
  bottomStart,
  bottomEnd,
}

enum SweetAlertInputType {
  text,
  email,
  url,
  password,
  number,
  textarea,
  select,
  radio,
  checkbox,
  range,
}

enum SweetAlertGrowMode { fullscreen, row, column }

enum SweetAlertDismissReason {
  cancel,
  backdrop,
  closeButton,
  escape,
  timer,
  programmatic,
}

typedef SweetAlertInputValidator = FutureOr<String?> Function(String value);
typedef SweetAlertLifecycleCallback = void Function(html.Element popup);

class SweetAlertResult<T> {
  const SweetAlertResult._({
    required this.isConfirmed,
    required this.isDismissed,
    this.value,
    this.dismissReason,
  });

  final bool isConfirmed;
  final bool isDismissed;
  final T? value;
  final SweetAlertDismissReason? dismissReason;

  factory SweetAlertResult.confirmed([T? value]) {
    return SweetAlertResult._(
      isConfirmed: true,
      isDismissed: false,
      value: value,
    );
  }

  factory SweetAlertResult.dismissed(SweetAlertDismissReason reason) {
    return SweetAlertResult._(
      isConfirmed: false,
      isDismissed: true,
      dismissReason: reason,
    );
  }
}

class SweetAlertController {
  SweetAlertController._(this._close, this.closed);

  final void Function() _close;
  final Future<SweetAlertDismissReason> closed;

  void close() {
    _close();
  }
}

class SweetAlert {
  static final Set<html.Element> _activeRoots = <html.Element>{};
  static int _sequence = 0;

  static Future<SweetAlertResult<void>> show({
    String? title,
    String? message,
    String? htmlContent,
    String? footer,
    SweetAlertType type = SweetAlertType.info,
    SweetAlertPosition position = SweetAlertPosition.center,
    String confirmButtonText = 'OK',
    bool allowOutsideClick = true,
    bool allowEscapeKey = true,
    bool showCloseButton = false,
    bool backdrop = true,
    bool animation = true,
    bool reverseButtons = false,
    Duration? timer,
    bool timerProgressBar = false,
    String? width,
    String? padding,
    String? background,
    String? backgroundImageUrl,
    String? imageUrl,
    num? imageWidth,
    num? imageHeight,
    String imageAlt = '',
    SweetAlertGrowMode? grow,
    String? containerClass,
    String? popupClass,
    String? confirmButtonClass,
    SweetAlertLifecycleCallback? onOpen,
    SweetAlertLifecycleCallback? onClose,
  }) {
    return _show<void>(
      title: title,
      message: message,
      htmlContent: htmlContent,
      footer: footer,
      type: type,
      position: position,
      confirmButtonText: confirmButtonText,
      allowOutsideClick: allowOutsideClick,
      allowEscapeKey: allowEscapeKey,
      showCloseButton: showCloseButton,
      backdrop: backdrop,
      animation: animation,
      reverseButtons: reverseButtons,
      timer: timer,
      timerProgressBar: timerProgressBar,
      width: width,
      padding: padding,
      background: background,
      backgroundImageUrl: backgroundImageUrl,
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imageAlt: imageAlt,
      grow: grow,
      containerClass: containerClass,
      popupClass: popupClass,
      confirmButtonClass: confirmButtonClass,
      onOpen: onOpen,
      onClose: onClose,
      onConfirm: (_) => null,
    ).result;
  }

  static Future<SweetAlertResult<bool>> confirm({
    String? title,
    String? message,
    String? htmlContent,
    String? footer,
    SweetAlertType type = SweetAlertType.question,
    SweetAlertPosition position = SweetAlertPosition.center,
    String confirmButtonText = 'OK',
    String cancelButtonText = 'Cancel',
    bool allowOutsideClick = true,
    bool allowEscapeKey = true,
    bool showCloseButton = false,
    bool backdrop = true,
    bool animation = true,
    bool reverseButtons = false,
    String? width,
    String? padding,
    String? background,
    String? backgroundImageUrl,
    String? imageUrl,
    num? imageWidth,
    num? imageHeight,
    String imageAlt = '',
    SweetAlertGrowMode? grow,
    String? containerClass,
    String? popupClass,
    String? confirmButtonClass,
    String? cancelButtonClass,
    SweetAlertLifecycleCallback? onOpen,
    SweetAlertLifecycleCallback? onClose,
  }) {
    return _show<bool>(
      title: title,
      message: message,
      htmlContent: htmlContent,
      footer: footer,
      type: type,
      position: position,
      showCancelButton: true,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      allowOutsideClick: allowOutsideClick,
      allowEscapeKey: allowEscapeKey,
      showCloseButton: showCloseButton,
      backdrop: backdrop,
      animation: animation,
      reverseButtons: reverseButtons,
      width: width,
      padding: padding,
      background: background,
      backgroundImageUrl: backgroundImageUrl,
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imageAlt: imageAlt,
      grow: grow,
      containerClass: containerClass,
      popupClass: popupClass,
      confirmButtonClass: confirmButtonClass,
      cancelButtonClass: cancelButtonClass,
      onOpen: onOpen,
      onClose: onClose,
      onConfirm: (_) => true,
    ).result;
  }

  static Future<SweetAlertResult<String>> prompt({
    String? title,
    String? message,
    String? htmlContent,
    String? footer,
    SweetAlertType type = SweetAlertType.question,
    SweetAlertPosition position = SweetAlertPosition.center,
    SweetAlertInputType inputType = SweetAlertInputType.text,
    String? inputPlaceholder,
    String? inputValue,
    Map<String, String>? inputOptions,
    String? inputLabel,
    bool inputChecked = false,
    num? inputMin,
    num? inputMax,
    num? inputStep,
    SweetAlertInputValidator? inputValidator,
    String confirmButtonText = 'Confirm',
    String cancelButtonText = 'Cancel',
    bool allowOutsideClick = true,
    bool allowEscapeKey = true,
    bool showCloseButton = true,
    bool backdrop = true,
    bool animation = true,
    bool reverseButtons = false,
    String? width,
    String? padding,
    String? background,
    String? backgroundImageUrl,
    String? imageUrl,
    num? imageWidth,
    num? imageHeight,
    String imageAlt = '',
    SweetAlertGrowMode? grow,
    String? containerClass,
    String? popupClass,
    String? confirmButtonClass,
    String? cancelButtonClass,
    SweetAlertLifecycleCallback? onOpen,
    SweetAlertLifecycleCallback? onClose,
  }) {
    final instance = _show<String>(
      title: title,
      message: message,
      htmlContent: htmlContent,
      footer: footer,
      type: type,
      position: position,
      showCancelButton: true,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      allowOutsideClick: allowOutsideClick,
      allowEscapeKey: allowEscapeKey,
      showCloseButton: showCloseButton,
      backdrop: backdrop,
      animation: animation,
      reverseButtons: reverseButtons,
      width: width,
      padding: padding,
      background: background,
      backgroundImageUrl: backgroundImageUrl,
      imageUrl: imageUrl,
      imageWidth: imageWidth,
      imageHeight: imageHeight,
      imageAlt: imageAlt,
      grow: grow,
      containerClass: containerClass,
      popupClass: popupClass,
      confirmButtonClass: confirmButtonClass,
      cancelButtonClass: cancelButtonClass,
      inputType: inputType,
      inputPlaceholder: inputPlaceholder,
      inputValue: inputValue,
      inputOptions: inputOptions,
      inputLabel: inputLabel,
      inputChecked: inputChecked,
      inputMin: inputMin,
      inputMax: inputMax,
      inputStep: inputStep,
      inputValidator: inputValidator,
      onOpen: onOpen,
      onClose: onClose,
      onConfirm: (activeInstance) => activeInstance.readInputValue(),
    );
    return instance.result;
  }

  static SweetAlertController toast(
    String message, {
    String? title,
    SweetAlertType type = SweetAlertType.success,
    SweetAlertPosition position = SweetAlertPosition.topEnd,
    Duration? timer = const Duration(seconds: 3),
    bool timerProgressBar = true,
    bool closeOnClick = true,
    String? containerClass,
    String? popupClass,
  }) {
    return _show<void>(
      title: title,
      message: message,
      type: type,
      toast: true,
      position: position,
      showConfirmButton: false,
      allowOutsideClick: closeOnClick,
      allowEscapeKey: true,
      timer: timer,
      timerProgressBar: timerProgressBar,
      closeOnClick: closeOnClick,
      containerClass: containerClass,
      popupClass: popupClass,
      onConfirm: (_) => null,
    ).controller;
  }

  static void dismissAll() {
    final roots = _activeRoots.toList(growable: false);
    for (final root in roots) {
      root.remove();
    }
    _activeRoots.clear();
    _syncBodyClasses();
  }

  static _SweetAlertInstance<T> _show<T>({
    String? title,
    String? message,
    String? htmlContent,
    String? footer,
    SweetAlertType? type,
    bool toast = false,
    SweetAlertPosition position = SweetAlertPosition.center,
    bool showConfirmButton = true,
    bool showCancelButton = false,
    String confirmButtonText = 'OK',
    String cancelButtonText = 'Cancel',
    bool allowOutsideClick = true,
    bool allowEscapeKey = true,
    bool showCloseButton = false,
    bool backdrop = true,
    bool animation = true,
    bool reverseButtons = false,
    bool closeOnClick = false,
    Duration? timer,
    bool timerProgressBar = false,
    SweetAlertInputType? inputType,
    String? inputPlaceholder,
    String? inputValue,
    Map<String, String>? inputOptions,
    String? inputLabel,
    bool inputChecked = false,
    num? inputMin,
    num? inputMax,
    num? inputStep,
    SweetAlertInputValidator? inputValidator,
    String? width,
    String? padding,
    String? background,
    String? backgroundImageUrl,
    String? imageUrl,
    num? imageWidth,
    num? imageHeight,
    String imageAlt = '',
    SweetAlertGrowMode? grow,
    String? containerClass,
    String? popupClass,
    String? confirmButtonClass,
    String? cancelButtonClass,
    SweetAlertLifecycleCallback? onOpen,
    SweetAlertLifecycleCallback? onClose,
    required FutureOr<T?> Function(_SweetAlertInstance<T> instance) onConfirm,
  }) {
    final alertId = _sequence++;
    final root = html.DivElement()
      ..id = 'swal2-container-$alertId'
      ..classes.addAll(<String>['swal2-container', _positionClass(position)]);
    root.classes.addAll(_classNames(containerClass));
    root.style.zIndex = '3000';
    root.style.overflowY = 'auto';
    if (!toast && backdrop) {
      root.classes.add('swal2-backdrop-show');
    }
    if (!toast && !backdrop) {
      root.style.background = 'transparent';
    }

    final popup = html.DivElement()
      ..classes.addAll(<String>[
        'swal2-popup',
        toast ? 'swal2-toast' : 'swal2-modal',
        if (animation) 'swal2-show',
      ])
      ..tabIndex = -1
      ..style.display = 'grid'
      ..attributes['role'] = toast ? 'alert' : 'dialog'
      ..attributes['aria-live'] = toast ? 'polite' : 'assertive';
    if (!toast) {
      popup.attributes['aria-modal'] = 'true';
    }
    popup.classes.addAll(_classNames(popupClass));
    if (type != null) {
      popup.classes.add('swal2-icon-${_iconName(type)}');
    }
    if (toast) {
      popup.style.width = '100%';
    }
    if (width != null && width.trim().isNotEmpty) {
      popup.style.width = width;
    }
    if (padding != null && padding.trim().isNotEmpty) {
      popup.style.padding = padding;
    }
    if (background != null && background.trim().isNotEmpty) {
      popup.style.background = background;
    }
    if (backgroundImageUrl != null && backgroundImageUrl.trim().isNotEmpty) {
      popup.style
        ..backgroundImage = 'url("${backgroundImageUrl.trim()}")'
        ..backgroundPosition = 'center'
        ..backgroundRepeat = 'no-repeat'
        ..backgroundSize = 'cover';
    }
    if (grow != null) {
      popup.classes.add(_growClass(grow));
    }

    if (showCloseButton) {
      final closeButton = html.ButtonElement()
        ..type = 'button'
        ..classes.add('swal2-close')
        ..attributes['aria-label'] = 'Close'
        ..text = '×';
      popup.append(closeButton);
    }

    final titleId = 'swal2-title-$alertId';
    final htmlContainerId = 'swal2-html-container-$alertId';
    popup.attributes['aria-labelledby'] = titleId;
    popup.attributes['aria-describedby'] = htmlContainerId;

    if (type != null) {
      popup.append(_createIcon(type));
    }

    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      popup.append(
        _createImage(
          imageUrl.trim(),
          width: imageWidth,
          height: imageHeight,
          alt: imageAlt,
        ),
      );
    }

    if (title != null && title.trim().isNotEmpty) {
      final titleElement = html.HeadingElement.h2()
        ..classes.add('swal2-title')
        ..id = titleId
        ..text = title;
      popup.append(titleElement);
    }

    final htmlContainer = html.DivElement()
      ..classes.add('swal2-html-container')
      ..id = htmlContainerId;
    if (message != null && message.trim().isNotEmpty) {
      final bodyText = html.DivElement()
        ..text = message
        ..style.whiteSpace = 'pre-line';
      htmlContainer.append(bodyText);
    }
    if (htmlContent != null && htmlContent.trim().isNotEmpty) {
      final htmlBlock = html.DivElement();
      htmlBlock.setInnerHtml(
        htmlContent,
        treeSanitizer: html.NodeTreeSanitizer.trusted,
      );
      htmlContainer.append(htmlBlock);
    }

    htmlContainer.style.display =
        htmlContainer.children.isNotEmpty ? 'block' : 'none';
    popup.append(htmlContainer);

    html.Element? inputElement;
    final validationMessage = html.DivElement()
      ..classes.add('swal2-validation-message')
      ..style.display = 'none';
    if (inputType != null) {
      inputElement = _createInput(
        inputType,
        inputPlaceholder,
        inputValue,
        inputOptions: inputOptions,
        inputLabel: inputLabel,
        inputChecked: inputChecked,
        inputMin: inputMin,
        inputMax: inputMax,
        inputStep: inputStep,
      );
      popup
        ..append(inputElement)
        ..append(validationMessage);
    }

    if (footer != null && footer.trim().isNotEmpty) {
      final footerElement = html.DivElement()
        ..classes.add('swal2-footer')
        ..text = footer;
      popup.append(footerElement);
    }

    html.DivElement? progressContainer;
    html.DivElement? progressBar;
    if (timer != null && timerProgressBar) {
      progressContainer = html.DivElement()
        ..classes.add('swal2-timer-progress-bar-container');
      progressBar = html.DivElement()..classes.add('swal2-timer-progress-bar');
      progressBar.style.width = '100%';
      progressContainer.append(progressBar);
      popup.append(progressContainer);
    }

    if (showConfirmButton || showCancelButton) {
      final actions = html.DivElement()..classes.add('swal2-actions');
      actions.append(html.DivElement()..classes.add('swal2-loader'));
      final buttons = <html.Element>[];
      if (showConfirmButton) {
        buttons.add(
          html.ButtonElement()
            ..type = 'button'
            ..classes.addAll(
              <String>[
                'swal2-confirm',
                'swal2-styled',
                'btn',
                'btn-primary',
                ..._classNames(confirmButtonClass),
              ],
            )
            ..text = confirmButtonText,
        );
      }
      if (showCancelButton) {
        buttons.add(
          html.ButtonElement()
            ..type = 'button'
            ..classes.addAll(
              <String>[
                'swal2-cancel',
                'swal2-styled',
                'btn',
                'btn-light',
                ..._classNames(cancelButtonClass),
              ],
            )
            ..text = cancelButtonText,
        );
      }
      if (reverseButtons && buttons.length > 1) {
        actions.children.addAll(buttons.reversed);
      } else {
        actions.children.addAll(buttons);
      }
      popup.append(actions);
    }

    root.append(popup);
    html.document.body?.append(root);
    _activeRoots.add(root);
    _syncBodyClasses();

    return _SweetAlertInstance<T>(
      root: root,
      popup: popup,
      inputElement: inputElement,
      validationMessage: validationMessage,
      toast: toast,
      allowOutsideClick: allowOutsideClick,
      allowEscapeKey: allowEscapeKey,
      closeOnClick: closeOnClick,
      timer: timer,
      progressBar: progressBar,
      inputValidator: inputValidator,
      onOpen: onOpen,
      onClose: onClose,
      onConfirm: onConfirm,
    )..attach();
  }

  static html.Element _createIcon(SweetAlertType type) {
    final icon = html.DivElement()
      ..classes.addAll(<String>['swal2-icon', 'swal2-${_iconName(type)}', 'swal2-icon-show'])
      ..style.display = 'flex';

    switch (type) {
      case SweetAlertType.success:
        icon.append(html.DivElement()..classes.add('swal2-success-circular-line-left'));
        icon.append(html.SpanElement()..classes.add('swal2-success-line-tip'));
        icon.append(html.SpanElement()..classes.add('swal2-success-line-long'));
        icon.append(html.DivElement()..classes.add('swal2-success-ring'));
        icon.append(html.DivElement()..classes.add('swal2-success-fix'));
        icon.append(html.DivElement()..classes.add('swal2-success-circular-line-right'));
        break;
      case SweetAlertType.error:
        final xMark = html.SpanElement()..classes.add('swal2-x-mark');
        xMark.append(
          html.SpanElement()..classes.add('swal2-x-mark-line-left'),
        );
        xMark.append(
          html.SpanElement()..classes.add('swal2-x-mark-line-right'),
        );
        icon.append(xMark);
        break;
      case SweetAlertType.warning:
        icon.append(html.DivElement()
          ..classes.add('swal2-icon-content')
          ..text = '!');
        break;
      case SweetAlertType.info:
        icon.append(html.DivElement()
          ..classes.add('swal2-icon-content')
          ..text = 'i');
        break;
      case SweetAlertType.question:
        icon.append(html.DivElement()
          ..classes.add('swal2-icon-content')
          ..text = '?');
        break;
    }

    return icon;
  }

  static html.Element _createInput(
    SweetAlertInputType inputType,
    String? inputPlaceholder,
    String? inputValue,
    {
    Map<String, String>? inputOptions,
    String? inputLabel,
    bool inputChecked = false,
    num? inputMin,
    num? inputMax,
    num? inputStep,
  }
  ) {
    switch (inputType) {
      case SweetAlertInputType.select:
        final select = html.SelectElement()
          ..classes.add('swal2-select')
          ..style.display = 'block';
        final placeholder = inputPlaceholder?.trim();
        if (placeholder != null && placeholder.isNotEmpty) {
          select.append(
            html.OptionElement()
              ..value = ''
              ..text = placeholder
              ..disabled = true
              ..selected = (inputValue ?? '').trim().isEmpty,
          );
        }
        for (final entry in (inputOptions ?? const <String, String>{}).entries) {
          select.append(
            html.OptionElement()
              ..value = entry.key
              ..text = entry.value
              ..selected = entry.key == (inputValue ?? ''),
          );
        }
        return select;
      case SweetAlertInputType.radio:
        final container = html.DivElement()
          ..classes.add('swal2-radio')
          ..style.display = 'flex'
          ..style.flexDirection = 'column';
        final resolvedValue = inputValue ??
            ((inputOptions ?? const <String, String>{}).keys.isNotEmpty
                ? (inputOptions ?? const <String, String>{}).keys.first
                : '');
        for (final entry in (inputOptions ?? const <String, String>{}).entries) {
          final label = html.LabelElement()..classes.add('swal2-radio-label');
          final input = html.RadioButtonInputElement()
            ..name = 'swal2-radio'
            ..value = entry.key
            ..checked = entry.key == resolvedValue;
          label
            ..append(input)
            ..append(html.SpanElement()..text = entry.value);
          container.append(label);
        }
        return container;
      case SweetAlertInputType.checkbox:
        final checkbox = html.CheckboxInputElement()
          ..checked = inputChecked || (inputValue ?? '').toLowerCase() == 'true';
        final label = html.LabelElement()
          ..classes.add('swal2-checkbox')
          ..style.display = 'flex'
          ..style.alignItems = 'center'
          ..style.gap = '0.5rem';
        label
          ..append(checkbox)
          ..append(html.SpanElement()..text = inputLabel ?? inputPlaceholder ?? '');
        return label;
      case SweetAlertInputType.range:
        final range = html.InputElement()
          ..classes.add('swal2-range')
          ..style.display = 'block'
          ..type = 'range'
          ..value = inputValue ?? ''
          ..autocomplete = 'off';
        if (inputMin != null) {
          range.min = '$inputMin';
        }
        if (inputMax != null) {
          range.max = '$inputMax';
        }
        if (inputStep != null) {
          range.step = '$inputStep';
        }
        return range;
      case SweetAlertInputType.textarea:
        return html.TextAreaElement()
          ..classes.add('swal2-textarea')
          ..style.display = 'block'
          ..placeholder = inputPlaceholder ?? ''
          ..value = inputValue ?? '';
      case SweetAlertInputType.text:
      case SweetAlertInputType.email:
      case SweetAlertInputType.url:
      case SweetAlertInputType.password:
      case SweetAlertInputType.number:
        return html.InputElement()
          ..classes.add('swal2-input')
          ..style.display = 'block'
          ..type = _inputTypeName(inputType)
          ..placeholder = inputPlaceholder ?? ''
          ..value = inputValue ?? ''
          ..autocomplete = 'off';
    }
  }

  static String _inputTypeName(SweetAlertInputType inputType) {
    switch (inputType) {
      case SweetAlertInputType.text:
        return 'text';
      case SweetAlertInputType.email:
        return 'email';
      case SweetAlertInputType.url:
        return 'url';
      case SweetAlertInputType.password:
        return 'password';
      case SweetAlertInputType.number:
        return 'number';
      case SweetAlertInputType.textarea:
      case SweetAlertInputType.select:
      case SweetAlertInputType.radio:
      case SweetAlertInputType.checkbox:
      case SweetAlertInputType.range:
        return 'text';
    }
  }

  static String _positionClass(SweetAlertPosition position) {
    switch (position) {
      case SweetAlertPosition.center:
        return 'swal2-center';
      case SweetAlertPosition.centerStart:
        return 'swal2-center-start';
      case SweetAlertPosition.centerEnd:
        return 'swal2-center-end';
      case SweetAlertPosition.top:
        return 'swal2-top';
      case SweetAlertPosition.topStart:
        return 'swal2-top-start';
      case SweetAlertPosition.topEnd:
        return 'swal2-top-end';
      case SweetAlertPosition.bottom:
        return 'swal2-bottom';
      case SweetAlertPosition.bottomStart:
        return 'swal2-bottom-start';
      case SweetAlertPosition.bottomEnd:
        return 'swal2-bottom-end';
    }
  }

  static String _growClass(SweetAlertGrowMode grow) {
    switch (grow) {
      case SweetAlertGrowMode.fullscreen:
        return 'swal2-grow-fullscreen';
      case SweetAlertGrowMode.row:
        return 'swal2-grow-row';
      case SweetAlertGrowMode.column:
        return 'swal2-grow-column';
    }
  }

  static html.Element _createImage(
    String imageUrl, {
    num? width,
    num? height,
    String alt = '',
  }) {
    return html.ImageElement(src: imageUrl)
      ..classes.add('swal2-image')
      ..alt = alt
      ..style.display = 'block'
      ..style.marginLeft = 'auto'
      ..style.marginRight = 'auto'
      ..style.maxWidth = '100%'
      ..style.width = width == null ? '' : '${width}px'
      ..style.height = height == null ? '' : '${height}px';
  }

  static String _iconName(SweetAlertType type) {
    switch (type) {
      case SweetAlertType.success:
        return 'success';
      case SweetAlertType.error:
        return 'error';
      case SweetAlertType.warning:
        return 'warning';
      case SweetAlertType.info:
        return 'info';
      case SweetAlertType.question:
        return 'question';
    }
  }

  static List<String> _classNames(String? rawClasses) {
    final normalized = rawClasses?.trim();
    if (normalized == null || normalized.isEmpty) {
      return const <String>[];
    }

    return normalized
        .split(RegExp(r'\s+'))
        .where((className) => className.trim().isNotEmpty)
        .toList(growable: false);
  }

  static void _syncBodyClasses() {
    final body = html.document.body;
    if (body == null) {
      return;
    }

    if (_activeRoots.isEmpty) {
      body.classes.removeAll(
        const <String>['swal2-shown', 'swal2-height-auto', 'swal2-toast-shown'],
      );
      return;
    }

    body.classes.add('swal2-shown');
    final hasToast = _activeRoots.any(
      (root) => root.querySelector('.swal2-toast') != null,
    );
    final hasModal = _activeRoots.any(
      (root) => root.querySelector('.swal2-modal') != null,
    );

    if (hasToast) {
      body.classes.add('swal2-toast-shown');
    } else {
      body.classes.remove('swal2-toast-shown');
    }

    if (hasModal) {
      body.classes.add('swal2-height-auto');
    } else {
      body.classes.remove('swal2-height-auto');
    }
  }
}

class _SweetAlertInstance<T> {
  _SweetAlertInstance({
    required this.root,
    required this.popup,
    required this.inputElement,
    required this.validationMessage,
    required this.toast,
    required this.allowOutsideClick,
    required this.allowEscapeKey,
    required this.closeOnClick,
    required this.timer,
    required this.progressBar,
    required this.inputValidator,
    required this.onOpen,
    required this.onClose,
    required this.onConfirm,
  });

  final html.DivElement root;
  final html.DivElement popup;
  final html.Element? inputElement;
  final html.DivElement validationMessage;
  final bool toast;
  final bool allowOutsideClick;
  final bool allowEscapeKey;
  final bool closeOnClick;
  final Duration? timer;
  final html.DivElement? progressBar;
  final SweetAlertInputValidator? inputValidator;
  final SweetAlertLifecycleCallback? onOpen;
  final SweetAlertLifecycleCallback? onClose;
  final FutureOr<T?> Function(_SweetAlertInstance<T> instance) onConfirm;

  final Completer<SweetAlertResult<T>> _resultCompleter =
      Completer<SweetAlertResult<T>>();
  final Completer<SweetAlertDismissReason> _closedCompleter =
      Completer<SweetAlertDismissReason>();
  final List<StreamSubscription<dynamic>> _subscriptions =
      <StreamSubscription<dynamic>>[];
  Timer? _timer;
  Timer? _progressTimer;
  bool _closed = false;
  late final SweetAlertController controller;

  Future<SweetAlertResult<T>> get result => _resultCompleter.future;

  void attach() {
    controller = SweetAlertController._(
      () => dismiss(SweetAlertDismissReason.programmatic),
      _closedCompleter.future,
    );

    final closeButton = popup.querySelector('.swal2-close');
    if (closeButton != null) {
      _subscriptions.add(closeButton.onClick.listen((event) {
        event.preventDefault();
        dismiss(SweetAlertDismissReason.closeButton);
      }));
    }

    final cancelButton = popup.querySelector('.swal2-cancel');
    if (cancelButton != null) {
      _subscriptions.add(cancelButton.onClick.listen((event) {
        event.preventDefault();
        dismiss(SweetAlertDismissReason.cancel);
      }));
    }

    final confirmButton = popup.querySelector('.swal2-confirm');
    if (confirmButton != null) {
      _subscriptions.add(confirmButton.onClick.listen((event) async {
        event.preventDefault();
        await confirm();
      }));
    }

    if (allowOutsideClick) {
      _subscriptions.add(root.onClick.listen((event) {
        if (toast && closeOnClick) {
          dismiss(SweetAlertDismissReason.closeButton);
          return;
        }

        if (event.target == root) {
          dismiss(SweetAlertDismissReason.backdrop);
        }
      }));
    }

    _subscriptions.add(popup.onClick.listen((event) {
      event.stopPropagation();
    }));

    if (allowEscapeKey) {
      _subscriptions.add(html.document.onKeyDown.listen((event) async {
        if (event.key == 'Escape' || event.keyCode == 27) {
          event.preventDefault();
          dismiss(SweetAlertDismissReason.escape);
          return;
        }

        if (inputElement != null &&
            (event.key == 'Enter' || event.keyCode == 13) &&
            event.target == inputElement) {
          event.preventDefault();
          await confirm();
        }
      }));
    }

    if (timer != null) {
      final totalMilliseconds = timer!.inMilliseconds;
      final start = DateTime.now();
      _timer = Timer(timer!, () => dismiss(SweetAlertDismissReason.timer));
      if (progressBar != null && totalMilliseconds > 0) {
        _progressTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
          final elapsed = DateTime.now().difference(start).inMilliseconds;
          final remaining = (totalMilliseconds - elapsed).clamp(0, totalMilliseconds);
          final progress = remaining / totalMilliseconds;
          progressBar!.style.width = '${progress * 100}%';
          if (_closed || remaining == 0) {
            timer.cancel();
          }
        });
      }
    }

    onOpen?.call(popup);

    Future<void>.delayed(const Duration(milliseconds: 20), () {
      if (_closed) {
        return;
      }
      final inputFocusTarget = _resolveInputFocusTarget();
      if (inputFocusTarget != null) {
        inputFocusTarget.focus();
        return;
      }
      final defaultFocus = popup.querySelector('.swal2-confirm') ??
          popup.querySelector('.swal2-cancel') ??
          popup.querySelector('.swal2-close');
      if (defaultFocus is html.HtmlElement) {
        defaultFocus.focus();
      }
    });
  }

  Future<void> confirm() async {
    if (_closed) {
      return;
    }

    if (inputElement != null) {
      final value = readInputValue();
      if (inputValidator != null) {
        final validation = await inputValidator!(value ?? '');
        if (validation != null && validation.trim().isNotEmpty) {
          validationMessage
            ..text = validation
            ..style.display = 'flex';
          return;
        }
      }
      validationMessage
        ..text = ''
        ..style.display = 'none';
    }

    final value = await onConfirm(this);
    if (_closed) {
      return;
    }
    _close(SweetAlertResult<T>.confirmed(value));
  }

  String? readInputValue() {
    final element = inputElement;
    if (element is html.InputElement) {
      if (element.type == 'checkbox') {
        return element.checked == true ? 'true' : 'false';
      }
      return element.value;
    }
    if (element is html.SelectElement) {
      return element.value;
    }
    if (element is html.TextAreaElement) {
      return element.value;
    }
    if (element is html.LabelElement) {
      final checkbox =
          element.querySelector('input[type="checkbox"]') as html.InputElement?;
      if (checkbox != null) {
        return checkbox.checked == true ? 'true' : 'false';
      }
    }
    if (element is html.DivElement) {
      final selected = element.querySelector('input[type="radio"]:checked')
          as html.InputElement?;
      if (selected != null) {
        return selected.value;
      }
    }
    return null;
  }

  html.HtmlElement? _resolveInputFocusTarget() {
    final element = inputElement;
    if (element is html.InputElement ||
        element is html.SelectElement ||
        element is html.TextAreaElement) {
      return element as html.HtmlElement;
    }

    final candidate = element?.querySelector('input, select, textarea');
    if (candidate is html.HtmlElement) {
      return candidate;
    }

    return null;
  }

  void dismiss(SweetAlertDismissReason reason) {
    if (_closed) {
      return;
    }
    _close(SweetAlertResult<T>.dismissed(reason), reason: reason);
  }

  void _close(
    SweetAlertResult<T> result, {
    SweetAlertDismissReason reason = SweetAlertDismissReason.programmatic,
  }) {
    if (_closed) {
      return;
    }
    _closed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _timer?.cancel();
    _progressTimer?.cancel();
    onClose?.call(popup);
    root.remove();
    SweetAlert._activeRoots.remove(root);
    SweetAlert._syncBodyClasses();
    if (!_resultCompleter.isCompleted) {
      _resultCompleter.complete(result);
    }
    if (!_closedCompleter.isCompleted) {
      _closedCompleter.complete(reason);
    }
  }
}