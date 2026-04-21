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

  /// ```dart
  /// "FAB"
  /// ```
  String get fab => """FAB""";
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
  /// "Clear"
  /// ```
  String get clear => """Clear""";

  /// ```dart
  /// "Status"
  /// ```
  String get status => """Status""";

  /// ```dart
  /// "Value"
  /// ```
  String get value => """Value""";

  /// ```dart
  /// "Label"
  /// ```
  String get label => """Label""";

  /// ```dart
  /// "Event"
  /// ```
  String get event => """Event""";

  /// ```dart
  /// "Current period"
  /// ```
  String get currentPeriod => """Current period""";

  /// ```dart
  /// "Restricted window"
  /// ```
  String get restrictedWindow => """Restricted window""";

  /// ```dart
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Description"
  /// ```
  String get sectionDescription => """Description""";

  /// ```dart
  /// "Features"
  /// ```
  String get sectionFeatures => """Features""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get sectionLimitations => """Limitations""";

  /// ```dart
  /// "How to use"
  /// ```
  String get sectionHowToUse => """How to use""";

  /// ```dart
  /// "Notes"
  /// ```
  String get sectionNotes => """Notes""";

  /// ```dart
  /// "Visible example"
  /// ```
  String get sectionVisibleExample => """Visible example""";

  /// ```dart
  /// "Main options"
  /// ```
  String get sectionMainOptions => """Main options""";

  /// ```dart
  /// "Best practices"
  /// ```
  String get sectionBestPractices => """Best practices""";

  /// ```dart
  /// "Outputs"
  /// ```
  String get sectionOutputs => """Outputs""";

  /// ```dart
  /// "Public methods"
  /// ```
  String get sectionPublicMethods => """Public methods""";
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
  DatatableSelectPagesMessagesEn get datatableSelect =>
      DatatableSelectPagesMessagesEn(this);
  NotificationPagesMessagesEn get notification =>
      NotificationPagesMessagesEn(this);
  TreeviewPagesMessagesEn get treeview => TreeviewPagesMessagesEn(this);
  HelpersPagesMessagesEn get helpers => HelpersPagesMessagesEn(this);
  ButtonPagesMessagesEn get button => ButtonPagesMessagesEn(this);
  FabPagesMessagesEn get fab => FabPagesMessagesEn(this);
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
  /// "AngularDart documentation"
  /// ```
  String get featureAngularDartDocsTitle => """AngularDart documentation""";

  /// ```dart
  /// "Open the setup guide published under site_ngdart."
  /// ```
  String get featureAngularDartDocsBody =>
      """Open the setup guide published under site_ngdart.""";

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

  /// ```dart
  /// "Unified API for modals, confirmation, prompt, toast, and also a declarative trigger."
  /// ```
  String get featureSweetAlertBody =>
      """Unified API for modals, confirmation, prompt, toast, and also a declarative trigger.""";

  /// ```dart
  /// "Lightweight block for Dart, HTML, and CSS snippets in the example documentation."
  /// ```
  String get featureHighlightBody =>
      """Lightweight block for Dart, HTML, and CSS snippets in the example documentation.""";

  /// ```dart
  /// "Text field with ngModel, floating label, textarea, and prefix or suffix addons."
  /// ```
  String get featureInputsFieldBody =>
      """Text field with ngModel, floating label, textarea, and prefix or suffix addons.""";

  /// ```dart
  /// "Compact speed dial for quick global or inline actions."
  /// ```
  String get featureFabBody =>
      """Compact speed dial for quick global or inline actions.""";
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
  /// "The accordion organizes dense blocks of information into expandable sections, reducing visual noise without losing context."
  /// ```
  String get descriptionBody =>
      """The accordion organizes dense blocks of information into expandable sections, reducing visual noise without losing context.""";

  /// ```dart
  /// "Collapsed, expanded, disabled items, and customized headers."
  /// ```
  String get featureOne =>
      """Collapsed, expanded, disabled items, and customized headers.""";

  /// ```dart
  /// "Open and close events per item."
  /// ```
  String get featureTwo => """Open and close events per item.""";

  /// ```dart
  /// "Lazy rendering and optional body destruction."
  /// ```
  String get featureThree =>
      """Lazy rendering and optional body destruction.""";

  /// ```dart
  /// "Highly interactive content requires extra focus care."
  /// ```
  String get limitOne =>
      """Highly interactive content requires extra focus care.""";

  /// ```dart
  /// "Very long sections still need internal hierarchy."
  /// ```
  String get limitTwo =>
      """Very long sections still need internal hierarchy.""";

  /// ```dart
  /// "The layout does not replace route-based navigation."
  /// ```
  String get limitThree =>
      """The layout does not replace route-based navigation.""";

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

  /// ```dart
  /// "Declarative API with directives"
  /// ```
  String get directiveApiTitle => """Declarative API with directives""";

  /// ```dart
  /// "This version keeps Bootstrap markup accessible in the DOM and exposes an API similar to ng-bootstrap."
  /// ```
  String get directiveApiIntro =>
      """This version keeps Bootstrap markup accessible in the DOM and exposes an API similar to ng-bootstrap.""";

  /// ```dart
  /// "For true physical destroyOnHide, use <template liAccordionBody>. The simple wrapper with <div liAccordionBody> keeps the content in the DOM when the reference must remain stable."
  /// ```
  String get directiveApiNote =>
      """For true physical destroyOnHide, use <template liAccordionBody>. The simple wrapper with <div liAccordionBody> keeps the content in the DOM when the reference must remain stable.""";

  /// ```dart
  /// "Overview"
  /// ```
  String get declarativeOverviewButton => """Overview""";

  /// ```dart
  /// "Basic content with declarative header and body, keeping accessibility classes and attributes."
  /// ```
  String get declarativeOverviewBody =>
      """Basic content with declarative header and body, keeping accessibility classes and attributes.""";

  /// ```dart
  /// "Custom header"
  /// ```
  String get declarativeCustomHeader => """Custom header""";

  /// ```dart
  /// "Toggle"
  /// ```
  String get declarativeToggle => """Toggle""";

  /// ```dart
  /// "The header can be fully customized without losing id, collapse, and event control."
  /// ```
  String get declarativeCustomBody =>
      """The header can be fully customized without losing id, collapse, and event control.""";

  /// ```dart
  /// "Disabled item"
  /// ```
  String get declarativeDisabledButton => """Disabled item""";

  /// ```dart
  /// "This content stays accessible through the API, but does not react to user clicks."
  /// ```
  String get declarativeDisabledBody =>
      """This content stays accessible through the API, but does not react to user clicks.""";

  /// ```dart
  /// "Expand overview"
  /// ```
  String get expandOverview => """Expand overview""";

  /// ```dart
  /// "Toggle custom"
  /// ```
  String get toggleCustom => """Toggle custom""";

  /// ```dart
  /// "Close all"
  /// ```
  String get closeAll => """Close all""";

  /// ```dart
  /// "Item API"
  /// ```
  String get itemApi => """Item API""";

  /// ```dart
  /// "No declarative API events yet."
  /// ```
  String get declarativeIdle => """No declarative API events yet.""";

  /// ```dart
  /// "liCollapse"
  /// ```
  String get collapseTitle => """liCollapse""";

  /// ```dart
  /// "Generic directive to hide and show blocks with the collapse, show, and collapsing classes."
  /// ```
  String get collapseIntro =>
      """Generic directive to hide and show blocks with the collapse, show, and collapsing classes.""";

  /// ```dart
  /// "Open panel"
  /// ```
  String get openPanel => """Open panel""";

  /// ```dart
  /// "Close panel"
  /// ```
  String get closePanel => """Close panel""";

  /// ```dart
  /// "This block uses the generic collapse directive without depending on the accordion."
  /// ```
  String get collapseBody =>
      """This block uses the generic collapse directive without depending on the accordion.""";

  /// ```dart
  /// "[allowMultipleOpen] lets more than one item stay expanded at the same time."
  /// ```
  String get apiOne =>
      """[allowMultipleOpen] lets more than one item stay expanded at the same time.""";

  /// ```dart
  /// "[flush] removes extra borders for a more compact composition."
  /// ```
  String get apiTwo =>
      """[flush] removes extra borders for a more compact composition.""";

  /// ```dart
  /// "[lazy] defers body rendering until the first open."
  /// ```
  String get apiThree =>
      """[lazy] defers body rendering until the first open.""";

  /// ```dart
  /// "[destroyOnCollapse] removes the content from the DOM when the item closes."
  /// ```
  String get apiFour =>
      """[destroyOnCollapse] removes the content from the DOM when the item closes.""";

  /// ```dart
  /// "[expanded] and (expandedChange) control open state per item."
  /// ```
  String get apiFive =>
      """[expanded] and (expandedChange) control open state per item.""";
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
  /// "The tabs page demonstrates horizontal and vertical composition, distributed alignment, custom headers, and on-demand rendering."
  /// ```
  String get overviewIntro =>
      """The tabs page demonstrates horizontal and vertical composition, distributed alignment, custom headers, and on-demand rendering.""";

  /// ```dart
  /// "Tabs organize content in layers without breaking page context and work well for documentation, segmented forms, and administrative panels."
  /// ```
  String get descriptionBody =>
      """Tabs organize content in layers without breaking page context and work well for documentation, segmented forms, and administrative panels.""";

  /// ```dart
  /// "Tabs and pills modes."
  /// ```
  String get featureOne => """Tabs and pills modes.""";

  /// ```dart
  /// "Horizontal or side placement."
  /// ```
  String get featureTwo => """Horizontal or side placement.""";

  /// ```dart
  /// "Projected header and disabled tabs."
  /// ```
  String get featureThree => """Projected header and disabled tabs.""";

  /// ```dart
  /// "Too many tabs at the same level hurt scannability."
  /// ```
  String get limitOne =>
      """Too many tabs at the same level hurt scannability.""";

  /// ```dart
  /// "Very long content calls for additional hierarchy."
  /// ```
  String get limitTwo =>
      """Very long content calls for additional hierarchy.""";

  /// ```dart
  /// "Nested tabs should be isolated into subcomponents."
  /// ```
  String get limitThree =>
      """Nested tabs should be isolated into subcomponents.""";

  /// ```dart
  /// "Visible example"
  /// ```
  String get previewTitle => """Visible example""";

  /// ```dart
  /// "The gallery below covers basic layouts, justified variants, side navigation, projected headers, and lifecycle behavior with lazyLoad and destroyOnHide."
  /// ```
  String get previewIntro =>
      """The gallery below covers basic layouts, justified variants, side navigation, projected headers, and lifecycle behavior with lazyLoad and destroyOnHide.""";

  /// ```dart
  /// "Use the component to group related content when section-based navigation makes more sense than stacking cards or opening new routes."
  /// ```
  String get apiIntro =>
      """Use the component to group related content when section-based navigation makes more sense than stacking cards or opening new routes.""";

  /// ```dart
  /// "type accepts tabs or pills."
  /// ```
  String get apiOne => """type accepts tabs or pills.""";

  /// ```dart
  /// "placement controls tab position, such as top or side."
  /// ```
  String get apiTwo =>
      """placement controls tab position, such as top or side.""";

  /// ```dart
  /// "[justified] distributes triggers evenly."
  /// ```
  String get apiThree => """[justified] distributes triggers evenly.""";

  /// ```dart
  /// "[active] and [disabled] control state per tab."
  /// ```
  String get apiFour => """[active] and [disabled] control state per tab.""";

  /// ```dart
  /// "template li-tabx-header allows custom headers."
  /// ```
  String get apiFive => """template li-tabx-header allows custom headers.""";

  /// ```dart
  /// "Core combinations"
  /// ```
  String get galleryLayoutsTitle => """Core combinations""";

  /// ```dart
  /// "Horizontal and side variations for documentation, operational dashboards, and review areas."
  /// ```
  String get galleryLayoutsIntro =>
      """Horizontal and side variations for documentation, operational dashboards, and review areas.""";

  /// ```dart
  /// "Composition and lifecycle"
  /// ```
  String get galleryAdvancedTitle => """Composition and lifecycle""";

  /// ```dart
  /// "Examples with projected headers, richer visual semantics, and panes rendered on demand."
  /// ```
  String get galleryAdvancedIntro =>
      """Examples with projected headers, richer visual semantics, and panes rendered on demand.""";

  /// ```dart
  /// "Basic tabs"
  /// ```
  String get basicCardTitle => """Basic tabs""";

  /// ```dart
  /// "A simple horizontal structure to split summary, metrics, and history without leaving the page."
  /// ```
  String get basicCardBody =>
      """A simple horizontal structure to split summary, metrics, and history without leaving the page.""";

  /// ```dart
  /// "Config: type=tabs"
  /// ```
  String get basicCardConfig => """Config: type=tabs""";

  /// ```dart
  /// "Summary"
  /// ```
  String get basicSummary => """Summary""";

  /// ```dart
  /// "Keep goals, context, and recent decisions in a short opening panel optimized for first-pass reading."
  /// ```
  String get basicSummaryBody =>
      """Keep goals, context, and recent decisions in a short opening panel optimized for first-pass reading.""";

  /// ```dart
  /// "Metrics"
  /// ```
  String get basicMetrics => """Metrics""";

  /// ```dart
  /// "Use the second tab for indicators that support the narrative without competing with the main content."
  /// ```
  String get basicMetricsBody =>
      """Use the second tab for indicators that support the narrative without competing with the main content.""";

  /// ```dart
  /// "History"
  /// ```
  String get basicHistory => """History""";

  /// ```dart
  /// "Reserve the third tab for events, changelog items, or auditable notes when the flow requires traceability."
  /// ```
  String get basicHistoryBody =>
      """Reserve the third tab for events, changelog items, or auditable notes when the flow requires traceability.""";

  /// ```dart
  /// "Justified tabs"
  /// ```
  String get justifiedCardTitle => """Justified tabs""";

  /// ```dart
  /// "Distributes the main screen areas with equal width to keep the visual hierarchy stable."
  /// ```
  String get justifiedCardBody =>
      """Distributes the main screen areas with equal width to keep the visual hierarchy stable.""";

  /// ```dart
  /// "Config: type=tabs, justified=true"
  /// ```
  String get justifiedCardConfig => """Config: type=tabs, justified=true""";

  /// ```dart
  /// "Backlog"
  /// ```
  String get justifiedBacklog => """Backlog""";

  /// ```dart
  /// "When each stage carries the same weight, the justified layout helps communicate equal priority across sections."
  /// ```
  String get justifiedBacklogBody =>
      """When each stage carries the same weight, the justified layout helps communicate equal priority across sections.""";

  /// ```dart
  /// "Delivery"
  /// ```
  String get justifiedDelivery => """Delivery""";

  /// ```dart
  /// "This format works well in compact cards, status boards, and documentation pages with limited horizontal space."
  /// ```
  String get justifiedDeliveryBody =>
      """This format works well in compact cards, status boards, and documentation pages with limited horizontal space.""";

  /// ```dart
  /// "Risks"
  /// ```
  String get justifiedRisks => """Risks""";

  /// ```dart
  /// "It is also useful to place critical areas side by side without relying on extra helper text to balance the navigation."
  /// ```
  String get justifiedRisksBody =>
      """It is also useful to place critical areas side by side without relying on extra helper text to balance the navigation.""";

  /// ```dart
  /// "Side pills"
  /// ```
  String get sideCardTitle => """Side pills""";

  /// ```dart
  /// "A good option when navigation behaves like a context menu and content needs more horizontal room."
  /// ```
  String get sideCardBody =>
      """A good option when navigation behaves like a context menu and content needs more horizontal room.""";

  /// ```dart
  /// "Config: type=pills, placement=left"
  /// ```
  String get sideCardConfig => """Config: type=pills, placement=left""";

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
  /// "Use the side rail to group visual variants, tokens, or example families without overloading the top navigation."
  /// ```
  String get tokensBody =>
      """Use the side rail to group visual variants, tokens, or example families without overloading the top navigation.""";

  /// ```dart
  /// "A side layout works well for dependency-heavy journeys, especially when each pane needs more explanatory text."
  /// ```
  String get flowBody =>
      """A side layout works well for dependency-heavy journeys, especially when each pane needs more explanatory text.""";

  /// ```dart
  /// "Disable entries temporarily when a stage depends on permissions, rollout, or data that is not available yet."
  /// ```
  String get blockedBody =>
      """Disable entries temporarily when a stage depends on permissions, rollout, or data that is not available yet.""";

  /// ```dart
  /// "Right-aligned tabs"
  /// ```
  String get rightCardTitle => """Right-aligned tabs""";

  /// ```dart
  /// "Useful for review and approval flows when the main content should remain on the left reading axis."
  /// ```
  String get rightCardBody =>
      """Useful for review and approval flows when the main content should remain on the left reading axis.""";

  /// ```dart
  /// "Config: type=tabs, placement=right"
  /// ```
  String get rightCardConfig => """Config: type=tabs, placement=right""";

  /// ```dart
  /// "Review"
  /// ```
  String get review => """Review""";

  /// ```dart
  /// "Place checklist, decision notes, and rationale in a dedicated pane to reduce context switching during validation."
  /// ```
  String get reviewBody =>
      """Place checklist, decision notes, and rationale in a dedicated pane to reduce context switching during validation.""";

  /// ```dart
  /// "Approvers"
  /// ```
  String get approvers => """Approvers""";

  /// ```dart
  /// "The middle tab works well for owners, roles, and acceptance criteria when governance is more formal."
  /// ```
  String get approversBody =>
      """The middle tab works well for owners, roles, and acceptance criteria when governance is more formal.""";

  /// ```dart
  /// "SLA"
  /// ```
  String get sla => """SLA""";

  /// ```dart
  /// "The third tab can consolidate deadlines, release windows, and escalation rules without competing with the main content."
  /// ```
  String get slaBody =>
      """The third tab can consolidate deadlines, release windows, and escalation rules without competing with the main content.""";

  /// ```dart
  /// "Projected header"
  /// ```
  String get workflowCardTitle => """Projected header""";

  /// ```dart
  /// "Combines icons, badges, and subtitles in the tab trigger to signal status and workload density."
  /// ```
  String get workflowCardBody =>
      """Combines icons, badges, and subtitles in the tab trigger to signal status and workload density.""";

  /// ```dart
  /// "Config: template li-tabx-header"
  /// ```
  String get workflowCardConfig => """Config: template li-tabx-header""";

  /// ```dart
  /// "Discovery"
  /// ```
  String get discovery => """Discovery""";

  /// ```dart
  /// "Scope and dependencies"
  /// ```
  String get discoveryHint => """Scope and dependencies""";

  /// ```dart
  /// "Execution"
  /// ```
  String get execution => """Execution""";

  /// ```dart
  /// "Implementation and QA"
  /// ```
  String get executionHint => """Implementation and QA""";

  /// ```dart
  /// "Publish"
  /// ```
  String get publish => """Publish""";

  /// ```dart
  /// "Rollout and communication"
  /// ```
  String get publishHint => """Rollout and communication""";

  /// ```dart
  /// "Use projected headers when a plain label is no longer enough and the tab needs to carry visible operational context."
  /// ```
  String get workflowDiscoveryBody =>
      """Use projected headers when a plain label is no longer enough and the tab needs to carry visible operational context.""";

  /// ```dart
  /// "Badges and subtitles help signal volume, stage, or criticality without requiring extra legends in the page body."
  /// ```
  String get workflowExecutionBody =>
      """Badges and subtitles help signal volume, stage, or criticality without requiring extra legends in the page body.""";

  /// ```dart
  /// "This pattern brings the demo closer to the Limitless visual language in richer, status-oriented navigation scenarios."
  /// ```
  String get workflowPublishBody =>
      """This pattern brings the demo closer to the Limitless visual language in richer, status-oriented navigation scenarios.""";

  /// ```dart
  /// "Lazy loading and teardown"
  /// ```
  String get lifecycleCardTitle => """Lazy loading and teardown""";

  /// ```dart
  /// "Renders panes on demand and removes inactive content from the DOM to reduce cost in heavy tab sets."
  /// ```
  String get lifecycleCardBody =>
      """Renders panes on demand and removes inactive content from the DOM to reduce cost in heavy tab sets.""";

  /// ```dart
  /// "Config: lazyLoad=true, destroyOnHide=true"
  /// ```
  String get lifecycleCardConfig =>
      """Config: lazyLoad=true, destroyOnHide=true""";

  /// ```dart
  /// "Dataset"
  /// ```
  String get dataset => """Dataset""";

  /// ```dart
  /// "Open with a light overview and leave expensive steps for the moment the user actually navigates to those tabs."
  /// ```
  String get datasetBody =>
      """Open with a light overview and leave expensive steps for the moment the user actually navigates to those tabs.""";

  /// ```dart
  /// "Transform"
  /// ```
  String get transform => """Transform""";

  /// ```dart
  /// "lazyLoad prevents complex charts, grids, or forms from mounting before the corresponding tab is first activated."
  /// ```
  String get transformBody =>
      """lazyLoad prevents complex charts, grids, or forms from mounting before the corresponding tab is first activated.""";

  /// ```dart
  /// "Export"
  /// ```
  String get export => """Export""";

  /// ```dart
  /// "destroyOnHide is useful when inactive content keeps listeners, tables, or state that should not live outside focus."
  /// ```
  String get exportBody =>
      """destroyOnHide is useful when inactive content keeps listeners, tables, or state that should not live outside focus.""";
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
  /// "The select demo shows stable dataSource usage and manual option projection, bringing description, features, limitations, and visible examples together in the same flow."
  /// ```
  String get overviewIntro =>
      """The select demo shows stable dataSource usage and manual option projection, bringing description, features, limitations, and visible examples together in the same flow.""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionTitle => """Description""";

  /// ```dart
  /// "The component solves simple selection with overlay, projected options, and direct ngModel binding."
  /// ```
  String get descriptionBody =>
      """The component solves simple selection with overlay, projected options, and direct ngModel binding.""";

  /// ```dart
  /// "Features"
  /// ```
  String get featuresTitle => """Features""";

  /// ```dart
  /// "External source through dataSource."
  /// ```
  String get featureOne => """External source through dataSource.""";

  /// ```dart
  /// "Manual projection with li-option."
  /// ```
  String get featureTwo => """Manual projection with li-option.""";

  /// ```dart
  /// "Placeholder, disabled items, and simple binding."
  /// ```
  String get featureThree =>
      """Placeholder, disabled items, and simple binding.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "Avoid recreating dataSource in reactive getters."
  /// ```
  String get limitOne => """Avoid recreating dataSource in reactive getters.""";

  /// ```dart
  /// "The overlay depends on consistent options for navigation and height."
  /// ```
  String get limitTwo =>
      """The overlay depends on consistent options for navigation and height.""";

  /// ```dart
  /// "For heavy filtering logic, keep orchestration in the parent component."
  /// ```
  String get limitThree =>
      """For heavy filtering logic, keep orchestration in the parent component.""";

  /// ```dart
  /// "How to use"
  /// ```
  String get apiTitle => """How to use""";

  /// ```dart
  /// "li-select accepts both [dataSource] and li-option projection. To avoid freezes and unnecessary render cycles, prefer providing stable lists from the parent component instead of getters that recreate the array whenever state changes."
  /// ```
  String get apiIntro =>
      """li-select accepts both [dataSource] and li-option projection. To avoid freezes and unnecessary render cycles, prefer providing stable lists from the parent component instead of getters that recreate the array whenever state changes.""";

  /// ```dart
  /// "external option list."
  /// ```
  String get apiDataSource => """external option list.""";

  /// ```dart
  /// "key used for visible text."
  /// ```
  String get apiLabelKey => """key used for visible text.""";

  /// ```dart
  /// "key used as the ngModel value."
  /// ```
  String get apiValueKey => """key used as the ngModel value.""";

  /// ```dart
  /// "boolean key used to disable items."
  /// ```
  String get apiDisabledKey => """boolean key used to disable items.""";

  /// ```dart
  /// "selected value."
  /// ```
  String get apiNgModel => """selected value.""";

  /// ```dart
  /// "text shown when empty."
  /// ```
  String get apiPlaceholder => """text shown when empty.""";

  /// ```dart
  /// "Notes and limits"
  /// ```
  String get notesTitle => """Notes and limits""";

  /// ```dart
  /// "Do not recreate dataSource in getters."
  /// ```
  String get noteOne => """Do not recreate dataSource in getters.""";

  /// ```dart
  /// "The overlay should not calculate height from its own rendered panel."
  /// ```
  String get noteTwo =>
      """The overlay should not calculate height from its own rendered panel.""";

  /// ```dart
  /// "Global keyboard events should handle only navigation and escape."
  /// ```
  String get noteThree =>
      """Global keyboard events should handle only navigation and escape.""";

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
  /// "The multi-select demo shows multiple selection with a stable dataSource, manual projection, and documentation organized between overview and API."
  /// ```
  String get overviewIntro =>
      """The multi-select demo shows multiple selection with a stable dataSource, manual projection, and documentation organized between overview and API.""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionTitle => """Description""";

  /// ```dart
  /// "The component keeps a collection of selected values and projects the result directly in the trigger."
  /// ```
  String get descriptionBody =>
      """The component keeps a collection of selected values and projects the result directly in the trigger.""";

  /// ```dart
  /// "Features"
  /// ```
  String get featuresTitle => """Features""";

  /// ```dart
  /// "Multiple selection with badges and placeholder."
  /// ```
  String get featureOne =>
      """Multiple selection with badges and placeholder.""";

  /// ```dart
  /// "Clear-selection button next to the arrow when values are selected."
  /// ```
  String get featureTwo =>
      """Clear-selection button next to the arrow when values are selected.""";

  /// ```dart
  /// "Integration with dataSource or li-multi-option."
  /// ```
  String get featureThree =>
      """Integration with dataSource or li-multi-option.""";

  /// ```dart
  /// "Direct binding with ngModel lists."
  /// ```
  String get featureFour => """Direct binding with ngModel lists.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "Avoid recreating option lists in reactive getters."
  /// ```
  String get limitOne =>
      """Avoid recreating option lists in reactive getters.""";

  /// ```dart
  /// "The overlay needs a consistent refresh when the selection changes."
  /// ```
  String get limitTwo =>
      """The overlay needs a consistent refresh when the selection changes.""";

  /// ```dart
  /// "For very large collections, keep pagination or search in the parent."
  /// ```
  String get limitThree =>
      """For very large collections, keep pagination or search in the parent.""";

  /// ```dart
  /// "How to use"
  /// ```
  String get apiTitle => """How to use""";

  /// ```dart
  /// "li-multi-select follows the same strategy as li-select, but keeps multiple selected values and renders badges in the trigger."
  /// ```
  String get apiIntroOne =>
      """li-multi-select follows the same strategy as li-select, but keeps multiple selected values and renders badges in the trigger.""";

  /// ```dart
  /// "The recommended pattern for the demo and production is to keep dataSource stable and update only the selected values collection."
  /// ```
  String get apiIntroTwo =>
      """The recommended pattern for the demo and production is to keep dataSource stable and update only the selected values collection.""";

  /// ```dart
  /// "external option list."
  /// ```
  String get apiDataSource => """external option list.""";

  /// ```dart
  /// "key used for visible text."
  /// ```
  String get apiLabelKey => """key used for visible text.""";

  /// ```dart
  /// "key used in the ngModel array."
  /// ```
  String get apiValueKey => """key used in the ngModel array.""";

  /// ```dart
  /// "list of selected values."
  /// ```
  String get apiNgModel => """list of selected values.""";

  /// ```dart
  /// "text shown when nothing is selected."
  /// ```
  String get apiPlaceholder => """text shown when nothing is selected.""";

  /// ```dart
  /// "shows the X button to clear everything in the trigger."
  /// ```
  String get apiShowClearButton =>
      """shows the X button to clear everything in the trigger.""";

  /// ```dart
  /// "Notes and limits"
  /// ```
  String get notesTitle => """Notes and limits""";

  /// ```dart
  /// "Do not recreate the option list in reactive getters."
  /// ```
  String get noteOne =>
      """Do not recreate the option list in reactive getters.""";

  /// ```dart
  /// "Schedule overlay.update() on a future frame when the selection changes."
  /// ```
  String get noteTwo =>
      """Schedule overlay.update() on a future frame when the selection changes.""";

  /// ```dart
  /// "Calculate maxHeight from the viewport, not from the current panel height."
  /// ```
  String get noteThree =>
      """Calculate maxHeight from the viewport, not from the current panel height.""";

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

  /// ```dart
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionTitle => """Description""";

  /// ```dart
  /// "The monetary field handles visual formatting and conversion to minor units without extra template logic."
  /// ```
  String get descriptionBody =>
      """The monetary field handles visual formatting and conversion to minor units without extra template logic.""";

  /// ```dart
  /// "Features"
  /// ```
  String get featuresTitle => """Features""";

  /// ```dart
  /// "Support for locale and currencyCode."
  /// ```
  String get featureOne => """Support for locale and currencyCode.""";

  /// ```dart
  /// "Automatic conversion to minor units."
  /// ```
  String get featureTwo => """Automatic conversion to minor units.""";

  /// ```dart
  /// "AngularDart forms integration."
  /// ```
  String get featureThree => """AngularDart forms integration.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "The field does not replace fiscal business rules."
  /// ```
  String get limitOne =>
      """The field does not replace fiscal business rules.""";

  /// ```dart
  /// "Very specific masks require additional extension."
  /// ```
  String get limitTwo =>
      """Very specific masks require additional extension.""";

  /// ```dart
  /// "The persisted value remains numeric."
  /// ```
  String get limitThree => """The persisted value remains numeric.""";

  /// ```dart
  /// "The same component now accepts BRL, USD, and EUR by changing only currencyCode and locale."
  /// ```
  String get summaryHelp =>
      """The same component now accepts BRL, USD, and EUR by changing only currencyCode and locale.""";

  /// ```dart
  /// "Use the component to display a formatted value to the user while keeping a consistent minor-unit number in state."
  /// ```
  String get apiIntro =>
      """Use the component to display a formatted value to the user while keeping a consistent minor-unit number in state.""";

  /// ```dart
  /// "[(ngModel)] works with the value in minor units."
  /// ```
  String get apiOne => """[(ngModel)] works with the value in minor units.""";

  /// ```dart
  /// "currencyCode and locale control symbol and separators."
  /// ```
  String get apiTwo =>
      """currencyCode and locale control symbol and separators.""";

  /// ```dart
  /// "prefix remains available to override the automatically resolved symbol."
  /// ```
  String get apiThree =>
      """prefix remains available to override the automatically resolved symbol.""";

  /// ```dart
  /// "[required] integrates validation into the form."
  /// ```
  String get apiFour => """[required] integrates validation into the form.""";

  /// ```dart
  /// "inputClass lets you apply utility classes to the field."
  /// ```
  String get apiFive =>
      """inputClass lets you apply utility classes to the field.""";
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
  /// "Overview"
  /// ```
  String get tabOverview => """Overview""";

  /// ```dart
  /// "API"
  /// ```
  String get tabApi => """API""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionTitle => """Description""";

  /// ```dart
  /// "The date range picker fits continuous period flows for filters, sprints, releases, and operational slices."
  /// ```
  String get descriptionBody =>
      """The date range picker fits continuous period flows for filters, sprints, releases, and operational slices.""";

  /// ```dart
  /// "Features"
  /// ```
  String get featuresTitle => """Features""";

  /// ```dart
  /// "Separate start and end binding."
  /// ```
  String get featureOne => """Separate start and end binding.""";

  /// ```dart
  /// "Minimum and maximum interval restrictions."
  /// ```
  String get featureTwo => """Minimum and maximum interval restrictions.""";

  /// ```dart
  /// "Configurable placeholder and locale."
  /// ```
  String get featureThree => """Configurable placeholder and locale.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "The component does not apply business-calendar rules on its own."
  /// ```
  String get limitOne =>
      """The component does not apply business-calendar rules on its own.""";

  /// ```dart
  /// "More specific validations still belong in the parent."
  /// ```
  String get limitTwo =>
      """More specific validations still belong in the parent.""";

  /// ```dart
  /// "Complex flows may require external presets."
  /// ```
  String get limitThree => """Complex flows may require external presets.""";

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

  /// ```dart
  /// "Use the component when the flow depends on a range with start and end dates clearly controlled by the parent component."
  /// ```
  String get apiIntro =>
      """Use the component when the flow depends on a range with start and end dates clearly controlled by the parent component.""";

  /// ```dart
  /// "[inicio] or [start], with (inicioChange) or (startChange), control the start date."
  /// ```
  String get apiOne =>
      """[inicio] or [start], with (inicioChange) or (startChange), control the start date.""";

  /// ```dart
  /// "[fim] or [end], with (fimChange) or (endChange), control the end date."
  /// ```
  String get apiTwo =>
      """[fim] or [end], with (fimChange) or (endChange), control the end date.""";

  /// ```dart
  /// "[minDate] and [maxDate] restrict the selectable window."
  /// ```
  String get apiThree =>
      """[minDate] and [maxDate] restrict the selectable window.""";

  /// ```dart
  /// "[placeholder] and locale adjust the field communication."
  /// ```
  String get apiFour =>
      """[placeholder] and locale adjust the field communication.""";
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
  /// "Support for 12-hour AM/PM and 24-hour display modes."
  /// ```
  String get featureThree =>
      """Support for 12-hour AM/PM and 24-hour display modes.""";

  /// ```dart
  /// "Limitations"
  /// ```
  String get limitsTitle => """Limitations""";

  /// ```dart
  /// "The displayed format depends on use24Hour and the configured locale."
  /// ```
  String get limitOne =>
      """The displayed format depends on use24Hour and the configured locale.""";

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
  /// "24-hour time picker"
  /// ```
  String get twentyFourHourTitle => """24-hour time picker""";

  /// ```dart
  /// "Select time"
  /// ```
  String get twentyFourHourPlaceholder => """Select time""";

  /// ```dart
  /// "Current time"
  /// ```
  String get twentyFourHourCurrentLabel => """Current time""";

  /// ```dart
  /// "Use use24Hour to display and edit the value without AM/PM."
  /// ```
  String get twentyFourHourHelp =>
      """Use use24Hour to display and edit the value without AM/PM.""";

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
  /// "This library datatable covers the most common administrative flow: field search, row selection, export, pagination, sorting, responsive collapse, and a layer of visual customization per column, row, and card."
  /// ```
  String get overviewIntro =>
      """This library datatable covers the most common administrative flow: field search, row selection, export, pagination, sorting, responsive collapse, and a layer of visual customization per column, row, and card.""";

  /// ```dart
  /// "The component serves operational listings that need to switch between table and grid without duplicating the data source, sorting rules, or search behavior."
  /// ```
  String get descriptionBody =>
      """The component serves operational listings that need to switch between table and grid without duplicating the data source, sorting rules, or search behavior.""";

  /// ```dart
  /// "Column-aware search with configurable field and operator."
  /// ```
  String get featureOne =>
      """Column-aware search with configurable field and operator.""";

  /// ```dart
  /// "XLSX and PDF export through the component API itself."
  /// ```
  String get featureTwo =>
      """XLSX and PDF export through the component API itself.""";

  /// ```dart
  /// "Table and grid modes with the same data source."
  /// ```
  String get featureThree =>
      """Table and grid modes with the same data source.""";

  /// ```dart
  /// "Width, alignment, classes, and styles per column and per row."
  /// ```
  String get featureFour =>
      """Width, alignment, classes, and styles per column and per row.""";

  /// ```dart
  /// "Custom cards with customCardBuilder in grid mode."
  /// ```
  String get featureFive =>
      """Custom cards with customCardBuilder in grid mode.""";

  /// ```dart
  /// "cellStyleResolver works with inline CSS, so it does not replace a full theme."
  /// ```
  String get limitOne =>
      """cellStyleResolver works with inline CSS, so it does not replace a full theme.""";

  /// ```dart
  /// "customCardBuilder is ideal for rich cards, but requires manual markup assembly."
  /// ```
  String get limitTwo =>
      """customCardBuilder is ideal for rich cards, but requires manual markup assembly.""";

  /// ```dart
  /// "Mobile collapse is still column-oriented, so very dense layouts need curation of secondary columns."
  /// ```
  String get limitThree =>
      """Mobile collapse is still column-oriented, so very dense layouts need curation of secondary columns.""";

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
  /// "Main demo with search, selection, export, and switching between table and grid."
  /// ```
  String get demoIntro =>
      """Main demo with search, selection, export, and switching between table and grid.""";

  /// ```dart
  /// "On-demand demos"
  /// ```
  String get onDemandTitle => """On-demand demos""";

  /// ```dart
  /// "The examples below use li-accordion with lazy loading to keep every datatable out of the DOM until the route section is opened."
  /// ```
  String get onDemandIntro =>
      """The examples below use li-accordion with lazy loading to keep every datatable out of the DOM until the route section is opened.""";

  /// ```dart
  /// "Read-only example"
  /// ```
  String get readonlyTitle => """Read-only example""";

  /// ```dart
  /// "Search and sorting without row clicks or selection."
  /// ```
  String get readonlyDescription =>
      """Search and sorting without row clicks or selection.""";

  /// ```dart
  /// "Grid mode example"
  /// ```
  String get gridPreviewTitle => """Grid mode example""";

  /// ```dart
  /// "The same dataset reused as cards."
  /// ```
  String get gridPreviewDescription => """The same dataset reused as cards.""";

  /// ```dart
  /// "Table with width, per-column color, and per-row color"
  /// ```
  String get customTableTitle =>
      """Table with width, per-column color, and per-row color""";

  /// ```dart
  /// "Combines fixed width, cellStyleResolver, and rowStyleResolver in the same scenario."
  /// ```
  String get customTableDescription =>
      """Combines fixed width, cellStyleResolver, and rowStyleResolver in the same scenario.""";

  /// ```dart
  /// "Grid with customCardBuilder"
  /// ```
  String get customGridTitle => """Grid with customCardBuilder""";

  /// ```dart
  /// "Manually assembled card only when the item is opened."
  /// ```
  String get customGridDescription =>
      """Manually assembled card only when the item is opened.""";

  /// ```dart
  /// "Lazy loading modal with datatable"
  /// ```
  String get lazyModalTitle => """Lazy loading modal with datatable""";

  /// ```dart
  /// "This scenario opens a li-modal with lazyContent and instantiates li-datatable only after opening."
  /// ```
  String get lazyModalIntro =>
      """This scenario opens a li-modal with lazyContent and instantiates li-datatable only after opening.""";

  /// ```dart
  /// "Open lazy modal"
  /// ```
  String get openLazyModal => """Open lazy modal""";

  /// ```dart
  /// "Lazy modal with datatable"
  /// ```
  String get modalTitle => """Lazy modal with datatable""";

  /// ```dart
  /// "Modal content only enters the DOM when it opens. The datatable reuses the page dataset to verify that first render works correctly."
  /// ```
  String get modalBody =>
      """Modal content only enters the DOM when it opens. The datatable reuses the page dataset to verify that first render works correctly.""";

  /// ```dart
  /// "The component is driven by three parts: Filters for pagination and search, DataFrame for data, and DatatableSettings for columns and visual behavior."
  /// ```
  String get howToUseBody =>
      """The component is driven by three parts: Filters for pagination and search, DataFrame for data, and DatatableSettings for columns and visual behavior.""";

  /// ```dart
  /// "[dataTableFilter]: controls limit, offset, search, and sorting."
  /// ```
  String get optionOne =>
      """[dataTableFilter]: controls limit, offset, search, and sorting.""";

  /// ```dart
  /// "[settings]: defines columns, grid, and custom builders."
  /// ```
  String get optionTwo =>
      """[settings]: defines columns, grid, and custom builders.""";

  /// ```dart
  /// "[searchInFields]: declares which fields appear in the search selector."
  /// ```
  String get optionThree =>
      """[searchInFields]: declares which fields appear in the search selector.""";

  /// ```dart
  /// "[responsiveCollapse]: moves secondary columns into the child row on mobile."
  /// ```
  String get optionFour =>
      """[responsiveCollapse]: moves secondary columns into the child row on mobile.""";

  /// ```dart
  /// "Keep DataFrame stable and update only filters and selection."
  /// ```
  String get practiceOne =>
      """Keep DataFrame stable and update only filters and selection.""";

  /// ```dart
  /// "Use hideOnMobile on secondary columns."
  /// ```
  String get practiceTwo => """Use hideOnMobile on secondary columns.""";

  /// ```dart
  /// "Reserve customCardBuilder for grids that really need to depart from the default layout."
  /// ```
  String get practiceThree =>
      """Reserve customCardBuilder for grids that really need to depart from the default layout.""";

  /// ```dart
  /// "Columns and styles"
  /// ```
  String get columnStylesTitle => """Columns and styles""";

  /// ```dart
  /// "width, minWidth, and maxWidth control the effective column width."
  /// ```
  String get columnStyleOne =>
      """width, minWidth, and maxWidth control the effective column width.""";

  /// ```dart
  /// "headerClass and cellClass add classes without touching the template."
  /// ```
  String get columnStyleTwo =>
      """headerClass and cellClass add classes without touching the template.""";

  /// ```dart
  /// "styleCss and cellStyleResolver control color and style per column."
  /// ```
  String get columnStyleThree =>
      """styleCss and cellStyleResolver control color and style per column.""";

  /// ```dart
  /// "rowStyleResolver returns a CSS string for the whole row based on the data."
  /// ```
  String get columnStyleFour =>
      """rowStyleResolver returns a CSS string for the whole row based on the data.""";

  /// ```dart
  /// "textAlign and nowrap improve readability for short columns or statuses."
  /// ```
  String get columnStyleFive =>
      """textAlign and nowrap improve readability for short columns or statuses.""";

  /// ```dart
  /// "CustomCardBuilder"
  /// ```
  String get customCardEyebrow => """CustomCardBuilder""";

  /// ```dart
  /// "Owner"
  /// ```
  String get ownerPrefix => """Owner""";

  /// ```dart
  /// "The card was manually assembled to combine title, state, and metadata without depending on the default layout."
  /// ```
  String get customCardSummary =>
      """The card was manually assembled to combine title, state, and metadata without depending on the default layout.""";

  /// ```dart
  /// "Sync ERP registrations"
  /// ```
  String get featureRow5 => """Sync ERP registrations""";

  /// ```dart
  /// "Publish operational report"
  /// ```
  String get featureRow6 => """Publish operational report""";

  /// ```dart
  /// "Review integration queue"
  /// ```
  String get featureRow7 => """Review integration queue""";

  /// ```dart
  /// "Update support dashboard"
  /// ```
  String get featureRow8 => """Update support dashboard""";

  /// ```dart
  /// "Finance"
  /// ```
  String get ownerFinance => """Finance""";

  /// ```dart
  /// "Support"
  /// ```
  String get ownerSupport => """Support""";

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

