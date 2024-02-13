import 'package:flutter/material.dart';

///Mixin that implements basic tools to use overlays
// ignore: lines_longer_than_80_chars
mixin OverlayerViewMixin<T extends StatefulWidget> on State<T> implements _IOverlayView {
  ///startup task to add startup overlays to widget tree
  void _startup(Duration _) {
    insertOverlays(
      _filterOverlaysWith(
        [
          OverlayMode.addAtStart,
        ],
      ).values,
    );
  }

  ///register startup using WidgetsBindings method called addPostFrameCallback
  ///to run startup callback after first frame
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_startup);
  }

  ///get removable overlays
  Map<OverlayEntryKey, OverlayEntry> get removableOverlays {
    return _filterOverlaysWith(
      [OverlayMode.cannotBeRemoved],
      false,
    );
  }

  ///get map of overlays with selected modes
  ///uses [containMode] true by default and will filter
  ///by test based on contain[modes]
  ///
  ///if [containMode] set to false then it will return overlays
  ///that don't have those modes
  ///
  ///if modes set to nothing it will return all of overlays and
  ///[containMode] is useless
  Map<OverlayEntryKey, OverlayEntry> _filterOverlaysWith(
    List<OverlayMode> modes, [
    bool containMode = true,
  ]) {
    var items = overlayEntries.entries.toList();
    for (final mode in modes) {
      items = items
          .where(
            (element) => element.key.modes.contains(mode) == containMode,
          )
          .toList();
    }
    return Map.fromEntries(items);
  }

  ///if you pass [entries] it will insert over current overlays
  ///# will throw exception on repetitive entries
  ///if nothing passed it will take items that are not tagged with
  ///[OverlayMode.addAtStart] and insert them
  bool insertOverlays([Iterable<OverlayEntry>? entries]) {
    final items = entries ??
        _filterOverlaysWith(
          [
            OverlayMode.addAtStart,
          ],
          false,
        ).values;
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      return false;
    }
    items.forEach(overlay.insert);
    return true;
  }

  ///will update every overlay that are not tagged with [OverlayMode.noRefresh]
  ///by calling its [OverlayEntry.markNeedsBuild]
  void refreshOverlays() {
    for (final entry in _filterOverlaysWith(
      [
        OverlayMode.noRefresh,
      ],
      false,
    ).values) {
      entry.markNeedsBuild();
    }
  }

  ///will remove removableOverlays
  ///(except entries tagged with [OverlayMode.cannotBeRemoved])
  void removeOverlays() {
    for (final entry in removableOverlays.values) {
      entry.remove();
    }
  }
}

abstract class _IOverlayView {
  ///list of overlay entries will that this view contains
  Map<OverlayEntryKey, OverlayEntry> get overlayEntries;
}

enum OverlayMode {
  cannotBeRemoved('#STATIC'),
  noRefresh('#STATELESS'),
  addAtStart('#STARTUP');

  const OverlayMode(this._tag);
  final String _tag;
  @override
  String toString() => _tag;
}

class OverlayEntryKey {

  ///Overlay entry Key that contains overlay name and modes
  const OverlayEntryKey(this.name, [this.modes = const []]);
  ///Overlay modes => [OverlayMode]
  final List<OverlayMode> modes;

  ///Overlay Name
  final String name;
}
