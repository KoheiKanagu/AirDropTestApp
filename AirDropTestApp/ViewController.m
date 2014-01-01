//
//  ViewController.m
//  AirDropTestApp
//
//  Created by Kohei on 2014/01/01.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    usersArray = [[NSMutableArray alloc]init];

    srand((unsigned)time(NULL));
    NSString *name = [NSString stringWithFormat:@"User%d", rand()];
    
    MCPeerID *peer = [[MCPeerID alloc]initWithDisplayName:name];
    mySession = [[MCSession alloc]initWithPeer:peer];
    [mySession setDelegate:self];
    
    myAssistant = [[MCAdvertiserAssistant alloc]initWithServiceType:@"Hoge"
                                                      discoveryInfo:nil
                                                            session:mySession];
    [myAssistant start];
}


-(IBAction)reloadButton:(id)sender
{
    MCBrowserViewController *bView = [[MCBrowserViewController alloc]initWithServiceType:@"Hoge"
                                                                                 session:mySession];
    
    [bView setDelegate:self];
    
    [self presentViewController:bView
                       animated:YES
                     completion:nil];
}


-(BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"%@", peerID);
    return YES;
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}



#pragma mark -
-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch(state){
            case MCSessionStateConnected:
                NSLog(@"Connected : %@", peerID.displayName);
                
                [usersArray addObject:session];
                break;
                
            case MCSessionStateConnecting:
                NSLog(@"Connecting : %@", peerID.displayName);
                break;
                
            case MCSessionStateNotConnected:
                [usersArray removeObject:session];
                NSLog(@"NotConnected : %@", peerID.displayName);
                break;
        }
        [self.tableView reloadData];
    });
}



-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSDictionary *dic;
    
    switch(buttonIndex){
        case 0:
            NSLog(@"close");
            return;
            break;
            
        case 1: //Text
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   @"TestData", @"data",
                   @"text", @"type", nil];
            break;
            
        case 2:{ //URL
            NSURL *url = [NSURL URLWithString:@"http://dev.classmethod.jp/references/ios-multipeer-apiusage/"];
            dic = [NSDictionary dictionaryWithObjectsAndKeys:
                   url, @"data",
                   @"url", @"type", nil];
            break;
        }
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    
    [self sendTestData:[usersArray objectAtIndex:alertView.tag]
              sendData:data];
}


-(void)sendTestData:(MCSession *)settion sendData:(NSData *)data
{
    NSError *error;
    [mySession sendData:data
                toPeers:@[settion]
               withMode:MCSessionSendDataReliable
                  error:&error];
    
    if(error){
        NSLog(@"%@", error);
    }
}


-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hogehoge:data];
    });
}


-(void)hogehoge:(NSData *)data
{
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if([[dic objectForKey:@"type"] isEqualToString:@"text"]){
        NSString *string = [dic objectForKey:@"data"];
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@""
                                                    message:string
                                                   delegate:nil
                                          cancelButtonTitle:@"閉じる"
                                          otherButtonTitles:nil, nil];
        [av show];
    }
    
    if([[dic objectForKey:@"type"] isEqualToString:@"url"]){
        NSURL *url = [dic objectForKey:@"data"];
        [[UIApplication sharedApplication] openURL:url];
    }
}


#pragma mark -
#pragma mark Table

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didReceiveStream");
    });
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didStartReceiving");
    });
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"didFinishReceiving");
    });
}









-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [usersArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    MCSession *settion = [usersArray objectAtIndex:indexPath.row];
    cell.textLabel.text = settion.myPeerID.displayName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"確認"
                                                message:nil
                                               delegate:self
                                      cancelButtonTitle:@"閉じる"
                                      otherButtonTitles:@"テキスト", @"URL", nil];
    av.tag = indexPath.row;
    [av show];
}

@end
