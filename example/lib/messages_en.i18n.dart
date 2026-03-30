// GENERATED FILE, do not edit!
// ignore_for_file: annotate_overrides, non_constant_identifier_names, prefer_single_quotes, unused_element, unused_field
import 'package:i18n/i18n.dart' as i18n;
import 'messages.i18n.dart';

String get _languageCode => 'en';
String _plural(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) =>
    i18n.plural(
      count,
      _languageCode,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
    );
String _ordinal(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) =>
    i18n.ordinal(
      count,
      _languageCode,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
    );
String _cardinal(
  int count, {
  String? zero,
  String? one,
  String? two,
  String? few,
  String? many,
  String? other,
}) =>
    i18n.cardinal(
      count,
      _languageCode,
      zero: zero,
      one: one,
      two: two,
      few: few,
      many: many,
      other: other,
    );

class MessagesEn extends Messages {
  const MessagesEn();
  String get locale => "en";
  String get languageCode => "en";
  AppMessagesEn get app => AppMessagesEn(this);
  NavMessagesEn get nav => NavMessagesEn(this);
  CommonMessagesEn get common => CommonMessagesEn(this);
  PagesMessagesEn get pages => PagesMessagesEn(this);
}

class AppMessagesEn extends AppMessages {
  final MessagesEn _parent;
  const AppMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Limitless UI Example"
  /// ```
  String get brand => """Limitless UI Example""";

  /// ```dart
  /// "Live package documentation"
  /// ```
  String get searchPlaceholder => """Live package documentation""";

  /// ```dart
  /// "AngularDart + Limitless"
  /// ```
  String get badge => """AngularDart + Limitless""";

  /// ```dart
  /// "Navigation"
  /// ```
  String get navigation => """Navigation""";

  /// ```dart
  /// "Example with ngrouter and real package components."
  /// ```
  String get navigationHelp =>
      """Example with ngrouter and real package components.""";

  /// ```dart
  /// "Components"
  /// ```
  String get components => """Components""";

  /// ```dart
  /// "Language"
  /// ```
  String get language => """Language""";

  /// ```dart
  /// "Portuguese"
  /// ```
  String get portuguese => """Portuguese""";

  /// ```dart
  /// "English"
  /// ```
  String get english => """English""";

  /// ```dart
  /// "Theme"
  /// ```
  String get theme => """Theme""";

  /// ```dart
  /// "Light"
  /// ```
  String get light => """Light""";

  /// ```dart
  /// "Dark"
  /// ```
  String get dark => """Dark""";

  /// ```dart
  /// "Auto"
  /// ```
  String get auto => """Auto""";
}

class NavMessagesEn extends NavMessages {
  final MessagesEn _parent;
  const NavMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Overview"
  /// ```
  String get overview => """Overview""";

  /// ```dart
  /// "Alerts"
  /// ```
  String get alerts => """Alerts""";

  /// ```dart
  /// "Progress"
  /// ```
  String get progress => """Progress""";

  /// ```dart
  /// "Accordion"
  /// ```
  String get accordion => """Accordion""";

  /// ```dart
  /// "Tabs"
  /// ```
  String get tabs => """Tabs""";

  /// ```dart
  /// "Modal"
  /// ```
  String get modal => """Modal""";

  /// ```dart
  /// "Select"
  /// ```
  String get select => """Select""";

  /// ```dart
  /// "Multi Select"
  /// ```
  String get multiSelect => """Multi Select""";

  /// ```dart
  /// "Currency"
  /// ```
  String get currency => """Currency""";

  /// ```dart
  /// "Date Picker"
  /// ```
  String get datePicker => """Date Picker""";

  /// ```dart
  /// "Time Picker"
  /// ```
  String get timePicker => """Time Picker""";

  /// ```dart
  /// "Date Range"
  /// ```
  String get dateRange => """Date Range""";

  /// ```dart
  /// "Carousel"
  /// ```
  String get carousel => """Carousel""";

  /// ```dart
  /// "Tooltip"
  /// ```
  String get tooltip => """Tooltip""";

  /// ```dart
  /// "Datatable"
  /// ```
  String get datatable => """Datatable""";

  /// ```dart
  /// "Datatable Select"
  /// ```
  String get datatableSelect => """Datatable Select""";

  /// ```dart
  /// "Notification"
  /// ```
  String get notification => """Notification""";

  /// ```dart
  /// "Treeview"
  /// ```
  String get treeview => """Treeview""";

  /// ```dart
  /// "Helpers"
  /// ```
  String get helpers => """Helpers""";

  /// ```dart
  /// "Buttons"
  /// ```
  String get button => """Buttons""";
}

class CommonMessagesEn extends CommonMessages {
  final MessagesEn _parent;
  const CommonMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Restore alert"
  /// ```
  String get restoreAlert => """Restore alert""";

  /// ```dart
  /// "None"
  /// ```
  String get none => """None""";

  /// ```dart
  /// "Open"
  /// ```
  String get open => """Open""";

  /// ```dart
  /// "Close"
  /// ```
  String get close => """Close""";

  /// ```dart
  /// "Status"
  /// ```
  String get status => """Status""";

  /// ```dart
  /// "Current period"
  /// ```
  String get currentPeriod => """Current period""";

  /// ```dart
  /// "Restricted window"
  /// ```
  String get restrictedWindow => """Restricted window""";
}

class PagesMessagesEn extends PagesMessages {
  final MessagesEn _parent;
  const PagesMessagesEn(this._parent) : super(_parent);
  OverviewPagesMessagesEn get overview => OverviewPagesMessagesEn(this);
  AlertsPagesMessagesEn get alerts => AlertsPagesMessagesEn(this);
  AccordionPagesMessagesEn get accordion => AccordionPagesMessagesEn(this);
  ProgressPagesMessagesEn get progress => ProgressPagesMessagesEn(this);
  TabsPagesMessagesEn get tabs => TabsPagesMessagesEn(this);
  ModalPagesMessagesEn get modal => ModalPagesMessagesEn(this);
  SelectPagesMessagesEn get select => SelectPagesMessagesEn(this);
  MultiSelectPagesMessagesEn get multiSelect =>
      MultiSelectPagesMessagesEn(this);
  CurrencyPagesMessagesEn get currency => CurrencyPagesMessagesEn(this);
  DateRangePagesMessagesEn get dateRange => DateRangePagesMessagesEn(this);
  TimePickerPagesMessagesEn get timePicker => TimePickerPagesMessagesEn(this);
  DatePickerPagesMessagesEn get datePicker => DatePickerPagesMessagesEn(this);
  CarouselPagesMessagesEn get carousel => CarouselPagesMessagesEn(this);
  TooltipPagesMessagesEn get tooltip => TooltipPagesMessagesEn(this);
  DatatablePagesMessagesEn get datatable => DatatablePagesMessagesEn(this);
  NotificationPagesMessagesEn get notification =>
      NotificationPagesMessagesEn(this);
  TreeviewPagesMessagesEn get treeview => TreeviewPagesMessagesEn(this);
  HelpersPagesMessagesEn get helpers => HelpersPagesMessagesEn(this);
  ButtonPagesMessagesEn get button => ButtonPagesMessagesEn(this);
}

class OverviewPagesMessagesEn extends OverviewPagesMessages {
  final PagesMessagesEn _parent;
  const OverviewPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Overview"
  /// ```
  String get subtitle => """Overview""";

  /// ```dart
  /// "Library overview"
  /// ```
  String get breadcrumb => """Library overview""";

  /// ```dart
  /// "Executable gallery to document components and configurations"
  /// ```
  String get heroTitle =>
      """Executable gallery to document components and configurations""";

  /// ```dart
  /// "This example uses the Limitless theme in index.html, navigates with ngrouter, and renders real package components in scenarios closer to the product."
  /// ```
  String get heroLead =>
      """This example uses the Limitless theme in index.html, navigates with ngrouter, and renders real package components in scenarios closer to the product.""";

  /// ```dart
  /// "Components"
  /// ```
  String get statComponentsLabel => """Components""";

  /// ```dart
  /// "Executable examples using the real package API."
  /// ```
  String get statComponentsHelp =>
      """Executable examples using the real package API.""";

  /// ```dart
  /// "Theme"
  /// ```
  String get statThemeLabel => """Theme""";

  /// ```dart
  /// "Layout and classes aligned with Limitless CSS."
  /// ```
  String get statThemeHelp =>
      """Layout and classes aligned with Limitless CSS.""";

  /// ```dart
  /// "Navigation"
  /// ```
  String get statNavigationLabel => """Navigation""";

  /// ```dart
  /// "Explicit routes for each showcase section."
  /// ```
  String get statNavigationHelp =>
      """Explicit routes for each showcase section.""";

  /// ```dart
  /// "How the demo is organized"
  /// ```
  String get organizationTitle => """How the demo is organized""";

  /// ```dart
  /// "Feedback"
  /// ```
  String get feedbackTitle => """Feedback""";

  /// ```dart
  /// "Alerts and progress with visual variations and states."
  /// ```
  String get feedbackBody =>
      """Alerts and progress with visual variations and states.""";

  /// ```dart
  /// "Disclosure"
  /// ```
  String get disclosureTitle => """Disclosure""";

  /// ```dart
  /// "Accordion, tabs, and modal for expandable structures."
  /// ```
  String get disclosureBody =>
      """Accordion, tabs, and modal for expandable structures.""";

  /// ```dart
  /// "Inputs"
  /// ```
  String get inputsTitle => """Inputs""";

  /// ```dart
  /// "Selects, date picker, time picker, and date range picker bound to real state."
  /// ```
  String get inputsBody =>
      """Selects, date picker, time picker, and date range picker bound to real state.""";

  /// ```dart
  /// "Showcase"
  /// ```
  String get showcaseTitle => """Showcase""";

  /// ```dart
  /// "Carousel, tooltip, and datatable in an editorial layout."
  /// ```
  String get showcaseBody =>
      """Carousel, tooltip, and datatable in an editorial layout.""";

  /// ```dart
  /// "Featured pages"
  /// ```
  String get featureSectionTitle => """Featured pages""";

  /// ```dart
  /// "Direct links to real showcase pages instead of placeholder cards."
  /// ```
  String get featureSectionBody =>
      """Direct links to real showcase pages instead of placeholder cards.""";

  /// ```dart
  /// "Date Picker"
  /// ```
  String get featureDatePickerTitle => """Date Picker""";

  /// ```dart
  /// "Dedicated page with variations, API, and locale support for single-date selection."
  /// ```
  String get featureDatePickerBody =>
      """Dedicated page with variations, API, and locale support for single-date selection.""";

  /// ```dart
  /// "Time Picker"
  /// ```
  String get featureTimePickerTitle => """Time Picker""";

  /// ```dart
  /// "Time selection with dial, AM/PM, and ngModel integration."
  /// ```
  String get featureTimePickerBody =>
      """Time selection with dial, AM/PM, and ngModel integration.""";

  /// ```dart
  /// "Date Range"
  /// ```
  String get featureDateRangeTitle => """Date Range""";

  /// ```dart
  /// "Period flows with constraints, locale, and an API centered on start and end dates."
  /// ```
  String get featureDateRangeBody =>
      """Period flows with constraints, locale, and an API centered on start and end dates.""";

  /// ```dart
  /// "Carousel"
  /// ```
  String get featureCarouselTitle => """Carousel""";

  /// ```dart
  /// "Transitions, grid, captions, and examples closer to the original Limitless behavior."
  /// ```
  String get featureCarouselBody =>
      """Transitions, grid, captions, and examples closer to the original Limitless behavior.""";

  /// ```dart
  /// "Datatable"
  /// ```
  String get featureDatatableTitle => """Datatable""";

  /// ```dart
  /// "Search, selection, export, and view switching with real data interactions."
  /// ```
  String get featureDatatableBody =>
      """Search, selection, export, and view switching with real data interactions.""";

  /// ```dart
  /// "Select"
  /// ```
  String get featureSelectTitle => """Select""";

  /// ```dart
  /// "Simple select with projected-content and data-source examples."
  /// ```
  String get featureSelectBody =>
      """Simple select with projected-content and data-source examples.""";

  /// ```dart
  /// "Tabs"
  /// ```
  String get featureTabsTitle => """Tabs""";

  /// ```dart
  /// "Tabs and pills for organizing documentation and interface states."
  /// ```
  String get featureTabsBody =>
      """Tabs and pills for organizing documentation and interface states.""";

  /// ```dart
  /// "Accordion"
  /// ```
  String get featureAccordionTitle => """Accordion""";

  /// ```dart
  /// "Expandable items with lazy, destroyOnCollapse, and custom headers."
  /// ```
  String get featureAccordionBody =>
      """Expandable items with lazy, destroyOnCollapse, and custom headers.""";

  /// ```dart
  /// "Helpers"
  /// ```
  String get featureHelpersTitle => """Helpers""";

  /// ```dart
  /// "Loading, dialogs, toasts, and popovers ready to use."
  /// ```
  String get featureHelpersBody =>
      """Loading, dialogs, toasts, and popovers ready to use.""";
}

class AlertsPagesMessagesEn extends AlertsPagesMessages {
  final PagesMessagesEn _parent;
  const AlertsPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Alerts"
  /// ```
  String get subtitle => """Alerts""";

  /// ```dart
  /// "Alert variations"
  /// ```
  String get breadcrumb => """Alert variations""";

  /// ```dart
  /// "Visual range and states"
  /// ```
  String get cardTitle => """Visual range and states""";

  /// ```dart
  /// "This page demonstrates solid, dismissible, roundedPill, truncated, alertClass, iconContainerClass, textClass, closeButtonWhite, and events."
  /// ```
  String get intro =>
      """This page demonstrates solid, dismissible, roundedPill, truncated, alertClass, iconContainerClass, textClass, closeButtonWhite, and events.""";

  /// ```dart
  /// "Deploy completed."
  /// ```
  String get releaseDone => """Deploy completed.""";

  /// ```dart
  /// "The package is ready for validation."
  /// ```
  String get releaseBody => """The package is ready for validation.""";

  /// ```dart
  /// "Attention."
  /// ```
  String get attention => """Attention.""";

  /// ```dart
  /// "Use solid=true when you need maximum contrast."
  /// ```
  String get solidHelp => """Use solid=true when you need maximum contrast.""";

