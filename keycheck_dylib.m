#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define TOTAL_KEYS 99

static NSDictionary *keyDatabase;
static bool isPromptShowing = false;
static dispatch_source_t expirationTimer = NULL;
static UIWindow *floatingWindow = nil;

NSString* getUUID() {
    return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

NSDictionary* loadKeys() {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    // (Use as mesmas 99 keys alfanuméricas que definimos antes)
    NSArray *keys7d = @[
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

    for (NSString *key in keys7d) {
        dict[key] = @7;
    }
    return dict;
}

#pragma mark - Expiration timer helpers

void cancelExpirationTimer() {
    if (expirationTimer) {
        dispatch_source_cancel(expirationTimer);
        expirationTimer = NULL;
    }
}

void scheduleExpirationTimerForDate(NSDate *expireDate) {
    cancelExpirationTimer();
    NSTimeInterval interval = [expireDate timeIntervalSinceNow];
    if (interval <= 0) {
        // já expirou -> mostrar prompt imediatamente
        dispatch_async(dispatch_get_main_queue(), ^{
            // força exibição do prompt
            extern void promptForKey(void);
            promptForKey();
        });
        return;
    }

    dispatch_queue_t q = dispatch_get_main_queue();
    expirationTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, q);
    if (!expirationTimer) return;
    uint64_t startNs = (uint64_t)(interval * NSEC_PER_SEC);
    dispatch_source_set_timer(expirationTimer, dispatch_time(DISPATCH_TIME_NOW, startNs), DISPATCH_TIME_FOREVER, 0);
    dispatch_source_set_event_handler(expirationTimer, ^{
        // quando o timer dispara: apresentar prompt
        extern void promptForKey(void);
        promptForKey();
    });
    dispatch_resume(expirationTimer);
}

#pragma mark - Key validation

bool validateKeyAndDate(NSString *key, NSString *uuid) {
    if (!keyDatabase[key]) return false;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *storedUUID = [defaults stringForKey:@"uuid"];
    if (storedUUID && ![storedUUID isEqualToString:uuid]) return false;

    NSDate *firstUse = [defaults objectForKey:[NSString stringWithFormat:@"%@_date", key]];
    if (!firstUse) return false;

    NSInteger daysValid = [keyDatabase[key] integerValue];
    NSDate *expireDate = [firstUse dateByAddingTimeInterval:(daysValid * 86400)];
    NSDate *now = [NSDate date];
    NSTimeInterval seconds = [now timeIntervalSinceDate:firstUse];

    if (seconds <= (daysValid * 86400)) {
        // Agendar o timer para o momento exato da expiração
        scheduleExpirationTimerForDate(expireDate);
        return true;
    } else {
        // expirou
        return false;
    }
}

#pragma mark - Floating button

void showFloatingButton(void) {
    if (floatingWindow) return; // já mostrado

    dispatch_async(dispatch_get_main_queue(), ^{
        CGSize btnSize = CGSizeMake(64, 64);
        CGRect screen = UIScreen.mainScreen.bounds;
        CGRect frame = CGRectMake(screen.size.width - btnSize.width - 20, screen.size.height/2 - btnSize.height/2, btnSize.width, btnSize.height);

        // Criar uma pequena UIWindow para o botão flutuante (fica acima de tudo)
        floatingWindow = [[UIWindow alloc] initWithFrame:frame];
        floatingWindow.windowLevel = UIWindowLevelAlert + 1;
        floatingWindow.backgroundColor = [UIColor clearColor];
        floatingWindow.layer.cornerRadius = btnSize.width/2;
        floatingWindow.clipsToBounds = YES;
        floatingWindow.hidden = NO;

        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = floatingWindow.bounds;
        // Carrega imagem "r" do bundle (r.png ou asset named "r")
        UIImage *img = [UIImage imageNamed:@"r"];
        if (!img) {
            // fallback: icone simples
            UIGraphicsBeginImageContextWithOptions(btn.bounds.size, NO, 0);
            [[UIColor redColor] setFill];
            UIBezierPath *p = [UIBezierPath bezierPathWithOvalInRect:btn.bounds];
            [p fill];
            UIImage *circle = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            [btn setImage:circle forState:UIControlStateNormal];
        } else {
            [btn setImage:img forState:UIControlStateNormal];
            btn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        }

        // Pan gesture para arrastar
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:[NSValue valueWithPointer:(void *)NULL] action:NULL];
        // não usamos target/action direto por compatibilidade C; crie um handler via bloco no runtime:
        // Usaremos uma subclass simples via associated object é complexo aqui; em vez disso, use addTarget:action:
        // Utilizaremos método local através do container: configurar gesto com target = btn e action = selector
        pan = [[UIPanGestureRecognizer alloc] initWithTarget:btn action:@selector(handlePan:)];
        [btn addGestureRecognizer:pan];

        // Botão tap abre mini-panel
        [btn addTarget:[NSValue valueWithPointer:(void *)NULL] action:NULL forControlEvents:UIControlEventTouchUpInside];
        // Em vez disso, adicionar um recognizer de tap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:floatingWindow action:@selector(handleTap:)];
        [btn addGestureRecognizer:tap];

        // Adiciona btn à window
        [floatingWindow addSubview:btn];

        // Expor métodos via category no runtime (simples helpers)
        // Para minimizar boilerplate, associamos blocos ao botão via objc_setAssociatedObject e selectors
        // Implementações concretas abaixo (via class_addMethod)
        Class btnClass = object_getClass(btn);

        // handlePan:
        void (^panBlock)(id, UIPanGestureRecognizer *) = ^(id selfBtn, UIPanGestureRecognizer *gesture) {
            UIWindow *win = (UIWindow *)selfBtn.window;
            CGPoint trans = [gesture translationInView:UIScreen.mainScreen.coordinateSpace];
            CGPoint center = win.center;
            center.x += trans.x;
            center.y += trans.y;

            // permitir parcialmente fora da tela (até 60% do botão)
            CGFloat halfW = CGRectGetWidth(win.bounds)/2.0;
            CGFloat leftLimit = -halfW * 1.2;
            CGFloat rightLimit = UIScreen.mainScreen.bounds.size.width + halfW * 1.2;
            CGFloat topLimit = halfW;
            CGFloat bottomLimit = UIScreen.mainScreen.bounds.size.height - halfW;
            center.x = fmax(leftLimit, fmin(center.x, rightLimit));
            center.y = fmax(topLimit, fmin(center.y, bottomLimit));

            win.center = center;
            [gesture setTranslation:CGPointZero inView:UIScreen.mainScreen.coordinateSpace];

            if (gesture.state == UIGestureRecognizerStateEnded) {
                // se arrastado muito para fora, manter parcialmente fora (efeito "esconder")
                CGFloat threshold = 0.6 * CGRectGetWidth(win.bounds);
                if (win.frame.origin.x < -threshold || win.frame.origin.x > UIScreen.mainScreen.bounds.size.width - CGRectGetWidth(win.bounds) + threshold) {
                    // opcional: reduzir alpha
                    win.alpha = 0.6;
                } else {
                    win.alpha = 1.0;
                }
            }
        };
        IMP impPan = imp_implementationWithBlock(panBlock);
        class_addMethod(btnClass, @selector(handlePan:), impPan, "v@:@");

        // handleTap:
        void (^tapBlock)(id, UITapGestureRecognizer *) = ^(id selfWin, UITapGestureRecognizer *gesture) {
            // apresentar mini painel com título e dois botões (Discord / TikTok)
            UIAlertController *mini = [UIAlertController alertControllerWithTitle:@"ramoss4m - discord: tiktok:"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction *discord = [UIAlertAction actionWithTitle:@"Abrir Discord" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *u = [NSURL URLWithString:@"https://discord.gg/Qr6fENhzG8"];
                if ([[UIApplication sharedApplication] canOpenURL:u]) {
                    [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
                }
            }];
            UIAlertAction *tiktok = [UIAlertAction actionWithTitle:@"Abrir TikTok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL *u = [NSURL URLWithString:@"https://www.tiktok.com/@ramoss4m"];
                if ([[UIApplication sharedApplication] canOpenURL:u]) {
                    [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
                }
            }];
            UIAlertAction *close = [UIAlertAction actionWithTitle:@"Fechar" style:UIAlertActionStyleCancel handler:nil];

            [mini addAction:discord];
            [mini addAction:tiktok];
            [mini addAction:close];

            // Apresentar na root VC atual
            UIWindow *keyW = UIApplication.sharedApplication.keyWindow;
            UIViewController *root = keyW.rootViewController;
            if (root.presentedViewController) {
                [root.presentedViewController presentViewController:mini animated:YES completion:nil];
            } else {
                [root presentViewController:mini animated:YES completion:nil];
            }
        };
        IMP impTap = imp_implementationWithBlock(tapBlock);
        class_addMethod(object_getClass(floatingWindow), @selector(handleTap:), impTap, "v@:@");

    });
}

#pragma mark - Prompt for key (bloqueante até key válida)

void promptForKey(void);

void ensureFloatingExists() {
    dispatch_async(dispatch_get_main_queue(), ^{
        showFloatingButton();
    });
}

__attribute__((constructor))
static void initialize() {
    keyDatabase = loadKeys();
    NSString *uuid = getUUID();
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *savedKey = [defaults stringForKey:@"key"];

    // Registrar observer para quando o app voltar a ser ativo -> validar expiração imediatamente
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        NSString *currentKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"key"];
        if (!currentKey || !validateKeyAndDate(currentKey, getUUID())) {
            // Se não tem key válida, mostrar prompt
            promptForKey();
        }
        // garantir que flutuante exista
        ensureFloatingExists();
    }];

    // Mostrar prompt imediatamente se não tem key válida
    dispatch_async(dispatch_get_main_queue(), ^{
        ensureFloatingExists();
        if (!savedKey || !validateKeyAndDate(savedKey, uuid)) {
            promptForKey();
        }
    });
}

