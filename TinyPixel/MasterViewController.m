//
//  MasterViewController.m
//  TinyPixel
//
//  Created by wanghuiyong on 29/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "TinyPixDocument.h"
#import "TinyPixUtils.h"

@interface MasterViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *colorControl;	// 高亮颜色, 分段控件
@property (strong, nonatomic) NSArray *documentFilenames;				// 存储文档名称列表(完整路径)
@property (strong, nonatomic) TinyPixDocument *chosenDocument;			// 指向用户所选文档

//@property NSMutableArray *objects;

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    // 导航栏右侧加号按钮, 用于新建文档
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // 从用户默认设置中加载分段控件索引
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger selectedColorIndex = [prefs integerForKey:@"selectedColorIndex"];	// 首次执行不存在用户默认设置时返回0, 指定默认颜色为红色 
    
    // 设置分段控件颜色和选择的段
    self.colorControl.tintColor = [TinyPixUtils getTintColorForIndex:selectedColorIndex];
    [self.colorControl setSelectedSegmentIndex:selectedColorIndex];
    
    // 加载已有文档
    [self reloadFiles];
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}

// 使用加号按钮新建文档
- (void)insertNewObject:(id)sender {
    // 警告视图标题
    NSString *title = @"Choose File Name";
    NSString *msg = @"Enter a name for your new TinyPix document.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message: msg preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:nil];	// 添加文本框 
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *createAction = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = (UITextField *)alert.textFields[0];		// 获取文本框
        [self createFileNamed:textField.text];
        NSLog(@"you input: %@", textField.text);
    }];
    [alert addAction:cancelAction];
    [alert addAction:createAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)createFileNamed:(NSString *)fileName {
    // 生成文件URL
    NSString *trimmedFileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (trimmedFileName.length > 0) {
        NSString *targetName = [NSString stringWithFormat:@"%@.tinypix", trimmedFileName];
        NSURL *saveUrl = [self urlForFilename:targetName];
        
        // 新建文档实例(后台线程执行), 加载文档, 并转场到详细视图
        self.chosenDocument = [[TinyPixDocument alloc] initWithFileURL:saveUrl];
        [self.chosenDocument saveToURL:saveUrl forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"save document seccessed");
                [self reloadFiles];
                NSLog(@"segue start");
                [self performSegueWithIdentifier:@"masterToDetail" sender:self];	 // 初始化这个转场的对象指定为本身
                NSLog(@"segue end");
            } else {
                NSLog(@"failed to save document");
            }
        }];
    }
}

// 将指定文件名添加到 Documents 路径
- (NSURL *)urlForFilename:(NSString *)filename {
    // URL 类型的 Documents 路径
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *urls = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL *driectoryURL = urls[0];
    
    NSURL *fileURL = [driectoryURL URLByAppendingPathComponent:filename];
    return fileURL;
}

// 查找 Documents 目录中代表现存文档的文件
- (void)reloadFiles {
    // 字符串类型的 Documents 路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = paths[0];
    
    // 获取 Documents 目录下的所有文件
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *dirError;
    NSArray *files = [fm contentsOfDirectoryAtPath:path error:&dirError];
    if (!files) {
        NSLog(@"Error listing files in directory %@: %@", path, dirError);
    }
    NSLog(@"found files: %@", files);
    
    // 将文档按日期从新到旧顺序排列
    files = [files sortedArrayUsingComparator:^NSComparisonResult(id filename1, id filename2) {
        NSDictionary *attr1 = [fm attributesOfItemAtPath:[path stringByAppendingPathComponent:filename1] error:nil];
        NSDictionary *attr2 = [fm attributesOfItemAtPath:[path stringByAppendingPathComponent:filename2] error:nil];
        return [attr2[NSFileCreationDate] compare:attr1[NSFileCreationDate]];
    }];
    
    // 保存文档文件名
    self.documentFilenames = files;
    [self.tableView reloadData];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // 转场的目标控制器是详细视图控制器
    UINavigationController *destination = (UINavigationController *)segue.destinationViewController;
    DetailViewController *detailVC = (DetailViewController *)destination.topViewController;
    
    // 由上可知, 如果刚刚创建了一个新文档, 则 sender 是控制器本身, 并且 chosenDocument 属性已经设置好
    if (sender == self) {
        detailVC.detailItem = self.chosenDocument;
        NSLog(@"New File");
        // 由选择表中的某一样文档触发的转场
    } else {					// 不用判断 showDetail 标识符??? 怎么转过来的???
        // 生成选中文档的 URL
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *filename = self.documentFilenames[indexPath.row];
        NSURL *docUrl = [self urlForFilename:filename];
        // 新建文档类实例
        self.chosenDocument = [[TinyPixDocument alloc] initWithFileURL:docUrl];
        // 打开文档
        [self.chosenDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"load OK");
                detailVC.detailItem = self.chosenDocument;
            } else {
                NSLog(@"failed to load!");
            }
        }];
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documentFilenames count];	// 一个文件用一行表示
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    NSString *path = self.documentFilenames[indexPath.row];		// 该行的完整路径文件名
    cell.textLabel.text = path.lastPathComponent.stringByDeletingPathExtension;	// 该行文件名输出到表单元
    return cell;
}


#pragma mark - 操作方法

- (IBAction)chooseColor:(id)sender {
    // 分段控件索引值
    NSInteger selectedColorIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    
    // 设置高亮颜色, 应用在分段控件上
    self.colorControl.tintColor = [TinyPixUtils getTintColorForIndex:selectedColorIndex];
    
    // 将索引值保存在用户默认设置中
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:selectedColorIndex forKey:@"selectedColorIndex"];
    [prefs synchronize];
}

@end
