import 'dart:html' as html;
import 'package:limitless_ui_example/limitless_ui_example.dart';
@Component(
  selector: 'helpers-page',
  templateUrl: 'helpers_page.html',
  styleUrls: ['helpers_page.css'],
  directives: [
    coreDirectives,
    LiTabsComponent,
    LiTabxDirective,
  ],
)
class HelpersPageComponent implements OnDestroy {
  HelpersPageComponent(this.i18n);

  final DemoI18nService i18n;
  Messages get t => i18n.t;

  final SimpleLoading _loading = SimpleLoading();
  String helperState = '';

  @ViewChild('loadingHost')
  html.DivElement? loadingHost;

  void showLoadingOverlay() {
    final host = loadingHost;
    if (host == null) {
      return;
    }

    helperState = t.pages.helpers.loadingShown;
    _loading.show(target: host);
    Future<void>.delayed(const Duration(seconds: 2), () {
      _loading.hide();
      helperState = t.pages.helpers.loadingHidden;
    });
  }

  void showDialogAlert() {
    SimpleDialogComponent.showAlert(
      t.pages.helpers.dialogAlertBody,
      title: t.pages.helpers.dialogAlertTitle,
      dialogColor: DialogColor.INFO,
    );
    helperState = t.pages.helpers.dialogAlertState;
  }

  Future<void> showDialogConfirm() async {
    final confirmed = await SimpleDialogComponent.showConfirm(
      t.pages.helpers.dialogConfirmBody,
      title: t.pages.helpers.dialogConfirmTitle,
      confirmButtonText: t.pages.helpers.dialogConfirmOk,
      cancelButtonText: t.pages.helpers.dialogConfirmCancel,
      dialogColor: DialogColor.WARNING,
    );

    helperState = confirmed
        ? t.pages.helpers.dialogConfirmTrue
        : t.pages.helpers.dialogConfirmFalse;
  }

  void showSimplePopover(html.Element target) {
    SimplePopover.showWarning(
      target,
      t.pages.helpers.simplePopoverBody,
    );
    helperState = t.pages.helpers.simplePopoverState;
  }

  void showSweetPopover(html.Element target) {
    SweetAlertPopover.showPopover(
      target,
      t.pages.helpers.sweetPopoverBody,
      title: t.pages.helpers.sweetPopoverTitle,
    );
    helperState = t.pages.helpers.sweetPopoverState;
  }

  void showSimpleSuccessToast() {
    SimpleToast.showSuccess(t.pages.helpers.simpleSuccessBody);
    helperState = t.pages.helpers.simpleSuccessState;
  }

  void showSimpleWarningToast() {
    SimpleToast.showWarning(t.pages.helpers.simpleWarningBody);
    helperState = t.pages.helpers.simpleWarningState;
  }

  void showSweetSuccessToast() {
    SweetAlertSimpleToast.showSuccessToast(t.pages.helpers.sweetSuccessBody);
    helperState = t.pages.helpers.sweetSuccessState;
  }

  void showSweetWarningToast() {
    SweetAlertSimpleToast.showWarningToast(t.pages.helpers.sweetWarningBody);
    helperState = t.pages.helpers.sweetWarningState;
  }

  @override
  void ngOnDestroy() {
    _loading.hide();
  }
}