  /// ```dart
  /// "This example combines borderless, roundedPill, and an icon at the end of the text."
  /// ```
  String get borderlessHelp =>
      """This example combines borderless, roundedPill, and an icon at the end of the text.""";

  /// ```dart
  /// "This alert demonstrates custom classes on the container and icon block to match more editorial layouts without changing the base component markup."
  /// ```
  String get customHelp =>
      """This alert demonstrates custom classes on the container and icon block to match more editorial layouts without changing the base component markup.""";

  /// ```dart
  /// "Waiting for interaction with alerts."
  /// ```
  String get waiting => """Waiting for interaction with alerts.""";

  /// ```dart
  /// "Main alert restored."
  /// ```
  String get restored => """Main alert restored.""";

  /// ```dart
  /// "Main alert dismissed by the user."
  /// ```
  String get dismissed => """Main alert dismissed by the user.""";

  /// ```dart
  /// "visibleChange: alert visible."
  /// ```
  String get visible => """visibleChange: alert visible.""";

  /// ```dart
  /// "visibleChange: alert hidden."
  /// ```
  String get hidden => """visibleChange: alert hidden.""";
}

class AccordionPagesMessagesEn extends AccordionPagesMessages {
  final PagesMessagesEn _parent;
  const AccordionPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Accordion"
  /// ```
  String get subtitle => """Accordion""";

  /// ```dart
  /// "Expandable items"
  /// ```
  String get breadcrumb => """Expandable items""";

  /// ```dart
  /// "Accordion settings"
  /// ```
  String get cardTitle => """Accordion settings""";

  /// ```dart
  /// "This page covers allowMultipleOpen, flush, lazy, destroyOnCollapse, disabled item, icons, and custom header."
  /// ```
  String get intro =>
      """This page covers allowMultipleOpen, flush, lazy, destroyOnCollapse, disabled item, icons, and custom header.""";

  /// ```dart
  /// "Collapsed state"
  /// ```
  String get collapsedHeader => """Collapsed state""";

  /// ```dart
  /// "Starts closed and expands on demand."
  /// ```
  String get collapsedDescription => """Starts closed and expands on demand.""";

  /// ```dart
  /// "Ideal for long lists that need to preserve visual focus."
  /// ```
  String get collapsedBody =>
      """Ideal for long lists that need to preserve visual focus.""";

  /// ```dart
  /// "Expanded state"
  /// ```
  String get expandedHeader => """Expanded state""";

  /// ```dart
  /// "Initially open item."
  /// ```
  String get expandedDescription => """Initially open item.""";

  /// ```dart
  /// "Set expanded=true on the item that must open on load."
  /// ```
  String get expandedBody =>
      """Set expanded=true on the item that must open on load.""";

  /// ```dart
  /// "Disabled"
  /// ```
  String get disabledHeader => """Disabled""";

  /// ```dart
  /// "Does not react to clicks."
  /// ```
  String get disabledDescription => """Does not react to clicks.""";

  /// ```dart
  /// "This item demonstrates the disabled state."
  /// ```
  String get disabledBody => """This item demonstrates the disabled state.""";

  /// ```dart
  /// "Custom header"
  /// ```
  String get customHeader => """Custom header""";

  /// ```dart
  /// "Template with li-accordion-header."
  /// ```
  String get customDescription => """Template with li-accordion-header.""";

  /// ```dart
  /// "The header can be fully customized without losing the accordion structure."
  /// ```
  String get customBody =>
      """The header can be fully customized without losing the accordion structure.""";

  /// ```dart
  /// "template"
  /// ```
  String get templateBadge => """template""";

  /// ```dart
  /// "No accordion changed."
  /// ```
  String get idle => """No accordion changed.""";

  /// ```dart
  /// "expanded"
  /// ```
  String get expandedState => """expanded""";

  /// ```dart
  /// "collapsed"
  /// ```
  String get collapsedState => """collapsed""";
}

class ProgressPagesMessagesEn extends ProgressPagesMessages {
  final PagesMessagesEn _parent;
  const ProgressPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Progress"
  /// ```
  String get subtitle => """Progress""";

  /// ```dart
  /// "Simple and stacked bars"
  /// ```
  String get breadcrumb => """Simple and stacked bars""";

  /// ```dart
  /// "Progress states"
  /// ```
  String get cardTitle => """Progress states""";

  /// ```dart
  /// "Release pipeline"
  /// ```
  String get releasePipeline => """Release pipeline""";

  /// ```dart
  /// "Config: height, rounded, showValueLabel"
  /// ```
  String get releaseConfig => """Config: height, rounded, showValueLabel""";

  /// ```dart
  /// "Squad capacity"
  /// ```
  String get squadCapacity => """Squad capacity""";

  /// ```dart
  /// "Config: striped, animated, stacked bars"
  /// ```
  String get squadConfig => """Config: striped, animated, stacked bars""";

  /// ```dart
  /// "Product"
  /// ```
  String get teamProduct => """Product""";

  /// ```dart
  /// "Custom range"
  /// ```
  String get customRange => """Custom range""";

  /// ```dart
  /// "Config: min, max and text label"
  /// ```
  String get customConfig => """Config: min, max and text label""";
}

class TabsPagesMessagesEn extends TabsPagesMessages {
  final PagesMessagesEn _parent;
  const TabsPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Tabs"
  /// ```
  String get subtitle => """Tabs""";

  /// ```dart
  /// "Horizontal and vertical tabs"
  /// ```
  String get breadcrumb => """Horizontal and vertical tabs""";

  /// ```dart
  /// "Pills with custom header"
  /// ```
  String get cardTitle => """Pills with custom header""";

  /// ```dart
  /// "Tokens"
  /// ```
  String get tokens => """Tokens""";

  /// ```dart
  /// "Flow"
  /// ```
  String get flow => """Flow""";

  /// ```dart
  /// "Blocked"
  /// ```
  String get blocked => """Blocked""";

  /// ```dart
  /// "Use tabs to separate documentation, examples, and API notes."
  /// ```
  String get tokensBody =>
      """Use tabs to separate documentation, examples, and API notes.""";

  /// ```dart
  /// "The component respects Bootstrap and Limitless composition."
  /// ```
  String get flowBody =>
      """The component respects Bootstrap and Limitless composition.""";

  /// ```dart
  /// "Disabled tab."
  /// ```
  String get blockedBody => """Disabled tab.""";
}

class ModalPagesMessagesEn extends ModalPagesMessages {
  final PagesMessagesEn _parent;
  const ModalPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Modal"
  /// ```
  String get subtitle => """Modal""";

  /// ```dart
  /// "Dialogs and layout variations"
  /// ```
  String get breadcrumb => """Dialogs and layout variations""";

  /// ```dart
  /// "Modal examples"
  /// ```
  String get cardTitle => """Modal examples""";

  /// ```dart
  /// "Open modal"
  /// ```
  String get openModal => """Open modal""";

  /// ```dart
  /// "Scrollable modal"
  /// ```
  String get scrollableModal => """Scrollable modal""";

  /// ```dart
  /// "Modal example"
  /// ```
  String get modalTitle => """Modal example""";

  /// ```dart
  /// "Standardized composition"
  /// ```
  String get modalHeading => """Standardized composition""";

  /// ```dart
  /// "The modal reuses the Limitless visual layer and can host short forms, confirmations, or detailed views."
  /// ```
  String get modalBody =>
      """The modal reuses the Limitless visual layer and can host short forms, confirmations, or detailed views.""";

  /// ```dart
  /// "Scrollable modal"
  /// ```
  String get scrollableTitle => """Scrollable modal""";

  /// ```dart
  /// "This example uses dialogScrollable, fullScreenOnMobile, and disables backdrop close."
  /// ```
  String get scrollableBody =>
      """This example uses dialogScrollable, fullScreenOnMobile, and disables backdrop close.""";

  /// ```dart
  /// "Line $index to demonstrate internal modal scrolling while keeping the header fixed in the component standard structure."
  /// ```
  String scrollableLine(int index) =>
      """Line $index to demonstrate internal modal scrolling while keeping the header fixed in the component standard structure.""";

  /// ```dart
  /// "Understood"
  /// ```
  String get understood => """Understood""";
}

class SelectPagesMessagesEn extends SelectPagesMessages {
  final PagesMessagesEn _parent;
  const SelectPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Select"
  /// ```
  String get subtitle => """Select""";

  /// ```dart
  /// "Simple select"
  /// ```
  String get breadcrumb => """Simple select""";

  /// ```dart
  /// "Data source and content projection"
  /// ```
  String get cardTitle => """Data source and content projection""";

  /// ```dart
  /// "Delivery status"
  /// ```
  String get deliveryStatus => """Delivery status""";

  /// ```dart
  /// "Select with li-option"
  /// ```
  String get projectedTitle => """Select with li-option""";

  /// ```dart
  /// "Choose a level"
  /// ```
  String get projectedPlaceholder => """Choose a level""";

  /// ```dart
  /// "Projected status"
  /// ```
  String get projectedStatus => """Projected status""";

  /// ```dart
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Troubleshooting"
  /// ```
  String get tabTroubleshooting => """Troubleshooting""";

  /// ```dart
  /// "Most used inputs"
  /// ```
  String get apiInputs => """Most used inputs""";

  /// ```dart
  /// "Common issues seen in this component and how to avoid them"
  /// ```
  String get troubleshootingIntro =>
      """Common issues seen in this component and how to avoid them""";

  /// ```dart
  /// "Draft"
  /// ```
  String get optionDraft => """Draft""";

  /// ```dart
  /// "In review"
  /// ```
  String get optionReview => """In review""";

  /// ```dart
  /// "Approved"
  /// ```
  String get optionApproved => """Approved""";

  /// ```dart
  /// "Archived"
  /// ```
  String get optionArchived => """Archived""";

  /// ```dart
  /// "Priority"
  /// ```
  String get optionPriority => """Priority""";

  /// ```dart
  /// "Backlog"
  /// ```
  String get optionBacklog => """Backlog""";
}

class MultiSelectPagesMessagesEn extends MultiSelectPagesMessages {
  final PagesMessagesEn _parent;
  const MultiSelectPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Multi Select"
  /// ```
  String get subtitle => """Multi Select""";

  /// ```dart
  /// "Multiple selection"
  /// ```
  String get breadcrumb => """Multiple selection""";

  /// ```dart
  /// "Data source and li-multi-option"
  /// ```
  String get cardTitle => """Data source and li-multi-option""";

  /// ```dart
  /// "Notification channels"
  /// ```
  String get channels => """Notification channels""";

  /// ```dart
  /// "Projected targets"
  /// ```
  String get projectedTargets => """Projected targets""";

  /// ```dart
  /// "Select targets"
  /// ```
  String get projectedPlaceholder => """Select targets""";

  /// ```dart
  /// "Projected"
  /// ```
  String get projectedLabel => """Projected""";

  /// ```dart
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Troubleshooting"
  /// ```
  String get tabTroubleshooting => """Troubleshooting""";

  /// ```dart
  /// "Most used inputs"
  /// ```
  String get apiInputs => """Most used inputs""";

  /// ```dart
  /// "Important precautions to avoid regressions"
  /// ```
  String get troubleshootingIntro =>
      """Important precautions to avoid regressions""";

  /// ```dart
  /// "E-mail"
  /// ```
  String get optionEmail => """E-mail""";

  /// ```dart
  /// "Push"
  /// ```
  String get optionPush => """Push""";

  /// ```dart
  /// "SMS"
  /// ```
  String get optionSms => """SMS""";

  /// ```dart
  /// "Webhook"
  /// ```
  String get optionWebhook => """Webhook""";

  /// ```dart
  /// "Portal"
  /// ```
  String get optionPortal => """Portal""";

  /// ```dart
  /// "API"
  /// ```
  String get optionApi => """API""";

  /// ```dart
  /// "Batch process"
  /// ```
  String get optionBatch => """Batch process""";
}

class CurrencyPagesMessagesEn extends CurrencyPagesMessages {
  final PagesMessagesEn _parent;
  const CurrencyPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Currency Input"
  /// ```
  String get subtitle => """Currency Input""";

  /// ```dart
  /// "Monetary input in minor units"
  /// ```
  String get breadcrumb => """Monetary input in minor units""";

  /// ```dart
  /// "Brazilian format"
  /// ```
  String get cardTitle => """Brazilian format""";

  /// ```dart
  /// "Budget"
  /// ```
  String get budget => """Budget""";

  /// ```dart
  /// "Minor units"
  /// ```
  String get minorUnits => """Minor units""";

  /// ```dart
  /// "The value bound to ngModel is always emitted as an integer in cents."
  /// ```
  String get help =>
      """The value bound to ngModel is always emitted as an integer in cents.""";
}

class DateRangePagesMessagesEn extends DateRangePagesMessages {
  final PagesMessagesEn _parent;
  const DateRangePagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Date Range"
  /// ```
  String get subtitle => """Date Range""";

  /// ```dart
  /// "Period selection"
  /// ```
  String get breadcrumb => """Period selection""";

  /// ```dart
  /// "Free and constrained ranges"
  /// ```
  String get cardTitle => """Free and constrained ranges""";

  /// ```dart
  /// "Select the sprint period"
  /// ```
  String get sprintPlaceholder => """Select the sprint period""";

  /// ```dart
  /// "Publication window"
  /// ```
  String get publicationPlaceholder => """Publication window""";

  /// ```dart
  /// "Partial or undefined period"
  /// ```
  String get partial => """Partial or undefined period""";

  /// ```dart
  /// "Window not completed yet"
  /// ```
  String get unfinished => """Window not completed yet""";

  /// ```dart
  /// "The second example constrains the selection with minDate and maxDate."
  /// ```
  String get constrainedHelp =>
      """The second example constrains the selection with minDate and maxDate.""";

  /// ```dart
  /// "to"
  /// ```
  String get between => """to""";
}

class TimePickerPagesMessagesEn extends TimePickerPagesMessages {
  final PagesMessagesEn _parent;
  const TimePickerPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Time Picker"
  /// ```
  String get subtitle => """Time Picker""";

  /// ```dart
  /// "Time selection"
  /// ```
  String get breadcrumb => """Time selection""";

  /// ```dart
  /// "Time Picker API and variations"
  /// ```
  String get cardTitle => """Time Picker API and variations""";

