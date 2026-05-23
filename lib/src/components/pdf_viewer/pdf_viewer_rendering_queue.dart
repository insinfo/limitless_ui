import 'dart:async';
import 'dart:collection';

import 'pdf_viewer_page_view.dart';

class PdfViewerRenderingQueue {
  PdfViewerRenderingQueue({
    required Future<void> Function(PdfPageView pageView) renderPage,
    required void Function(PdfPageView pageView) onRendered,
    required void Function(String message) onLog,
  })  : _renderPage = renderPage,
        _onRendered = onRendered,
        _onLog = onLog;

  final Future<void> Function(PdfPageView pageView) _renderPage;
  final void Function(PdfPageView pageView) _onRendered;
  final void Function(String message) _onLog;

  final List<PdfPageView> _queue = <PdfPageView>[];
  PdfPageView? _activeView;
  bool _disposed = false;
  int _generation = 0;

  void schedule(
    Iterable<PdfPageView> pageViews, {
    Set<int>? cancelActiveOutsidePageIds,
  }) {
    if (_disposed) {
      return;
    }

    final seen = <int>{};
    final nextQueue = <PdfPageView>[];
    for (final view in pageViews) {
      if (!seen.add(view.pageNum) || !_needsRendering(view)) {
        continue;
      }
      nextQueue.add(view);
    }

    _queue
      ..clear()
      ..addAll(nextQueue);

    final active = _activeView;
    if (active != null &&
        cancelActiveOutsidePageIds != null &&
        !cancelActiveOutsidePageIds.contains(active.pageNum)) {
      active.cancelRender();
      active.renderingState =
          active.canvas == null ? RenderingState.initial : RenderingState.zooming;
    }

    _generation++;
    unawaited(_drain(_generation));
  }

  void clear({bool cancelActive = false}) {
    _queue.clear();
    if (cancelActive) {
      final active = _activeView;
      if (active != null) {
        active.cancelRender();
        active.renderingState = active.canvas == null
            ? RenderingState.initial
            : RenderingState.zooming;
      }
    }
    _generation++;
  }

  void dispose() {
    _disposed = true;
    clear(cancelActive: true);
  }

  bool _needsRendering(PdfPageView view) {
    if (identical(view, _activeView)) {
      return false;
    }

    return view.renderingState != RenderingState.finished &&
        view.renderingState != RenderingState.rendering;
  }

  Future<void> _drain(int generation) async {
    if (_activeView != null || _disposed) {
      return;
    }

    while (_queue.isNotEmpty && !_disposed) {
      final view = _queue.removeAt(0);
      if (!_needsRendering(view)) {
        continue;
      }

      _activeView = view;
      try {
        await _renderPage(view);
        if (view.renderingState == RenderingState.finished) {
          _onRendered(view);
        }
      } catch (error) {
        _onLog('Error in PDF rendering queue for page ${view.pageNum}: $error');
      } finally {
        if (identical(_activeView, view)) {
          _activeView = null;
        }
      }

      if (generation != _generation) {
        generation = _generation;
      }
    }
  }
}

class PdfPageViewCache {
  PdfPageViewCache(this._size);

  final LinkedHashSet<PdfPageView> _buffer = LinkedHashSet<PdfPageView>();
  int _size;

  void push(PdfPageView view) {
    if (_buffer.remove(view)) {
      _buffer.add(view);
      return;
    }

    _buffer.add(view);
    _trim();
  }

  void resize(int newSize, {Set<int>? idsToKeep}) {
    _size = newSize;

    if (idsToKeep != null && idsToKeep.isNotEmpty) {
      final current = _buffer.toList(growable: false);
      for (final view in current) {
        if (!idsToKeep.contains(view.pageNum)) {
          continue;
        }
        if (_buffer.remove(view)) {
          _buffer.add(view);
        }
      }
    }

    _trim(idsToKeep: idsToKeep);
  }

  void clear({bool destroyPages = false}) {
    if (destroyPages) {
      for (final view in _buffer) {
        view.destroy();
      }
    }
    _buffer.clear();
  }

  void _trim({Set<int>? idsToKeep}) {
    while (_buffer.length > _size) {
      final first = _buffer.first;
      if (idsToKeep != null && idsToKeep.contains(first.pageNum)) {
        _buffer
          ..remove(first)
          ..add(first);
        if (_buffer.every((view) => idsToKeep.contains(view.pageNum))) {
          break;
        }
        continue;
      }

      first.destroy();
      _buffer.remove(first);
    }
  }
}