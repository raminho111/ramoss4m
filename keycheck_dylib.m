#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

bool validateKey(NSString *key, NSString *hwid);
void promptForKey(NSString *deviceID);

__attribute__((constructor))
static void initialize() {
    NSString *deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedKey = [defaults stringForKey:@"user_key"];
    if (!savedKey || !validateKey(savedKey, deviceID)) {
        promptForKey(deviceID);
    }
}

bool validateKey(NSString *key, NSString *hwid) {
    NSString *urlString = [NSString stringWithFormat:@"https://keyauth.win/api/1.0/?name=ramoss4m%%20ios&ownerid=wBOrQJSMB8&version=1.0&type=verify&key=%@&hwid=%@", key, hwid];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if (!responseData) return false;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
    return [json[@"success"] boolValue];
}

void promptForKey(NSString *deviceID) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"FFH4X FFMAX"
                                                                   message:@"Insira sua key para continuar."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Sua Key";
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
        NSString *inputKey = alert.textFields.firstObject.text;
        if (validateKey(inputKey, deviceID)) {
            [[NSUserDefaults standardUserDefaults] setObject:inputKey forKey:@"user_key"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } else {
            // Se a key for inválida, chama o prompt novamente
            promptForKey(deviceID);
        }
    }];
    [alert addAction:confirm];

    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        NSSet *scenes = UIApplication.sharedApplication.connectedScenes;
        for (UIScene *scene in scenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *w in windowScene.windows) {
                    if (w.isKeyWindow) {
                        window = w;
                        break;
                    }
                }
            }
            if (window) break;
        }
    } else {
        window = UIApplication.sharedApplication.keyWindow;
    }

    if (window == nil) {
        NSLog(@"[keyauth] Erro: não encontrou janela ativa para apresentar o login.");
        return;
    }

    UIViewController *rootVC = window.rootViewController;
    if (!rootVC) {
        NSLog(@"[keyauth] Erro: rootViewController é nil.");
        return;
    }

    // Delay para garantir que a UI esteja pronta para apresentar o alert
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}
