#import "CYLSearchResources.h"

@implementation CYLSearchResources

+ (NSBundle *)resourceBundle
{
    static NSBundle *resourceBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSBundle *> *containers = @[[NSBundle bundleForClass:self], NSBundle.mainBundle];
        for (NSBundle *container in containers) {
            NSURL *url = [container URLForResource:@"CYLSearchViewController" withExtension:@"bundle"];
            resourceBundle = url ? [NSBundle bundleWithURL:url] : nil;
            if (resourceBundle) break;
        }
        if (!resourceBundle) NSLog(@"CYLSearchViewController: resource bundle not found.");
    });
    return resourceBundle;
}

+ (UIImage *)imageNamed:(NSString *)name
{
    NSBundle *bundle = self.resourceBundle;
    UIImage *image = bundle ? [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil] : nil;
    if (!image) NSLog(@"CYLSearchViewController: resource image '%@' not found.", name);
    return image;
}

+ (NSString *)localizedStringForKey:(NSString *)key
{
    return [self localizedStringForKey:key language:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key language:(NSString *)language
{
    NSBundle *bundle = self.resourceBundle;
    if (!bundle) return key;
    NSArray<NSString *> *preferences = language.length ? @[language] : NSLocale.preferredLanguages;
    NSString *resolved = [NSBundle preferredLocalizationsFromArray:bundle.localizations forPreferences:preferences].firstObject ?: @"en";
    NSString *path = [bundle pathForResource:resolved ofType:@"lproj"];
    NSBundle *languageBundle = path ? [NSBundle bundleWithPath:path] : nil;
    NSString *value = [languageBundle localizedStringForKey:key value:nil table:@"CYLSearchViewController"];
    if (!value || [value isEqualToString:key]) {
        NSString *englishPath = [bundle pathForResource:@"en" ofType:@"lproj"];
        NSBundle *english = englishPath ? [NSBundle bundleWithPath:englishPath] : nil;
        value = [english localizedStringForKey:key value:nil table:@"CYLSearchViewController"];
    }
    if (!value || [value isEqualToString:key]) {
        NSLog(@"CYLSearchViewController: localization key '%@' not found.", key);
        return key;
    }
    return value;
}

@end
