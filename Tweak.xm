#define PLIST_PATH @"/var/mobile/Library/Preferences/com.i0stweak3r.autorotate.plist"

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
 
inline bool GetPrefBool(NSString *key) {
return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] boolValue];
}

%hook SBDashBoardViewController
-(bool) shouldAutorotate {
if((GetPrefBool(@"enabled"))&& (GetPrefBool(@"key1"))) {
%orig;
return TRUE;

}
return %orig;
}
%end


%hook SBMedusaSettings
-(bool)anyRotationDebuggingEnabled {
if(GetPrefBool(@"enabled")) {
%orig;
return TRUE;
}
return %orig;
}
%end

%hook SpringBoard
-(long long) homeScreenRotationStyle {
if((GetPrefBool(@"enabled")) 
&& (GetPrefBool(@"key2"))) {
%orig;
return 1;
}
else if((GetPrefBool(@"enabled")) 
&& (GetPrefBool(@"key3"))) {
%orig;
return 2;
}
else {
return %orig;
}
}
%end

%hook CCUIControlCenterPageContainerViewController
-(long long) layoutStyle {
if(GetPrefBool(@"key31")) {
%orig;
return 1;
}

return %orig;
}
%end
