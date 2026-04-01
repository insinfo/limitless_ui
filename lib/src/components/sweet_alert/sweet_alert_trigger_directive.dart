import 'dart:async';

import 'package:ngdart/angular.dart';

import 'sweet_alert.dart';
import 'sweet_alert_service.dart';

const liSweetAlertDirectives = <Object>[
  LiSweetAlertDirective,
];

@Directive(selector: '[liSweetAlert]')
class LiSweetAlertDirective implements OnDestroy {
  LiSweetAlertDirective(this._sweetAlertService);

  final SweetAlertService _sweetAlertService;
  final StreamController<Object> _resultController =
      StreamController<Object>.broadcast();

  @Input('liSweetAlert')
  String message = '';

  @Input('liSweetAlertMode')
  String mode = 'show';

  @Input('liSweetAlertTitle')
  String title = '';

  @Input('liSweetAlertHtml')
  String htmlContent = '';

  @Input('liSweetAlertFooter')
  String footer = '';

  @Input('liSweetAlertType')
  String type = 'info';

  @Input('liSweetAlertPosition')
  String position = 'topEnd';

  @Input('liSweetAlertInputType')
  String inputType = 'text';

  @Input('liSweetAlertPromptPlaceholder')
  String promptPlaceholder = '';

  @Input('liSweetAlertPromptValue')
  String promptValue = '';

  @Input('liSweetAlertConfirmText')
  String confirmText = 'OK';

  @Input('liSweetAlertCancelText')
  String cancelText = 'Cancel';

  @Input('liSweetAlertAllowOutsideClick')
  bool allowOutsideClick = true;

  @Input('liSweetAlertAllowEscapeKey')
  bool allowEscapeKey = true;

  @Input('liSweetAlertShowCloseButton')
  bool showCloseButton = false;

  @Input('liSweetAlertBackdrop')
  bool backdrop = true;

  @Input('liSweetAlertAnimation')
  bool animation = true;

  @Input('liSweetAlertReverseButtons')
  bool reverseButtons = false;

  @Input('liSweetAlertTimerMs')
  int? timerMs;

  @Input('liSweetAlertTimerProgressBar')
  bool timerProgressBar = true;

  @Input('liSweetAlertCloseOnClick')
  bool closeOnClick = true;

  @Input('liSweetAlertContainerClass')
  String containerClass = '';

  @Input('liSweetAlertPopupClass')
  String popupClass = '';

  @Input('liSweetAlertWidth')
  String width = '';

  @Input('liSweetAlertPadding')
  String padding = '';

  @Input('liSweetAlertBackground')
  String background = '';

  @Input('liSweetAlertConfirmButtonClass')
  String confirmButtonClass = '';

  @Input('liSweetAlertCancelButtonClass')
  String cancelButtonClass = '';

  @Output('liSweetAlertResult')
  Stream<Object> get resultStream => _resultController.stream;

