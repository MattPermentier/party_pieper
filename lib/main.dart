import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const MyHomePage(title: 'LED Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({required this.title, Key? key}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLedOn = false;
  String? _accessToken;
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    try {
      final initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleIncomingLinks(initialUri);
      }
    } on FormatException catch (e) {
      print('Error parsing initial URI: $e');
    }

    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleIncomingLinks(uri);
      }
    }, onError: (Object err) {
      print('Error receiving URI: $err');
    });
  }

  void _handleIncomingLinks(Uri uri) {
    final token = uri.fragment.split('&').firstWhere((element) => element.startsWith('access_token')).split('=')[1];
    setState(() {
      _accessToken = token;
    });
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

  Future<void> _authenticateWithSpotify() async {
    const clientId = 'a15c0b0bee0b483f9f2452f427cbf8e0';
    const redirectUri = 'myapp://auth';
    const scopes = 'user-read-private user-read-email';

    final authUrl = Uri.https('accounts.spotify.com', '/authorize', {
      'response_type': 'token',
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'scope': scopes,
    });

    try {
      final result = await FlutterWebAuth.authenticate(
        url: authUrl.toString(),
        callbackUrlScheme: 'myapp',
      );

      print('Authentication result: $result');

      final token = Uri.parse(result).fragment.split('&').firstWhere((element) => element.startsWith('access_token')).split('=')[1];
      setState(() {
        _accessToken = token;
      });

      print('Access token: $_accessToken');
    } catch (e) {
      print('Error during Spotify authentication: $e');
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _authenticateWithSpotify,
              child: Text(_accessToken == null ? 'Login with Spotify' : 'Logged in'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