class DatatableSelectPagesMessagesEn extends DatatableSelectPagesMessages {
  final PagesMessagesEn _parent;
  const DatatableSelectPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "Datatable Select"
  /// ```
  String get subtitle => """Datatable Select""";

  /// ```dart
  /// "Select with datatable modal"
  /// ```
  String get breadcrumb => """Select with datatable modal""";

  /// ```dart
  /// "A select that opens a modal with a full datatable, allowing search, pagination, and sorting. Clicking a row selects the item and closes the modal."
  /// ```
  String get overviewIntro =>
      """A select that opens a modal with a full datatable, allowing search, pagination, and sorting. Clicking a row selects the item and closes the modal.""";

  /// ```dart
  /// "The component combines a form-select-style trigger with a modal that displays a complete li-datatable. It implements ControlValueAccessor for ngModel compatibility."
  /// ```
  String get descriptionBody =>
      """The component combines a form-select-style trigger with a modal that displays a complete li-datatable. It implements ControlValueAccessor for ngModel compatibility.""";

  /// ```dart
  /// "Search, pagination, and sorting through li-datatable."
  /// ```
  String get featureOne =>
      """Search, pagination, and sorting through li-datatable.""";

  /// ```dart
  /// "Selection by row click."
  /// ```
  String get featureTwo => """Selection by row click.""";

