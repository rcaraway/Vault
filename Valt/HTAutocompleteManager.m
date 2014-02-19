//
//  HTAutocompleteManager.m
//  HotelTonight
//
//  Created by Jonathan Sibley on 12/6/12.
//  Copyright (c) 2012 Hotel Tonight. All rights reserved.
//

#import "HTAutocompleteManager.h"
#import "RCPasswordManager.h"

static HTAutocompleteManager *sharedManager;

@implementation HTAutocompleteManager
{
    NSMutableArray * titleList;
    NSMutableArray * usernameList;
    NSMutableArray * passwordList;
    NSMutableArray * urlList;
}

+(void)initialize
{
    sharedManager = [[HTAutocompleteManager alloc] init];
}

+ (HTAutocompleteManager *)sharedManager
{
	return sharedManager;
}

#pragma mark - HTAutocompleteTextFieldDelegate

- (NSString *)textField:(HTAutocompleteTextField *)textField
    completionForPrefix:(NSString *)prefix
             ignoreCase:(BOOL)ignoreCase
{
    if (textField.autocompleteType == RCAutocompleteTypeUsername)
    {
        return [self usernameAutoFillWithPrefix:prefix];
    }else if (textField.autocompleteType == RCAutoCompleteTypeEmailOnly){
        return [self emailOnlyAutoFillWithPrefix:prefix];
    }
    else if (textField.autocompleteType == RCAutocompleteTypeTitle)
    {
        static dispatch_once_t colorOnceToken;
        static NSArray * autoFillArray;
        dispatch_once(&colorOnceToken, ^{
            autoFillArray = [self prefilledTitles];
        });
        return [self autoFilledFromList:autoFillArray prefix:prefix ignoreCase:YES];
    }else if (textField.autocompleteType == RCAutocompleteTypeURL){
        return [self autoFillForURLForWithPrefix:prefix];
    }else if (textField.autocompleteType == RCAutocompleteTypePassword){
        NSArray * passwordListx = [self passwordList];
        return [self autoFilledFromList:passwordListx prefix:prefix ignoreCase:NO];
    }
    return @"";
}