  /// ```dart
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "The time picker uses a Limitless-inspired dial for hour and minute selection with ngModel integration."
  /// ```
  String get intro =>
      """The time picker uses a Limitless-inspired dial for hour and minute selection with ngModel integration.""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionTitle => """Description""";

  /// ```dart
  /// "The component fits scheduling, review, publishing, and operating-hour flows with a light, direct overlay."
  /// ```
  String get descriptionBody =>
      """The component fits scheduling, review, publishing, and operating-hour flows with a light, direct overlay.""";

  /// ```dart
  /// "Features"
  /// ```
  String get featuresTitle => """Features""";

  /// ```dart
  /// "Direct ngModel binding with Duration?."
  /// ```
  String get featureOne => """Direct ngModel binding with Duration?.""";

  /// ```dart
  /// "Clock-based selection switching between hour and minute."
  /// ```
  String get featureTwo =>
      """Clock-based selection switching between hour and minute.""";

  /// ```dart
  /// "Integrated AM/PM toggle inside the panel."
  /// ```
  String get featureThree => """Integrated AM/PM toggle inside the panel.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "The component currently works in a 12-hour AM/PM format."
  /// ```
  String get limitOne =>
      """The component currently works in a 12-hour AM/PM format.""";

  /// ```dart
  /// "It does not apply business window rules on its own."
  /// ```
  String get limitTwo =>
      """It does not apply business window rules on its own.""";

  /// ```dart
  /// "The returned value carries only hour and minute."
  /// ```
  String get limitThree =>
      """The returned value carries only hour and minute.""";

  /// ```dart
  /// "Default time picker"
  /// ```
  String get defaultTitle => """Default time picker""";

  /// ```dart
  /// "English time picker"
  /// ```
  String get englishTitle => """English time picker""";

  /// ```dart
  /// "Disabled time picker"
  /// ```
  String get disabledTitle => """Disabled time picker""";

  /// ```dart
  /// "Select time"
  /// ```
  String get placeholder => """Select time""";

  /// ```dart
  /// "Select time"
  /// ```
  String get englishPlaceholder => """Select time""";

  /// ```dart
  /// "Locked time"
  /// ```
  String get disabledPlaceholder => """Locked time""";

  /// ```dart
  /// "Current time"
  /// ```
  String get currentLabel => """Current time""";

  /// ```dart
  /// "Review time"
  /// ```
  String get reviewLabel => """Review time""";

  /// ```dart
  /// "Locked time"
  /// ```
  String get disabledLabel => """Locked time""";

  /// ```dart
  /// "Click the hour block first and the minute block next to refine the selection."
  /// ```
  String get defaultHelp =>
      """Click the hour block first and the minute block next to refine the selection.""";

  /// ```dart
  /// "Locale switches the placeholder and helper texts used by the panel."
  /// ```
  String get englishHelp =>
      """Locale switches the placeholder and helper texts used by the panel.""";

  /// ```dart
  /// "The field keeps displaying the value without opening the overlay."
  /// ```
  String get disabledHelp =>
      """The field keeps displaying the value without opening the overlay.""";

  /// ```dart
  /// "Usage notes"
  /// ```
  String get notesTitle => """Usage notes""";

  /// ```dart
  /// "The component returns a Duration normalized to the minutes of the day, which fits forms and filters without carrying a full date."
  /// ```
  String get notesBody =>
      """The component returns a Duration normalized to the minutes of the day, which fits forms and filters without carrying a full date.""";

  /// ```dart
  /// "No time selected"
  /// ```
  String get noneSelected => """No time selected""";

  /// ```dart
  /// "Use li-time-picker when the form needs only a time value, without an associated date, while keeping ngModel integration."
  /// ```
  String get apiIntro =>
      """Use li-time-picker when the form needs only a time value, without an associated date, while keeping ngModel integration.""";

  /// ```dart
  /// "Main inputs"
  /// ```
  String get apiInputsTitle => """Main inputs""";

  /// ```dart
  /// "The ngModel binding works with Duration?."
  /// ```
  String get apiInputOne => """The ngModel binding works with Duration?.""";

  /// ```dart
  /// "locale adjusts the placeholder and panel labels."
  /// ```
  String get apiInputTwo =>
      """locale adjusts the placeholder and panel labels.""";

  /// ```dart
  /// "disabled prevents opening the clock."
  /// ```
  String get apiInputThree => """disabled prevents opening the clock.""";

  /// ```dart
  /// "Behavior"
  /// ```
  String get apiBehaviorTitle => """Behavior""";

  /// ```dart
  /// "Click the clock to select the hour and then the minute."
  /// ```
  String get apiBehaviorOne =>
      """Click the clock to select the hour and then the minute.""";

  /// ```dart
  /// "The OK button confirms the selection and emits valueChange and ngModel."
  /// ```
  String get apiBehaviorTwo =>
      """The OK button confirms the selection and emits valueChange and ngModel.""";

  /// ```dart
  /// "AM and PM switch the half of the day without rebuilding the value manually."
  /// ```
  String get apiBehaviorThree =>
      """AM and PM switch the half of the day without rebuilding the value manually.""";

  /// ```dart
  /// """
  /// // Usage example
  /// selectedTime = const Duration(hours: 10, minutes: 48);
  ///
  /// <li-time-picker
  ///   [(ngModel)]="selectedTime"
  ///   locale="en_US">
  /// </li-time-picker>
  /// """
  /// ```
  String get apiUsageExample => """// Usage example
selectedTime = const Duration(hours: 10, minutes: 48);

<li-time-picker
  [(ngModel)]="selectedTime"
  locale="en_US">
</li-time-picker>
""";
}

class DatePickerPagesMessagesEn extends DatePickerPagesMessages {
  final PagesMessagesEn _parent;
  const DatePickerPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Date Picker"
  /// ```
  String get subtitle => """Date Picker""";

  /// ```dart
  /// "Single date selection"
  /// ```
  String get breadcrumb => """Single date selection""";

  /// ```dart
  /// "Date Picker API and variations"
  /// ```
  String get cardTitle => """Date Picker API and variations""";

  /// ```dart
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Variations"
  /// ```
  String get tabVariations => """Variations""";

  /// ```dart
  /// "This page is dedicated to li-date-picker, focusing on single-date flows, quick month/year navigation, locale, and common field states."
  /// ```
  String get intro =>
      """This page is dedicated to li-date-picker, focusing on single-date flows, quick month/year navigation, locale, and common field states.""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionTitle => """Description""";

  /// ```dart
  /// "The date picker fits single-date flows such as scheduling, publication, due dates, and punctual filters without mixing responsibilities with the range selector."
  /// ```
  String get descriptionBody =>
      """The date picker fits single-date flows such as scheduling, publication, due dates, and punctual filters without mixing responsibilities with the range selector.""";

  /// ```dart
  /// "Features"
  /// ```
  String get featuresTitle => """Features""";

  /// ```dart
  /// "Direct ngModel binding with DateTime?."
  /// ```
  String get featureOne => """Direct ngModel binding with DateTime?.""";

  /// ```dart
  /// "Restriction through minDate and maxDate."
  /// ```
  String get featureTwo => """Restriction through minDate and maxDate.""";

  /// ```dart
  /// "Immediate apply on day click."
  /// ```
  String get featureThree => """Immediate apply on day click.""";

  /// ```dart
  /// "Direct month and year navigation inside the overlay."
  /// ```
  String get featureFour =>
      """Direct month and year navigation inside the overlay.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "It does not replace specific business calendar rules."
  /// ```
  String get limitOne =>
      """It does not replace specific business calendar rules.""";

  /// ```dart
  /// "Special rules such as holidays and blocked dates still belong in the parent component."
  /// ```
  String get limitTwo =>
      """Special rules such as holidays and blocked dates still belong in the parent component.""";

  /// ```dart
  /// "Special dates and messages remain the parent component's responsibility."
  /// ```
  String get limitThree =>
      """Special dates and messages remain the parent component's responsibility.""";

  /// ```dart
  /// "Date picker with ngModel"
  /// ```
  String get ngModelTitle => """Date picker with ngModel""";

  /// ```dart
  /// "Restricted date picker"
  /// ```
  String get restrictedTitle => """Restricted date picker""";

  /// ```dart
  /// "Date picker in English"
  /// ```
  String get englishLocaleTitle => """Date picker in English""";

  /// ```dart
  /// "Disabled date picker"
  /// ```
  String get disabledTitle => """Disabled date picker""";

  /// ```dart
  /// "Select a date"
  /// ```
  String get placeholder => """Select a date""";

  /// ```dart
  /// "Allowed window"
  /// ```
  String get restrictedPlaceholder => """Allowed window""";

  /// ```dart
  /// "Choose a date"
  /// ```
  String get englishPlaceholder => """Choose a date""";

  /// ```dart
  /// "Locked field"
  /// ```
  String get disabledPlaceholder => """Locked field""";

  /// ```dart
  /// "Current date"
  /// ```
  String get currentDateLabel => """Current date""";

  /// ```dart
  /// "Restricted date"
  /// ```
  String get restrictedLabel => """Restricted date""";

  /// ```dart
  /// "EN date"
  /// ```
  String get englishLabel => """EN date""";

  /// ```dart
  /// "Locked value"
  /// ```
  String get disabledLabel => """Locked value""";

  /// ```dart
  /// "Click the calendar header to jump quickly between month and year."
  /// ```
  String get defaultHelp =>
      """Click the calendar header to jump quickly between month and year.""";

  /// ```dart
  /// "This example limits selection between minDate and maxDate."
  /// ```
  String get restrictedHelp =>
      """This example limits selection between minDate and maxDate.""";

  /// ```dart
  /// "Locale switches calendar labels and the displayed date format."
  /// ```
  String get englishHelp =>
      """Locale switches calendar labels and the displayed date format.""";

  /// ```dart
  /// "The field keeps the current value readable without opening the overlay."
  /// ```
  String get disabledHelp =>
      """The field keeps the current value readable without opening the overlay.""";

  /// ```dart
  /// "No date selected"
  /// ```
  String get noneSelected => """No date selected""";

  /// ```dart
  /// "Partial or undefined period"
  /// ```
  String get partialRange => """Partial or undefined period""";

  /// ```dart
  /// "Use li-date-picker when the flow depends on a single date with a light overlay, ngModel, locale, and basic constraints."
  /// ```
  String get apiIntro =>
      """Use li-date-picker when the flow depends on a single date with a light overlay, ngModel, locale, and basic constraints.""";

  /// ```dart
  /// "Main inputs"
  /// ```
  String get apiInputsTitle => """Main inputs""";

  /// ```dart
  /// "The [(ngModel)] binding works with DateTime?."
  /// ```
  String get apiInputOne => """The [(ngModel)] binding works with DateTime?.""";

  /// ```dart
  /// "[minDate] and [maxDate] constrain the navigable and selectable window."
  /// ```
  String get apiInputTwo =>
      """[minDate] and [maxDate] constrain the navigable and selectable window.""";

  /// ```dart
  /// "locale adjusts labels and the visual date format."
  /// ```
  String get apiInputThree =>
      """locale adjusts labels and the visual date format.""";

  /// ```dart
  /// "[disabled] prevents opening and selection."
  /// ```
  String get apiInputFour => """[disabled] prevents opening and selection.""";

  /// ```dart
  /// "Behavior"
  /// ```
  String get apiBehaviorTitle => """Behavior""";

  /// ```dart
  /// "Clicking a day applies immediately and closes the overlay."
  /// ```
  String get apiBehaviorOne =>
      """Clicking a day applies immediately and closes the overlay.""";

  /// ```dart
  /// "Clicking the calendar title cycles between day, month, and year views."
  /// ```
  String get apiBehaviorTwo =>
      """Clicking the calendar title cycles between day, month, and year views.""";

  /// ```dart
  /// "clear() remains available in the footer to reset the current value."
  /// ```
  String get apiBehaviorThree =>
      """clear() remains available in the footer to reset the current value.""";

  /// ```dart
  /// "valueChange and ngModel receive the normalized date without time."
  /// ```
  String get apiBehaviorFour =>
      """valueChange and ngModel receive the normalized date without time.""";

  /// ```dart
  /// """
  /// // Usage example
  /// selectedDate = DateTime(2026, 3, 20);
  ///
  /// <li-date-picker
  ///   [(ngModel)]="selectedDate"
  ///   [minDate]="DateTime(2026, 3, 1)"
  ///   [maxDate]="DateTime(2026, 3, 31)"
  ///   locale="en_US">
  /// </li-date-picker>
  /// """
  /// ```
  String get apiUsageExample => """// Usage example
selectedDate = DateTime(2026, 3, 20);

<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="DateTime(2026, 3, 1)"
  [maxDate]="DateTime(2026, 3, 31)"
  locale="en_US">
</li-date-picker>
""";

  /// ```dart
  /// "Default flow"
  /// ```
  String get variationStandardTitle => """Default flow""";

  /// ```dart
  /// "Best fit for forms where the user picks a date and moves on without extra confirmation."
  /// ```
  String get variationStandardBody =>
      """Best fit for forms where the user picks a date and moves on without extra confirmation.""";

  /// ```dart
  /// "Visual locale"
  /// ```
  String get variationLocaleTitle => """Visual locale""";

  /// ```dart
  /// "The same API switches labels, months, and displayed format between Portuguese and English."
  /// ```
  String get variationLocaleBody =>
      """The same API switches labels, months, and displayed format between Portuguese and English.""";

  /// ```dart
  /// "Locked state"
  /// ```
  String get variationDisabledTitle => """Locked state""";

  /// ```dart
  /// "Preserves the rendered value when the date is informative and cannot be edited."
  /// ```
  String get variationDisabledBody =>
      """Preserves the rendered value when the date is informative and cannot be edited.""";
}

class CarouselPagesMessagesEn extends CarouselPagesMessages {
  final PagesMessagesEn _parent;
  const CarouselPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Carousel"
  /// ```
  String get subtitle => """Carousel""";

  /// ```dart
  /// "Carousel with transitions, captions, and grid"
  /// ```
  String get breadcrumb => """Carousel with transitions, captions, and grid""";

  /// ```dart
  /// "Carousel variations"
  /// ```
  String get cardTitle => """Carousel variations""";

  /// ```dart
  /// "Example"
  /// ```
  String get exampleLabel => """Example""";

  /// ```dart
  /// "Carousel with Caption"
  /// ```
  String get standardTitle => """Carousel with Caption""";

  /// ```dart
  /// "Indicators and controls in the Limitless style, with a centered white caption inside each slide."
  /// ```
  String get standardSubtitle =>
      """Indicators and controls in the Limitless style, with a centered white caption inside each slide.""";

