//
//  RAMOSS4MAuth.m
//  Uso: cole este arquivo no seu projeto iOS (Objective-C) e compile.
//  Dependências: UIKit, Foundation, Security (Keychain).
//
//  Funcionalidades:
//  - Prompt de login imediato no startup e onBecomeActive
//  - Validação online via KeyAuth (license)
//  - Fallback offline com lista de 99 keys alfanuméricas
//  - Agendamento de timer local para reaparecer na expiração
//  - Floating button (imagem "r") arrastável que abre um mini-panel (Discord/TikTok)
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>

#pragma mark - KeyAuth Configuration (já com seus dados)

static NSString * const kKeyAuthApiBase = @"https://keyauth.win/api/1.3/"; // endpoint padrão
static NSString * const kKeyAuthName    = @"ramoss4m";
static NSString * const kKeyAuthOwnerId = @"wBOrQJSMB8";
static NSString * const kKeyAuthSecret  = @"5640b89484d0d686a373fb93897e63fb2664cdf2a9ca2260d9167382c0d1609e";
static NSString * const kKeyAuthVersion = @"1.0";

#pragma mark - Local keys (offline fallback)

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

    NSArray *keys7d = @[
        @"ramos-XA12B-BT7YQ", @"ramos-B29TG-NVU92", @"ramos-19CXP-4UEZL", @"ramos-Q2R76-THW0K",
        @"ramos-Z9T2Q-L2JNY", @"ramos-KI9ZT-GP5R7", @"ramos-W2YU9-8J5CV", @"ramos-3UYTD-55KL3",
        @"ramos-YT83L-QKUIZ", @"ramos-HXZLK-M22TR", @"ramos-8NW9U-YXKLS", @"ramos-VP7RZ-LDKC3",
        @"ramos-0M3TZ-WR6CJ", @"ramos-FEJ3A-RUKP0", @"ramos-DZXJL-UE9YP", @"ramos-LZUP4-KTXV6",
        @"ramos-XWYTZ-M5ZQ3", @"ramos-PYUZS-R84JX", @"ramos-WQJ2L-F8M5D", @"ramos-EZLPK-HGX93",
        @"ramos-AK72P-BTN43", @"ramos-M2JU1-KL2XP", @"ramos-TI9G3-WE9UP", @"ramos-LX9K2-JD03X",
        @"ramos-V7EPL-N2J5M", @"ramos-NU32A-QWTZ4", @"ramos-KW84X-H3RLP", @"ramos-XZL5D-WY9PM",
        @"ramos-QPA3M-LZX7N", @"ramos-IE3KM-VTP5Q", @"ramos-GW93P-KLZUX", @"ramos-LMZ8A-R3WXP",
        @"ramos-ZY38M-XKT7L", @"ramos-OK4MD-KPZ8N", @"ramos-XF3ZQ-KMZ7L", @"ramos-RQ2Z8-KM3LW",
        @"ramos-WP94L-XUZ3Q", @"ramos-LT72Z-KPZXM", @"ramos-KQX28-MWP9L", @"ramos-BL94M-RX29Q",
        @"ramos-MXZLP-KTW7R", @"ramos-PU2KX-LZQ5T", @"ramos-OLZ8T-WRX9M", @"ramos-JX72M-LKT94",
        @"ramos-YX2KQ-MWPZ8", @"ramos-IZ83M-RPXL4", @"ramos-XP7ZK-L93MT", @"ramos-ZU29L-KTWP3",
        @"ramos-LY48T-RPQZ9", @"ramos-VT39M-LXPQ2", @"ramos-MT93Z-QKWP4", @"ramos-XZ83K-PML7W",
        @"ramos-QP9ZL-KXW72", @"ramos-WKX28-TY9ML", @"ramos-PLZ93-MTK7Q", @"ramos-KMX29-TWLPQ",
        @"ramos-JPZ39-LTWKQ", @"ramos-YTZ94-KXPMW", @"ramos-ZPW94-KMX2L", @"ramos-WXM29-LP9KT",
        @"ramos-9A1BX-7YQ2P", @"ramos-3B4TZ-KP9QW", @"ramos-H8K2L-M3Z9X", @"ramos-2XK3P-Z7L4J",
        @"ramos-T9Q2W-6M3RK", @"ramos-V8P3X-2KJ4Z", @"ramos-R7M4K-Q2Z9L", @"ramos-N5J9P-LK3T8",
        @"ramos-Q8L2X-M7P3R", @"ramos-S4K9P-2Z3WQ", @"ramos-Y6P3Z-KL8X2", @"ramos-U2M9K-7Q4LP",
        @"ramos-C8K3Z-V2Q7P", @"ramos-B7L2X-N9P3K", @"ramos-D9P4K-L2X7Q", @"ramos-F3K7P-Q9L2X",
        @"ramos-G2L9X-M3P7Q", @"ramos-H4P8K-Z2M9X", @"ramos-J7X3K-P9L2Q", @"ramos-K9P2Z-M7Q3L",
        @"ramos-L3M9X-Q8P2K", @"ramos-M4K2P-Z7L9X", @"ramos-N8P3X-L2Q7M", @"ramos-P2L7K-Q9M3X",
        @"ramos-Q3K9P-L7X2M", @"ramos-R4P2X-K9M7L", @"ramos-S8L3K-Q2P9M", @"ramos-T9M4P-L3X2K",
        @"ramos-U7K2X-P9L3M", @"ramos-V3P9K-L2M7X", @"ramos-W2L8P-Q3K9M", @"ramos-X9M7K-P2L3Q",
        @"ramos-Y4P3X-K7L9M", @"ramos-Z2K9P-M3L7X", @"ramos-A3L7X-Q9P2M", @"ramos-B9P4K-L3M2X",
        @"ramos-C7M2P-Q9L3X", @"ramos-D3K9X-P7L2M", @"ramos-E2P7K-L9M3X", @"ramos-F9L3P-Q2K7M",
        @"ramos-G4M7X-K3P9L", @"ramos-H2P3K-L9X7M", @"ramos-J9K7P-M2L3X", @"ramos-K4P2X-Q7M9L",
        @"ramos-L9M3K-P7X2Q", @"ramos-M2L7P-K9Q3X", @"ramos-N3P9X-L2M7K", @"ramos-O7K4P-Q9L2M",
        @"ramos-P9M2X-L3K7Q"
    ];

    for (NSString *k in keys7d) dict[k] = @7;
    gKeyDatabase = [dict copy];
    return gKeyDatabase;
}

