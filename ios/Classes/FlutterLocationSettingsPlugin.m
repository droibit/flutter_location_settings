#import "FlutterLocationSettingsPlugin.h"
#import <flutter_location_settings/flutter_location_settings-Swift.h>

@implementation FlutterLocationSettingsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterLocationSettingsPlugin registerWithRegistrar:registrar];
}
@end