  /// ```dart
  /// "Support for ngModel and currentValueChange."
  /// ```
  String get featureThree => """Support for ngModel and currentValueChange.""";

  /// ```dart
  /// "Configurable modal size."
  /// ```
  String get featureFour => """Configurable modal size.""";

  /// ```dart
  /// "Disabled and programmatic states."
  /// ```
  String get featureFive => """Disabled and programmatic states.""";

  /// ```dart
  /// "Requires dataRequest to provide data to the datatable."
  /// ```
  String get limitOne =>
      """Requires dataRequest to provide data to the datatable.""";

  /// ```dart
  /// "The displayed label depends on labelKey without custom projection."
  /// ```
  String get limitTwo =>
      """The displayed label depends on labelKey without custom projection.""";

  /// ```dart
  /// "Does not support multiple selection."
  /// ```
  String get limitThree => """Does not support multiple selection.""";

  /// ```dart
  /// "Basic usage with currentValueChange and programmatic control."
  /// ```
  String get demoIntro =>
      """Basic usage with currentValueChange and programmatic control.""";

  /// ```dart
  /// "Select Maria Silva"
  /// ```
  String get selectMaria => """Select Maria Silva""";

  /// ```dart
  /// "Select person"
  /// ```
  String get selectPersonLabel => """Select person""";

