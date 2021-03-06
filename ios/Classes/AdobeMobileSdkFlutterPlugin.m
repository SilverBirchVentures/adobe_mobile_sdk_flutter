#import "AdobeMobileSdkFlutterPlugin.h"
#import "ADBMobile.h"

@implementation AdobeMobileSdkFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"adobe_analytics_plugin"
            binaryMessenger:[registrar messenger]];
  AdobeMobileSdkFlutterPlugin* instance = [[AdobeMobileSdkFlutterPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  NSDictionary *arguments = call.arguments;

  if ([@"collectLifecycleData" isEqualToString:call.method]) {
    [self collectLifecycle:call result:result];
  }
  else if ([@"trackAction" isEqualToString:call.method]) {
    [self trackAction:call result:result args:arguments];
  }
  else if ([@"trackState" isEqualToString:call.method]) {
    [self trackState:call result:result args:arguments];
  }
  else if ([@"trackCrash" isEqualToString:call.method]) {
    [self trackCrash:call result:result args:arguments];
  }
  else if ([@"visitorAppendToURL" isEqualToString:call.method]) {
    [self visitorAppendToURL:call result:result args:arguments];
  }
  else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)collectLifecycle:(FlutterMethodCall*)call result:(FlutterResult)result {
  [ADBMobile collectLifecycleData];
  result([NSString stringWithFormat:@"collectLifecycle called"]);
}

- (void)trackAction:(FlutterMethodCall*)call result:(FlutterResult)result args:(NSDictionary*)args {
  NSString *actionName = [args objectForKey:@"actionName"];
  if(actionName != nil ){
    NSDictionary *additionalData = [args objectForKey:@"additionalData"];
    [self sendTrack:actionName additionalData:additionalData isState:false];
    result([NSString stringWithFormat:@"trackAction [%@]", actionName]);
  }else{
    result([FlutterError errorWithCode:@"[ trackAction ERROR ] :: actionName is required" message: @"actionName is required" details: nil]);
  }
}

- (void)trackState:(FlutterMethodCall*)call result:(FlutterResult)result args:(NSDictionary*)args {
  NSString *screenName = [args objectForKey:@"screenName"];
  if(screenName != nil ){
    NSDictionary *additionalData = [args objectForKey:@"additionalData"];
    [self sendTrack:screenName additionalData:additionalData isState:true];
    result([NSString stringWithFormat:@"screenName [%@]", screenName]);
  }else{
    result([FlutterError errorWithCode:@"[ trackState ERROR ] :: screenName is required" message: @"screenName is required" details: nil]);
  }
}

- (void)sendTrack:(NSString*)name additionalData:(NSDictionary*)additionalData isState:(bool)isState {

  NSMutableDictionary *contextData = nil;

  if([additionalData count] > 0){
      contextData = [NSMutableDictionary dictionary];
      for (NSString *key in additionalData) {
          NSString *value = additionalData[key];
          [contextData setObject:value forKey:key];
      }
  }

  if(isState){
    [ADBMobile trackState:name data:contextData];
  }else{
    [ADBMobile trackAction:name data:contextData];
  }
}

- (void)visitorAppendToURL:(FlutterMethodCall*)call result:(FlutterResult)result args:(NSDictionary*)args {
  NSString *urlString = [args objectForKey:@"url"];
  if (urlString != nil) {
    NSURL *url = [NSURL URLWithString:urlString]; 
    NSURL *urlWithVisitorData = [ADBMobile visitorAppendToURL:url]; 
    result([urlWithVisitorData absoluteString]);
  } else{
    result([FlutterError errorWithCode:@"[ visitorAppendToUrl ERROR ] :: url is required" message: @"url is required" details: nil]);
  }
}

- (void)trackCrash:(FlutterMethodCall*)call result:(FlutterResult)result args:(NSDictionary*)args {
  result([NSString stringWithFormat:@"TrackCrash is not implemented"]);
}

@end
