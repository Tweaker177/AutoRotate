#define PLIST_PATH @"/var/mobile/Library/Preferences/com.i0stweak3r.autorotate.plist"

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>
 
inline bool GetPrefBool(NSString *key) {
return [[[NSDictionary dictionaryWithContentsOfFile:PLIST_PATH] valueForKey:key] boolValue];
}

/**
NOTE: this tweak was made in very short time. I didn't bother setting user defaults, using 
callbacks, and read directly from settings plist file.  This project was a "quickie tweak" that was way
more popular then I expected, hence the need to update for iOS 11 quirks, and maybe do settings the
proper way with defaults and post notifications.  Kind of embrarassed sharing this code but am 
limited in time, and would love anyone wishing to collab. Will credit you in pref bundle.

UPDATE: This is version currently in BigBoss. UPDATED this GitHub so now when compiled will reflect the current version
in my beta repo. It's come alomg nicely, just need iPHONE X testers and to add AppList for one method. CURRENT tweak file is now 
AutoRotate.xm  TWEAK now rotates all apps, some crash tho hence need for Applist if medusaCapable is selected.
**/

%hook SBDashBoardViewController

// Lockscreen autorotate if enabled and LS (key1) is selected.

-(bool) shouldAutorotate {
if((GetPrefBool(@"enabled"))&& (GetPrefBool(@"key1"))) {
%orig;
return TRUE;

}
return %orig;
}
%end


%hook SBMedusaSettings
//Necessary to rotate and not crash SB
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
//IF stacked rotation (key2) and enabled choose stacked style
if((GetPrefBool(@"enabled")) 
&& (GetPrefBool(@"key2"))) {
%orig;
return 1;
}
//Else if iOS 11 style rotation rotate that way
else if((GetPrefBool(@"enabled")) 
&& (GetPrefBool(@"key3"))) {
%orig;
return 2;
}
//Else obviously do nothing
else {
return %orig;
}
}
%end

%hook CCUIControlCenterPageContainerViewController
-(long long) layoutStyle {
if(GetPrefBool(@"key31")) {
//CC shifted layout for iOS 10, does nothing in 11
%orig;
return 1;
}

return %orig;
}
%end
