#import "CYLSearchDemoMenuViewController.h"
#import "CYLSearchExampleViewController.h"
#import <CYLSearchViewController/CYLSearchPlaceholderView.h>
#import <CYLSearchViewController/CYLSearchResources.h>

static NSString *CYLDemoText(NSString *key)
{
    return [CYLSearchResources localizedStringForKey:key];
}

@interface CYLSearchPlaceholderGalleryViewController : UITableViewController
@end

@implementation CYLSearchPlaceholderGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = CYLDemoText(@"demo.styles");
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return CYLSearchPlaceholderStyleCount + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == CYLSearchPlaceholderStyleCount ? 3 : 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == CYLSearchPlaceholderStyleCount) return CYLDemoText(@"demo.custom");
    return [CYLSearchPlaceholderView imageNameForStyle:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CYLDemoOption"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CYLDemoOption"];
    NSArray<NSString *> *messages = @[@"placeholder.empty", @"placeholder.search", @"placeholder.error", @"placeholder.network"];
    NSArray<NSString *> *custom = @[@"demo.custom.textOnly", @"demo.custom.imageOnly", @"demo.custom.both"];
    cell.textLabel.text = CYLDemoText(indexPath.section == CYLSearchPlaceholderStyleCount ? custom[indexPath.row] : messages[indexPath.row]);
    if (indexPath.section == CYLSearchPlaceholderStyleCount) {
        cell.imageView.image = indexPath.row == 0
            ? [[CYLSearchResources imageNamed:@"CYLSearchNoResults"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
            : [UIImage systemImageNamed:@"heart.fill"];
    } else {
        UIImage *image = [CYLSearchResources imageNamed:[CYLSearchPlaceholderView imageNameForStyle:indexPath.section]];
        cell.imageView.image = indexPath.section == CYLSearchPlaceholderStyleEmpty ? image : [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    cell.imageView.tintColor = UIColor.secondaryLabelColor;
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CYLSearchPlaceholderView *placeholder;
    if (indexPath.section < CYLSearchPlaceholderStyleCount) {
        placeholder = [[CYLSearchPlaceholderView alloc] initWithStyle:indexPath.section message:indexPath.row];
    } else if (indexPath.row == 0) {
        placeholder = [[CYLSearchPlaceholderView alloc] initWithStyle:CYLSearchPlaceholderStyleNoResults text:CYLDemoText(@"demo.custom.text")];
    } else {
        UIImage *image = [UIImage systemImageNamed:@"heart.fill"];
        if (indexPath.row == 1) {
            placeholder = [[CYLSearchPlaceholderView alloc] initWithImage:image message:CYLSearchPlaceholderMessageNetwork];
        } else {
            placeholder = [[CYLSearchPlaceholderView alloc] initWithImage:image text:CYLDemoText(@"demo.custom.text")];
        }
        placeholder.imageView.tintColor = UIColor.systemPinkColor;
    }
    UIViewController *detail = [UIViewController new];
    detail.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    detail.view.backgroundColor = UIColor.systemBackgroundColor;
    placeholder.frame = detail.view.bounds;
    placeholder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [detail.view addSubview:placeholder];
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

@implementation CYLSearchDemoMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = CYLDemoText(@"demo.title");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CYLDemoMenu"];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CYLDemoMenu"];
    cell.textLabel.text = CYLDemoText(indexPath.row == 0 ? @"demo.reproduction" : @"demo.styles");
    cell.textLabel.numberOfLines = 0;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *controller;
    if (indexPath.row == 0) {
        CYLSearchExampleDataSource *source = [CYLSearchExampleDataSource new];
        controller = [[CYLSearchExampleViewController alloc] initWithSearchDataSource:source refreshProvider:source];
    } else {
        controller = [[CYLSearchPlaceholderGalleryViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    [self.navigationController pushViewController:controller animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
