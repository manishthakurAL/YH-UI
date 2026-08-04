({
    /* Emoji fallback per label; menu items carry no icon metadata. Default: 📄 */
    ICON_MAP: {
        'home': 'utility:home',
        'repairs': 'utility:custom_apps',
        'rent & payments': 'utility:moneybag',
        'payments': 'utility:billing',
        'my cases': 'utility:case',
        'cases': 'utility:case',
        'my home': 'utility:company',
        'get in touch': 'utility:anywhere_chat',
        'contact': 'utility:contact'
    },

    ICON_COLOR_MAP: {
        'home': 'yh-rose',
        'repairs': 'yh-green',
        'rent & payments': 'yh-yellow',
        'payments': 'yh-yellow',
        'my cases': 'yh-blue',
        'cases': 'yh-blue',
        'my home': 'yh-purple-tint',
        'get in touch': 'yh-white',
        'contact': 'yh-white'
    },

    loadNavigationMenu: function (component) {
        var self = this;
        var action = component.get('c.getNavigationMenuItems');
        console.log('menu name ' + component.get('v.menuName'));
        action.setParams({ menuName: component.get('v.menuName') });
        action.setCallback(this, function (response) {
            var items = [];
            if (response.getState() === 'SUCCESS' && response.getReturnValue()) {
                items = [{ label: 'Home', itemType: 'InternalLink', actionValue: '/' }, ...response.getReturnValue()];
                console.log('Loaded nav menu:', JSON.stringify(items,null, 2) );
            }
            if (!items.length) {
                // Builder preview / menu not found — keep layout intact
                items = self.getFallbackItems();
            }
            items.forEach(function (item) {
                item.icon = self.ICON_MAP[(item.label || '').toLowerCase()] || 'utility:home';
                item.iconColor = self.ICON_COLOR_MAP[(item.label || '').toLowerCase()] || 'utility:home';
            });
            component.set('v.navItems', items);
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
            { label: 'Home', actionValue: '/' },
            { label: 'Repairs', actionValue: '' },
            { label: 'Rent & Payments', actionValue: '' },
            { label: 'My Cases', actionValue: '' },
            { label: 'My Home', actionValue: '' },
            { label: 'Get in Touch', actionValue: '' }
        ];
    }
})