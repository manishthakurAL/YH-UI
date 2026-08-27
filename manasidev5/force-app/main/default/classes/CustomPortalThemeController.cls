public with sharing class CustomPortalThemeController {
    private static final Integer OPEN_CASES_LIMIT = 2;

    public class OpenCaseDisplay {
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String caseType;
        @AuraEnabled public String description;
        @AuraEnabled public String status;
        @AuraEnabled public Date openedDate;

        public OpenCaseDisplay(String caseNumber, String caseType, String description, String status, Date openedDate) {
            this.caseNumber = caseNumber;
            this.caseType = caseType;
            this.description = description;
            this.status = status;
            this.openedDate = openedDate;
        }
    }

    public class NavItem {
        @AuraEnabled public String label;
        @AuraEnabled public String actionValue;
        @AuraEnabled public String itemType;
        @AuraEnabled public String defaultListViewId;
        public NavItem(String label, String actionValue, String itemType, String defaultListViewId) {
            this.label = label;
            this.actionValue = actionValue;
            this.itemType = itemType;
            this.defaultListViewId = defaultListViewId;
        }
    }

    public class UserDisplay {
        @AuraEnabled public String name;
        @AuraEnabled public String firstName;
        @AuraEnabled public String initials;
        @AuraEnabled public String subtitle;

        public UserDisplay(String name, String firstName, String initials, String subtitle) {
            this.name = name;
            this.firstName = firstName;
            this.initials = initials;
            this.subtitle = subtitle;
        }
    }

    private static User aUser{
        get{
            if(aUser == null){
                aUser = [SELECT FirstName, LastName, Name, CreatedDate, ContactId, Contact.CreatedDate
                    FROM User
                    WHERE Id = :UserInfo.getUserId()
                    LIMIT 1];
            }
            return aUser;
        }
        set;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<NavItem> getNavigationMenuItems(String menuName) {
        List<NavItem> result = new List<NavItem>();
        String communityId = Network.getNetworkId();
        if (String.isBlank(communityId) || String.isBlank(menuName)) {
            return result;
        } 
        try {
         List<NavigationLinkSet> menuContainer = [SELECT Id FROM NavigationLinkSet 
                                       WHERE NetworkId = :communityId 
                                       AND DeveloperName = :menuName 
                                       LIMIT 1];

        List<NavigationMenuItem> menuItems = [SELECT Id, Label, Target, Type, Status, DefaultListViewId 
                FROM NavigationMenuItem 
                WHERE NavigationLinkSetId = :menuContainer[0].Id 
                AND Status = 'Live' 
                ORDER BY Position];
            for (NavigationMenuItem item :menuItems) {
                result.add(new NavItem(item.label, item.Target, String.valueOf(item.Type), item.DefaultListViewId));
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'CustomPortalThemeController: ' + e.getMessage());
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static UserDisplay getCurrentUser() {
        String initials =
            (String.isNotBlank(aUser.FirstName) ? aUser.FirstName.left(1) : '') +
            (String.isNotBlank(aUser.LastName) ? aUser.LastName.left(1) : '');
        List<Member__c> memberList = new MemberService().getActiveMembersByContactIdOrderByTenancyStartDate(aUser.ContactId);
        Datetime since = (memberList != null && !memberList.isEmpty()) ? memberList[0].TenancyStartDate__c : aUser.Contact.CreatedDate;
        String subtitle = 'Tenant since ' + String.valueOf(since.year());
        UserDisplay aUserDisplay = new UserDisplay(aUser.Name, aUser.FirstName, initials.toUpperCase(), subtitle);
        
        return aUserDisplay;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpenCaseDisplay> getMyOpenCases() {
        List<OpenCaseDisplay> result = new List<OpenCaseDisplay>();
        for (Case c : [
            SELECT CaseNumber, CaseType__c, Description, ExternalCaseStatus__c, CreatedDate
            FROM Case
            WHERE ExternalCaseStatus__c != null
                AND ExternalCaseStatus__c != :CaseDecorator.EXTERNAL_STATUS_CLOSED
            ORDER BY CreatedDate DESC
            LIMIT :OPEN_CASES_LIMIT
        ]) {
            OpenCaseDisplay aOpenCaseDisplay = new OpenCaseDisplay(
                c.CaseNumber,
                c.CaseType__c,
                c.Description,
                c.ExternalCaseStatus__c,
                c.CreatedDate.date()
            );
            result.add(aOpenCaseDisplay);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getCustomerPortalURL() {
        CustomerPortalSettings__c settings = CustomerPortalSettings__c.getInstance();
        return settings.Customer_Portal_URL__c;
    }
}