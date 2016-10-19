//
//  EditFriendsViewController.m
//
//  Created by Vincent Jardel on 20/05/2014.
//  Copyright (c) 2014 Jardel Vincent. All rights reserved.

#import "EditFriendsViewController.h"
#import "HomeViewController.h"
#import <MEAlertView.h>

@interface EditFriendsViewController ()
@end

@implementation EditFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentUser = [PFUser currentUser];
    self.allUsers = [[NSArray alloc] init];
    self.tableData = [[NSMutableArray alloc] init];
    self.searchResults = [[NSArray alloc] init];
    phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    self.friendRequestsWaiting = [NSMutableArray array];
    [self refreshWaitingFriend];
    
    
    [self getPersonOutOfAddressBook];
    
    [self refreshAllUsersAndLoadFriends];
    
    //UISearchController
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.scopeButtonTitles = @[];
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([[self.navigationController.viewControllers objectAtIndex:0] isKindOfClass:[HomeViewController class]]) {
        HomeViewController* viewController = (HomeViewController*)[self.navigationController.viewControllers objectAtIndex:0];
//        [viewController reloadFriend];
    }
}

- (void)dealloc {
    [self.searchController.view removeFromSuperview];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if (self.segment.selectedSegmentIndex == 0) {
        return 1;
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        return (self.searchResults.count > 0 ? 1 : [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count]);
        return 1;
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        return 1;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.segment.selectedSegmentIndex == 1) {
        BOOL showSection = [[self.sectionedPersonName objectAtIndex:section] count] != 0;
        // Only show the section title if there are rows in the section
        return showSection ? 23 : 0;
    }
    
    return 23;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    /* Section header is in 0th index... */
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 18)];
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, tableView.frame.size.width, 18)];
    [label setFont:[UIFont boldSystemFontOfSize:12]];
    NSString *string;
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorChillin]];
    
    if (self.segment.selectedSegmentIndex == 0) {
        string = @"Liste d'amis";
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        BOOL showSection = [[self.sectionedPersonName objectAtIndex:section] count] != 0;
        string = (self.searchResults.count > 0 ? Localized(@"SearchFriend") : (showSection) ? [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section] : nil);
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        string = @"Classement";
    }
    
    [label setText:string];
    
    return view;
}

