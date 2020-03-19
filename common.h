#define TROGGLE_WITH_DOUBLE_TAP 0

@interface UIView(findvc)
-(UIViewController*)findViewController;
@end

@implementation UIView(find)
-(UIViewController*)findViewController
{
    UIResponder* target= self;
    while (target) {
        target = target.nextResponder;
        if ([target isKindOfClass:[UIViewController class]]) {
            break;
        }
    }
    return (UIViewController*)target;
}
@end

void show_debug_view(UIViewController* showVC, NSString* _bundleid);