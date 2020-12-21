#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>


const CGFloat firmware =  [[UIDevice currentDevice].systemVersion floatValue];

static bool kEnabled = YES;
static bool kiPadCapable = YES;
//This rotates most apps. May cause issues in some apps on some devices (beta feature)

static bool kWantsDeviceIdiom1;
// fake device into thinking it's iPad (beta feature)

static bool kWantsLockscreenRotation = YES;
//Lockscreen rotation  

static bool kWantsIpadStyle = YES; 
//landscape iPad rotation style

static bool kIphoneStyleRotation = YES;
//iPhone plus rotation style

static bool kCCisAlwaysRotated = YES;
//iOS 10 CC always shifted

static bool kWantsDragging = YES;
//Can rotate while dragging icons

static bool kHideLabels;
static bool twoRowTweakInstalled;  //currently only checking for Docky

static bool kWantsCustomDock;   //Wants 12 icon dock (iOS 10-12.4.x only) FolderControllerXII and FCXIII both have custom number of icons in dock.


/*This is one of the main methods that rotates apps and makes them more like iPad, but it incorrectly splits or crashes some on compact devices and iPhoneX. Might need to use an AppList for this at some point.  */

%hook SBApplication
-(BOOL)isMedusaCapable {
if(kEnabled && kiPadCapable) {
	return YES;
}
return %orig;
}
%end


//iOS 11.0-12.4.x only method

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
Normal iOS 11 plus style rotation with verticle dock is automatically picked if enabled is on. iPad style is picked if stacked is on.
*/

%hook SpringBoard
-(long long) homeScreenRotationStyle {
if(kEnabled && kWantsIpadStyle) {
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




 %hook SBRootIconListView
-(double)topIconInset {
    if(kEnabled && kWantsIpadStyle) {
return twoRowTweakInstalled ? 20.f : 0.0009f;
//if two row tweak(Docky) is installed return 20.f else return 0.0009f
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

%hook SBIconListView
-(long long)orientation {
    if(kEnabled && kWantsIpadStyle) {
        return 1;
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

%hook SBIconView
-(void) setLabelAccessoryViewHidden:(bool)arg1 {  //Hides the cloud for offloaded apps, new-install dots...looks cleaner  
    if(kEnabled && kHideLabels) {           
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
     if(kEnabled && kWantsIpadStyle) {
    arg1 = 2;
    return YES;
    %orig;
}
return %orig;
}
%end

%group iOS13UP

%hook SBRootFolderDockIconListView
+(NSInteger)rotationAnchor {
    if(kEnabled) {
        return 0;
    }
    return %orig;
}

%end


%hook SBDockIconListView
+(NSInteger)rotationAnchor {
    if(kEnabled) {
        return 0;
    }
    return %orig;
}
%end

%hook SBRootFolderController
-(BOOL)isDockPinnedForRotation {
    if(kEnabled && kWantsIpadStyle) {
        return 0;
    }
    else if(kEnabled) {
        return 1;
    }
    else {
        return %orig;
    }
}
%end

%end  //end of group iOS13UP



// sideways CC for ios 10, this isn't updated for iOS 11+ yet 


%hook CCUIControlCenterPageContainerViewController
-(long long) layoutStyle {
    if(kCCisAlwaysRotated && kEnabled) {
        return 1;
    }
    return %orig;
}
%end

// 12 icon dock for iOS 10-12.4.x

%hook SBDockIconListView
+ (unsigned long long)maxIcons {
    if(!kEnabled || !kWantsCustomDock) {
        return %orig;
    }
 else if(kEnabled && kWantsCustomDock && (firmware <13.0)) {
    return 13; //Allows up to 12 icons or folder icons in the dock at once.
} 
 else {
     return %orig;
 }
}

- (bool)allowsAddingIconCount:(unsigned long long)count {
    if(kEnabled && kWantsCustomDock && (firmware < 13.0) && (count < 13)) {
    return 1;
%orig;
} 
return %orig;
}

%end

//Just added last update

 %hook UIClientRotationContext
       -(void)setupRotationOrderingKeyboardInAfterRotation:(bool)arg1 {
           if(kEnabled) { 
               arg1= YES;
               return %orig(arg1);
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
    
    kWantsCustomDock = ([prefs boolForKey:@"wantsCustomDock"] && (firmware <13.0)) ? [prefs boolForKey:@"wantsCustomDock"] : NO;
    
    kHideLabels = [prefs boolForKey:@"hideLabels"];

    kWantsLockscreenRotation = [prefs boolForKey:@"key1"];

    kWantsIpadStyle = [prefs boolForKey:@"key2"];
    //iPadStyleRotation

    kIphoneStyleRotation = [prefs boolForKey:@"key3"];
    //defaults to this style if neither stye are selected, not really needed.
   
    kCCisAlwaysRotated = [prefs boolForKey:@"key31"];
    //iOS 10 only so far.

/****. Beta methods for rotating more apps and having more "medusa" capabilities. ***/
kiPadCapable = [prefs boolForKey:@"iPadCapable"];
kWantsDeviceIdiom1 =[prefs boolForKey:@"wantsDeviceIdiom1"];

// Allows rotation while in icon editing mode on iOS 11-12.4.x. Found a similar method for 13+ just need to add it.
kWantsDragging = [prefs boolForKey:@"wantsDragging"];

}

%ctor {
    CFNotificationCenterAddObserver(
                                    CFNotificationCenterGetDarwinNotifyCenter(), NULL,
                                    (CFNotificationCallback)loadPrefs,
                                    CFSTR("com.i0stweak3r.autorotate/saved"), NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);
    loadPrefs();
    
    if([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/me.nepeta.docky.dylib"]) {
        twoRowTweakInstalled = YES;
    }
     else { twoRowTweakInstalled = NO; }
     
     %init; //ungrouped
        
	if(firmware >= 13) {
            %init(iOS13UP);
           
        }                    
     
}  //end of %ctor
    
/* 
Skipping IconSupport, not working for A12 to have more then 4 icons in dock, and I prefer IconState now anyways.
If I add iOS 13-14 custom dock support I'll use Nepeta's IconState
    // Register with IconSupport.
	void *h = dlopen("/Library/MobileSubstrate/DynamicLibraries/IconSupport.dylib", RTLD_NOW);
	if (h) {
		[[objc_getClass("ISIconSupport") sharedInstance] addExtension:@"AutoRotate"];
	}
*/	