-(NSString *)usernameAutoFillWithPrefix:(NSString *)prefix
{
    static dispatch_once_t onceToken;
    static NSArray *autocompleteArray;
    static NSArray * usernameArray;
    BOOL ignoreCase = YES;
    autocompleteArray = [self prefilledSites];
    usernameArray = [self usernameList];
    dispatch_once(&onceToken, ^
                  {

                  });
    
    // Check that text field contains an @
    NSRange atSignRange = [prefix rangeOfString:@"@"];
    if (atSignRange.location == NSNotFound)
    {
        return [self autoFilledFromList:usernameArray prefix:prefix ignoreCase:YES];
    }
    NSString *domainAndTLD = [prefix substringFromIndex:atSignRange.location];
    NSRange rangeOfDot = [domainAndTLD rangeOfString:@"."];
    if (rangeOfDot.location != NSNotFound)
    {
        return @"";
    }
    
    // Check that there aren't two @-signs
    NSArray *textComponents = [prefix componentsSeparatedByString:@"@"];
    if ([textComponents count] > 2)
    {
        return @"";
    }
    
    if ([textComponents count] > 1)
    {
        // If no domain is entered, use the first domain in the list
        if ([(NSString *)textComponents[1] length] == 0)
        {
            return [autocompleteArray objectAtIndex:0];
        }
        
        NSString *textAfterAtSign = textComponents[1];
        
        NSString *stringToLookFor;
        if (ignoreCase)
        {
            stringToLookFor = [textAfterAtSign lowercaseString];
        }
        else
        {
            stringToLookFor = textAfterAtSign;
        }
        
        for (NSString *stringFromReference in autocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    return @"";
}


-(NSString *)emailOnlyAutoFillWithPrefix:(NSString *)prefix
{
    static dispatch_once_t onceToken;
    static NSArray *autocompleteArray;
    static NSArray * usernameArray;
    BOOL ignoreCase = YES;
    autocompleteArray = [self prefilledSites];
    usernameArray = [self emailList];
    dispatch_once(&onceToken, ^
                  {
                      
                  });
    
    if (prefix.length == 0){
        if (usernameArray.count > 0){
            return usernameArray[0];
        }
        return nil;
    }
    
    // Check that text field contains an @
    NSRange atSignRange = [prefix rangeOfString:@"@"];
    if (atSignRange.location == NSNotFound)
    {
        return [self autoFilledFromList:usernameArray prefix:prefix ignoreCase:YES];
    }
    NSString *domainAndTLD = [prefix substringFromIndex:atSignRange.location];
    NSRange rangeOfDot = [domainAndTLD rangeOfString:@"."];
    if (rangeOfDot.location != NSNotFound)
    {
        return @"";
    }
    
    // Check that there aren't two @-signs
    NSArray *textComponents = [prefix componentsSeparatedByString:@"@"];
    if ([textComponents count] > 2)
    {
        return @"";
    }
    
    if ([textComponents count] > 1)
    {
        // If no domain is entered, use the first domain in the list
        if ([(NSString *)textComponents[1] length] == 0)
        {
            return [autocompleteArray objectAtIndex:0];
        }
        
        NSString *textAfterAtSign = textComponents[1];
        
        NSString *stringToLookFor;
        if (ignoreCase)
        {
            stringToLookFor = [textAfterAtSign lowercaseString];
        }
        else
        {
            stringToLookFor = textAfterAtSign;
        }
        
        for (NSString *stringFromReference in autocompleteArray)
        {
            NSString *stringToCompare;
            if (ignoreCase)
            {
                stringToCompare = [stringFromReference lowercaseString];
            }
            else
            {
                stringToCompare = stringFromReference;
            }
            
            if ([stringToCompare hasPrefix:stringToLookFor])
            {
                return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
            }
            
        }
    }
    return @"";
}


-(NSString *)autofillForEmailOnlyWithPrefix:(NSString *)prefix
{
    return nil;
}

-(NSString *)autoFillForURLForWithPrefix:(NSString *)prefix
{
    static dispatch_once_t onceToken;
    static NSArray *autocompleteArray;
    static NSArray * prefixes;
    static NSArray * postFixes;
    BOOL ignoreCase = YES;
    dispatch_once(&onceToken, ^
                  {
                      autocompleteArray = [self prefilledURLs];
                      prefixes = [self urlPrefixes];
                      postFixes = [self urlPostFixes];
                  });
    return [self autoFilledFromList:autocompleteArray prefix:prefix ignoreCase:YES];
}

-(NSString *)autoFilledFromList:(NSArray *)list prefix:(NSString * )prefix ignoreCase:(BOOL)ignoreCase
{
    NSString *stringToLookFor;
    NSArray *componentsString = [prefix componentsSeparatedByString:@","];
    NSString *prefixLastComponent = [componentsString.lastObject stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (ignoreCase){
        stringToLookFor = [prefixLastComponent lowercaseString];
    }
    else{
        stringToLookFor = prefixLastComponent;
    }
    for (NSString *stringFromReference in list){
        NSString *stringToCompare;
        if (ignoreCase){
            stringToCompare = [stringFromReference lowercaseString];
        }
        else{
            stringToCompare = stringFromReference;
        }
        
        if ([stringToCompare hasPrefix:stringToLookFor]){
            return [stringFromReference stringByReplacingCharactersInRange:[stringToCompare rangeOfString:stringToLookFor] withString:@""];
        }
        
    }
    return @"";
}

-(NSArray *)emailList
{
    NSArray * passwords = [[RCPasswordManager defaultManager] passwords];
    NSMutableArray * usernames = [NSMutableArray arrayWithCapacity:passwords.count];
    for (RCPassword * password in passwords) {
        if (password.username && [self validEmail:password.username]){
            [usernames addObject:password.username];
        }
    }
    return [NSArray arrayWithArray:usernames];

}

-(NSArray *)usernameList
{
    NSArray * passwords = [[RCPasswordManager defaultManager] passwords];
    NSMutableArray * usernames = [NSMutableArray arrayWithCapacity:passwords.count];
    for (RCPassword * password in passwords) {
        if (password.username){
             [usernames addObject:password.username];   
        }
    }
    return [[NSArray arrayWithArray:usernames]  sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 length] < [obj2 length]){
            return NSOrderedAscending;
        }
        if ([obj1 length] > [obj2 length])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];;
}

-(NSArray *)passwordList
{
    NSArray * passwords = [[RCPasswordManager defaultManager] passwords];
    NSMutableArray * usernames = [NSMutableArray arrayWithCapacity:passwords.count];
    for (RCPassword * password in passwords) {
        [usernames addObject:password.password];
    }
    return [[NSArray arrayWithArray:usernames] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        if ([obj1 length] < [obj2 length]){
            return NSOrderedAscending;
        }
        if ([obj1 length] > [obj2 length])
            return NSOrderedDescending;
        return NSOrderedSame;
    }];;
}

