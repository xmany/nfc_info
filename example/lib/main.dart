import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:nfc_info/nfc_info.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  String _platformVersion = 'Unknown';
  String _initialNfc = "";
  String _latestNfc = "";
  StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initPlatformState();
    getInitialNfcInfo();
    listenToNfcStream();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_sub != null) _sub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app resumed");
        // getNfcInfo();
        break;
      default:
        break;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await NfcInfo.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> getInitialNfcInfo() async {
    String nfc = "";
    try {
      nfc = await NfcInfo.getInitialText();
    } on PlatformException {
      print("getInitialNfcInfo: error getInitialText()");
    }
    print('getInitialNfcInfo: $nfc');
    if (!mounted) return;
    setState(() {
      _initialNfc = nfc;
    });
    // ��icoffee://www.icoffee.app/shops/123
    if (nfc != null && nfc.isNotEmpty) {
      /// TODO if we got nfc, need to clear
      /// so that next time the app goes from background to foreground
      /// the app will not process the same old NFC payload all over again.
      // await NfcInfo.reset();
    }
  }

  void listenToNfcStream() {
    _sub = NfcInfo.getTextsStream().listen((String nfc) {
      if (!mounted) return;
      print("nfc from stream: $nfc");
      setState(() {
        _latestNfc = nfc;
      });
    }, onError: (Object err) {
      if (!mounted) return;
      print(err.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NFC INFO'),
        ),
        body: Column(
          children: [
            Text('Running on: $_platformVersion\n'),
            Text('Got nfc: $_initialNfc'),
            Text('nfc stream: $_latestNfc'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.nfc),
          onPressed: getInitialNfcInfo,
        ),
      ),
    );
  }
}
