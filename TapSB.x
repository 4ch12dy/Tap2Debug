// Copyright (c) 2019-2020 Lars Fröder

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
	if([keyPath isEqualToString:@"info.choicy_hasHiddenTag"])
	{
		return [[self _appInfo] valueForKey:@"choicy_hasHiddenTag"];
	}

	return %orig;
}

%end
%end


// %hook FBProcessManager

// %new
// - (void)handleSafeModeForExecutionContext:(FBProcessExecutionContext*)executionContext withApplicationID:(NSString*)applicationID
// {

// 	NSMutableDictionary* environmentM = [executionContext.environment mutableCopy];
// 	[environmentM setObject:@(1) forKey:@"_MSSafeMode"];
// 	[environmentM setObject:@(1) forKey:@"_SafeMode"];
// 	executionContext.environment = [environmentM copy];
// }

// %group SafeMode_iOS13Up

// - (id)_createProcessWithExecutionContext:(FBProcessExecutionContext*)executionContext
// {
// 	[self handleSafeModeForExecutionContext:executionContext withApplicationID:executionContext.identity.embeddedApplicationIdentifier];

// 	return %orig;
// }

// %end

// %group SafeMode_iOS12Down

// - (id)createApplicationProcessForBundleID:(NSString*)bundleID withExecutionContext:(FBProcessExecutionContext*)executionContext
// {
// 	[self handleSafeModeForExecutionContext:executionContext withApplicationID:bundleID];

// 	return %orig;
// }

// %end

// %end

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
	XLOG("bundleID:%@ view:%@", bundleID, iconView);
	GCD_AFTER_MAIN(0.01)
		show_debug_view([iconView findViewController], bundleID);
	GCD_END
	// %orig;
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

	// %orig;
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