  /// ```dart
  /// "Carousel in Grid"
  /// ```
  String get gridTitle => """Carousel in Grid""";

  /// ```dart
  /// "You can have up to 12 items per slide using the Bootstrap grid, with row and col-* inside each carousel-item."
  /// ```
  String get gridSubtitle =>
      """You can have up to 12 items per slide using the Bootstrap grid, with row and col-* inside each carousel-item.""";

  /// ```dart
  /// "Architecture"
  /// ```
  String get slideOneLabel => """Architecture""";

  /// ```dart
  /// "First slide"
  /// ```
  String get slideOneTitle => """First slide""";

  /// ```dart
  /// "Small indicators at the bottom and side navigation in the Bootstrap/Limitless style."
  /// ```
  String get slideOneBody =>
      """Small indicators at the bottom and side navigation in the Bootstrap/Limitless style.""";

  /// ```dart
  /// "Composition"
  /// ```
  String get slideTwoLabel => """Composition""";

  /// ```dart
  /// "Second slide"
  /// ```
  String get slideTwoTitle => """Second slide""";

  /// ```dart
  /// "The caption uses the correct component class and respects the theme's centered positioning."
  /// ```
  String get slideTwoBody =>
      """The caption uses the correct component class and respects the theme's centered positioning.""";

  /// ```dart
  /// "Delivery"
  /// ```
  String get slideThreeLabel => """Delivery""";

  /// ```dart
  /// "Third slide"
  /// ```
  String get slideThreeTitle => """Third slide""";

  /// ```dart
  /// "Navigation stays consistent even with autoplay and manual changes."
  /// ```
  String get slideThreeBody =>
      """Navigation stays consistent even with autoplay and manual changes.""";

  /// ```dart
  /// "Reference"
  /// ```
  String get slideFourLabel => """Reference""";

  /// ```dart
  /// "Fourth slide"
  /// ```
  String get slideFourTitle => """Fourth slide""";

  /// ```dart
  /// "Structure equivalent to the classic example from components_carousel.html."
  /// ```
  String get slideFourBody =>
      """Structure equivalent to the classic example from components_carousel.html.""";

  /// ```dart
  /// "Collection 1"
  /// ```
  String get gridSlideOneLabel => """Collection 1""";

  /// ```dart
  /// "Collection 2"
  /// ```
  String get gridSlideTwoLabel => """Collection 2""";

  /// ```dart
  /// "Collection 3"
  /// ```
  String get gridSlideThreeLabel => """Collection 3""";

  /// ```dart
  /// "Editorial workspace"
  /// ```
  String get gridCardOneTitle => """Editorial workspace""";

  /// ```dart
  /// "Visual board for documents, highlights, and more narrative layouts."
  /// ```
  String get gridCardOneBody =>
      """Visual board for documents, highlights, and more narrative layouts.""";

  /// ```dart
  /// "Featured product"
  /// ```
  String get gridCardTwoTitle => """Featured product""";

  /// ```dart
  /// "Structure ready for card showcases, media, or campaigns."
  /// ```
  String get gridCardTwoBody =>
      """Structure ready for card showcases, media, or campaigns.""";

  /// ```dart
  /// "User journey"
  /// ```
  String get gridCardThreeTitle => """User journey""";

  /// ```dart
  /// "A slide can gather multiple entries without losing readability."
  /// ```
  String get gridCardThreeBody =>
      """A slide can gather multiple entries without losing readability.""";

  /// ```dart
  /// "Visual identity"
  /// ```
  String get gridCardFourTitle => """Visual identity""";

  /// ```dart
  /// "Larger images help validate contrast, crop, and overlay behavior."
  /// ```
  String get gridCardFourBody =>
      """Larger images help validate contrast, crop, and overlay behavior.""";

  /// ```dart
  /// "Composable modules"
  /// ```
  String get gridCardFiveTitle => """Composable modules""";

  /// ```dart
  /// "Carousel, Caption, and Grid work together without coupled markup."
  /// ```
  String get gridCardFiveBody =>
      """Carousel, Caption, and Grid work together without coupled markup.""";

  /// ```dart
  /// "Executable demo"
  /// ```
  String get gridCardSixTitle => """Executable demo""";

  /// ```dart
  /// "The showcase stops being static and starts showing real behavior."
  /// ```
  String get gridCardSixBody =>
      """The showcase stops being static and starts showing real behavior.""";

  /// ```dart
  /// "Expanded collection"
  /// ```
  String get gridCardSevenTitle => """Expanded collection""";

  /// ```dart
  /// "One more slide to validate indicators and continuous transition in the grid."
  /// ```
  String get gridCardSevenBody =>
      """One more slide to validate indicators and continuous transition in the grid.""";

  /// ```dart
  /// "Stable navigation"
  /// ```
  String get gridCardEightTitle => """Stable navigation""";

  /// ```dart
  /// "Side controls stay predictable because the row lives inside the item."
  /// ```
  String get gridCardEightBody =>
      """Side controls stay predictable because the row lives inside the item.""";

  /// ```dart
  /// "Correct structure"
  /// ```
  String get gridCardNineTitle => """Correct structure""";

  /// ```dart
  /// "The item remains the real slide; the grid is only internal content."
  /// ```
  String get gridCardNineBody =>
      """The item remains the real slide; the grid is only internal content.""";

  /// ```dart
  /// "Carousel with Fade"
  /// ```
  String get fadeTitle => """Carousel with Fade""";

  /// ```dart
  /// "Switches slides through opacity instead of lateral movement, useful for hero banners and caption-heavy content."
  /// ```
  String get fadeSubtitle =>
      """Switches slides through opacity instead of lateral movement, useful for hero banners and caption-heavy content.""";

  /// ```dart
  /// "Fade 1"
  /// ```
  String get fadeSlideOneLabel => """Fade 1""";

  /// ```dart
  /// "Editorial fade"
  /// ```
  String get fadeSlideOneTitle => """Editorial fade""";

  /// ```dart
  /// "The slide enters through opacity without competing for attention with horizontal movement."
  /// ```
  String get fadeSlideOneBody =>
      """The slide enters through opacity without competing for attention with horizontal movement.""";

  /// ```dart
  /// "Fade 2"
  /// ```
  String get fadeSlideTwoLabel => """Fade 2""";

  /// ```dart
  /// "Cleaner reading"
  /// ```
  String get fadeSlideTwoTitle => """Cleaner reading""";

  /// ```dart
  /// "Works well when the image already has a lot of texture and you want a more discreet transition."
  /// ```
  String get fadeSlideTwoBody =>
      """Works well when the image already has a lot of texture and you want a more discreet transition.""";

  /// ```dart
  /// "Fade 3"
  /// ```
  String get fadeSlideThreeLabel => """Fade 3""";

  /// ```dart
  /// "Smooth transition"
  /// ```
  String get fadeSlideThreeTitle => """Smooth transition""";

  /// ```dart
  /// "Controls, indicators, and autoplay stay the same; only the visual language of the transition changes."
  /// ```
  String get fadeSlideThreeBody =>
      """Controls, indicators, and autoplay stay the same; only the visual language of the transition changes.""";

  /// ```dart
  /// "Carousel with Zoom"
  /// ```
  String get zoomTitle => """Carousel with Zoom""";

  /// ```dart
  /// "Scale and opacity on entry for a more cinematic feeling without changing the component structure."
  /// ```
  String get zoomSubtitle =>
      """Scale and opacity on entry for a more cinematic feeling without changing the component structure.""";

  /// ```dart
  /// "Zoom 1"
  /// ```
  String get zoomSlideOneLabel => """Zoom 1""";

  /// ```dart
  /// "Zoom in"
  /// ```
  String get zoomSlideOneTitle => """Zoom in""";

  /// ```dart
  /// "The next slide enters at a larger scale and settles into the main plane by the end of the transition."
  /// ```
  String get zoomSlideOneBody =>
      """The next slide enters at a larger scale and settles into the main plane by the end of the transition.""";

  /// ```dart
  /// "Zoom 2"
  /// ```
  String get zoomSlideTwoLabel => """Zoom 2""";

  /// ```dart
  /// "Visual emphasis"
  /// ```
  String get zoomSlideTwoTitle => """Visual emphasis""";

  /// ```dart
  /// "A good variation for campaign showcases, portfolios, or more editorial screens."
  /// ```
  String get zoomSlideTwoBody =>
      """A good variation for campaign showcases, portfolios, or more editorial screens.""";

  /// ```dart
  /// "Zoom 3"
  /// ```
  String get zoomSlideThreeLabel => """Zoom 3""";

  /// ```dart
  /// "Same markup"
  /// ```
  String get zoomSlideThreeTitle => """Same markup""";

  /// ```dart
  /// "The API remains the same: the effect changes through input, without alternate item markup."
  /// ```
  String get zoomSlideThreeBody =>
      """The API remains the same: the effect changes through input, without alternate item markup.""";

  /// ```dart
  /// "Vertical Carousel"
  /// ```
  String get verticalTitle => """Vertical Carousel""";

  /// ```dart
  /// "The transition happens on the Y axis, useful when the page composition already has a lot of horizontal movement."
  /// ```
  String get verticalSubtitle =>
      """The transition happens on the Y axis, useful when the page composition already has a lot of horizontal movement.""";

  /// ```dart
  /// "Vertical 1"
  /// ```
  String get verticalSlideOneLabel => """Vertical 1""";

  /// ```dart
  /// "Vertical displacement"
  /// ```
  String get verticalSlideOneTitle => """Vertical displacement""";

  /// ```dart
  /// "The carousel behavior stays the same, but the perception changes completely."
  /// ```
  String get verticalSlideOneBody =>
      """The carousel behavior stays the same, but the perception changes completely.""";

  /// ```dart
  /// "Vertical 2"
  /// ```
  String get verticalSlideTwoLabel => """Vertical 2""";

  /// ```dart
  /// "Alternate flow"
  /// ```
  String get verticalSlideTwoTitle => """Alternate flow""";

  /// ```dart
  /// "This mode can pair better with column-based layouts and more documentary content."
  /// ```
  String get verticalSlideTwoBody =>
      """This mode can pair better with column-based layouts and more documentary content.""";

  /// ```dart
  /// "Vertical 3"
  /// ```
  String get verticalSlideThreeLabel => """Vertical 3""";

  /// ```dart
  /// "Consistent API"
  /// ```
  String get verticalSlideThreeTitle => """Consistent API""";

  /// ```dart
  /// "Just like zoom, the change is encapsulated in the component and can be reused on other screens."
  /// ```
  String get verticalSlideThreeBody =>
      """Just like zoom, the change is encapsulated in the component and can be reused on other screens.""";

  /// ```dart
  /// "Carousel with Blur"
  /// ```
  String get blurTitle => """Carousel with Blur""";

  /// ```dart
  /// "A transition with blur and opacity that softens the exchange between more detailed images."
  /// ```
  String get blurSubtitle =>
      """A transition with blur and opacity that softens the exchange between more detailed images.""";

  /// ```dart
  /// "Blur 1"
  /// ```
  String get blurSlideOneLabel => """Blur 1""";

  /// ```dart
  /// "Diffused entry"
  /// ```
  String get blurSlideOneTitle => """Diffused entry""";

  /// ```dart
  /// "The slide emerges with reduced blur and growing opacity, creating a more atmospheric change."
  /// ```
  String get blurSlideOneBody =>
      """The slide emerges with reduced blur and growing opacity, creating a more atmospheric change.""";

  /// ```dart
  /// "Blur 2"
  /// ```
  String get blurSlideTwoLabel => """Blur 2""";

  /// ```dart
  /// "Texture under control"
  /// ```
  String get blurSlideTwoTitle => """Texture under control""";

  /// ```dart
  /// "This mode works well when the photography has a lot of detail and pure fade feels too subtle."
  /// ```
  String get blurSlideTwoBody =>
      """This mode works well when the photography has a lot of detail and pure fade feels too subtle.""";

  /// ```dart
  /// "Blur 3"
  /// ```
  String get blurSlideThreeLabel => """Blur 3""";

  /// ```dart
  /// "Reusable variation"
  /// ```
  String get blurSlideThreeTitle => """Reusable variation""";

  /// ```dart
  /// "The effect remains encapsulated in the component and can be applied to any carousel through input."
  /// ```
  String get blurSlideThreeBody =>
      """The effect remains encapsulated in the component and can be applied to any carousel through input.""";

  /// ```dart
  /// "Carousel with Parallax"
  /// ```
  String get parallaxTitle => """Carousel with Parallax""";

  /// ```dart
  /// "Shifts the image with apparent depth, creating a more spatial transition between slides."
  /// ```
  String get parallaxSubtitle =>
      """Shifts the image with apparent depth, creating a more spatial transition between slides.""";

  /// ```dart
  /// "Parallax 1"
  /// ```
  String get parallaxSlideOneLabel => """Parallax 1""";

  /// ```dart
  /// "Lateral depth"
  /// ```
  String get parallaxSlideOneTitle => """Lateral depth""";

  /// ```dart
  /// "The slide enters with displacement and slightly larger scale, suggesting a moving background plane."
  /// ```
  String get parallaxSlideOneBody =>
      """The slide enters with displacement and slightly larger scale, suggesting a moving background plane.""";

  /// ```dart
  /// "Parallax 2"
  /// ```
  String get parallaxSlideTwoLabel => """Parallax 2""";

  /// ```dart
  /// "Editorial motion"
  /// ```
  String get parallaxSlideTwoTitle => """Editorial motion""";

  /// ```dart
  /// "This mode works well in visual showcases and pages where the image change should feel more physical."
  /// ```
  String get parallaxSlideTwoBody =>
      """This mode works well in visual showcases and pages where the image change should feel more physical.""";

  /// ```dart
  /// "Parallax 3"
  /// ```
  String get parallaxSlideThreeLabel => """Parallax 3""";

  /// ```dart
  /// "Subtle layers"
  /// ```
  String get parallaxSlideThreeTitle => """Subtle layers""";

  /// ```dart
  /// "The parallax feel stays subtle and reusable without requiring special item markup."
  /// ```
  String get parallaxSlideThreeBody =>
      """The parallax feel stays subtle and reusable without requiring special item markup.""";
}

