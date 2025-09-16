// RAMOSS4M_Auth_and_Float.m
// Cole no seu projeto (compile junto ao restante). Objective-C (.m)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Security/Security.h>

#pragma mark - KeyAuth config (fornecido por você)
static NSString * const kKeyAuthApiBase = @"https://keyauth.win/api/1.3/"; // endpoint padrão doc
static NSString * const kKeyAuthName = @"ramoss4m";
static NSString * const kKeyAuthOwnerId = @"wBOrQJSMB8";
static NSString * const kKeyAuthSecret = @"5640b89484d0d686a373fb93897e63fb2664cdf2a9ca2260d9167382c0d1609e";
static NSString * const kKeyAuthVersion = @"1.0";

#pragma mark - Local keys (offline fallback)
static NSDictionary *keyDatabase;
static bool isPromptShowing = false;
static dispatch_source_t expirationTimer = NULL;
static UIWindow *floatingWindow = nil;

NSString* getUUID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSDictionary* loadKeys() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSArray *keys7d = @[
        // (99 keys alfanuméricas — mesmas que combinamos antes)
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
    return dict;
}

#pragma mark - Keychain h
