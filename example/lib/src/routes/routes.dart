import 'package:limitless_ui_example/limitless_ui_example.dart';
import 'package:ngrouter/ngrouter.dart';

import 'package:limitless_ui_example/src/pages/accordion/accordion_page.template.dart'
    as accordion_page;
import 'package:limitless_ui_example/src/pages/alert/alert_page.template.dart'
    as alert_page;
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
import 'package:limitless_ui_example/src/pages/helpers/helpers_page.template.dart'
    as helpers_page;
import 'package:limitless_ui_example/src/pages/modal/modal_page.template.dart'
    as modal_page;
import 'package:limitless_ui_example/src/pages/multi_select/multi_select_page.template.dart'
    as multi_select_page;
import 'package:limitless_ui_example/src/pages/notification/notification_page.template.dart'
    as notification_page;
import 'package:limitless_ui_example/src/pages/overview/overview_page.template.dart'
    as overview_page;
import 'package:limitless_ui_example/src/pages/progress/progress_page.template.dart'
    as progress_page;
import 'package:limitless_ui_example/src/pages/select/select_page.template.dart'
    as select_page;
import 'package:limitless_ui_example/src/pages/tabs/tabs_page.template.dart'
    as tabs_page;
import 'package:limitless_ui_example/src/pages/tooltip/tooltip_page.template.dart'
    as tooltip_page;
import 'package:limitless_ui_example/src/pages/treeview/treeview_page.template.dart'
    as treeview_page;

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

  static final select = RouteDefinition(
    routePath: DemoRoutePaths.select,
    component: select_page.SelectPageComponentNgFactory,
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

  static final dateRange = RouteDefinition(
    routePath: DemoRoutePaths.dateRange,
    component: date_range_page.DateRangePageComponentNgFactory,
  );

  static final carousel = RouteDefinition(
    routePath: DemoRoutePaths.carousel,
    component: carousel_page.CarouselPageComponentNgFactory,
  );

  static final tooltip = RouteDefinition(
    routePath: DemoRoutePaths.tooltip,
    component: tooltip_page.TooltipPageComponentNgFactory,
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

  static final treeview = RouteDefinition(
    routePath: DemoRoutePaths.treeview,
    component: treeview_page.TreeviewPageComponentNgFactory,
  );

  static final helpers = RouteDefinition(
    routePath: DemoRoutePaths.helpers,
    component: helpers_page.HelpersPageComponentNgFactory,
  );

  static final all = <RouteDefinition>[
    overview,
    alerts,
    progress,
    accordion,
    tabs,
    modal,
    select,
    multiSelect,
    currency,
    datePicker,
    dateRange,
    carousel,
    tooltip,
    datatable,
    datatableSelect,
    notification,
    treeview,
    helpers,
    RouteDefinition.redirect(
      path: '.+',
      redirectTo: DemoRoutePaths.overview.path,
    ),
  ];
}
