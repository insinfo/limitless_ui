// ignore_for_file: implementation_imports

import 'dart:async';
import 'dart:html' as html;
import 'dart:math' as math;

import 'package:ngdart/angular.dart';
import 'package:ngdart/src/security/dom_sanitization_service.dart'
    show DomSanitizationService, SafeResourceUrl, SafeUrl;
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import '../../directives/li_form_directive.dart';
import '../modal/modal_component.dart';
import '../../validation/li_rule.dart';
import '../../validation/li_validated_field.dart';
import 'file_drop_directive.dart';
import 'file_select_directive.dart';
import 'file_type.dart';

/// What a click on a selected file (its card, thumbnail or list row) does.
///
/// Clicks on the buttons inside the item (preview, remove) always run the
/// button's own action, whatever this is set to.
enum LiFileItemClickAction {
  /// The click is handled as a click on the empty dropzone: it opens the file
  /// picker to add files when `dropzoneClickOpensPicker` is `true`. Default,
  /// and the only behavior before these options existed.
  dropzone,

  /// The click does nothing.
  none,

  /// Opens the preview modal for that file, when it can be previewed (images
  /// and PDFs, with `enablePreviewModal` on).
  preview,

  /// Opens the file picker to replace that file. The first file picked takes
  /// its place in the list; the others are ignored.
  replace,
}

/// The user actions of `li-file-upload` that emit a `before*` event and go
/// through `confirmAction`.
enum LiFileUploadAction {
  /// Files dropped on the dropzone or picked in the file dialog.
  add,

  /// One file removed by its remove button.
  remove,

  /// Every file removed by the clear button or the dropzone close button.
  clear,

  /// The preview modal opened for one file.
  preview,

  /// One file replaced by another, in the same position.
  replace,

  /// The file picker opened to add files.
  browse,
}

/// Signature of `li-file-upload`'s `confirmAction`: completes with `true` to
/// let the action run and `false` to cancel it.
typedef LiFileUploadConfirmAction = Future<bool> Function(
    LiFileUploadActionEvent event);

/// An action of `li-file-upload`, emitted before it runs (`beforeAdd`,
/// `beforeRemove`, `beforeClear`, `beforePreview`, `beforeReplace`,
/// `beforeBrowse`) and after it ran (`added`, `removed`, `cleared`,
/// `previewOpened`, `replaced`).
///
/// The `before*` streams are synchronous: the handler runs inside the
/// component's own call, and the component reads [defaultPrevented] right
/// after it returns. [preventDefault] therefore has to be called before the
/// handler's first `await`; to cancel on asynchronous work (a confirmation
/// dialog, a server check), use the component's `confirmAction` instead.
/// Calling [preventDefault] on an event received after the action has no
/// effect.
class LiFileUploadActionEvent {
  LiFileUploadActionEvent({
    required this.action,
    this.file,
    this.index = -1,
    List<html.File>? files,
    this.previousFile,
  }) : files = files ?? <html.File>[];

  /// The action this event is about.
  final LiFileUploadAction action;

  /// The file involved: the one removed, previewed or about to be replaced.
  /// In `replaced` it is the new file, and [previousFile] is the old one.
  /// `null` for [LiFileUploadAction.add], [LiFileUploadAction.clear] and
  /// [LiFileUploadAction.browse].
  final html.File? file;

  /// Position of [file] in the list, or `-1` when the action has no single
  /// file.
  final int index;

  /// The files involved. In `beforeAdd`, the files about to enter, before
  /// the duplicate filter and `maxFiles`: the handler (or `confirmAction`) can
  /// remove items from this list, or assign a new list, and only what is left
  /// enters; an empty list adds nothing. In `added`, the files that did
  /// enter. In `clear`, the files being removed. For the single-file actions,
  /// a list with [file]. Only `beforeAdd` reads it back.
  List<html.File> files;

  /// In `replaced`, the file that was replaced. `null` in the other events.
  final html.File? previousFile;

  bool _defaultPrevented = false;

  /// Whether a handler cancelled the action.
  bool get defaultPrevented => _defaultPrevented;

  /// Cancels the action. Has to run synchronously inside the `before*`
  /// handler.
  void preventDefault() {
    _defaultPrevented = true;
  }
}

/// Default texts of `li-file-upload` in one language. The inputs the
/// application sets (`title`, `subtitle`, `browseLabel`, `clearLabel` and the
/// preview titles) take precedence over these.
class _LiFileUploadTexts {
  const _LiFileUploadTexts({
    required this.title,
    required this.subtitle,
    required this.captionPlaceholderSingle,
    required this.captionPlaceholderMultiple,
    required this.browse,
    required this.browseAria,
    required this.selectedFiles,
    required this.clear,
    required this.upload,
    required this.uploadIndicator,
    required this.cancel,
    required this.preview,
    required this.remove,
    required this.zoomIn,
    required this.zoomOut,
    required this.openPreview,
    required this.removeFile,
    required this.resetZoom,
    required this.closePreview,
    required this.pdfPreview,
    required this.documentPreview,
    required this.previousFile,
    required this.nextFile,
    required this.rotate,
    required this.enterFullscreen,
    required this.exitFullscreen,
    required this.enterBorderless,
    required this.exitBorderless,
    required this.filePreview,
    required this.maxSizePrefix,
    required this.typeNotAllowed,
  });

  final String title;
  final String subtitle;
  final String captionPlaceholderSingle;
  final String captionPlaceholderMultiple;
  final String browse;
  final String browseAria;
  final String selectedFiles;
  final String clear;
  final String upload;
  final String uploadIndicator;
  final String cancel;
  final String preview;
  final String remove;
  final String zoomIn;
  final String zoomOut;
  final String openPreview;
  final String removeFile;
  final String resetZoom;
  final String closePreview;
  final String pdfPreview;
  final String documentPreview;
  final String previousFile;
  final String nextFile;
  final String rotate;
  final String enterFullscreen;
  final String exitFullscreen;
  final String enterBorderless;
  final String exitBorderless;
  final String filePreview;

  /// Followed by the formatted size and a period.
  final String maxSizePrefix;
  final String typeNotAllowed;