#pragma mark - Keychain helpers (simples)

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

#pragma mark - KeyAuth online validation (license)

typedef void (^KeyAuthLicenseCompletion)(BOOL success, NSDictionary *json, NSError *err);

NSString * urlEncode(NSString *s) {
    if (!s) return @"";
    NSCharacterSet *cs = [NSCharacterSet URLQueryAllowedCharacterSet];
    return [s stringByAddingPercentEncodingWithAllowedCharacters:cs];
}

void validateKeyOnlineWithKeyAuth(NSString *key, KeyAuthLicenseCompletion completion) {
    if (!key) {
        if (completion) completion(NO, nil, [NSError errorWithDomain:@"KeyAuth" code:400 userInfo:@{NSLocalizedDescriptionKey:@"no key"}]);
        return;
    }
    NSString *hwid = getUUID();
    NSString *urlStr = [NSString stringWithFormat:@"%@?type=license&key=%@&name=%@&ownerid=%@&hwid=%@",
                        kKeyAuthApiBase,
                        urlEncode(key),
                        urlEncode(kKeyAuthName),
                        urlEncode(kKeyAuthOwnerId),
                        urlEncode(hwid)];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"GET";
    req.timeoutInterval = 8.0;
    NSURLSessionDataTask *t = [[NSURLSession sharedSession] dataTaskWithRequest:req completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (completion) completion(NO, nil, error);
            return;
        }
        if (!data) {
            if (completion) completion(NO, nil, [NSError errorWithDomain:@"KeyAuth" code:500 userInfo:@{NSLocalizedDescriptionKey:@"no data"}]);
            return;
        }
        NSError *jerr = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jerr];
        if (jerr) {
            if (completion) completion(NO, nil, jerr);
            return;
        }
        BOOL success = [json[@"success"] boolValue];
        if (completion) completion(success, json, nil);
    }];
    [t resume];
}

