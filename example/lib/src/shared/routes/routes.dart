// ignore_for_file: uri_has_not_been_generated

import 'package:ngrouter/ngrouter.dart';

import 'package:limitless_ui_example/src/pages/accordion/accordion_page.template.dart'
    as accordion_page;
import 'package:limitless_ui_example/src/pages/alert/alert_page.template.dart'
    as alert_page;
import 'package:limitless_ui_example/src/pages/breadcrumbs/breadcrumbs_page.template.dart'
    as breadcrumbs_page;
import 'package:limitless_ui_example/src/pages/pagination/pagination_page.template.dart'
    as pagination_page;
import 'package:limitless_ui_example/src/pages/carousel/carousel_page.template.dart'
    as carousel_page;
import 'package:limitless_ui_example/src/pages/currency/currency_page.template.dart'
    as currency_page;
import 'package:limitless_ui_example/src/pages/datatable/datatable_page.template.dart'
    as datatable_page;
import 'package:limitless_ui_example/src/pages/datatable_select/datatable_select_page.template.dart'
    as datatable_select_page;
import 'package:limitless_ui_example/src/pages/date_picker/date_picker_page.template.dart'
    as date_picker_page;
import 'package:limitless_ui_example/src/pages/date_range/date_range_page.template.dart'
    as date_range_page;
import 'package:limitless_ui_example/src/pages/time_picker/time_picker_page.template.dart'
    as time_picker_page;
import 'package:limitless_ui_example/src/pages/button/button_page.template.dart'
    as button_page;
import 'package:limitless_ui_example/src/pages/helpers/helpers_page.template.dart'
    as helpers_page;
import 'package:limitless_ui_example/src/pages/modal/modal_page.template.dart'
    as modal_page;
import 'package:limitless_ui_example/src/pages/multi_select/multi_select_page.template.dart'
    as multi_select_page;
import 'package:limitless_ui_example/src/pages/nav/nav_page.template.dart'
    as nav_page;
import 'package:limitless_ui_example/src/pages/notification/notification_page.template.dart'
    as notification_page;
import 'package:limitless_ui_example/src/pages/offcanvas/offcanvas_page.template.dart'
    as offcanvas_page;
import 'package:limitless_ui_example/src/pages/overview/overview_page.template.dart'
    as overview_page;
import 'package:limitless_ui_example/src/pages/popover/popover_page.template.dart'
    as popover_page;
import 'package:limitless_ui_example/src/pages/progress/progress_page.template.dart'
    as progress_page;
import 'package:limitless_ui_example/src/pages/scrollspy/scrollspy_page.template.dart'
    as scrollspy_page;
import 'package:limitless_ui_example/src/pages/select/select_page.template.dart'
    as select_page;
import 'package:limitless_ui_example/src/pages/typeahead/typeahead_page.template.dart'
    as typeahead_page;
import 'package:limitless_ui_example/src/pages/dropdown/dropdown_page.template.dart'
    as dropdown_page;
import 'package:limitless_ui_example/src/pages/tabs/tabs_page.template.dart'
    as tabs_page;
import 'package:limitless_ui_example/src/pages/toast/toast_page.template.dart'
    as toast_page;
import 'package:limitless_ui_example/src/pages/tooltip/tooltip_page.template.dart'
    as tooltip_page;
import 'package:limitless_ui_example/src/pages/treeview/treeview_page.template.dart'
    as treeview_page;
import 'route_paths.dart';

class DemoRoutes {
  static final overview = RouteDefinition(
    routePath: DemoRoutePaths.overview,
    component: overview_page.OverviewPageComponentNgFactory,
    useAsDefault: true,
  );

  static final alerts = RouteDefinition(
    routePath: DemoRoutePaths.alerts,
    component: alert_page.AlertPageComponentNgFactory,
  );

  static final progress = RouteDefinition(
    routePath: DemoRoutePaths.progress,
    component: progress_page.ProgressPageComponentNgFactory,
  );

  static final accordion = RouteDefinition(
    routePath: DemoRoutePaths.accordion,
    component: accordion_page.AccordionPageComponentNgFactory,
  );

  static final tabs = RouteDefinition(
    routePath: DemoRoutePaths.tabs,
    component: tabs_page.TabsPageComponentNgFactory,
  );

  static final modal = RouteDefinition(
    routePath: DemoRoutePaths.modal,
    component: modal_page.ModalPageComponentNgFactory,
  );

