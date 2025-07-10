#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

bool validateKey(NSString *key);
void promptForKey(void);

static bool isPromptShowing = false;

__attribute__((constructor))
static void initialize() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedKey = [defaults stringForKey:@"user_key"];
    if (!savedKey || !validateKey(savedKey)) {
        dispatch_async(dispatch_get_main_queue(), ^{
            promptForKey();
        });
    }
}

bool validateKey(NSString *key) {
    // Apenas valida a key, sem HWID
    NSString *urlString = [NSString stringWithFormat:@"https://keyauth.win/api/1.0/?name=ramoss4m%%20ios&ownerid=wBOrQJSMB8&version=1.0&type=verify&key=%@", key];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (!responseData) return false;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    return [json[@"success"] boolValue];
}

void promptForKey() {
    if (isPromptShowing) return;
    isPromptShowing = true;

    UIWindow *window = nil;
    UIViewController *rootVC = nil;

    if (@available(iOS 13.0, *)) {
        NSSet *scenes = [UIApplication.sharedApplication connectedScenes];
        for (UIScene *scene in scenes) {
            if ([scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *win in windowScene.windows) {
                    if (win.isKeyWindow) {
                        window = win;
                        break;
                    }
                }
                if (window) break;
            }
        }
        rootVC = window.rootViewController;
    } else {
        window = UIApplication.sharedApplication.keyWindow;
        rootVC = window.rootViewController;
    }

    if (!rootVC) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            isPromptShowing = false;
            promptForKey();
        });
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FFH4X FFMAX"
                                                                   message:@"Insira sua key para continuar."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Sua Key";
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *inputKey = alert.textFields.firstObject.text;
        if (validateKey(inputKey)) {
            [[NSUserDefaults standardUserDefaults] setObject:inputKey forKey:@"user_key"];
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