#pragma mark - Combined validation: online prefer, fallback offline

void validateKeyPreferOnline(NSString *inputKey, void (^result)(BOOL ok, NSString *reason)) {
    if (!inputKey) {
        if (result) result(NO, @"no_key");
        return;
    }

    // Try online first
    validateKeyOnlineWithKeyAuth(inputKey, ^(BOOL success, NSDictionary *json, NSError *err) {
        if (success) {
            // Save local metadata and schedule expiration (use server expires if provided)
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:inputKey forKey:@"key"];
            [defaults setObject:getUUID() forKey:@"uuid"];
            [defaults setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@_date", inputKey]];
            [defaults synchronize];

            // If server returned expires inside info.expires parse it (ISO8601)
            NSString *expiresStr = nil;
            if ([json isKindOfClass:[NSDictionary class]] && json[@"info"] && [json[@"info"] isKindOfClass:[NSDictionary class]] && json[@"info"][@"expires"]) {
                expiresStr = json[@"info"][@"expires"];
            }
            if (expiresStr) {
                NSDateFormatter *f = [[NSDateFormatter alloc] init];
                f.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
                f.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
                NSDate *expireDate = [f dateFromString:expiresStr];
                if (expireDate) scheduleExpirationTimerForDate(expireDate);
            } else {
                // fallback to local key days
                NSDictionary *dict = loadLocalKeys();
                if (dict[inputKey]) {
                    NSInteger daysValid = [dict[inputKey] integerValue];
                    NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:(daysValid * 86400)];
                    scheduleExpirationTimerForDate(expireDate);
                }
            }

            // save potential token
            if (json[@"token"]) saveStringToKeychain(@"_remote_token", json[@"token"]);
            if (result) result(YES, @"online_valid");
            return;
        } else {
            // if server explicit invalid (no error, success==NO) -> reject immediately
            if (err == nil && success == NO) {
                if (result) result(NO, @"online_invalid");
                return;
            }
            // network error -> fallback offline
            BOOL ok = validateKeyOffline(inputKey, getUUID());
            if (result) result(ok, ok?@"offline_valid":@"offline_invalid");
            return;
        }
    });
}

#pragma mark - Floating Button (subclass simple)

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
    CGPoint trans = [g translationInView:UIScreen.mainScreen.coordinateSpace];
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
    [g setTranslation:CGPointZero inView:UIScreen.mainScreen.coordinateSpace];

    if (g.state == UIGestureRecognizerStateEnded) {
        CGFloat threshold = 0.6 * CGRectGetWidth(win.bounds);
        if (win.frame.origin.x < -threshold || win.frame.origin.x > UIScreen.mainScreen.bounds.size.width - CGRectGetWidth(win.bounds) + threshold) {
            win.alpha = 0.6;
        } else {
            win.alpha = 1.0;
        }
    }
}

