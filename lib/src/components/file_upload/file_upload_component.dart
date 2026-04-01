import 'dart:async';
import 'dart:html' as html;

import 'package:ngdart/angular.dart';
import 'package:ngforms/ngforms.dart'
    show ChangeFunction, ControlValueAccessor, TouchFunction, ngValueAccessor;

import 'file_drop_directive.dart';
import 'file_select_directive.dart';
import 'file_type.dart';

class LiFileUploadPreviewItem {
  const LiFileUploadPreviewItem({
    required this.file,
    required this.kind,
    required this.kindLabel,
    required this.sizeLabel,
  });

  final html.File file;
  final String kind;
  final String kindLabel;
  final String sizeLabel;
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
    implements ControlValueAccessor<List<html.File>?>, OnDestroy {
  LiFileUploadComponent(this._changeDetectorRef);

  final ChangeDetectorRef _changeDetectorRef;
  final StreamController<List<html.File>> _filesChangeController =
      StreamController<List<html.File>>.broadcast();

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
  String title = 'Arraste arquivos aqui';

  @Input()
  String subtitle = 'Ou selecione arquivos do seu dispositivo';

  @Input()
  String browseLabel = 'Selecionar arquivos';

  @Input()
  String helperText = '';

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

  bool isDragOver = false;
  List<LiFileUploadPreviewItem> previewItems = const <LiFileUploadPreviewItem>[];

  bool get hasFiles => _files.isNotEmpty;

  bool get hasHelperText => helperText.trim().isNotEmpty;

  String get resolvedAccept => accept.trim();

  String get resolvedDropzoneClass => _joinClasses(<String>[
        'li-file-upload__dropzone',
        isDragOver ? 'is-over' : '',
        disabled ? 'is-disabled' : '',
        dropzoneClass,
      ]);

  String get resolvedListClass => _joinClasses(<String>[
        'list-group',
        listClass,
      ]);

  @HostBinding('class.d-block')
  bool get hostClass => true;

  void openPicker() {
    if (disabled) {
      return;
    }
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
    final nextFiles = List<html.File>.from(_files)..removeAt(index);
    _setFiles(nextFiles, emitToForm: true);
  }

  void clear() {
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
    if (incoming.isEmpty) {
      return;
    }

    final normalizedIncoming = multiple
        ? _mergeFiles(_files, incoming)
        : <html.File>[incoming.first];

    _setFiles(_applyMaxFiles(normalizedIncoming), emitToForm: true);
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
  }) {
    _files = List<html.File>.from(value);
    previewItems = _files.map((file) {
      final kind = LiFileType.getMimeClass(file);
      return LiFileUploadPreviewItem(
        file: file,
        kind: kind,
        kindLabel: _kindLabel(kind),
        sizeLabel: _formatBytes(file.size),
      );
    }).toList(growable: false);

    if (emitToForm) {
      final payload = List<html.File>.unmodifiable(_files);
      _filesChangeController.add(payload);
      _onChange(payload, rawValue: _files.length.toString());
      _onTouched();
    }
    _markForCheck();
  }

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

  @override
  void ngOnDestroy() {
    _filesChangeController.close();
  }
}
