import 'dart:async';

import 'package:limitless_ui_example/limitless_ui_example.dart';

enum PdfViewerDemoValidationMode {
  quick,
  advanced,
}

class PdfViewerDemoSignatureEntry {
  const PdfViewerDemoSignatureEntry({
    required this.pageNumber,
    required this.label,
    this.signerName,
    this.reason,
    this.policyDisplay,
    this.valid,
  });

  final int pageNumber;
  final String label;
  final String? signerName;
  final String? reason;
  final String? policyDisplay;
  final bool? valid;
}

@Component(
  selector: 'pdf-viewer-signature-demo-panel',
  templateUrl: 'pdf_viewer_signature_demo_panel_component.html',
  styleUrls: ['pdf_viewer_signature_demo_panel_component.css'],
  directives: [coreDirectives],
  changeDetection: ChangeDetectionStrategy.onPush,
)
class PdfViewerSignatureDemoPanelComponent implements OnDestroy {
  PdfViewerSignatureDemoPanelComponent(this.i18n);

  final DemoI18nService i18n;

  bool get isPt => i18n.isPortuguese;

  @Input()
  PdfViewerDemoValidationMode activeMode = PdfViewerDemoValidationMode.quick;

  @Input()
  bool canRunAdvancedValidation = true;

  @Input()
  bool? documentIntact;

  @Input()
  String? signatureValidationSummary;

  @Input()
  String? signatureValidationElapsedLabel;

  @Input()
  List<PdfViewerDemoSignatureEntry> signatureEntries =
      const <PdfViewerDemoSignatureEntry>[];

  final StreamController<void> _quickValidationController =
      StreamController<void>.broadcast();
  final StreamController<void> _advancedValidationController =
      StreamController<void>.broadcast();
  final StreamController<PdfViewerDemoSignatureEntry> _entryOpenController =
      StreamController<PdfViewerDemoSignatureEntry>.broadcast();

  bool get isQuickValidationActive => activeMode == PdfViewerDemoValidationMode.quick;

  bool get isAdvancedValidationActive =>
      activeMode == PdfViewerDemoValidationMode.advanced;

  String get title => isPt ? 'Assinaturas' : 'Signatures';

  String get quickValidationLabel =>
      isPt ? 'Validação rápida' : 'Quick validation';

  String get advancedValidationLabel =>
      isPt ? 'Validação avançada' : 'Advanced validation';

  String get emptyStateLabel => isPt
      ? 'Escolha uma validação para exibir os detalhes das assinaturas.'
      : 'Choose a validation mode to display the signature details.';

  String get integrityOkLabel =>
      isPt ? 'Documento íntegro' : 'Document intact';

  String get integrityFailLabel => isPt
      ? 'Documento alterado ou corrompido após assinatura'
      : 'Document changed or corrupted after signing';

  String get pageLabel => isPt ? 'Página' : 'Page';

  String get signerLabel => isPt ? 'Assinante' : 'Signer';

  String get reasonLabel => isPt ? 'Motivo' : 'Reason';

  String get policyLabel => isPt ? 'Política' : 'Policy';

  String get approvedLabel =>
      isPt ? 'Assinatura aprovada' : 'Signature approved';

  String get invalidLabel =>
      isPt ? 'Assinatura inválida' : 'Signature invalid';

  String get elapsedPrefix =>
      isPt ? 'Tempo total da validação:' : 'Validation total time:';

  @Output()
  Stream<void> get quickValidation => _quickValidationController.stream;

  @Output()
  Stream<void> get advancedValidation => _advancedValidationController.stream;

  @Output()
  Stream<PdfViewerDemoSignatureEntry> get entryOpen =>
      _entryOpenController.stream;

  void emitQuickValidation() {
    _quickValidationController.add(null);
  }

  void emitAdvancedValidation() {
    _advancedValidationController.add(null);
  }

  void emitEntryOpen(PdfViewerDemoSignatureEntry entry) {
    _entryOpenController.add(entry);
  }

  @override
  void ngOnDestroy() {
    _quickValidationController.close();
    _advancedValidationController.close();
    _entryOpenController.close();
  }
}