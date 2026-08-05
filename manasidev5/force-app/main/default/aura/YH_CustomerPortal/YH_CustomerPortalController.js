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
        component.set('v.activeItem', label);

        if (url) {
            component.find('navService').navigate({
                type: 'standard__webPage',
                attributes: { url: url }
            });
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