void promptForKey() {
    if (isPromptShowing) return;
    isPromptShowing = true;

    cancelExpirationTimer(); // evita timers concorrentes até validar

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    UIViewController *rootVC = window.rootViewController;

    if (!rootVC) {
        // tentar novamente em breve
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
        textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
    }];

    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Verificar"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
        NSString *inputKey = alert.textFields.firstObject.text;
        NSString *uuid = getUUID();

        if (inputKey && keyDatabase[inputKey]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:inputKey forKey:@"key"];
            [defaults setObject:uuid forKey:@"uuid"];
            [defaults setObject:[NSDate date] forKey:[NSString stringWithFormat:@"%@_date", inputKey]];
            [defaults synchronize];
            isPromptShowing = false;

            // Agendar timer de expiração com base na data agora + daysValid
            NSDate *expireDate = [[NSDate date] dateByAddingTimeInterval:([keyDatabase[inputKey] integerValue] * 86400)];
            scheduleExpirationTimerForDate(expireDate);

        } else {
            // chave inválida -> reapresenta até acertar
            isPromptShowing = false;
            promptForKey();
        }
    }];

    UIAlertAction *discordAction = [UIAlertAction actionWithTitle:@"Discord"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
        NSURL *discordURL = [NSURL URLWithString:@"https://discord.gg/Qr6fENhzG8"];
        if ([[UIApplication sharedApplication] canOpenURL:discordURL]) {
            [[UIApplication sharedApplication] openURL:discordURL options:@{} completionHandler:nil];
        }
        // Reapresentar o prompt ao voltar
        isPromptShowing = false;
        // o UIApplicationDidBecomeActiveNotification cuidará de revalidar e reabrir
    }];

    [alert addAction:discordAction];
    [alert addAction:confirm];

    dispatch_async(dispatch_get_main_queue(), ^{
        // usar rootVC visível para apresentar
        UIViewController *presenting = rootVC;
        while (presenting.presentedViewController) presenting = presenting.presentedViewController;
        [presenting presentViewController:alert animated:YES completion:nil];
    });
}
