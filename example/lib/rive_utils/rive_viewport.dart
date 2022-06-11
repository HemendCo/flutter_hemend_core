import 'package:flutter/material.dart';
import 'package:hemend/ui_related/pre_built_widgets/future_builder.dart';
import 'package:rive/rive.dart';

import 'rive_controller.dart';
import 'rive_loader.dart';

class RiveViewport extends StatefulWidget {
  const RiveViewport({
    super.key,
    required this.loader,
  });
  final RiveLoader loader;

  @override
  State<RiveViewport> createState() => _RiveViewportState();
}

class _RiveViewportState extends State<RiveViewport> {
  late Artboard artboard;
  late RiveSimpleToggleController controller;
  Future<Artboard> getArtBoardAndAttachToController() async {
    final file = await widget.loader.fileLoader();
    artboard = file.mainArtboard;

    controller = RiveSimpleToggleController.fromArtboard(artboard, 'stateMachine');
    artboard.addController(controller);
    return artboard;
  }

  @override
  Widget build(BuildContext context) {
    return BuildInFuture(
      itemFromFuture: getArtBoardAndAttachToController(),
      childInFuture: (_, artBoard, rebuilder) {
        return GestureDetector(
          onTap: () => controller.toggle(),
          onLongPressStart: (_) {
            controller.isUnderPressure = true;
          },
          onLongPressEnd: (_) {
            controller.isUnderPressure = false;
            controller.toggle();
          },
          child: Rive(
            artboard: artboard,
          ),
        );
      },
    );
  }
}
