import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() {
  runApp(const MyApp());
}

late BluetoothConnection connection;
Future<void> connect(
  BluetoothDevice device,
  context,
) async {
  try {
    connection = await BluetoothConnection.toAddress(device.address);
    connection.input!.listen(
      (event) {
        print(ascii.decode(event));
      },
    );
    print(connection.isConnected);
  } catch (e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('error in connect'),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await connect(device, context);
              },
              child: const Text('try again'),
            )
          ],
        ),
      ),
    );
  }
}

void rw(bool f, b, l, r) {
  String event;
  if (f & b) {
    event = 's';
  } else if (l & r) {
    event = 'n';
  } else if (f) {
    event = 'f';
  } else if (b) {
    event = 'b';
  } else if (l) {
    event = 'l';
  } else {
    event = 'r';
  }
  connection.output.add(ascii.encode(event));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyApp createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  String _address = "...";

  @override
  void initState() {
    super.initState();
    // FlutterBluetoothSerial.instance
    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address!;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool f = false, b = false, l = false, r = false;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.orange,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          // leading: IconButton(
          //   onPressed: () {
          //     Scaffold.of(context).openDrawer();
          //   },
          //   icon: Icon(
          //     Icons.bluetooth,
          //     color: Colors.orange,
          //   ),
          // ),
          title: const Center(
            child: Text(
              'Truck Platooning',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        drawer: SafeArea(
          child: Drawer(
            backgroundColor: Colors.black87,
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    const Text(
                      'Connection',
                      style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Enable Bluetooth',
                          style: TextStyle(color: Colors.orange)),
                      value: _bluetoothState.isEnabled,
                      activeColor: Colors.orange,
                      onChanged: (bool value) {
                        // Do the request and update with the true value then
                        future() async {
                          // async lambda seems to not working
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    ),
                    FutureBuilder(
                        future:
                            FlutterBluetoothSerial.instance.getBondedDevices(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    snapshot.data![index].name!,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    snapshot.data![index].address,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  trailing: ElevatedButton(
                                    child: const Text('Connect'),
                                    onPressed: () async {
                                      await connect(
                                          snapshot.data![index], context);
                                    },
                                  ),
                                );
                              },
                            );
                          } else {
                            return const Text('enable bluetooth');
                          }
                        }),
                    ListTile(
                      title: const Text('Bluetooth status',
                          style: TextStyle(color: Colors.orange)),
                      subtitle: Text(_bluetoothState.toString(),
                          style: const TextStyle(color: Colors.orangeAccent)),
                      trailing: ElevatedButton(
                        child: const Text('Settings'),
                        onPressed: () {
                          FlutterBluetoothSerial.instance.openSettings();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Container(
          color: Colors.black,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  f = true;
                  if (b) {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        f = false;
                      },
                    );
                  } else {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        rw(f, b, l, r);
                        f = false;
                      },
                    );
                  }
                },
                icon: const Icon(
                  Icons.arrow_upward,
                ),
                color: Colors.orange,
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 50,
                      ),
                      child: IconButton(
                        onPressed: () {
                          l = true;
                          if (r) {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                l = false;
                              },
                            );
                          } else {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                rw(f, b, l, r);
                                l = false;
                              },
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        color: Colors.orange,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 50,
                      ),
                      child: IconButton(
                        onPressed: () {
                          r = true;
                          if (l) {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                r = false;
                              },
                            );
                          } else {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                rw(f, b, l, r);
                                r = false;
                              },
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                        ),
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  b = true;
                  if (f) {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        b = false;
                      },
                    );
                  } else {
                    Future.delayed(
                      const Duration(milliseconds: 100),
                      () {
                        rw(f, b, l, r);
                        b = false;
                      },
                    );
                  }
                },
                icon: const Icon(
                  Icons.arrow_downward,
                ),
                color: Colors.orange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// This widget is the root of your application.

class BluetoothDeviceListEntry extends ListTile {
  BluetoothDeviceListEntry({
    super.key,
    required BluetoothDevice device,
    int? rssi,
    GestureTapCallback? onTop,
    super.onLongPress,
    super.enabled,
  }) : super(
          onTap: onTop,
          leading: const Icon(Icons.devices),
          title: Text(device.name ?? ''),
          subtitle: Text(device.address.toString()),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              rssi != null
                  ? Container(
                      margin: const EdgeInsets.all(8.0),
                      child: DefaultTextStyle(
                        style: const TextStyle(color: Colors.orange),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text(rssi.toString()),
                            const Text('dBm'),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
              device.isConnected
                  ? const Icon(Icons.import_export)
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
              device.isBonded
                  ? const Icon(Icons.link)
                  : const SizedBox(
                      width: 0,
                      height: 0,
                    ),
            ],
          ),
        );
}