  /// ```dart
  /// "Select person"
  /// ```
  String get modalTitle => """Select person""";

  /// ```dart
  /// "Click to select..."
  /// ```
  String get placeholder => """Click to select...""";

  /// ```dart
  /// "Search by name, email..."
  /// ```
  String get searchPlaceholder => """Search by name, email...""";

  /// ```dart
  /// "Disabled state, the trigger stays inactive and does not open the modal."
  /// ```
  String get disabledIntro =>
      """Disabled state, the trigger stays inactive and does not open the modal.""";

  /// ```dart
  /// "Person (disabled)"
  /// ```
  String get disabledLabel => """Person (disabled)""";

  /// ```dart
  /// "Disabled field"
  /// ```
  String get disabledPlaceholder => """Disabled field""";

  /// ```dart
  /// "Binding with ngModel. The value is synchronized through ControlValueAccessor."
  /// ```
  String get ngModelIntro =>
      """Binding with ngModel. The value is synchronized through ControlValueAccessor.""";

  /// ```dart
  /// "Select person (ngModel)"
  /// ```
  String get ngModelLabel => """Select person (ngModel)""";

  /// ```dart
  /// "The component is driven by three parts: Filters for pagination and search, DataFrame for data, and DatatableSettings for columns. Clicking the trigger opens a modal with the datatable; clicking a row completes the selection."
  /// ```
  String get howToUseBody =>
      """The component is driven by three parts: Filters for pagination and search, DataFrame for data, and DatatableSettings for columns. Clicking the trigger opens a modal with the datatable; clicking a row completes the selection.""";

  /// ```dart
  /// "[settings]: datatable column definitions."
  /// ```
  String get optionOne => """[settings]: datatable column definitions.""";

  /// ```dart
  /// "[data]: DataFrame with paginated data."
  /// ```
  String get optionTwo => """[data]: DataFrame with paginated data.""";

  /// ```dart
  /// "[dataTableFilter]: search and pagination filters."
  /// ```
  String get optionThree =>
      """[dataTableFilter]: search and pagination filters.""";

  /// ```dart
  /// "[searchInFields]: search fields."
  /// ```
  String get optionFour => """[searchInFields]: search fields.""";

  /// ```dart
  /// "[labelKey]: key for the text shown in the trigger."
  /// ```
  String get optionFive =>
      """[labelKey]: key for the text shown in the trigger.""";

  /// ```dart
  /// "[valueKey]: key for the value; null means the whole instance."
  /// ```
  String get optionSix =>
      """[valueKey]: key for the value; null means the whole instance.""";

  /// ```dart
  /// "[placeholder]: text shown when no item is selected."
  /// ```
  String get optionSeven =>
      """[placeholder]: text shown when no item is selected.""";

  /// ```dart
  /// "[title]: modal title."
  /// ```
  String get optionEight => """[title]: modal title.""";

  /// ```dart
  /// "[modalSize]: modal size (large, xtra-large, xx-large, xxx-large, fluid, modal-full)."
  /// ```
  String get optionNine =>
      """[modalSize]: modal size (large, xtra-large, xx-large, xxx-large, fluid, modal-full).""";

  /// ```dart
  /// "[disabled]: disables the component."
  /// ```
  String get optionTen => """[disabled]: disables the component.""";

  /// ```dart
  /// "[fullScreenOnMobile]: fullscreen modal on mobile."
  /// ```
  String get optionEleven =>
      """[fullScreenOnMobile]: fullscreen modal on mobile.""";

  /// ```dart
  /// "(dataRequest): emitted when the datatable requests data."
  /// ```
  String get outputOne =>
      """(dataRequest): emitted when the datatable requests data.""";

  /// ```dart
  /// "(currentValueChange): emitted when the selected value changes."
  /// ```
  String get outputTwo =>
      """(currentValueChange): emitted when the selected value changes.""";

  /// ```dart
  /// "(limitChange): emitted when the page-size limit changes."
  /// ```
  String get outputThree =>
      """(limitChange): emitted when the page-size limit changes.""";

  /// ```dart
  /// "(searchRequest): emitted when a search is submitted."
  /// ```
  String get outputFour =>
      """(searchRequest): emitted when a search is submitted.""";

  /// ```dart
  /// "clear(): clears the selection."
  /// ```
  String get methodOne => """clear(): clears the selection.""";

  /// ```dart
  /// "setSelectedItem({label, value}): sets the selection programmatically."
  /// ```
  String get methodTwo =>
      """setSelectedItem({label, value}): sets the selection programmatically.""";

  /// ```dart
  /// "selectedLabel: getter that returns the current label."
  /// ```
  String get methodThree =>
      """selectedLabel: getter that returns the current label.""";

  /// ```dart
  /// "Compatible with ngModel through ControlValueAccessor."
  /// ```
  String get noteOne =>
      """Compatible with ngModel through ControlValueAccessor.""";

  /// ```dart
  /// "Keep DataFrame stable; update only through (dataRequest)."
  /// ```
  String get noteTwo =>
      """Keep DataFrame stable; update only through (dataRequest).""";

  /// ```dart
  /// "The clear button in the trigger appears when a value is selected."
  /// ```
  String get noteThree =>
      """The clear button in the trigger appears when a value is selected.""";

  /// ```dart
  /// "ID"
  /// ```
  String get columnId => """ID""";

  /// ```dart
  /// "Name"
  /// ```
  String get columnName => """Name""";

  /// ```dart
  /// "Email"
  /// ```
  String get columnEmail => """Email""";

  /// ```dart
  /// "Department"
  /// ```
  String get columnDepartment => """Department""";

  /// ```dart
  /// "Name"
  /// ```
  String get searchName => """Name""";

  /// ```dart
  /// "Email"
  /// ```
  String get searchEmail => """Email""";

  /// ```dart
  /// "Department"
  /// ```
  String get searchDepartment => """Department""";

  /// ```dart
  /// "Engineering"
  /// ```
  String get departmentEngineering => """Engineering""";

  /// ```dart
  /// "Design"
  /// ```
  String get departmentDesign => """Design""";

  /// ```dart
  /// "Marketing"
  /// ```
  String get departmentMarketing => """Marketing""";

  /// ```dart
  /// "Finance"
  /// ```
  String get departmentFinance => """Finance""";

  /// ```dart
  /// "HR"
  /// ```
  String get departmentHr => """HR""";

  /// ```dart
  /// "ngModel value"
  /// ```
  String get ngModelValuePrefix => """ngModel value""";
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
  /// "Sweet modal"
  /// ```
  String get sweetModal => """Sweet modal""";

  /// ```dart
  /// "Sweet confirm"
  /// ```
  String get sweetConfirm => """Sweet confirm""";

  /// ```dart
  /// "Sweet prompt"
  /// ```
  String get sweetPrompt => """Sweet prompt""";

  /// ```dart
  /// "Sweet error toast"
  /// ```
  String get sweetErrorToast => """Sweet error toast""";

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

  /// ```dart
  /// "The pipeline finished successfully and generated a summary ready for review."
  /// ```
  String get sweetModalBody =>
      """The pipeline finished successfully and generated a summary ready for review.""";

  /// ```dart
  /// "Build complete"
  /// ```
  String get sweetModalTitle => """Build complete""";

  /// ```dart
  /// "SweetAlert.show confirmed."
  /// ```
  String get sweetModalState => """SweetAlert.show confirmed.""";

  /// ```dart
  /// "SweetAlert.show was closed without confirmation."
  /// ```
  String get sweetModalDismissed =>
      """SweetAlert.show was closed without confirmation.""";

  /// ```dart
  /// "Do you want to promote this release to production now?"
  /// ```
  String get sweetConfirmBody =>
      """Do you want to promote this release to production now?""";

  /// ```dart
  /// "Promote release"
  /// ```
  String get sweetConfirmTitle => """Promote release""";

  /// ```dart
  /// "Promote"
  /// ```
  String get sweetConfirmOk => """Promote""";

  /// ```dart
  /// "Review"
  /// ```
  String get sweetConfirmCancel => """Review""";

  /// ```dart
  /// "SweetAlert.confirm returned a positive confirmation."
  /// ```
  String get sweetConfirmTrue =>
      """SweetAlert.confirm returned a positive confirmation.""";

  /// ```dart
  /// "SweetAlert.confirm was cancelled."
  /// ```
  String get sweetConfirmFalse => """SweetAlert.confirm was cancelled.""";

  /// ```dart
  /// "Enter the batch identifier that should receive priority monitoring."
  /// ```
  String get sweetPromptBody =>
      """Enter the batch identifier that should receive priority monitoring.""";

  /// ```dart
  /// "Batch priority"
  /// ```
  String get sweetPromptTitle => """Batch priority""";

  /// ```dart
  /// "e.g. batch-42"
  /// ```
  String get sweetPromptPlaceholder => """e.g. batch-42""";

  /// ```dart
  /// "Save priority"
  /// ```
  String get sweetPromptOk => """Save priority""";

  /// ```dart
  /// "Not now"
  /// ```
  String get sweetPromptCancel => """Not now""";

  /// ```dart
  /// "Enter an identifier before continuing."
  /// ```
  String get sweetPromptValidation =>
      """Enter an identifier before continuing.""";

  /// ```dart
  /// "SweetAlert.prompt confirmed with value"
  /// ```
  String get sweetPromptFilledPrefix =>
      """SweetAlert.prompt confirmed with value""";

  /// ```dart
  /// "SweetAlert.prompt was cancelled."
  /// ```
  String get sweetPromptDismissed => """SweetAlert.prompt was cancelled.""";

  /// ```dart
  /// "SweetAlert error toast shown in the bottom corner."
  /// ```
  String get sweetErrorBody =>
      """SweetAlert error toast shown in the bottom corner.""";

  /// ```dart
  /// "SweetAlert.toast executed with error type."
  /// ```
  String get sweetErrorState =>
      """SweetAlert.toast executed with error type.""";
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
  /// "This page brings together color, style, size, alignment, and state variations for the button component."
  /// ```
  String get overviewIntro =>
      """This page brings together color, style, size, alignment, and state variations for the button component.""";

  /// ```dart
  /// "Use"
  /// ```
  String get usePrefix => """Use""";

  /// ```dart
  /// "Button"
  /// ```
  String get demoButton => """Button""";

  /// ```dart
  /// "Light button"
  /// ```
  String get lightCardTitle => """Light button""";

  /// ```dart
  /// "Dark button"
  /// ```
  String get darkCardTitle => """Dark button""";

