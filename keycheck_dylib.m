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
    NSArray *keys7d = @[@"ramos-XA12B-BT7YQ", @"ramos-B29TG-NVU92", @"ramos-19CXP-4UEZL"];
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
        NSData *data = (NSData *)result; // sem __bridge_transfer
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        CFRelease(result);
        return str;
    }
    return nil;
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
    UIView *view = g.view; // <<< aqui corrigido
    if (!view) return;
    CGPoint trans = [g translationInView:view.superview];
    CGPoint center = view.center;
    center.x += trans.x;
    center.y += trans.y;

    CGFloat halfW = CGRectGetWidth(view.bounds)/2.0;
    CGFloat leftLimit = -halfW * 1.2;
    CGFloat rightLimit = UIScreen.mainScreen.bounds.size.width + halfW * 1.2;
    CGFloat topLimit = halfW;
    CGFloat bottomLimit = UIScreen.mainScreen.bounds.size.height - halfW;
    center.x = fmax(leftLimit, fmin(center.x, rightLimit));
    center.y = fmax(topLimit, fmin(center.y, bottomLimit));
    view.center = center;

    [g setTranslation:CGPointZero inView:view.superview];

    if (g.state == UIGestureRecognizerStateEnded) {
        CGFloat threshold = 0.6 * CGRectGetWidth(view.bounds);
        if (view.frame.origin.x < -threshold || view.frame.origin.x > UIScreen.mainScreen.bounds.size.width - CGRectGetWidth(view.bounds) + threshold) {
            view.alpha = 0.6;
        } else {
            view.alpha = 1.0;
        }
    }
}

- (void)handleTap {
    // aqui você pode colocar o mini panel
}

@end
