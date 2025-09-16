//
//  RAMOSS4MAuth.m
//  Uso: cole este arquivo no seu projeto iOS (Objective-C) e compile.
//  Dependências: UIKit, Foundation, Security (Keychain).
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>

#pragma mark - KeyAuth Configuration

static NSString * const kKeyAuthApiBase = @"https://keyauth.win/api/1.3/";
static NSString * const kKeyAuthName    = @"ramoss4m";
static NSString * const kKeyAuthOwnerId = @"wBOrQJSMB8";
static NSString * const kKeyAuthSecret  = @"5640b89484d0d686a373fb93897e63fb2664cdf2a9ca2260d9167382c0d1609e";
static NSString * const kKeyAuthVersion = @"1.0";

#pragma mark - Local keys

static NSDictionary *gKeyDatabase = nil;
static bool gIsPromptShowing = false;
static dispatch_source_t gExpirationTimer = NULL;
static UIWindow *gFloatingWindow = nil;

NSString * getUUID(void) {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSDictionary * loadLocalKeys(void) {
    if (gKeyDatabase) return gKeyDatabase;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys7d = @[@"ramos-XA12B-BT7YQ", @"ramos-B29TG-NVU92"]; // reduzido para exemplo
    for (NSString *k in keys7d) dict[k] = @7;
    gKeyDatabase = [dict copy];
    return gKeyDatabase;
}

#pragma mark - Keychain helpers

void saveStringToKeychain(NSString *service, NSString *value) {
    if (!service || !value) return;
    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
    };
    SecItemDelete((__bridge CFDictionaryRef)query);
    NSMutableDictionary *add = [query mutableCopy];
    add[(__bridge id)kSecValueData] = data;
    SecItemAdd((__bridge CFDictionaryRef)add, NULL);
}

NSString * loadStringFromKeychain(NSString *service) {
    if (!service) return nil;
    NSDictionary *query = @{
        (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
        (__bridge id)kSecAttrService: service,
        (__bridge id)kSecReturnData: @YES,
        (__bridge id)kSecMatchLimit: (__bridge id)kSecMatchLimitOne
    };
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess && result) {
        NSData *data = (__bridge_transfer NSData *)result;
        return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

#pragma mark - Expiration timer helpers

void cancelExpirationTimer(void) {
    if (gExpirationTimer) {
        dispatch_source_cancel(gExpirationTimer);
        gExpirationTimer = NULL;
    }
}

void scheduleExpirationTimerForDate(NSDate *expireDate) {
    cancelExpirationTimer();
    NSTimeInterval interval = [expireDate timeIntervalSinceNow];
    if (interval <= 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            extern void promptForKey(void);
            promptForKey();
        });
        return;
    }
    dispatch_queue_t q = dispatch_get_main_queue();
    gExpirationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q);
    if (!gExpirationTimer) return;
    uint64_t startNs = (uint64_t)(interval * NSEC_PER_SEC);
    dispatch_source_set_timer(gExpirationTimer, dispatch_time(DISPATCH_TIME_NOW, startNs), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(gExpirationTimer, ^{
        extern void promptForKey(void);
        promptForKey();
    });
    dispatch_resume(gExpirationTimer);
}

#pragma mark - Offline validation

bool validateKeyOffline(NSString *key, NSString *uuid) {
    NSDictionary *dict = loadLocalKeys();
    if (!key || !dict[key]) return false;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedUUID = [defaults stringForKey:@"uuid"];
    if (storedUUID && ![storedUUID isEqualToString:uuid]) return false;
    NSDate *firstUse = [defaults objectForKey:[NSString stringWithFormat:@"%@_date", key]];
    if (!firstUse) return false;
    NSInteger daysValid = [dict[key] integerValue];
    NSDate *expireDate = [firstUse dateByAddingTimeInterval:(daysValid * 86400)];
    NSDate *now = [NSDate date];
    if ([now compare:expireDate] == NSOrderedAscending) {
        scheduleExpirationTimerForDate(expireDate);
        return true;
    }
    return false;
}

#pragma mark - Floating Button

@interface RAMFloatingButton : UIButton
@end

@implementation RAMFloatingButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = frame.size.width/2.0;
        self.adjustsImageWhenHighlighted = NO;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
        [self addTarget:self action:@selector(handleTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)g {
    UIWindow *win = self.window;
    CGPoint trans = [g translationInView:g.superview];
    CGPoint center = win.center;
    center.x += trans.x;
    center.y += trans.y;
    CGFloat halfW = CGRectGetWidth(win.bounds)/2.0;
    CGFloat leftLimit = -halfW * 1.2;
    CGFloat rightLimit = UIScreen.mainScreen.bounds.size.width + halfW * 1.2;
    CGFloat topLimit = halfW;
    CGFloat bottomLimit = UIScreen.mainScreen.bounds.size.height - halfW;
    center.x = fmax(leftLimit, fmin(center.x, rightLimit));
    center.y = fmax(topLimit, fmin(center.y, bottomLimit));
    win.center = center;
    [g setTranslation:CGPointZero inView:g.superview];
}

- (void)handleTap {
    UIAlertController *mini = [UIAlertController alertControllerWithTitle:@"ramoss4m"
                                                                   message:@"Mini painel"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Fechar" style:UIAlertActionStyleCancel handler:nil];
    [mini addAction:close];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *keyW = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
        UIViewController *root = keyW.rootViewController;
        UIViewController *presenting = root;
        while (presenting.presentedViewController) presenting = presenting.presentedViewController;
        [presenting presentViewController:mini animated:YES completion:nil];
    });
}

@end

#pragma mark - Floating window

void showFloatingButton(void) {
    if (gFloatingWindow) return;
    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize btnSize = CGSizeMake(64, 64);
        CGRect screen = UIScreen.mainScreen.bounds;
        CGRect frame = CGRectMake(screen.size.width - btnSize.width - 20, screen.size.height/2 - btnSize.height/2, btnSize.width, btnSize.height);
        gFloatingWindow = [[UIWindow alloc] initWithFrame:frame];
        gFloatingWindow.windowLevel = UIWindowLevelAlert + 1;
        gFloatingWindow.backgroundColor = [UIColor clearColor];
        gFloatingWindow.layer.cornerRadius = btnSize.width/2;
        gFloatingWindow.clipsToBounds = YES;
        gFloatingWindow.hidden = NO;

        RAMFloatingButton *btn = [[RAMFloatingButton alloc] initWithFrame:gFloatingWindow.bounds];

        // Desenhar letra "R" no centro
        UIGraphicsBeginImageContextWithOptions(btn.bounds.size, NO, 0);
        [[UIColor redColor] setFill];
        UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:btn.bounds];
        [p fill];
        NSString *rStr = @"R";
        NSDictionary *attr = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:36],
                               NSForegroundColorAttributeName: [UIColor whiteColor]};
        CGSize textSize = [rStr sizeWithAttributes:attr];
        CGPoint textPoint = CGPointMake((btn.bounds.size.width - textSize.width)/2,
                                        (btn.bounds.size.height - textSize.height)/2);
        [rStr drawAtPoint:textPoint withAttributes:attr];
        UIImage *circleR = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        [btn setImage:circleR forState:UIControlStateNormal];
        btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [gFloatingWindow addSubview:btn];
    });
}

void ensureFloatingExists(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        showFloatingButton();
    });
}

__attribute__((constructor))
static void ram_initialize(void) {
    loadLocalKeys();
    dispatch_async(dispatch_get_main_queue(), ^{
        ensureFloatingExists();
    });
}
