({
    /* Emoji fallback per label; menu items carry no icon metadata. Default: 📄 */
    getIconMap: function() {
        return {
            'home': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Home.svg',
            'repairs': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Spanner_fill.svg',
            'rent & payments': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Pound_sign_circle.svg',
            'my cases':  $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Personal_file.svg',
            'cases': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/House_people.svg',
            'my home': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/House_people.svg',
            'get in touch': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Question_circle.svg',
            'contact': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Contact.svg',
            'my details':$A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Personal_file.svg',
            'account settings':$A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Cog_black.svg',
            'reset password': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Lock_black.svg',
            'log out': $A.get('$Resource.CustomerPortalIcons') + '/CustomerPortalIcons/Door_exit_right_arrow_black.svg'
        };
    },

    loadNavigationMenu: function (component) {
        var self = this;
        var iconMap = self.getIconMap();
        var action = component.get('c.getNavigationMenuItems');
        action.setParams({ menuName: component.get('v.menuName') });
        action.setCallback(this, function (response) {
            var items = [];
            if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
                items = [{ label: 'Home', itemType: 'InternalLink', actionValue: '/' }, ...response.getReturnValue()];
            }
            if (!items.length) {
                // Builder preview / menu not found — keep layout intact
                items = self.getFallbackItems();
            }
            items.forEach(function (item) {
                item.icon = iconMap[(item.label || '').toLowerCase()] || 'utility:home';
            });
            component.set('v.navItems', items);
            self.setInitialActive(component, items);
        });
        $A.enqueueAction(action);
    },

    loadUserProfileMenu: function (component) {
        var self = this;
        var iconMap = self.getIconMap();
        var action = component.get('c.getNavigationMenuItems');
        action.setParams({ menuName: component.get('v.userProfileMenu') });
        action.setCallback(this, function (response) {
            var items = [];
            if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
                items = response.getReturnValue();
            }
            if (!items.length) {
                // Builder preview / menu not found — keep layout intact
                items = self.getFallbackItems();
            }
            items.forEach(function (item) {
                item.icon = iconMap[(item.label || '').toLowerCase()] || 'utility:home';
            });
            component.set('v.navItemsUserProfileMenu', items);
            self.setInitialActive(component, items);
        });
        $A.enqueueAction(action);
    },

    /* Highlight the item matching the current URL, else the first item. */
    setInitialActive: function (component, items) {
        var path = window.location.pathname;
        var active = items[0] ? items[0].label : '';
        items.forEach(function (item) {
            if (item.actionValue && item.actionValue !== '/' && path.indexOf(item.actionValue) !== -1) {
                active = item.label;
            }
        });
        component.set('v.activeItem', active);
    },

    loadCurrentUser: function (component) {
        var action = component.get('c.getCurrentUser');
        action.setCallback(this, function (response) {
            if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
                var u = response.getReturnValue();
                component.set('v.userName', u.name);
                component.set('v.userInitials', u.initials);
                component.set('v.userSubtitle', u.subtitle);
            } else {
                component.set('v.userName', 'Guest');
                component.set('v.userInitials', 'G');
                component.set('v.userSubtitle', '');
            }
        });
        $A.enqueueAction(action);
    },

    getFallbackItems: function () {
        return [
            { label: $A.get('$Label.c.CP_Home'), actionValue: '/' },
            { label: $A.get('$Label.c.CP_Repairs'), actionValue: '' },
            { label: $A.get('$Label.c.CP_RentAndPayments'), actionValue: '' },
            { label: $A.get('$Label.c.CP_MyCases'), actionValue: '' },
            { label: $A.get('$Label.c.CP_MyHome'), actionValue: '' },
            { label: $A.get('$Label.c.CP_GetInTouch'), actionValue: '' }
        ];
    }
})