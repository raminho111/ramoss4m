#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TOTAL_KEYS 100

typedef struct {
    __unsafe_unretained NSString *key;
    NSTimeInterval validityDays;
} LicenseKey;

static LicenseKey validKeys[TOTAL_KEYS] = {
    {@"ramos-X5T3Q-F9PL0", 7}, {@"ramos-K2VD8-J8RLC", 7}, {@"ramos-A7UZT-P0KL3", 7},
    {@"ramos-L5B2X-W1QNP", 7}, {@"ramos-E4YXM-M3FJ9", 7}, {@"ramos-W9ZQM-U2GKD", 7},
    {@"ramos-C2JVL-V7UEQ", 7}, {@"ramos-H3YPU-Y0KMN", 7}, {@"ramos-P5RTO-K3DJC", 7},
    {@"ramos-V7EMQ-X4KWP", 7}, {@"ramos-D1HZA-C7MYL", 7}, {@"ramos-G3TNO-J6AVX", 7},
    {@"ramos-N6WRM-E5BJL", 7}, {@"ramos-B8YDK-T0ZRM", 7}, {@"ramos-M1LQC-Z2XJK", 7},
    {@"ramos-Q2UYA-K9CMZ", 7}, {@"ramos-R5AVB-J3FZL", 7}, {@"ramos-F9HZK-W6UPM", 7},
    {@"ramos-T8LMW-Y3NKD", 7}, {@"ramos-Z3UPT-D1VXM", 7},

    {@"ramos-J0NWB-B9GZX", 15}, {@"ramos-X1DQC-T4LZN", 15}, {@"ramos-K7YUJ-F0JDL", 15},
    {@"ramos-V6MWR-M2PCX", 15}, {@"ramos-E3UZY-K7XJL", 15}, {@"ramos-T4PXB-C9LZV", 15},
    {@"ramos-F5YKM-W1VUZ", 15}, {@"ramos-H9UZN-K5YXM", 15}, {@"ramos-Q4LMW-X0NTZ", 15},
    {@"ramos-Z1TJC-F7RML", 15}, {@"ramos-C2MWN-Y8PAK", 15}, {@"ramos-G0VXP-D2UJL", 15},
    {@"ramos-M3YUZ-V9NKC", 15}, {@"ramos-N9RXJ-Z1CLQ", 15}, {@"ramos-D8PUW-K6LXY", 15},
    {@"ramos-B3QTL-X9MYN", 15}, {@"ramos-A5KYC-R4PWJ", 15}, {@"ramos-U2ZMV-F8WCL", 15},
    {@"ramos-L7WQX-J0TVD", 15}, {@"ramos-Y6TXB-M3ZVK", 15},

    {@"ramos-P9AKW-B3YJL", 30}, {@"ramos-X4VNL-C5WQM", 30}, {@"ramos-J1QWM-X8PKY", 30},
    {@"ramos-K3UPX-N2TJQ", 30}, {@"ramos-V8DYC-Y9KLN", 30}, {@"ramos-Z7MXB-P5VLW", 30},
    {@"ramos-Q0ULC-T1MXN", 30}, {@"ramos-H5PYX-K7DWC", 30}, {@"ramos-F3ZWJ-Y4NVC", 30},
    {@"ramos-E1XKL-J6TZW", 30}, {@"ramos-L6VKQ-W8RMC", 30}, {@"ramos-M0XZT-D2LNP", 30},
    {@"ramos-N7AQY-X9PKV", 30}, {@"ramos-C5VRM-F3TLZ", 30}, {@"ramos-B2MWZ-P0KLC", 30},
    {@"ramos-G9YTC-Z1NQV", 30}, {@"ramos-T3RXJ-L7MWC", 30}, {@"ramos-Y5PKQ-V2UCL", 30},
    {@"ramos-D0ZYN-K3JXV", 30}, {@"ramos-A6MQB-X5LRC", 30},

    {@"ramos-R1KQY-W3DMC", 0}, {@"ramos-S2XZW-L9YNP", 0}, {@"ramos-W0NMC-X2TVK", 0},
    {@"ramos-J9ZPQ-D6RLW", 0}, {@"ramos-V3YLK-K1UPQ", 0}, {@"ramos-E2XVM-Z5MWY", 0},
    {@"ramos-T7PLQ-Y3DNC", 0}, {@"ramos-Q9KZW-F0TJL", 0}, {@"ramos-H1NMC-W6LQB", 0},
    {@"ramos-K8RYZ-J2VPM", 0}, {@"ramos-Z6UKL-M5XWC", 0}, {@"ramos-N0XBW-T9JVL", 0},
    {@"ramos-B5LKM-Y7PQD", 0}, {@"ramos-F6QWC-D3MLN", 0}, {@"ramos-A9WTP-X4JCM", 0},
    {@"ramos-M8RXC-K6UPZ", 0}, {@"ramos-D1ZYL-V1NQK", 0}, {@"ramos-C3MWZ-J0PKL", 0},
    {@"ramos-Y2KQT-F7VWC", 0}, {@"ramos-U0TWM-L9DYC", 0}, {@"ramos-G8PLV-M2NJK", 0},
    {@"ramos-X5AVC-Z8RLW", 0}, {@"ramos-J3WQN-K4YLP", 0}, {@"ramos-K6XBP-P9MNL", 0},
    {@"ramos-T1VXM-D5YQK", 0}, {@"ramos-R4ULW-X7JKP", 0}, {@"ramos-H2NZC-V0MLW", 0},
    {@"ramos-Z9YKW-Y1RNL", 0}, {@"ramos-Q5TXM-K3DPL", 0}, {@"ramos-L7PMB-X2UQN", 0},
    {@"ramos-N3ZLK-J6MKP", 0}, {@"ramos-B0KYW-W8RPQ", 0}, {@"ramos-G4YTC-L5NVK", 0},
    {@"ramos-A2PXZ-Y9JQC", 0}, {@"ramos-F8VMW-T3PKD", 0}, {@"ramos-E7KYC-X0MRL", 0},
    {@"ramos-M6QTB-P1LKC", 0}, {@"ramos-C1UPW-Z6NKQ", 0}, {@"ramos-D9XTV-Y8RLJ", 0},
    {@"ramos-Y4LMK-K2UPX", 0}, {@"ramos-U5MWP-M7YTL", 0}
};

