#import <mach-o/dyld.h>
// GCD
#define GCD_RUN_MAIN dispatch_async(dispatch_get_main_queue(),^(){
#define GCD_RUN(__dp_q) dispatch_async(dispatch_queue_create(__dp_q, NULL),^(){
#define GCD_AFTER_MAIN(__dp_af) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(__dp_af * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
#define GCD_AFTER(__dp_af, __dp_q) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(__dp_af * NSEC_PER_SEC)), dispatch_queue_create(__dp_q, NULL), ^{
#define GCD_END });
#define SLEEP(sec) 	[NSThread sleepForTimeInterval:sec]

#define XLOG(log, ...)	NSLog(@"[tap2debug] " log, ##__VA_ARGS__)

#define X_OC_NEW_NAME(CLASS_ID, SEL_ID)	_x_new_func$##CLASS_ID##$##SEL_ID
#define X_OC_NEW(CLASS_ID, SEL_ID, ...)	X_OC_NEW_NAME(CLASS_ID, SEL_ID)(id _id, SEL _sel, ##__VA_ARGS__)

#define X_OC_ORI_NAME(CLASS_ID, SEL_ID)	_x_orig_func$##CLASS_ID##$##SEL_ID
#define X_OC_ORI(CLASS_ID, SEL_ID, ...)	(*X_OC_ORI_NAME(CLASS_ID, SEL_ID))(id _id, SEL _sel, ##__VA_ARGS__)

#define X_OC_HOOK(CLASS_ID, SEL_ID, CLASS_NAME, SEL_NAME)	do{	    Method _method_$##CLASS_ID##$##SEL_ID = class_getClassMethod(NSClassFromString(@""CLASS_NAME), NSSelectorFromString(@""SEL_NAME));     X_OC_ORI_NAME(CLASS_ID,SEL_ID) = (void*)method_getImplementation(_method_$##CLASS_ID##$##SEL_ID);	    method_setImplementation(_method_$##CLASS_ID##$##SEL_ID, (IMP)&X_OC_NEW_NAME(CLASS_ID, SEL_ID));	    }while(0)


#define X_C_NEW_NAME(FUNC_ADDR)	_x_c_new_func_##FUNC_ADDR
#define X_C_NEW(FUNC_ADDR, ...)	X_C_NEW_NAME(FUNC_ADDR)(##__VA_ARGS__)

#define X_C_ORI_NAME(FUNC_ADDR)	_x_c_orig_func_##FUNC_ADDR
#define X_C_ORI(FUNC_ADDR, ...)	(*X_C_ORI_NAME(FUNC_ADDR))(##__VA_ARGS__)

#define X_C_HOOK(FUNC_ADDR)		do{    void* _sub_##FUNC_ADDR = (void*)(_dyld_get_image_vmaddr_slide(0) + FUNC_ADDR);    MSHookFunction(_sub_##FUNC_ADDR, X_C_NEW_NAME(FUNC_ADDR), &X_C_ORI_NAME(FUNC_ADDR)); }while(0)