- (IBAction)segmentedControlIndexChanged {
    if (self.segment.selectedSegmentIndex == 0) {
        [self loadFriends:NO];
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        [self loadFriends:NO];
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        [self loadFriends:NO];
    }
    
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (self.segment.selectedSegmentIndex == 0) {
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        return (self.searchResults.count > 0 ? nil : [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles]);
    }
    else if (self.segment.selectedSegmentIndex == 2) {
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index {
    return (self.searchResults.count > 0 ? 0 : [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index]);
}


- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
    if (self.segment.selectedSegmentIndex == 0) {
        return (self.searchResults.count > 0 ? [self.searchResults count] : [self.allUsers count]);
    }
    
    else if (self.segment.selectedSegmentIndex == 1) {
        return (self.searchResults.count > 0 ? [self.searchResults count] : [[self.sectionedPersonName objectAtIndex:section] count]);
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        return (self.searchResults.count > 0 ? [self.searchResults count] : [self.friends count]);
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (self.segment.selectedSegmentIndex == 0) {
        NSArray *sourceData = (self.searchResults.count > 0 ? self.searchResults : self.allUsers);
        PFUser *selectedUser = [sourceData objectAtIndex:indexPath.row];
        NSString *name = [[sourceData objectAtIndex:indexPath.row] valueForKey:@"surname"];
        if ([self isFriend:selectedUser]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        cell.textLabel.text = name;
        cell.detailTextLabel.text = nil;
    }
    
    else if (self.segment.selectedSegmentIndex == 1) {
        NSArray *sourceData = (self.searchResults.count > 0 ? self.searchResults : [self.sectionedPersonName objectAtIndex:indexPath.section]);
        Person *person = [sourceData objectAtIndex:indexPath.row];
        cell.textLabel.text = person.fullName;
        cell.detailTextLabel.text = nil;
        
        if ([[self.allUsers valueForKey:@"phone"] containsObject:person.number]) {
            for (PFUser *user in self.allUsers) {
                if ([self isFriend:user]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    else if (self.segment.selectedSegmentIndex == 2) {
        NSArray *sourceData = (self.searchResults.count > 0 ? self.searchResults : self.friends);
        cell.accessoryType = UITableViewCellAccessoryNone;
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"xp" ascending:NO];
        NSArray *sortDescriptors = [NSArray arrayWithObject:descriptor];
        sourceData = [sourceData sortedArrayUsingDescriptors:sortDescriptors];
        NSString *name = [[sourceData objectAtIndex:indexPath.row] valueForKey:@"surname"];
        NSString *experience = [[[sourceData objectAtIndex:indexPath.row] valueForKey:@"xp"] stringValue];
        NSString *bananaEmoji = @" \U0001F34C";
        
        cell.textLabel.text = [[NSString stringWithFormat:@"%ld. ", (long)indexPath.row+1
                                ] stringByAppendingString:name];
        cell.detailTextLabel.text = [experience stringByAppendingString:bananaEmoji];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.segment.selectedSegmentIndex == 0) {
        self.tableView.userInteractionEnabled = NO;
        PFUser *selected = (self.searchResults.count > 0 ? [self.searchResults objectAtIndex:indexPath.row] : [self.allUsers objectAtIndex:indexPath.row]);
        
        if ([self isFriend:selected]) {
            // Remove Friend
            MEAlertView *alertView = [[MEAlertView alloc] initWithTitle:@"Attention !" message:@"Êtes-vous sûr de vouloir supprimer cet ami(e) ?"];
            [alertView setCancelButtonWithTitle:@"Annuler" onTapped:^{
                self.tableView.userInteractionEnabled = YES;
            }];
            [alertView addOtherButtonWithTitle:@"Oui" onTapped:^{
                [self removeFriend:selected withCell:cell];
            }];
            [alertView show];
        } else {
            // Not friend
            [self checkSelectedUserRequest:selected forIndexPath:indexPath forCell:cell];
        }
    }
    
    //CONTACT
    else if (self.segment.selectedSegmentIndex == 1) {
        NSArray *sourceData = (self.searchResults.count > 0 ? self.searchResults : [self.sectionedPersonName objectAtIndex:indexPath.section]);
        Person *person = [sourceData objectAtIndex:indexPath.row];
        NSLog(@"%@", person.number);
        
        NSMutableArray *realResult   = [NSMutableArray new];
        [self.tableData enumerateObjectsUsingBlock:^(Person *obj, NSUInteger idx, BOOL *stop) {
            self.result = [self.allUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"phone", obj.number]];
            if (self.result.count) {
                [realResult addObjectsFromArray:self.result];
            }
            
            for (PFUser *user in self.result) {
                if ([[self.result valueForKey:@"phone"] containsObject:person.number]) {
                    self.selectedObjectId = user.objectId;
                    self.selectedUser = user;
                }
            }
        }];
        
        if (cell.accessoryType == UITableViewCellAccessoryDisclosureIndicator) {
            // Not friend
            [self checkSelectedUserRequest:self.selectedUser forIndexPath:indexPath forCell:cell];
            self.tableView.userInteractionEnabled = YES;
        }
        else if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            // Already friend
            self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check"]];
            self.hud.mode = MBProgressHUDModeCustomView;
            self.hud.labelText = @"Deleted";
            
            [PFCloud callFunctionInBackground:@"removeFriend" withParameters:@{@"friendRequest" : self.selectedUser.objectId} block:^(id object, NSError *error) {
                if (!error) {
                    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
                        if (succeeded) {
                            cell.accessoryType = UITableViewCellAccessoryNone;
                            [self.hud removeFromSuperview];
                            [self loadFriends:NO];
                            self.tableView.userInteractionEnabled = YES;
                        }
                    }];
                } else {
                    NSLog(@"error");
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again !" message:@"Check your network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    self.tableView.userInteractionEnabled = YES;
                }
            }];
        }
    }
    
    //AMIS EN ATTENTE
    else if (self.segment.selectedSegmentIndex == 2) {
        //        [self addFriend:indexPath forCell:cell];
    }
    
    [self.tableView reloadData];
}


- (void)getPersonOutOfAddressBook {
    //1
    CFErrorRef error = nil;
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSLog(@"Succesful.");
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    NSLog(@"granted");
                    // First time, add contacts.
                    NSMutableSet *foundIDs = [NSMutableSet set];
                    NSArray *allContacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
                    
                    for (id record in allContacts) {
                        ABRecordRef contactPerson = (__bridge ABRecordRef)record;
                        ABRecordID recordId = ABRecordGetRecordID(contactPerson);
                        if (![foundIDs containsObject:@(recordId)]) {
                            Person *person = [[Person alloc] init];
                            
                            // Get name
                            
                            person.firstName = CFBridgingRelease(ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty)) ?: @"";
                            person.lastName = CFBridgingRelease(ABRecordCopyValue(contactPerson, kABPersonLastNameProperty)) ?: @"";
                            person.fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
                            
                            // Get phones
                            
                            ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                            for (NSUInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
                                
                                if ([CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) hasPrefix:@"07"] || [CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) hasPrefix:@"06"] ||[CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) hasPrefix:@"+33"]) {
                                    NSError *anError = nil;
                                    NBPhoneNumber *myNumber = [phoneUtil parse:[CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) mutableCopy]
                                                                 defaultRegion:@"FR" error:&anError];
                                    NSString *phoneNumber = [NSString stringWithFormat:@"%@", [phoneUtil format:myNumber
                                                                                                   numberFormat:NBEPhoneNumberFormatNATIONAL
                                                                                                          error:&anError]];
                                    person.number = phoneNumber;
                                }
                            }
                            CFRelease(phones);
                            
                            // Add the `Person` record
                            [self.tableData addObject:person];
                            
                            // Add the ID for this person (and all linked contacts) to our set of `foundIDs`
                            
                            NSArray *linkedPeople = CFBridgingRelease(ABPersonCopyArrayOfAllLinkedPeople(contactPerson));
                            if (linkedPeople) {
                                for (id record in linkedPeople) {
                                    [foundIDs addObject:@(ABRecordGetRecordID((__bridge ABRecordRef)record))];
                                }
                            } else {
                                [foundIDs addObject:@(recordId)];
                            }
                        }
                    }
                    
                    CFRelease(addressBook);
                    
                    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
                    [self.tableData sortUsingDescriptors:@[descriptor]];
                    self.sectionedPersonName = [self partitionObjects:self.tableData collationStringSelector:@selector(fullName)];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                        [cantAddContactAlert show];
                        // User denied access.Display an alert telling user that they must allow access to proceed to the "invites" page.
                    });
                }
            });
        }
        
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            // The user has previously given access, add all the user's contacts to array.
            NSLog(@"kABAuthorizationStatusAuthorized");
            NSMutableSet *foundIDs = [NSMutableSet set];
            NSArray *allContacts = CFBridgingRelease(ABAddressBookCopyArrayOfAllPeople(addressBook));
            
            for (id record in allContacts) {
                ABRecordRef contactPerson = (__bridge ABRecordRef)record;
                ABRecordID recordId = ABRecordGetRecordID(contactPerson);
                if (![foundIDs containsObject:@(recordId)]) {
                    Person *person = [[Person alloc] init];
                    
                    // Get name
                    person.firstName = CFBridgingRelease(ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty)) ?: @"";
                    person.lastName = CFBridgingRelease(ABRecordCopyValue(contactPerson, kABPersonLastNameProperty)) ?: @"";
                    person.fullName = [NSString stringWithFormat:@"%@ %@", person.firstName, person.lastName];
                    
                    // Get phones
                    ABMultiValueRef phones = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
                    for (NSUInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
                        
                        if ([CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) hasPrefix:@"07"] || [CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) hasPrefix:@"06"] ||[CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) hasPrefix:@"+33"]) {
                            NSError *anError = nil;
                            NBPhoneNumber *myNumber = [phoneUtil parse:[CFBridgingRelease(ABMultiValueCopyValueAtIndex(phones, j)) mutableCopy]
                                                         defaultRegion:@"FR" error:&anError];
                            NSString *phoneNumber = [NSString stringWithFormat:@"%@", [phoneUtil format:myNumber
                                                                                           numberFormat:NBEPhoneNumberFormatNATIONAL
                                                                                                  error:&anError]];
                            person.number = phoneNumber;
                        }
                    }
                    
                    CFRelease(phones);
                    
                    // Add the `Person` record
                    [self.tableData addObject:person];
                    
                    // Add the ID for this person (and all linked contacts) to our set of `foundIDs`
                    
                    NSArray *linkedPeople = CFBridgingRelease(ABPersonCopyArrayOfAllLinkedPeople(contactPerson));
                    if (linkedPeople) {
                        for (id record in linkedPeople) {
                            [foundIDs addObject:@(ABRecordGetRecordID((__bridge ABRecordRef)record))];
                        }
                    } else {
                        [foundIDs addObject:@(recordId)];
                    }
                }
            }
            
            CFRelease(addressBook);
            
            NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"fullName" ascending:YES];
            [self.tableData sortUsingDescriptors:@[descriptor]];
            self.sectionedPersonName = [self partitionObjects:self.tableData collationStringSelector:@selector(fullName)];
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) {
            NSLog(@"denied");
        }
        else {
            //9
            NSLog(@"ERROR!!!");
        }
    } else {
        NSLog(@"No AddressBook");
        UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Search by Contact" message: @"You must give the app permission in Parameter > Chillin" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
        [cantAddContactAlert show];
        // The user has previously denied access
        // Send an alert telling user that they must allow access to proceed to the "invites" page.
    }
}

