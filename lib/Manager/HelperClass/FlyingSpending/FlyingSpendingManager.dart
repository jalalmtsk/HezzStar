import 'package:flutter/material.dart';
import 'FlyingSpendingWidget.dart';
import 'dart:async';

class FlyingSpendManager {
  static final FlyingSpendManager _instance = FlyingSpendManager._internal();
  factory FlyingSpendManager() => _instance;
  FlyingSpendManager._internal();

  late OverlayState _overlayState;

  void init(BuildContext context) {
    _overlayState = Overlay.of(context)!;
  }

  /// Now returns a Future that completes when all flying icons finish
  Future<void> spawnSpend({
    required BuildContext context,
    required Offset start,
    required GlobalKey endKey,
    required int amount,
  }) async {
    _overlayState = Overlay.of(context)!;

    int numIcons = amount < 50 ? 3 : amount < 200 ? 6 : 10;
    int perIcon = (amount / numIcons).ceil();

    final completers = <Completer<void>>[];

    for (int i = 0; i < numIcons; i++) {
      final completer = Completer<void>();
      completers.add(completer);

      Future.delayed(Duration(milliseconds: i * 80), () {
        OverlayEntry? entry;
        entry = OverlayEntry(
          builder: (context) => FlyingSpendWidget(
            startOffset: start,
            endKey: endKey,
            amount: perIcon,
            onCompleted: () {
              entry?.remove();
              completer.complete();
            },
          ),
        );
        _overlayState.insert(entry);
      });
    }

    // Wait until all icons complete
    await Future.wait(completers.map((c) => c.future));
  }
}
