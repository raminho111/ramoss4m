#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define STORED_KEY @"user_key"
#define STORED_DATE @"activation_date"
#define VALID_KEY @"LP08U-I63TL-TH9EJ-JBJY1-LYW99"
#define MAX_DAYS 7
#define CLIENT_UUID @"00008101-001E40A614C0001E"

static bool isPromptShowing = false;

bool isKeyValid(NSString *key) {
    return [key isEqualToString:@VALID_KEY];
}

bool isUUIDValid(void) {
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return [deviceUUID isEqualToString:@CLIENT_UUID];
}

bool isDateValid(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *activationDate = [defaults objectForKey:@STORED_DATE];
    if (!activationDate) return false;

    NSTimeInterval timeSince = [[NSDate date] timeIntervalSinceDate:activationDate];
    return timeSince <= (MAX_DAYS * 24 * 60 * 60);
}

void saveActivationDate(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSDate date] forKey:@STORED_DATE];
    [defaults synchronize];
}

void promptForKey(void);

__attribute__((constructor))
static void initialize() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedKey = [defaults stringForKey:@STORED_KEY];

    if (!isUUIDValid() || !isKeyValid(savedKey) || !isDateValid()) {
        dispatch_async(dispatch_get_main_queue(), ^{
            promptForKey();
        });
    }
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
                if (window) break;
            }
        }
    } else {
        window = UIApplication.sharedApplication.keyWindow;
    }

    rootVC = window.rootViewController;
    if (!rootVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPromptShowing = false;
            promptForKey();
        });
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FFH4X FFMAX"
                                                                   message:@"Insira sua key exclusiva para continuar"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Sua Key";
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *inputKey = alert.textFields.firstObject.text;
        if (isUUIDValid() && isKeyValid(inputKey)) {
            [[NSUserDefaults standardUserDefaults] setObject:inputKey forKey:@STORED_KEY];
            saveActivationDate();
            [[NSUserDefaults standardUserDefaults] synchronize];
            isPromptShowing = false;
        } else {
            isPromptShowing = false;
            promptForKey();
        }
    }];

    [alert addAction:confirm];
    dispatch_async(dispatch_get_main_queue(), ^{
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}