- (NSArray *)partitionObjects:(NSArray *)array collationStringSelector:(SEL)selector {
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionCount = [[collation sectionTitles] count]; // Section count is take from sectionTitles and not sectionIndexTitles
    NSMutableArray *unsortedSections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    //create an array to hold the data for each section
    for(int i = 0; i < sectionCount; i++) {
        [unsortedSections addObject:[NSMutableArray array]];
    }
    
    // Put each object into a section
    for (id object in array) {
        NSInteger index = [collation sectionForObject:object collationStringSelector:selector];
        [[unsortedSections objectAtIndex:index] addObject:object];
    }
    
    NSMutableArray *sections = [NSMutableArray arrayWithCapacity:sectionCount];
    
    // Sort each section
    for (NSMutableArray *section in unsortedSections) {
        [sections addObject:[collation sortedArrayFromArray:section collationStringSelector:selector]];
    }
    
    return sections;
}

- (BOOL)isFriend:(PFUser *)user {
    for(PFUser *friend in self.friends) {
        if ([friend.objectId isEqualToString:user.objectId]) {
            return YES;
        }
    }
    return NO;
}

- (void)loadFriends:(BOOL)fromDeleteFriend {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    if (fromDeleteFriend) {
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_check"]];
        self.hud.mode = MBProgressHUDModeCustomView;
        self.hud.labelText = @"Deleted";
    } else {
        
    }
    self.friendsRelation = [self.currentUser relationForKey:@"friends"];
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"surname"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
            [self.hud removeFromSuperview];
        } else {
            self.friends = objects;
            [self.tableView reloadData];
            [self.hud removeFromSuperview];
            self.tableView.userInteractionEnabled = YES;
        }
    }];
}

