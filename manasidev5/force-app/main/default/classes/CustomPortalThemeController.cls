public without sharing class CustomPortalThemeController {
    private static final Integer OPEN_CASES_LIMIT = 2;

    public class OpenCaseDisplay {
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String caseType;
        @AuraEnabled public String description;
        @AuraEnabled public String status;
        @AuraEnabled public Date openedDate;
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
        User u = [
            SELECT FirstName, LastName, Name, CreatedDate, ContactId, Contact.CreatedDate
            FROM User
            WHERE Id = :UserInfo.getUserId()
            LIMIT 1
        ];

        List<Member__c> memberList = [SELECT Id, TenancyStartDate__c FROM Member__c WHERE Contact__c = :u.ContactId AND IsActive__c = true
                AND (Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT) ORDER BY TenancyStartDate__c ASC LIMIT 1];
        UserDisplay d = new UserDisplay();
        d.name = u.Name;
        d.firstname = u.FirstName;
        d.initials =
            (String.isNotBlank(u.FirstName) ? u.FirstName.left(1) : '') +
            (String.isNotBlank(u.LastName) ? u.LastName.left(1) : '');
        d.initials = d.initials.toUpperCase();

        Datetime since = (memberList != null && !memberList.isEmpty()) ? memberList[0].TenancyStartDate__c : u.Contact.CreatedDate;
        d.subtitle = 'Tenant since ' + String.valueOf(since.year());
        return d;
    }

    @AuraEnabled(cacheable=true)
    public static List<OpenCaseDisplay> getMyOpenCases() {
        List<OpenCaseDisplay> result = new List<OpenCaseDisplay>();
        User u = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        if (u.ContactId == null) {
            return result;
        }

        for (Case c : [
            SELECT CaseNumber, CaseType__c, Description, ExternalCaseStatus__c, CreatedDate
            FROM Case
            WHERE ExternalCaseStatus__c != null
                AND ExternalCaseStatus__c != :CaseDecorator.EXTERNAL_STATUS_CLOSED WITH SYSTEM_MODE 
            ORDER BY CreatedDate DESC
            LIMIT :OPEN_CASES_LIMIT
        ]) {
            OpenCaseDisplay d = new OpenCaseDisplay();
            d.caseNumber = c.CaseNumber;
            d.caseType = c.CaseType__c;
            d.description = c.Description;
            d.status = c.ExternalCaseStatus__c;
            d.openedDate = c.CreatedDate.date();
            result.add(d);
        }
        return result;
    }

    @AuraEnabled(cacheable=true)
    public static String getCustomerPortalURL() {
        CustomerPortalSettings__c settings = CustomerPortalSettings__c.getInstance();

        if (settings == null || String.isBlank(settings.Customer_Portal_URL__c)) {
            return null;
        }
        return settings.Customer_Portal_URL__c;
    }
}