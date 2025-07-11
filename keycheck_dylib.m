#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define MAX_KEYS 100

static NSString *validKeys[MAX_KEYS] = {
    @"ramos-19A7E-AB3XZ", @"ramos-F8K2Q-W8YLM", @"ramos-3DL9T-RQ5NE", @"ramos-KJ1QZ-HT9XP",
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

int keyIndex(NSString *key) {
    for (int i = 0; i < MAX_KEYS; i++) {
        if ([validKeys[i] isEqualToString:key]) return i;
    }
    return -1;
}

BOOL isKeyValid(NSString *key) {
    NSInteger idx = keyIndex(key);
    if (idx == -1) return NO;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedKey = [defaults stringForKey:@"offline_key"];
    NSDate *activationDate = [defaults objectForKey:@"activation_date"];

    if (storedKey && [storedKey isEqualToString:key] && activationDate) {
        NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:activationDate];
        if ((idx < 20 && elapsed > 7*86400) || (idx < 40 && elapsed > 15*86400) || (idx < 60 && elapsed > 30*86400)) {
            return NO;
        }
        return YES;
    }
    return YES; // Primeira vez, permitido. Depois, salva.
}

void showKeyPrompt();

__attribute__((constructor))
static void init() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *key = [defaults stringForKey:@"offline_key"];
    if (!key || !isKeyValid(key)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            showKeyPrompt();
        });
    }
}

void showKeyPrompt() {
    static BOOL showing = NO;
    if (showing) return;
    showing = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = nil;
        UIViewController *vc = nil;

        if (@available(iOS 13.0, *)) {
            for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
                if ([scene isKindOfClass:[UIWindowScene class]]) {
                    for (UIWindow *win in ((UIWindowScene *)scene).windows) {
                        if (win.isKeyWindow) {
                            window = win;
                            break;
                        }
                    }
                    if (window) break;
                }
            }
        } else {
            window = UIApplication.sharedApplication.keyWindow;
        }

        vc = window.rootViewController;
        if (!vc) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                showing = NO;
                showKeyPrompt();
            });
            return;
        }

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RAMOS FFH4X"
                                                                       message:@"Insira sua key para continuar"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"ramos-XXXXX-XXXXX";
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Verificar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *inputKey = alert.textFields.firstObject.text;
            if (isKeyValid(inputKey)) {
                [[NSUserDefaults standardUserDefaults] setObject:inputKey forKey:@"offline_key"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"activation_date"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                showing = NO;
                showKeyPrompt();
            }
        }];
        [alert addAction:ok];
        [vc presentViewController:alert animated:YES completion:nil];
    });
}
