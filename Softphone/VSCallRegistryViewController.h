//
//  VSCallRegistryViewController.h
//  Softphone
//
//  Created by Alex Gotev on 19/12/14.
//  Copyright (c) 2014 voismart. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSPaginatedTableViewController.h"
#import "VoiSmartWebServicesFactory.h"

@interface VSCallRegistryViewController : VSPaginatedTableViewController <VSPaginatedTableViewControllerDelegate,
                                                                          VoiSmartWebServiceDelegate>

@end
