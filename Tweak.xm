#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

static bool kEnabled = YES;
static bool kiPadCapable= YES; 
static bool kWantsLockscreenRotation = YES;
//Lockscreen rotation  

static bool kWantsIpadStyle = YES; 
//landscape iPad rotation style

/*
static bool kKey3 = YES;
//iPhone plus rotation style 
Changed settings so kKey3 basically does nothing now, since as long as tweak is enabled iPhone plus style rotation is set to be the default style.  Originally it was a switch that needed to be oh.
*/

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


//iOS 11.0+ only method

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
return 2;
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

//This method hides the labels by setting scale to zero
%hook SBIconLabelImageParametersBuilder
- (double)_scale {
    if(kEnabled && kHideLabels) {
        return 0;
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
    return 12; //Allows up to 12 icons or folder icons in the dock at once.
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

//kKey3 = [prefs boolForKey:@"key3"];
 //no longer used
   
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
}
