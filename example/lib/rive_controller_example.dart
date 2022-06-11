import 'package:flutter/material.dart';

class RiveControllerExample extends StatelessWidget {
  const RiveControllerExample({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RiveControllerExample'),
      ),
      body: const RiveExampleBody(),
    );
  }
}

class RiveExampleBody extends StatelessWidget {
  const RiveExampleBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: const Center(
        child: Text('RiveControllerExample'),
      ),
    );
  }
}
