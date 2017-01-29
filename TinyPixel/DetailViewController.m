//
//  DetailViewController.m
//  TinyPixel
//
//  Created by wanghuiyong on 29/01/2017.
//  Copyright © 2017 Personal Organization. All rights reserved.
//

#import "DetailViewController.h"
#import "TinyPixUtils.h"
#import "TinyPixView.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet TinyPixView *pixView;

@end

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.pixView.document = self.detailItem;
        NSLog(@"get the document");
        [self.pixView setNeedsDisplay];
        NSLog(@"need to display");
    } else {
        NSLog(@"not good");
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"show Detail");
    [self configureView];
    [self updateTintColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSettingsChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)onSettingsChanged:(NSNotification *)notification {
    [self updateTintColor];
}

- (void)updateTintColor {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger selectedColorIndex = [prefs integerForKey:@"selectedColorIndex"];
    UIColor *tintColor = [TinyPixUtils getTintColorForIndex:selectedColorIndex];
    self.pixView .tintColor = tintColor;
    [self.pixView setNeedsDisplay];
    NSLog(@"color updated");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIDocument *doc = self.detailItem;
    [doc closeWithCompletionHandler:nil];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    NSLog(@"setDetailItem called, %@", newDetailItem);
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}

@end