  static const _LiFileUploadTexts en = _LiFileUploadTexts(
    title: 'Drop files here',
    subtitle: 'Or choose files from your device',
    captionPlaceholderSingle: 'Select file ...',
    captionPlaceholderMultiple: 'Select files ...',
    browse: 'Browse files',
    browseAria: 'Choose files',
    selectedFiles: 'Selected files',
    clear: 'Clear',
    upload: 'Upload',
    uploadIndicator: 'Not uploaded yet',
    cancel: 'Cancel',
    preview: 'Preview',
    remove: 'Remove',
    zoomIn: 'Zoom in',
    zoomOut: 'Zoom out',
    openPreview: 'Open preview',
    removeFile: 'Remove file',
    resetZoom: 'Reset zoom',
    closePreview: 'Close preview',
    pdfPreview: 'PDF preview',
    documentPreview: 'Document preview',
    previousFile: 'View previous file',
    nextFile: 'View next file',
    rotate: 'Rotate 90 deg. clockwise',
    enterFullscreen: 'Toggle full screen',
    exitFullscreen: 'Exit full screen',
    enterBorderless: 'Toggle borderless mode',
    exitBorderless: 'Disable borderless mode',
    filePreview: 'File preview',
    maxSizePrefix: 'File exceeds the maximum size of',
    typeNotAllowed: 'File type not allowed.',
  );

  static const _LiFileUploadTexts ptBr = _LiFileUploadTexts(
    title: 'Arraste arquivos aqui',
    subtitle: 'Ou selecione arquivos do seu dispositivo',
    captionPlaceholderSingle: 'Selecionar arquivo ...',
    captionPlaceholderMultiple: 'Selecionar arquivos ...',
    browse: 'Selecionar arquivos',
    browseAria: 'Selecionar arquivos',
    selectedFiles: 'Arquivos selecionados',
    clear: 'Limpar',
    upload: 'Enviar',
    uploadIndicator: 'Ainda não enviado',
    cancel: 'Cancelar',
    preview: 'Visualizar',
    remove: 'Remover',
    zoomIn: 'Ampliar',
    zoomOut: 'Reduzir',
    openPreview: 'Abrir visualização',
    removeFile: 'Remover arquivo',
    resetZoom: 'Restaurar zoom',
    closePreview: 'Fechar visualização',
    pdfPreview: 'Visualização do PDF',
    documentPreview: 'Visualização do documento',
    previousFile: 'Visualizar arquivo anterior',
    nextFile: 'Visualizar próximo arquivo',
    rotate: 'Girar 90 graus no sentido horário',
    enterFullscreen: 'Alternar tela cheia',
    exitFullscreen: 'Sair da tela cheia',
    enterBorderless: 'Alternar modo sem borda',
    exitBorderless: 'Desativar modo sem borda',
    filePreview: 'Pré-visualização',
    maxSizePrefix: 'Arquivo excede o tamanho máximo de',
    typeNotAllowed: 'Tipo de arquivo não permitido.',
  );
}

class LiFileUploadPreviewItem {
  const LiFileUploadPreviewItem({
    required this.file,
    required this.kind,
    required this.kindLabel,
    required this.sizeLabel,
    this.errorText = '',
    this.previewUrl,
    this.previewSafeUrl,
    this.previewResourceUrl,
  });

  final html.File file;
  final String kind;
  final String kindLabel;
  final String sizeLabel;
  final String errorText;
  final String? previewUrl;
  final SafeUrl? previewSafeUrl;
  final SafeResourceUrl? previewResourceUrl;

  bool get hasError => errorText.trim().isNotEmpty;

  bool get isImage => kind == 'image';

  bool get isPdf => kind == 'pdf';

  bool get canPreview => previewUrl != null;
}

