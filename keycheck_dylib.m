#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ALERT_TITLE @"FFH4X FFMAX"
#define ALERT_MSG @"Insira sua key para continuar."

// --- KEYS EMBUTIDAS ---
NSDictionary* getValidKeys() {
    return @{
        // 7 dias
        @"ramos-A1B2C-D3E4F": @(7),
        @"ramos-G5H6I-J7K8L": @(7),
        @"ramos-M9N0O-P1Q2R": @(7),
        @"ramos-S3T4U-V5W6X": @(7),
        @"ramos-Y7Z8A-B9C0D": @(7),
        @"ramos-E1F2G-H3I4J": @(7),
        @"ramos-K5L6M-N7O8P": @(7),
        @"ramos-Q9R0S-T1U2V": @(7),
        @"ramos-W3X4Y-Z5A6B": @(7),
        @"ramos-C7D8E-F9G0H": @(7),
        @"ramos-I1J2K-L3M4N": @(7),
        @"ramos-O5P6Q-R7S8T": @(7),
        @"ramos-U9V0W-X1Y2Z": @(7),
        @"ramos-A3B4C-D5E6F": @(7),
        @"ramos-G7H8I-J9K0L": @(7),
        @"ramos-M1N2O-P3Q4R": @(7),
        @"ramos-S5T6U-V7W8X": @(7),
        @"ramos-Y9Z0A-B1C2D": @(7),
        @"ramos-E3F4G-H5I6J": @(7),
        @"ramos-K7L8M-N9O0P": @(7),

        // 15 dias
        @"ramos-Q1R2S-T3U4V": @(15),
        @"ramos-W5X6Y-Z7A8B": @(15),
        @"ramos-C9D0E-F1G2H": @(15),
        @"ramos-I3J4K-L5M6N": @(15),
        @"ramos-O7P8Q-R9S0T": @(15),
        @"ramos-U1V2W-X3Y4Z": @(15),
        @"ramos-A5B6C-D7E8F": @(15),
        @"ramos-G9H0I-J1K2L": @(15),
        @"ramos-M3N4O-P5Q6R": @(15),
        @"ramos-S7T8U-V9W0X": @(15),
        @"ramos-Y1Z2A-B3C4D": @(15),
        @"ramos-E5F6G-H7I8J": @(15),
        @"ramos-K9L0M-N1O2P": @(15),
        @"ramos-Q3R4S-T5U6V": @(15),
        @"ramos-W7X8Y-Z9A0B": @(15),
        @"ramos-C1D2E-F3G4H": @(15),
        @"ramos-I5J6K-L7M8N": @(15),
        @"ramos-O9P0Q-R1S2T": @(15),
        @"ramos-U3V4W-X5Y6Z": @(15),
        @"ramos-A7B8C-D9E0F": @(15),

        // 30 dias
        @"ramos-G1H2I-J3K4L": @(30),
        @"ramos-M5N6O-P7Q8R": @(30),
        @"ramos-S9T0U-V1W2X": @(30),
        @"ramos-Y3Z4A-B5C6D": @(30),
        @"ramos-E7F8G-H9I0J": @(30),
        @"ramos-K1L2M-N3O4P": @(30),
        @"ramos-Q5R6S-T7U8V": @(30),
        @"ramos-W9X0Y-Z1A2B": @(30),
        @"ramos-C3D4E-F5G6H": @(30),
        @"ramos-I7J8K-L9M0N": @(30),
        @"ramos-O1P2Q-R3S4T": @(30),
        @"ramos-U5V6W-X7Y8Z": @(30),
        @"ramos-A9B0C-D1E2F": @(30),
        @"ramos-G3H4I-J5K6L": @(30),
        @"ramos-M7N8O-P9Q0R": @(30),
        @"ramos-S1T2U-V3W4X": @(30),
        @"ramos-Y5Z6A-B7C8D": @(30),
        @"ramos-E9F0G-H1I2J": @(30),
        @"ramos-K3L4M-N5O6P": @(30),
        @"ramos-Q7R8S-T9U0V": @(30),

        // Sem expiração
        @"ramos-W1X2Y-Z3A4B": @(0),
        @"ramos-C5D6E-F7G8H": @(0),
        @"ramos-I9J0K-L1M2N": @(0),
        @"ramos-O3P4Q-R5S6T": @(0),
        @"ramos-U7V8W-X9Y0Z": @(0),
        @"ramos-A1B3C-D5E7F": @(0),
        @"ramos-G9H1I-J3K5L": @(0),
        @"ramos-M7N9O-P1Q3R": @(0),
        @"ramos-S5T7U-V9W1X": @(0),
        @"ramos-Y3Z5A-B7C9D": @(0),
        @"ramos-E1F3G-H5I7J": @(0),
        @"ramos-K9L1M-N3O5P": @(0),
        @"ramos-Q7R9S-T1U3V": @(0),
        @"ramos-W5X7Y-Z9A1B": @(0),
        @"ramos-C3D5E-F7G9H": @(0),
        @"ramos-I1J3K-L5M7N": @(0),
        @"ramos-O9P1Q-R3S5T": @(0),
        @"ramos-U7V9W-X1Y3Z": @(0),
        @"ramos-A5B7C-D9E1F": @(0),
        @"ramos-G3H5I-J7K9L": @(0)
    };
}

NSString* getDeviceID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

bool validateKeyForDevice(NSString *key, NSString *deviceID) {
    NSDictionary *validKeys = getValidKeys();
    NSNumber *days = validKeys[key];
    if (!days) return false;

    NSString *storedUUID = [[NSUserDefaults standardUserDefaults] stringForKey:@"uuid"];
    if (storedUUID && ![storedUUID isEqualToString:deviceID]) return false;

    if (![storedUUID isEqualToString:deviceID]) {
        [[NSUserDefaults standardUserDefaults] setObject:deviceID forKey:@"uuid"];
    }

    if ([days intValue] == 0) return true;

    NSDate *activationDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"activation_date"];
    if (!activationDate) return false;

    NSTimeInterval elapsed = [[NSDate date] timeIntervalSinceDate:activationDate];
    return elapsed <= ([days intValue] * 86400);
}

void promptForKeyIfNeeded() {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *deviceID = getDeviceID();
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *savedKey = [defaults stringForKey:@"user_key"];

        if (!savedKey || !validateKeyForDevice(savedKey, deviceID)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:ALERT_TITLE
                                                                               message:ALERT_MSG
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
                    textField.placeholder = @"Sua Key";
                }];

                UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar"
                                                                  style:UIAlertActionStyleDefault
                                                                handler:^(UIAlertAction *action) {
                    NSString *inputKey = alert.textFields.firstObject.text;
                    if (validateKeyForDevice(inputKey, deviceID)) {
                        [defaults setObject:inputKey forKey:@"user_key"];
                        [defaults setObject:deviceID forKey:@"uuid"];
                        [defaults setObject:[NSDate date] forKey:@"activation_date"];
                        [defaults synchronize];
                    } else {
                        promptForKeyIfNeeded(); // reexibe se for inválida
                    }
                }];
                [alert addAction:confirm];

                UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
                [window.rootViewController presentViewController:alert animated:YES completion:nil];
            });
        }
    });
}

__attribute__((constructor))
static void initialize() {
    dispatch_async(dispatch_get_main_queue(), ^{
        promptForKeyIfNeeded();
    });
}
