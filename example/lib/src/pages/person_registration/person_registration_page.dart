import 'dart:convert';
import 'dart:html' as html;

import 'package:essential_core/essential_core.dart';
import 'package:limitless_ui_example/limitless_ui_example.dart';

import '../datatable/datatable_demo_service.dart';
import 'person_registration_demo_service.dart';

class PersonRegistrationFormState {
  String fullName = '';
  String preferredName = '';
  String cpf = '';
  String email = '';
  String phone = '';
  String password = '';
  String notes = '';
  DateTime? birthDate;
  Duration? preferredContactTime;
  DateTime? availabilityStart;
  DateTime? availabilityEnd;
  String personType = '';
  String departmentId = '';
  List<dynamic> skillIds = <dynamic>[];
  List<dynamic> reviewerIds = <dynamic>[];
  String workflowNode = '';
  int? expectedCompensationMinorUnits;
  String contactChannel = '';
  bool remoteEnabled = true;
  bool accessibilityNeeded = false;
  bool notificationsEnabled = true;
  bool publicProfile = false;
  bool acceptTerms = false;
  bool acceptPrivacy = false;
  List<html.File> attachments = <html.File>[];

  PersonRegistrationMockRequest toRequest() {
    return PersonRegistrationMockRequest(
      fullName: fullName,
      preferredName: preferredName,
      cpf: cpf,
      email: email,
      phone: phone,
      password: password,
      notes: notes,
      birthDate: birthDate,
      preferredContactTime: preferredContactTime,
      availabilityStart: availabilityStart,
      availabilityEnd: availabilityEnd,
      personType: personType,
      departmentId: departmentId,
      skillIds: skillIds.map((item) => '$item').toList(growable: false),
      reviewerIds: reviewerIds.map((item) => '$item').toList(growable: false),
      workflowNode: workflowNode,
      expectedCompensationMinorUnits: expectedCompensationMinorUnits,
      contactChannel: contactChannel,
      remoteEnabled: remoteEnabled,
      accessibilityNeeded: accessibilityNeeded,
      notificationsEnabled: notificationsEnabled,
      publicProfile: publicProfile,
      acceptTerms: acceptTerms,
      acceptPrivacy: acceptPrivacy,
      attachments: List<html.File>.from(attachments),
    );
  }
}

@Component(
  selector: 'person-registration-page',
  templateUrl: 'person_registration_page.html',
  styleUrls: ['person_registration_page.css'],
  directives: [
    coreDirectives,
    DemoPageBreadcrumbComponent,
    formDirectives,
    LiFormDirective,
    LiFormFieldDirective,
    LiCheckboxComponent,
    LiCheckboxGroupComponent,
    LiCurrencyInputComponent,
    LiDatePickerComponent,
    LiDateRangePickerComponent,
    LiDatatableSelectComponent,
    LiFileUploadComponent,
    LiHighlightComponent,
    LiInputComponent,
    LiMultiSelectComponent,
    LiRadioComponent,
    LiRadioGroupComponent,
    LiSelectComponent,
    LiTabsComponent,
    LiTabxDirective,
    LiTimePickerComponent,
    LiToastStackComponent,
    LiToggleComponent,
    LiTreeviewSelectComponent,
  ],
  providers: [ClassProvider(PersonRegistrationDemoService)],
)
class PersonRegistrationPageComponent implements OnInit {
  PersonRegistrationPageComponent(this.i18n, this._service)
      : _reviewerRecords = _buildReviewerRecords(i18n.isPortuguese),
        workflowNodes = _buildWorkflowNodes(i18n.isPortuguese),
        _reviewerDemoService = DatatableDemoService(
          _buildReviewerRecords(i18n.isPortuguese),
        );

