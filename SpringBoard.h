@interface RBSProcessIdentity : NSObject
@property(readonly, copy, nonatomic) NSString *executablePath;
@property(readonly, copy, nonatomic) NSString *embeddedApplicationIdentifier;
@end

@interface FBProcessExecutionContext : NSObject
@property (nonatomic,copy) NSDictionary* environment;
@property (nonatomic,copy) RBSProcessIdentity* identity;
@end

@interface FBProcessManager : NSObject
- (void)handleSafeModeForExecutionContext:(FBProcessExecutionContext*)executionContext withApplicationID:(NSString*)applicationID;
@end



@interface SBApplicationInfo : NSObject
@property (nonatomic,readonly) NSURL* executableURL;
@property (nonatomic,readonly) BOOL hasHiddenTag;
@property (nonatomic,retain,readonly) NSArray* tags;
@end

@interface SBApplication : NSObject
- (SBApplicationInfo*)_appInfo;
@end

@interface SBSApplicationShortcutIcon : NSObject
@end

@interface SBSApplicationShortcutSystemItem : SBSApplicationShortcutIcon
- (instancetype)initWithSystemImageName:(NSString*)systemImageName;
@end

@interface SBSApplicationShortcutItem : NSObject
@property (nonatomic,copy) NSString* type;
@property (nonatomic,copy) NSString* localizedTitle;
@property (nonatomic,copy) NSString* localizedSubtitle;
@property (nonatomic,copy) SBSApplicationShortcutIcon* icon;
@property (nonatomic,copy) NSDictionary* userInfo; 
@property (assign,nonatomic) NSUInteger activationMode;
@property (nonatomic,copy) NSString* bundleIdentifierToLaunch;
@end

@interface SBIconView : NSObject
- (NSString*)applicationBundleIdentifier;
- (NSString*)applicationBundleIdentifierForShortcuts;
@end

@interface SBUIAppIconForceTouchControllerDataProvider : NSObject
- (NSString*)applicationBundleIdentifier;
@end

@interface SBIconController : NSObject
@property (weak, nonatomic) id _rootFolderController;
@end

@interface SBUIAppIconForceTouchController : NSObject
@property (weak, nonatomic) SBIconController* delegate;
- (void) dismissAnimated:(BOOL)arg1 withCompletionHandler:(void (^)())block;
@end