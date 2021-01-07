package app.icoffee.nfc_info;

import android.app.Activity;
import android.content.Intent;
import android.nfc.NdefMessage;
import android.nfc.NfcAdapter;
import android.os.Parcelable;
import android.util.Log;

import androidx.annotation.NonNull;

import io.flutter.embedding.android.FlutterView;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.NewIntentListener;

/** NfcInfoPlugin */
public class NfcInfoPlugin implements FlutterPlugin, MethodCallHandler, NewIntentListener, ActivityAware {
  private static final String TAG = "NfcInfoPlugin";

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static final String channelName = "NfcInfo";

  private String initialText = null;

  /// not necessary for background nfc starts app scenario?
  private ActivityPluginBinding binding = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "nfc_info");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    Log.d(TAG, "onMethodCall: method: "+call.method+", initialText: "+initialText);
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("getInitialText")) {
      try {
        result.success(initialText);
      } catch (Exception ex) {
        result.error("1", ex.getMessage(), ex.getStackTrace());
      }
    } else if (call.method.equals("reset")) {
      initialText = null;
      result.success(null);
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }


  @Override
  public boolean onNewIntent(Intent intent) {
    Log.d(TAG, "onNewIntent: incoming intent");
    handleIntent(intent);
    return false;
  }

  private void handleIntent(Intent intent) {
    if (NfcAdapter.ACTION_NDEF_DISCOVERED.equals(intent.getAction())) {
      Parcelable[] rawMessages =
              intent.getParcelableArrayExtra(NfcAdapter.EXTRA_NDEF_MESSAGES);
      if (rawMessages != null) {
        NdefMessage[] messages = new NdefMessage[rawMessages.length];
        for (int i = 0; i < rawMessages.length; i++) {
          messages[i] = (NdefMessage) rawMessages[i];
        }
        // Process the messages array.
        // TODO need to process the array instead of just first element
        initialText = new String(messages[0].getRecords()[0].getPayload());
        Log.i(TAG, "handleIntent: first payload: "+initialText+", message length: "+messages.length+", records length: "+messages[0].getRecords().length);
      } else {
        Log.w(TAG, "handleIntent: null rawMessages");
      }
    }
  }
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    this.binding = binding;
    binding.addOnNewIntentListener(this);
    Log.d(TAG, "onAttachedToActivity: incoming activity");
    handleIntent(binding.getActivity().getIntent());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    if(binding != null) {
      binding.removeOnNewIntentListener(this);
    }
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    this.binding = binding;
    binding.addOnNewIntentListener(this);
  }

  @Override
  public void onDetachedFromActivity() {
    if(binding != null) {
      binding.removeOnNewIntentListener(this);
    }
  }
}