class TooltipPagesMessagesEn extends TooltipPagesMessages {
  final PagesMessagesEn _parent;
  const TooltipPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Tooltip"
  /// ```
  String get subtitle => """Tooltip""";

  /// ```dart
  /// "Hover, click, and manual mode"
  /// ```
  String get breadcrumb => """Hover, click, and manual mode""";

  /// ```dart
  /// "Triggers and placement"
  /// ```
  String get cardTitle => """Triggers and placement""";

  /// ```dart
  /// "Shows hints on hover."
  /// ```
  String get hoverText => """Shows hints on hover.""";

  /// ```dart
  /// "Hover tooltip"
  /// ```
  String get hoverButton => """Hover tooltip""";

  /// ```dart
  /// "<strong>HTML</strong> also works with click trigger."
  /// ```
  String get clickText =>
      """<strong>HTML</strong> also works with click trigger.""";

  /// ```dart
  /// "Click tooltip"
  /// ```
  String get clickButton => """Click tooltip""";

  /// ```dart
  /// "Manual tooltip with programmatic control."
  /// ```
  String get manualText => """Manual tooltip with programmatic control.""";

  /// ```dart
  /// "Manual tooltip"
  /// ```
  String get manualButton => """Manual tooltip""";

  /// ```dart
  /// "No tooltip events yet."
  /// ```
  String get idle => """No tooltip events yet.""";

  /// ```dart
  /// "Tooltip: $label"
  /// ```
  String event(String label) => """Tooltip: $label""";
}

class DatatablePagesMessagesEn extends DatatablePagesMessages {
  final PagesMessagesEn _parent;
  const DatatablePagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Datatable"
  /// ```
  String get subtitle => """Datatable""";

  /// ```dart
  /// "Search, selection, and export"
  /// ```
  String get breadcrumb => """Search, selection, and export""";

  /// ```dart
  /// "Table operations"
  /// ```
  String get cardTitle => """Table operations""";

  /// ```dart
  /// "Toggle grid"
  /// ```
  String get toggleGrid => """Toggle grid""";

  /// ```dart
  /// "Single selection"
  /// ```
  String get singleSelection => """Single selection""";

  /// ```dart
  /// "Search sprint"
  /// ```
  String get searchLabel => """Search sprint""";

  /// ```dart
  /// "Type delivery, squad, or status"
  /// ```
  String get searchPlaceholder => """Type delivery, squad, or status""";

  /// ```dart
  /// "Delivery"
  /// ```
  String get featureCol => """Delivery""";

  /// ```dart
  /// "Squad"
  /// ```
  String get ownerCol => """Squad""";

  /// ```dart
  /// "Status"
  /// ```
  String get statusCol => """Status""";

  /// ```dart
  /// "Health"
  /// ```
  String get healthCol => """Health""";

  /// ```dart
  /// "Executive dashboard"
  /// ```
  String get featureRow1 => """Executive dashboard""";

  /// ```dart
  /// "PDF export"
  /// ```
  String get featureRow2 => """PDF export""";

  /// ```dart
  /// "Approval flow"
  /// ```
  String get featureRow3 => """Approval flow""";

  /// ```dart
  /// "Real-time alerts"
  /// ```
  String get featureRow4 => """Real-time alerts""";

  /// ```dart
  /// "Product"
  /// ```
  String get ownerProduct => """Product""";

  /// ```dart
  /// "Backoffice"
  /// ```
  String get ownerBackoffice => """Backoffice""";

  /// ```dart
  /// "Operations"
  /// ```
  String get ownerOperations => """Operations""";

  /// ```dart
  /// "Infra"
  /// ```
  String get ownerInfra => """Infra""";

  /// ```dart
  /// "In progress"
  /// ```
  String get statusInProgress => """In progress""";

  /// ```dart
  /// "Completed"
  /// ```
  String get statusDone => """Completed""";

  /// ```dart
  /// "Planned"
  /// ```
  String get statusPlanned => """Planned""";

  /// ```dart
  /// "Blocked"
  /// ```
  String get statusBlocked => """Blocked""";

  /// ```dart
  /// "Attention"
  /// ```
  String get healthWarning => """Attention""";

  /// ```dart
  /// "OK"
  /// ```
  String get healthOk => """OK""";

  /// ```dart
  /// "Critical"
  /// ```
  String get healthCritical => """Critical""";

  /// ```dart
  /// "Table ready for interaction."
  /// ```
  String get ready => """Table ready for interaction.""";

  /// ```dart
  /// "Datatable switched to grid mode."
  /// ```
  String get gridMode => """Datatable switched to grid mode.""";

  /// ```dart
  /// "Datatable switched to table mode."
  /// ```
  String get tableMode => """Datatable switched to table mode.""";

  /// ```dart
  /// "Single selection enabled."
  /// ```
  String get singleMode => """Single selection enabled.""";

  /// ```dart
  /// "Multiple selection enabled."
  /// ```
  String get multiMode => """Multiple selection enabled.""";

  /// ```dart
  /// "XLSX export triggered."
  /// ```
  String get exportXlsx => """XLSX export triggered.""";

  /// ```dart
  /// "PDF export triggered."
  /// ```
  String get exportPdf => """PDF export triggered.""";

  /// ```dart
  /// "Row clicked: $feature."
  /// ```
  String rowClicked(String feature) => """Row clicked: $feature.""";

  /// ```dart
  /// "Selected items: $count."
  /// ```
  String selectedItems(int count) => """Selected items: $count.""";
}

class NotificationPagesMessagesEn extends NotificationPagesMessages {
  final PagesMessagesEn _parent;
  const NotificationPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Notification Outlet"
  /// ```
  String get subtitle => """Notification Outlet""";

  /// ```dart
  /// "Fixed viewport toasts"
  /// ```
  String get breadcrumb => """Fixed viewport toasts""";

  /// ```dart
  /// "Trigger notifications"
  /// ```
  String get cardTitle => """Trigger notifications""";

  /// ```dart
  /// "With link"
  /// ```
  String get withLink => """With link""";

  /// ```dart
  /// "No notification triggered."
  /// ```
  String get idle => """No notification triggered.""";

  /// ```dart
  /// "Synchronization completed successfully."
  /// ```
  String get successMessage => """Synchronization completed successfully.""";

  /// ```dart
  /// "Event queue"
  /// ```
  String get successTitle => """Event queue""";

  /// ```dart
  /// "Success notification triggered."
  /// ```
  String get successState => """Success notification triggered.""";

  /// ```dart
  /// "There are items waiting for manual validation."
  /// ```
  String get warningMessage =>
      """There are items waiting for manual validation.""";

  /// ```dart
  /// "Attention"
  /// ```
  String get warningTitle => """Attention""";

  /// ```dart
  /// "Warning notification triggered."
  /// ```
  String get warningState => """Warning notification triggered.""";

  /// ```dart
  /// "Click to open the datatable demo."
  /// ```
  String get linkMessage => """Click to open the datatable demo.""";

  /// ```dart
  /// "Shortcut"
  /// ```
  String get linkTitle => """Shortcut""";

  /// ```dart
  /// "Notification with datatable link triggered."
  /// ```
  String get linkState => """Notification with datatable link triggered.""";
}

class TreeviewPagesMessagesEn extends TreeviewPagesMessages {
  final PagesMessagesEn _parent;
  const TreeviewPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Treeview"
  /// ```
  String get subtitle => """Treeview""";

  /// ```dart
  /// "Hierarchical structure"
  /// ```
  String get breadcrumb => """Hierarchical structure""";

  /// ```dart
  /// "Search, expand, and select"
  /// ```
  String get cardTitle => """Search, expand, and select""";

  /// ```dart
  /// "The treeview includes search, expand/collapse, and cascade selection."
  /// ```
  String get intro =>
      """The treeview includes search, expand/collapse, and cascade selection.""";

  /// ```dart
  /// "Search by module or status"
  /// ```
  String get searchPlaceholder => """Search by module or status""";

  /// ```dart
  /// "Service"
  /// ```
  String get nodeService => """Service""";

  /// ```dart
  /// "Triage"
  /// ```
  String get nodeTriage => """Triage""";

  /// ```dart
  /// "Referrals"
  /// ```
  String get nodeReferrals => """Referrals""";

  /// ```dart
  /// "Benefits"
  /// ```
  String get nodeBenefits => """Benefits""";

  /// ```dart
  /// "Food basket"
  /// ```
  String get nodeFoodBasket => """Food basket""";

  /// ```dart
  /// "Under review"
  /// ```
  String get nodeReview => """Under review""";

  /// ```dart
  /// "Approved"
  /// ```
  String get nodeApproved => """Approved""";

  /// ```dart
  /// "Rent aid"
  /// ```
  String get nodeRentAid => """Rent aid""";
}

class HelpersPagesMessagesEn extends HelpersPagesMessages {
  final PagesMessagesEn _parent;
  const HelpersPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Helpers"
  /// ```
  String get subtitle => """Helpers""";

  /// ```dart
  /// "Loading, dialogs, popovers, and toasts"
  /// ```
  String get breadcrumb => """Loading, dialogs, popovers, and toasts""";

  /// ```dart
  /// "SimpleLoading"
  /// ```
  String get loadingTitle => """SimpleLoading""";

  /// ```dart
  /// "Show overlay"
  /// ```
  String get showOverlay => """Show overlay""";

  /// ```dart
  /// "Loading target area"
  /// ```
  String get loadingTarget => """Loading target area""";

  /// ```dart
  /// "The overlay stays attached to the container."
  /// ```
  String get loadingTargetHelp =>
      """The overlay stays attached to the container.""";

  /// ```dart
  /// "Dialogs, toasts, and popovers"
  /// ```
  String get actionTitle => """Dialogs, toasts, and popovers""";

  /// ```dart
  /// "Dialog alert"
  /// ```
  String get dialogAlert => """Dialog alert""";

  /// ```dart
  /// "Dialog confirm"
  /// ```
  String get dialogConfirm => """Dialog confirm""";

  /// ```dart
  /// "Simple popover"
  /// ```
  String get simplePopover => """Simple popover""";

  /// ```dart
  /// "Sweet popover"
  /// ```
  String get sweetPopover => """Sweet popover""";

  /// ```dart
  /// "Simple success toast"
  /// ```
  String get simpleSuccessToast => """Simple success toast""";

  /// ```dart
  /// "Simple warning toast"
  /// ```
  String get simpleWarningToast => """Simple warning toast""";

  /// ```dart
  /// "Sweet success toast"
  /// ```
  String get sweetSuccessToast => """Sweet success toast""";

  /// ```dart
  /// "Sweet warning toast"
  /// ```
  String get sweetWarningToast => """Sweet warning toast""";

  /// ```dart
  /// "Use the buttons to trigger the static helpers."
  /// ```
  String get idle => """Use the buttons to trigger the static helpers.""";

  /// ```dart
  /// "Loading overlay shown for 2 seconds."
  /// ```
  String get loadingShown => """Loading overlay shown for 2 seconds.""";

  /// ```dart
  /// "Loading overlay finished."
  /// ```
  String get loadingHidden => """Loading overlay finished.""";

  /// ```dart
  /// "The operation has started and will be monitored in the background."
  /// ```
  String get dialogAlertBody =>
      """The operation has started and will be monitored in the background.""";

  /// ```dart
  /// "Execution started"
  /// ```
  String get dialogAlertTitle => """Execution started""";

  /// ```dart
  /// "SimpleDialog.showAlert executed."
  /// ```
  String get dialogAlertState => """SimpleDialog.showAlert executed.""";

  /// ```dart
  /// "Do you want to continue publishing this configuration?"
  /// ```
  String get dialogConfirmBody =>
      """Do you want to continue publishing this configuration?""";

  /// ```dart
  /// "Confirmation"
  /// ```
  String get dialogConfirmTitle => """Confirmation""";

  /// ```dart
  /// "Publish"
  /// ```
  String get dialogConfirmOk => """Publish""";

  /// ```dart
  /// "Cancel"
  /// ```
  String get dialogConfirmCancel => """Cancel""";

  /// ```dart
  /// "Positive confirmation returned true."
  /// ```
  String get dialogConfirmTrue => """Positive confirmation returned true.""";

  /// ```dart
  /// "Confirmation returned false."
  /// ```
  String get dialogConfirmFalse => """Confirmation returned false.""";

  /// ```dart
  /// "Simple popover anchored to the button using Bootstrap/Limitless markup."
  /// ```
  String get simplePopoverBody =>
      """Simple popover anchored to the button using Bootstrap/Limitless markup.""";

  /// ```dart
  /// "SimplePopover shown."
  /// ```
  String get simplePopoverState => """SimplePopover shown.""";

  /// ```dart
  /// "SweetAlert-based version with Popper overlay."
  /// ```
  String get sweetPopoverBody =>
      """SweetAlert-based version with Popper overlay.""";

  /// ```dart
  /// "Sweet popover"
  /// ```
  String get sweetPopoverTitle => """Sweet popover""";

  /// ```dart
  /// "SweetAlertPopover shown."
  /// ```
  String get sweetPopoverState => """SweetAlertPopover shown.""";

  /// ```dart
  /// "Simple success toast shown."
  /// ```
  String get simpleSuccessBody => """Simple success toast shown.""";

  /// ```dart
  /// "SimpleToast.showSuccess executed."
  /// ```
  String get simpleSuccessState => """SimpleToast.showSuccess executed.""";

  /// ```dart
  /// "Simple warning toast shown."
  /// ```
  String get simpleWarningBody => """Simple warning toast shown.""";

  /// ```dart
  /// "SimpleToast.showWarning executed."
  /// ```
  String get simpleWarningState => """SimpleToast.showWarning executed.""";

  /// ```dart
  /// "SweetAlert success toast shown."
  /// ```
  String get sweetSuccessBody => """SweetAlert success toast shown.""";

  /// ```dart
  /// "SweetAlertSimpleToast.showSuccessToast executed."
  /// ```
  String get sweetSuccessState =>
      """SweetAlertSimpleToast.showSuccessToast executed.""";

  /// ```dart
  /// "SweetAlert warning toast shown."
  /// ```
  String get sweetWarningBody => """SweetAlert warning toast shown.""";

  /// ```dart
  /// "SweetAlertSimpleToast.showWarningToast executed."
  /// ```
  String get sweetWarningState =>
      """SweetAlertSimpleToast.showWarningToast executed.""";
}

