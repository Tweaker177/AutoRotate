#import <spawn.h>
#import <objc/runtime.h>
#import <Preferences/Preferences.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>

@interface AutoRotateListController: PSListController 

- (void)respring:(id)sender;
-(void)twitter;
-(void)donate;
-(void)twitter2;
-(void)repolink;
-(void)link;
@end

@implementation AutoRotateListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"AutoRotate" target:self];
	}
	return _specifiers;
}
- (void)respring:(id)sender {
	pid_t pid;
    const char* args[] = {"killall", "SpringBoard", NULL};
    posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, (char* const*)args, NULL);
}



- (void)twitter {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://user?screen_name=brianvs"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=brianvs"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:///user_profile/brianvs"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/brianvs"]];
    }  else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://twitter.com/brianvs"]];
    }
}

- (void)twitter2 {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/prouser"]];
} 

- (void)donate
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://paypal.me/i0stweak3r"]];
}
- (void)repolink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://i0s-tweak3r-betas.yourepo.com"]];
} 

/* The "Visit iOSGods.com" link inside the Preferences button */
- (void)link {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://iosgods.com"]];
} 
@end

// vim:ft=objc
