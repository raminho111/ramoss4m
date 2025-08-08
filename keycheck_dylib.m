#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TOTAL_KEYS 100

static NSDictionary *keyDatabase;
static bool isPromptShowing = false;

NSString* getUUID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSDictionary* loadKeys() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    NSArray *keys7d = @[
        @"ramos-XA12B-BT7YQ", @"ramos-B29TG-NVU92", @"ramos-19CXP-4UEZL", @"ramos-Q2R76-THW0K",
        @"ramos-Z9T2Q-L2JNY", @"ramos-KI9ZT-GP5R7", @"ramos-W2YU9-8J5CV", @"ramos-3UYTD-55KL3",
        @"ramos-YT83L-QKUIZ", @"ramos-HXZLK-M22TR", @"ramos-8NW9U-YXKLS", @"ramos-VP7RZ-LDKC3",
        @"ramos-0M3TZ-WR6CJ", @"ramos-FEJ3A-RUKP0", @"ramos-DZXJL-UE9YP", @"ramos-LZUP4-KTXV6",
        @"ramos-XWYTZ-M5ZQ3", @"ramos-PYUZS-R84JX", @"ramos-WQJ2L-F8M5D", @"ramos-EZLPK-HGX93"
    ];
    NSArray *keys15d = @[
        @"ramos-AK72P-BTN43", @"ramos-M2JU1-KL2XP", @"ramos-TI9G3-WE9UP", @"ramos-LX9K2-JD03X",
        @"ramos-V7EPL-N2J5M", @"ramos-NU32A-QWTZ4", @"ramos-KW84X-H3RLP", @"ramos-XZL5D-WY9PM",
        @"ramos-QPA3M-LZX7N", @"ramos-IE3KM-VTP5Q", @"ramos-GW93P-KLZUX", @"ramos-LMZ8A-R3WXP",
        @"ramos-ZY38M-XKT7L", @"ramos-OK4MD-KPZ8N", @"ramos-XF3ZQ-KMZ7L", @"ramos-RQ2Z8-KM3LW",
        @"ramos-WP94L-XUZ3Q", @"ramos-LT72Z-KPZXM", @"ramos-KQX28-MWP9L", @"ramos-BL94M-RX29Q"
    ];
    NSArray *keys30d = @[
        @"ramos-MXZLP-KTW7R", @"ramos-PU2KX-LZQ5T", @"ramos-OLZ8T-WRX9M", @"ramos-JX72M-LKT94",
        @"ramos-YX2KQ-MWPZ8", @"ramos-IZ83M-RPXL4", @"ramos-XP7ZK-L93MT", @"ramos-ZU29L-KTWP3",
        @"ramos-LY48T-RPQZ9", @"ramos-VT39M-LXPQ2", @"ramos-MT93Z-QKWP4", @"ramos-XZ83K-PML7W",
        @"ramos-QP9ZL-KXW72", @"ramos-WKX28-TY9ML", @"ramos-PLZ93-MTK7Q", @"ramos-KMX29-TWLPQ",
        @"ramos-JPZ39-LTWKQ", @"ramos-YTZ94-KXPMW", @"ramos-ZPW94-KMX2L", @"ramos-WXM29-LP9KT"
    ];
    NSArray *keysInfinite = @[];

    // Adicionando duas keys de 1 minuto (validação em segundos no código)
    NSArray *keys1min = @[
        @"ramos-MIN01-TESTE", @"ramos-MIN02-TESTE"
    ];

    for (NSString *key in keys7d) dict[key] = @7;
    for (NSString *key in keys15d) dict[key] = @15;
    for (NSString *key in keys30d) dict[key] = @30;
    for (NSString *key in keys1min) dict[key] = @(1.0/1440.0); // 1 minuto = 1/1440 dias

    return dict;
}

void showExpirationAlert(void) {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UIViewController *rootVC = window.rootViewController;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Key Expirada"
                                                                   message:@"Sua key expirou! Por favor, renove para continuar usando."
                                                            preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *discordAction = [UIAlertAction actionWithTitle:@"Abrir Discord"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSURL *discordURL = [NSURL URLWithString:@"https://discord.com/invite/ramoss4m"];
        if ([[UIApplication sharedApplication] canOpenURL:discordURL]) {
            [[UIApplication sharedApplication] openURL:discordURL options:@{} completionHandler:nil];
        }
    }];

    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Fechar"
                                                          style:UIAlertActionStyleCancel
                                                        handler:nil];

    [alert addAction:discordAction];
    [alert addAction:closeAction];

    dispatch_async(dispatch_get_main_queue(), ^{
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}

bool validateKeyAndDate(NSString *key, NSString *uuid) {
    if (!keyDatabase[key]) return false;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedUUID = [defaults stringForKey:@"uuid"];
    if (storedUUID && ![storedUUID isEqualToString:uuid]) return false;

    NSDate *firstUse = [defaults objectForKey:[NSString stringWithFormat:@"%@_date", key]];
    if (!firstUse) return false;

    // Ajustando cálculo para considerar 1 minuto como 60 segundos
    NSInteger daysValid = [keyDatabase[key] integerValue];
    if (daysValid == 0) return true; // no expiration

    NSDate *now = [NSDate date];
    NSTimeInterval seconds = [now timeIntervalSinceDate:firstUse];

    // Se a key for de 1 minuto (valor fracionado), calcular em segundos
    if (daysValid < 1) {
        NSTimeInterval allowedSeconds = daysValid * 86400; // daysValid está em dias fracionados
        if (seconds <= allowedSeconds) {
            return true;
        } else {
            showExpirationAlert();
            return false;
        }
    } else {
        if (seconds <= (daysValid * 86400)) {
            return true;
        } else {
            showExpirationAlert();
            return false;
        }
    }
}

void promptForKey(void);

__attribute__((constructor))
static void initialize() {
    keyDatabase = loadKeys();
    NSString *uuid = getUUID();
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedKey = [defaults stringForKey:@"key"];

    if (!savedKey || !validateKeyAndDate(savedKey, uuid)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            promptForKey();
        });
    }
}

void promptForKey() {
    if (isPromptShowing) return;
    isPromptShowing = true;

    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    UIViewController *rootVC = window.rootViewController;

    if (!rootVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPromptShowing = false;
            promptForKey();
        });
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FFH4X FFMAX"
                                                                   message:@"Insira sua key para continuar"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Sua Key";
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
        NSString *inputKey = alert.textFields.firstObject.text;
        NSString *uuid = getUUID();

        if (keyDatabase[inputKey]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:inputKey forKey:@"key"];
            [defaults setObject:uuid forKey:@"uuid"];
            [defaults setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@_date", inputKey]];
            [defaults synchronize];
            isPromptShowing = false;
        } else {
            isPromptShowing = false;
            promptForKey();
        }
    }];

    [alert addAction:confirm];
    [rootVC presentViewController:alert animated:YES completion:nil];
}