  static final offcanvas = RouteDefinition(
    routePath: DemoRoutePaths.offcanvas,
    component: offcanvas_page.OffcanvasPageComponentNgFactory,
  );

  static final breadcrumbs = RouteDefinition(
    routePath: DemoRoutePaths.breadcrumbs,
    component: breadcrumbs_page.BreadcrumbsPageComponentNgFactory,
  );

  static final pagination = RouteDefinition(
    routePath: DemoRoutePaths.pagination,
    component: pagination_page.PaginationPageComponentNgFactory,
  );

  static final select = RouteDefinition(
    routePath: DemoRoutePaths.select,
    component: select_page.SelectPageComponentNgFactory,
  );

  static final typeahead = RouteDefinition(
    routePath: DemoRoutePaths.typeahead,
    component: typeahead_page.TypeaheadPageComponentNgFactory,
  );

  static final multiSelect = RouteDefinition(
    routePath: DemoRoutePaths.multiSelect,
    component: multi_select_page.MultiSelectPageComponentNgFactory,
  );

  static final currency = RouteDefinition(
    routePath: DemoRoutePaths.currency,
    component: currency_page.CurrencyPageComponentNgFactory,
  );

  static final datePicker = RouteDefinition(
    routePath: DemoRoutePaths.datePicker,
    component: date_picker_page.DatePickerPageComponentNgFactory,
  );

  static final timePicker = RouteDefinition(
    routePath: DemoRoutePaths.timePicker,
    component: time_picker_page.TimePickerPageComponentNgFactory,
  );

  static final dateRange = RouteDefinition(
    routePath: DemoRoutePaths.dateRange,
    component: date_range_page.DateRangePageComponentNgFactory,
  );

  static final carousel = RouteDefinition(
    routePath: DemoRoutePaths.carousel,
    component: carousel_page.CarouselPageComponentNgFactory,
  );

  static final scrollSpy = RouteDefinition(
    routePath: DemoRoutePaths.scrollSpy,
    component: scrollspy_page.ScrollspyPageComponentNgFactory,
  );

  static final tooltip = RouteDefinition(
    routePath: DemoRoutePaths.tooltip,
    component: tooltip_page.TooltipPageComponentNgFactory,
  );

  static final popover = RouteDefinition(
    routePath: DemoRoutePaths.popover,
    component: popover_page.PopoverPageComponentNgFactory,
  );

  static final nav = RouteDefinition(
    routePath: DemoRoutePaths.nav,
    component: nav_page.NavPageComponentNgFactory,
  );

  static final dropdown = RouteDefinition(
    routePath: DemoRoutePaths.dropdown,
    component: dropdown_page.DropdownPageComponentNgFactory,
  );

  static final datatable = RouteDefinition(
    routePath: DemoRoutePaths.datatable,
    component: datatable_page.DatatablePageComponentNgFactory,
  );

  static final datatableSelect = RouteDefinition(
    routePath: DemoRoutePaths.datatableSelect,
    component: datatable_select_page.DatatableSelectPageComponentNgFactory,
  );

  static final notification = RouteDefinition(
    routePath: DemoRoutePaths.notification,
    component: notification_page.NotificationPageComponentNgFactory,
  );

  static final toast = RouteDefinition(
    routePath: DemoRoutePaths.toast,
    component: toast_page.ToastPageComponentNgFactory,
  );

  static final treeview = RouteDefinition(
    routePath: DemoRoutePaths.treeview,
    component: treeview_page.TreeviewPageComponentNgFactory,
  );

  static final helpers = RouteDefinition(
    routePath: DemoRoutePaths.helpers,
    component: helpers_page.HelpersPageComponentNgFactory,
  );

  static final button = RouteDefinition(
    routePath: DemoRoutePaths.button,
    component: button_page.ButtonPageComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    overview,
    alerts,
    progress,
    accordion,
    tabs,
    modal,
    offcanvas,
    breadcrumbs,
    pagination,
    select,
    typeahead,
    multiSelect,
    currency,
    datePicker,
    timePicker,
    dateRange,
    carousel,
    scrollSpy,
    tooltip,
    popover,
    nav,
    dropdown,
    datatable,
    datatableSelect,
    toast,
    notification,
    treeview,
    helpers,
    button,
    RouteDefinition.redirect(
      path: '.+',
      redirectTo: DemoRoutePaths.overview.path,
    ),
  ];
}
