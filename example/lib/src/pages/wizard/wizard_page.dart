import 'package:limitless_ui_example/limitless_ui_example.dart';

//import 'package:ngforms/ngforms.dart' show RadioButtonState;

@Component(
  selector: 'wizard-page',
  templateUrl: 'wizard_page.html',
  styleUrls: ['wizard_page.css'],
  directives: [
    coreDirectives,
    formDirectives,
    DemoPageBreadcrumbComponent,
    LiHighlightComponent,
    LiTabsComponent,
    LiTabxDirective,
    liWizardDirectives,
  ],
)
class WizardPageComponent {
  WizardPageComponent(this.i18n);

  static const String apiSnippet = '''
<li-wizard
  [previousLabel]="'Anterior'"
  [nextLabel]="'Próximo'"
  [finishLabel]="'Enviar'"
  [actionsTemplate]="wizardActionsTemplate"
  [beforeChange]="validateStep"
  (finish)="submitWizard(\$event)">
  <li-wizard-step
      title="Dados pessoais"
      [headerTemplate]="wizardStepHeaderTemplate">
    <input class="form-control" [(ngModel)]="name" name="name">
  </li-wizard-step>

  <li-wizard-step title="Confirmação" [error]="hasReviewError">
    <div class="alert alert-info">Revisão final</div>
  </li-wizard-step>
</li-wizard>''';

  final DemoI18nService i18n;

  // --- stable option lists (never rebuilt) ---

  final List<String> _locationsPt = const <String>[
    'Brasil',
    'Portugal',
    'Estados Unidos',
  ];
  final List<String> _locationsEn = const <String>[
    'Brazil',
    'Portugal',
    'United States',
  ];
  final List<String> _positionsPt = const <String>[
    'Analista de produto',
    'Desenvolvedor full stack',
    'Arquiteto de integrações',
    'Engenheiro de vendas',
  ];
  final List<String> _positionsEn = const <String>[
    'Product analyst',
    'Full stack developer',
    'Integration architect',
    'Sales Engineer',
  ];
  final List<String> _sourcesPt = const <String>[
    'Indicação interna',
    'LinkedIn',
    'Comunidade técnica',
    'Monster.com',
  ];
  final List<String> _sourcesEn = const <String>[
    'Internal referral',
    'LinkedIn',
    'Developer community',
    'Monster.com',
  ];
  final List<String> _monthsEn = const <String>[
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];
  final List<String> _monthsPt = const <String>[
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];
  final List<String> monthValues = const <String>[
    '01', '02', '03', '04', '05', '06',
    '07', '08', '09', '10', '11', '12',
  ];
  final List<String> days = const <String>[
    '1','2','3','4','5','6','7','8','9','10',
    '11','12','13','14','15','16','17','18','19','20',
    '21','22','23','24','25','26','27','28','29','30','31',
  ];
  final List<String> years = const <String>[
    '1980','1981','1982','1983','1984','1985','1986','1987','1988','1989',
    '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999',
    '2000','2001','2002','2003','2004','2005',
  ];

  // --- basic wizard fields ---

  String basicLocation = '';
  String basicPosition = '';
  String basicName = '';
  String basicEmail = '';
  String basicPhone = '';
  String basicBirthMonth = '01';
  String basicBirthDay = '1';
  String basicBirthYear = '1980';
  String basicDegree = '';
  String basicUniversity = '';
  String basicCompany = '';
  String basicRole = '';
  String basicDescription = '';
  String basicFromMonth = '01';
  String basicFromYear = '1995';
  String basicToMonth = '01';
  String basicToYear = '1995';
  String basicSource = '';
    RadioButtonState basicAvailabilityImmediate =
      RadioButtonState(false, 'immediate');
    RadioButtonState basicAvailabilityOneTwoWeeks =
      RadioButtonState(false, '1-2-weeks');
    RadioButtonState basicAvailabilityThreeFourWeeks =
      RadioButtonState(false, '3-4-weeks');
    RadioButtonState basicAvailabilityOneMonthPlus =
      RadioButtonState(false, '1-month-plus');
  String basicAdditionalInfo = '';
  String basicSummary = '';

  // --- validation wizard fields ---

  String validationLocation = '';
  String validationPosition = '';
  String validationName = '';
  String validationEmail = '';
  String validationPhone = '';
  String validationDegree = '';
  String validationUniversity = '';
  String validationCompany = '';
  String validationRole = '';
  String validationSource = '';
  String validationAvailability = '';
  String validationStatus = '';

  final List<bool> validationErrors = <bool>[false, false, false, false];

  bool get isPt => i18n.isPortuguese;

  Messages get t => i18n.t;

  List<String> get locationOptions => isPt ? _locationsPt : _locationsEn;

  List<String> get positionOptions => isPt ? _positionsPt : _positionsEn;

  List<String> get sourceOptions => isPt ? _sourcesPt : _sourcesEn;

  String get title => 'Wizard';

  String monthLabel(String monthValue) {
    final monthIndex = int.parse(monthValue) - 1;
    return isPt ? _monthsPt[monthIndex] : _monthsEn[monthIndex];
  }

  String get subtitle =>
      isPt ? 'Fluxos em etapas e formulários guiados' : 'Stepped flows and guided forms';