- (void)handleTap {
    // show mini panel
    UIAlertController *mini = [UIAlertController alertControllerWithTitle:@"ramoss4m - discord: tiktok:" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *discord = [UIAlertAction actionWithTitle:@"Abrir Discord" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *u = [NSURL URLWithString:@"https://discord.gg/Qr6fENhzG8"];
        if ([[UIApplication sharedApplication] canOpenURL:u]) {
            [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
        }
    }];
    UIAlertAction *tiktok = [UIAlertAction actionWithTitle:@"Abrir TikTok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *u = [NSURL URLWithString:@"https://www.tiktok.com/@ramoss4m"];
        if ([[UIApplication sharedApplication] canOpenURL:u]) {
            [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
        }
    }];
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"Fechar" style:UIAlertActionStyleCancel handler:nil];
    [mini addAction:discord];
    [mini addAction:tiktok];
    [mini addAction:close];

    // present using keyWindow root VC
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
        UIImage *img = [UIImage imageNamed:@"r"];
        if (!img) {
            UIGraphicsBeginImageContextWithOptions(btn.bounds.size, NO, 0);
            [[UIColor redColor] setFill];
            UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:btn.bounds];
            [p fill];
            UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [btn setImage:circle forState:UIControlStateNormal];
        } else {
            [btn setImage:img forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }
        [gFloatingWindow addSubview:btn];
    });
}

void ensureFloatingExists(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        showFloatingButton();
    });
}

#pragma mark - Prompt for key (bloqueante até validar)

void promptForKey(void);

__attribute__((constructor))
static void ram_initialize(void) {
    // prepare local DB
    loadLocalKeys();

    // observe become active to revalidate immediately
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        NSString *curKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"key"];
        if (!curKey) {
            promptForKey();
        } else {
            // prefer online revalidation
            validateKeyPreferOnline(curKey, ^(BOOL ok, NSString *reason) {
                if (!ok) {
                    promptForKey();
                }
            });
        }
        ensureFloatingExists();
    }];

    // startup: show floating and prompt if needed
    dispatch_async(dispatch_get_main_queue(), ^{
        ensureFloatingExists();
        NSString *savedKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"key"];
        NSString *uuid = getUUID();
        if (!savedKey || !validateKeyOffline(savedKey, uuid)) {
            if (savedKey) {
                validateKeyPreferOnline(savedKey, ^(BOOL ok, NSString *reason) {
                    if (!ok) promptForKey();
                });
            } else {
                promptForKey();
            }
        }
    });
}

void promptForKey(void) {
    if (gIsPromptShowing) return;
    gIsPromptShowing = true;
    cancelExpirationTimer();

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = UIApplication.sharedApplication.keyWindow ?: UIApplication.sharedApplication.windows.firstObject;
        UIViewController *rootVC = window.rootViewController;
        if (!rootVC) {
            gIsPromptShowing = false;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                promptForKey();
            });
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RAMOSS4M FFH4X"
                                                                       message:@"Insira sua key ou usuário"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"Sua Key ou usuário (ex: 1)";
            textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        }];

        __weak UIAlertController *weakAlert = alert;
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UIAlertController *strong = weakAlert;
            NSString *input = strong.textFields.firstObject.text;
            if (!input || input.length == 0) {
                gIsPromptShowing = false;
                promptForKey();
                return;
            }
            // prefer online -> fallback offline
            validateKeyPreferOnline(input, ^(BOOL ok, NSString *reason) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (ok) {
                        gIsPromptShowing = false;
                        // success: do nothing else, floating stays
                    } else {
                        gIsPromptShowing = false;
                        // invalid -> re-prompt
                        promptForKey();
                    }
                });
            });
        }];

        UIAlertAction *discordAction = [UIAlertAction actionWithTitle:@"Discord" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL *discordURL = [NSURL URLWithString:@"https://discord.gg/Qr6fENhzG8"];
            if ([[UIApplication sharedApplication] canOpenURL:discordURL]) {
                [[UIApplication sharedApplication] openURL:discordURL options:@{} completionHandler:nil];
            }
            gIsPromptShowing = false;
        }];

        [alert addAction:discordAction];
        [alert addAction:confirm];

        UIViewController *presenting = rootVC;
        while (presenting.presentedViewController) presenting = presenting.presentedViewController;
        [presenting presentViewController:alert animated:YES completion:nil];
    });
}
