import 'dart:js_interop';
import 'dart:async';
import 'package:web/web.dart' as web;

import '../../web_support/dom_tokens.dart';
import '../../web_support/html_sinks.dart';

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
typedef SweetAlertLifecycleCallback = void Function(web.Element popup);
typedef SweetAlertResultCallback<T> = FutureOr<void> Function(
  SweetAlertResult<T> result,
);

class SweetAlertInputConfig {
  const SweetAlertInputConfig({
    this.className,
    this.style,
    this.attributes,
    this.rows,
    this.cols,
    this.minLength,
    this.maxLength,
    this.autocomplete,
  });

  final String? className;
  final Map<String, String>? style;
  final Map<String, String>? attributes;
  final int? rows;
  final int? cols;
  final int? minLength;
  final int? maxLength;
  final String? autocomplete;
}

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
  static final Set<web.Element> _activeRoots = <web.Element>{};
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
    SweetAlertResultCallback<void>? onConfirmAction,
    SweetAlertResultCallback<void>? onDismissAction,
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
      onConfirmAction: onConfirmAction,
      onDismissAction: onDismissAction,
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
    SweetAlertResultCallback<bool>? onConfirmAction,
    SweetAlertResultCallback<bool>? onCancelAction,
    SweetAlertResultCallback<bool>? onDismissAction,
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
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
      onDismissAction: onDismissAction,
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
    SweetAlertInputConfig? inputConfig,
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
    SweetAlertResultCallback<String>? onConfirmAction,
    SweetAlertResultCallback<String>? onCancelAction,
    SweetAlertResultCallback<String>? onDismissAction,
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
      inputConfig: inputConfig,
      inputValidator: inputValidator,
      onOpen: onOpen,
      onClose: onClose,
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
      onDismissAction: onDismissAction,
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
    SweetAlertInputConfig? inputConfig,
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
    SweetAlertResultCallback<T>? onConfirmAction,
    SweetAlertResultCallback<T>? onCancelAction,
    SweetAlertResultCallback<T>? onDismissAction,
    required FutureOr<T?> Function(_SweetAlertInstance<T> instance) onConfirm,
  }) {
    final alertId = _sequence++;
    final root = addClassTokens(
      web.HTMLDivElement()..id = 'swal2-container-$alertId',
      <String>['swal2-container', _positionClass(position)],
    )
      ..setAttribute('data-label', 'li_sa_root')
      ..setAttribute('data-value', alertId.toString())
      ..setAttribute('data-open', 'true')
      ..setAttribute('data-toast', toast ? 'true' : 'false');
    addClassTokens(root, _classNames(containerClass));
    root.style.zIndex = '3000';
    root.style.overflowY = 'auto';
    if (!toast && backdrop) {
      root.classList.add('swal2-backdrop-show');
    }
    if (!toast && !backdrop) {
      root.style.background = 'transparent';
    }

    final popup = addClassTokens(
      web.HTMLDivElement(),
      <String>[
        'swal2-popup',
        toast ? 'swal2-toast' : 'swal2-modal',
        if (animation) 'swal2-show',
      ],
    )
      ..tabIndex = -1
      ..style.display = 'grid'
      ..setAttribute('role', toast ? 'alert' : 'dialog')
      ..setAttribute('aria-live', toast ? 'polite' : 'assertive')
      ..setAttribute('data-label', 'li_sa_popup')
      ..setAttribute('data-value', alertId.toString())
      ..setAttribute('data-open', 'true')
      ..setAttribute('data-toast', toast ? 'true' : 'false');
    if (!toast) {
      popup.setAttribute('aria-modal', 'true');
    }
    addClassTokens(popup, _classNames(popupClass));
    if (type != null) {
      popup.classList.add('swal2-icon-${_iconName(type)}');
      popup.setAttribute('data-type', _iconName(type));
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
      popup.classList.add(_growClass(grow));
    }

    if (showCloseButton) {
      final closeButton = web.HTMLButtonElement()
        ..type = 'button'
        ..classList.add('swal2-close')
        ..setAttribute('aria-label', 'Close')
        ..setAttribute('data-label', 'li_sa_close')
        ..setAttribute('data-value', alertId.toString())
        ..textContent = '×';
      popup.append(closeButton);
    }

    final titleId = 'swal2-title-$alertId';
    final htmlContainerId = 'swal2-html-container-$alertId';
    popup.setAttribute('aria-labelledby', titleId);
    popup.setAttribute('aria-describedby', htmlContainerId);

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
      final titleElement = web.HTMLHeadingElement.h2()
        ..classList.add('swal2-title')
        ..id = titleId
        ..setAttribute('data-label', 'li_sa_title')
        ..setAttribute('data-value', alertId.toString())
        ..textContent = title;
      popup.append(titleElement);
    }

    final htmlContainer = web.HTMLDivElement()
      ..classList.add('swal2-html-container')
      ..id = htmlContainerId
      ..setAttribute('data-label', 'li_sa_body')
      ..setAttribute('data-value', alertId.toString());
    if (message != null && message.trim().isNotEmpty) {
      final bodyText = web.HTMLDivElement()
        ..textContent = message
        ..style.whiteSpace = 'pre-line';
      htmlContainer.append(bodyText);
    }
    if (htmlContent != null && htmlContent.trim().isNotEmpty) {
      final htmlBlock = web.HTMLDivElement();
      setTrustedHtml(htmlBlock, htmlContent);
      htmlContainer.append(htmlBlock);
    }

    htmlContainer.style.display =
        htmlContainer.children.length != 0 ? 'block' : 'none';
    popup.append(htmlContainer);

    web.Element? inputElement;
    final validationMessage = web.HTMLDivElement()
      ..classList.add('swal2-validation-message')
      ..setAttribute('data-label', 'li_sa_validation')
      ..setAttribute('data-value', alertId.toString())
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
        inputConfig: inputConfig,
      );
      popup
        ..append(inputElement)
        ..append(validationMessage);
    }

    if (footer != null && footer.trim().isNotEmpty) {
      final footerElement = web.HTMLDivElement()
        ..classList.add('swal2-footer')
        ..setAttribute('data-label', 'li_sa_footer')
        ..setAttribute('data-value', alertId.toString())
        ..textContent = footer;
      popup.append(footerElement);
    }

    web.HTMLDivElement? progressContainer;
    web.HTMLDivElement? progressBar;
    if (timer != null && timerProgressBar) {
      progressContainer = web.HTMLDivElement()
        ..classList.add('swal2-timer-progress-bar-container')
        ..setAttribute('data-label', 'li_sa_progress');
      progressBar = web.HTMLDivElement()
        ..classList.add('swal2-timer-progress-bar')
        ..setAttribute('data-label', 'li_sa_progress_bar');
      progressBar.style.width = '100%';
      progressContainer.append(progressBar);
      popup.append(progressContainer);
    }

    if (showConfirmButton || showCancelButton) {
      final actions = web.HTMLDivElement()
        ..classList.add('swal2-actions')
        ..setAttribute('data-label', 'li_sa_actions')
        ..setAttribute('data-value', alertId.toString());
      actions.append(web.HTMLDivElement()
        ..classList.add('swal2-loader')
        ..setAttribute('data-label', 'li_sa_loader')
        ..setAttribute('data-value', alertId.toString()));
      final buttons = <web.Element>[];
      if (showConfirmButton) {
        buttons.add(
          addClassTokens(
            web.HTMLButtonElement()..type = 'button',
            <String>[
              'swal2-confirm',
              'swal2-styled',
              'btn',
              'btn-primary',
              ..._classNames(confirmButtonClass),
            ],
          )
            ..setAttribute('data-label', 'li_sa_confirm')
            ..setAttribute('data-value', alertId.toString())
            ..textContent = confirmButtonText,
        );
      }
      if (showCancelButton) {
        buttons.add(
          addClassTokens(
            web.HTMLButtonElement()..type = 'button',
            <String>[
              'swal2-cancel',
              'swal2-styled',
              'btn',
              'btn-light',
              ..._classNames(cancelButtonClass),
            ],
          )
            ..setAttribute('data-label', 'li_sa_cancel')
            ..setAttribute('data-value', alertId.toString())
            ..textContent = cancelButtonText,
        );
      }
      if (reverseButtons && buttons.length > 1) {
        for (final button in buttons.reversed) {
          actions.append(button);
        }
      } else {
        for (final button in buttons) {
          actions.append(button);
        }
      }
      popup.append(actions);
    }

    root.append(popup);
    web.document.body?.append(root);
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
      onConfirmAction: onConfirmAction,
      onCancelAction: onCancelAction,
      onDismissAction: onDismissAction,
      onConfirm: onConfirm,
    )..attach();
  }

  static web.Element _createIcon(SweetAlertType type) {
    final icon = addClassTokens(
      web.HTMLDivElement(),
      <String>['swal2-icon', 'swal2-${_iconName(type)}', 'swal2-icon-show'],
    )
      ..setAttribute('data-label', 'li_sa_icon')
      ..setAttribute('data-value', _iconName(type))
      ..style.display = 'flex';

    switch (type) {
      case SweetAlertType.success:
        icon.append(web.HTMLDivElement()
          ..classList.add('swal2-success-circular-line-left'));
        icon.append(
            web.HTMLSpanElement()..classList.add('swal2-success-line-tip'));
        icon.append(
            web.HTMLSpanElement()..classList.add('swal2-success-line-long'));
        icon.append(web.HTMLDivElement()..classList.add('swal2-success-ring'));
        icon.append(web.HTMLDivElement()..classList.add('swal2-success-fix'));
        icon.append(web.HTMLDivElement()
          ..classList.add('swal2-success-circular-line-right'));
        break;
      case SweetAlertType.error:
        final xMark = web.HTMLSpanElement()..classList.add('swal2-x-mark');
        xMark.append(
          web.HTMLSpanElement()..classList.add('swal2-x-mark-line-left'),
        );
        xMark.append(
          web.HTMLSpanElement()..classList.add('swal2-x-mark-line-right'),
        );
        icon.append(xMark);
        break;
      case SweetAlertType.warning:
        icon.append(web.HTMLDivElement()
          ..classList.add('swal2-icon-content')
          ..textContent = '!');
        break;
      case SweetAlertType.info:
        icon.append(web.HTMLDivElement()
          ..classList.add('swal2-icon-content')
          ..textContent = 'i');
        break;
      case SweetAlertType.question:
        icon.append(web.HTMLDivElement()
          ..classList.add('swal2-icon-content')
          ..textContent = '?');
        break;
    }

    return icon;
  }

  static web.Element _createInput(
    SweetAlertInputType inputType,
    String? inputPlaceholder,
    String? inputValue, {
    Map<String, String>? inputOptions,
    String? inputLabel,
    bool inputChecked = false,
    num? inputMin,
    num? inputMax,
    num? inputStep,
    SweetAlertInputConfig? inputConfig,
  }) {
    switch (inputType) {
      case SweetAlertInputType.select:
        final select = web.HTMLSelectElement()
          ..classList.add('swal2-select')
          ..setAttribute('data-label', 'li_sa_input')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
          ..style.display = 'block';
        final placeholder = inputPlaceholder?.trim();
        if (placeholder != null && placeholder.isNotEmpty) {
          select.append(
            web.HTMLOptionElement()
              ..value = ''
              ..setAttribute('data-label', 'li_sa_input_option')
              ..setAttribute('data-value', '')
              ..textContent = placeholder
              ..disabled = true
              ..selected = (inputValue ?? '').trim().isEmpty,
          );
        }
        for (final entry
            in (inputOptions ?? const <String, String>{}).entries) {
          select.append(
            web.HTMLOptionElement()
              ..value = entry.key
              ..setAttribute('data-label', 'li_sa_input_option')
              ..setAttribute('data-value', entry.key)
              ..textContent = entry.value
              ..selected = entry.key == (inputValue ?? ''),
          );
        }
        _applyInputConfig(select, inputConfig);
        return select;
      case SweetAlertInputType.radio:
        final container = web.HTMLDivElement()
          ..classList.add('swal2-radio')
          ..setAttribute('data-label', 'li_sa_input')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
          ..style.display = 'flex'
          ..style.flexDirection = 'column';
        final resolvedValue = inputValue ??
            ((inputOptions ?? const <String, String>{}).keys.isNotEmpty
                ? (inputOptions ?? const <String, String>{}).keys.first
                : '');
        for (final entry
            in (inputOptions ?? const <String, String>{}).entries) {
          final label = web.HTMLLabelElement()
            ..classList.add('swal2-radio-label')
            ..setAttribute('data-label', 'li_sa_input_radio_label')
            ..setAttribute('data-value', entry.key);
          final input = web.HTMLInputElement()
            ..type = 'radio'
            ..name = 'swal2-radio'
            ..value = entry.key
            ..setAttribute('data-label', 'li_sa_input_radio')
            ..setAttribute('data-value', entry.key)
            ..checked = entry.key == resolvedValue;
          label
            ..append(input)
            ..append(web.HTMLSpanElement()..textContent = entry.value);
          container.append(label);
        }
        _applyInputConfig(container, inputConfig);
        return container;
      case SweetAlertInputType.checkbox:
        final checkbox = web.HTMLInputElement()
          ..type = 'checkbox'
          ..setAttribute('data-label', 'li_sa_input_checkbox')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
          ..checked =
              inputChecked || (inputValue ?? '').toLowerCase() == 'true';
        final label = web.HTMLLabelElement()
          ..classList.add('swal2-checkbox')
          ..setAttribute('data-label', 'li_sa_input')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
          ..style.display = 'flex'
          ..style.alignItems = 'center'
          ..style.gap = '0.5rem';
        label
          ..append(checkbox)
          ..append(web.HTMLSpanElement()
            ..textContent = inputLabel ?? inputPlaceholder ?? '');
        _applyInputConfig(label, inputConfig);
        return label;
      case SweetAlertInputType.range:
        final range = web.HTMLInputElement()
          ..classList.add('swal2-range')
          ..setAttribute('data-label', 'li_sa_input')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
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
        _applyInputConfig(range, inputConfig);
        return range;
      case SweetAlertInputType.textarea:
        final textarea = addClassTokens(
          web.HTMLTextAreaElement(),
          const <String>['swal2-textarea', 'form-control'],
        )
          ..setAttribute('data-label', 'li_sa_input')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
          ..style.display = 'block'
          ..style.width = '100%'
          ..style.boxSizing = 'border-box'
          ..style.minHeight = '7rem'
          ..style.resize = 'vertical'
          ..placeholder = inputPlaceholder ?? ''
          ..value = inputValue ?? ''
          ..rows = inputConfig?.rows ?? 4;
        _applyInputConfig(textarea, inputConfig);
        return textarea;
      case SweetAlertInputType.text:
      case SweetAlertInputType.email:
      case SweetAlertInputType.url:
      case SweetAlertInputType.password:
      case SweetAlertInputType.number:
        final input = web.HTMLInputElement()
          ..classList.add('swal2-input')
          ..setAttribute('data-label', 'li_sa_input')
          ..setAttribute('data-value', _inputAutomationTypeName(inputType))
          ..style.display = 'block'
          ..type = _inputTypeName(inputType)
          ..placeholder = inputPlaceholder ?? ''
          ..value = inputValue ?? ''
          ..autocomplete = inputConfig?.autocomplete ?? 'off';
        _applyInputConfig(input, inputConfig);
        return input;
    }
  }

  static void _applyInputConfig(
    web.Element input,
    SweetAlertInputConfig? inputConfig,
  ) {
    if (inputConfig == null) {
      return;
    }

    addClassTokens(input, _classNames(inputConfig.className));
    for (final entry
        in (inputConfig.style ?? const <String, String>{}).entries) {
      final property = entry.key.trim();
      if (property.isNotEmpty) {
        (input as web.HTMLElement).style.setProperty(property, entry.value);
      }
    }
    for (final entry
        in (inputConfig.attributes ?? const <String, String>{}).entries) {
      final attribute = entry.key.trim();
      if (attribute.isNotEmpty) {
        input.setAttribute(attribute, entry.value);
      }
    }

    if (input.isA<web.HTMLTextAreaElement>()) {
      final textarea = input as web.HTMLTextAreaElement;
      if (inputConfig.rows != null) {
        textarea.rows = inputConfig.rows!;
      }
      if (inputConfig.cols != null) {
        textarea.cols = inputConfig.cols!;
      }
      if (inputConfig.minLength != null) {
        textarea.minLength = inputConfig.minLength!;
      }
      if (inputConfig.maxLength != null) {
        textarea.maxLength = inputConfig.maxLength!;
      }
      return;
    }

    if (input.isA<web.HTMLInputElement>()) {
      final field = input as web.HTMLInputElement;
      if (inputConfig.minLength != null) {
        field.minLength = inputConfig.minLength!;
      }
      if (inputConfig.maxLength != null) {
        field.maxLength = inputConfig.maxLength!;
      }
      if (inputConfig.autocomplete != null) {
        field.autocomplete = inputConfig.autocomplete!;
      }
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

  static String _inputAutomationTypeName(SweetAlertInputType inputType) {
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
        return 'textarea';
      case SweetAlertInputType.select:
        return 'select';
      case SweetAlertInputType.radio:
        return 'radio';
      case SweetAlertInputType.checkbox:
        return 'checkbox';
      case SweetAlertInputType.range:
        return 'range';
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

  static web.Element _createImage(
    String imageUrl, {
    num? width,
    num? height,
    String alt = '',
  }) {
    return web.HTMLImageElement()
      ..src = imageUrl
      ..classList.add('swal2-image')
      ..setAttribute('data-label', 'li_sa_image')
      ..setAttribute('data-value', imageUrl)
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
    final body = web.document.body;
    if (body == null) {
      return;
    }

    if (_activeRoots.isEmpty) {
      removeClassTokens(
        body,
        const <String>['swal2-shown', 'swal2-height-auto', 'swal2-toast-shown'],
      );
      return;
    }

    body.classList.add('swal2-shown');
    final hasToast = _activeRoots.any(
      (root) => root.querySelector('.swal2-toast') != null,
    );
    final hasModal = _activeRoots.any(
      (root) => root.querySelector('.swal2-modal') != null,
    );

    if (hasToast) {
      body.classList.add('swal2-toast-shown');
    } else {
      body.classList.remove('swal2-toast-shown');
    }

    if (hasModal) {
      body.classList.add('swal2-height-auto');
    } else {
      body.classList.remove('swal2-height-auto');
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
    required this.onConfirmAction,
    required this.onCancelAction,
    required this.onDismissAction,
    required this.onConfirm,
  });

  final web.HTMLDivElement root;
  final web.HTMLDivElement popup;
  final web.Element? inputElement;
  final web.HTMLDivElement validationMessage;
  final bool toast;
  final bool allowOutsideClick;
  final bool allowEscapeKey;
  final bool closeOnClick;
  final Duration? timer;
  final web.HTMLDivElement? progressBar;
  final SweetAlertInputValidator? inputValidator;
  final SweetAlertLifecycleCallback? onOpen;
  final SweetAlertLifecycleCallback? onClose;
  final SweetAlertResultCallback<T>? onConfirmAction;
  final SweetAlertResultCallback<T>? onCancelAction;
  final SweetAlertResultCallback<T>? onDismissAction;
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
      _subscriptions.add(cancelButton.onClick.listen((event) async {
        event.preventDefault();
        await cancel();
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
      _subscriptions.add(
        web.EventStreamProvider<web.KeyboardEvent>('keydown')
            .forTarget(web.document)
            .listen((event) async {
          if (event.key == 'Escape') {
            event.preventDefault();
            dismiss(SweetAlertDismissReason.escape);
            return;
          }

          if (inputElement != null &&
              event.key == 'Enter' &&
              event.target == inputElement) {
            event.preventDefault();
            await confirm();
          }
        }),
      );
    }

    if (timer != null) {
      final totalMilliseconds = timer!.inMilliseconds;
      final start = DateTime.now();
      _timer = Timer(timer!, () => dismiss(SweetAlertDismissReason.timer));
      if (progressBar != null && totalMilliseconds > 0) {
        _progressTimer =
            Timer.periodic(const Duration(milliseconds: 30), (timer) {
          final elapsed = DateTime.now().difference(start).inMilliseconds;
          final remaining =
              (totalMilliseconds - elapsed).clamp(0, totalMilliseconds);
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
      if ((defaultFocus?.isA<web.HTMLElement>() ?? false)) {
        (defaultFocus as web.HTMLElement).focus();
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
            ..textContent = validation
            ..style.display = 'flex';
          return;
        }
      }
      validationMessage
        ..textContent = ''
        ..style.display = 'none';
    }

    final value = await onConfirm(this);
    if (_closed) {
      return;
    }
    final result = SweetAlertResult<T>.confirmed(value);
    if (onConfirmAction != null) {
      await onConfirmAction!(result);
      if (_closed) {
        return;
      }
    }
    _close(result);
  }

  Future<void> cancel() async {
    if (_closed) {
      return;
    }

    final result = SweetAlertResult<T>.dismissed(
      SweetAlertDismissReason.cancel,
    );
    if (onCancelAction != null) {
      await onCancelAction!(result);
      if (_closed) {
        return;
      }
    }
    _close(result, reason: SweetAlertDismissReason.cancel);
  }

  String? readInputValue() {
    final element = inputElement;
    if ((element?.isA<web.HTMLInputElement>() ?? false)) {
      final input = element as web.HTMLInputElement;
      if (input.type == 'checkbox') {
        return input.checked == true ? 'true' : 'false';
      }
      return input.value;
    }
    if ((element?.isA<web.HTMLSelectElement>() ?? false)) {
      return (element as web.HTMLSelectElement).value;
    }
    if ((element?.isA<web.HTMLTextAreaElement>() ?? false)) {
      return (element as web.HTMLTextAreaElement).value;
    }
    if ((element?.isA<web.HTMLLabelElement>() ?? false)) {
      final checkbox = element!.querySelector('input[type="checkbox"]')
          as web.HTMLInputElement?;
      if (checkbox != null) {
        return checkbox.checked == true ? 'true' : 'false';
      }
    }
    if ((element?.isA<web.HTMLDivElement>() ?? false)) {
      final selected = element!.querySelector('input[type="radio"]:checked')
          as web.HTMLInputElement?;
      if (selected != null) {
        return selected.value;
      }
    }
    return null;
  }

  web.HTMLElement? _resolveInputFocusTarget() {
    final element = inputElement;
    if ((element?.isA<web.HTMLInputElement>() ?? false) ||
        (element?.isA<web.HTMLSelectElement>() ?? false) ||
        (element?.isA<web.HTMLTextAreaElement>() ?? false)) {
      return element as web.HTMLElement;
    }

    final candidate = element?.querySelector('input, select, textarea');
    if ((candidate?.isA<web.HTMLElement>() ?? false)) {
      return candidate as web.HTMLElement;
    }

    return null;
  }

  void dismiss(SweetAlertDismissReason reason) {
    if (_closed) {
      return;
    }

    final result = SweetAlertResult<T>.dismissed(reason);
    final dismissalCallback = onDismissAction;
    if (dismissalCallback != null) {
      Future.sync(() => dismissalCallback(result)).then((_) {
        if (_closed) {
          return;
        }
        _close(result, reason: reason);
      });
      return;
    }

    _close(result, reason: reason);
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
