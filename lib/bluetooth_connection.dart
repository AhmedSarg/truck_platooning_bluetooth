import 'package:flutter/material.dart';

class BluetoothConnection extends StatelessWidget {
  const BluetoothConnection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Item();
        },
      ),
    );
  }
}

class Item extends StatelessWidget {
  const Item({super.key});

  @override
  Widget build(BuildContext context) {
    // BlueDevice.instance.connection
    return const Placeholder();
  }
}
