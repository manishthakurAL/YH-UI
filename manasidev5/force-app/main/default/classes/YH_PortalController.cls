public with sharing class YH_PortalController {

    public class NavItem {
        @AuraEnabled public String label;
        @AuraEnabled public String actionValue;
        @AuraEnabled public String itemType;
        public NavItem(String label, String actionValue, String itemType) {
            this.label = label;
            this.actionValue = actionValue;
            this.itemType = itemType;
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

        List<NavigationMenuItem> menuItems = [SELECT Id, Label, Target, Type, Status 
                FROM NavigationMenuItem 
                WHERE NavigationLinkSetId = :menuContainer[0].Id 
                AND Status = 'Live' 
                ORDER BY Position];
            for (NavigationMenuItem item :menuItems) {
                result.add(new NavItem(item.label, item.Target, String.valueOf(item.Type)));
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'YH_PortalController: ' + e.getMessage());
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
        UserDisplay d = new UserDisplay();
        d.name = u.Name;
        d.firstname = u.FirstName;
        d.initials =
            (String.isNotBlank(u.FirstName) ? u.FirstName.left(1) : '') +
            (String.isNotBlank(u.LastName) ? u.LastName.left(1) : '');
        d.initials = d.initials.toUpperCase();

        Datetime since = (u.ContactId != null) ? u.Contact.CreatedDate : u.CreatedDate;
        d.subtitle = 'Tenant since ' + String.valueOf(since.year());
        return d;
    }
}