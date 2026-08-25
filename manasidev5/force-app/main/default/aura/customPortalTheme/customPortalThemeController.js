({
    doInit: function (component, event, helper) {
        component.set('v.menuName', 'YH_Portal_Navigation_Menu');
        component.set('v.userProfileMenu', 'YH_Portal_User_Profile_Menu');
        helper.loadNavigationMenu(component);
        helper.loadUserProfileMenu(component);
        helper.loadCurrentUser(component);
    },

    /** Set active state, then navigate to the menu item's target. */
    handleNavClick: function (component, event, helper) {
        var label = event.currentTarget.dataset.label;
        var url = event.currentTarget.dataset.url;
        var type = event.currentTarget.dataset.type;
        var defaultListViewId = event.currentTarget.dataset.defaultlistviewid;     
        component.set('v.activeItem', label);

        if (type== 'InternalLink' && url) {
            component.find('navService').navigate({
                type: 'standard__webPage',
                attributes: { url: url }
            });
        }else if(type == 'SalesforceObject'){
            component.find('navService').navigate({
            type: "standard__objectPage",
            attributes: {
                objectApiName: url,
                actionName: "list",
            },
            state: {
                // 'filterName' is a property on the page 'state'
                // and identifies the target list view.
                // It may also be an 18 character list view id.
                filterName: defaultListViewId,
            },
            });
        }else if(type == 'Event'){
         if(url == 'Logout'){
            $A.get("e.force:logout").fire();
         }   
        }
        component.set("v.sidebarOpen", false);
    },

    toggleSidebar : function(component, event, helper) {
        component.set("v.sidebarOpen",
        !component.get("v.sidebarOpen"));
    },

    openSettingPage : function(component, event, helper) {
            component.find('navService').navigate({
                type: 'standard__webPage',
                attributes: { url: '/yhcustomerportal/s/account-settings' }
            });
            component.set("v.sidebarOpen", false);
    }

})