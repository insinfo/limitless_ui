import 'datatable_col.dart';

/// Resolves title rendering, tooltip, and popover metadata for column headers.
///
/// Keeping these pure accessors out of the component makes the template support
/// code easier to maintain without changing render behavior.
class DatatableTitleHelpController {
  /// Whether the column title was rendered as an HTML node.
  bool hasRenderedTitleHtml(DatatableCol column) {
    return column.titleHtmlElement != null;
  }

  /// Text title already resolved by the row builder/settings metadata step.
  String resolveRenderedTitle(DatatableCol column) {
    return column.renderedTitle;
  }

  /// Whether the column has tooltip metadata.
  bool hasTitleTooltip(DatatableCol column) {
    return column.titleTooltip != null;
  }

  /// Whether the tooltip should be attached directly to the title text.
  bool isTitleTooltipInline(DatatableCol column) {
    return column.titleTooltip?.displayMode ==
        DatatableTitleTooltipDisplayMode.title;
  }

  /// Whether the tooltip text should be exposed through the native title attr.
  bool useNativeTitleTooltip(DatatableCol column) {
    return column.titleTooltip?.useNativeTitle ?? false;
  }

  /// Whether the column has popover metadata.
  bool hasTitlePopover(DatatableCol column) {
    return column.titlePopover != null;
  }

  Object? resolveTitleTooltipText(DatatableCol column) {
    return column.titleTooltip?.text;
  }

  String resolveTitleTooltipPlacement(DatatableCol column) {
    return column.titleTooltip?.placement ?? 'top';
  }

  String resolveTitleTooltipTrigger(DatatableCol column) {
    return column.titleTooltip?.trigger ?? 'hover focus';
  }

  bool resolveTitleTooltipAllowHtml(DatatableCol column) {
    return column.titleTooltip?.allowHtml ?? false;
  }

  String? resolveTitleTooltipClass(DatatableCol column) {
    return column.titleTooltip?.tooltipClass;
  }

  String? resolveTitleTooltipContainer(DatatableCol column) {
    return column.titleTooltip?.container;
  }

  int resolveTitleTooltipOpenDelay(DatatableCol column) {
    return column.titleTooltip?.openDelay ?? 0;
  }

  int resolveTitleTooltipCloseDelay(DatatableCol column) {
    return column.titleTooltip?.closeDelay ?? 0;
  }

  String resolveTitleTooltipIconClass(DatatableCol column) {
    return column.titleTooltip?.iconClass ?? 'ph ph-info';
  }

  String resolveTitleTooltipButtonClass(DatatableCol column) {
    return column.titleTooltip?.buttonClass ??
        'btn btn-link btn-icon p-0 border-0 bg-transparent datatable-title-help-button';
  }

  String resolveTitleTooltipAriaLabel(DatatableCol column) {
    return column.titleTooltip?.ariaLabel ?? 'Ajuda da coluna ${column.title}';
  }

  String? resolveNativeTitleTooltipText(DatatableCol column) {
    if (!useNativeTitleTooltip(column)) {
      return null;
    }

    final text = column.titleTooltip?.text;
    return text?.toString();
  }

  Object? resolveTitlePopoverBody(DatatableCol column) {
    return column.titlePopover?.body;
  }

  Object? resolveTitlePopoverTitle(DatatableCol column) {
    return column.titlePopover?.title;
  }

  String resolveTitlePopoverPlacement(DatatableCol column) {
    return column.titlePopover?.placement ?? 'top';
  }

  String resolveTitlePopoverTrigger(DatatableCol column) {
    return column.titlePopover?.trigger ?? 'click';
  }

  bool resolveTitlePopoverAllowHtml(DatatableCol column) {
    return column.titlePopover?.allowHtml ?? false;
  }

  String? resolveTitlePopoverClass(DatatableCol column) {
    return column.titlePopover?.popoverClass;
  }

  String? resolveTitlePopoverContainer(DatatableCol column) {
    return column.titlePopover?.container;
  }

  Object resolveTitlePopoverAutoClose(DatatableCol column) {
    return column.titlePopover?.autoClose ?? 'outside';
  }

  int resolveTitlePopoverOpenDelay(DatatableCol column) {
    return column.titlePopover?.openDelay ?? 0;
  }

  int resolveTitlePopoverCloseDelay(DatatableCol column) {
    return column.titlePopover?.closeDelay ?? 0;
  }

  String resolveTitlePopoverIconClass(DatatableCol column) {
    return column.titlePopover?.iconClass ?? 'ph ph-question';
  }

  String resolveTitlePopoverButtonClass(DatatableCol column) {
    return column.titlePopover?.buttonClass ??
        'btn btn-link btn-icon p-0 border-0 bg-transparent datatable-title-help-button';
  }

  String resolveTitlePopoverAriaLabel(DatatableCol column) {
    return column.titlePopover?.ariaLabel ??
        'Mais informações da coluna ${column.title}';
  }
}
