//
//  BrowserViewController.m
//  FileBrowserPCloud
//
//  Created by Genislav Hristov on 5/15/14.
//  Copyright (c) 2014 Genislav Hristov. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "BrowserViewController.h"
#import "GrandFinalleViewController.h"

@interface BrowserViewController ()<NSURLConnectionDataDelegate> {
    NSMutableData *_responseData;
    
    NSArray *_contents;
    NSNumber *_folderID;
    
    NSURLConnection *_connection;
    NSURLConnection *_videoLinkConnection;
    NSURLConnection *_audioLinkConnection;
}

@end

@implementation BrowserViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithFolderID:(NSNumber *)fID
{
	self = [super initWithNibName:nil bundle:nil];
	if (self) {
		_folderID = fID;
	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self listFolder];
}

- (void)listFolder
{
    NSString *urlString = @"http://api.pcloud.com/listfolder?auth=s8CY3yWHPrbZkMdkZCBMKaslperhtqkNKf4kFQFIpJrzk&folderid=";
    
    urlString = [NSString stringWithFormat:@"%@%@", urlString, _folderID.stringValue];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    _responseData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"receiving data %@", data);
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"%@",[error description]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:_responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"%@", res);
    
    if (_connection == connection) {
        NSDictionary *metaData = [res objectForKey:@"metadata"];
        _contents = [metaData objectForKey:@"contents"];
        self.title = [metaData[@"name"] isEqualToString:@"/"] ? @"Root" : metaData[@"name"];
    } else if (_videoLinkConnection == connection) {
        NSLog(@"Callback from video link request");
        NSArray *hosts = res[@"hosts"];
        NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:hosts[0] path:res[@"path"]];
        
        NSLog(@"%@", url);
        
        MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        
        [self presentMoviePlayerViewControllerAnimated:vc];
    } else if (_audioLinkConnection == connection) {
        NSLog(@"Callback from audi link request");
        NSArray *hosts = res[@"hosts"];
        NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:hosts[0] path:res[@"path"]];
        
        NSLog(@"%@", url);
        
        MPMoviePlayerViewController *vc = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
        
        [self presentMoviePlayerViewControllerAnimated:vc];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contents count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    NSDictionary *current = _contents[indexPath.row];
    cell.textLabel.text = current[@"name"];
    
    if ([current[@"isfolder"] integerValue] == 1) {
        cell.imageView.image = [UIImage imageNamed:@"folder.jpg"];
    } else {
        cell.imageView.image = [UIImage imageNamed:@"file.jpg"];
    }
	
	return cell;
}

/*
 1 - image
 2 - video
 3 - audio
 4 - document
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedObject = _contents[indexPath.row];
    
    if ([[selectedObject objectForKey:@"isfolder"] integerValue] == 1) {
        BrowserViewController *folderViewController = [[BrowserViewController alloc] initWithFolderID:[selectedObject objectForKey:@"folderid"]];

        [self.navigationController pushViewController:folderViewController animated:YES];
    } else {
        //this is file
        //need to check file type
        if ([selectedObject[@"category"] integerValue] == 2) {
            //create request for video link
            NSLog(@"selected file ids is %@", selectedObject[@"fileid"]);
            [self getVideoLinkWithFileID:selectedObject[@"fileid"]];
        } else if ([selectedObject[@"category"] integerValue] == 3) {
            //create request for audio link
             NSLog(@"selected file ids is %@", selectedObject[@"fileid"]);
            [self getFileLinkWithFileID:selectedObject[@"fileid"]];
        }
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)getVideoLinkWithFileID:(NSNumber *)fileID
{
    NSString *getVideoLinkRequestString = [NSString
                                           stringWithFormat:@"http://api.pcloud.com/gethlslink?auth=s8CY3yWHPrbZkMdkZCBMKaslperhtqkNKf4kFQFIpJrzk&vbitrate=640&abitrate=40&resolution=640x480&fileid=%@", fileID.stringValue];
    
    NSURL *url = [NSURL URLWithString:getVideoLinkRequestString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _videoLinkConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)getFileLinkWithFileID:(NSNumber *)fileID
{
    NSString *getFileLinkRequestString = [NSString stringWithFormat:@"http://api.pcloud.com/getfilelink?auth=s8CY3yWHPrbZkMdkZCBMKaslperhtqkNKf4kFQFIpJrzk&fileid=%@", fileID.stringValue];
    
    NSURL *url = [NSURL URLWithString:getFileLinkRequestString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    _audioLinkConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
	btn.frame = CGRectMake(0.0f, 0.0f, 44.0f, 44.0f);
	[btn addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)didTapButton:(UIButton *)sender
{
	[self presentViewController:[[GrandFinalleViewController alloc] init] animated:YES completion:nil];
}

@end
