import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


   await Permission.bluetoothScan.request(); // Dynamically request Bluetooth scan permission
  
  await FlutterBlue.instance
      .startScan(timeout: Duration(seconds: 4)); // Start Bluetooth scan
      
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'LED Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLedOn = false;
  BluetoothDevice? _connectedDevice;
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  Future<void> _initBluetooth() async {
    // Start scanning for devices
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    // Listen for scan results
    flutterBlue.scanResults.listen((results) {
      // Connect to the first found device
      if (results.isNotEmpty) {
        setState(() {
          _connectedDevice = results.first.device;
        });
        // Stop scanning once connected
        flutterBlue.stopScan();
      }
    });
  }

  Future<void> _enableBluetoothAndScan() async {
    // Enable Bluetooth
    await flutterBlue.isOn.then((isOn) async {
      if (!isOn) {
        await flutterBlue.startScan(timeout: Duration(seconds: 4));
      } else {
        await flutterBlue.stopScan();
        await flutterBlue.startScan(timeout: Duration(seconds: 4));
      }
    });
    // Navigate to Bluetooth devices screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BluetoothDevicesScreen()),
    );
  }

  Future<void> _connectToDevice() async {
    if (_connectedDevice != null) {
      await _connectedDevice!.connect();
      // Do something after connecting
    } else {
      print('No device found.');
    }
  }

  Future<void> _sendLedStatus(int status) async {
    final url = Uri.parse(
        'https://party-pieper-224a2-default-rtdb.firebaseio.com/LED_STATUS.json');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'LED_STATUS': status,
        }),
      );

      if (response.statusCode == 200) {
        print('Request successful');
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error occurred: $error');
    }
  }

  void _toggleLed() {
    setState(() {
      _isLedOn = !_isLedOn;
    });
    _sendLedStatus(_isLedOn ? 0 : 1);
  }

  @override
  void initState() {
    super.initState();
    _initBluetooth();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _toggleLed,
              child: Text(_isLedOn ? 'Off' : 'On'),
            ),
            if (_connectedDevice == null)
              Text('No device connected')
            else
              Text('Connected device: ${_connectedDevice!.name}'),
            ElevatedButton(
              onPressed: _enableBluetoothAndScan,
              child: Text('Enable Bluetooth and Scan'),
            ),
          ],
        ),
      ),
    );
  }
}

class BluetoothDevicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Devices'),
      ),
      body: Center(
        child: Text('List of available Bluetooth devices will be shown here'),
      ),
    );
  }
}
