// ignore_for_file: constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

enum LiDialogColor { DANGER, PRIMARY, SUCCESS, WARNING, INFO, PINK }

enum LiSimpleDialogInputType { text, textarea }

typedef LiSimpleDialogInputValidator = FutureOr<String?> Function(String value);

class LiSimpleDialogInputConfig {
  const LiSimpleDialogInputConfig({
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

class LiSimpleDialogComponent {
  static const int defaultZIndex = 2000;

  static String getColor(LiDialogColor dialogColor) {
    var headerColor = '';
    switch (dialogColor) {
      case LiDialogColor.PRIMARY:
        headerColor = 'primary';
        break;
      case LiDialogColor.SUCCESS:
        headerColor = 'success';
        break;
      case LiDialogColor.DANGER:
        headerColor = 'danger';
        break;
      case LiDialogColor.WARNING:
        headerColor = 'warning';
        break;
      case LiDialogColor.INFO:
        headerColor = 'info';
        break;
      case LiDialogColor.PINK:
        headerColor = 'pink';
        break;
    }
    return headerColor;
  }

  static int _backdropZIndex(int zIndex) => zIndex <= 0 ? 0 : zIndex - 1;

  static void showFullScreenDialog(String content,
      {int zIndex = defaultZIndex}) {
    var template = '''
    <div style="width: 100%;height: 100%;display: block; 
    position: fixed;top: 0;left: 0;z-index:$zIndex;background: rgba(255, 255, 255, 0.5);">
    $content
    </div>
     ''';
    // ignore: omit_local_variable_types
    html.DivElement root = html.DivElement();
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
  }

  static void showFullScreenAlert(String message,
      {String backgroundColor = '#de589d', int zIndex = defaultZIndex}) {
    var template = '''
    <div style="width: 100%;height: 100%;display: block; 
        position: fixed;top: 0;left: 0;z-index:$zIndex;background: rgba(255, 255, 255, 0.5);">
        <div style="display:flex;align-items:center;justify-content:center;width: 100%;height: 100%;">
            <h1 style="width:50%;height:77px;text-align:center;background:$backgroundColor;color:#fff;padding:20px;">$message</h1>
        </div>
    </div>
     ''';
    html.document.querySelector('.FullScreenAlert')?.remove();
    // ignore: omit_local_variable_types
    html.DivElement root = html.DivElement();
    root.classes.add('FullScreenAlert');
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
  }

  static void showAlert(
    String message, {
    String? subMessage,
    String title = 'Alerta',
    String detailLabel = 'Detalhe',
    LiDialogColor dialogColor = LiDialogColor.PRIMARY,
    Function? okAction,
    int zIndex = defaultZIndex,
  }) {
    final backdropZIndex = _backdropZIndex(zIndex);
    final template = '''
      <div class="modal fade show li-simple-dialog__modal" tabindex="-1" role="dialog" style="padding-left: 0px; display: block;overflow: auto;z-index:$zIndex;" aria-modal="true" role="dialog" data-li-simple-dialog="true">
        <div class="modal-dialog">
            <div class="modal-content">                
                <div class="modal-header bg-${getColor(dialogColor)} text-white border-0">
                  <h6 class="modal-title">$title</h6>
                  <!--<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>-->
							  </div>
                <div class="modal-body">
                    $message                   
                </div>
                <div class="modal-footer">                    
                    <button type="button" class="BtnOk btn btn-primary" data-bs-dismiss="modal">OK</button>
                </div>
            </div>
        </div>
    </div>
        <div class="modal-backdrop fade show li-simple-dialog__backdrop" style="z-index:$backdropZIndex;"></div>
    ''';
    var root = html.DivElement();
    root.classes.add('li-simple-dialog-root');
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
    if (subMessage != null) {
      var btnEle = html.DivElement();
      btnEle.attributes['style'] =
          'padding-top:15px;padding-bottom:5px;cursor: pointer;';
      var t =
          '<label class="text-muted" style="cursor: pointer;">$detailLabel  </label> <a class="list-icons-item dropdown-toggle" data-toggle="dropdown" ></a>';
      // ignore: unsafe_html
      btnEle.setInnerHtml(t, treeSanitizer: html.NodeTreeSanitizer.trusted);
      root.querySelector('.modal-body')?.append(btnEle);

      var container = html.DivElement();
      container.classes.add('modal-detail');
      root.querySelector('.modal-body')?.append(container);

      btnEle.onClick.listen((e) {
        var el = e.target as html.HtmlElement;
        if (el
                .closest('.modal-body')
                ?.querySelector('.modal-detail')
                ?.style
                .display ==
            'none') {
          el
              .closest('.modal-body')
              ?.querySelector('.modal-detail')
              ?.style
              .display = 'block';
        } else {
          el
              .closest('.modal-body')
              ?.querySelector('.modal-detail')
              ?.style
              .display = 'none';
        }
      });

      container.style.overflow = 'hidden';
      container.style.display = 'none';
      container.innerHtml = subMessage;
    }
    root.querySelector('button.BtnOk')?.onClick.listen((e) {
      if (okAction != null) {
        okAction();
      }
      root.remove();
    });

    Future.delayed(Duration(milliseconds: 40), () {
      // print('showAlert focus');
      root.querySelector('.modal')?.focus();
    });
  }

  static Future<bool> showConfirm(String message,
      {String? subMessage,
      String title = 'Confirmar',
      String cancelButtonText = 'Cancelar',
      Function? cancelAction,
      String confirmButtonText = 'Sim',
      Function? confirmAction,
      LiDialogColor dialogColor = LiDialogColor.DANGER,
      int zIndex = defaultZIndex}) {
    // var uuid = Uuid();
    // final idModal = uuid.v1();
    final comp = Completer<bool>();
    final backdropZIndex = _backdropZIndex(zIndex);
    final template = '''
      <div class="modal fade show li-simple-dialog__modal" tabindex="-1" role="dialog" style="padding-left: 0px; display: block;overflow: auto;z-index:$zIndex;" aria-modal="true" role="dialog" data-li-simple-dialog="true">
        <div class="modal-dialog">
            <div class="modal-content">                
                <div class="modal-header bg-${getColor(dialogColor)} text-white border-0">
                  <h6 class="modal-title">$title</h6>
                  <!--<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>-->
							  </div>
                <div class="modal-body">
                    $message
                    ${subMessage != null ? '<div class="mt-2 text-muted">$subMessage</div>' : ''}                   
                </div>
                <div class="modal-footer"> 
                  <button data-bb-handler="cancel" type="button" class="BtnCancel btn btn-primary">$cancelButtonText</button>
                  <button data-bb-handler="confirm" type="button" class="BtnOk btn btn-danger">$confirmButtonText</button>
               </div>
            </div>
        </div>
    </div>
        <div class="modal-backdrop fade show li-simple-dialog__backdrop" style="z-index:$backdropZIndex;"></div>
    ''';
    final root = html.DivElement();
    root.classes.add('li-simple-dialog-root');
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);
    root.querySelector('button.BtnCancel')?.onClick.listen((e) {
      if (cancelAction != null) {
        cancelAction();
      }
      root.remove();
      comp.complete(false);
    });
    root.querySelector('button.BtnOk')?.onClick.listen((e) {
      if (confirmAction != null) {
        confirmAction();
      }
      root.remove();
      comp.complete(true);
    });

    Future.delayed(Duration(milliseconds: 40), () {
      root.querySelector('.modal')?.focus();
    });

    return comp.future;
  }

  static Future<String?> showPrompt(
    String message, {
    String? subMessage,
    String title = 'Solicitar informação',
    String cancelButtonText = 'Cancelar',
    Function? cancelAction,
    String confirmButtonText = 'Confirmar',
    Function(String value)? confirmAction,
    LiDialogColor dialogColor = LiDialogColor.PRIMARY,
    LiSimpleDialogInputType inputType = LiSimpleDialogInputType.text,
    String? inputLabel,
    String? inputPlaceholder,
    String inputValue = '',
    LiSimpleDialogInputConfig? inputConfig,
    LiSimpleDialogInputValidator? inputValidator,
    int zIndex = defaultZIndex,
  }) {
    final comp = Completer<String?>();
    final backdropZIndex = _backdropZIndex(zIndex);
    final inputId =
        'li-simple-dialog-input-${DateTime.now().microsecondsSinceEpoch}';
    final escapedTitle = _escapeHtml(title);
    final escapedMessage = _escapeHtml(message);
    final escapedSubMessage =
        subMessage == null ? null : _escapeHtml(subMessage);
    final escapedInputLabel =
        inputLabel == null ? null : _escapeHtml(inputLabel);
    final escapedCancelButtonText = _escapeHtml(cancelButtonText);
    final escapedConfirmButtonText = _escapeHtml(confirmButtonText);
    final template = '''
      <div class="modal fade show li-simple-dialog__modal" tabindex="-1" role="dialog" style="padding-left: 0px; display: block;overflow: auto;z-index:$zIndex;" aria-modal="true" role="dialog" data-li-simple-dialog="true">
        <div class="modal-dialog">
            <div class="modal-content">                
                <div class="modal-header bg-${getColor(dialogColor)} text-white border-0">
                  <h6 class="modal-title">$escapedTitle</h6>
							  </div>
                <div class="modal-body">
                    <div class="mb-3">$escapedMessage</div>
                    ${escapedSubMessage != null ? '<div class="mb-3 text-muted">$escapedSubMessage</div>' : ''}
                    ${escapedInputLabel != null && escapedInputLabel.trim().isNotEmpty ? '<label class="form-label" for="$inputId">$escapedInputLabel</label>' : ''}
                    ${_promptInputTemplate(inputType, inputId)}
                    <div class="invalid-feedback li-simple-dialog__validation" style="display:none;"></div>
                </div>
                <div class="modal-footer"> 
                  <button data-bb-handler="cancel" type="button" class="BtnCancel btn btn-light">$escapedCancelButtonText</button>
                  <button data-bb-handler="confirm" type="button" class="BtnOk btn btn-primary">$escapedConfirmButtonText</button>
               </div>
            </div>
        </div>
    </div>
        <div class="modal-backdrop fade show li-simple-dialog__backdrop" style="z-index:$backdropZIndex;"></div>
    ''';
    final root = html.DivElement();
    root.classes.add('li-simple-dialog-root');
    html.document.querySelector('body')?.append(root);
    // ignore: unsafe_html
    root.setInnerHtml(template, treeSanitizer: html.NodeTreeSanitizer.trusted);

    final input = root.querySelector('#$inputId') as html.HtmlElement?;
    if (input is html.InputElement) {
      input
        ..placeholder = inputPlaceholder ?? ''
        ..value = inputValue
        ..autocomplete = inputConfig?.autocomplete ?? 'off';
    } else if (input is html.TextAreaElement) {
      input
        ..placeholder = inputPlaceholder ?? ''
        ..value = inputValue
        ..rows = inputConfig?.rows ?? 4;
    }
    if (input != null) {
      _applyInputConfig(input, inputConfig);
    }

    Future<void> confirm() async {
      final value = _readPromptValue(input);
      final validationMessage = root
          .querySelector('.li-simple-dialog__validation') as html.DivElement?;

      if (inputValidator != null) {
        final validation = await inputValidator(value);
        if (validation != null && validation.trim().isNotEmpty) {
          if (validationMessage != null) {
            validationMessage
              ..text = validation
              ..style.display = 'block';
          }
          input?.classes.add('is-invalid');
          return;
        }
      }

      if (validationMessage != null) {
        validationMessage
          ..text = ''
          ..style.display = 'none';
      }
      input?.classes.remove('is-invalid');
      confirmAction?.call(value);
      root.remove();
      if (!comp.isCompleted) {
        comp.complete(value);
      }
    }

    root.querySelector('button.BtnCancel')?.onClick.listen((e) {
      cancelAction?.call();
      root.remove();
      if (!comp.isCompleted) {
        comp.complete(null);
      }
    });
    root.querySelector('button.BtnOk')?.onClick.listen((e) {
      confirm();
    });
    input?.onKeyDown.listen((event) {
      final isEnter = event.key == 'Enter' || event.keyCode == 13;
      if (!isEnter) {
        return;
      }
      if (input is html.TextAreaElement && !event.ctrlKey && !event.metaKey) {
        return;
      }
      event.preventDefault();
      confirm();
    });

    Future.delayed(Duration(milliseconds: 40), () {
      input?.focus();
    });

    return comp.future;
  }

  static String _promptInputTemplate(
    LiSimpleDialogInputType inputType,
    String inputId,
  ) {
    switch (inputType) {
      case LiSimpleDialogInputType.textarea:
        return '<textarea id="$inputId" class="form-control li-simple-dialog__input li-simple-dialog__textarea" style="min-height:7rem;resize:vertical;"></textarea>';
      case LiSimpleDialogInputType.text:
        return '<input id="$inputId" type="text" class="form-control li-simple-dialog__input">';
    }
  }

  static String _readPromptValue(html.HtmlElement? input) {
    if (input is html.InputElement) {
      return input.value ?? '';
    }
    if (input is html.TextAreaElement) {
      return input.value ?? '';
    }
    return '';
  }

  static String _escapeHtml(String value) => const HtmlEscape().convert(value);

  static void _applyInputConfig(
    html.HtmlElement input,
    LiSimpleDialogInputConfig? inputConfig,
  ) {
    if (inputConfig == null) {
      return;
    }

    final className = inputConfig.className?.trim();
    if (className != null && className.isNotEmpty) {
      input.classes.addAll(className.split(RegExp(r'\s+')));
    }
    for (final entry
        in (inputConfig.style ?? const <String, String>{}).entries) {
      final property = entry.key.trim();
      if (property.isNotEmpty) {
        input.style.setProperty(property, entry.value);
      }
    }
    for (final entry
        in (inputConfig.attributes ?? const <String, String>{}).entries) {
      final attribute = entry.key.trim();
      if (attribute.isNotEmpty) {
        input.attributes[attribute] = entry.value;
      }
    }

    if (input is html.TextAreaElement) {
      if (inputConfig.rows != null) {
        input.rows = inputConfig.rows!;
      }
      if (inputConfig.cols != null) {
        input.cols = inputConfig.cols!;
      }
      if (inputConfig.minLength != null) {
        input.minLength = inputConfig.minLength!;
      }
      if (inputConfig.maxLength != null) {
        input.maxLength = inputConfig.maxLength!;
      }
      return;
    }

    if (input is html.InputElement) {
      if (inputConfig.minLength != null) {
        input.minLength = inputConfig.minLength!;
      }
      if (inputConfig.maxLength != null) {
        input.maxLength = inputConfig.maxLength!;
      }
      if (inputConfig.autocomplete != null) {
        input.autocomplete = inputConfig.autocomplete!;
      }
    }
  }
}