class ButtonPagesMessagesEn extends ButtonPagesMessages {
  final PagesMessagesEn _parent;
  const ButtonPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Buttons"
  /// ```
  String get subtitle => """Buttons""";

  /// ```dart
  /// "Button styles and variations"
  /// ```
  String get breadcrumb => """Button styles and variations""";

  /// ```dart
  /// "Button colors"
  /// ```
  String get colorsTitle => """Button colors""";

  /// ```dart
  /// "Preset color options for buttons"
  /// ```
  String get colorsSubtitle => """Preset color options for buttons""";

  /// ```dart
  /// "Solid buttons"
  /// ```
  String get solidTitle => """Solid buttons""";

  /// ```dart
  /// "Buttons with a solid background color"
  /// ```
  String get solidSubtitle => """Buttons with a solid background color""";

  /// ```dart
  /// "Outline buttons"
  /// ```
  String get outlineTitle => """Outline buttons""";

  /// ```dart
  /// "Buttons with a transparent background by default"
  /// ```
  String get outlineSubtitle =>
      """Buttons with a transparent background by default""";

  /// ```dart
  /// "Flat buttons"
  /// ```
  String get flatTitle => """Flat buttons""";

  /// ```dart
  /// "Buttons with a semi-transparent background"
  /// ```
  String get flatSubtitle => """Buttons with a semi-transparent background""";

  /// ```dart
  /// "Link buttons"
  /// ```
  String get linkTitle => """Link buttons""";

  /// ```dart
  /// "Buttons with text link styling"
  /// ```
  String get linkSubtitle => """Buttons with text link styling""";

  /// ```dart
  /// "Button sizes"
  /// ```
  String get sizesTitle => """Button sizes""";

  /// ```dart
  /// "Buttons in large, default, and small sizes"
  /// ```
  String get sizesSubtitle => """Buttons in large, default, and small sizes""";

  /// ```dart
  /// "Icon alignment"
  /// ```
  String get alignTitle => """Icon alignment""";

  /// ```dart
  /// "Examples of left and right icon alignment"
  /// ```
  String get alignSubtitle => """Examples of left and right icon alignment""";

  /// ```dart
  /// "Disabled buttons"
  /// ```
  String get disabledTitle => """Disabled buttons""";

  /// ```dart
  /// "Buttons in the disabled state"
  /// ```
  String get disabledSubtitle => """Buttons in the disabled state""";
}