- (void)refreshAllUsersAndLoadFriends {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    self.segment.userInteractionEnabled = NO;
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"surname"];
    //    [query whereKey:@"objectId" notEqualTo:self.currentUser.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            self.segment.userInteractionEnabled = YES;
            [self.hud removeFromSuperview];
        } else {
            self.allUsers = objects;
            self.friendsRelation = [self.currentUser relationForKey:@"friends"];
            PFQuery *query = [self.friendsRelation query];
            [query orderByAscending:@"surname"];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (error) {
                    NSLog(@"Error %@ %@", error, [error userInfo]);
                    [self.hud removeFromSuperview];
                    self.segment.userInteractionEnabled = YES;
                } else {
                    self.friends = objects;
                    [self.tableView reloadData];
                    [self.hud removeFromSuperview];
                    self.segment.userInteractionEnabled = YES;
                }
            }];
        }
    }];
}

- (void)addFriend:(NSIndexPath *)indexPath forCell:(UITableViewCell *)cell {
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeIndeterminate;
    // Get the selected request
    PFObject *friendRequest = [self.friendRequestsWaiting objectAtIndex:indexPath.row];
    // Get the user the request is from
    PFUser *fromUser = [friendRequest objectForKey:@"from"];
    // Call the cloud function addFriendToFriendRelation which adds the current user to the from users friends:
    // We pass in the object id of the friendRequest as a parameter (you cant pass in objects, so we pass in the id)
    [PFCloud callFunctionInBackground:@"addFriendToFriendsRelation" withParameters:@{@"friendRequest" : friendRequest.objectId} block:^(id object, NSError *error) {
        
        if (!error) {
            // Add the fromuser to the currentUsers friends
            PFRelation *friendsRelation = [self.currentUser relationForKey:@"friends"];
            [friendsRelation addObject:fromUser];
            
            // Save the current user
            [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (succeeded) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    [self.friendRequestsWaiting removeObjectAtIndex:indexPath.row];
                    NSLog(@"succeed");
                    NSLog(@"%@", friendRequest);
                    
                    [friendRequest deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"Clean !");
                            [self.tableView reloadData];
                            [self.hud removeFromSuperview];
                        } else {
                            [self.hud removeFromSuperview];
                        }
                    }];
                } else {
                    [self.hud removeFromSuperview];
                }
                
            }];
        } else {
            [self.hud removeFromSuperview];
        }
    }];
}

