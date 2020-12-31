#import "NfcInfoPlugin.h"
#if __has_include(<nfc_info/nfc_info-Swift.h>)
#import <nfc_info/nfc_info-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "nfc_info-Swift.h"
#endif

@implementation NfcInfoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftNfcInfoPlugin registerWithRegistrar:registrar];
}
@end
