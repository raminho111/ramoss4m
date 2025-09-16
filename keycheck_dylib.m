#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TOTAL_KEYS 99

static NSDictionary *keyDatabase;
static bool isPromptShowing = false;

NSString* getUUID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSDictionary* loadKeys() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    // 99 novas keys de 7 dias
    NSArray *keys7d = @[
        @"ramos-7D-001", @"ramos-7D-002", @"ramos-7D-003", @"ramos-7D-004", @"ramos-7D-005",
        @"ramos-7D-006", @"ramos-7D-007", @"ramos-7D-008", @"ramos-7D-009", @"ramos-7D-010",
        @"ramos-7D-011", @"ramos-7D-012", @"ramos-7D-013", @"ramos-7D-014", @"ramos-7D-015",
        @"ramos-7D-016", @"ramos-7D-017", @"ramos-7D-018", @"ramos-7D-019", @"ramos-7D-020",
        @"ramos-7D-021", @"ramos-7D-022", @"ramos-7D-023", @"ramos-7D-024", @"ramos-7D-025",
        @"ramos-7D-026", @"ramos-7D-027", @"ramos-7D-028", @"ramos-7D-029", @"ramos-7D-030",
        @"ramos-7D-031", @"ramos-7D-032", @"ramos-7D-033", @"ramos-7D-034", @"ramos-7D-035",
        @"ramos-7D-036", @"ramos-7D-037", @"ramos-7D-038", @"ramos-7D-039", @"ramos-7D-040",
        @"ramos-7D-041", @"ramos-7D-042", @"ramos-7D-043", @"ramos-7D-044", @"ramos-7D-045",
        @"ramos-7D-046", @"ramos-7D-047", @"ramos-7D-048", @"ramos-7D-049", @"ramos-7D-050",
        @"ramos-7D-051", @"ramos-7D-052", @"ramos-7D-053", @"ramos-7D-054", @"ramos-7D-055",
        @"ramos-7D-056", @"ramos-7D-057", @"ramos-7D-058", @"ramos-7D-059", @"ramos-7D-060",
        @"ramos-7D-061", @"ramos-7D-062", @"ramos-7D-063", @"ramos-7D-064", @"ramos-7D-065",
        @"ramos-7D-066", @"ramos-7D-067", @"ramos-7D-068", @"ramos-7D-069", @"ramos-7D-070",
        @"ramos-7D-071", @"ramos-7D-072", @"ramos-7D-073", @"ramos-7D-074", @"ramos-7D-075",
        @"ramos-7D-076", @"ramos-7D-077", @"ramos-7D-078", @"ramos-7D-079", @"ramos-7D-080",
        @"ramos-7D-081", @"ramos-7D-082", @"ramos-7D-083", @"ramos-7D-084", @"ramos-7D-085",
        @"ramos-7D-086", @"ramos-7D-087", @"ramos-7D-088", @"ramos-7D-089", @"ramos-7D-090",
        @"ramos-7D-091", @"ramos-7D-092", @"ramos-7D-093", @"ramos-7D-094", @"ramos-7D-095",
        @"ramos-7D-096", @"ramos-7D-097", @"ramos-7D-098", @"ramos-7D-099"
    ];

    for (NSString *key in keys7d) {
        dict[key] = @7; // cada key vale 7 dias
    }

    return dict;
}

bool validateKeyAndDate(NSString *key, NSString *uuid) {
    if (!keyDatabase[key]) return false;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedUUID = [defaults stringForKey:@"uuid"];
    if (storedUUID && ![storedUUID isEqualToString:uuid]) return false;

    NSDate *firstUse = [defaults objectForKey:[NSString stringWithFormat:@"%@_date", key]];
    if (!firstUse) return false;

    NSInteger daysValid = [keyDatabase[key] integerValue];
    NSDate *now = [NSDate date];
    NSTimeInterval seconds = [now timeIntervalSinceDate:firstUse];

    if (seconds <= (daysValid * 86400)) {
        return true;
    } else {
        return false;
    }
}

void promptForKey(void);

__attribute__((constructor))
static void initialize() {
    keyDatabase = loadKeys();
    NSString *uuid = getUUID();
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedKey = [defaults stringForKey:@"key"];

    // Sempre pede key ao abrir, só libera após validação
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!savedKey || !validateKeyAndDate(savedKey, uuid)) {
            promptForKey();
        }
    });
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

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RAMOSS4M FFH4X"
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
            isPromptShowing = false; // fecha somente após sucesso
        } else {
            isPromptShowing = false;
            promptForKey(); // força reaparecer até digitar key válida
        }
    }];

    UIAlertAction *discordAction = [UIAlertAction actionWithTitle:@"Discord"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSURL *discordURL = [NSURL URLWithString:@"https://discord.gg/Qr6fENhzG8"];
        if ([[UIApplication sharedApplication] canOpenURL:discordURL]) {
            [[UIApplication sharedApplication] openURL:discordURL options:@{} completionHandler:nil];
        }
        isPromptShowing = false;
        promptForKey(); // reaparece mesmo após abrir o discord
    }];

    [alert addAction:discordAction];
    [alert addAction:confirm];

    dispatch_async(dispatch_get_main_queue(), ^{
        [rootVC presentViewController:alert animated:YES completion:nil];
    });
}