- (void)checkSelectedUserRequest:(PFUser *)selectedUser forIndexPath:(NSIndexPath *)indexPath forCell:(UITableViewCell *)cell {
    // Check if selected user has already sent a request.
    PFQuery *checkSelectedUserRequest = [PFQuery queryWithClassName:@"FriendRequest"];
    [checkSelectedUserRequest whereKey:@"to" equalTo:self.currentUser];
    [checkSelectedUserRequest whereKey:@"from" equalTo: selectedUser];
    [checkSelectedUserRequest getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error) {
        if (!user) {
            [self sendFriendRequest:selectedUser];
        }
        else {
            [PFCloud callFunctionInBackground:@"addFriend" withParameters:@{@"friendRequest" : selectedUser.objectId} block:^(id object, NSError *error)
             {
                 if (!error) {
                     [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                         if (succeeded) {
                             [user deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                 if (succeeded) {
                                     [PFCloud callFunctionInBackground:@"pushFriendHasAccepted" withParameters:@{@"userId" : selectedUser.objectId} block:^(id object, NSError *error) {
                                         if (!error) {
                                             NSLog(@"YES");
                                         } else {
                                             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again !" message:@"Check your network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                             [alert show];
                                         }
                                     }];
                                     [self loadFriends:NO];
                                     
                                 }
                             }];
                         }
                     }];
                 } else  {
                     self.tableView.userInteractionEnabled = YES;
                 }
             }];
        }
    }];
}

