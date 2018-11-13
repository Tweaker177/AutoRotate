#define PLIST_PATH                                                             \
@"/var/mobile/Library/Preferences/com.i0stweak3r.autorotate.plist"

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static bool kEnabled = YES;
static bool kiPadCapable= YES; 
static bool kKey1 = YES; 
//Lockscreen rotation 

static bool kKey2 = YES; 
//landscape rotation style
static bool kKey3 = YES;
//iPhone rotation style 
static bool kKey31 = YES;
//iOS 10 CC always shifted

static bool kWantsDragging = YES;
//Can rotate while dragging icons


//One main method for iPad landscape style
%hook SBPlatformController
-(long long)medusaCapabilities {
if((kEnabled) &&(kiPadCapable)) {
	return 1;
}
return %orig;
}
%end

/**
not used, for more possible split screen uses, iPad features 

%hook UIApplication
-(bool)SKUI_isMedusaActive {
if((kEnabled"))&& (kWantsMedusa)) {
	return 1;
}
return %orig;
}
%end

%hook SBMainWorkspace
-(BOOL)isMedusaEnabled {
if((kEnabled")&& (kWantsMedusa)) {
	return TRUE;
}
return %orig;
}
%end
**/

/*This is main method that rotates apps and makes them more like iPad, but crashes some. Need to use an AppList for this for final updated release. */

%hook SBApplication
-(BOOL)isMedusaCapable {
if((kEnabled)&&(kiPadCapable)) {
	return YES;
}
return %orig;
}
%end


%hook SpringBoard
-(bool) homeScreenSupportsRotation {
if((kEnabled) && (kKey2)) {
return YES;
}
return %orig;
}
%end

//iOS 11.0+ only method

%hook SBHomeScreenViewController
-(bool)homeScreenAutorotatesEvenWhenIconIsDragging {
if((kEnabled) && (kWantsDragging)) {
return TRUE;
}
return %orig;
}
-(void)setHomeScreenAutorotatesEvenWhenIconIsDragging:(bool)arg1 {
if((kEnabled) && (kWantsDragging)) {
arg1= TRUE;
return %orig(arg1);
}
return %orig;
}
%end

//Lockscreen rotation

%hook SBDashBoardViewController
-(bool) shouldAutorotate {
if((kEnabled) && (kKey1)) {
return TRUE;
}
return %orig;
}
%end


%hook SBMedusaSettings
-(bool)anyRotationDebuggingEnabled {
if(kEnabled) {
return TRUE;
}
return %orig;
}
%end


%hook UIApplicationRotationFollowingWindow
-(bool)isInterfaceAutorotationDisabled {
if(kEnabled) {
return FALSE;
}
return %orig;
}

%end


%hook UIApplicationRotationFollowingController
-(bool) shouldAutorotate {
if(kEnabled) {
return TRUE;
}
return %orig;
}

-(bool) shouldAutorotateToInterfaceOrientation:(long long)arg1 {
if((kEnabled) && (kKey2)) {
return TRUE;
%orig;
}
return %orig;
}

-(void) setSizesWindowToScene:(bool)arg1 {
if((kEnabled) && (kKey2)) {
arg1= TRUE;
return %orig(arg1);
}
return %orig;
}
%end

%hook UIClientRotationContext
-(void) setupRotationOrderingKeyboardInAfterRotation:(bool)arg1 {
if((kEnabled) && (kKey2)) {
arg1= TRUE;
return %orig(arg1);
}
return %orig;
}
/* not sure if this method is needed but seems to work ok with landscape */
%end



%hook SpringBoard
-(long long) homeScreenRotationStyle {
if((kEnabled) && (kKey2)) {
return 1; 
//iPad rotation style

}
else if(kEnabled) {
return 2;
/* Normal iOS 11 rotation style verticle dock
should probably remove kKey31 so it's automatic if enabled */

}
else {
return %orig;
}
}
%end

/* supports upside down CC ios 10, this isn't updated for iOS 11 yet */

%hook CCUIControlCenterPageContainerViewController
-(long long) layoutStyle {
if((kKey31) && (kEnabled)) {
return 1;
}

return %orig;
}
%end

static void
loadPrefs() {
    static NSUserDefaults *prefs = [[NSUserDefaults alloc]
                                    initWithSuiteName:@"com.i0stweak3r.autorotate"];
    
    kEnabled = [prefs boolForKey:@"enabled"];

kKey1 = [prefs boolForKey:@"key1"];

kKey2 = [prefs boolForKey:@"key2"];

kKey3 = [prefs boolForKey:@"key3"];
    
kKey31 = [prefs boolForKey:@"key31"];
    
kiPadCapable = [prefs boolForKey:@"iPadCapable"];

kWantsDragging = [prefs boolForKey:@"wantsDragging"];
}

%ctor {
    CFNotificationCenterAddObserver(
                                    CFNotificationCenterGetDarwinNotifyCenter(), NULL,
                                    (CFNotificationCallback)loadPrefs,
                                    CFSTR("com.i0stweak3r.autorotate/saved"), NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
}