  static final List<LiRule> _fullNameRulesPt = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = '${value ?? ''}'.trim();
        if (normalized.length >= 6) {
          return null;
        }
        return 'Informe nome e sobrenome com pelo menos 6 caracteres.';
      },
      code: 'fullName',
    ),
  ];
  static final List<LiRule> _fullNameRulesEn = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = '${value ?? ''}'.trim();
        if (normalized.length >= 6) {
          return null;
        }
        return 'Provide first and last name with at least 6 characters.';
      },
      code: 'fullName',
    ),
  ];
  static const List<LiRule> _requiredSelectionRules = <LiRule>[
    LiRule.required(),
  ];
  static final List<LiRule> _skillsRulesPt = <LiRule>[
    LiRule.custom(
      (value) {
        final selections = value is Iterable ? value.length : 0;
        if (selections >= 2) {
          return null;
        }
        return 'Selecione pelo menos duas skills.';
      },
      code: 'skills',
    ),
  ];
  static final List<LiRule> _skillsRulesEn = <LiRule>[
    LiRule.custom(
      (value) {
        final selections = value is Iterable ? value.length : 0;
        if (selections >= 2) {
          return null;
        }
        return 'Select at least two skills.';
      },
      code: 'skills',
    ),
  ];
  static final List<LiRule> _passwordRulesPt = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = '${value ?? ''}';
        final hasLength = normalized.trim().length >= 8;
        final hasLetter = RegExp(r'[A-Za-z]').hasMatch(normalized);
        final hasNumber = RegExp(r'\d').hasMatch(normalized);
        if (hasLength && hasLetter && hasNumber) {
          return null;
        }
        return 'Use pelo menos 8 caracteres com letras e numeros.';
      },
      code: 'password',
    ),
  ];
  static final List<LiRule> _passwordRulesEn = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = '${value ?? ''}';
        final hasLength = normalized.trim().length >= 8;
        final hasLetter = RegExp(r'[A-Za-z]').hasMatch(normalized);
        final hasNumber = RegExp(r'\d').hasMatch(normalized);
        if (hasLength && hasLetter && hasNumber) {
          return null;
        }
        return 'Use at least 8 characters with letters and numbers.';
      },
      code: 'password',
    ),
  ];
  static final List<LiRule> _notesRulesPt = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = '${value ?? ''}'.trim();
        if (normalized.length >= 20) {
          return null;
        }
        return 'Explique o contexto em pelo menos 20 caracteres.';
      },
      code: 'notes',
    ),
  ];
  static final List<LiRule> _notesRulesEn = <LiRule>[
    LiRule.custom(
      (value) {
        final normalized = '${value ?? ''}'.trim();
        if (normalized.length >= 20) {
          return null;
        }
        return 'Explain the context in at least 20 characters.';
      },
      code: 'notes',
    ),
  ];

  final DemoI18nService i18n;
  final PersonRegistrationDemoService _service;
  final List<Map<String, dynamic>> _reviewerRecords;
  final DatatableDemoService _reviewerDemoService;
  final List<TreeViewNode> workflowNodes;
  final LiToastService toastService = LiToastService();
  final JsonEncoder _jsonEncoder = const JsonEncoder.withIndent('  ');
  Messages get t => i18n.t;

  @ViewChild('personForm')
  LiFormDirective? personForm;

  static const String markupSnippet = '''
<div liForm #personForm="liForm">
  <div liFormField="fullName" [liFormFieldOrder]="10">
    <li-input
        label="Nome completo"
        liType="requiredText"
        [liRules]="fullNameRules"
        liValidationMode="submittedOrTouchedOrDirty"
        [(ngModel)]="draft.fullName"
        [locale]="validationLocale">
    </li-input>
  </div>

  <div liFormField="departmentId" [liFormFieldOrder]="20">
    <li-select
        [dataSource]="departmentOptions"
        labelKey="label"
        valueKey="id"
        [liRules]="requiredSelectionRules"
      liValidationMode="submittedOrTouchedOrDirty"
        [(ngModel)]="draft.departmentId"
        (modelChange)="onDepartmentModelChange(\$event)">
    </li-select>
  </div>

  <button type="button" (click)="validateFrontendOnly(personForm)">
    Validar front-end
  </button>
</div>''';

  static const String serviceSnippet = '''
final result = await personRegistrationDemoService.submit(
  PersonRegistrationMockRequest(
    fullName: draft.fullName,
    email: draft.email,
    departmentId: draft.departmentId,
    skillIds: draft.skillIds.cast<String>(),
    attachments: draft.attachments,
    acceptTerms: draft.acceptTerms,
    acceptPrivacy: draft.acceptPrivacy,
  ),
);

if (!result.success) {
  backendErrors = result.fieldErrors;
  backendMessages = result.generalErrors;
}''';

  final PersonRegistrationFormState draft = PersonRegistrationFormState();

  final List<Map<String, dynamic>> departmentOptions =
      const <Map<String, dynamic>>[
    <String, dynamic>{'id': 'operations', 'label': 'Operações'},
    <String, dynamic>{'id': 'product', 'label': 'Produto'},
    <String, dynamic>{'id': 'finance', 'label': 'Financeiro'},
    <String, dynamic>{'id': 'people', 'label': 'Pessoas e cultura'},
  ];

  final List<Map<String, dynamic>> skillOptions = const <Map<String, dynamic>>[
    <String, dynamic>{'id': 'support', 'label': 'Atendimento'},
    <String, dynamic>{'id': 'analytics', 'label': 'Analytics'},
    <String, dynamic>{'id': 'contracts', 'label': 'Contratos'},
    <String, dynamic>{'id': 'design', 'label': 'Design'},
    <String, dynamic>{'id': 'sensitive-data', 'label': 'Dados sensíveis'},
  ];

  final Filters reviewerFilter = Filters(limit: 5, offset: 0);
  DataFrame<Map<String, dynamic>> reviewerData =
      DataFrame<Map<String, dynamic>>(
          items: <Map<String, dynamic>>[], totalRecords: 0);
  late final DatatableSettings reviewerSettings = DatatableSettings(
    colsDefinitions: <DatatableCol>[
      DatatableCol(
        key: 'id',
        title: 'ID',
        enableSorting: true,
        sortingBy: 'id',
        width: '72px',
      ),
      DatatableCol(
        key: 'name',
        title: isPt ? 'Nome' : 'Name',
        enableSorting: true,
        sortingBy: 'name',
      ),
      DatatableCol(
        key: 'email',
        title: 'E-mail',
        enableSorting: true,
        sortingBy: 'email',
      ),
      DatatableCol(
        key: 'department',
        title: isPt ? 'Departamento' : 'Department',
        enableSorting: true,
        sortingBy: 'department',
      ),
    ],
  );
  late final List<DatatableSearchField> reviewerSearchFields =
      <DatatableSearchField>[
    DatatableSearchField(
      label: isPt ? 'Nome' : 'Name',
      field: 'name',
      operator: 'like',
      selected: true,
    ),
    DatatableSearchField(
      label: 'E-mail',
      field: 'email',
      operator: 'like',
    ),
    DatatableSearchField(
      label: isPt ? 'Departamento' : 'Department',
      field: 'department',
      operator: 'like',
    ),
  ];

  Map<String, dynamic>? selectedDepartmentModel;
  List<Map<String, dynamic>> selectedSkillModels = <Map<String, dynamic>>[];
  Map<String, String> frontendErrors = <String, String>{};
  Map<String, String> backendErrors = <String, String>{};
  List<String> backendMessages = <String>[];
  PersonRegistrationMockResult? lastResult;
  bool isSubmitting = false;

  @override
  Future<void> ngOnInit() async {
    await _loadReviewerData(reviewerFilter);
  }

  bool get isPt => i18n.isPortuguese;

  String get validationLocale => isPt ? 'pt_BR' : 'en_US';

  List<LiRule> get fullNameRules => isPt ? _fullNameRulesPt : _fullNameRulesEn;

  List<LiRule> get requiredSelectionRules => _requiredSelectionRules;

  List<LiRule> get skillsRules => isPt ? _skillsRulesPt : _skillsRulesEn;

  List<LiRule> get passwordRules => isPt ? _passwordRulesPt : _passwordRulesEn;

  List<LiRule> get notesRules => isPt ? _notesRulesPt : _notesRulesEn;
  late final List<LiRule> reviewerRules = <LiRule>[
    LiRule.custom(
      (value) {
        final total = value is Iterable ? value.length : 0;
        if (total > 0) {
          return null;
        }
        return isPt
            ? 'Selecione ao menos um responsável.'
            : 'Select at least one reviewer.';
      },
      code: 'reviewers',
    ),
  ];

  late final List<LiRule> workflowRules = <LiRule>[
    LiRule.required(),
  ];

  late final List<LiRule> attachmentRules = <LiRule>[
    LiRule.custom(
      (value) {
        final files = value is List<html.File>
            ? value
            : (value is Iterable
                ? value.whereType<html.File>().toList(growable: false)
                : const <html.File>[]);

        final hasPdf = files.any((file) {
          final name = file.name.toLowerCase();
          final type = file.type.toLowerCase();
          return name.endsWith('.pdf') || type.contains('pdf');
        });

        final hasImage = files.any((file) {
          final type = file.type.toLowerCase();
          final name = file.name.toLowerCase();
          return type.startsWith('image/') ||
              name.endsWith('.png') ||
              name.endsWith('.jpg') ||
              name.endsWith('.jpeg') ||
              name.endsWith('.webp');
        });

        if (draft.departmentId == 'finance' && !hasPdf) {
          return isPt
              ? 'Financeiro exige ao menos um PDF.'
              : 'Finance requires at least one PDF.';
        }

        if (draft.publicProfile && !hasImage) {
          return isPt
              ? 'Perfis públicos exigem pelo menos uma imagem.'
              : 'Public profiles require at least one image.';
        }

        return null;
      },
      code: 'attachments',
    ),
  ];

  String get pageTitle => isPt ? 'Forms' : 'Forms';
  String get pageSubtitle =>
      isPt ? 'Cadastro de pessoa' : 'Person registration';
  String get breadcrumb => isPt
      ? 'Formulário completo com validação'
      : 'Complete form with validation';
  String get overviewIntro => isPt
      ? 'Esta página junta `li-input`, selects, radios, toggles, date/time pickers e file upload em um cadastro completo com regras de frontend e um backend simulado.'
      : 'This page combines `li-input`, selects, radios, toggles, date/time pickers, and file upload into a complete registration flow with frontend rules and a simulated backend.';
  String get apiIntro => isPt
      ? 'O fluxo foi separado em duas camadas: validação imediata no host e uma chamada assíncrona para um service fake que devolve erros por campo.'
      : 'The flow is split into two layers: immediate host-side validation and an async call to a fake service that returns field-level errors.';

  String get fullNameLabel => isPt ? 'Nome completo' : 'Full name';
  String get preferredNameLabel => isPt ? 'Nome preferido' : 'Preferred name';
  String get cpfLabel => 'CPF';
  String get emailLabel => 'E-mail';
  String get phoneLabel => isPt ? 'Telefone' : 'Phone';
  String get passwordLabel => isPt ? 'Senha provisória' : 'Temporary password';
  String get birthDateLabel => isPt ? 'Data de nascimento' : 'Birth date';
  String get contactTimeLabel =>
      isPt ? 'Melhor horário para contato' : 'Best contact time';
  String get departmentLabel => isPt ? 'Departamento' : 'Department';
  String get skillsLabel => isPt ? 'Skills iniciais' : 'Initial skills';
  String get reviewerLabel =>
      isPt ? 'Responsáveis da frente' : 'Squad reviewers';
  String get workflowLabel => isPt ? 'Etapa do workflow' : 'Workflow stage';
  String get expectedCompensationLabel =>
      isPt ? 'Pretensão salarial' : 'Expected compensation';
  String get availabilityLabel =>
      isPt ? 'Janela de disponibilidade' : 'Availability window';
  String get notesLabel =>
      isPt ? 'Observações para o backend' : 'Backend notes';
  String get uploadsLabel => isPt ? 'Anexos opcionais' : 'Optional attachments';
  String get consentsLegend =>
      isPt ? 'Consentimentos obrigatórios' : 'Required consents';
  String get consentsError => isPt
      ? 'Aceite os dois consentimentos para concluir o cadastro.'
      : 'Accept both consents to complete the registration.';
  String get contactChannelLegend =>
      isPt ? 'Canal preferencial de contato' : 'Preferred contact channel';
  String get personTypeLegend => isPt ? 'Tipo de vínculo' : 'Relationship type';
  String get submitLabel =>
      isPt ? 'Enviar para backend simulado' : 'Submit to simulated backend';
  String get frontendOnlyLabel =>
      isPt ? 'Validar só front-end' : 'Validate frontend only';
  String get fillApprovedLabel =>
      isPt ? 'Preencher cenário aprovado' : 'Fill approved scenario';
  String get fillRejectedLabel =>
      isPt ? 'Preencher conflito backend' : 'Fill backend conflict';
  String get resetLabel => isPt ? 'Limpar formulário' : 'Reset form';
  String get summaryTitle => isPt ? 'Resumo vivo' : 'Live summary';
  String get backendRulesTitle =>
      isPt ? 'Regras do backend fake' : 'Fake backend rules';
  String get responseTitle =>
      isPt ? 'Última resposta do backend' : 'Latest backend response';
  String get payloadTitle =>
      isPt ? 'Payload normalizado do host' : 'Normalized host payload';
  String get statusReady =>
      isPt ? 'Pronto para validar e enviar.' : 'Ready to validate and send.';
  String get backendIdle =>
      isPt ? 'Nenhuma submissão executada ainda.' : 'No submission yet.';

  List<String> get backendRuleHints => isPt
      ? const <String>[
          'Use `duplicado@limitless.dev` para disparar conflito de e-mail.',
          'Use `111.111.111-11` para simular CPF bloqueado no backend.',
          'Escolha Financeiro sem PDF para ver erro server-side de anexo.',
          'Ative perfil público sem imagem para testar validação de upload.',
          'Escolha SMS e termine o telefone com `0000` para ver rejeição.',
          'Inclua a skill "Dados sensíveis" em prestador para erro de permissão.',
        ]
      : const <String>[
          'Use `duplicado@limitless.dev` to trigger an email conflict.',
          'Use `111.111.111-11` to simulate a blocked CPF in the backend.',
          'Pick Finance without a PDF to see a server-side attachment error.',
          'Enable public profile without an image to test upload validation.',
          'Choose SMS and end the phone with `0000` to trigger rejection.',
          'Add the "Sensitive data" skill to a contractor to trigger permission denial.',
        ];

  bool get hasConsentError => hasFieldError('consents');
  bool get hasPersonTypeError => hasFieldError('personType');
  bool get hasContactChannelError => hasFieldError('contactChannel');
  bool get hasAvailabilityError => hasFieldError('availability');
  bool get hasFrontendErrors => frontendErrors.isNotEmpty;
  bool get hasSuccessfulResponse => lastResult?.success == true;
  String get submitButtonLabel =>
      isSubmitting ? (isPt ? 'Enviando...' : 'Sending...') : submitLabel;

  String get selectedDepartmentLabel {
    final model = selectedDepartmentModel;
    if (model == null) {
      return isPt ? 'Não selecionado' : 'Not selected';
    }
    return '${model['label']} (${model['id']})';
  }

  String get selectedSkillsLabel {
    if (selectedSkillModels.isEmpty) {
      return isPt ? 'Nenhuma skill ainda.' : 'No skills yet.';
    }
    return selectedSkillModels.map((item) => item['label']).join(', ');
  }

  String get selectedReviewerLabel {
    if (draft.reviewerIds.isEmpty) {
      return isPt ? 'Nenhum responsável.' : 'No reviewers selected.';
    }

    final labels = _reviewerRecords
        .where((item) => draft.reviewerIds.contains(item['id']))
        .map((item) => '${item['name']}')
        .toList(growable: false);
    return labels.isEmpty ? draft.reviewerIds.join(', ') : labels.join(', ');
  }

  String get selectedWorkflowLabel {
    if (draft.workflowNode.trim().isEmpty) {
      return isPt ? 'Não definido' : 'Not defined';
    }

    return _findWorkflowLabel(workflowNodes, draft.workflowNode) ??
        draft.workflowNode;
  }

  String get expectedCompensationLabelText {
    final value = draft.expectedCompensationMinorUnits;
    return value == null ? (isPt ? 'Não definido' : 'Not defined') : '$value';
  }

  String get attachmentSummary {
    if (draft.attachments.isEmpty) {
      return isPt ? 'Sem anexos por enquanto.' : 'No attachments yet.';
    }
    return draft.attachments.map((file) => file.name).join(', ');
  }

  String get currentStatusLabel {
    if (isSubmitting) {
      return isPt
          ? 'Enviando para o backend fake...'
          : 'Sending to fake backend...';
    }
    if (hasFrontendErrors) {
      return isPt
          ? 'Existem pendências de frontend antes da submissão.'
          : 'There are frontend issues before submission.';
    }
    if (backendErrors.isNotEmpty || backendMessages.isNotEmpty) {
      return isPt
          ? 'O backend devolveu erros para revisão.'
          : 'The backend returned errors for review.';
    }
    if (hasSuccessfulResponse) {
      return isPt
          ? 'Último envio salvo com sucesso.'
          : 'Latest submission saved successfully.';
    }
    return statusReady;
  }

  String get payloadPreview {
    final payload = <String, dynamic>{
      'full_name': draft.fullName,
      'preferred_name': draft.preferredName,
      'cpf': draft.cpf,
      'email': draft.email,
      'phone': draft.phone,
      'birth_date': _formatDateIso(draft.birthDate),
      'preferred_contact_time': formatDuration(draft.preferredContactTime),
      'person_type': draft.personType,
      'department_id': draft.departmentId,
      'skill_ids': draft.skillIds,
      'reviewer_ids': draft.reviewerIds,
      'workflow_node': draft.workflowNode,
      'expected_compensation_minor_units': draft.expectedCompensationMinorUnits,
      'contact_channel': draft.contactChannel,
      'remote_enabled': draft.remoteEnabled,
      'accessibility_needed': draft.accessibilityNeeded,
      'notifications_enabled': draft.notificationsEnabled,
      'public_profile': draft.publicProfile,
      'availability_start': _formatDateIso(draft.availabilityStart),
      'availability_end': _formatDateIso(draft.availabilityEnd),
      'attachments': draft.attachments
          .map((file) => <String, dynamic>{
                'name': file.name,
                'type': file.type,
                'size': file.size,
              })
          .toList(growable: false),
    };
    return _jsonEncoder.convert(payload);
  }

  String get responsePreview {
    final result = lastResult;
    if (result == null) {
      return backendIdle;
    }
    if (!result.success) {
      return _jsonEncoder.convert(<String, dynamic>{
        'success': false,
        'field_errors': result.fieldErrors,
        'general_errors': result.generalErrors,
      });
    }
    return _jsonEncoder.convert(<String, dynamic>{
      'success': true,
      'person_id': result.personId,
      'protocol': result.protocol,
      'payload': result.normalizedPayload,
    });
  }

  void fillApprovedScenario() {
    draft
      ..fullName = 'Marina Costa'
      ..preferredName = 'Mari'
      ..cpf = '390.533.447-05'
      ..email = 'marina.costa@limitless.dev'
      ..phone = '(21) 99876-5432'
      ..password = 'Limitless2026'
      ..birthDate = DateTime(1994, 7, 11)
      ..preferredContactTime = const Duration(hours: 14, minutes: 30)
      ..personType = 'employee'
      ..departmentId = 'operations'
      ..skillIds = <dynamic>['support', 'analytics']
      ..reviewerIds = <dynamic>['2', '11']
      ..workflowNode = 'analise'
      ..expectedCompensationMinorUnits = 780000
      ..contactChannel = 'email'
      ..remoteEnabled = true
      ..accessibilityNeeded = false
      ..notificationsEnabled = true
      ..publicProfile = false
      ..availabilityStart = DateTime(2026, 4, 15)
      ..availabilityEnd = DateTime(2026, 5, 20)
      ..acceptTerms = true
      ..acceptPrivacy = true
      ..attachments = <html.File>[
        _createDemoFile(
          'curriculo-marina.pdf',
          'application/pdf',
          'Curriculo de aprovacao',
        ),
      ]
      ..notes =
          'Pessoa usada para demonstrar um envio aprovado com validações de frontend e backend.';
    selectedDepartmentModel = departmentOptions.firstWhere(
      (item) => item['id'] == draft.departmentId,
    );
    selectedSkillModels = skillOptions
        .where((item) => draft.skillIds.contains(item['id']))
        .toList(growable: false);
    _resetValidationState();
  }

  void fillBackendConflictScenario() {
    fillApprovedScenario();
    draft
      ..fullName = 'Usuario de Teste'
      ..email = 'duplicado@limitless.dev'
      ..cpf = '111.111.111-11'
      ..personType = 'contractor'
      ..departmentId = 'finance'
      ..skillIds = <dynamic>['contracts', 'sensitive-data']
      ..reviewerIds = <dynamic>['5']
      ..workflowNode = 'auxilio-aluguel'
      ..expectedCompensationMinorUnits = 1250000
      ..contactChannel = 'sms'
      ..phone = '(21) 99999-0000'
      ..publicProfile = true
      ..attachments = <html.File>[
        _createDemoFile(
          'comprovante-financeiro.pdf',
          'application/pdf',
          'Comprovante financeiro',
        ),
        _createDemoFile(
          'perfil-publico.png',
          'image/png',
          'preview image',
        ),
      ]
      ..notes =
          'Fluxo de teste com combinação proposital para disparar erros do backend.';
    selectedDepartmentModel = departmentOptions.firstWhere(
      (item) => item['id'] == draft.departmentId,
    );
    selectedSkillModels = skillOptions
        .where((item) => draft.skillIds.contains(item['id']))
        .toList(growable: false);
    _resetValidationState();
  }

  void resetForm() {
    draft
      ..fullName = ''
      ..preferredName = ''
      ..cpf = ''
      ..email = ''
      ..phone = ''
      ..password = ''
      ..notes = ''
      ..birthDate = null
      ..preferredContactTime = null
      ..availabilityStart = null
      ..availabilityEnd = null
      ..personType = ''
      ..departmentId = ''
      ..skillIds = <dynamic>[]
      ..reviewerIds = <dynamic>[]
      ..workflowNode = ''
      ..expectedCompensationMinorUnits = null
      ..contactChannel = ''
      ..remoteEnabled = true
      ..accessibilityNeeded = false
      ..notificationsEnabled = true
      ..publicProfile = false
      ..acceptTerms = false
      ..acceptPrivacy = false
      ..attachments = <html.File>[];
    selectedDepartmentModel = null;
    selectedSkillModels = <Map<String, dynamic>>[];
    lastResult = null;
    _resetValidationState();
  }

  void onDepartmentModelChange(dynamic model) {
    if (model is Map<String, dynamic>) {
      selectedDepartmentModel = model;
    } else {
      selectedDepartmentModel = null;
    }
    clearFieldError('departmentId');
  }

  void onSkillModelsChange(List<dynamic> models) {
    selectedSkillModels = models.whereType<Map<String, dynamic>>().toList();
    clearFieldError('skills');
  }

  Future<void> onReviewerDataRequest(Filters filters) async {
    reviewerFilter.fillFromFilters(filters);
    await _loadReviewerData(reviewerFilter);
  }

  void onReviewerIdsChange(dynamic value) {
    onFieldChange('reviewerIds', value);
  }

  void onWorkflowNodeChange(dynamic value) {
    onFieldChange('workflowNode', value);
  }

  void onExpectedCompensationChange(int? value) {
    onFieldChange(
        'expectedCompensationMinorUnits', value, 'expectedCompensation');
  }

  void onAvailabilityStartChange(DateTime? value) {
    draft.availabilityStart = value;
    clearFieldError('availability');
  }

  void onAvailabilityEndChange(DateTime? value) {
    draft.availabilityEnd = value;
    clearFieldError('availability');
  }

  void onBirthDateChange(DateTime? value) {
    draft.birthDate = value;
    clearFieldError('birthDate');
  }

  void onPreferredContactTimeChange(Duration? value) {
    draft.preferredContactTime = value;
    clearFieldError('preferredContactTime');
  }

  Future<void> validateFrontendOnly([LiFormDirective? formUi]) async {
    backendErrors = <String, String>{};
    backendMessages = <String>[];
    final errors = _runManualFrontendValidation();
    frontendErrors = errors;
    final automaticValid = await formUi?.validateAndFocusFirstInvalid() ?? true;
    if (errors.isEmpty && automaticValid) {
      toastService.show(
        header: isPt ? 'Frontend OK' : 'Frontend OK',
        body: isPt
            ? 'Nenhum erro encontrado no host. Agora você pode testar o backend simulado.'
            : 'No host-side errors were found. You can now test the simulated backend.',
        toastClass: 'bg-success text-white',
        delay: 3500,
      );
      return;
    }

    toastService.show(
      header: isPt ? 'Revisar formulário' : 'Review form',
      body: isPt
          ? 'Revise os campos destacados antes de continuar.'
          : 'Review the highlighted fields before continuing.',
      toastClass: 'bg-warning text-white border-0',
      delay: 4500,
    );
  }

  Future<void> submit([LiFormDirective? formUi]) async {
    backendErrors = <String, String>{};
    backendMessages = <String>[];
    final errors = _runManualFrontendValidation();
    frontendErrors = errors;
    final automaticValid = await formUi?.validateAndFocusFirstInvalid() ?? true;
    if (errors.isNotEmpty || !automaticValid) {
      toastService.show(
        header: isPt ? 'Envio bloqueado' : 'Submission blocked',
        body: isPt
            ? 'Corrija os campos destacados antes de consultar o backend fake.'
            : 'Fix the highlighted fields before calling the fake backend.',
        toastClass: 'bg-warning text-white border-0',
        delay: 4500,
      );
      return;
    }

    isSubmitting = true;
    try {
      final result = await _service.submit(draft.toRequest());
      lastResult = result;
      if (!result.success) {
        backendErrors = result.fieldErrors;
        backendMessages = result.generalErrors;
        toastService.show(
          header: isPt
              ? 'Backend rejeitou o cadastro'
              : 'Backend rejected the registration',
          body: isPt
              ? 'A resposta simulada devolveu ${result.fieldErrors.length} erro(s) de campo.'
              : 'The simulated response returned ${result.fieldErrors.length} field error(s).',
          toastClass: 'bg-danger text-white',
          delay: 5000,
        );
        return;
      }

      toastService.show(
        header: isPt ? 'Cadastro salvo' : 'Registration saved',
        body: isPt
            ? 'Pessoa ${result.personId} registrada com protocolo ${result.protocol}.'
            : 'Person ${result.personId} was saved with protocol ${result.protocol}.',
        toastClass: 'bg-success text-white',
        delay: 5000,
      );
    } finally {
      isSubmitting = false;
    }
  }

  bool hasFieldError(String field) => fieldError(field).trim().isNotEmpty;

  bool hasBackendError(String field) =>
      backendFieldError(field).trim().isNotEmpty;

  String fieldError(String field) {
    final frontend = frontendErrors[field];
    if (frontend != null && frontend.trim().isNotEmpty) {
      return frontend;
    }
    final backend = backendErrors[field];
    return backend?.trim() ?? '';
  }

  String backendFieldError(String field) => backendErrors[field]?.trim() ?? '';

  void clearFieldError(String field) {
    if (frontendErrors.containsKey(field)) {
      frontendErrors = Map<String, String>.from(frontendErrors)..remove(field);
    }
    if (backendErrors.containsKey(field)) {
      backendErrors = Map<String, String>.from(backendErrors)..remove(field);
    }
  }

  void onFieldChange(String field, dynamic value, [String? errorField]) {
    switch (field) {
      case 'fullName':
        draft.fullName = '$value';
        break;
      case 'cpf':
        draft.cpf = '$value';
        break;
      case 'email':
        draft.email = '$value';
        break;
      case 'phone':
        draft.phone = '$value';
        break;
      case 'password':
        draft.password = '$value';
        break;
      case 'personType':
        draft.personType = '$value';
        break;
      case 'departmentId':
        draft.departmentId = '$value';
        break;
      case 'skillIds':
        draft.skillIds =
            value is List ? List<dynamic>.from(value) : <dynamic>[];
        break;
      case 'reviewerIds':
        draft.reviewerIds =
            value is List ? List<dynamic>.from(value) : <dynamic>[];
        break;
      case 'workflowNode':
        draft.workflowNode = '$value';
        break;
      case 'expectedCompensationMinorUnits':
        draft.expectedCompensationMinorUnits = value is int ? value : null;
        break;
      case 'contactChannel':
        draft.contactChannel = '$value';
        break;
      case 'acceptTerms':
        draft.acceptTerms = value == true;
        break;
      case 'acceptPrivacy':
        draft.acceptPrivacy = value == true;
        break;
      case 'notes':
        draft.notes = '$value';
        break;
      case 'attachments':
        draft.attachments = value is List<html.File>
            ? List<html.File>.from(value)
            : <html.File>[];
        break;
    }
    clearFieldError(errorField ?? field);
  }

  List<String> get inlineMessages {
    if (backendMessages.isNotEmpty) {
      return backendMessages;
    }
    return const <String>[];
  }

  Map<String, String> _runManualFrontendValidation() {
    final errors = <String, String>{};

    final normalizedPhone = draft.phone.replaceAll(RegExp(r'\D'), '');

    final birthDate = draft.birthDate;
    if (birthDate == null) {
      errors['birthDate'] =
          isPt ? 'Selecione a data de nascimento.' : 'Select the birth date.';
    } else if (_calculateAge(birthDate) < 16) {
      errors['birthDate'] = isPt
          ? 'A demo exige idade mínima de 16 anos.'
          : 'The demo requires a minimum age of 16.';
    }

    if (draft.preferredContactTime == null) {
      errors['preferredContactTime'] = isPt
          ? 'Selecione um horário preferencial.'
          : 'Select a preferred time.';
    }

    if (draft.personType.trim().isEmpty) {
      errors['personType'] =
          isPt ? 'Escolha o tipo de vínculo.' : 'Choose the relationship type.';
    }

    if (draft.personType == 'contractor' &&
        draft.skillIds.contains('sensitive-data')) {
      errors['skills'] = isPt
          ? 'Prestador não pode receber a skill "Dados sensíveis".'
          : 'Contractors cannot receive the "Sensitive data" skill.';
    }

    if (draft.contactChannel.trim().isEmpty) {
      errors['contactChannel'] =
          isPt ? 'Escolha um canal de contato.' : 'Choose a contact channel.';
    } else if (draft.contactChannel == 'sms' &&
        normalizedPhone.length >= 4 &&
        normalizedPhone.endsWith('0000')) {
      errors['phone'] = isPt
          ? 'Telefone SMS não pode terminar com 0000.'
          : 'SMS phone numbers cannot end with 0000.';
    }

    if (draft.expectedCompensationMinorUnits == null ||
        draft.expectedCompensationMinorUnits! <= 0) {
      errors['expectedCompensation'] = isPt
          ? 'Informe a pretensão salarial.'
          : 'Provide the expected compensation.';
    }

    if (draft.availabilityStart == null || draft.availabilityEnd == null) {
      errors['availability'] = isPt
          ? 'Defina início e fim da disponibilidade.'
          : 'Define start and end availability.';
    } else if (!draft.availabilityEnd!.isAfter(draft.availabilityStart!)) {
      errors['availability'] = isPt
          ? 'A data final deve ser maior que a inicial.'
          : 'The end date must be after the start date.';
    }

    final hasPdf = draft.attachments.any((file) {
      final name = file.name.toLowerCase();
      final type = file.type.toLowerCase();
      return name.endsWith('.pdf') || type.contains('pdf');
    });
    final hasImage = draft.attachments.any((file) {
      final type = file.type.toLowerCase();
      final name = file.name.toLowerCase();
      return type.startsWith('image/') ||
          name.endsWith('.png') ||
          name.endsWith('.jpg') ||
          name.endsWith('.jpeg') ||
          name.endsWith('.webp');
    });

    if (draft.attachments.isEmpty) {
      errors['attachments'] =
          isPt ? 'Adicione ao menos um anexo.' : 'Add at least one attachment.';
    }

    if (draft.departmentId == 'finance' && !hasPdf) {
      errors['attachments'] = isPt
          ? 'Financeiro exige pelo menos um PDF.'
          : 'Finance requires at least one PDF.';
    }

    if (draft.publicProfile && !hasImage) {
      errors['attachments'] = errors.containsKey('attachments')
          ? '${errors['attachments']} ${isPt ? 'Perfis públicos exigem uma imagem.' : 'Public profiles require an image.'}'
          : (isPt
              ? 'Perfis públicos exigem uma imagem.'
              : 'Public profiles require an image.');
    }

    if (!draft.acceptTerms || !draft.acceptPrivacy) {
      errors['consents'] = consentsError;
    }

    return errors;
  }

  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    final hasBirthdayPassed = now.month > birthDate.month ||
        (now.month == birthDate.month && now.day >= birthDate.day);
    if (!hasBirthdayPassed) {
      age -= 1;
    }
    return age;
  }

  String formatDuration(Duration? value) {
    if (value == null) {
      return isPt ? 'Não definido' : 'Not defined';
    }
    final hours = value.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String? _formatDateIso(DateTime? value) {
    if (value == null) {
      return null;
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  html.File _createDemoFile(String name, String type, String content) {
    return html.File(<Object>[content], name, <String, Object>{'type': type});
  }

  void _clearAllErrors() {
    frontendErrors = <String, String>{};
    backendErrors = <String, String>{};
    backendMessages = <String>[];
  }

  void _resetValidationState() {
    personForm?.resetSubmissionState();
    _clearAllErrors();
  }

  Future<void> _loadReviewerData(Filters filters) async {
    reviewerData = await _reviewerDemoService.query(filters);
  }

  String? _findWorkflowLabel(List<TreeViewNode> nodes, dynamic value) {
    final normalized = '$value';
    for (final node in nodes) {
      if ('${node.value}' == normalized) {
        return node.treeViewNodeLabel;
      }

      final nested = _findWorkflowLabel(node.treeViewNodes, value);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  static List<Map<String, dynamic>> _buildReviewerRecords(bool isPt) {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'id': '1',
        'name': 'João Oliveira',
        'email': 'joao@example.com',
        'department': isPt ? 'Operações' : 'Operations',
      },
      <String, dynamic>{
        'id': '2',
        'name': 'Maria Silva',
        'email': 'maria@example.com',
        'department': 'Design',
      },
      <String, dynamic>{
        'id': '3',
        'name': 'Pedro Santos',
        'email': 'pedro@example.com',
        'department': 'Marketing',
      },
      <String, dynamic>{
        'id': '4',
        'name': 'Ana Costa',
        'email': 'ana@example.com',
        'department': isPt ? 'Produto' : 'Product',
      },
      <String, dynamic>{
        'id': '5',
        'name': 'Carlos Ferreira',
        'email': 'carlos@example.com',
        'department': isPt ? 'Financeiro' : 'Finance',
      },
      <String, dynamic>{
        'id': '11',
        'name': 'Bruno Pereira',
        'email': 'bruno@example.com',
        'department': isPt ? 'Operações' : 'Operations',
      },
    ];
  }

  static List<TreeViewNode> _buildWorkflowNodes(bool isPt) {
    final onboarding = TreeViewNode(
      treeViewNodeLabel: isPt ? 'Onboarding' : 'Onboarding',
      treeViewNodeLevel: 0,
      value: 'onboarding',
    );
    onboarding.addChild(TreeViewNode(
      treeViewNodeLabel: isPt ? 'Triagem inicial' : 'Initial triage',
      treeViewNodeLevel: 1,
      value: 'triagem',
    ));
    onboarding.addChild(TreeViewNode(
      treeViewNodeLabel: isPt ? 'Análise documental' : 'Document review',
      treeViewNodeLevel: 1,
      value: 'analise',
    ));

    final approvals = TreeViewNode(
      treeViewNodeLabel: isPt ? 'Aprovações' : 'Approvals',
      treeViewNodeLevel: 0,
      value: 'approvals',
    );
    approvals.addChild(TreeViewNode(
      treeViewNodeLabel: isPt ? 'Aprovação final' : 'Final approval',
      treeViewNodeLevel: 1,
      value: 'aprovado',
    ));
    approvals.addChild(TreeViewNode(
      treeViewNodeLabel: isPt ? 'Ajustes pendentes' : 'Pending adjustments',
      treeViewNodeLevel: 1,
      value: 'ajustes',
    ));

    return <TreeViewNode>[onboarding, approvals];
  }
}