  @HostListener('click', ['\$event'])
  Future<void> handleClick(dynamic event) async {
    event?.preventDefault();

    switch (_normalizedMode) {
      case 'confirm':
        _resultController.add(
          await _sweetAlertService.confirm(
            title: _normalizedText(title),
            message: _normalizedText(message),
            htmlContent: _normalizedText(htmlContent),
            footer: _normalizedText(footer),
            type: _resolvedType,
            position: _resolvedPosition,
            confirmButtonText: confirmText,
            cancelButtonText: cancelText,
            allowOutsideClick: allowOutsideClick,
            allowEscapeKey: allowEscapeKey,
            showCloseButton: showCloseButton,
            backdrop: backdrop,
            animation: animation,
            reverseButtons: reverseButtons,
            width: _normalizedText(width),
            padding: _normalizedText(padding),
            background: _normalizedText(background),
            containerClass: _normalizedText(containerClass),
            popupClass: _normalizedText(popupClass),
            confirmButtonClass: _normalizedText(confirmButtonClass),
            cancelButtonClass: _normalizedText(cancelButtonClass),
          ),
        );
        return;
      case 'prompt':
        _resultController.add(
          await _sweetAlertService.prompt(
            title: _normalizedText(title),
            message: _normalizedText(message),
            htmlContent: _normalizedText(htmlContent),
            footer: _normalizedText(footer),
            type: _resolvedType,
            inputType: _resolvedInputType,
            inputPlaceholder: _normalizedText(promptPlaceholder),
            inputValue: _normalizedText(promptValue),
            confirmButtonText: confirmText,
            cancelButtonText: cancelText,
            position: _resolvedPosition,
            allowOutsideClick: allowOutsideClick,
            allowEscapeKey: allowEscapeKey,
            showCloseButton: showCloseButton,
            backdrop: backdrop,
            animation: animation,
            reverseButtons: reverseButtons,
            width: _normalizedText(width),
            padding: _normalizedText(padding),
            background: _normalizedText(background),
            containerClass: _normalizedText(containerClass),
            popupClass: _normalizedText(popupClass),
            confirmButtonClass: _normalizedText(confirmButtonClass),
            cancelButtonClass: _normalizedText(cancelButtonClass),
          ),
        );
        return;
      case 'toast':
        final controller = _sweetAlertService.toast(
          _normalizedText(message) ?? '',
          title: _normalizedText(title),
          type: _resolvedType,
          position: _resolvedPosition,
          timer: timerMs == null
              ? const Duration(seconds: 3)
              : Duration(milliseconds: timerMs!),
          timerProgressBar: timerProgressBar,
          closeOnClick: closeOnClick,
          containerClass: _normalizedText(containerClass),
          popupClass: _normalizedText(popupClass),
        );
        final reason = await controller.closed;
        _resultController.add(SweetAlertResult<Object?>.dismissed(reason));
        return;
      case 'show':
      default:
        _resultController.add(
          await _sweetAlertService.show(
            title: _normalizedText(title),
            message: _normalizedText(message),
            htmlContent: _normalizedText(htmlContent),
            footer: _normalizedText(footer),
            type: _resolvedType,
            position: _resolvedPosition,
            confirmButtonText: confirmText,
            allowOutsideClick: allowOutsideClick,
            allowEscapeKey: allowEscapeKey,
            showCloseButton: showCloseButton,
            backdrop: backdrop,
            animation: animation,
            reverseButtons: reverseButtons,
            timer: timerMs == null ? null : Duration(milliseconds: timerMs!),
            timerProgressBar: timerProgressBar,
            width: _normalizedText(width),
            padding: _normalizedText(padding),
            background: _normalizedText(background),
            containerClass: _normalizedText(containerClass),
            popupClass: _normalizedText(popupClass),
            confirmButtonClass: _normalizedText(confirmButtonClass),
          ),
        );
        return;
    }
  }

  SweetAlertType get _resolvedType {
    switch (type.trim().toLowerCase()) {
      case 'success':
        return SweetAlertType.success;
      case 'error':
      case 'danger':
        return SweetAlertType.error;
      case 'warning':
        return SweetAlertType.warning;
      case 'question':
        return SweetAlertType.question;
      case 'info':
      default:
        return SweetAlertType.info;
    }
  }

  SweetAlertPosition get _resolvedPosition {
    switch (position.trim().toLowerCase()) {
      case 'center':
        return SweetAlertPosition.center;
      case 'centerstart':
      case 'center-start':
      case 'centerleft':
      case 'center-left':
        return SweetAlertPosition.centerStart;
      case 'centerend':
      case 'center-end':
      case 'centerright':
      case 'center-right':
        return SweetAlertPosition.centerEnd;
      case 'top':
        return SweetAlertPosition.top;
      case 'topstart':
      case 'top-start':
        return SweetAlertPosition.topStart;
      case 'bottom':
        return SweetAlertPosition.bottom;
      case 'bottomstart':
      case 'bottom-start':
        return SweetAlertPosition.bottomStart;
      case 'bottomend':
      case 'bottom-end':
        return SweetAlertPosition.bottomEnd;
      case 'topend':
      case 'top-end':
      default:
        return SweetAlertPosition.topEnd;
    }
  }

  SweetAlertInputType get _resolvedInputType {
    switch (inputType.trim().toLowerCase()) {
      case 'email':
        return SweetAlertInputType.email;
      case 'url':
        return SweetAlertInputType.url;
      case 'password':
        return SweetAlertInputType.password;
      case 'number':
        return SweetAlertInputType.number;
      case 'textarea':
        return SweetAlertInputType.textarea;
      case 'select':
        return SweetAlertInputType.select;
      case 'radio':
        return SweetAlertInputType.radio;
      case 'checkbox':
        return SweetAlertInputType.checkbox;
      case 'range':
        return SweetAlertInputType.range;
      case 'text':
      default:
        return SweetAlertInputType.text;
    }
  }

  String get _normalizedMode {
    switch (mode.trim().toLowerCase()) {
      case 'confirm':
      case 'prompt':
      case 'toast':
        return mode.trim().toLowerCase();
      case 'show':
      default:
        return 'show';
    }
  }

  String? _normalizedText(String? value) {
    final normalized = value?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  @override
  void ngOnDestroy() {
    _resultController.close();
  }
}