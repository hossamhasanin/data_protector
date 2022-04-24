#import "WifiP2pPlugin.h"
#if __has_include(<wifi_p2p/wifi_p2p-Swift.h>)
#import <wifi_p2p/wifi_p2p-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "wifi_p2p-Swift.h"
#endif

@implementation WifiP2pPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftWifiP2pPlugin registerWithRegistrar:registrar];
}
@end
