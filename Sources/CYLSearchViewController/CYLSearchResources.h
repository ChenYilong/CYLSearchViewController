#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/*!
 * Resources are located in the Pod's bundle, not in the host app's assets.
 */
@interface CYLSearchResources : NSObject

/*!
 * Returns nil and logs an error if the bundle is missing.
 */
+ (nullable NSBundle *)resourceBundle;
+ (nullable UIImage *)imageNamed:(NSString *)name;
/*!
 * Uses the application's preferred languages and falls back to English.
 */
+ (NSString *)localizedStringForKey:(NSString *)key;
/*!
 * Resolves the closest supported language; nil uses preferred languages.
 */
+ (NSString *)localizedStringForKey:(NSString *)key language:(nullable NSString *)language;

@end

NS_ASSUME_NONNULL_END