-(NSArray *)prefilledURLs
{
    return [[self titleUrlPairs] allValues];
}

-(NSDictionary *)titleUrlPairs
{
    return @{@"Gmail": @"http://www.gmail.com",
             @"Yahoo!": @"http://www.yahoo.com",
             @"AOL" :  @"http://www.aol.com",
             @"iCloud":  @"http://www.icloud.com",
             @"Apple" : @"http://www.icloud.com",
             @"Netflix" : @"https://signup.netflix.com/Login",
             @"ATT ":  @"https://www.att.com/olam/loginAction.olamexecute",
             @"MSN" : @"http://ww.msn.com",
             @"DeviantArt" : @"http://www.deviantart.com/",
             @"Youtube" : @"http://www.youtube.com",
             @"Outlook" :@"http://www.outlook.com",
             @"Reddit": @"http://www.reddit.com",
             @"Twitter" :  @"https://twitter.com/",
             @"Tumblr":  @"https://www.tumblr.com/",
             @"Facebook": @"https://www.facebook.com/",
             @"Dribbble": @"https://dribbble.com/session/new",
             @"Forrst" : @"https://forrst.com/login",
             @"Hotmail": @"https://hotmail.com",
             @"LinkedIn" :@"https://www.linkedin.com/uas/login",
             @"Groupon": @"https://www.groupon.com/login",
             @"Vine": @"https://vine.co/",
             @"Instagram" : @"https://instagram.com/accounts/login/",
             @"MySpace": @"https://myspace.com/signin",
             @"HostGator": @"https://gbclient.hostgator.com/login",
             @"NameCheap": @"https://www.namecheap.com/myaccount/login-only.aspx",
             @"GoDaddy": @"http://www.godaddy.com",
             @"Wordpress": @"http://wordpress.com/",
             @"Craigslist": @"https://accounts.craigslist.org/",
             @"Paypal": @"https://www.paypal.com/home",
             @"Amazon": @"http://www.amazon.com/",
             @"Flickr": @"http://flickr.com",
             @"RetailMeNot": @"http://www.retailmenot.com/community/login",
             @"WhatsApp": @"http://www.whatsapp.com/",
             @"Kik Messenger" : @"http://kik.com/",
             @"Skype": @"http://www.skype.com/",
             @"Instapaper": @"http://www.instapaper.com/",
             @"Tango" : @"http://www.tango.me/",
             @"Viber": @"http://www.viber.com/",
             @"ooVoo": @"https://secure.oovoo.com/",
             @"Dropbox" :@"https://www.dropbox.com/",
             @"Sallie Mae" : @"https://www.salliemae.com/",
             @"Great Lakes" : @"https://www.mygreatlakes.org/",
             @"Nelnet" : @"http://www.nelnet.com/home.aspx",
             @"LegalZoom" : @"http://www.legalzoom.com/",
             @"Rocket Lawyer" : @"https://www.rocketlawyer.com/login-register.rl#/login?hd=def",
             @"Ebay" : @"https://signin.ebay.com/",
             @"Snapchat" : @"http://www.snapchat.com/",
             @"Pinterest": @"https://www.pinterest.com/login/",
             @"Path" : @"https://path.com/login",
             @"MessageMe" : @"http://chat.messageme.com/",
             @"Blogger" : @"http://blogger.com",
             @"StackOverflow" : @"",
             @"StackExchange": @"",
             @"ESPN" : @"espn.go.com",
             @"DailyMotion" : @"http://www.dailymotion.com/us",
             @"Vimeo": @"https://vimeo.com/log_in",
             @"HootSuite" : @"https://hootsuite.com/",
             @"LiveJournal" : @"http://www.livejournal.com/",
             @"Github" : @"https://github.com/login",
             @"Parse" : @"https://parse.com/",
             @"Basecamp": @"https://launchpad.37signals.com/basecamp",
             @"Campfire" : @"https://launchpad.37signals.com/campfire/signin",
             @"Sourceforge" : @"https://sourceforge.net/account/login.php",
             @"Bank Of America": @"https://www.bankofamerica.com/",
             @"Regions Bank" : @"https://m.regions.com",
             @"Capital One" : @"https://www.capitalone.com/",
             @"Ally Financial" : @"http://www.ally.com/",
             @"Wells Fargo" : @"https://www.wellsfargo.com/",
             @"Chase Bank" : @"https://www.chase.com/",
             @"MailChimp" : @"https://login.mailchimp.com/",
             @"SquareSpace": @"http://www.squarespace.com/",
             @"Action Method" : @"https://www.actionmethod.com/login",
             @"Asana" : @"https://asana.com/",
             @"Trello" : @"https://trello.com/login",
             @"SalesForce" : @"https://login.salesforce.com/",
             @"Indeed" : @"https://secure.indeed.com/account/login",
             @"WarriorForum" : @"http://www.warriorforum.com/",
             @"Moz" : @"https://moz.com/login",
             @"Disqus" : @"https://disqus.com/profile/login/",
             @"American Express" : @"https://www.americanexpress.com/",
             @"ClickBank" : @"https://accounts.clickbank.com/login.htm",
             @"Bluehost" : @"https://my.bluehost.com/cgi-bin/cplogin",
             @"oDesk" : @"https://www.odesk.com/login",
             @"Zen Desk" : @"http://www.zendesk.com/login",
             @"Survey Monkey" : @"https://www.surveymonkey.com/MyAccount_Login.aspx",
             @"TypePad" : @"https://www.typepad.com/secure/services/signin/",
             @"SlickDeals" : @"http://slickdeals.net/",
             @"Elance" : @"https://www.elance.com/php/landing/main/login.php",
             @"HSBC" : @"http://hsbc.com",
             @"CitiGroup" : @"http://www.citigroup.com",
             @"CommonWealth Bank" : @"https://www.commbank.com.au/",
             @"Barclays" : @"http://www.barclays.co.uk/PersonalBanking/",
             @"ING" : @"http://www.ing.com/",
             @"Westpac Bank" : @"http://www.westpac.com.au/",
             @"ANZ Bank" : @"https://www.anz.com/INETBANK/bankmain.asp",
             @"RBC" : @"http://www.rbc.com/",
             @"NAB" : @"http://www.nab.com.au/",
             @"BBT" : @"http://www.bbt.com/",
             @"Fifth Third Bank" : @"https://www.53.com/site",
             @"SunTrust Bank" : @"https://www.suntrust.com/PersonalBanking",
             @"PNC Bank" : @"https://www.pnc.com",
             @"US Bank" : @"https://www.usbank.com/index.html",
             @"AgileZen" : @"https://agilezen.com/login",
             @"Rally Software" : @"http://www.rallydev.com/",
             @"Steam" : @"https://store.steampowered.com/login/",
             @"AthenaNet" : @"https://athenanet.athenahealth.com",
             @"Behance" : @"https://www.behance.net/account/login",
             @"Scoutzie" : @"https://scoutzie.com/",
             @"Carbonmade" : @"https://carbonmade.com/signin",
             @"Gaia Online" : @"https://www.gaiaonline.com/",
             @"Something Aweful Forums" : @"http://forums.somethingawful.com/account.php?action=loginform&next=%2F#form",
             @"BodyBuilding.com" : @"http://forum.bodybuilding.com/",
             @"City-Data.com forum" : @"http://www.city-data.com/forum/",
             @"Major League Gaming" : @"https://accounts.majorleaguegaming.com/",
             @"Ultimate Guitar" : @"http://www.ultimate-guitar.com/login.php",
             @"NewGrounds" : @"https://www.newgrounds.com/login",
             @"MacRumors forum" : @"http://forums.macrumors.com/",
             @"Ubuntu Forums" : @"https://login.ubuntu.com/",
             @"GameDev.net" : @"http://www.gamedev.net/"
             };
}