  /// ```dart
  /// "Primary button"
  /// ```
  String get primaryCardTitle => """Primary button""";

  /// ```dart
  /// "Secondary button"
  /// ```
  String get secondaryCardTitle => """Secondary button""";

  /// ```dart
  /// "Danger button"
  /// ```
  String get dangerCardTitle => """Danger button""";

  /// ```dart
  /// "Success button"
  /// ```
  String get successCardTitle => """Success button""";

  /// ```dart
  /// "Warning button"
  /// ```
  String get warningCardTitle => """Warning button""";

  /// ```dart
  /// "Info button"
  /// ```
  String get infoCardTitle => """Info button""";

  /// ```dart
  /// "Indigo button"
  /// ```
  String get indigoCardTitle => """Indigo button""";

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

class FabPagesMessagesEn extends FabPagesMessages {
  final PagesMessagesEn _parent;
  const FabPagesMessagesEn(this._parent) : super(_parent);

  /// ```dart
  /// "Components"
  /// ```
  String get title => """Components""";

  /// ```dart
  /// "FAB"
  /// ```
  String get subtitle => """FAB""";

  /// ```dart
  /// "Components"
  /// ```
  String get breadcrumbParent => """Components""";

  /// ```dart
  /// "FAB"
  /// ```
  String get breadcrumb => """FAB""";

  /// ```dart
  /// "Floating action button (FAB) menu is the component used to display a single floating button with or without a nested menu. The demo below follows the Limitless visual organization with interaction, direction, label, and color examples."
  /// ```
  String get intro =>
      """Floating action button (FAB) menu is the component used to display a single floating button with or without a nested menu. The demo below follows the Limitless visual organization with interaction, direction, label, and color examples.""";

  /// ```dart
  /// "Basic examples"
  /// ```
  String get basicTitle => """Basic examples""";

  /// ```dart
  /// "Demo of buttons and button lists"
  /// ```
  String get basicSubtitle => """Demo of buttons and button lists""";

  /// ```dart
  /// "Single floating button"
  /// ```
  String get singleTitle => """Single floating button""";

  /// ```dart
  /// "Floating button uses regular button markup with .fab-menu-btn inside the .fab-menu container."
  /// ```
  String get singleBody =>
      """Floating button uses regular button markup with .fab-menu-btn inside the .fab-menu container.""";

  /// ```dart
  /// "Open menu on hover"
  /// ```
  String get hoverTitle => """Open menu on hover""";

  /// ```dart
  /// "Use data-fab-toggle="hover" semantics for menus that should expand on hover."
  /// ```
  String get hoverBody =>
      """Use data-fab-toggle="hover" semantics for menus that should expand on hover.""";

  /// ```dart
  /// "Open menu on click"
  /// ```
  String get clickTitle => """Open menu on click""";

  /// ```dart
  /// "The most common case is click-to-open with the default icon-only trigger."
  /// ```
  String get clickBody =>
      """The most common case is click-to-open with the default icon-only trigger.""";

  /// ```dart
  /// "FAB menu elements"
  /// ```
  String get elementsTitle => """FAB menu elements""";

  /// ```dart
  /// "Buttons, directions, and fixed placement"
  /// ```
  String get elementsSubtitle => """Buttons, directions, and fixed placement""";

  /// ```dart
  /// "Simple buttons"
  /// ```
  String get simpleButtonsTitle => """Simple buttons""";

  /// ```dart
  /// "The submenu usually contains rounded buttons with a single icon."
  /// ```
  String get simpleButtonsBody =>
      """The submenu usually contains rounded buttons with a single icon.""";

  /// ```dart
  /// "Side actions"
  /// ```
  String get sideActionsTitle => """Side actions""";

  /// ```dart
  /// "Left direction keeps the main trigger compact while exposing contextual actions on the side."
  /// ```
  String get sideActionsBody =>
      """Left direction keeps the main trigger compact while exposing contextual actions on the side.""";

  /// ```dart
  /// "Custom templates"
  /// ```
  String get customTemplatesTitle => """Custom templates""";

  /// ```dart
  /// "Use TemplateRef to customize trigger and action content without replacing the FAB behavior, keyboard shortcuts, or link handling."
  /// ```
  String get customTemplatesBody =>
      """Use TemplateRef to customize trigger and action content without replacing the FAB behavior, keyboard shortcuts, or link handling.""";

  /// ```dart
  /// "No-backdrop page action"
  /// ```
  String get noBackdropTitle => """No-backdrop page action""";

  /// ```dart
  /// "The no-backdrop variant is previewed inside the card to avoid colliding with the left sidebar. The actual fixed FAB remains on the right edge."
  /// ```
  String get noBackdropBody =>
      """The no-backdrop variant is previewed inside the card to avoid colliding with the left sidebar. The actual fixed FAB remains on the right edge.""";

  /// ```dart
  /// "Inner button labels"
  /// ```
  String get innerLabelsTitle => """Inner button labels""";

  /// ```dart
  /// "Visible tooltips, light labels, and label positions"
  /// ```
  String get innerLabelsSubtitle =>
      """Visible tooltips, light labels, and label positions""";

  /// ```dart
  /// "Visible labels"
  /// ```
  String get visibleLabelsTitle => """Visible labels""";

  /// ```dart
  /// "Use .fab-label-visible when labels should stay visible while the menu is expanded."
  /// ```
  String get visibleLabelsBody =>
      """Use .fab-label-visible when labels should stay visible while the menu is expanded.""";

  /// ```dart
  /// "Light labels"
  /// ```
  String get lightLabelsTitle => """Light labels""";

  /// ```dart
  /// "All button types support light tooltips as an alternative to the default dark labels."
  /// ```
  String get lightLabelsBody =>
      """All button types support light tooltips as an alternative to the default dark labels.""";

  /// ```dart
  /// "Label positions"
  /// ```
  String get labelPositionsTitle => """Label positions""";

  /// ```dart
  /// "Left is default; use .fab-label-end to place labels on the right side."
  /// ```
  String get labelPositionsBody =>
      """Left is default; use .fab-label-end to place labels on the right side.""";

  /// ```dart
  /// "Default button colors"
  /// ```
  String get defaultColorsTitle => """Default button colors""";

  /// ```dart
  /// "Examples of predefined contextual colors"
  /// ```
  String get defaultColorsSubtitle =>
      """Examples of predefined contextual colors""";

  /// ```dart
  /// "Primary button color"
  /// ```
  String get primaryColorTitle => """Primary button color""";

  /// ```dart
  /// "Primary contextual color uses the standard .btn-primary main button."
  /// ```
  String get primaryColorBody =>
      """Primary contextual color uses the standard .btn-primary main button.""";

  /// ```dart
  /// "Success button color"
  /// ```
  String get successColorTitle => """Success button color""";

  /// ```dart
  /// "Use .btn-success for a positive contextual variant."
  /// ```
  String get successColorBody =>
      """Use .btn-success for a positive contextual variant.""";

  /// ```dart
  /// "Warning button color"
  /// ```
  String get warningColorTitle => """Warning button color""";

  /// ```dart
  /// "Warning is a strong contextual alternative for attention-heavy actions."
  /// ```
  String get warningColorBody =>
      """Warning is a strong contextual alternative for attention-heavy actions.""";

  /// ```dart
  /// "Custom color options"
  /// ```
  String get customColorsTitle => """Custom color options""";

  /// ```dart
  /// "Use custom colors in main and inner buttons"
  /// ```
  String get customColorsSubtitle =>
      """Use custom colors in main and inner buttons""";

  /// ```dart
  /// "Custom main button color"
  /// ```
  String get customMainColorTitle => """Custom main button color""";

  /// ```dart
  /// "Secondary palette colors can be applied directly to the main trigger."
  /// ```
  String get customMainColorBody =>
      """Secondary palette colors can be applied directly to the main trigger.""";

  /// ```dart
  /// "Custom inner button color"
  /// ```
  String get customInnerColorTitle => """Custom inner button color""";

  /// ```dart
  /// "Inner actions can use any Limitless button color while keeping the light main trigger."
  /// ```
  String get customInnerColorBody =>
      """Inner actions can use any Limitless button color while keeping the light main trigger.""";

  /// ```dart
  /// "Mixing button colors"
  /// ```
  String get mixedColorsTitle => """Mixing button colors""";

  /// ```dart
  /// "The submenu supports mixed contextual colors without changing the structural markup."
  /// ```
  String get mixedColorsBody =>
      """The submenu supports mixed contextual colors without changing the structural markup.""";

  /// ```dart
  /// "Waiting for FAB action."
  /// ```
  String get waitingAction => """Waiting for FAB action.""";

  /// ```dart
  /// "FAB action selected: "
  /// ```
  String get demoActionPrefix => """FAB action selected: """;

  /// ```dart
  /// "Fixed FAB with backdrop triggered: "
  /// ```
  String get fixedActionPrefix => """Fixed FAB with backdrop triggered: """;

  /// ```dart
  /// "Fixed FAB without backdrop triggered: "
  /// ```
  String get noBackdropActionPrefix =>
      """Fixed FAB without backdrop triggered: """;

  /// ```dart
  /// "The AngularDart implementation keeps the Limitless visual contract and exposes a short API for actions, direction, toggle, and positioning."
  /// ```
  String get apiIntro =>
      """The AngularDart implementation keeps the Limitless visual contract and exposes a short API for actions, direction, toggle, and positioning.""";

  /// ```dart
  /// "Default FAB menu markup:"
  /// ```
  String get overviewLead => """Default FAB menu markup:""";

  /// ```dart
  /// "FAB menu classes"
  /// ```
  String get classesTitle => """FAB menu classes""";

  /// ```dart
  /// "FAB menu styling is driven by CSS classes and data attributes. The table below summarizes the classes used by this AngularDart wrapper while preserving the original Limitless contract."
  /// ```
  String get classesIntro =>
      """FAB menu styling is driven by CSS classes and data attributes. The table below summarizes the classes used by this AngularDart wrapper while preserving the original Limitless contract.""";

  /// ```dart
  /// "Class"
  /// ```
  String get classHeader => """Class""";

  /// ```dart
  /// "Description"
  /// ```
  String get descriptionHeader => """Description""";

  /// ```dart
  /// "Basic classes"
  /// ```
  String get basicClassesGroup => """Basic classes""";

  /// ```dart
  /// "Directions and positioning"
  /// ```
  String get directionsGroup => """Directions and positioning""";

  /// ```dart
  /// "Visibility and labels"
  /// ```
  String get visibilityGroup => """Visibility and labels""";

  /// ```dart
  /// "Main wrapper used by the component."
  /// ```
  String get classMenuDesc => """Main wrapper used by the component.""";

  /// ```dart
  /// "Main circular trigger button."
  /// ```
  String get classMenuBtnDesc => """Main circular trigger button.""";

  /// ```dart
  /// "Inner action list container."
  /// ```
  String get classMenuInnerDesc => """Inner action list container.""";

  /// ```dart
  /// "Icons rotated and faded by the Limitless CSS depending on menu state."
  /// ```
  String get classIconsDesc =>
      """Icons rotated and faded by the Limitless CSS depending on menu state.""";

  /// ```dart
  /// "Menu opens below the trigger."
  /// ```
  String get classMenuTopDesc => """Menu opens below the trigger.""";

  /// ```dart
  /// "Menu opens above the trigger."
  /// ```
  String get classMenuBottomDesc => """Menu opens above the trigger.""";

  /// ```dart
  /// "Viewport-fixed FAB used for persistent page actions."
  /// ```
  String get classMenuFixedDesc =>
      """Viewport-fixed FAB used for persistent page actions.""";

  /// ```dart
  /// "Horizontal extensions added by the AngularDart wrapper."
  /// ```
  String get classDirHorizontalDesc =>
      """Horizontal extensions added by the AngularDart wrapper.""";

  /// ```dart
  /// "Click-to-open behavior."
  /// ```
  String get toggleClickDesc => """Click-to-open behavior.""";

  /// ```dart
  /// "Hover-to-open behavior."
  /// ```
  String get toggleHoverDesc => """Hover-to-open behavior.""";

  /// ```dart
  /// "Applied while the menu is expanded."
  /// ```
  String get stateOpenDesc => """Applied while the menu is expanded.""";

  /// ```dart
  /// "Tooltip text for inner actions."
  /// ```
  String get dataFabLabelDesc => """Tooltip text for inner actions.""";

  /// ```dart
  /// "Right-aligned, light, and persistent label modifiers."
  /// ```
  String get labelModifiersDesc =>
      """Right-aligned, light, and persistent label modifiers.""";

  /// ```dart
  /// "Close"
  /// ```
  String get customTriggerClose => """Close""";

  /// ```dart
  /// "Quick actions"
  /// ```
  String get customTriggerActions => """Quick actions""";

  /// ```dart
  /// "Compose email"
  /// ```
  String get actionComposeEmail => """Compose email""";

  /// ```dart
  /// "Conversations"
  /// ```
  String get actionConversations => """Conversations""";

  /// ```dart
  /// "Account security"
  /// ```
  String get actionAccountSecurity => """Account security""";

  /// ```dart
  /// "Analytics"
  /// ```
  String get actionAnalytics => """Analytics""";

  /// ```dart
  /// "Privacy"
  /// ```
  String get actionPrivacy => """Privacy""";

  /// ```dart
  /// "Edit"
  /// ```
  String get actionEdit => """Edit""";

  /// ```dart
  /// "Share"
  /// ```
  String get actionShare => """Share""";

  /// ```dart
  /// "Archive"
  /// ```
  String get actionArchive => """Archive""";

  /// ```dart
  /// "Publish"
  /// ```
  String get actionPublish => """Publish""";

  /// ```dart
  /// "Save draft"
  /// ```
  String get actionSaveDraft => """Save draft""";

  /// ```dart
  /// "Preview"
  /// ```
  String get actionPreview => """Preview""";