  String get breadcrumb => 'Wizard';

  String get overviewIntro => isPt
      ? 'li-wizard replica a estrutura visual do Limitless 4 para steps e form wizard sem depender do plugin jQuery original. O componente oferece navegação linear, clique em etapas já visitadas, bloqueio por validação e ações Previous/Next/Finish.'
      : 'li-wizard mirrors the Limitless 4 visual structure for steps and form wizards without depending on the original jQuery plugin. The component provides linear navigation, clicks on previously visited steps, validation guards, and Previous/Next/Finish actions.';

  String get descriptionBody => isPt
      ? 'Use li-wizard quando o fluxo exigir contexto progressivo, grupos de campos extensos ou checkpoints visuais com estados current, done e error.'
      : 'Use li-wizard when the flow needs progressive context, larger field groups, or visual checkpoints with current, done, and error states.';

  String get featureOne => isPt
      ? 'Markup compatível com as classes .wizard, .steps, .content e .actions do Limitless 4.'
      : 'Markup compatible with the .wizard, .steps, .content, and .actions classes from Limitless 4.';

  String get featureTwo => isPt
      ? 'Guards assíncronos ou síncronos via beforeChange e beforeFinish.'
      : 'Synchronous or asynchronous guards through beforeChange and beforeFinish.';

  String get featureThree => isPt
      ? 'Integração natural com ngModel e qualquer formulário projetado dentro das etapas.'
      : 'Natural integration with ngModel and any form projected inside the steps.';

  String get limitOne => isPt
      ? 'Não tenta reproduzir o plugin jQuery Steps inteiro nem recursos legados de AJAX embutido.'
      : 'It does not try to replicate the full jQuery Steps plugin or legacy built-in AJAX behavior.';

  String get limitTwo => isPt
      ? 'A validação é controlada pela aplicação consumidora; o componente apenas bloqueia a navegação.'
      : 'Validation stays in the consuming app; the component only blocks navigation.';

  String get limitThree => isPt
      ? 'Os rótulos e o conteúdo continuam totalmente customizáveis pela aplicação.'
      : 'Labels and content remain fully customizable by the consuming application.';

  String get apiIntro => isPt
      ? 'A API foi pensada para cobrir o fluxo mais comum do Limitless: steps horizontais com botões Previous/Next/Finish e bloqueio condicional por etapa.'
      : 'The API targets the most common Limitless flow: horizontal steps with Previous/Next/Finish buttons and conditional blocking per step.';

  String get basicSubmittedLabel => isPt ? 'Formulário enviado!' : 'Form submitted!';

  String get validationStatusLabel => isPt ? 'Status da validação:' : 'Validation status:';

  String wizardStepStateLabel(LiWizardStepHeaderContext context) {
    if (context.hasError) {
      return isPt ? 'Etapa com erro' : 'Step has error';
    }

    if (context.isDisabled) {
      return isPt ? 'Etapa desabilitada' : 'Step disabled';
    }

    if (context.isDone) {
      return isPt ? 'Etapa concluída' : 'Step completed';
    }

    if (context.isCurrent) {
      return isPt ? 'Etapa atual' : 'Current step';
    }

    return isPt ? 'Etapa pendente' : 'Pending step';
  }

  String wizardActionSummary(LiWizardActionsContext context) {
    if (context.isLastStep) {
      return isPt ? 'Última etapa pronta para envio' : 'Final step ready to submit';
    }

    return isPt
        ? 'Etapa ${context.activeIndex + 1} de ${context.stepCount}'
        : 'Step ${context.activeIndex + 1} of ${context.stepCount}';
  }

  Future<bool> handleValidationChange(int currentIndex, int targetIndex) async {
    if (targetIndex <= currentIndex) {
      return true;
    }

    return _validateStep(currentIndex);
  }

  Future<bool> handleValidationFinish(int currentIndex) async {
    return _validateStep(currentIndex);
  }

  void onBasicFinish(int currentIndex) {
    basicSummary = isPt
      ? 'Cadastro completo de $basicName para a posição $basicPosition.'
      : 'Registration complete for $basicName for position $basicPosition.';
  }

  void onValidationFinish(int currentIndex) {
    if (!_validateStep(currentIndex)) {
      return;
    }

    validationStatus = isPt
        ? 'Fluxo validado e pronto para envio.'
        : 'Flow validated and ready for submission.';
  }

  bool _validateStep(int stepIndex) {
    final isValid = switch (stepIndex) {
      0 =>
          validationLocation.trim().isNotEmpty &&
          validationPosition.trim().isNotEmpty &&
          validationName.trim().isNotEmpty &&
          validationEmail.trim().isNotEmpty,
      1 => validationDegree.trim().isNotEmpty && validationUniversity.trim().isNotEmpty,
      2 => validationCompany.trim().isNotEmpty && validationRole.trim().isNotEmpty,
      3 => validationSource.trim().isNotEmpty && validationAvailability.trim().isNotEmpty,
      _ => true,
    };

    validationErrors[stepIndex] = !isValid;
    validationStatus = isValid
        ? ''
        : (isPt
            ? 'Preencha os campos obrigatórios da etapa atual para continuar.'
            : 'Fill in the required fields on the current step before continuing.');
    return isValid;
  }
}
