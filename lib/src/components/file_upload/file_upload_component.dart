import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import '../../directives/li_form_directive.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_rule_context.dart';
import '../../validation/li_validation.dart';
import '../../validation/li_validation_issue.dart';
import 'file_drop_directive.dart';
import 'file_select_directive.dart';
import 'file_type.dart';

class LiFileUploadPreviewItem {
  const LiFileUploadPreviewItem({
    required this.file,
    required this.kind,
    required this.kindLabel,
    required this.sizeLabel,
    this.errorText = '',
  });

  final html.File file;
  final String kind;
  final String kindLabel;
  final String sizeLabel;
  final String errorText;

  bool get hasError => errorText.trim().isNotEmpty;
}

@Component(
  selector: 'li-file-upload',
  templateUrl: 'file_upload_component.html',
  styleUrls: ['file_upload_component.css'],
  directives: [coreDirectives, LiFileDropDirective, LiFileSelectDirective],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiFileUploadComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiFileUploadComponent
    implements ControlValueAccessor<List<html.File>?>, AfterChanges, OnDestroy {
  LiFileUploadComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();
  StreamSubscription<bool>? _formSubmissionSubscription;

  List<html.File> _files = <html.File>[];

  @Input()
  bool multiple = true;

  @Input()
  bool disabled = false;

  @Input()
  bool showPreview = true;

  @Input()
  int maxFiles = 0;

  @Input()
  String accept = '';

  @Input()
  String title = '';

  @Input()
  String subtitle = '';

  @Input()
  String browseLabel = '';

  @Input()
  String helperText = '';

  @Input()
  List<LiRule> liRules = const <LiRule>[];

  @Input()
  Map<String, String> liMessages = const <String, String>{};

  @Input()
  String liValidationMode = 'submittedOrTouchedOrDirty';

  @Input()
  bool validateOnInput = true;

  @Input()
  String locale = 'pt_BR';

  @Input()
  bool invalid = false;

  @Input()
  bool valid = false;

  @Input()
  bool dataInvalid = false;

  @Input()
  bool required = false;

  @Input()
  String errorText = '';

  @Input()
  String feedbackClass = '';

  @Input()
  String describedBy = '';

  @Input()
  int maxSize = 0;

  @Input()
  List<String> allowedTypes = const <String>[];

  @Input()
  String dropzoneClass = '';

  @Input()
  String listClass = '';

  @Output()
  Stream<List<html.File>> get filesChange => _filesChangeController.stream;

  @ViewChild('fileInput')
  html.InputElement? fileInput;

  ChangeFunction<List<html.File>?> _onChange =
      (List<html.File>? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};
  bool _touched = false;
  bool _dirty = false;
  bool _formSubmitted = false;
  LiValidationIssue? _autoValidationIssue;
  List<LiRule> _effectiveRules = const <LiRule>[];
  Map<String, String> _effectiveMessages = const <String, String>{};

  bool isDragOver = false;
  List<LiFileUploadPreviewItem> previewItems = const <LiFileUploadPreviewItem>[];
  Map<String, String> fileErrors = const <String, String>{};

  bool get hasFiles => _files.isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get hasFileErrors => fileErrors.isNotEmpty;

  String get effectiveErrorText {
    final externalMessage = errorText.trim();
    if (externalMessage.isNotEmpty) {
      return externalMessage;
    }

    return _autoValidationIssue?.message ?? '';
  }

  bool get showErrorFeedback =>
      effectiveInvalid && effectiveErrorText.trim().isNotEmpty;

  bool get effectiveAutoInvalid =>
      _shouldShowValidation && _autoValidationIssue != null;

  bool get effectiveInvalid =>
      invalid ||
      dataInvalid ||
      hasFileErrors ||
      effectiveAutoInvalid;

  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          (_shouldShowValidation &&
              (_files.isNotEmpty || _effectiveRules.isNotEmpty) &&
              !hasFileErrors &&
              _autoValidationIssue == null));

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String get resolvedAccept => accept.trim();

  List<String> get resolvedAllowedTypes {
    if (allowedTypes.isNotEmpty) {
      return allowedTypes
          .map((type) => type.trim().toLowerCase())
          .where((type) => type.isNotEmpty)
          .toList(growable: false);
    }

    return accept
        .split(',')
        .map((type) => type.trim().toLowerCase())
        .where((type) => type.isNotEmpty)
        .toList(growable: false);
  }

  String get resolvedTitle => title.trim().isNotEmpty
      ? title
      : (isEnglishLocale ? 'Drop files here' : 'Arraste arquivos aqui');

  String get resolvedSubtitle => subtitle.trim().isNotEmpty
      ? subtitle
      : (isEnglishLocale
          ? 'Or choose files from your device'
          : 'Ou selecione arquivos do seu dispositivo');

  String get resolvedBrowseLabel => browseLabel.trim().isNotEmpty
      ? browseLabel
      : (isEnglishLocale ? 'Browse files' : 'Selecionar arquivos');

  String get selectedFilesTitle =>
      isEnglishLocale ? 'Selected files' : 'Arquivos selecionados';

  String get clearLabel => isEnglishLocale ? 'Clear' : 'Limpar';

  String get browseAriaLabel =>
      isEnglishLocale ? 'Choose files' : 'Selecionar arquivos';

  String get resolvedDropzoneClass => _joinClasses(<String>[
        'li-file-upload__dropzone',
        isDragOver ? 'is-over' : '',
        disabled ? 'is-disabled' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        dropzoneClass,
      ]);

  String get resolvedListClass => _joinClasses(<String>[
        'list-group',
        listClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  bool get _shouldShowValidation => liShouldShowValidation(
        mode: liValidationMode,
        touched: _touched,
        dirty: _dirty,
        submitted: _formSubmitted,
      );

  @override
  void ngAfterChanges() {
    _formSubmitted = _formDirective?.submitted ?? false;
    _formSubmissionSubscription ??=
        _formDirective?.submissionStateChanges.listen((submitted) {
      _formSubmitted = submitted;
      _runAutoValidation();
      _markForCheck();
    });

    _effectiveRules = List<LiRule>.unmodifiable(<LiRule>[
      if (required) const LiRequiredRule(),
      ...liRules,
    ]);
    _effectiveMessages = Map<String, String>.unmodifiable(<String, String>{
      ...liMessages,
    });
    _runAutoValidation();
    _markForCheck();
  }

  @HostBinding('class.d-block')
  bool get hostClass => true;

  void onDropzoneKeyDown(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (disabled) {
      return;
    }

    if (event.key == 'Enter' || event.key == ' ') {
      event.preventDefault();
      openPicker();
    }
  }

  void openPicker() {
    if (disabled) {
      return;
    }
    _markTouched();
    fileInput?.click();
  }

  void onFileOver(bool value) {
    isDragOver = value && !disabled;
    _markForCheck();
  }

  void onFilesSelected(List<html.File> files) {
    if (disabled) {
      return;
    }
    _consumeFiles(files);
  }

  void removeAt(int index) {
    if (disabled || index < 0 || index >= _files.length) {
      return;
    }
    _dirty = true;
    final nextFiles = List<html.File>.from(_files)..removeAt(index);
    _setFiles(nextFiles, emitToForm: true);
  }

  void clear() {
    _dirty = true;
    _setFiles(const <html.File>[], emitToForm: true);
  }

  @override
  void registerOnChange(ChangeFunction<List<html.File>?> fn) {
    _onChange = fn;
  }

  @override
  void registerOnTouched(TouchFunction fn) {
    _onTouched = fn;
  }

  @override
  void writeValue(List<html.File>? value) {
    _setFiles(value ?? const <html.File>[], emitToForm: false);
  }

  @override
  void onDisabledChanged(bool isDisabled) {
    disabled = isDisabled;
    _markForCheck();
  }

  Object trackByPreview(int index, dynamic item) {
    final preview = item as LiFileUploadPreviewItem;
    return '${preview.file.name}-${preview.file.size}-${preview.file.type}';
  }

  String kindClass(LiFileUploadPreviewItem item) {
    return _joinClasses(<String>[
      'li-file-upload__kind',
      'li-file-upload__kind-${item.kind}',
    ]);
  }

  void _consumeFiles(List<html.File> incoming) {
    _markTouched();
    if (incoming.isEmpty) {
      return;
    }

    _dirty = true;

    final normalizedIncoming = multiple
        ? _mergeFiles(_files, incoming)
        : <html.File>[incoming.first];

    _setFiles(
      _applyMaxFiles(normalizedIncoming),
      emitToForm: true,
      validationErrors: _collectFileErrors(normalizedIncoming),
    );
    if (fileInput != null) {
      fileInput!.value = '';
    }
  }

  List<html.File> _mergeFiles(
    List<html.File> current,
    List<html.File> incoming,
  ) {
    final next = List<html.File>.from(current);
    for (final file in incoming) {
      final alreadyExists = next.any((existing) =>
          existing.name == file.name &&
          existing.size == file.size &&
          existing.type == file.type);
      if (!alreadyExists) {
        next.add(file);
      }
    }
    return next;
  }

  List<html.File> _applyMaxFiles(List<html.File> files) {
    if (maxFiles <= 0 || files.length <= maxFiles) {
      return files;
    }
    return files.take(maxFiles).toList(growable: false);
  }

  void _setFiles(
    List<html.File> value, {
    required bool emitToForm,
    Map<String, String>? validationErrors,
  }) {
    final resolvedErrors = validationErrors ?? _collectFileErrors(value);
    _files = List<html.File>.from(value);
    fileErrors = Map<String, String>.unmodifiable(resolvedErrors);
    previewItems = _files.map((file) {
      final kind = LiFileType.getMimeClass(file);
      final fileKey = _fileKey(file);
      return LiFileUploadPreviewItem(
        file: file,
        kind: kind,
        kindLabel: _kindLabel(kind),
        sizeLabel: _formatBytes(file.size),
        errorText: resolvedErrors[fileKey] ?? '',
      );
    }).toList(growable: false);

    if (emitToForm) {
      final payload = List<html.File>.unmodifiable(_files);
      _filesChangeController.add(payload);
      _onChange(payload, rawValue: _files.length.toString());
      _markTouched();
    }
    _runAutoValidation();
    _markForCheck();
  }

  Map<String, String> _collectFileErrors(List<html.File> files) {
    final errors = <String, String>{};
    for (final file in files) {
      final error = _validateFile(file);
      if (error != null) {
        errors[_fileKey(file)] = error;
      }
    }
    return errors;
  }

  String? _validateFile(html.File file) {
    if (maxSize > 0 && file.size > maxSize) {
      return isEnglishLocale
          ? 'File exceeds the maximum size of ${_formatBytes(maxSize)}.'
          : 'Arquivo excede o tamanho maximo de ${_formatBytes(maxSize)}.';
    }

    final allowed = resolvedAllowedTypes;
    if (allowed.isEmpty) {
      return null;
    }

    final mime = file.type.toLowerCase();
    final extension = _fileExtension(file.name);
    final extensionWithDot =
        extension.isEmpty ? '' : '.${extension.toLowerCase()}';
    final mimeClass = LiFileType.getMimeClass(file).toLowerCase();

    final isAllowed = allowed.any((type) {
      if (type == mimeClass) {
        return true;
      }
      if (type.startsWith('.')) {
        return type == extensionWithDot;
      }
      if (type.endsWith('/*')) {
        final prefix = type.substring(0, type.length - 1);
        return mime.startsWith(prefix);
      }
      return type == mime || type == extension;
    });

    if (isAllowed) {
      return null;
    }

    return isEnglishLocale
        ? 'File type not allowed.'
        : 'Tipo de arquivo nao permitido.';
  }

  String _fileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex < 0 || lastDotIndex == fileName.length - 1) {
      return '';
    }
    return fileName.substring(lastDotIndex + 1);
  }

  String _fileKey(html.File file) => '${file.name}-${file.size}-${file.type}';

  String _kindLabel(String kind) {
    switch (kind) {
      case 'image':
        return 'IMG';
      case 'video':
        return 'VID';
      case 'audio':
        return 'AUD';
      case 'pdf':
        return 'PDF';
      case 'compress':
        return 'ZIP';
      case 'doc':
        return 'DOC';
      case 'xls':
        return 'XLS';
      case 'ppt':
        return 'PPT';
      default:
        return 'FILE';
    }
  }

  String _formatBytes(num bytes) {
    const units = <String>['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex += 1;
    }
    final precision = value >= 100 || unitIndex == 0 ? 0 : 1;
    return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
  }

  String _joinClasses(List<String> values) {
    return values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  void _markForCheck() {
    _changeDetectorRef.markForCheck();
  }

  void _markTouched() {
    if (_touched) {
      _onTouched();
      if (_shouldShowValidation || _autoValidationIssue != null) {
        _runAutoValidation();
      }
      return;
    }
    _touched = true;
    _onTouched();
    _runAutoValidation();
  }

  void _runAutoValidation() {
    if (_effectiveRules.isEmpty) {
      _autoValidationIssue = null;
      return;
    }

    _autoValidationIssue = liValidateValue(
      value: _files,
      rules: _effectiveRules,
      context: LiRuleContext(
        fieldName: resolvedTitle,
        messages: _effectiveMessages,
        locale: locale,
      ),
    );
  }

  @override
  void ngOnDestroy() {
    _formSubmissionSubscription?.cancel();
    _filesChangeController.close();
  }
}