  /// ```dart
  /// "Run pipeline"
  /// ```
  String get markupRunPipeline => """Run pipeline""";
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
      """nav.fab""": """FAB""",
      """common.restoreAlert""": """Restore alert""",
      """common.none""": """None""",
      """common.open""": """Open""",
      """common.close""": """Close""",
      """common.clear""": """Clear""",
      """common.status""": """Status""",
      """common.value""": """Value""",
      """common.label""": """Label""",
      """common.event""": """Event""",
      """common.currentPeriod""": """Current period""",
      """common.restrictedWindow""": """Restricted window""",
      """common.tabOverview""": """Overview""",
      """common.tabApi""": """API""",
      """common.sectionDescription""": """Description""",
      """common.sectionFeatures""": """Features""",
      """common.sectionLimitations""": """Limitations""",
      """common.sectionHowToUse""": """How to use""",
      """common.sectionNotes""": """Notes""",
      """common.sectionVisibleExample""": """Visible example""",
      """common.sectionMainOptions""": """Main options""",
      """common.sectionBestPractices""": """Best practices""",
      """common.sectionOutputs""": """Outputs""",
      """common.sectionPublicMethods""": """Public methods""",
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
      """pages.overview.featureAngularDartDocsTitle""":
          """AngularDart documentation""",
      """pages.overview.featureAngularDartDocsBody""":
          """Open the setup guide published under site_ngdart.""",
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
      """pages.overview.featureSweetAlertBody""":
          """Unified API for modals, confirmation, prompt, toast, and also a declarative trigger.""",
      """pages.overview.featureHighlightBody""":
          """Lightweight block for Dart, HTML, and CSS snippets in the example documentation.""",
      """pages.overview.featureInputsFieldBody""":
          """Text field with ngModel, floating label, textarea, and prefix or suffix addons.""",
      """pages.overview.featureFabBody""":
          """Compact speed dial for quick global or inline actions.""",
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
      """pages.accordion.descriptionBody""":
          """The accordion organizes dense blocks of information into expandable sections, reducing visual noise without losing context.""",
      """pages.accordion.featureOne""":
          """Collapsed, expanded, disabled items, and customized headers.""",
      """pages.accordion.featureTwo""": """Open and close events per item.""",
      """pages.accordion.featureThree""":
          """Lazy rendering and optional body destruction.""",
      """pages.accordion.limitOne""":
          """Highly interactive content requires extra focus care.""",
      """pages.accordion.limitTwo""":
          """Very long sections still need internal hierarchy.""",
      """pages.accordion.limitThree""":
          """The layout does not replace route-based navigation.""",
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
      """pages.accordion.directiveApiTitle""":
          """Declarative API with directives""",
      """pages.accordion.directiveApiIntro""":
          """This version keeps Bootstrap markup accessible in the DOM and exposes an API similar to ng-bootstrap.""",
      """pages.accordion.directiveApiNote""":
          """For true physical destroyOnHide, use <template liAccordionBody>. The simple wrapper with <div liAccordionBody> keeps the content in the DOM when the reference must remain stable.""",
      """pages.accordion.declarativeOverviewButton""": """Overview""",
      """pages.accordion.declarativeOverviewBody""":
          """Basic content with declarative header and body, keeping accessibility classes and attributes.""",
      """pages.accordion.declarativeCustomHeader""": """Custom header""",
      """pages.accordion.declarativeToggle""": """Toggle""",
      """pages.accordion.declarativeCustomBody""":
          """The header can be fully customized without losing id, collapse, and event control.""",
      """pages.accordion.declarativeDisabledButton""": """Disabled item""",
      """pages.accordion.declarativeDisabledBody""":
          """This content stays accessible through the API, but does not react to user clicks.""",
      """pages.accordion.expandOverview""": """Expand overview""",
      """pages.accordion.toggleCustom""": """Toggle custom""",
      """pages.accordion.closeAll""": """Close all""",
      """pages.accordion.itemApi""": """Item API""",
      """pages.accordion.declarativeIdle""":
          """No declarative API events yet.""",
      """pages.accordion.collapseTitle""": """liCollapse""",
      """pages.accordion.collapseIntro""":
          """Generic directive to hide and show blocks with the collapse, show, and collapsing classes.""",
      """pages.accordion.openPanel""": """Open panel""",
      """pages.accordion.closePanel""": """Close panel""",
      """pages.accordion.collapseBody""":
          """This block uses the generic collapse directive without depending on the accordion.""",
      """pages.accordion.apiOne""":
          """[allowMultipleOpen] lets more than one item stay expanded at the same time.""",
      """pages.accordion.apiTwo""":
          """[flush] removes extra borders for a more compact composition.""",
      """pages.accordion.apiThree""":
          """[lazy] defers body rendering until the first open.""",
      """pages.accordion.apiFour""":
          """[destroyOnCollapse] removes the content from the DOM when the item closes.""",
      """pages.accordion.apiFive""":
          """[expanded] and (expandedChange) control open state per item.""",
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
      """pages.tabs.overviewIntro""":
          """The tabs page demonstrates horizontal and vertical composition, distributed alignment, custom headers, and on-demand rendering.""",
      """pages.tabs.descriptionBody""":
          """Tabs organize content in layers without breaking page context and work well for documentation, segmented forms, and administrative panels.""",
      """pages.tabs.featureOne""": """Tabs and pills modes.""",
      """pages.tabs.featureTwo""": """Horizontal or side placement.""",
      """pages.tabs.featureThree""": """Projected header and disabled tabs.""",
      """pages.tabs.limitOne""":
          """Too many tabs at the same level hurt scannability.""",
      """pages.tabs.limitTwo""":
          """Very long content calls for additional hierarchy.""",
      """pages.tabs.limitThree""":
          """Nested tabs should be isolated into subcomponents.""",
      """pages.tabs.previewTitle""": """Visible example""",
      """pages.tabs.previewIntro""":
          """The gallery below covers basic layouts, justified variants, side navigation, projected headers, and lifecycle behavior with lazyLoad and destroyOnHide.""",
      """pages.tabs.apiIntro""":
          """Use the component to group related content when section-based navigation makes more sense than stacking cards or opening new routes.""",
      """pages.tabs.apiOne""": """type accepts tabs or pills.""",
      """pages.tabs.apiTwo""":
          """placement controls tab position, such as top or side.""",
      """pages.tabs.apiThree""": """[justified] distributes triggers evenly.""",
      """pages.tabs.apiFour""":
          """[active] and [disabled] control state per tab.""",
      """pages.tabs.apiFive""":
          """template li-tabx-header allows custom headers.""",
      """pages.tabs.galleryLayoutsTitle""": """Core combinations""",
      """pages.tabs.galleryLayoutsIntro""":
          """Horizontal and side variations for documentation, operational dashboards, and review areas.""",
      """pages.tabs.galleryAdvancedTitle""": """Composition and lifecycle""",
      """pages.tabs.galleryAdvancedIntro""":
          """Examples with projected headers, richer visual semantics, and panes rendered on demand.""",
      """pages.tabs.basicCardTitle""": """Basic tabs""",
      """pages.tabs.basicCardBody""":
          """A simple horizontal structure to split summary, metrics, and history without leaving the page.""",
      """pages.tabs.basicCardConfig""": """Config: type=tabs""",
      """pages.tabs.basicSummary""": """Summary""",
      """pages.tabs.basicSummaryBody""":
          """Keep goals, context, and recent decisions in a short opening panel optimized for first-pass reading.""",
      """pages.tabs.basicMetrics""": """Metrics""",
      """pages.tabs.basicMetricsBody""":
          """Use the second tab for indicators that support the narrative without competing with the main content.""",
      """pages.tabs.basicHistory""": """History""",
      """pages.tabs.basicHistoryBody""":
          """Reserve the third tab for events, changelog items, or auditable notes when the flow requires traceability.""",
      """pages.tabs.justifiedCardTitle""": """Justified tabs""",
      """pages.tabs.justifiedCardBody""":
          """Distributes the main screen areas with equal width to keep the visual hierarchy stable.""",
      """pages.tabs.justifiedCardConfig""":
          """Config: type=tabs, justified=true""",
      """pages.tabs.justifiedBacklog""": """Backlog""",
      """pages.tabs.justifiedBacklogBody""":
          """When each stage carries the same weight, the justified layout helps communicate equal priority across sections.""",
      """pages.tabs.justifiedDelivery""": """Delivery""",
      """pages.tabs.justifiedDeliveryBody""":
          """This format works well in compact cards, status boards, and documentation pages with limited horizontal space.""",
      """pages.tabs.justifiedRisks""": """Risks""",
      """pages.tabs.justifiedRisksBody""":
          """It is also useful to place critical areas side by side without relying on extra helper text to balance the navigation.""",
      """pages.tabs.sideCardTitle""": """Side pills""",
      """pages.tabs.sideCardBody""":
          """A good option when navigation behaves like a context menu and content needs more horizontal room.""",
      """pages.tabs.sideCardConfig""": """Config: type=pills, placement=left""",
      """pages.tabs.tokens""": """Tokens""",
      """pages.tabs.flow""": """Flow""",
      """pages.tabs.blocked""": """Blocked""",
      """pages.tabs.tokensBody""":
          """Use the side rail to group visual variants, tokens, or example families without overloading the top navigation.""",
      """pages.tabs.flowBody""":
          """A side layout works well for dependency-heavy journeys, especially when each pane needs more explanatory text.""",
      """pages.tabs.blockedBody""":
          """Disable entries temporarily when a stage depends on permissions, rollout, or data that is not available yet.""",
      """pages.tabs.rightCardTitle""": """Right-aligned tabs""",
      """pages.tabs.rightCardBody""":
          """Useful for review and approval flows when the main content should remain on the left reading axis.""",
      """pages.tabs.rightCardConfig""":
          """Config: type=tabs, placement=right""",
      """pages.tabs.review""": """Review""",
      """pages.tabs.reviewBody""":
          """Place checklist, decision notes, and rationale in a dedicated pane to reduce context switching during validation.""",
      """pages.tabs.approvers""": """Approvers""",
      """pages.tabs.approversBody""":
          """The middle tab works well for owners, roles, and acceptance criteria when governance is more formal.""",
      """pages.tabs.sla""": """SLA""",
      """pages.tabs.slaBody""":
          """The third tab can consolidate deadlines, release windows, and escalation rules without competing with the main content.""",
      """pages.tabs.workflowCardTitle""": """Projected header""",
      """pages.tabs.workflowCardBody""":
          """Combines icons, badges, and subtitles in the tab trigger to signal status and workload density.""",
      """pages.tabs.workflowCardConfig""":
          """Config: template li-tabx-header""",
      """pages.tabs.discovery""": """Discovery""",
      """pages.tabs.discoveryHint""": """Scope and dependencies""",
      """pages.tabs.execution""": """Execution""",
      """pages.tabs.executionHint""": """Implementation and QA""",
      """pages.tabs.publish""": """Publish""",
      """pages.tabs.publishHint""": """Rollout and communication""",
      """pages.tabs.workflowDiscoveryBody""":
          """Use projected headers when a plain label is no longer enough and the tab needs to carry visible operational context.""",
      """pages.tabs.workflowExecutionBody""":
          """Badges and subtitles help signal volume, stage, or criticality without requiring extra legends in the page body.""",
      """pages.tabs.workflowPublishBody""":
          """This pattern brings the demo closer to the Limitless visual language in richer, status-oriented navigation scenarios.""",
      """pages.tabs.lifecycleCardTitle""": """Lazy loading and teardown""",
      """pages.tabs.lifecycleCardBody""":
          """Renders panes on demand and removes inactive content from the DOM to reduce cost in heavy tab sets.""",
      """pages.tabs.lifecycleCardConfig""":
          """Config: lazyLoad=true, destroyOnHide=true""",
      """pages.tabs.dataset""": """Dataset""",
      """pages.tabs.datasetBody""":
          """Open with a light overview and leave expensive steps for the moment the user actually navigates to those tabs.""",
      """pages.tabs.transform""": """Transform""",
      """pages.tabs.transformBody""":
          """lazyLoad prevents complex charts, grids, or forms from mounting before the corresponding tab is first activated.""",
      """pages.tabs.export""": """Export""",
      """pages.tabs.exportBody""":
          """destroyOnHide is useful when inactive content keeps listeners, tables, or state that should not live outside focus.""",
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
      """pages.select.overviewIntro""":
          """The select demo shows stable dataSource usage and manual option projection, bringing description, features, limitations, and visible examples together in the same flow.""",
      """pages.select.descriptionTitle""": """Description""",
      """pages.select.descriptionBody""":
          """The component solves simple selection with overlay, projected options, and direct ngModel binding.""",
      """pages.select.featuresTitle""": """Features""",
      """pages.select.featureOne""": """External source through dataSource.""",
      """pages.select.featureTwo""": """Manual projection with li-option.""",
      """pages.select.featureThree""":
          """Placeholder, disabled items, and simple binding.""",
      """pages.select.limitsTitle""": """Limitations""",
      """pages.select.limitOne""":
          """Avoid recreating dataSource in reactive getters.""",
      """pages.select.limitTwo""":
          """The overlay depends on consistent options for navigation and height.""",
      """pages.select.limitThree""":
          """For heavy filtering logic, keep orchestration in the parent component.""",
      """pages.select.apiTitle""": """How to use""",
      """pages.select.apiIntro""":
          """li-select accepts both [dataSource] and li-option projection. To avoid freezes and unnecessary render cycles, prefer providing stable lists from the parent component instead of getters that recreate the array whenever state changes.""",
      """pages.select.apiDataSource""": """external option list.""",
      """pages.select.apiLabelKey""": """key used for visible text.""",
      """pages.select.apiValueKey""": """key used as the ngModel value.""",
      """pages.select.apiDisabledKey""":
          """boolean key used to disable items.""",
      """pages.select.apiNgModel""": """selected value.""",
      """pages.select.apiPlaceholder""": """text shown when empty.""",
      """pages.select.notesTitle""": """Notes and limits""",
      """pages.select.noteOne""": """Do not recreate dataSource in getters.""",
      """pages.select.noteTwo""":
          """The overlay should not calculate height from its own rendered panel.""",
      """pages.select.noteThree""":
          """Global keyboard events should handle only navigation and escape.""",
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
      """pages.multiSelect.overviewIntro""":
          """The multi-select demo shows multiple selection with a stable dataSource, manual projection, and documentation organized between overview and API.""",
      """pages.multiSelect.descriptionTitle""": """Description""",
      """pages.multiSelect.descriptionBody""":
          """The component keeps a collection of selected values and projects the result directly in the trigger.""",
      """pages.multiSelect.featuresTitle""": """Features""",
      """pages.multiSelect.featureOne""":
          """Multiple selection with badges and placeholder.""",
      """pages.multiSelect.featureTwo""":
          """Clear-selection button next to the arrow when values are selected.""",
      """pages.multiSelect.featureThree""":
          """Integration with dataSource or li-multi-option.""",
      """pages.multiSelect.featureFour""":
          """Direct binding with ngModel lists.""",
      """pages.multiSelect.limitsTitle""": """Limitations""",
      """pages.multiSelect.limitOne""":
          """Avoid recreating option lists in reactive getters.""",
      """pages.multiSelect.limitTwo""":
          """The overlay needs a consistent refresh when the selection changes.""",
      """pages.multiSelect.limitThree""":
          """For very large collections, keep pagination or search in the parent.""",
      """pages.multiSelect.apiTitle""": """How to use""",
      """pages.multiSelect.apiIntroOne""":
          """li-multi-select follows the same strategy as li-select, but keeps multiple selected values and renders badges in the trigger.""",
      """pages.multiSelect.apiIntroTwo""":
          """The recommended pattern for the demo and production is to keep dataSource stable and update only the selected values collection.""",
      """pages.multiSelect.apiDataSource""": """external option list.""",
      """pages.multiSelect.apiLabelKey""": """key used for visible text.""",
      """pages.multiSelect.apiValueKey""": """key used in the ngModel array.""",
      """pages.multiSelect.apiNgModel""": """list of selected values.""",
      """pages.multiSelect.apiPlaceholder""":
          """text shown when nothing is selected.""",
      """pages.multiSelect.apiShowClearButton""":
          """shows the X button to clear everything in the trigger.""",
      """pages.multiSelect.notesTitle""": """Notes and limits""",
      """pages.multiSelect.noteOne""":
          """Do not recreate the option list in reactive getters.""",
      """pages.multiSelect.noteTwo""":
          """Schedule overlay.update() on a future frame when the selection changes.""",
      """pages.multiSelect.noteThree""":
          """Calculate maxHeight from the viewport, not from the current panel height.""",
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
      """pages.currency.tabOverview""": """Overview""",
      """pages.currency.tabApi""": """API""",
      """pages.currency.descriptionTitle""": """Description""",
      """pages.currency.descriptionBody""":
          """The monetary field handles visual formatting and conversion to minor units without extra template logic.""",
      """pages.currency.featuresTitle""": """Features""",
      """pages.currency.featureOne""":
          """Support for locale and currencyCode.""",
      """pages.currency.featureTwo""":
          """Automatic conversion to minor units.""",
      """pages.currency.featureThree""": """AngularDart forms integration.""",
      """pages.currency.limitsTitle""": """Limitations""",
      """pages.currency.limitOne""":
          """The field does not replace fiscal business rules.""",
      """pages.currency.limitTwo""":
          """Very specific masks require additional extension.""",
      """pages.currency.limitThree""":
          """The persisted value remains numeric.""",
      """pages.currency.summaryHelp""":
          """The same component now accepts BRL, USD, and EUR by changing only currencyCode and locale.""",
      """pages.currency.apiIntro""":
          """Use the component to display a formatted value to the user while keeping a consistent minor-unit number in state.""",
      """pages.currency.apiOne""":
          """[(ngModel)] works with the value in minor units.""",
      """pages.currency.apiTwo""":
          """currencyCode and locale control symbol and separators.""",
      """pages.currency.apiThree""":
          """prefix remains available to override the automatically resolved symbol.""",
      """pages.currency.apiFour""":
          """[required] integrates validation into the form.""",
      """pages.currency.apiFive""":
          """inputClass lets you apply utility classes to the field.""",
      """pages.dateRange.title""": """Components""",
      """pages.dateRange.subtitle""": """Date Range""",
      """pages.dateRange.breadcrumb""": """Period selection""",
      """pages.dateRange.cardTitle""": """Free and constrained ranges""",
      """pages.dateRange.tabOverview""": """Overview""",
      """pages.dateRange.tabApi""": """API""",
      """pages.dateRange.descriptionTitle""": """Description""",
      """pages.dateRange.descriptionBody""":
          """The date range picker fits continuous period flows for filters, sprints, releases, and operational slices.""",
      """pages.dateRange.featuresTitle""": """Features""",
      """pages.dateRange.featureOne""": """Separate start and end binding.""",
      """pages.dateRange.featureTwo""":
          """Minimum and maximum interval restrictions.""",
      """pages.dateRange.featureThree""":
          """Configurable placeholder and locale.""",
      """pages.dateRange.limitsTitle""": """Limitations""",
      """pages.dateRange.limitOne""":
          """The component does not apply business-calendar rules on its own.""",
      """pages.dateRange.limitTwo""":
          """More specific validations still belong in the parent.""",
      """pages.dateRange.limitThree""":
          """Complex flows may require external presets.""",
      """pages.dateRange.sprintPlaceholder""": """Select the sprint period""",
      """pages.dateRange.publicationPlaceholder""": """Publication window""",
      """pages.dateRange.partial""": """Partial or undefined period""",
      """pages.dateRange.unfinished""": """Window not completed yet""",
      """pages.dateRange.constrainedHelp""":
          """The second example constrains the selection with minDate and maxDate.""",
      """pages.dateRange.between""": """to""",
      """pages.dateRange.apiIntro""":
          """Use the component when the flow depends on a range with start and end dates clearly controlled by the parent component.""",
      """pages.dateRange.apiOne""":
          """[inicio] or [start], with (inicioChange) or (startChange), control the start date.""",
      """pages.dateRange.apiTwo""":
          """[fim] or [end], with (fimChange) or (endChange), control the end date.""",
      """pages.dateRange.apiThree""":
          """[minDate] and [maxDate] restrict the selectable window.""",
      """pages.dateRange.apiFour""":
          """[placeholder] and locale adjust the field communication.""",
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
          """Support for 12-hour AM/PM and 24-hour display modes.""",
      """pages.timePicker.limitsTitle""": """Limitations""",
      """pages.timePicker.limitOne""":
          """The displayed format depends on use24Hour and the configured locale.""",
      """pages.timePicker.limitTwo""":
          """It does not apply business window rules on its own.""",
      """pages.timePicker.limitThree""":
          """The returned value carries only hour and minute.""",
      """pages.timePicker.twentyFourHourTitle""": """24-hour time picker""",
      """pages.timePicker.twentyFourHourPlaceholder""": """Select time""",
      """pages.timePicker.twentyFourHourCurrentLabel""": """Current time""",
      """pages.timePicker.twentyFourHourHelp""":
          """Use use24Hour to display and edit the value without AM/PM.""",
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
      """pages.datatable.overviewIntro""":
          """This library datatable covers the most common administrative flow: field search, row selection, export, pagination, sorting, responsive collapse, and a layer of visual customization per column, row, and card.""",
      """pages.datatable.descriptionBody""":
          """The component serves operational listings that need to switch between table and grid without duplicating the data source, sorting rules, or search behavior.""",
      """pages.datatable.featureOne""":
          """Column-aware search with configurable field and operator.""",
      """pages.datatable.featureTwo""":
          """XLSX and PDF export through the component API itself.""",
      """pages.datatable.featureThree""":
          """Table and grid modes with the same data source.""",
      """pages.datatable.featureFour""":
          """Width, alignment, classes, and styles per column and per row.""",
      """pages.datatable.featureFive""":
          """Custom cards with customCardBuilder in grid mode.""",
      """pages.datatable.limitOne""":
          """cellStyleResolver works with inline CSS, so it does not replace a full theme.""",
      """pages.datatable.limitTwo""":
          """customCardBuilder is ideal for rich cards, but requires manual markup assembly.""",
      """pages.datatable.limitThree""":
          """Mobile collapse is still column-oriented, so very dense layouts need curation of secondary columns.""",
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
      """pages.datatable.demoIntro""":
          """Main demo with search, selection, export, and switching between table and grid.""",
      """pages.datatable.onDemandTitle""": """On-demand demos""",
      """pages.datatable.onDemandIntro""":
          """The examples below use li-accordion with lazy loading to keep every datatable out of the DOM until the route section is opened.""",
      """pages.datatable.readonlyTitle""": """Read-only example""",
      """pages.datatable.readonlyDescription""":
          """Search and sorting without row clicks or selection.""",
      """pages.datatable.gridPreviewTitle""": """Grid mode example""",
      """pages.datatable.gridPreviewDescription""":
          """The same dataset reused as cards.""",
      """pages.datatable.customTableTitle""":
          """Table with width, per-column color, and per-row color""",
      """pages.datatable.customTableDescription""":
          """Combines fixed width, cellStyleResolver, and rowStyleResolver in the same scenario.""",
      """pages.datatable.customGridTitle""": """Grid with customCardBuilder""",
      """pages.datatable.customGridDescription""":
          """Manually assembled card only when the item is opened.""",
      """pages.datatable.lazyModalTitle""":
          """Lazy loading modal with datatable""",
      """pages.datatable.lazyModalIntro""":
          """This scenario opens a li-modal with lazyContent and instantiates li-datatable only after opening.""",
      """pages.datatable.openLazyModal""": """Open lazy modal""",
      """pages.datatable.modalTitle""": """Lazy modal with datatable""",
      """pages.datatable.modalBody""":
          """Modal content only enters the DOM when it opens. The datatable reuses the page dataset to verify that first render works correctly.""",
      """pages.datatable.howToUseBody""":
          """The component is driven by three parts: Filters for pagination and search, DataFrame for data, and DatatableSettings for columns and visual behavior.""",
      """pages.datatable.optionOne""":
          """[dataTableFilter]: controls limit, offset, search, and sorting.""",
      """pages.datatable.optionTwo""":
          """[settings]: defines columns, grid, and custom builders.""",
      """pages.datatable.optionThree""":
          """[searchInFields]: declares which fields appear in the search selector.""",
      """pages.datatable.optionFour""":
          """[responsiveCollapse]: moves secondary columns into the child row on mobile.""",
      """pages.datatable.practiceOne""":
          """Keep DataFrame stable and update only filters and selection.""",
      """pages.datatable.practiceTwo""":
          """Use hideOnMobile on secondary columns.""",
      """pages.datatable.practiceThree""":
          """Reserve customCardBuilder for grids that really need to depart from the default layout.""",
      """pages.datatable.columnStylesTitle""": """Columns and styles""",
      """pages.datatable.columnStyleOne""":
          """width, minWidth, and maxWidth control the effective column width.""",
      """pages.datatable.columnStyleTwo""":
          """headerClass and cellClass add classes without touching the template.""",
      """pages.datatable.columnStyleThree""":
          """styleCss and cellStyleResolver control color and style per column.""",
      """pages.datatable.columnStyleFour""":
          """rowStyleResolver returns a CSS string for the whole row based on the data.""",
      """pages.datatable.columnStyleFive""":
          """textAlign and nowrap improve readability for short columns or statuses.""",
      """pages.datatable.customCardEyebrow""": """CustomCardBuilder""",
      """pages.datatable.ownerPrefix""": """Owner""",
      """pages.datatable.customCardSummary""":
          """The card was manually assembled to combine title, state, and metadata without depending on the default layout.""",
      """pages.datatable.featureRow5""": """Sync ERP registrations""",
      """pages.datatable.featureRow6""": """Publish operational report""",
      """pages.datatable.featureRow7""": """Review integration queue""",
      """pages.datatable.featureRow8""": """Update support dashboard""",
      """pages.datatable.ownerFinance""": """Finance""",
      """pages.datatable.ownerSupport""": """Support""",
      """pages.datatable.gridMode""": """Datatable switched to grid mode.""",
      """pages.datatable.tableMode""": """Datatable switched to table mode.""",
      """pages.datatable.singleMode""": """Single selection enabled.""",
      """pages.datatable.multiMode""": """Multiple selection enabled.""",
      """pages.datatable.exportXlsx""": """XLSX export triggered.""",
      """pages.datatable.exportPdf""": """PDF export triggered.""",
      """pages.datatableSelect.title""": """Components""",
      """pages.datatableSelect.subtitle""": """Datatable Select""",
      """pages.datatableSelect.breadcrumb""": """Select with datatable modal""",
      """pages.datatableSelect.overviewIntro""":
          """A select that opens a modal with a full datatable, allowing search, pagination, and sorting. Clicking a row selects the item and closes the modal.""",
      """pages.datatableSelect.descriptionBody""":
          """The component combines a form-select-style trigger with a modal that displays a complete li-datatable. It implements ControlValueAccessor for ngModel compatibility.""",
      """pages.datatableSelect.featureOne""":
          """Search, pagination, and sorting through li-datatable.""",
      """pages.datatableSelect.featureTwo""": """Selection by row click.""",
      """pages.datatableSelect.featureThree""":
          """Support for ngModel and currentValueChange.""",
      """pages.datatableSelect.featureFour""": """Configurable modal size.""",
      """pages.datatableSelect.featureFive""":
          """Disabled and programmatic states.""",
      """pages.datatableSelect.limitOne""":
          """Requires dataRequest to provide data to the datatable.""",
      """pages.datatableSelect.limitTwo""":
          """The displayed label depends on labelKey without custom projection.""",
      """pages.datatableSelect.limitThree""":
          """Does not support multiple selection.""",
      """pages.datatableSelect.demoIntro""":
          """Basic usage with currentValueChange and programmatic control.""",
      """pages.datatableSelect.selectMaria""": """Select Maria Silva""",
      """pages.datatableSelect.selectPersonLabel""": """Select person""",
      """pages.datatableSelect.modalTitle""": """Select person""",
      """pages.datatableSelect.placeholder""": """Click to select...""",
      """pages.datatableSelect.searchPlaceholder""":
          """Search by name, email...""",
      """pages.datatableSelect.disabledIntro""":
          """Disabled state, the trigger stays inactive and does not open the modal.""",
      """pages.datatableSelect.disabledLabel""": """Person (disabled)""",
      """pages.datatableSelect.disabledPlaceholder""": """Disabled field""",
      """pages.datatableSelect.ngModelIntro""":
          """Binding with ngModel. The value is synchronized through ControlValueAccessor.""",
      """pages.datatableSelect.ngModelLabel""": """Select person (ngModel)""",
      """pages.datatableSelect.howToUseBody""":
          """The component is driven by three parts: Filters for pagination and search, DataFrame for data, and DatatableSettings for columns. Clicking the trigger opens a modal with the datatable; clicking a row completes the selection.""",
      """pages.datatableSelect.optionOne""":
          """[settings]: datatable column definitions.""",
      """pages.datatableSelect.optionTwo""":
          """[data]: DataFrame with paginated data.""",
      """pages.datatableSelect.optionThree""":
          """[dataTableFilter]: search and pagination filters.""",
      """pages.datatableSelect.optionFour""":
          """[searchInFields]: search fields.""",
      """pages.datatableSelect.optionFive""":
          """[labelKey]: key for the text shown in the trigger.""",
      """pages.datatableSelect.optionSix""":
          """[valueKey]: key for the value; null means the whole instance.""",
      """pages.datatableSelect.optionSeven""":
          """[placeholder]: text shown when no item is selected.""",
      """pages.datatableSelect.optionEight""": """[title]: modal title.""",
      """pages.datatableSelect.optionNine""":
          """[modalSize]: modal size (large, xtra-large, xx-large, xxx-large, fluid, modal-full).""",
      """pages.datatableSelect.optionTen""":
          """[disabled]: disables the component.""",
      """pages.datatableSelect.optionEleven""":
          """[fullScreenOnMobile]: fullscreen modal on mobile.""",
      """pages.datatableSelect.outputOne""":
          """(dataRequest): emitted when the datatable requests data.""",
      """pages.datatableSelect.outputTwo""":
          """(currentValueChange): emitted when the selected value changes.""",
      """pages.datatableSelect.outputThree""":
          """(limitChange): emitted when the page-size limit changes.""",
      """pages.datatableSelect.outputFour""":
          """(searchRequest): emitted when a search is submitted.""",
      """pages.datatableSelect.methodOne""":
          """clear(): clears the selection.""",
      """pages.datatableSelect.methodTwo""":
          """setSelectedItem({label, value}): sets the selection programmatically.""",
      """pages.datatableSelect.methodThree""":
          """selectedLabel: getter that returns the current label.""",
      """pages.datatableSelect.noteOne""":
          """Compatible with ngModel through ControlValueAccessor.""",
      """pages.datatableSelect.noteTwo""":
          """Keep DataFrame stable; update only through (dataRequest).""",
      """pages.datatableSelect.noteThree""":
          """The clear button in the trigger appears when a value is selected.""",
      """pages.datatableSelect.columnId""": """ID""",
      """pages.datatableSelect.columnName""": """Name""",
      """pages.datatableSelect.columnEmail""": """Email""",
      """pages.datatableSelect.columnDepartment""": """Department""",
      """pages.datatableSelect.searchName""": """Name""",
      """pages.datatableSelect.searchEmail""": """Email""",
      """pages.datatableSelect.searchDepartment""": """Department""",
      """pages.datatableSelect.departmentEngineering""": """Engineering""",
      """pages.datatableSelect.departmentDesign""": """Design""",
      """pages.datatableSelect.departmentMarketing""": """Marketing""",
      """pages.datatableSelect.departmentFinance""": """Finance""",
      """pages.datatableSelect.departmentHr""": """HR""",
      """pages.datatableSelect.ngModelValuePrefix""": """ngModel value""",
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
      """pages.helpers.sweetModal""": """Sweet modal""",
      """pages.helpers.sweetConfirm""": """Sweet confirm""",
      """pages.helpers.sweetPrompt""": """Sweet prompt""",
      """pages.helpers.sweetErrorToast""": """Sweet error toast""",
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
      """pages.helpers.sweetModalBody""":
          """The pipeline finished successfully and generated a summary ready for review.""",
      """pages.helpers.sweetModalTitle""": """Build complete""",
      """pages.helpers.sweetModalState""": """SweetAlert.show confirmed.""",
      """pages.helpers.sweetModalDismissed""":
          """SweetAlert.show was closed without confirmation.""",
      """pages.helpers.sweetConfirmBody""":
          """Do you want to promote this release to production now?""",
      """pages.helpers.sweetConfirmTitle""": """Promote release""",
      """pages.helpers.sweetConfirmOk""": """Promote""",
      """pages.helpers.sweetConfirmCancel""": """Review""",
      """pages.helpers.sweetConfirmTrue""":
          """SweetAlert.confirm returned a positive confirmation.""",
      """pages.helpers.sweetConfirmFalse""":
          """SweetAlert.confirm was cancelled.""",
      """pages.helpers.sweetPromptBody""":
          """Enter the batch identifier that should receive priority monitoring.""",
      """pages.helpers.sweetPromptTitle""": """Batch priority""",
      """pages.helpers.sweetPromptPlaceholder""": """e.g. batch-42""",
      """pages.helpers.sweetPromptOk""": """Save priority""",
      """pages.helpers.sweetPromptCancel""": """Not now""",
      """pages.helpers.sweetPromptValidation""":
          """Enter an identifier before continuing.""",
      """pages.helpers.sweetPromptFilledPrefix""":
          """SweetAlert.prompt confirmed with value""",
      """pages.helpers.sweetPromptDismissed""":
          """SweetAlert.prompt was cancelled.""",
      """pages.helpers.sweetErrorBody""":
          """SweetAlert error toast shown in the bottom corner.""",
      """pages.helpers.sweetErrorState""":
          """SweetAlert.toast executed with error type.""",
      """pages.button.title""": """Components""",
      """pages.button.subtitle""": """Buttons""",
      """pages.button.breadcrumb""": """Button styles and variations""",
      """pages.button.overviewIntro""":
          """This page brings together color, style, size, alignment, and state variations for the button component.""",
      """pages.button.usePrefix""": """Use""",
      """pages.button.demoButton""": """Button""",
      """pages.button.lightCardTitle""": """Light button""",
      """pages.button.darkCardTitle""": """Dark button""",
      """pages.button.primaryCardTitle""": """Primary button""",
      """pages.button.secondaryCardTitle""": """Secondary button""",
      """pages.button.dangerCardTitle""": """Danger button""",
      """pages.button.successCardTitle""": """Success button""",
      """pages.button.warningCardTitle""": """Warning button""",
      """pages.button.infoCardTitle""": """Info button""",
      """pages.button.indigoCardTitle""": """Indigo button""",
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
      """pages.fab.title""": """Components""",
      """pages.fab.subtitle""": """FAB""",
      """pages.fab.breadcrumbParent""": """Components""",
      """pages.fab.breadcrumb""": """FAB""",
      """pages.fab.intro""":
          """Floating action button (FAB) menu is the component used to display a single floating button with or without a nested menu. The demo below follows the Limitless visual organization with interaction, direction, label, and color examples.""",
      """pages.fab.basicTitle""": """Basic examples""",
      """pages.fab.basicSubtitle""": """Demo of buttons and button lists""",
      """pages.fab.singleTitle""": """Single floating button""",
      """pages.fab.singleBody""":
          """Floating button uses regular button markup with .fab-menu-btn inside the .fab-menu container.""",
      """pages.fab.hoverTitle""": """Open menu on hover""",
      """pages.fab.hoverBody""":
          """Use data-fab-toggle="hover" semantics for menus that should expand on hover.""",
      """pages.fab.clickTitle""": """Open menu on click""",
      """pages.fab.clickBody""":
          """The most common case is click-to-open with the default icon-only trigger.""",
      """pages.fab.elementsTitle""": """FAB menu elements""",
      """pages.fab.elementsSubtitle""":
          """Buttons, directions, and fixed placement""",
      """pages.fab.simpleButtonsTitle""": """Simple buttons""",
      """pages.fab.simpleButtonsBody""":
          """The submenu usually contains rounded buttons with a single icon.""",
      """pages.fab.sideActionsTitle""": """Side actions""",
      """pages.fab.sideActionsBody""":
          """Left direction keeps the main trigger compact while exposing contextual actions on the side.""",
      """pages.fab.customTemplatesTitle""": """Custom templates""",
      """pages.fab.customTemplatesBody""":
          """Use TemplateRef to customize trigger and action content without replacing the FAB behavior, keyboard shortcuts, or link handling.""",
      """pages.fab.noBackdropTitle""": """No-backdrop page action""",
      """pages.fab.noBackdropBody""":
          """The no-backdrop variant is previewed inside the card to avoid colliding with the left sidebar. The actual fixed FAB remains on the right edge.""",
      """pages.fab.innerLabelsTitle""": """Inner button labels""",
      """pages.fab.innerLabelsSubtitle""":
          """Visible tooltips, light labels, and label positions""",
      """pages.fab.visibleLabelsTitle""": """Visible labels""",
      """pages.fab.visibleLabelsBody""":
          """Use .fab-label-visible when labels should stay visible while the menu is expanded.""",
      """pages.fab.lightLabelsTitle""": """Light labels""",
      """pages.fab.lightLabelsBody""":
          """All button types support light tooltips as an alternative to the default dark labels.""",
      """pages.fab.labelPositionsTitle""": """Label positions""",
      """pages.fab.labelPositionsBody""":
          """Left is default; use .fab-label-end to place labels on the right side.""",
      """pages.fab.defaultColorsTitle""": """Default button colors""",
      """pages.fab.defaultColorsSubtitle""":
          """Examples of predefined contextual colors""",
      """pages.fab.primaryColorTitle""": """Primary button color""",
      """pages.fab.primaryColorBody""":
          """Primary contextual color uses the standard .btn-primary main button.""",
      """pages.fab.successColorTitle""": """Success button color""",
      """pages.fab.successColorBody""":
          """Use .btn-success for a positive contextual variant.""",
      """pages.fab.warningColorTitle""": """Warning button color""",
      """pages.fab.warningColorBody""":
          """Warning is a strong contextual alternative for attention-heavy actions.""",
      """pages.fab.customColorsTitle""": """Custom color options""",
      """pages.fab.customColorsSubtitle""":
          """Use custom colors in main and inner buttons""",
      """pages.fab.customMainColorTitle""": """Custom main button color""",
      """pages.fab.customMainColorBody""":
          """Secondary palette colors can be applied directly to the main trigger.""",
      """pages.fab.customInnerColorTitle""": """Custom inner button color""",
      """pages.fab.customInnerColorBody""":
          """Inner actions can use any Limitless button color while keeping the light main trigger.""",
      """pages.fab.mixedColorsTitle""": """Mixing button colors""",
      """pages.fab.mixedColorsBody""":
          """The submenu supports mixed contextual colors without changing the structural markup.""",
      """pages.fab.waitingAction""": """Waiting for FAB action.""",
      """pages.fab.demoActionPrefix""": """FAB action selected: """,
      """pages.fab.fixedActionPrefix""":
          """Fixed FAB with backdrop triggered: """,
      """pages.fab.noBackdropActionPrefix""":
          """Fixed FAB without backdrop triggered: """,
      """pages.fab.apiIntro""":
          """The AngularDart implementation keeps the Limitless visual contract and exposes a short API for actions, direction, toggle, and positioning.""",
      """pages.fab.overviewLead""": """Default FAB menu markup:""",
      """pages.fab.classesTitle""": """FAB menu classes""",
      """pages.fab.classesIntro""":
          """FAB menu styling is driven by CSS classes and data attributes. The table below summarizes the classes used by this AngularDart wrapper while preserving the original Limitless contract.""",
      """pages.fab.classHeader""": """Class""",
      """pages.fab.descriptionHeader""": """Description""",
      """pages.fab.basicClassesGroup""": """Basic classes""",
      """pages.fab.directionsGroup""": """Directions and positioning""",
      """pages.fab.visibilityGroup""": """Visibility and labels""",
      """pages.fab.classMenuDesc""": """Main wrapper used by the component.""",
      """pages.fab.classMenuBtnDesc""": """Main circular trigger button.""",
      """pages.fab.classMenuInnerDesc""": """Inner action list container.""",
      """pages.fab.classIconsDesc""":
          """Icons rotated and faded by the Limitless CSS depending on menu state.""",
      """pages.fab.classMenuTopDesc""": """Menu opens below the trigger.""",
      """pages.fab.classMenuBottomDesc""": """Menu opens above the trigger.""",
      """pages.fab.classMenuFixedDesc""":
          """Viewport-fixed FAB used for persistent page actions.""",
      """pages.fab.classDirHorizontalDesc""":
          """Horizontal extensions added by the AngularDart wrapper.""",
      """pages.fab.toggleClickDesc""": """Click-to-open behavior.""",
      """pages.fab.toggleHoverDesc""": """Hover-to-open behavior.""",
      """pages.fab.stateOpenDesc""": """Applied while the menu is expanded.""",
      """pages.fab.dataFabLabelDesc""": """Tooltip text for inner actions.""",
      """pages.fab.labelModifiersDesc""":
          """Right-aligned, light, and persistent label modifiers.""",
      """pages.fab.customTriggerClose""": """Close""",
      """pages.fab.customTriggerActions""": """Quick actions""",
      """pages.fab.actionComposeEmail""": """Compose email""",
      """pages.fab.actionConversations""": """Conversations""",
      """pages.fab.actionAccountSecurity""": """Account security""",
      """pages.fab.actionAnalytics""": """Analytics""",
      """pages.fab.actionPrivacy""": """Privacy""",
      """pages.fab.actionEdit""": """Edit""",
      """pages.fab.actionShare""": """Share""",
      """pages.fab.actionArchive""": """Archive""",
      """pages.fab.actionPublish""": """Publish""",
      """pages.fab.actionSaveDraft""": """Save draft""",
      """pages.fab.actionPreview""": """Preview""",
      """pages.fab.markupRunPipeline""": """Run pipeline""",
    };
