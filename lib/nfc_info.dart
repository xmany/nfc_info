import 'dart:async';
import 'package:flutter/services.dart';

class NfcInfo {
  static const MethodChannel _channel = const MethodChannel('nfc_info');
  static const EventChannel _eChannel = EventChannel('nfc_info_events');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  /// Returns a [Future], which completes to one of the following:
  ///
  ///   * the initially stored text (possibly null), on successful invocation;
  ///   * a [PlatformException], if the invocation failed in the platform plugin.
  static Future<String> getInitialText() async {
    final String text = await _channel.invokeMethod('getInitialText');
    return text;
  }

  /// Call this method if you already consumed the callback
  /// and don't want the same callback again
  static Future<void> reset() async {
    await _channel.invokeMethod('reset');
  }

  static Stream<String> _stream;
  static Stream<String> getTextsStream() =>
      _stream ??= _eChannel.receiveBroadcastStream().cast<String>();
}