-(NSArray *)urlPrefixes
{
    return @[@"http://",@"https://", @"www."];
}


-(NSArray *)urlPostFixes
{
    return @[@"com", @"net", @"us", @"org", @"la", @"ca", @"io", @"me", @"fm", @"as"];
}

-(NSArray *)prefilledTitles
{
    return [[[self titleUrlPairs] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
}


-(NSArray *)prefilledSites
{
    return @[ @"gmail.com",
              @"yahoo.com",
              @"hotmail.com",
              @"aol.com",
              @"comcast.net",
              @"me.com",
              @"msn.com",
              @"live.com",
              @"sbcglobal.net",
              @"ymail.com",
              @"att.net",
              @"mac.com",
              @"cox.net",
              @"verizon.net",
              @"hotmail.co.uk",
              @"bellsouth.net",
              @"rocketmail.com",
              @"aim.com",
              @"yahoo.co.uk",
              @"earthlink.net",
              @"charter.net",
              @"optonline.net",
              @"shaw.ca",
              @"yahoo.ca",
              @"googlemail.com",
              @"mail.com",
              @"qq.com",
              @"btinternet.com",
              @"mail.ru",
              @"live.co.uk",
              @"naver.com",
              @"rogers.com",
              @"juno.com",
              @"yahoo.com.tw",
              @"live.ca",
              @"walla.com",
              @"163.com",
              @"roadrunner.com",
              @"telus.net",
              @"embarqmail.com",
              @"hotmail.fr",
              @"pacbell.net",
              @"sky.com",
              @"sympatico.ca",
              @"cfl.rr.com",
              @"tampabay.rr.com",
              @"q.com",
              @"yahoo.co.in",
              @"yahoo.fr",
              @"hotmail.ca",
              @"windstream.net",
              @"hotmail.it",
              @"web.de",
              @"asu.edu",
              @"gmx.de",
              @"gmx.com",
              @"insightbb.com",
              @"netscape.net",
              @"icloud.com",
              @"frontier.com",
              @"126.com",
              @"hanmail.net",
              @"suddenlink.net",
              @"netzero.net",
              @"mindspring.com",
              @"ail.com",
              @"windowslive.com",
              @"netzero.com",
              @"yahoo.com.hk",
              @"yandex.ru",
              @"mchsi.com",
              @"cableone.net",
              @"yahoo.com.cn",
              @"yahoo.es",
              @"yahoo.com.br",
              @"cornell.edu",
              @"ucla.edu",
              @"us.army.mil",
              @"excite.com",
              @"ntlworld.com",
              @"usc.edu",
              @"nate.com",
              @"outlook.com",
              @"nc.rr.com",
              @"prodigy.net",
              @"wi.rr.com",
              @"videotron.ca",
              @"yahoo.it",
              @"yahoo.com.au",
              @"umich.edu",
              @"ameritech.net",
              @"libero.it",
              @"yahoo.de",
              @"rochester.rr.com",
              @"cs.com",
              @"frontiernet.net",
              @"swbell.net",
              @"msu.edu",
              @"ptd.net",
              @"proxymail.facebook.com",
              @"hotmail.es",
              @"austin.rr.com",
              @"nyu.edu",
              @"sina.com",
              @"centurytel.net",
              @"usa.net",
              @"nycap.rr.com",
              @"uci.edu",
              @"hotmail.de",
              @"yahoo.com.sg",
              @"email.arizona.edu",
              @"yahoo.com.mx",
              @"ufl.edu",
              @"bigpond.com",
              @"unlv.nevada.edu",
              @"yahoo.cn",
              @"ca.rr.com",
              @"google.com",
              @"yahoo.co.id",
              @"inbox.com",
              @"fuse.net",
              @"hawaii.rr.com",
              @"talktalk.net",
              @"gmx.net",
              @"walla.co.il",
              @"ucdavis.edu",
              @"carolina.rr.com",
              @"comcast.com",
              @"live.fr",
              @"blueyonder.co.uk",
              @"live.cn",
              @"cogeco.ca",
              @"abv.bg",
              @"tds.net",
              @"centurylink.net",
              @"yahoo.com.vn",
              @"uol.com.br",
              @"osu.edu",
              @"san.rr.com",
              @"rcn.com",
              @"umn.edu",
              @"live.nl",
              @"live.com.au",
              @"tx.rr.com",
              @"eircom.net",
              @"sasktel.net",
              @"post.harvard.edu",
              @"snet.net",
              @"wowway.com",
              @"live.it",
              @"att.com",
              @"vt.edu",
              @"rambler.ru",
              @"temple.edu",
              @"cinci.rr.com"];

}

-(BOOL)validEmail:(NSString *)name
{
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", laxString];
    return [emailTest evaluateWithObject:name];
}

@end