@Component(
  selector: 'li-file-upload',
  templateUrl: 'file_upload_component.html',
  styleUrls: ['file_upload_component.css'],
  directives: [
    coreDirectives,
    LiFileDropDirective,
    LiFileSelectDirective,
    LiModalComponent,
  ],
  providers: [
    ExistingProvider.forToken(ngValueAccessor, LiFileUploadComponent),
  ],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class LiFileUploadComponent
    with LiValidatedField
    implements ControlValueAccessor<List<html.File>?>, AfterChanges, OnDestroy {
  static const num _minPreviewZoomLevel = 0.25;
  static const num _maxPreviewZoomLevel = 8;
  static const num _previewZoomFactor = 1.25;
  static const double _previewModalPaddingPx = 32;

  LiFileUploadComponent(
    this._changeDetectorRef, [
    @Optional() this._formDirective,
  ]);

  final ChangeDetectorRef _changeDetectorRef;
  final LiFormDirective? _formDirective;
  final DomSanitizationService _domSanitizationService =
      DomSanitizationService();
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();

  // `before*` streams are synchronous so a handler's preventDefault() is seen
  // before the component goes on; `after` streams are asynchronous like
  // `filesChange`.
  final StreamController<LiFileUploadActionEvent> _beforeAddController =
      StreamController<LiFileUploadActionEvent>.broadcast(sync: true);
  final StreamController<LiFileUploadActionEvent> _beforeRemoveController =
      StreamController<LiFileUploadActionEvent>.broadcast(sync: true);
  final StreamController<LiFileUploadActionEvent> _beforeClearController =
      StreamController<LiFileUploadActionEvent>.broadcast(sync: true);
  final StreamController<LiFileUploadActionEvent> _beforePreviewController =
      StreamController<LiFileUploadActionEvent>.broadcast(sync: true);
  final StreamController<LiFileUploadActionEvent> _beforeReplaceController =
      StreamController<LiFileUploadActionEvent>.broadcast(sync: true);
  final StreamController<LiFileUploadActionEvent> _beforeBrowseController =
      StreamController<LiFileUploadActionEvent>.broadcast(sync: true);
  final StreamController<LiFileUploadActionEvent> _addedController =
      StreamController<LiFileUploadActionEvent>.broadcast();
  final StreamController<LiFileUploadActionEvent> _removedController =
      StreamController<LiFileUploadActionEvent>.broadcast();
  final StreamController<LiFileUploadActionEvent> _clearedController =
      StreamController<LiFileUploadActionEvent>.broadcast();
  final StreamController<LiFileUploadActionEvent> _previewOpenedController =
      StreamController<LiFileUploadActionEvent>.broadcast();
  final StreamController<LiFileUploadActionEvent> _replacedController =
      StreamController<LiFileUploadActionEvent>.broadcast();
  StreamSubscription<html.Event>? _fullscreenChangeSubscription;

  List<html.File> _files = <html.File>[];

  /// The file waiting for its replacement while the picker opened by a
  /// `replace` is up; `null` when the picker adds files.
  html.File? _pendingReplaceFile;

  /// Set while [openPicker] clicks the native input, so the browse button's
  /// click handler lets that click through instead of guarding it again.
  bool _openingPicker = false;

  bool _destroyed = false;

  @Input()
  bool multiple = true;

  @Input()
  bool disabled = false;

  @Input()
  bool showPreview = true;

  /// Renders the caption field of the bottom bar: the read-only input that
  /// lists the selected file names, and its icon, beside the browse button.
  ///
  /// With `false` neither is rendered and the browse button takes the whole
  /// bar. Useful with the `thumbnails` and `limitless` preview modes, where
  /// each card already shows the file name.
  @Input()
  bool showCaption = true;

  /// Renders the browse button of the bottom bar. With `false` the native
  /// `input[type=file]` stays in the component, outside the bar, so a click
  /// on the dropzone and [browse] still open the picker.
  @Input()
  bool showBrowseButton = true;

  /// Icon class of the browse button, beside [browseLabel]. Empty renders no
  /// icon.
  @Input()
  String browseIcon = 'ph-file-plus';

  /// Renders the "Clear" button of the bottom bar, which removes every file.
  ///
  /// Defaults to `false` because the Limitless theme has always hidden that
  /// button (`.file-input-ajax-new .fileinput-remove-button`), so pages saw
  /// only the dropzone close button. With `true` the component shows it,
  /// while there are files.
  @Input()
  bool showClearButton = false;

  /// Label of the clear button, also the accessible name of the dropzone
  /// close button. Empty uses the default text of [locale].
  @Input()
  String clearLabel = '';

  /// Renders the close button at the top right corner of the dropzone, shown
  /// while there are files. It removes every file, like the clear button, and
  /// goes through `beforeClear`/`confirmAction`.
  @Input()
  bool showDropzoneClearButton = true;

  /// Renders the button that opens the preview modal of a file, in the
  /// `thumbnails` and `limitless` cards.
  @Input()
  bool showPreviewButton = true;

  /// Renders the remove button of each file, in the cards and in the
  /// `compact` list.
  @Input()
  bool showRemoveButton = true;

  /// Renders the size of each file, in the cards and in the `compact` list.
  @Input()
  bool showFileSize = true;

  /// Renders the name of each file, in the cards and in the `compact` list.
  @Input()
  bool showFileName = true;

  /// Renders the green "not uploaded yet" icon of each card. It is a status
  /// indicator inherited from the Krajee fileinput markup, not a button: the
  /// component never uploads anything.
  @Input()
  bool showUploadIndicator = true;

  /// Whether a click (or Enter/Space) on the dropzone, outside the files,
  /// opens the file picker. Dropping files keeps working with `false`.
  @Input()
  bool dropzoneClickOpensPicker = true;

  /// What a click on a selected file does. See [LiFileItemClickAction].
  @Input()
  LiFileItemClickAction itemClickAction = LiFileItemClickAction.dropzone;

  /// Optional asynchronous confirmation of every user action. When set, the
  /// component waits for it after the `before*` event and runs the action
  /// only if it completes with `true`; `false` or an error cancels it. Read
  /// [LiFileUploadActionEvent.action] to confirm only some actions and
  /// complete with `true` for the others.
  ///
  /// Browsers open the file picker only during a user gesture; a dialog
  /// confirmed by a click gives a new one, but a long-running check before
  /// [LiFileUploadAction.browse] or [LiFileUploadAction.replace] may get the
  /// picker blocked.
  @Input()
  LiFileUploadConfirmAction? confirmAction;

  @Input()
  String previewMode = 'compact';

  @Input()
  bool enablePreviewModal = true;

  @Input()
  bool enablePreviewZoom = true;

  @Input()
  int maxFiles = 0;

  @Input()
  String accept = '';

  @Input()
  String? name;

  @Input()
  String title = '';

  @Input()
  String subtitle = '';

  @Input()
  String browseLabel = '';

  @Input()
  String pdfPreviewTitle = '';

  @Input()
  String documentPreviewTitle = '';

  @Input()
  String previousFileTitle = '';

  @Input()
  String nextFileTitle = '';

  @Input()
  String helperText = '';

  @override
  @Input()
  String locale = 'pt_BR';

  @Input()
  bool valid = false;

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

  /// Before files enter the list, by drop or by the picker. Synchronous:
  /// cancel with `preventDefault()`, or filter `event.files`.
  @Output()
  Stream<LiFileUploadActionEvent> get beforeAdd => _beforeAddController.stream;

  /// Before a file is removed by its remove button. Synchronous.
  @Output()
  Stream<LiFileUploadActionEvent> get beforeRemove =>
      _beforeRemoveController.stream;

  /// Before every file is removed by the clear button or the dropzone close
  /// button. Synchronous.
  @Output()
  Stream<LiFileUploadActionEvent> get beforeClear =>
      _beforeClearController.stream;

  /// Before the preview modal opens. Synchronous.
  @Output()
  Stream<LiFileUploadActionEvent> get beforePreview =>
      _beforePreviewController.stream;

  /// Before the picker opens to replace a file, with the file that would be
  /// replaced. Synchronous.
  @Output()
  Stream<LiFileUploadActionEvent> get beforeReplace =>
      _beforeReplaceController.stream;

  /// Before the picker opens to add files. Synchronous.
  @Output()
  Stream<LiFileUploadActionEvent> get beforeBrowse =>
      _beforeBrowseController.stream;

  /// After files entered the list; `files` holds only the new ones.
  @Output()
  Stream<LiFileUploadActionEvent> get added => _addedController.stream;

  /// After a file was removed.
  @Output()
  Stream<LiFileUploadActionEvent> get removed => _removedController.stream;

  /// After every file was removed; `files` holds what was removed.
  @Output()
  Stream<LiFileUploadActionEvent> get cleared => _clearedController.stream;

  /// After the preview modal opened.
  @Output()
  Stream<LiFileUploadActionEvent> get previewOpened =>
      _previewOpenedController.stream;

  /// After a file was replaced: `file` is the new one, `previousFile` the
  /// old one.
  @Output()
  Stream<LiFileUploadActionEvent> get replaced => _replacedController.stream;

  /// The native input inside the browse button, while it is shown.
  @ViewChild('fileInput')
  html.InputElement? fileInput;

  /// The native input kept outside the bar while [showBrowseButton] is off.
  @ViewChild('detachedFileInput')
  html.InputElement? detachedFileInput;

  /// The native file input in use, wherever it is rendered.
  html.InputElement? get nativeFileInput => fileInput ?? detachedFileInput;

  @ViewChild('previewModal')
  LiModalComponent? previewModal;

  @ViewChild('previewZoomBody')
  html.HtmlElement? previewZoomBodyElement;

  @ViewChild('previewImage')
  html.HtmlElement? previewImageElement;

  ChangeFunction<List<html.File>?> _onChange =
      (List<html.File>? _, {String? rawValue}) {};
  TouchFunction _onTouched = () {};

  bool isDragOver = false;
  List<LiFileUploadPreviewItem> previewItems =
      const <LiFileUploadPreviewItem>[];
  Map<String, String> fileErrors = const <String, String>{};
  LiFileUploadPreviewItem? activePreviewItem;
  num previewZoomLevel = 1;
  bool isPreviewFullscreen = false;
  bool isPreviewBorderless = false;
  int previewRotationQuarterTurns = 0;
  num _previewImageNaturalWidth = 0;
  num _previewImageNaturalHeight = 0;
  double? _previewRenderedWidth;
  double? _previewRenderedHeight;

  bool get hasFiles => _files.isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  bool get isEnglishLocale => locale.toLowerCase().startsWith('en');

  bool get hasFileErrors => fileErrors.isNotEmpty;

  @override
  dynamic get validationValue => _files;

  @override
  String get externalErrorText => errorText;

  @override
  String? get validationFieldName => resolvedTitle;

  @override
  List<LiRule> buildValidationRules() => <LiRule>[
        if (required) const LiRequiredRule(),
        ...liRules,
      ];

  @override
  void didChangeFormSubmission() {
    _markForCheck();
  }

  /// Also invalid while a selected file breaks [maxSize] or [allowedTypes].
  @override
  bool get effectiveInvalid =>
      invalid || dataInvalid || hasFileErrors || effectiveAutoInvalid;

  /// Also valid, once visible, when files are selected and no rule is set.
  @override
  bool get effectiveValid =>
      !effectiveInvalid &&
      (valid ||
          (shouldShowValidation &&
              (_files.isNotEmpty || effectiveRules.isNotEmpty) &&
              !hasFileErrors &&
              validationIssue == null));

  String? get resolvedDescribedBy =>
      describedBy.trim().isEmpty ? null : describedBy.trim();

  String? get resolvedName => name;

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

  /// Default texts for [locale]: English for `en*`, Brazilian Portuguese
  /// otherwise, like the other components of the package.
  _LiFileUploadTexts get _texts =>
      isEnglishLocale ? _LiFileUploadTexts.en : _LiFileUploadTexts.ptBr;

  String get resolvedTitle =>
      title.trim().isNotEmpty ? title : _texts.title;

  String get resolvedSubtitle =>
      subtitle.trim().isNotEmpty ? subtitle : _texts.subtitle;

  String get captionPlaceholder => multiple
      ? _texts.captionPlaceholderMultiple
      : _texts.captionPlaceholderSingle;

  String get captionValue =>
      hasFiles ? _files.map((file) => file.name).join(', ') : '';

  String get resolvedBrowseLabel =>
      browseLabel.trim().isNotEmpty ? browseLabel : _texts.browse;

  /// Icon class of the browse button, or empty when [browseIcon] is blank.
  String get resolvedBrowseIcon => browseIcon.trim();

  String get selectedFilesTitle => _texts.selectedFiles;

  String get previewStatusText => '';

  /// [clearLabel] when set, else the default text of [locale].
  String get resolvedClearLabel =>
      clearLabel.trim().isNotEmpty ? clearLabel : _texts.clear;

  String get uploadLabel => _texts.upload;

  /// Tooltip of the green status icon of each card.
  String get uploadIndicatorLabel => _texts.uploadIndicator;

  String get cancelLabel => _texts.cancel;

  String get previewLabel => _texts.preview;

  /// Tooltip of the remove button of each file.
  String get removeLabel => _texts.remove;

  String get zoomInLabel => _texts.zoomIn;

  String get zoomOutLabel => _texts.zoomOut;

  String get zoomPreviewAriaLabel => _texts.openPreview;

  String get removePreviewAriaLabel => _texts.removeFile;

  String get resetZoomLabel => _texts.resetZoom;

  String get closePreviewLabel => _texts.closePreview;

  String get resolvedPdfPreviewTitle =>
      pdfPreviewTitle.trim().isNotEmpty ? pdfPreviewTitle : _texts.pdfPreview;

  String get resolvedDocumentPreviewTitle =>
      documentPreviewTitle.trim().isNotEmpty
          ? documentPreviewTitle
          : _texts.documentPreview;

  String get resolvedPreviousFileTitle => previousFileTitle.trim().isNotEmpty
      ? previousFileTitle
      : _texts.previousFile;

  String get resolvedNextFileTitle =>
      nextFileTitle.trim().isNotEmpty ? nextFileTitle : _texts.nextFile;

  String get rotatePreviewLabel => _texts.rotate;

  String get fullscreenPreviewLabel =>
      isPreviewFullscreen ? _texts.exitFullscreen : _texts.enterFullscreen;

  String get borderlessPreviewLabel =>
      isPreviewBorderless ? _texts.exitBorderless : _texts.enterBorderless;

  String get previewModalSize =>
      isPreviewFullscreen || isPreviewBorderless ? 'modal-full' : 'large';

  bool get canRotateActivePreview => activePreviewItem?.isImage ?? false;

  bool get canZoomActivePreview => activePreviewItem?.isImage ?? false;

  String get previewImageTransform =>
      'rotate(${previewRotationQuarterTurns * 90}deg)';

  bool get previewShouldAllowScroll =>
      activePreviewItem?.isPdf == true ||
      previewRotationQuarterTurns.isOdd ||
      previewZoomLevel > 1;

  String? get previewImageWidthStyle => _previewRenderedWidth == null
      ? null
      : '${_previewRenderedWidth!.toStringAsFixed(2)}px';

  String? get previewImageHeightStyle => _previewRenderedHeight == null
      ? null
      : '${_previewRenderedHeight!.toStringAsFixed(2)}px';

  bool get isThumbnailPreviewMode => resolvedPreviewMode == 'thumbnails';

  bool get isLimitlessPreviewMode => resolvedPreviewMode == 'limitless';

  bool get isCardPreviewMode =>
      isThumbnailPreviewMode || isLimitlessPreviewMode;

  String get resolvedPreviewMode {
    final normalized = previewMode.trim().toLowerCase();
    if (normalized == 'thumbnails' || normalized == 'limitless') {
      return normalized;
    }
    return 'compact';
  }

  String get resolvedPreviewClass => _joinClasses(<String>[
        'li-file-upload__preview',
        isCardPreviewMode ? 'li-file-upload__preview--thumbnails' : '',
        isLimitlessPreviewMode ? 'li-file-upload__preview--limitless' : '',
      ]);

  num get initialPreviewZoomLevel => 1;

  String get activePreviewTitle =>
      activePreviewItem?.file.name ?? _texts.filePreview;

  String get resolvedRootClass => _joinClasses(<String>[
        'li-file-upload',
        'file-input',
        'file-input-ajax-new',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        disabled ? 'is-disabled' : '',
        hasBottomBar ? '' : 'li-file-upload--without-bar',
      ]);

  String get browseAriaLabel => _texts.browseAria;

  String get resolvedDropzoneClass => _joinClasses(<String>[
        'li-file-upload__dropzone',
        'file-drop-zone',
        dropzoneClickOpensPicker ? 'clickable' : '',
        'clearfix',
        isDragOver ? 'is-over' : '',
        disabled ? 'is-disabled' : '',
        effectiveInvalid ? 'is-invalid' : '',
        effectiveValid ? 'is-valid' : '',
        dropzoneClass,
      ]);

  String get resolvedListClass => _joinClasses(<String>[
        'list-group',
        'list-group-flush',
        listClass,
      ]);

  String get resolvedFeedbackClass => _joinClasses(<String>[
        'invalid-feedback',
        'd-block',
        feedbackClass,
      ]);

  /// Whether the clear button of the bottom bar is rendered now.
  bool get showsClearButton => showClearButton && hasFiles;

  /// Whether the bottom bar has anything to show. Without it the bar is not
  /// rendered and the dropzone loses its bottom margin.
  bool get hasBottomBar => showCaption || showBrowseButton || showsClearButton;

  /// Whether the dropzone close button is rendered now.
  bool get showsDropzoneClearButton => showDropzoneClearButton && hasFiles;

  /// Whether a click on a file does something of its own (preview or
  /// replace), so the item is styled as clickable and a PDF thumbnail stops
  /// swallowing the click.
  bool get itemClickIsActive =>
      itemClickAction == LiFileItemClickAction.preview ||
      itemClickAction == LiFileItemClickAction.replace;

  /// Whether the card of [item] shows its preview button.
  bool showsPreviewButton(LiFileUploadPreviewItem item) =>
      showPreviewButton && canOpenPreview(item);

  /// Whether the action buttons area of the card of [item] has content.
  bool showsCardButtons(LiFileUploadPreviewItem item) =>
      showUploadIndicator || showsPreviewButton(item) || showRemoveButton;

  /// Whether the size/buttons bar of the card of [item] has content.
  bool showsCardFooterBar(LiFileUploadPreviewItem item) =>
      showFileSize || showsCardButtons(item);

  /// Whether the footer of the card of [item] has content.
  bool showsCardFooter(LiFileUploadPreviewItem item) =>
      showFileName || showsCardFooterBar(item) || item.hasError;

  /// The [locale] the per-file error texts were built with.
  String _lastLocale = '';

  @override
  void ngAfterChanges() {
    connectValidationForm(_formDirective);
    _fullscreenChangeSubscription ??=
        html.document.onFullscreenChange.listen((_) {
      final isBrowserFullscreen = html.document.fullscreenElement != null;
      if (!isBrowserFullscreen && isPreviewFullscreen) {
        isPreviewFullscreen = false;
      }
      _schedulePreviewLayoutUpdate();
      _markForCheck();
    });

    if (_lastLocale != locale) {
      final firstRun = _lastLocale.isEmpty;
      _lastLocale = locale;
      if (!firstRun) {
        _refreshFileErrors();
      }
    }

    rebuildValidationConfig();
    runValidation();
    _markForCheck();
  }

  @HostBinding('class.d-block')
  bool get hostClass => true;

  /// Enter or Space on the focused dropzone opens the picker, like a click,
  /// when [dropzoneClickOpensPicker] is on. Keys pressed on a button inside
  /// it (remove, preview) are left to that button.
  void onDropzoneKeyDown(html.Event event) {
    if (event is! html.KeyboardEvent) {
      return;
    }

    if (disabled || !dropzoneClickOpensPicker) {
      return;
    }

    final target = event.target;
    if (target is html.Element &&
        !identical(target, event.currentTarget) &&
        _isInteractiveTarget(target)) {
      return;
    }

    if (event.key == 'Enter' || event.key == ' ') {
      event.preventDefault();
      browse();
    }
  }

  /// A click on the dropzone outside any button opens the picker, when
  /// [dropzoneClickOpensPicker] is on. Clicks on a file reach here only with
  /// [LiFileItemClickAction.dropzone].
  void onDropzoneClick(html.Event event) {
    if (disabled || !dropzoneClickOpensPicker) {
      return;
    }

    final target = event.target;
    if (target is html.Element && _isInteractiveTarget(target)) {
      return;
    }

    browse();
  }

  /// A click on the file at [index] (card, thumbnail or list row), outside
  /// its buttons, runs [itemClickAction].
  void onItemClick(html.Event event, int index) {
    if (itemClickAction == LiFileItemClickAction.dropzone) {
      return; // bubbles to onDropzoneClick, as before
    }

    final target = event.target;
    if (target is html.Element && _isInteractiveTarget(target)) {
      return;
    }

    event.stopPropagation();
    if (disabled || index < 0 || index >= previewItems.length) {
      return;
    }

    switch (itemClickAction) {
      case LiFileItemClickAction.preview:
        requestPreview(previewItems[index]);
        break;
      case LiFileItemClickAction.replace:
        requestReplace(index);
        break;
      case LiFileItemClickAction.none:
      case LiFileItemClickAction.dropzone:
        break;
    }
  }

  /// The browse button is a label around the native input, whose default
  /// action opens the picker. That default is held back so the click goes
  /// through [browse] and its `beforeBrowse`/[confirmAction]; [openPicker]
  /// then clicks the input again, and that second click is let through.
  void onBrowseButtonClick(html.Event event) {
    if (_openingPicker) {
      return;
    }
    event.preventDefault();
    browse();
  }

  /// Opens the file picker to add files, as the browse button and the
  /// dropzone do: emits `beforeBrowse`, waits for [confirmAction] and then
  /// opens it. Completes with whether the picker was opened.
  Future<bool> browse() {
    return _runGuarded(
      _beforeBrowseController,
      LiFileUploadActionEvent(action: LiFileUploadAction.browse),
      () {
        _pendingReplaceFile = null;
        openPicker();
      },
    );
  }

  /// Opens the file picker at once, without `beforeBrowse` or
  /// [confirmAction]. Works with the browse button hidden.
  void openPicker() {
    if (disabled) {
      return;
    }
    _markTouched();
    final input = nativeFileInput;
    if (input == null) {
      return;
    }
    input.multiple = _pendingReplaceFile == null && multiple;
    _openingPicker = true;
    try {
      input.click();
    } finally {
      _openingPicker = false;
    }
  }

  void onFileOver(bool value) {
    isDragOver = value && !disabled;
    _markForCheck();
  }

  /// Files dropped on the dropzone, or picked to add. Goes through
  /// `beforeAdd` and [confirmAction].
  void onFilesSelected(List<html.File> files) {
    if (disabled) {
      return;
    }
    _pendingReplaceFile = null;
    _consumeFiles(files);
  }

  /// Files picked in the native input: they replace the pending file when
  /// the picker was opened by a `replace`, and are added otherwise.
  void onFileInputChange(List<html.File> files) {
    final pending = _pendingReplaceFile;
    _pendingReplaceFile = null;
    _resetNativeInput();
    if (disabled) {
      return;
    }
    if (pending == null) {
      _consumeFiles(files);
      return;
    }
    if (files.isEmpty) {
      return;
    }
    final index = _files.indexWhere((file) => identical(file, pending));
    if (index < 0) {
      return;
    }
    replaceAt(index, files.first);
  }

  /// The user closed the picker without choosing: a pending replace is
  /// dropped.
  void onFileInputCancel() {
    _pendingReplaceFile = null;
    _resetNativeInput();
  }

  /// Removes the file at [index] as its remove button does: emits
  /// `beforeRemove`, waits for [confirmAction] and then removes it.
  /// Completes with whether it was removed.
  Future<bool> requestRemove(int index) {
    if (index < 0 || index >= _files.length) {
      return Future<bool>.value(false);
    }
    final file = _files[index];
    return _runGuarded(
      _beforeRemoveController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.remove,
        file: file,
        index: index,
        files: <html.File>[file],
      ),
      () {
        // The list may have changed while confirmAction was pending.
        final current = _files.indexWhere((item) => identical(item, file));
        if (current >= 0) {
          removeAt(current);
        }
      },
    );
  }

  /// Removes the file at [index] at once, without `beforeRemove` or
  /// [confirmAction], and emits `removed`.
  void removeAt(int index) {
    if (disabled || index < 0 || index >= _files.length) {
      return;
    }
    final removedFile = _files[index];
    if (activePreviewItem != null &&
        identical(activePreviewItem!.file, removedFile)) {
      closePreview();
    }
    validationDirty = true;
    final nextFiles = List<html.File>.from(_files)..removeAt(index);
    _setFiles(nextFiles, emitToForm: true);
    _emitAfter(
      _removedController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.remove,
        file: removedFile,
        index: index,
        files: <html.File>[removedFile],
      ),
    );
  }

  /// Removes every file as the clear buttons do: emits `beforeClear`, waits
  /// for [confirmAction] and then clears. Completes with whether it cleared.
  Future<bool> requestClear() {
    return _runGuarded(
      _beforeClearController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.clear,
        files: List<html.File>.from(_files),
      ),
      clear,
    );
  }

  /// Removes every file at once, without `beforeClear` or [confirmAction],
  /// and emits `cleared`.
  void clear() {
    final previous = List<html.File>.from(_files);
    validationDirty = true;
    closePreview();
    _setFiles(const <html.File>[], emitToForm: true);
    _emitAfter(
      _clearedController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.clear,
        files: previous,
      ),
    );
  }

  /// Opens the picker to replace the file at [index]: emits `beforeReplace`,
  /// waits for [confirmAction] and then opens it. The first file picked takes
  /// that position and `replaced` is emitted. Completes with whether the
  /// picker was opened.
  Future<bool> requestReplace(int index) {
    if (index < 0 || index >= _files.length) {
      return Future<bool>.value(false);
    }
    final file = _files[index];
    return _runGuarded(
      _beforeReplaceController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.replace,
        file: file,
        index: index,
        files: <html.File>[file],
      ),
      () {
        if (!_files.any((item) => identical(item, file))) {
          return;
        }
        _pendingReplaceFile = file;
        openPicker();
      },
    );
  }

  /// Puts [file] in place of the file at [index] at once, without
  /// `beforeReplace` or [confirmAction], and emits `replaced`.
  void replaceAt(int index, html.File file) {
    if (disabled || index < 0 || index >= _files.length) {
      return;
    }
    final previous = _files[index];
    if (activePreviewItem != null &&
        identical(activePreviewItem!.file, previous)) {
      closePreview();
    }
    validationDirty = true;
    final nextFiles = List<html.File>.from(_files)..[index] = file;
    _setFiles(nextFiles, emitToForm: true);
    _emitAfter(
      _replacedController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.replace,
        file: file,
        index: index,
        files: <html.File>[file],
        previousFile: previous,
      ),
    );
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

  bool canOpenPreview(LiFileUploadPreviewItem item) {
    return enablePreviewModal && item.canPreview;
  }

  /// Opens the preview modal as the preview button does: emits
  /// `beforePreview`, waits for [confirmAction] and then opens it. Completes
  /// with whether it opened.
  Future<bool> requestPreview(LiFileUploadPreviewItem item) {
    if (!canOpenPreview(item)) {
      return Future<bool>.value(false);
    }
    return _runGuarded(
      _beforePreviewController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.preview,
        file: item.file,
        index: _files.indexWhere((file) => identical(file, item.file)),
        files: <html.File>[item.file],
      ),
      () {
        for (final current in previewItems) {
          if (identical(current.file, item.file)) {
            openPreview(current);
            return;
          }
        }
      },
    );
  }

  /// Opens the preview modal at once, without `beforePreview` or
  /// [confirmAction], and emits `previewOpened`.
  void openPreview(LiFileUploadPreviewItem item) {
    if (!canOpenPreview(item)) {
      return;
    }
    activePreviewItem = item;
    isPreviewFullscreen = false;
    isPreviewBorderless = false;
    previewRotationQuarterTurns = 0;
    previewZoomLevel = initialPreviewZoomLevel;
    _clearPreviewImageLayout();
    _markForCheck();
    previewModal?.open();
    _schedulePreviewLayoutUpdate();
    _emitAfter(
      _previewOpenedController,
      LiFileUploadActionEvent(
        action: LiFileUploadAction.preview,
        file: item.file,
        index: _files.indexWhere((file) => identical(file, item.file)),
        files: <html.File>[item.file],
      ),
    );
  }

  /// Emits [event] on the synchronous [before] stream and, unless a handler
  /// prevented it, waits for [confirmAction] before calling [run]. With no
  /// [confirmAction], [run] happens before this returns, so the picker opens
  /// inside the user's click. An error from [confirmAction] cancels the
  /// action and is reported to the zone.
  Future<bool> _runGuarded(
    StreamController<LiFileUploadActionEvent> before,
    LiFileUploadActionEvent event,
    void Function() run,
  ) {
    if (disabled || _destroyed) {
      return Future<bool>.value(false);
    }
    before.add(event);
    if (event.defaultPrevented) {
      _markForCheck();
      return Future<bool>.value(false);
    }

    final confirm = confirmAction;
    if (confirm == null) {
      run();
      return Future<bool>.value(true);
    }

    return confirm(event).then((approved) {
      if (!approved || event.defaultPrevented || disabled || _destroyed) {
        _markForCheck();
        return false;
      }
      run();
      return true;
    }, onError: (Object error, StackTrace stackTrace) {
      Zone.current.handleUncaughtError(error, stackTrace);
      return false;
    });
  }

  /// Emits an after-the-fact event unless the component is gone.
  void _emitAfter(
    StreamController<LiFileUploadActionEvent> controller,
    LiFileUploadActionEvent event,
  ) {
    if (!_destroyed && !controller.isClosed) {
      controller.add(event);
    }
  }

  /// Empties the native input so picking the same file again fires `change`.
  void _resetNativeInput() {
    final input = nativeFileInput;
    if (input != null) {
      input.value = '';
    }
  }

  void closePreview() {
    _setBrowserFullscreen(false);
    activePreviewItem = null;
    isPreviewFullscreen = false;
    isPreviewBorderless = false;
    previewRotationQuarterTurns = 0;
    previewZoomLevel = initialPreviewZoomLevel;
    _clearPreviewImageLayout();
    previewModal?.close();
    _markForCheck();
  }

  void zoomInPreview() {
    if (!enablePreviewZoom || !canZoomActivePreview) {
      return;
    }
    if (previewZoomLevel >= _maxPreviewZoomLevel) {
      previewZoomLevel = _maxPreviewZoomLevel;
      _markForCheck();
      return;
    }
    previewZoomLevel = (previewZoomLevel * _previewZoomFactor)
        .clamp(_minPreviewZoomLevel, _maxPreviewZoomLevel);
    _refreshPreviewImageLayout();
  }

  void zoomOutPreview() {
    if (!enablePreviewZoom || !canZoomActivePreview) {
      return;
    }
    if (previewZoomLevel <= _minPreviewZoomLevel) {
      previewZoomLevel = _minPreviewZoomLevel;
      _markForCheck();
      return;
    }
    previewZoomLevel = (previewZoomLevel / _previewZoomFactor)
        .clamp(_minPreviewZoomLevel, _maxPreviewZoomLevel);
    _refreshPreviewImageLayout();
  }

  void resetPreviewZoom() {
    if (!canZoomActivePreview) {
      return;
    }
    previewZoomLevel = initialPreviewZoomLevel;
    _refreshPreviewImageLayout();
  }

  void togglePreviewFullscreen() {
    if (activePreviewItem == null) {
      return;
    }
    isPreviewFullscreen = !isPreviewFullscreen;
    if (isPreviewFullscreen) {
      isPreviewBorderless = false;
    }
    _setBrowserFullscreen(isPreviewFullscreen);
    _schedulePreviewLayoutUpdate();
    _markForCheck();
  }

  void togglePreviewBorderless() {
    if (activePreviewItem == null) {
      return;
    }
    isPreviewBorderless = !isPreviewBorderless;
    if (isPreviewBorderless) {
      _setBrowserFullscreen(false);
      isPreviewFullscreen = false;
    }
    _schedulePreviewLayoutUpdate();
    _markForCheck();
  }

  void rotatePreviewClockwise() {
    if (!canRotateActivePreview) {
      return;
    }
    previewRotationQuarterTurns = (previewRotationQuarterTurns + 1) % 4;
    _refreshPreviewImageLayout();
  }

  void onPreviewImageLoad(html.Event event) {
    final target = event.target;
    if (target is html.ImageElement) {
      _previewImageNaturalWidth = target.naturalWidth;
      _previewImageNaturalHeight = target.naturalHeight;
    }
    _refreshPreviewImageLayout();
  }

  /// Adds [incoming] through `beforeAdd` and [confirmAction]. The event
  /// carries the files offered (only the first one without [multiple]); what
  /// the application leaves in `event.files` is merged without duplicates
  /// and cut at [maxFiles], and `added` reports the files that entered.
  void _consumeFiles(List<html.File> incoming) {
    _markTouched();
    _resetNativeInput();
    if (incoming.isEmpty) {
      return;
    }

    final event = LiFileUploadActionEvent(
      action: LiFileUploadAction.add,
      files: multiple
          ? List<html.File>.from(incoming)
          : <html.File>[incoming.first],
    );
    _runGuarded(_beforeAddController, event, () => _addFiles(event.files));
  }

  /// Merges [offered] into the list, as the component always did, and emits
  /// `added` with the files that were not there before.
  void _addFiles(List<html.File> offered) {
    if (offered.isEmpty) {
      _markForCheck();
      return;
    }

    validationDirty = true;
    final previous = List<html.File>.from(_files);

    final normalizedIncoming =
        multiple ? _mergeFiles(_files, offered) : <html.File>[offered.first];

    _setFiles(
      _applyMaxFiles(normalizedIncoming),
      emitToForm: true,
      validationErrors: _collectFileErrors(normalizedIncoming),
    );

    final entered = _files
        .where((file) => !previous.any((old) => identical(old, file)))
        .toList();
    if (entered.isNotEmpty) {
      _emitAfter(
        _addedController,
        LiFileUploadActionEvent(action: LiFileUploadAction.add, files: entered),
      );
    }
  }

  /// Rebuilds the per-file error texts (after a [locale] change) keeping the
  /// preview URLs already created.
  void _refreshFileErrors() {
    if (_files.isEmpty) {
      return;
    }
    final errors = _collectFileErrors(_files);
    fileErrors = Map<String, String>.unmodifiable(errors);
    previewItems = previewItems
        .map((item) => LiFileUploadPreviewItem(
              file: item.file,
              kind: item.kind,
              kindLabel: item.kindLabel,
              sizeLabel: item.sizeLabel,
              errorText: errors[_fileKey(item.file)] ?? '',
              previewUrl: item.previewUrl,
              previewSafeUrl: item.previewSafeUrl,
              previewResourceUrl: item.previewResourceUrl,
            ))
        .toList(growable: false);
    final active = activePreviewItem;
    if (active != null) {
      for (final item in previewItems) {
        if (identical(item.file, active.file)) {
          activePreviewItem = item;
        }
      }
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
    _disposePreviewUrls();
    _files = List<html.File>.from(value);
    fileErrors = Map<String, String>.unmodifiable(resolvedErrors);
    previewItems = _files.map((file) {
      final kind = LiFileType.getMimeClass(file);
      final fileKey = _fileKey(file);
      final previewUrl = _createPreviewUrl(file, kind);
      return LiFileUploadPreviewItem(
        file: file,
        kind: kind,
        kindLabel: _kindLabel(kind),
        sizeLabel: _formatBytes(file.size),
        errorText: resolvedErrors[fileKey] ?? '',
        previewUrl: previewUrl,
        previewSafeUrl: _createPreviewSafeUrl(previewUrl, kind),
        previewResourceUrl: _createPreviewResourceUrl(previewUrl, kind),
      );
    }).toList(growable: false);

    if (activePreviewItem != null) {
      final activeKey = _fileKey(activePreviewItem!.file);
      activePreviewItem =
          previewItems.cast<LiFileUploadPreviewItem?>().firstWhere(
                (item) => item != null && _fileKey(item.file) == activeKey,
                orElse: () => null,
              );
    }

    if (emitToForm) {
      final payload = List<html.File>.unmodifiable(_files);
      _filesChangeController.add(payload);
      _onChange(payload, rawValue: _files.length.toString());
      _markTouched();
    }
    runValidation();
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
      return '${_texts.maxSizePrefix} ${_formatBytes(maxSize)}.';
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

    return _texts.typeNotAllowed;
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

  bool _isInteractiveTarget(html.Element target) {
    return target.closest('button') != null ||
        target.closest('label') != null ||
        target.closest('input') != null ||
        target.closest('iframe') != null;
  }

  void _setBrowserFullscreen(bool enable) {
    final root = html.document.documentElement;
    if (root == null) {
      return;
    }

    if (enable) {
      if (html.document.fullscreenElement == null) {
        unawaited(root.requestFullscreen());
      }
      return;
    }

    if (html.document.fullscreenElement != null) {
      html.document.exitFullscreen();
    }
  }

  void _clearPreviewImageLayout() {
    _previewImageNaturalWidth = 0;
    _previewImageNaturalHeight = 0;
    _previewRenderedWidth = null;
    _previewRenderedHeight = null;
  }

  void _schedulePreviewLayoutUpdate() {
    Future<void>.delayed(const Duration(milliseconds: 16), () {
      if (activePreviewItem == null || !canZoomActivePreview) {
        return;
      }
      _refreshPreviewImageLayout();
    });
  }

  void _refreshPreviewImageLayout() {
    if (!canZoomActivePreview) {
      return;
    }

    final body = previewZoomBodyElement;
    final image = previewImageElement;
    if (body == null || image == null || image is! html.ImageElement) {
      return;
    }

    final naturalWidth = _previewImageNaturalWidth > 0
        ? _previewImageNaturalWidth
        : image.naturalWidth;
    final naturalHeight = _previewImageNaturalHeight > 0
        ? _previewImageNaturalHeight
        : image.naturalHeight;
    if (naturalWidth <= 0 || naturalHeight <= 0) {
      return;
    }

    final viewportWidth = body.clientWidth.toDouble();
    final viewportHeight = body.clientHeight.toDouble();
    if (viewportWidth <= 0 || viewportHeight <= 0) {
      return;
    }

    final rotatedWidth = previewRotationQuarterTurns.isOdd
        ? naturalHeight.toDouble()
        : naturalWidth.toDouble();
    final rotatedHeight = previewRotationQuarterTurns.isOdd
        ? naturalWidth.toDouble()
        : naturalHeight.toDouble();
    final availableWidth = math.max(1, viewportWidth - _previewModalPaddingPx);
    final availableHeight =
        math.max(1, viewportHeight - _previewModalPaddingPx);
    final fittedScale = math.min(
      1,
      math.min(availableWidth / rotatedWidth, availableHeight / rotatedHeight),
    );

    _previewRenderedWidth =
        naturalWidth.toDouble() * fittedScale * previewZoomLevel.toDouble();
    _previewRenderedHeight =
        naturalHeight.toDouble() * fittedScale * previewZoomLevel.toDouble();
    _markForCheck();
  }

  String? _createPreviewUrl(html.File file, String kind) {
    if (kind != 'image' && kind != 'pdf') {
      return null;
    }
    return html.Url.createObjectUrl(file);
  }

  SafeUrl? _createPreviewSafeUrl(String? previewUrl, String kind) {
    if (kind != 'image' || previewUrl == null) {
      return null;
    }
    return _domSanitizationService.bypassSecurityTrustUrl(previewUrl);
  }

  SafeResourceUrl? _createPreviewResourceUrl(String? previewUrl, String kind) {
    if (kind != 'pdf' || previewUrl == null) {
      return null;
    }
    return _domSanitizationService.bypassSecurityTrustResourceUrl(previewUrl);
  }

  void _disposePreviewUrls() {
    for (final item in previewItems) {
      final previewUrl = item.previewUrl;
      if (previewUrl != null && previewUrl.isNotEmpty) {
        html.Url.revokeObjectUrl(previewUrl);
      }
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
    if (validationTouched) {
      _onTouched();
      if (shouldShowValidation || validationIssue != null) {
        runValidation();
      }
      return;
    }
    validationTouched = true;
    _onTouched();
    runValidation();
  }

  @override
  void ngOnDestroy() {
    _destroyed = true;
    _disposePreviewUrls();
    disconnectValidationForm();
    _fullscreenChangeSubscription?.cancel();
    _filesChangeController.close();
    for (final controller in <StreamController<LiFileUploadActionEvent>>[
      _beforeAddController,
      _beforeRemoveController,
      _beforeClearController,
      _beforePreviewController,
      _beforeReplaceController,
      _beforeBrowseController,
      _addedController,
      _removedController,
      _clearedController,
      _previewOpenedController,
      _replacedController,
    ]) {
      controller.close();
    }
  }
}
