#import <sys/types.h>
#import <objc/runtime.h>
#import "xia0.h"
#import "common.h"

@interface NSTask : NSObject
 
- (id)init;
- (void)setLaunchPath:(NSString *)path;
- (void)setArguments:(NSArray *)arguments;
- (void)launch; 
- (int)processIdentifier;
  
@end
 
@interface LSApplicationProxy : NSObject
+ (id) applicationProxyForIdentifier:(id)arg1;
@property (readonly, nonatomic) NSString* canonicalExecutablePath;
@end

@interface TaskManager : NSObject
+ (TaskManager*)sharedManager;
@property (nonatomic,strong) NSTask * runningTask;
@end

@implementation TaskManager
+ (TaskManager*)sharedManager {
    static TaskManager *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[self alloc] init];
    });
    return _sharedSingleton;
}
@end

@interface SBApplication : NSObject
@property(copy, nonatomic) NSArray *dynamicShortcutItems;
@property(copy, nonatomic) NSArray *staticShortcutItems;
@property(copy, nonatomic) NSString* bundleIdentifier;
- (id)badgeNumberOrString;
- (void)loadStaticShortcutItemsFromInfoDictionary:(id)arg1 bundle:(id)arg2;
- (NSString*)bundleIdentifier;
- (NSString*)displayName;
@end;

@interface SBIcon : NSObject
@property(copy, nonatomic) SBApplication* application;
- (void)launchFromLocation:(int)location;
- (BOOL)isFolderIcon;
- (id)badgeNumberOrString;
@end

@interface SBIconView : UIView

@property(nullable, nonatomic,copy) NSArray *gestureRecognizers;
@property(nonatomic,copy) NSString *applicationBundleIdentifierForShortcuts;
@property(nonatomic,copy) SBIcon *icon;
@end


void show_debug_view(UIViewController* showVC, NSString* _bundleid){
	NSString* bundle = _bundleid;
    if(!bundle){
    	XLOG(@"error bundleid is null");
    	return;
    }
	UIViewController * vc = showVC;

	NSString * debugserver = @"/iOSRE/tools/debugserver";
    NSString * ip_port = @"127.0.0.1:1234";
    NSString * last_server = [[NSUserDefaults standardUserDefaults] objectForKey:@"server_bin_path"] ;
    NSString * last_ip =[[NSUserDefaults standardUserDefaults] objectForKey:@"ip_port"] ;
    if(last_server!=nil){
        debugserver = last_server;
    }
    if(last_ip!=nil){
        ip_port = last_ip;
    }

    Class LSApplicationProxy_class = objc_getClass("LSApplicationProxy");
    NSObject* proxyObj = [LSApplicationProxy_class performSelector:@selector(applicationProxyForIdentifier:) withObject:bundle];
	NSString * canonicalExecutablePath = [proxyObj performSelector:@selector(canonicalExecutablePath)];

    UIAlertController * panel = [UIAlertController alertControllerWithTitle:@"🍎 SERVER LAUNCHER" message:canonicalExecutablePath preferredStyle:UIAlertControllerStyleAlert];
    [panel addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
		textField.userInteractionEnabled = NO;
        textField.placeholder = @"server path(not null)";
        textField.text = debugserver;
		GCD_AFTER_MAIN(0.3)
			textField.userInteractionEnabled = YES;
		GCD_END
    }];
    [panel addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"ip:port(nullable)";
        textField.text = ip_port;

    }];
    [panel addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"executable path(not null)";
        textField.text = canonicalExecutablePath;
        textField.enabled = NO;
        textField.textColor = [UIColor lightGrayColor];
    }];
    [panel addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"-x";
        textField.text = @"-x";
        textField.enabled = NO;
        textField.textColor = [UIColor lightGrayColor];
    }];
    [panel addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"backboard";
        textField.text = @"backboard";
        textField.enabled = NO;
        textField.textColor = [UIColor lightGrayColor];
    }];
    
    UIAlertAction * okaction = [UIAlertAction actionWithTitle:@"▶ START️ SERVER" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField * tf_server = panel.textFields[0];
        UITextField * tf_ip = panel.textFields[1];
        UITextField * tf_exepath = panel.textFields[2];
        UITextField * tf_x = panel.textFields[3];
        UITextField * tf_board = panel.textFields[4];

        NSString * bin_serverpath = [tf_server.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!bin_serverpath || bin_serverpath.length == 0) {
            XLOG(@"server path is null,stop");
            return ;
        }
        
        NSString * arg_ipport = [tf_ip.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!arg_ipport || arg_ipport.length == 0) {
            XLOG(@"ipport is null,continue");
        }
        
        NSString * arg_exepath = [tf_exepath.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!arg_exepath || arg_exepath.length == 0) {
            XLOG(@"exe path is null,stop");
            return ;
        }
        
        NSString * arg_x = [tf_x.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!arg_x || arg_x.length == 0) {
            XLOG(@"arg_x is null,user default -x");
            arg_x = @"-x";
        }

        NSString * arg_board = [tf_board.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!arg_board || arg_board.length == 0) {
            XLOG(@"arg_board is null,user default -x backboard");
            arg_board = @"-x backboard";
        }
        XLOG(@"launch path %@",bin_serverpath);
        XLOG(@"%@ %@ %@ %@",bin_serverpath,arg_ipport,arg_exepath,arg_board);
		NSMutableArray * args = [NSMutableArray array];
		[args addObject:arg_ipport];
		[args addObject:arg_exepath];
        [args addObject:arg_x];
        [args addObject:arg_board];
        [[NSUserDefaults standardUserDefaults] setObject:bin_serverpath forKey:@"server_bin_path"] ;
        [[NSUserDefaults standardUserDefaults] setObject:arg_ipport forKey:@"ip_port"] ;
        [[NSUserDefaults standardUserDefaults] synchronize]; 

        NSTask * task = [TaskManager sharedManager].runningTask;
        if(task){
            kill(task.processIdentifier,SIGKILL);
            task = nil;
        }
        task = [[NSTask alloc]init];
        [task setLaunchPath:bin_serverpath];
		[task setArguments:args];
    	[task launch];
        [TaskManager sharedManager].runningTask = task;
    }];
    UIAlertAction * cancelaction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        XLOG(@"cancel");
    }];
    UIAlertAction * stopAction = [UIAlertAction actionWithTitle:@"⏹ STOP SERVER" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSTask * task = [TaskManager sharedManager].runningTask;
        if(task){
            kill(task.processIdentifier,SIGKILL);
            task = nil;
        }
    }];

    [panel addAction:okaction];
    [panel addAction:stopAction];
    [panel addAction:cancelaction];
    XLOG("vc:%@", vc);
    [vc presentViewController:panel animated:YES completion:nil];
}

%hook SBIconView

%new
-(void)handleDoubleClick:(UITapGestureRecognizer*)doubleTap
{
    NSString* bid = self.icon.application.bundleIdentifier;
	XLOG(@"id:%@",bid);
    show_debug_view([self findViewController], bid);
}
%end


%hook SBIconView

- (void)didMoveToWindow
{
	%orig;
#if TROGGLE_WITH_DOUBLE_TAP
	UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleClick:)];
	[doubleTap setNumberOfTapsRequired:2];
	[self addGestureRecognizer:doubleTap];
	NSArray * ges = self.gestureRecognizers;
	for(UITapGestureRecognizer * each in ges){
		if([each isKindOfClass:[UITapGestureRecognizer class]]){
			[each requireGestureRecognizerToFail: doubleTap];
		}
	}
#endif
}

- (void)tapGestureDidChange:(id)ges
{
	XLOG(@"single click");
	%orig;
}

%end






























