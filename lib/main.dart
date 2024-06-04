import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLedOn = false;

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _toggleLed,
          child: Text(_isLedOn ? 'Off' : 'On'),
        ),
      ),
    );
  }
}
