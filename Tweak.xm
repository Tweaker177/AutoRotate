#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
/*
#import <IconSupport/ISIconSupport.h>
#include <dlfcn.h> //needed for dlopen (for IconSupport)
//Was going to add IconSupport to register extra icons in Dock but not sure if it's supporting more then 4 for A12 devices
//Decided to leave out
*/

static bool kEnabled = YES;
static bool kiPadCapable= YES; 
static bool kWantsLockscreenRotation = YES;
//Lockscreen rotation  

static bool kWantsIpadStyle = YES; 
//landscape iPad rotation style
//iPhone style is enabed by default unless iPad style is picked

static bool kCCisAlwaysRotated = YES;
//iOS 10 CC always shifted

static bool kWantsDragging = YES;
//Can rotate while dragging icons

static bool kHideLabels;
//this method was part of @SbhnKhrmn 's fix
//Found it wasn't necessary though so just added it as a new setting


/*This is one of the main methods that rotates apps and makes them more like iPad, but it  crashes some. Might need to use an AppList for this at some point.  */

%hook SBApplication
-(BOOL)isMedusaCapable {
if((kEnabled)&&(kiPadCapable)) {
	return YES;
}
return %orig;
}
%end


//iOS 11.0-12.4.3 only method

%hook SBHomeScreenViewController
-(bool)homeScreenAutorotatesEvenWhenIconIsDragging {
if(kEnabled && kWantsDragging) {
return TRUE;
}
return %orig;
}
-(void)setHomeScreenAutorotatesEvenWhenIconIsDragging:(bool)arg1 {
if(kEnabled && kWantsDragging) {
arg1= TRUE;
return %orig(arg1);
}
return %orig;
}
%end

//Lockscreen rotation

%hook SBDashBoardViewController
-(bool) shouldAutorotate {
if(kEnabled && kWantsLockscreenRotation) {
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


/* 
Normal iOS 11 plus style rotation with verticle dock is automatically picked if enabled is on. iPad style is picked if stacked, iPad style rotation key is on.
*/

%hook SpringBoard
-(long long) homeScreenRotationStyle {
if((kEnabled) && (kWantsIpadStyle)) {
return 1; 
//iPad rotation style
}
else if(kEnabled) {
return 2;   //iphone plus style rotation
}
else {
return %orig;
}
}
%end

/* sideways CC for ios 10, this isn't updated for iOS 11+ yet */

%hook CCUIControlCenterPageContainerViewController
-(long long) layoutStyle {
if((kCCisAlwaysRotated) && (kEnabled)) {
return 1;
}
return %orig;
}
%end

%hook SBIconListView
-(long long)orientation {
    if(kEnabled && kWantsIpadStyle) {
        return 1;
    }
    return %orig;
}
%end


 %hook SBRootIconListView
-(double)topIconInset {
    if(kEnabled && kWantsIpadStyle) {
        return 0.0009;
    }
    return %orig;
}

- (double)bottomIconInset {
    if(kEnabled && kWantsIpadStyle) {
        return 0.0009;
    }
    return %orig;
}
%end

//This method hid the labels by setting scale to zero, worked in some cases and firmwares.

%hook SBIconLabelImageParametersBuilder
- (double)_scale {
    if(kEnabled && kHideLabels) {
        return 0;
}
return %orig;
}
%end

/*
Note: 12-18-2019 Discovered not working on iOS 12.4 iPhone X. May be a tweak conflict, idk, but a better way to hidew icons
is to use SBIconView's LabelAccessoryViewHidden, and / or setting alpha to zero, Works great in combo without respring.
*/


%hook SBIconView
-(void) setLabelAccessoryViewHidden:(bool)arg1 {
if(kEnabled && kHideLabels) {           //sets hidden property for the view
arg1= YES;
return %orig(arg1);
}
return %orig;
} 

-(void) setIconLabelAlpha:(double)arg1 {
if(kEnabled && kHideLabels) {
arg1= 0;                              //hide labels by making transparent or zero alpha
return %orig(arg1);
}
return %orig;
}
%end
  
    %hook UIDevice
- (void)setOrientation:(long long)arg1 animated:(bool)arg2 {
    if(kEnabled && kWantsIpadStyle) {
        arg2 = 1;
        return %orig(arg1, arg2);
    }
    return %orig;
}
%end

%hook SBMainSwitcherViewController
- (bool)shouldAutorotate {
if(kEnabled) {
    return 1;
} 
return %orig;
}
%end




%hook SBRootFolderController
- (bool)_shouldSlideDockOutDuringRotationFromOrientation:(long long)arg1 toOrientation:(long long)arg2 {
if(kEnabled) {
    arg1 = 2;
    return YES;
     %orig;
} 
return %orig;
}
%end


%hook SBDockIconListView
+ (unsigned long long)maxIcons {
if(kEnabled) {
    return 12; 
    //Allows up to 12 icons or folder icons in the dock at once.
    //Works up to iOS 12.4.3
    //Resets back to 4 after reboot or safe mode, was going to use IconSupport for fix but changed mind
} 
return %orig;
}


- (bool)allowsAddingIconCount:(unsigned long long)arg1 {
if(kEnabled) {
    return 1;
%orig;
} 
return %orig;
}

%end

//handle prefs with user defaults

static void
loadPrefs() {
    static NSUserDefaults *prefs = [[NSUserDefaults alloc]
                                    initWithSuiteName:@"com.i0stweak3r.autorotate"];
    
    kEnabled = [prefs boolForKey:@"enabled"];
    
    kHideLabels = [prefs boolForKey:@"hideLabels"];

kWantsLockscreenRotation = [prefs boolForKey:@"key1"];

kWantsIpadStyle = [prefs boolForKey:@"key2"];
//iPadStyleRotation
   
kCCisAlwaysRotated = [prefs boolForKey:@"key31"];
    //iOS 10 only so far.

kiPadCapable = [prefs boolForKey:@"iPadCapable"];
//Beta method for rotating more apps and having more "medusa" capabilities.

kWantsDragging = [prefs boolForKey:@"wantsDragging"];
// Allows rotation while in icon editing mode
}

%ctor {
    CFNotificationCenterAddObserver(
                                    CFNotificationCenterGetDarwinNotifyCenter(), NULL,
                                    (CFNotificationCallback)loadPrefs,
                                    CFSTR("com.i0stweak3r.autorotate/saved"), NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
    
/* 
Skipping IconSupport for now
    // Register with IconSupport.
	void *h = dlopen("/Library/MobileSubstrate/DynamicLibraries/IconSupport.dylib", RTLD_NOW);
	if (h) {
		[[objc_getClass("ISIconSupport") sharedInstance] addExtension:@"AutoRotate"];
	}
*/	
}
