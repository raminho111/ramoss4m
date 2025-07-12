#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TOTAL_KEYS 100
#define KEY_PREFIX @"ramos-"
#define ALERT_TITLE @"RAMOS FFH4X"
#define ALERT_MSG @"Insira sua key para continuar."

// -------- CONFIG --------
static NSString *validKeys[TOTAL_KEYS] = {
    @"ramos-ABC12-DEF34", @"ramos-GHI56-JKL78", @" @"ramos-19A7E-AB3XZ", @"ramos-F8K2Q-W8YLM", @"ramos-3DL9T-RQ5NE", @"ramos-KJ1QZ-HT9XP",
    @"ramos-ZU8NY-AL4PQ", @"ramos-UE0JW-SX2LE", @"ramos-CR6ZM-LW4KF", @"ramos-EX9LD-NC1TB",
    @"ramos-YT3MB-JR2ED", @"ramos-BN2QU-ZP9KH", @"ramos-QM6FD-WK4TX", @"ramos-XL5RY-HM2VL",
    @"ramos-TN7KP-VR8UE", @"ramos-VF3JD-ZL6NH", @"ramos-MP1UZ-RB9TW", @"ramos-WX2CL-YD3EQ",
    @"ramos-ZT8VN-GK7MW", @"ramos-KY5XJ-NH1DF", @"ramos-HC4WM-LE6TP", @"ramos-DN9BR-UX3QK",
    // 15 dias
    @"ramos-FD5EL-PW7ZK", @"ramos-XU9KP-JM4VQ", @"ramos-KE6YD-WX1CB", @"ramos-LQ3MU-TP5NZ",
    @"ramos-AP2JV-ZK7RE", @"ramos-NY1XD-GF3TB", @"ramos-TK4ZR-MU9JY", @"ramos-RB7WD-XC6QE",
    @"ramos-ZN6YM-LF5UJ", @"ramos-VJ8QE-NK2TX", @"ramos-HX9MB-WD3CL", @"ramos-KT3RW-ZV8NM",
    @"ramos-QL5EP-JF1DU", @"ramos-BW2TX-GH9MC", @"ramos-MZ1KU-YL4VJ", @"ramos-JC7QM-RX6EB",
    @"ramos-WE9TZ-VN3LY", @"ramos-YX4PJ-UG7KC", @"ramos-LB6EW-KN2FD", @"ramos-FV3UP-DJ9TZ",
    // 30 dias
    @"ramos-ZD9MR-YK8TL", @"ramos-TC1JL-QN3XB", @"ramos-KV5XP-WD7RJ", @"ramos-NM4QY-HX9LU",
    @"ramos-XB2LE-VK5MJ", @"ramos-QR8JD-NY7TP", @"ramos-PT6XM-GF2UC", @"ramos-JF3YW-RB4LK",
    @"ramos-WD7QL-MZ1VU", @"ramos-LN9TC-KQ3YW", @"ramos-EK5UB-ZF7XD", @"ramos-VT3MP-YD9NC",
    @"ramos-HL1XE-WR6KZ", @"ramos-MB7YQ-XV2LU", @"ramos-RK6JN-TC9PV", @"ramos-YQ3LU-MD8BW",
    @"ramos-XN4KC-WP7LQ", @"ramos-TZ5EM-RK3VY", @"ramos-GD1LF-XB6QM", @"ramos-WK2YZ-JT9UC",
    // Ilimitadas (sem expiração)
    @"ramos-ILIM-001", @"ramos-ILIM-002", @"ramos-ILIM-003", @"ramos-ILIM-004", @"ramos-ILIM-005",
    @"ramos-ILIM-006", @"ramos-ILIM-007", @"ramos-ILIM-008", @"ramos-ILIM-009", @"ramos-ILIM-010",
    @"ramos-ILIM-011", @"ramos-ILIM-012", @"ramos-ILIM-013", @"ramos-ILIM-014", @"ramos-ILIM-015",
    @"ramos-ILIM-016", @"ramos-ILIM-017", @"ramos-ILIM-018", @"ramos-ILIM-019", @"ramos-ILIM-020"
};

    // 
};

static NSTimeInterval keyExpiryDays[TOTAL_KEYS] = {
    7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
    15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15,
    30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

#define STORED_KEY @"user_key"
#define STORED_UUID @"device_uuid"
#define STORED_DATE @"activation_date"

static bool isPromptShowing = false;

bool validateKey(NSString *key, NSString *uuid) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (int i = 0; i < TOTAL_KEYS; i++) {
        if ([key isEqualToString:validKeys[i]]) {
            NSString *storedUUID = [defaults stringForKey:STORED_UUID];
            if (!storedUUID || [storedUUID isEqualToString:uuid]) {
                NSTimeInterval expiryDays = keyExpiryDays[i];
                if (expiryDays == 0) return true; // Permanente

                NSDate *activationDate = [defaults objectForKey:STORED_DATE];
                if (!activationDate) return true; // Primeiro uso: válido, ativar
                NSDate *now = [NSDate date];
                NSTimeInterval elapsed = [now timeIntervalSinceDate:activationDate];
                return elapsed < (expiryDays * 24 * 60 * 60);
            }
        }
    }
    return false;
}

void promptForKey(void);

__attribute__((constructor))
static void initialize() {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *savedKey = [defaults stringForKey:STORED_KEY];
        NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        if (!savedKey || !validateKey(savedKey, uuid)) {
            promptForKey();
        }
    });
}

void promptForKey() {
    if (isPromptShowing) return;
    isPromptShowing = true;

    UIWindow *window = nil;
    UIViewController *rootVC = nil;

    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                for (UIWindow *win in ((UIWindowScene *)scene).windows) {
                    if (win.isKeyWindow) {
                        window = win;
                        break;
                    }
                }
            }
        }
    } else {
        window = UIApplication.sharedApplication.keyWindow;
    }
    rootVC = window.rootViewController;
    if (!rootVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPromptShowing = false;
            promptForKey();
        });
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE
                                                                   message:ALERT_MSG
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Sua Key";
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *inputKey = alert.textFields.firstObject.text;
        NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];

        if (validateKey(inputKey, uuid)) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:inputKey forKey:STORED_KEY];
            [defaults setObject:uuid forKey:STORED_UUID];
            if (![defaults objectForKey:STORED_DATE]) {
                [defaults setObject:[NSDate date] forKey:STORED_DATE];
            }
            [defaults synchronize];
        } else {
            isPromptShowing = false;
            promptForKey();
            return;
        }
        isPromptShowing = false;
    }];

    [alert addAction:confirm];
    [rootVC presentViewController:alert animated:YES completion:nil];
}
