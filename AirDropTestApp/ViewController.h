//
//  ViewController.h
//  AirDropTestApp
//
//  Created by Kohei on 2014/01/01.
//  Copyright (c) 2014年 KoheiKanagu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface ViewController : UITableViewController <UINavigationBarDelegate, UINavigationControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate>
{
    NSMutableArray *usersArray;
    
    
    MCSession *mySession;
    MCAdvertiserAssistant *myAssistant;
}


-(IBAction)reloadButton:(id)sender;

@end