- (void)sendFriendRequest:(PFUser *)selectedUser {
    // Request them
    PFObject *friendRequest = [PFObject objectWithClassName:@"FriendRequest"];
    friendRequest[@"from"] = self.currentUser;
    friendRequest[@"fromUsername"] = [self.currentUser objectForKey:@"surname"];
    //selected user is the user at the cell that was selected
    friendRequest[@"to"] = selectedUser;
    // set the initial status to pending
    friendRequest[@"status"] = @"pending";
    
    PFQuery *query = [PFQuery queryWithClassName:@"FriendRequest"];
    [query whereKey:@"from" equalTo:self.currentUser];
    [query whereKey:@"to" equalTo: selectedUser];
    [query countObjectsInBackgroundWithBlock:^(int object, NSError*error) {
        
        if (!error) {
            if (object == 0) {
                // Save & Send Request
                [friendRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Envoyée !" message:@"Demande d'ami envoyée" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        [alert show];
                        [self.hud removeFromSuperview];
                        self.tableView.userInteractionEnabled = YES;
                        [PFCloud callFunctionInBackground:@"pushAddFriendNotification" withParameters:@{@"userId" : selectedUser.objectId} block:^(id object, NSError *error) {
                            if (!error) {
                                NSLog(@"YES");
                            } else {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again !" message:@"Check your network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                [alert show];
                            }
                        }];
                    } else {
                        [self.hud removeFromSuperview];
                        self.tableView.userInteractionEnabled = YES;
                        // Error occurred
                    }
                }];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erreur" message:@"La demande d'ami est déjà envoyée" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                self.tableView.userInteractionEnabled = YES;
            }
        } else {
            
        }
    }];
}

- (void)removeFriend:(PFUser *)selectedUser withCell:(UITableViewCell *)cell {
    // Already friend
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PFCloud callFunctionInBackground:@"removeFriend" withParameters:@{@"friendRequest" : selectedUser.objectId} block:^(id object, NSError *error) {
        if (!error) {
            
            PFRelation *friendsRelation = [[PFUser currentUser] relationForKey:@"friends"];
            [friendsRelation removeObject:selectedUser];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                
                if (succeeded) {
                    // Refresh Relation
                    self.friendsRelation = [self.currentUser relationForKey:@"friends"];
                    PFQuery *query = [self.friendsRelation query];
                    [query orderByAscending:@"surname"];
                    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (error) {
                            NSLog(@"Error %@ %@", error, [error userInfo]);
                            [self.hud removeFromSuperview];
                            self.tableView.userInteractionEnabled = YES;
                        } else {
                            self.friends = objects;
                            [self.tableView reloadData];
                            [self.hud removeFromSuperview];
                            self.tableView.userInteractionEnabled = YES;
                            cell.accessoryType = UITableViewCellAccessoryNone;
                        }
                    }];
                }
                else {
                    NSLog(@"error");
                    [self.hud removeFromSuperview];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again !" message:@"Check your network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                    [alert show];
                    self.tableView.userInteractionEnabled = YES;
                }
            }];
        }
        else {
            NSLog(@"error");
            [self.hud removeFromSuperview];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Try Again !" message:@"Check your network" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            self.tableView.userInteractionEnabled = YES;
        }
    }];
}

- (void)refreshWaitingFriend {
    PFQuery *requestsToCurrentUser = [PFQuery queryWithClassName:@"FriendRequest"];
    [requestsToCurrentUser whereKey:@"to" equalTo:self.currentUser];
    [requestsToCurrentUser whereKey:@"status" equalTo:@"pending"];
    [requestsToCurrentUser findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //this property stores the data for the tableView
            self.friendRequestsWaiting = [NSMutableArray arrayWithArray:objects];
            //reload the table
            [self.tableView reloadData];
        } else {
            // Error occcurred
        }
    }];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText {
    NSPredicate *predicate;
    if (self.segment.selectedSegmentIndex == 0) {
        predicate = [NSPredicate predicateWithFormat:@"surname beginswith[c] %@", searchText];
        self.searchResults = [self.allUsers filteredArrayUsingPredicate:predicate];
    }
    else if (self.segment.selectedSegmentIndex == 1) {
        [self.tableData enumerateObjectsUsingBlock:^(Person *obj, NSUInteger idx, BOOL *stop) {
            __block NSPredicate *fullNamePredicate = [NSPredicate predicateWithFormat:@"fullName beginswith[c] %@", searchText];
            self.searchResults = [self.tableData filteredArrayUsingPredicate:fullNamePredicate];
        }];
        
    }
    else if (self.segment.selectedSegmentIndex == 2) {
        predicate = [NSPredicate predicateWithFormat:@"surname beginswith[c] %@", searchText];
        self.searchResults = [self.friends filteredArrayUsingPredicate:predicate];
    }
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}

@end
