#import "SpringBoard.h"
#import "xia0.h"
#import "common.h"
#import <objc/runtime.h>

NSString* toggleOneTimeApplicationID;
#ifndef kCFCoreFoundationVersionNumber_iOS_11_0
#define kCFCoreFoundationVersionNumber_iOS_11_0 1443.00
#endif

#ifndef kCFCoreFoundationVersionNumber_iOS_13_0
#define kCFCoreFoundationVersionNumber_iOS_13_0 1665.15
#endif

%group iOS10Down
%hook SBApplication

- (id)valueForKeyPath:(NSString*)keyPath
{
	if([keyPath isEqualToString:@"info.xia0_hasHiddenTag"])
	{
		return [[self _appInfo] valueForKey:@"xia0_hasHiddenTag"];
	}

	return %orig;
}

%end
%end

%group Shortcut_iOS13Up

%hook SBIconView

- (NSArray *)applicationShortcutItems
{
	NSArray* orig = %orig;

	NSString* applicationID;
	if([self respondsToSelector:@selector(applicationBundleIdentifier)])
	{
		applicationID = [self applicationBundleIdentifier];
	}
	else if([self respondsToSelector:@selector(applicationBundleIdentifierForShortcuts)])
	{
		applicationID = [self applicationBundleIdentifierForShortcuts];
	}

	if(!applicationID)
	{
		return orig;
	}


	SBSApplicationShortcutItem* toggleSafeModeOnceItem = [[%c(SBSApplicationShortcutItem) alloc] init];

	toggleSafeModeOnceItem.localizedTitle = @"Tap2Debug";

	
	//toggleSafeModeOnceItem.icon = [[%c(SBSApplicationShortcutSystemItem) alloc] initWithSystemImageName:@"fx"];
	toggleSafeModeOnceItem.bundleIdentifierToLaunch = applicationID;
	toggleSafeModeOnceItem.type = @"com.xia0.tap2debug";

	return [orig arrayByAddingObject:toggleSafeModeOnceItem];

	return orig;
}

+ (void)activateShortcut:(SBSApplicationShortcutItem*)item withBundleIdentifier:(NSString*)bundleID forIconView:(id)iconView
{
	if(![item.type isEqualToString:@"com.xia0.tap2debug"]){
		return %orig;
	}

	XLOG("bundleID:%@ view:%@", bundleID, iconView);
	GCD_AFTER_MAIN(0.01)
		show_debug_view([iconView findViewController], bundleID);
	GCD_END
}

%end

%end

%group Shortcut_iOS12Down

%hook SBUIAppIconForceTouchControllerDataProvider

- (NSArray *)applicationShortcutItems
{
	NSArray* orig = %orig;

	NSString* applicationID = [self applicationBundleIdentifier];

	if(!applicationID)
	{
		return orig;
	}


    SBSApplicationShortcutItem* toggleSafeModeOnceItem = [[%c(SBSApplicationShortcutItem) alloc] init];

    toggleSafeModeOnceItem.localizedTitle = @"Tap2Debug";

    //toggleSafeModeOnceItem.icon = [[%c(SBSApplicationShortcutSystemItem) alloc] init];
    toggleSafeModeOnceItem.bundleIdentifierToLaunch = applicationID;
    toggleSafeModeOnceItem.type = @"com.xia0.tap2debug";

    if(!orig)
    {
        return @[toggleSafeModeOnceItem];
    }
    else
    {
        return [orig arrayByAddingObject:toggleSafeModeOnceItem];
    }

	return orig;
}

%end

%hook SBUIAppIconForceTouchController

- (void)appIconForceTouchShortcutViewController:(id)arg1 activateApplicationShortcutItem:(SBSApplicationShortcutItem*)item
{
	if(![item.type isEqualToString:@"com.xia0.tap2debug"]){
		return %orig;
	}
	
	NSString* bundleID = item.bundleIdentifierToLaunch;
	// Ivar ivar = object_getInstanceVariable(object_getClass(self.delegate), "_rootFolderController", NULL);
	// id rootFolderController = (__bridge id)((__bridge void *)self.delegate + ivar_getOffset(ivar));
	// id rootFolderController = MSHookIvar<id>(self.delegate, "_rootFolderController");
	SBIconController* sbivc = self.delegate;
	id rootFolderController = sbivc._rootFolderController;
	XLOG(@"tap on app:%@ vc:%@ rootFolderController:%@", bundleID, arg1, rootFolderController);
	[self dismissAnimated:YES withCompletionHandler:^{
		GCD_AFTER_MAIN(0.01)
			show_debug_view(rootFolderController, bundleID);
		GCD_END
	}];
}

%end

%end

%ctor
{
	%init();
	if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_13_0)
	{
		// %init(SafeMode_iOS13Up);
		%init(Shortcut_iOS13Up);
	}
	else
	{
		// %init(SafeMode_iOS12Down);
		%init(Shortcut_iOS12Down);
	}

	if(kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_11_0)
	{
		%init(iOS10Down);
	}
}