Map<String, String> get messagesEnMap => {
      """app.brand""": """Limitless UI Example""",
      """app.searchPlaceholder""": """Live package documentation""",
      """app.badge""": """AngularDart + Limitless""",
      """app.navigation""": """Navigation""",
      """app.navigationHelp""":
          """Example with ngrouter and real package components.""",
      """app.components""": """Components""",
      """app.language""": """Language""",
      """app.portuguese""": """Portuguese""",
      """app.english""": """English""",
      """app.theme""": """Theme""",
      """app.light""": """Light""",
      """app.dark""": """Dark""",
      """app.auto""": """Auto""",
      """nav.overview""": """Overview""",
      """nav.alerts""": """Alerts""",
      """nav.progress""": """Progress""",
      """nav.accordion""": """Accordion""",
      """nav.tabs""": """Tabs""",
      """nav.modal""": """Modal""",
      """nav.select""": """Select""",
      """nav.multiSelect""": """Multi Select""",
      """nav.currency""": """Currency""",
      """nav.datePicker""": """Date Picker""",
      """nav.timePicker""": """Time Picker""",
      """nav.dateRange""": """Date Range""",
      """nav.carousel""": """Carousel""",
      """nav.tooltip""": """Tooltip""",
      """nav.datatable""": """Datatable""",
      """nav.datatableSelect""": """Datatable Select""",
      """nav.notification""": """Notification""",
      """nav.treeview""": """Treeview""",
      """nav.helpers""": """Helpers""",
      """nav.button""": """Buttons""",
      """common.restoreAlert""": """Restore alert""",
      """common.none""": """None""",
      """common.open""": """Open""",
      """common.close""": """Close""",
      """common.status""": """Status""",
      """common.currentPeriod""": """Current period""",
      """common.restrictedWindow""": """Restricted window""",
      """pages.overview.title""": """Components""",
      """pages.overview.subtitle""": """Overview""",
      """pages.overview.breadcrumb""": """Library overview""",
      """pages.overview.heroTitle""":
          """Executable gallery to document components and configurations""",
      """pages.overview.heroLead""":
          """This example uses the Limitless theme in index.html, navigates with ngrouter, and renders real package components in scenarios closer to the product.""",
      """pages.overview.statComponentsLabel""": """Components""",
      """pages.overview.statComponentsHelp""":
          """Executable examples using the real package API.""",
      """pages.overview.statThemeLabel""": """Theme""",
      """pages.overview.statThemeHelp""":
          """Layout and classes aligned with Limitless CSS.""",
      """pages.overview.statNavigationLabel""": """Navigation""",
      """pages.overview.statNavigationHelp""":
          """Explicit routes for each showcase section.""",
      """pages.overview.organizationTitle""": """How the demo is organized""",
      """pages.overview.feedbackTitle""": """Feedback""",
      """pages.overview.feedbackBody""":
          """Alerts and progress with visual variations and states.""",
      """pages.overview.disclosureTitle""": """Disclosure""",
      """pages.overview.disclosureBody""":
          """Accordion, tabs, and modal for expandable structures.""",
      """pages.overview.inputsTitle""": """Inputs""",
      """pages.overview.inputsBody""":
          """Selects, date picker, time picker, and date range picker bound to real state.""",
      """pages.overview.showcaseTitle""": """Showcase""",
      """pages.overview.showcaseBody""":
          """Carousel, tooltip, and datatable in an editorial layout.""",
      """pages.overview.featureSectionTitle""": """Featured pages""",
      """pages.overview.featureSectionBody""":
          """Direct links to real showcase pages instead of placeholder cards.""",
      """pages.overview.featureDatePickerTitle""": """Date Picker""",
      """pages.overview.featureDatePickerBody""":
          """Dedicated page with variations, API, and locale support for single-date selection.""",
      """pages.overview.featureTimePickerTitle""": """Time Picker""",
      """pages.overview.featureTimePickerBody""":
          """Time selection with dial, AM/PM, and ngModel integration.""",
      """pages.overview.featureDateRangeTitle""": """Date Range""",
      """pages.overview.featureDateRangeBody""":
          """Period flows with constraints, locale, and an API centered on start and end dates.""",
      """pages.overview.featureCarouselTitle""": """Carousel""",
      """pages.overview.featureCarouselBody""":
          """Transitions, grid, captions, and examples closer to the original Limitless behavior.""",
      """pages.overview.featureDatatableTitle""": """Datatable""",
      """pages.overview.featureDatatableBody""":
          """Search, selection, export, and view switching with real data interactions.""",
      """pages.overview.featureSelectTitle""": """Select""",
      """pages.overview.featureSelectBody""":
          """Simple select with projected-content and data-source examples.""",
      """pages.overview.featureTabsTitle""": """Tabs""",
      """pages.overview.featureTabsBody""":
          """Tabs and pills for organizing documentation and interface states.""",
      """pages.overview.featureAccordionTitle""": """Accordion""",
      """pages.overview.featureAccordionBody""":
          """Expandable items with lazy, destroyOnCollapse, and custom headers.""",
      """pages.overview.featureHelpersTitle""": """Helpers""",
      """pages.overview.featureHelpersBody""":
          """Loading, dialogs, toasts, and popovers ready to use.""",
      """pages.alerts.title""": """Components""",
      """pages.alerts.subtitle""": """Alerts""",
      """pages.alerts.breadcrumb""": """Alert variations""",
      """pages.alerts.cardTitle""": """Visual range and states""",
      """pages.alerts.intro""":
          """This page demonstrates solid, dismissible, roundedPill, truncated, alertClass, iconContainerClass, textClass, closeButtonWhite, and events.""",
      """pages.alerts.releaseDone""": """Deploy completed.""",
      """pages.alerts.releaseBody""":
          """The package is ready for validation.""",
      """pages.alerts.attention""": """Attention.""",
      """pages.alerts.solidHelp""":
          """Use solid=true when you need maximum contrast.""",
      """pages.alerts.borderlessHelp""":
          """This example combines borderless, roundedPill, and an icon at the end of the text.""",
      """pages.alerts.customHelp""":
          """This alert demonstrates custom classes on the container and icon block to match more editorial layouts without changing the base component markup.""",
      """pages.alerts.waiting""": """Waiting for interaction with alerts.""",
      """pages.alerts.restored""": """Main alert restored.""",
      """pages.alerts.dismissed""": """Main alert dismissed by the user.""",
      """pages.alerts.visible""": """visibleChange: alert visible.""",
      """pages.alerts.hidden""": """visibleChange: alert hidden.""",
      """pages.accordion.title""": """Components""",
      """pages.accordion.subtitle""": """Accordion""",
      """pages.accordion.breadcrumb""": """Expandable items""",
      """pages.accordion.cardTitle""": """Accordion settings""",
      """pages.accordion.intro""":
          """This page covers allowMultipleOpen, flush, lazy, destroyOnCollapse, disabled item, icons, and custom header.""",
      """pages.accordion.collapsedHeader""": """Collapsed state""",
      """pages.accordion.collapsedDescription""":
          """Starts closed and expands on demand.""",
      """pages.accordion.collapsedBody""":
          """Ideal for long lists that need to preserve visual focus.""",
      """pages.accordion.expandedHeader""": """Expanded state""",
      """pages.accordion.expandedDescription""": """Initially open item.""",
      """pages.accordion.expandedBody""":
          """Set expanded=true on the item that must open on load.""",
      """pages.accordion.disabledHeader""": """Disabled""",
      """pages.accordion.disabledDescription""":
          """Does not react to clicks.""",
      """pages.accordion.disabledBody""":
          """This item demonstrates the disabled state.""",
      """pages.accordion.customHeader""": """Custom header""",
      """pages.accordion.customDescription""":
          """Template with li-accordion-header.""",
      """pages.accordion.customBody""":
          """The header can be fully customized without losing the accordion structure.""",
      """pages.accordion.templateBadge""": """template""",
      """pages.accordion.idle""": """No accordion changed.""",
      """pages.accordion.expandedState""": """expanded""",
      """pages.accordion.collapsedState""": """collapsed""",
      """pages.progress.title""": """Components""",
      """pages.progress.subtitle""": """Progress""",
      """pages.progress.breadcrumb""": """Simple and stacked bars""",
      """pages.progress.cardTitle""": """Progress states""",
      """pages.progress.releasePipeline""": """Release pipeline""",
      """pages.progress.releaseConfig""":
          """Config: height, rounded, showValueLabel""",
      """pages.progress.squadCapacity""": """Squad capacity""",
      """pages.progress.squadConfig""":
          """Config: striped, animated, stacked bars""",
      """pages.progress.teamProduct""": """Product""",
      """pages.progress.customRange""": """Custom range""",
      """pages.progress.customConfig""": """Config: min, max and text label""",
      """pages.tabs.title""": """Components""",
      """pages.tabs.subtitle""": """Tabs""",
      """pages.tabs.breadcrumb""": """Horizontal and vertical tabs""",
      """pages.tabs.cardTitle""": """Pills with custom header""",
      """pages.tabs.tokens""": """Tokens""",
      """pages.tabs.flow""": """Flow""",
      """pages.tabs.blocked""": """Blocked""",
      """pages.tabs.tokensBody""":
          """Use tabs to separate documentation, examples, and API notes.""",
      """pages.tabs.flowBody""":
          """The component respects Bootstrap and Limitless composition.""",
      """pages.tabs.blockedBody""": """Disabled tab.""",
      """pages.modal.title""": """Components""",
      """pages.modal.subtitle""": """Modal""",
      """pages.modal.breadcrumb""": """Dialogs and layout variations""",
      """pages.modal.cardTitle""": """Modal examples""",
      """pages.modal.openModal""": """Open modal""",
      """pages.modal.scrollableModal""": """Scrollable modal""",
      """pages.modal.modalTitle""": """Modal example""",
      """pages.modal.modalHeading""": """Standardized composition""",
      """pages.modal.modalBody""":
          """The modal reuses the Limitless visual layer and can host short forms, confirmations, or detailed views.""",
      """pages.modal.scrollableTitle""": """Scrollable modal""",
      """pages.modal.scrollableBody""":
          """This example uses dialogScrollable, fullScreenOnMobile, and disables backdrop close.""",
      """pages.modal.understood""": """Understood""",
      """pages.select.title""": """Components""",
      """pages.select.subtitle""": """Select""",
      """pages.select.breadcrumb""": """Simple select""",
      """pages.select.cardTitle""": """Data source and content projection""",
      """pages.select.deliveryStatus""": """Delivery status""",
      """pages.select.projectedTitle""": """Select with li-option""",
      """pages.select.projectedPlaceholder""": """Choose a level""",
      """pages.select.projectedStatus""": """Projected status""",
      """pages.select.tabOverview""": """Overview""",
      """pages.select.tabApi""": """API""",
      """pages.select.tabTroubleshooting""": """Troubleshooting""",
      """pages.select.apiInputs""": """Most used inputs""",
      """pages.select.troubleshootingIntro""":
          """Common issues seen in this component and how to avoid them""",
      """pages.select.optionDraft""": """Draft""",
      """pages.select.optionReview""": """In review""",
      """pages.select.optionApproved""": """Approved""",
      """pages.select.optionArchived""": """Archived""",
      """pages.select.optionPriority""": """Priority""",
      """pages.select.optionBacklog""": """Backlog""",
      """pages.multiSelect.title""": """Components""",
      """pages.multiSelect.subtitle""": """Multi Select""",
      """pages.multiSelect.breadcrumb""": """Multiple selection""",
      """pages.multiSelect.cardTitle""": """Data source and li-multi-option""",
      """pages.multiSelect.channels""": """Notification channels""",
      """pages.multiSelect.projectedTargets""": """Projected targets""",
      """pages.multiSelect.projectedPlaceholder""": """Select targets""",
      """pages.multiSelect.projectedLabel""": """Projected""",
      """pages.multiSelect.tabOverview""": """Overview""",
      """pages.multiSelect.tabApi""": """API""",
      """pages.multiSelect.tabTroubleshooting""": """Troubleshooting""",
      """pages.multiSelect.apiInputs""": """Most used inputs""",
      """pages.multiSelect.troubleshootingIntro""":
          """Important precautions to avoid regressions""",
      """pages.multiSelect.optionEmail""": """E-mail""",
      """pages.multiSelect.optionPush""": """Push""",
      """pages.multiSelect.optionSms""": """SMS""",
      """pages.multiSelect.optionWebhook""": """Webhook""",
      """pages.multiSelect.optionPortal""": """Portal""",
      """pages.multiSelect.optionApi""": """API""",
      """pages.multiSelect.optionBatch""": """Batch process""",
      """pages.currency.title""": """Components""",
      """pages.currency.subtitle""": """Currency Input""",
      """pages.currency.breadcrumb""": """Monetary input in minor units""",
      """pages.currency.cardTitle""": """Brazilian format""",
      """pages.currency.budget""": """Budget""",
      """pages.currency.minorUnits""": """Minor units""",
      """pages.currency.help""":
          """The value bound to ngModel is always emitted as an integer in cents.""",
      """pages.dateRange.title""": """Components""",
      """pages.dateRange.subtitle""": """Date Range""",
      """pages.dateRange.breadcrumb""": """Period selection""",
      """pages.dateRange.cardTitle""": """Free and constrained ranges""",
      """pages.dateRange.sprintPlaceholder""": """Select the sprint period""",
      """pages.dateRange.publicationPlaceholder""": """Publication window""",
      """pages.dateRange.partial""": """Partial or undefined period""",
      """pages.dateRange.unfinished""": """Window not completed yet""",
      """pages.dateRange.constrainedHelp""":
          """The second example constrains the selection with minDate and maxDate.""",
      """pages.dateRange.between""": """to""",
      """pages.timePicker.title""": """Components""",
      """pages.timePicker.subtitle""": """Time Picker""",
      """pages.timePicker.breadcrumb""": """Time selection""",
      """pages.timePicker.cardTitle""": """Time Picker API and variations""",
      """pages.timePicker.tabOverview""": """Overview""",
      """pages.timePicker.tabApi""": """API""",
      """pages.timePicker.intro""":
          """The time picker uses a Limitless-inspired dial for hour and minute selection with ngModel integration.""",
      """pages.timePicker.descriptionTitle""": """Description""",
      """pages.timePicker.descriptionBody""":
          """The component fits scheduling, review, publishing, and operating-hour flows with a light, direct overlay.""",
      """pages.timePicker.featuresTitle""": """Features""",
      """pages.timePicker.featureOne""":
          """Direct ngModel binding with Duration?.""",
      """pages.timePicker.featureTwo""":
          """Clock-based selection switching between hour and minute.""",
      """pages.timePicker.featureThree""":
          """Integrated AM/PM toggle inside the panel.""",
      """pages.timePicker.limitsTitle""": """Limitations""",
      """pages.timePicker.limitOne""":
          """The component currently works in a 12-hour AM/PM format.""",
      """pages.timePicker.limitTwo""":
          """It does not apply business window rules on its own.""",
      """pages.timePicker.limitThree""":
          """The returned value carries only hour and minute.""",
      """pages.timePicker.defaultTitle""": """Default time picker""",
      """pages.timePicker.englishTitle""": """English time picker""",
      """pages.timePicker.disabledTitle""": """Disabled time picker""",
      """pages.timePicker.placeholder""": """Select time""",
      """pages.timePicker.englishPlaceholder""": """Select time""",
      """pages.timePicker.disabledPlaceholder""": """Locked time""",
      """pages.timePicker.currentLabel""": """Current time""",
      """pages.timePicker.reviewLabel""": """Review time""",
      """pages.timePicker.disabledLabel""": """Locked time""",
      """pages.timePicker.defaultHelp""":
          """Click the hour block first and the minute block next to refine the selection.""",
      """pages.timePicker.englishHelp""":
          """Locale switches the placeholder and helper texts used by the panel.""",
      """pages.timePicker.disabledHelp""":
          """The field keeps displaying the value without opening the overlay.""",
      """pages.timePicker.notesTitle""": """Usage notes""",
      """pages.timePicker.notesBody""":
          """The component returns a Duration normalized to the minutes of the day, which fits forms and filters without carrying a full date.""",
      """pages.timePicker.noneSelected""": """No time selected""",
      """pages.timePicker.apiIntro""":
          """Use li-time-picker when the form needs only a time value, without an associated date, while keeping ngModel integration.""",
      """pages.timePicker.apiInputsTitle""": """Main inputs""",
      """pages.timePicker.apiInputOne""":
          """The ngModel binding works with Duration?.""",
      """pages.timePicker.apiInputTwo""":
          """locale adjusts the placeholder and panel labels.""",
      """pages.timePicker.apiInputThree""":
          """disabled prevents opening the clock.""",
      """pages.timePicker.apiBehaviorTitle""": """Behavior""",
      """pages.timePicker.apiBehaviorOne""":
          """Click the clock to select the hour and then the minute.""",
      """pages.timePicker.apiBehaviorTwo""":
          """The OK button confirms the selection and emits valueChange and ngModel.""",
      """pages.timePicker.apiBehaviorThree""":
          """AM and PM switch the half of the day without rebuilding the value manually.""",
      """pages.timePicker.apiUsageExample""": """// Usage example
selectedTime = const Duration(hours: 10, minutes: 48);

<li-time-picker
  [(ngModel)]="selectedTime"
  locale="en_US">
</li-time-picker>
""",
      """pages.datePicker.title""": """Components""",
      """pages.datePicker.subtitle""": """Date Picker""",
      """pages.datePicker.breadcrumb""": """Single date selection""",
      """pages.datePicker.cardTitle""": """Date Picker API and variations""",
      """pages.datePicker.tabOverview""": """Overview""",
      """pages.datePicker.tabApi""": """API""",
      """pages.datePicker.tabVariations""": """Variations""",
      """pages.datePicker.intro""":
          """This page is dedicated to li-date-picker, focusing on single-date flows, quick month/year navigation, locale, and common field states.""",
      """pages.datePicker.descriptionTitle""": """Description""",
      """pages.datePicker.descriptionBody""":
          """The date picker fits single-date flows such as scheduling, publication, due dates, and punctual filters without mixing responsibilities with the range selector.""",
      """pages.datePicker.featuresTitle""": """Features""",
      """pages.datePicker.featureOne""":
          """Direct ngModel binding with DateTime?.""",
      """pages.datePicker.featureTwo""":
          """Restriction through minDate and maxDate.""",
      """pages.datePicker.featureThree""": """Immediate apply on day click.""",
      """pages.datePicker.featureFour""":
          """Direct month and year navigation inside the overlay.""",
      """pages.datePicker.limitsTitle""": """Limitations""",
      """pages.datePicker.limitOne""":
          """It does not replace specific business calendar rules.""",
      """pages.datePicker.limitTwo""":
          """Special rules such as holidays and blocked dates still belong in the parent component.""",
      """pages.datePicker.limitThree""":
          """Special dates and messages remain the parent component's responsibility.""",
      """pages.datePicker.ngModelTitle""": """Date picker with ngModel""",
      """pages.datePicker.restrictedTitle""": """Restricted date picker""",
      """pages.datePicker.englishLocaleTitle""": """Date picker in English""",
      """pages.datePicker.disabledTitle""": """Disabled date picker""",
      """pages.datePicker.placeholder""": """Select a date""",
      """pages.datePicker.restrictedPlaceholder""": """Allowed window""",
      """pages.datePicker.englishPlaceholder""": """Choose a date""",
      """pages.datePicker.disabledPlaceholder""": """Locked field""",
      """pages.datePicker.currentDateLabel""": """Current date""",
      """pages.datePicker.restrictedLabel""": """Restricted date""",
      """pages.datePicker.englishLabel""": """EN date""",
      """pages.datePicker.disabledLabel""": """Locked value""",
      """pages.datePicker.defaultHelp""":
          """Click the calendar header to jump quickly between month and year.""",
      """pages.datePicker.restrictedHelp""":
          """This example limits selection between minDate and maxDate.""",
      """pages.datePicker.englishHelp""":
          """Locale switches calendar labels and the displayed date format.""",
      """pages.datePicker.disabledHelp""":
          """The field keeps the current value readable without opening the overlay.""",
      """pages.datePicker.noneSelected""": """No date selected""",
      """pages.datePicker.partialRange""": """Partial or undefined period""",
      """pages.datePicker.apiIntro""":
          """Use li-date-picker when the flow depends on a single date with a light overlay, ngModel, locale, and basic constraints.""",
      """pages.datePicker.apiInputsTitle""": """Main inputs""",
      """pages.datePicker.apiInputOne""":
          """The [(ngModel)] binding works with DateTime?.""",
      """pages.datePicker.apiInputTwo""":
          """[minDate] and [maxDate] constrain the navigable and selectable window.""",
      """pages.datePicker.apiInputThree""":
          """locale adjusts labels and the visual date format.""",
      """pages.datePicker.apiInputFour""":
          """[disabled] prevents opening and selection.""",
      """pages.datePicker.apiBehaviorTitle""": """Behavior""",
      """pages.datePicker.apiBehaviorOne""":
          """Clicking a day applies immediately and closes the overlay.""",
      """pages.datePicker.apiBehaviorTwo""":
          """Clicking the calendar title cycles between day, month, and year views.""",
      """pages.datePicker.apiBehaviorThree""":
          """clear() remains available in the footer to reset the current value.""",
      """pages.datePicker.apiBehaviorFour""":
          """valueChange and ngModel receive the normalized date without time.""",
      """pages.datePicker.apiUsageExample""": """// Usage example
selectedDate = DateTime(2026, 3, 20);

<li-date-picker
  [(ngModel)]="selectedDate"
  [minDate]="DateTime(2026, 3, 1)"
  [maxDate]="DateTime(2026, 3, 31)"
  locale="en_US">
</li-date-picker>
""",
      """pages.datePicker.variationStandardTitle""": """Default flow""",
      """pages.datePicker.variationStandardBody""":
          """Best fit for forms where the user picks a date and moves on without extra confirmation.""",
      """pages.datePicker.variationLocaleTitle""": """Visual locale""",
      """pages.datePicker.variationLocaleBody""":
          """The same API switches labels, months, and displayed format between Portuguese and English.""",
      """pages.datePicker.variationDisabledTitle""": """Locked state""",
      """pages.datePicker.variationDisabledBody""":
          """Preserves the rendered value when the date is informative and cannot be edited.""",
      """pages.carousel.title""": """Components""",
      """pages.carousel.subtitle""": """Carousel""",
      """pages.carousel.breadcrumb""":
          """Carousel with transitions, captions, and grid""",
      """pages.carousel.cardTitle""": """Carousel variations""",
      """pages.carousel.exampleLabel""": """Example""",
      """pages.carousel.standardTitle""": """Carousel with Caption""",
      """pages.carousel.standardSubtitle""":
          """Indicators and controls in the Limitless style, with a centered white caption inside each slide.""",
      """pages.carousel.gridTitle""": """Carousel in Grid""",
      """pages.carousel.gridSubtitle""":
          """You can have up to 12 items per slide using the Bootstrap grid, with row and col-* inside each carousel-item.""",
      """pages.carousel.slideOneLabel""": """Architecture""",
      """pages.carousel.slideOneTitle""": """First slide""",
      """pages.carousel.slideOneBody""":
          """Small indicators at the bottom and side navigation in the Bootstrap/Limitless style.""",
      """pages.carousel.slideTwoLabel""": """Composition""",
      """pages.carousel.slideTwoTitle""": """Second slide""",
      """pages.carousel.slideTwoBody""":
          """The caption uses the correct component class and respects the theme's centered positioning.""",
      """pages.carousel.slideThreeLabel""": """Delivery""",
      """pages.carousel.slideThreeTitle""": """Third slide""",
      """pages.carousel.slideThreeBody""":
          """Navigation stays consistent even with autoplay and manual changes.""",
      """pages.carousel.slideFourLabel""": """Reference""",
      """pages.carousel.slideFourTitle""": """Fourth slide""",
      """pages.carousel.slideFourBody""":
          """Structure equivalent to the classic example from components_carousel.html.""",
      """pages.carousel.gridSlideOneLabel""": """Collection 1""",
      """pages.carousel.gridSlideTwoLabel""": """Collection 2""",
      """pages.carousel.gridSlideThreeLabel""": """Collection 3""",
      """pages.carousel.gridCardOneTitle""": """Editorial workspace""",
      """pages.carousel.gridCardOneBody""":
          """Visual board for documents, highlights, and more narrative layouts.""",
      """pages.carousel.gridCardTwoTitle""": """Featured product""",
      """pages.carousel.gridCardTwoBody""":
          """Structure ready for card showcases, media, or campaigns.""",
      """pages.carousel.gridCardThreeTitle""": """User journey""",
      """pages.carousel.gridCardThreeBody""":
          """A slide can gather multiple entries without losing readability.""",
      """pages.carousel.gridCardFourTitle""": """Visual identity""",
      """pages.carousel.gridCardFourBody""":
          """Larger images help validate contrast, crop, and overlay behavior.""",
      """pages.carousel.gridCardFiveTitle""": """Composable modules""",
      """pages.carousel.gridCardFiveBody""":
          """Carousel, Caption, and Grid work together without coupled markup.""",
      """pages.carousel.gridCardSixTitle""": """Executable demo""",
      """pages.carousel.gridCardSixBody""":
          """The showcase stops being static and starts showing real behavior.""",
      """pages.carousel.gridCardSevenTitle""": """Expanded collection""",
      """pages.carousel.gridCardSevenBody""":
          """One more slide to validate indicators and continuous transition in the grid.""",
      """pages.carousel.gridCardEightTitle""": """Stable navigation""",
      """pages.carousel.gridCardEightBody""":
          """Side controls stay predictable because the row lives inside the item.""",
      """pages.carousel.gridCardNineTitle""": """Correct structure""",
      """pages.carousel.gridCardNineBody""":
          """The item remains the real slide; the grid is only internal content.""",
      """pages.carousel.fadeTitle""": """Carousel with Fade""",
      """pages.carousel.fadeSubtitle""":
          """Switches slides through opacity instead of lateral movement, useful for hero banners and caption-heavy content.""",
      """pages.carousel.fadeSlideOneLabel""": """Fade 1""",
      """pages.carousel.fadeSlideOneTitle""": """Editorial fade""",
      """pages.carousel.fadeSlideOneBody""":
          """The slide enters through opacity without competing for attention with horizontal movement.""",
      """pages.carousel.fadeSlideTwoLabel""": """Fade 2""",
      """pages.carousel.fadeSlideTwoTitle""": """Cleaner reading""",
      """pages.carousel.fadeSlideTwoBody""":
          """Works well when the image already has a lot of texture and you want a more discreet transition.""",
      """pages.carousel.fadeSlideThreeLabel""": """Fade 3""",
      """pages.carousel.fadeSlideThreeTitle""": """Smooth transition""",
      """pages.carousel.fadeSlideThreeBody""":
          """Controls, indicators, and autoplay stay the same; only the visual language of the transition changes.""",
      """pages.carousel.zoomTitle""": """Carousel with Zoom""",
      """pages.carousel.zoomSubtitle""":
          """Scale and opacity on entry for a more cinematic feeling without changing the component structure.""",
      """pages.carousel.zoomSlideOneLabel""": """Zoom 1""",
      """pages.carousel.zoomSlideOneTitle""": """Zoom in""",
      """pages.carousel.zoomSlideOneBody""":
          """The next slide enters at a larger scale and settles into the main plane by the end of the transition.""",
      """pages.carousel.zoomSlideTwoLabel""": """Zoom 2""",
      """pages.carousel.zoomSlideTwoTitle""": """Visual emphasis""",
      """pages.carousel.zoomSlideTwoBody""":
          """A good variation for campaign showcases, portfolios, or more editorial screens.""",
      """pages.carousel.zoomSlideThreeLabel""": """Zoom 3""",
      """pages.carousel.zoomSlideThreeTitle""": """Same markup""",
      """pages.carousel.zoomSlideThreeBody""":
          """The API remains the same: the effect changes through input, without alternate item markup.""",
      """pages.carousel.verticalTitle""": """Vertical Carousel""",
      """pages.carousel.verticalSubtitle""":
          """The transition happens on the Y axis, useful when the page composition already has a lot of horizontal movement.""",
      """pages.carousel.verticalSlideOneLabel""": """Vertical 1""",
      """pages.carousel.verticalSlideOneTitle""": """Vertical displacement""",
      """pages.carousel.verticalSlideOneBody""":
          """The carousel behavior stays the same, but the perception changes completely.""",
      """pages.carousel.verticalSlideTwoLabel""": """Vertical 2""",
      """pages.carousel.verticalSlideTwoTitle""": """Alternate flow""",
      """pages.carousel.verticalSlideTwoBody""":
          """This mode can pair better with column-based layouts and more documentary content.""",
      """pages.carousel.verticalSlideThreeLabel""": """Vertical 3""",
      """pages.carousel.verticalSlideThreeTitle""": """Consistent API""",
      """pages.carousel.verticalSlideThreeBody""":
          """Just like zoom, the change is encapsulated in the component and can be reused on other screens.""",
      """pages.carousel.blurTitle""": """Carousel with Blur""",
      """pages.carousel.blurSubtitle""":
          """A transition with blur and opacity that softens the exchange between more detailed images.""",
      """pages.carousel.blurSlideOneLabel""": """Blur 1""",
      """pages.carousel.blurSlideOneTitle""": """Diffused entry""",
      """pages.carousel.blurSlideOneBody""":
          """The slide emerges with reduced blur and growing opacity, creating a more atmospheric change.""",
      """pages.carousel.blurSlideTwoLabel""": """Blur 2""",
      """pages.carousel.blurSlideTwoTitle""": """Texture under control""",
      """pages.carousel.blurSlideTwoBody""":
          """This mode works well when the photography has a lot of detail and pure fade feels too subtle.""",
      """pages.carousel.blurSlideThreeLabel""": """Blur 3""",
      """pages.carousel.blurSlideThreeTitle""": """Reusable variation""",
      """pages.carousel.blurSlideThreeBody""":
          """The effect remains encapsulated in the component and can be applied to any carousel through input.""",
      """pages.carousel.parallaxTitle""": """Carousel with Parallax""",
      """pages.carousel.parallaxSubtitle""":
          """Shifts the image with apparent depth, creating a more spatial transition between slides.""",
      """pages.carousel.parallaxSlideOneLabel""": """Parallax 1""",
      """pages.carousel.parallaxSlideOneTitle""": """Lateral depth""",
      """pages.carousel.parallaxSlideOneBody""":
          """The slide enters with displacement and slightly larger scale, suggesting a moving background plane.""",
      """pages.carousel.parallaxSlideTwoLabel""": """Parallax 2""",
      """pages.carousel.parallaxSlideTwoTitle""": """Editorial motion""",
      """pages.carousel.parallaxSlideTwoBody""":
          """This mode works well in visual showcases and pages where the image change should feel more physical.""",
      """pages.carousel.parallaxSlideThreeLabel""": """Parallax 3""",
      """pages.carousel.parallaxSlideThreeTitle""": """Subtle layers""",
      """pages.carousel.parallaxSlideThreeBody""":
          """The parallax feel stays subtle and reusable without requiring special item markup.""",
      """pages.tooltip.title""": """Components""",
      """pages.tooltip.subtitle""": """Tooltip""",
      """pages.tooltip.breadcrumb""": """Hover, click, and manual mode""",
      """pages.tooltip.cardTitle""": """Triggers and placement""",
      """pages.tooltip.hoverText""": """Shows hints on hover.""",
      """pages.tooltip.hoverButton""": """Hover tooltip""",
      """pages.tooltip.clickText""":
          """<strong>HTML</strong> also works with click trigger.""",
      """pages.tooltip.clickButton""": """Click tooltip""",
      """pages.tooltip.manualText""":
          """Manual tooltip with programmatic control.""",
      """pages.tooltip.manualButton""": """Manual tooltip""",
      """pages.tooltip.idle""": """No tooltip events yet.""",
      """pages.datatable.title""": """Components""",
      """pages.datatable.subtitle""": """Datatable""",
      """pages.datatable.breadcrumb""": """Search, selection, and export""",
      """pages.datatable.cardTitle""": """Table operations""",
      """pages.datatable.toggleGrid""": """Toggle grid""",
      """pages.datatable.singleSelection""": """Single selection""",
      """pages.datatable.searchLabel""": """Search sprint""",
      """pages.datatable.searchPlaceholder""":
          """Type delivery, squad, or status""",
      """pages.datatable.featureCol""": """Delivery""",
      """pages.datatable.ownerCol""": """Squad""",
      """pages.datatable.statusCol""": """Status""",
      """pages.datatable.healthCol""": """Health""",
      """pages.datatable.featureRow1""": """Executive dashboard""",
      """pages.datatable.featureRow2""": """PDF export""",
      """pages.datatable.featureRow3""": """Approval flow""",
      """pages.datatable.featureRow4""": """Real-time alerts""",
      """pages.datatable.ownerProduct""": """Product""",
      """pages.datatable.ownerBackoffice""": """Backoffice""",
      """pages.datatable.ownerOperations""": """Operations""",
      """pages.datatable.ownerInfra""": """Infra""",
      """pages.datatable.statusInProgress""": """In progress""",
      """pages.datatable.statusDone""": """Completed""",
      """pages.datatable.statusPlanned""": """Planned""",
      """pages.datatable.statusBlocked""": """Blocked""",
      """pages.datatable.healthWarning""": """Attention""",
      """pages.datatable.healthOk""": """OK""",
      """pages.datatable.healthCritical""": """Critical""",
      """pages.datatable.ready""": """Table ready for interaction.""",
      """pages.datatable.gridMode""": """Datatable switched to grid mode.""",
      """pages.datatable.tableMode""": """Datatable switched to table mode.""",
      """pages.datatable.singleMode""": """Single selection enabled.""",
      """pages.datatable.multiMode""": """Multiple selection enabled.""",
      """pages.datatable.exportXlsx""": """XLSX export triggered.""",
      """pages.datatable.exportPdf""": """PDF export triggered.""",
      """pages.notification.title""": """Components""",
      """pages.notification.subtitle""": """Notification Outlet""",
      """pages.notification.breadcrumb""": """Fixed viewport toasts""",
      """pages.notification.cardTitle""": """Trigger notifications""",
      """pages.notification.withLink""": """With link""",
      """pages.notification.idle""": """No notification triggered.""",
      """pages.notification.successMessage""":
          """Synchronization completed successfully.""",
      """pages.notification.successTitle""": """Event queue""",
      """pages.notification.successState""":
          """Success notification triggered.""",
      """pages.notification.warningMessage""":
          """There are items waiting for manual validation.""",
      """pages.notification.warningTitle""": """Attention""",
      """pages.notification.warningState""":
          """Warning notification triggered.""",
      """pages.notification.linkMessage""":
          """Click to open the datatable demo.""",
      """pages.notification.linkTitle""": """Shortcut""",
      """pages.notification.linkState""":
          """Notification with datatable link triggered.""",
      """pages.treeview.title""": """Components""",
      """pages.treeview.subtitle""": """Treeview""",
      """pages.treeview.breadcrumb""": """Hierarchical structure""",
      """pages.treeview.cardTitle""": """Search, expand, and select""",
      """pages.treeview.intro""":
          """The treeview includes search, expand/collapse, and cascade selection.""",
      """pages.treeview.searchPlaceholder""": """Search by module or status""",
      """pages.treeview.nodeService""": """Service""",
      """pages.treeview.nodeTriage""": """Triage""",
      """pages.treeview.nodeReferrals""": """Referrals""",
      """pages.treeview.nodeBenefits""": """Benefits""",
      """pages.treeview.nodeFoodBasket""": """Food basket""",
      """pages.treeview.nodeReview""": """Under review""",
      """pages.treeview.nodeApproved""": """Approved""",
      """pages.treeview.nodeRentAid""": """Rent aid""",
      """pages.helpers.title""": """Components""",
      """pages.helpers.subtitle""": """Helpers""",
      """pages.helpers.breadcrumb""":
          """Loading, dialogs, popovers, and toasts""",
      """pages.helpers.loadingTitle""": """SimpleLoading""",
      """pages.helpers.showOverlay""": """Show overlay""",
      """pages.helpers.loadingTarget""": """Loading target area""",
      """pages.helpers.loadingTargetHelp""":
          """The overlay stays attached to the container.""",
      """pages.helpers.actionTitle""": """Dialogs, toasts, and popovers""",
      """pages.helpers.dialogAlert""": """Dialog alert""",
      """pages.helpers.dialogConfirm""": """Dialog confirm""",
      """pages.helpers.simplePopover""": """Simple popover""",
      """pages.helpers.sweetPopover""": """Sweet popover""",
      """pages.helpers.simpleSuccessToast""": """Simple success toast""",
      """pages.helpers.simpleWarningToast""": """Simple warning toast""",
      """pages.helpers.sweetSuccessToast""": """Sweet success toast""",
      """pages.helpers.sweetWarningToast""": """Sweet warning toast""",
      """pages.helpers.idle""":
          """Use the buttons to trigger the static helpers.""",
      """pages.helpers.loadingShown""":
          """Loading overlay shown for 2 seconds.""",
      """pages.helpers.loadingHidden""": """Loading overlay finished.""",
      """pages.helpers.dialogAlertBody""":
          """The operation has started and will be monitored in the background.""",
      """pages.helpers.dialogAlertTitle""": """Execution started""",
      """pages.helpers.dialogAlertState""":
          """SimpleDialog.showAlert executed.""",
      """pages.helpers.dialogConfirmBody""":
          """Do you want to continue publishing this configuration?""",
      """pages.helpers.dialogConfirmTitle""": """Confirmation""",
      """pages.helpers.dialogConfirmOk""": """Publish""",
      """pages.helpers.dialogConfirmCancel""": """Cancel""",
      """pages.helpers.dialogConfirmTrue""":
          """Positive confirmation returned true.""",
      """pages.helpers.dialogConfirmFalse""":
          """Confirmation returned false.""",
      """pages.helpers.simplePopoverBody""":
          """Simple popover anchored to the button using Bootstrap/Limitless markup.""",
      """pages.helpers.simplePopoverState""": """SimplePopover shown.""",
      """pages.helpers.sweetPopoverBody""":
          """SweetAlert-based version with Popper overlay.""",
      """pages.helpers.sweetPopoverTitle""": """Sweet popover""",
      """pages.helpers.sweetPopoverState""": """SweetAlertPopover shown.""",
      """pages.helpers.simpleSuccessBody""": """Simple success toast shown.""",
      """pages.helpers.simpleSuccessState""":
          """SimpleToast.showSuccess executed.""",
      """pages.helpers.simpleWarningBody""": """Simple warning toast shown.""",
      """pages.helpers.simpleWarningState""":
          """SimpleToast.showWarning executed.""",
      """pages.helpers.sweetSuccessBody""":
          """SweetAlert success toast shown.""",
      """pages.helpers.sweetSuccessState""":
          """SweetAlertSimpleToast.showSuccessToast executed.""",
      """pages.helpers.sweetWarningBody""":
          """SweetAlert warning toast shown.""",
      """pages.helpers.sweetWarningState""":
          """SweetAlertSimpleToast.showWarningToast executed.""",
      """pages.button.title""": """Components""",
      """pages.button.subtitle""": """Buttons""",
      """pages.button.breadcrumb""": """Button styles and variations""",
      """pages.button.colorsTitle""": """Button colors""",
      """pages.button.colorsSubtitle""": """Preset color options for buttons""",
      """pages.button.solidTitle""": """Solid buttons""",
      """pages.button.solidSubtitle""":
          """Buttons with a solid background color""",
      """pages.button.outlineTitle""": """Outline buttons""",
      """pages.button.outlineSubtitle""":
          """Buttons with a transparent background by default""",
      """pages.button.flatTitle""": """Flat buttons""",
      """pages.button.flatSubtitle""":
          """Buttons with a semi-transparent background""",
      """pages.button.linkTitle""": """Link buttons""",
      """pages.button.linkSubtitle""": """Buttons with text link styling""",
      """pages.button.sizesTitle""": """Button sizes""",
      """pages.button.sizesSubtitle""":
          """Buttons in large, default, and small sizes""",
      """pages.button.alignTitle""": """Icon alignment""",
      """pages.button.alignSubtitle""":
          """Examples of left and right icon alignment""",
      """pages.button.disabledTitle""": """Disabled buttons""",
      """pages.button.disabledSubtitle""": """Buttons in the disabled state""",
    };