NSString *getUUID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

bool isKeyValid(NSString *inputKey) {
    NSString *uuid = getUUID();
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    for (int i = 0; i < TOTAL_KEYS; i++) {
        if ([inputKey isEqualToString:validKeys[i].key]) {
            NSString *storedUUID = [defaults stringForKey:[@"uuid_" stringByAppendingString:inputKey]];
            NSDate *activationDate = [defaults objectForKey:[@"date_" stringByAppendingString:inputKey]];
            NSTimeInterval validity = validKeys[i].validityDays;

            if (storedUUID && ![storedUUID isEqualToString:uuid]) return false;

            if (!storedUUID) {
                [defaults setObject:uuid forKey:[@"uuid_" stringByAppendingString:inputKey]];
                [defaults setObject:[NSDate date] forKey:[@"date_" stringByAppendingString:inputKey]];
                [defaults synchronize];
                return true;
            }

            if (validity > 0 && activationDate) {
                NSTimeInterval timeElapsed = [[NSDate date] timeIntervalSinceDate:activationDate];
                return timeElapsed <= validity * 86400;
            }

            return true;
        }
    }
    return false;
}

void showKeyPrompt() {
    static BOOL showing = NO;
    if (showing) return;
    showing = YES;

    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
        UIViewController *vc = window.rootViewController;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FFH4X FFMAX"
                                                                       message:@"Insira sua key para continuar"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"ramos-XXXXX-XXXXX";
        }];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"Verificar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *key = alert.textFields.firstObject.text;
            if (isKeyValid(key)) {
                [[NSUserDefaults standardUserDefaults] setObject:key forKey:@"user_key"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                showing = NO;
            } else {
                showing = NO;
                showKeyPrompt();
            }
        }];
        [alert addAction:ok];
        [vc presentViewController:alert animated:YES completion:nil];
    });
}

__attribute__((constructor))
void start() {
    NSString *key = [[NSUserDefaults standardUserDefaults] stringForKey:@"user_key"];
    if (!key || !isKeyValid(key)) {
        showKeyPrompt();
    }
}
