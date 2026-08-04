import { LightningElement, wire, track, api } from 'lwc';
import { gql, graphql } from 'lightning/uiGraphQLApi';
import { getRecord } from 'lightning/uiRecordApi';
import ALERT_ICONS from '@salesforce/resourceUrl/YHicons';
import USER_ID from '@salesforce/user/Id';
import getAllConfigs from '@salesforce/apex/AlertController.getAllConfigs';

const WORKORDER_FIELDS = ['WorkOrder.Id', 'WorkOrder.Property__c'];

export default class AlertModule extends LightningElement {
    @api recordId;
    @track categories = [];
    @track selectedCategory = null;
    @track showCategoryView = false;
    @track showSubCategoryView = false;
    @track selectedSubCategory = null;
    @track showNoteView = false;
    @track profileName = '';
    @track isLoading = true;
    @track hasError = false;
    @track errorMessage = '';
    @track alerts = [];
    @track alertMaps = [];
    @track configs = [];
    isConfigLoaded = false; 
    isAlertLoaded = false; 
    isAlertMapLoaded = false;
    showEmptyState = false;   
    propertyId = null;
   
    connectedCallback() {}

    disconnectedCallback() {}

    @wire(getAllConfigs)
    wiredGetConfig({ error, data }) {
        if (data) {
            this.isConfigLoaded = true;
            this.extractAlertConfig(data);
        } else if (error) {
            console.error('GetAlertConfig-error:', error);
            this.errors = error;
        }
    }

    @wire(graphql, {
        query: '$userQuery',
        variables: { userId: USER_ID }
    })
    GetProfileResult({ data, errors }) {
        if (data) {
            this.profileName = data.uiapi.query.User.edges[0]?.node?.Profile?.Name?.value;
        } else if (errors) {
            console.error('Error fetching profile:', errors);
        }
    }

    @wire(graphql, {
        query: '$workOrderQuery',
        variables: '$workOrderId'
    })
    GetWorkOrderResult({ data, errors }) {
        if (data) {
            this.propertyId = data.uiapi.query.WorkOrder.edges[0]?.node.Property__c?.value;
        } else {
            console.error('###GetWorkOrder-error:', errors);
            this.errors = errors;
        }
        
    }

    @wire(graphql, {
        query: '$alertQuery',
        variables: '$workOrderPropertyId'
    })
    GetAlertResult({ data, errors }) {
        if (data) {
            try {
                this.extractAlertData(data);
                this.isAlertLoaded = true;
                this.processAllData();
            } catch (error) {
                console.error('Error extracting alert data:', error);
                this.handleError(error, 'Failed to process alert data');
            }
        } else {
            console.error('###GetAlert-error:', errors);
            this.errors = errors;
        }
    }

    @wire(graphql, {
        query: '$alertMapQuery',
        variables: '$workOrderPropertyId'
    })
    GetAlertMapResult({ data, errors }) {
        if (data) {   
            try {  
                this.extractAlertMapData(data);
                this.isAlertMapLoaded = true;
                this.processAllData();   
            } catch (error) {
                console.error('Error extracting alert data:', error);
                this.handleError(error, 'Failed to process alert data');
            }         
        } else {
            console.error('###GetAlert-error:', errors);
            this.errors = errors;
        }
    }

    get workOrderId() {
        return { workOrderId: this.recordId }
    }

    get workOrderPropertyId() {
        return { propertyId: this.propertyId }
    }

    extractAlertConfig(apexData) {
        this.configs = apexData.map(record => { 
            return {
                Type__c: record.Type__c,
                Category__c: record.Category__c,
                SubCategory__c: record.SubCategory__c,
                SubCategoryDisplayText__c: record.SubCategoryDisplayText__c,
                GroupIcon__c: record.GroupIcon__c,
                SubGroupIcon__c: record.SubGroupIcon__c,
                GroupName__c: record.GroupName__c,
                GroupOrder__c: record.GroupOrder__c,
                HideSubGroup__c: record.HideSubGroup__c,
                IsVisibleToFSDispatchers__c: record.IsVisibleToFSDispatchers__c,
                IsVisibleToFSResource__c: record.IsVisibleToFSResource__c,
                ShowNotesToFSDispatchers__c: record.ShowNotesToFSDispatchers__c,
                ShowNotesToFSResource__c: record.ShowNotesToFSResource__c,
                SubGroupOrder__c: record.SubGroupOrder__c,
                key: `${record.Type__c || ''}_${record.Category__c || ''}_${record.SubCategory__c || ''}`.toUpperCase()
            };
        });
    }
   
    extractAlertData(graphqlData) {
        try {
            const edges = graphqlData?.uiapi?.query?.Alert?.edges || [];
            this.alerts = edges.map(edge => {
                const node = edge.node;
                return {
                    id: node.Id,
                    type: node.Type__c?.value || '',
                    category: node.Category__c?.value || '',
                    subcategory: node.SubCategory__c?.value || '',
                    note: node.Notes__c?.value || '',
                    startDate: this.formatDate(node.StartDate__c?.value) || new Date().addDays(-999),
                    endDate: this.formatDate(node.EndDate__c?.value),
                    active: node.IsActive__c?.value || false,
                    propertyId: node.Property__c?.value,
                    createdDate:  this.formatDate(node.CreatedDate?.value),
                    lastModified:  this.formatRelativeTime(node.LastModifiedDate?.value),
                    expireIn:  this.formatRelativeDays( this.formatDate(node.EndDate__c?.value)),
                    source: 'Alert__c',
                    isFromAlertMap: false
                };
            });
        } catch (error) {
            console.error('Error extracting alert data:', error.message);
            return [];
        }
    }
   
    extractAlertMapData(graphqlData) {
        try {
            const edges = graphqlData?.uiapi?.query?.AlertMap?.edges || [];
            this.alertMaps = edges.map(edge => {
                const node = edge.node;
                const parentAlert = node.Alert__r;  
                return {
                    id: node.Id,
                    type: parentAlert?.Type__c?.value || '',
                    category: parentAlert?.Category__c?.value || '',
                    subcategory: parentAlert?.SubCategory__c?.value || '',
                    note: node?.Notes__c?.value || parentAlert?.Notes__c?.value || '',
                    startDate: this.formatDate(parentAlert?.StartDate__c?.value) || new Date().addDays(-999),
                    endDate: this.formatDate(parentAlert?.EndDate__c?.value),
                    active: parentAlert?.IsActive__c?.value || false,
                    propertyId: node.Property__c?.value,
                    createdDate:  this.formatDate(node.CreatedDate?.value),
                    lastModified:  this.formatRelativeTime(node.LastModifiedDate?.value),
                    expireIn:  this.formatRelativeDays( this.formatDate(parentAlert.EndDate__c?.value)),
                    source: 'AlertMap__c',
                    isFromAlertMap: true,
                    parentAlertId: node.Alert__c?.value
                };
            });
        } catch (error) {
            console.error('Error extracting alert map data:', error.message);
            return [];
        }
    }
   
    processAllData() {

        this.showEmptyState = false;
        if (!this.isConfigLoaded || !this.isAlertLoaded || !this.isAlertMapLoaded) {
            return;
        }

        try {
            const allAlerts = [...this.alerts, ...this.alertMaps];               
            if (allAlerts.length === 0) {
                this.isLoading = false;
                this.showEmptyState = true;
                this.hasError = false;
                this.categories = [];
                return;
            }
            const categoryMap = new Map();
            allAlerts.forEach(alert => {
                const keyFromAlert = this.generateKey(alert.type, alert.category, alert.subcategory);
                const config = this.configs.find(cfg => {
                    const keyFromConfig = this.generateKey(cfg.Type__c, cfg.Category__c, cfg.SubCategory__c);
                    return keyFromAlert === keyFromConfig;
                }) || this.defaultConfig;                
                
                if ( this.hasViewPermission(config.IsVisibleToFSDispatchers__c, config.IsVisibleToFSResource__c) ) {
                    if (!categoryMap.has(config.GroupName__c)) {
                        categoryMap.set(config.GroupName__c, {
                            key: config.GroupName__c,
                            displayName: config.GroupName__c,
                            iconName: config.GroupIcon__c,
                            iconColor: this.getIconStyle('yh-purple'),
                            iconUrl: this.getIconUrl(config.GroupIcon__c),
                            hideSubGroup: config.HideSubGroup__c,
                            categoryOrder: config.GroupOrder__c || 9999,
                            subCategoryMap: new Map(),
                            subCategories: new Array()
                        });
                    }
                    const subGroupKey = config.HideSubGroup__c ? config.GroupName__c : keyFromAlert;
                    if (!categoryMap.get(config.GroupName__c).subCategoryMap.has(subGroupKey)) {
                        const isNoteVisible = this.hasNoteViewPermission(config.ShowNotesToFSDispatchers__c, config.ShowNotesToFSResource__c);
                        const displayName = config.HideSubGroup__c ? config.GroupName__c : config.SubCategoryDisplayText__c;
                        categoryMap.get(config.GroupName__c).subCategoryMap.set(subGroupKey, {
                            key: subGroupKey,
                            displayName: displayName,
                            iconName: config.SubGroupIcon__c || 'standard:announcement',
                            iconColor: this.getIconStyle('yh-purple'),
                            iconUrl: this.getIconUrl(config.SubGroupIcon__c),
                            subCategoryOrder: config.SubGroupOrder__c || 9999,
                            hideSubGroup: config.HideSubGroup__c,
                            isNoteVisible: isNoteVisible,
                            notes: [],
                        });
                    }
                    const noteWithOrder = {
                        ...alert,
                        isNoteExpandable: alert.note?.length > 250,
                        isNoteExpanded: false,
                        alertNoteClass: alert.note?.length > 250 ? 'alert-note alert-note-clamped' : 'alert-note alert-note-full',
                        displayOrder: config.SubGroupOrder__c || 9999,
                        config: config
                    };
                    categoryMap.get(config.GroupName__c).subCategoryMap.get(subGroupKey).notes.push(noteWithOrder);
                }
            });

            categoryMap.forEach((category, categoryName) => {
                category.subCategories = Array.from(category.subCategoryMap.values())
                    .map(subCategory => ({     
                        ...subCategory,
                        subCategoryCount: `${subCategory.notes.length}`,
                        subCategoryCountText: `${subCategory.notes.length} ${subCategory.notes.length > 1 ? 'Alerts' : 'Alert'}`,
                        notes: subCategory.notes.sort((a, b) => b.startDate - a.startDate)
                    }))
                    .sort((a, b) => a.subCategoryOrder - b.subCategoryOrder);
            });
           
            this.categories = Array.from(categoryMap.values())
                .map(category => ({
                    ...category,
                    categoryCount: category.hideSubGroup ? `${category.subCategories[0].subCategoryCount}` :`${category.subCategories.length}`,
                    categoryCountText: category.hideSubGroup ? `${category.subCategories[0].subCategoryCount} ${category.subCategories[0].subCategoryCount > 1 ? 'Alerts' : 'Alert'}` :`${category.subCategories.length} ${category.subCategories.length > 1 ? 'Alerts' : 'Alert'}`
                }))
                .sort((a, b) => a.categoryOrder - b.categoryOrder);   
            
            // console.log('Processed categories:', JSON.stringify(this.categories, null, 2));
            this.isLoading = false;
            this.hasError = false; 
            this.showCategoryView = true;          
        } catch (error) {
            console.error('Error processing all data:', JSON.stringify(error));
            this.handleError(error);
        }
    }

    get defaultConfig() {
        return {
            GroupName__c: 'General Information​',
            Type__c: 'Property​',
            Category__c: 'General Alert​',
            SubCategory__c: 'General Alert​',
            GroupIcon__c: 'General_alert',
            SubGroupIcon__c: 'General_alert',
            GroupOrder__c: 90,
            SubGroupOrder__c: 9999,
            HideSubGroup__c: true,
            ShowNotesToFSDispatchers__c: true,
            ShowNotesToFSResource__c: true,
            IsVisibleToFSDispatchers__c: true,
            IsVisibleToFSResource__c: true
        };
    }

    hasViewPermission(isVisibleToFSDispatchers, isVisibleToFSResource) {
        const isDispatcher = this.profileName === 'FS Service Dispatcher' || this.profileName === 'FS Service Dispatcher And Resource';
        const isResource = this.profileName === 'FS Service Resource';  
        const isAdmin = this.profileName === 'System Administrator';
        return ( isVisibleToFSDispatchers && isDispatcher ) || ( isVisibleToFSResource && isResource )  || isAdmin;
    }

    hasNoteViewPermission(showNotesToFSDispatchers, showNotesToFSResource) {
        const isDispatcher = this.profileName === 'FS Service Dispatcher' || this.profileName === 'FS Service Dispatcher And Resource';
        const isResource = this.profileName === 'FS Service Resource';  
        const isAdmin = this.profileName === 'System Administrator';
        return ( showNotesToFSDispatchers && isDispatcher ) || ( showNotesToFSResource && isResource )  || (isAdmin && ( showNotesToFSDispatchers || showNotesToFSResource));
    }

    generateKey(type, category, subcategory) {
        return `${type || ''}_${category || ''}_${subcategory || ''}`.toLowerCase().replace(/[\u200B-\u200D\uFEFF]/g, '').trim();
    }
   
    getIconUrl(iconName) {
        try {
            if (iconName.includes(':')) {
                return {
                    iconPath: iconName,
                    isStandardIcon: true
                };
            }
            return {
                iconPath: `${ALERT_ICONS}/${iconName || 'default'}.png`,
                isStandardIcon: false
            };
        } catch (error) {
            return {
                iconPath: 'standard:announcement',
                isStandardIcon: true
            };
        }
    }

    getIconStyle(iconColor) {
        return `background-color: ${this.getIconColor(iconColor)};`;
    }
   
    getIconColor(iconColor) {
        const colorMap = {
            'yh-purple': '#34215a',
            'yh-light-purple': '#857a9c',
            'yh-lightest-purple': '#ece6f9',
            'yh-light-rose': '#f694a8',
            'yh-lightest-rose': '#ffeef1',
            'yh-light-yellow': '#f9ab23',
            'yh-light-green': '#06D6A0',
            'yh-light-blue': '#118AB2',
            'yh-light-teal': '#4FD1C7',
            'yh-lightest-green': '#06D6A0',
            'yh-lightest-blue': '#118AB2',
            'yh-lightest-teal': '#4FD1C7',
            'yh-lightest-lightpurple': '#9F7AEA',
            'yh-teal': '#4FD1C7',
            'yh-lightpurple': '#9F7AEA',
            'default': '#5A67D8'
        };
        return colorMap[iconColor?.toLowerCase()] || '#ece6f9';
    }
   
    formatDate(dateString) {
        if (!dateString) return null;
        try {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric'
            });
        } catch (error) {
            console.warn('formatDate: Invalid date format:', dateString);
            return dateString;
        }
    }

    formatRelativeDays(dateString) {
        try {
            if (!dateString) return ' - ';
            const date = new Date(dateString);
            const now = new Date();
            const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
            const targetDate = new Date(date.getFullYear(), date.getMonth(), date.getDate());
            
            const diffMs = targetDate - today;
            const diffDays = Math.ceil(diffMs / (1000 * 60 * 60 * 24));

            console.log(`Calculating relative days for ${dateString}: diffDays = ${diffDays}` , typeof diffDays);
            if (diffDays < 0) {
                return 'Expired';
            }
            if (diffDays === 0) {
                return 'Expires Today';
            }
            if (diffDays > 0 && diffDays <= 3) {
                return `Expires Soon (${diffDays} Day${diffDays !== 1 ? 's' : ''})`;
            }
            if (diffDays > 3) {
                return `${diffDays} Days Left`;
            }
            return ' - ';
        } catch (error) {
            console.error(`Error formatting relative days on ${date}: `, error);
            return ' - ';
        }
    }
   
    formatRelativeTime(dateString) {
        if (!dateString) return 'Unknown';
       
        try {
            const date = new Date(dateString);
            const now = new Date();
            const diffMs = now - date;
            const diffMins = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMins / 60);
            const diffDays = Math.floor(diffHours / 24);
           
            if (diffMins < 1) return 'Just now';
            if (diffMins < 60) return `${diffMins} minute${diffMins !== 1 ? 's' : ''} ago`;
            if (diffHours < 24) return `${diffHours} hour${diffHours !== 1 ? 's' : ''} ago`;
            if (diffDays < 7) return `${diffDays} day${diffDays !== 1 ? 's' : ''} ago`;
           
            return date.toLocaleDateString('en-US', {
                month: 'short',
                day: 'numeric',
                year: 'numeric'
            });
        } catch (error) {
            console.warn('formatRelativeTime : Invalid date format:', dateString);
            return dateString;
        }
    }
    
    handleCategoryClick(event) {
        const categoryKey = event.currentTarget.dataset.key;
        this.selectedCategory = this.categories.find(cat => cat.key === categoryKey);
        if (this.selectedCategory.subCategories.length == 1)  {
            this.selectedSubCategory = this.selectedCategory.subCategories[0];
            if (this.selectedSubCategory.hideSubGroup) {
                this.showCategoryView = false;
                this.showSubCategoryView = false;
                this.showNoteView = true;
            } else {
                this.showCategoryView = false;
                this.showSubCategoryView = true;
                this.showNoteView = false;
            }
        } else {
            this.showCategoryView = false;
            this.showSubCategoryView = true;
            this.showNoteView = false;
        }
        this.animateTransition();
    }

    handleSubCategoryClick(event) {
        const subCategoryKey = event.currentTarget.dataset.key;
        this.selectedSubCategory = this.selectedCategory.subCategories.find(cat => cat.key === subCategoryKey);
        if (this.selectedSubCategory.isNoteVisible) {
            this.showCategoryView = false;
            this.showSubCategoryView = false;
            this.showNoteView = true;
        }
        this.animateTransition();
    }

    handleBackClickSubCategory() {
       if (this.selectedSubCategory.hideSubGroup) {
            this.handleBackClick();
        } else {
            this.showCategoryView = false;
            this.showSubCategoryView = true;
            this.showNoteView = false;
            this.animateTransition();
        }
    }
   
    handleBackClick() {
        this.showCategoryView = true;
        this.showSubCategoryView = false;
        this.showNoteView = false;
        this.selectedCategory = null;
        this.selectedSubCategory = null;
        this.animateTransition();
    }
   
    animateTransition() {
        const content = this.template.querySelector('.slds-grid');
        if (content) {
            content.style.opacity = '0';
            content.style.transition = 'opacity 0.3s ease';
            setTimeout(() => {
                content.style.opacity = '1';
            }, 50);
        }
    }
   
    handleError(error, defaultMessage = 'An error occurred while loading alerts') {
        this.hasError = true;
        this.isLoading = false;
        if (!error || typeof error !== 'object' || Object.keys(error).length === 0) {
            this.errorMessage = defaultMessage;
            return;
        }
       
        let message = defaultMessage;
        if (error.message) {
            message = error.message;
        } else if (error.body?.message) {
            message = error.body.message;
        } else if (error.body?.errors) {
            message = error.body.errors.map(e => e.message).join(', ');
        }
       
        this.errorMessage = message;
        this.hasError = true;
        this.isLoading = false;
    }
      
    get totalAlertsCount() {
        return this.categories.reduce((total, category) => total + category.alertCount, 0);
    }
   
    get hasData() {
        return this.categories.length > 0 && !this.isLoading && !this.hasError;
    }

    handleNoteViewToggle(event) {
        const alertId = event.currentTarget.dataset.id;
        const alertIndex = this.selectedSubCategory.notes.findIndex(a => a.id === alertId);
        if (alertIndex > -1) {
            this.selectedSubCategory.notes[alertIndex].isNoteExpanded = 
                !this.selectedSubCategory.notes[alertIndex].isNoteExpanded;
            this.selectedSubCategory.notes[alertIndex].alertNoteClass = this.selectedSubCategory.notes[alertIndex].isNoteExpanded ? 'alert-note alert-note-full' : 'alert-note alert-note-clamped';
            this.selectedSubCategory.notes = [...this.selectedSubCategory.notes];
        }
    }

    get userQuery() {
        return gql`
            query GetProfile($userId: ID) {
                uiapi {
                    query {
                        User(where: { Id: { eq: $userId } }) {
                            edges {
                                node {
                                    Profile {
                                        Name {
                                            value
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        `;
    }

    get workOrderQuery() {
        return gql`
        query GetWorkOrder($workOrderId: ID) {
            uiapi {
                query {
                    WorkOrder(
                        where: { Id: { eq: $workOrderId } }
                    ) {
                        edges {
                            node {
                                Id
                                Property__c { value }
                            }
                        }
                    }
                }
            }
        }`;
    }

    get alertQuery() {
        return gql`
        query GetAlert($propertyId: ID) {
            uiapi {
                query {
                    Alert: Alert__c(
                        first: 1000,
                        where: {
                            IsActive__c: { eq: true }
                            Property__c: { eq: $propertyId }
                            Type__c: { eq: "Property" }
                        },
                        orderBy: { 
                            Type__c: { order: ASC }
                            Category__c: { order: ASC }
                            SubCategory__c: { order: ASC }
                            StartDate__c: { order: DESC }
                        }   
                    ) {
                        edges {
                            node {
                                Id
                                Type__c @category(name: "record") { value }
                                Category__c @category(name: "record") { value }
                                SubCategory__c @category(name: "record") { value }
                                Notes__c @category(name: "record") { value }
                                StartDate__c @category(name: "record") { value }
                                EndDate__c @category(name: "record") { value }
                                Property__c @category(name: "record") { value }
                                Tenancy__c @category(name: "record") { value }
                                CreatedDate @category(name: "record") { value }
                                LastModifiedDate @category(name: "record") { value }
                            }
                        }
                    }
                }
            }
        }`;
    }

    get alertMapQuery() {
        return gql`
        query GetAlertMap($propertyId: ID) {
            uiapi {
                query {
                    AlertMap: AlertMap__c(
                        first: 1000,
                        where: {
                            Property__c: { eq: $propertyId }
                            Alert__r: { 
                                IsActive__c: { eq: true }
                                Type__c: { in: ["Person", "Tenancy"] }
                            }
                        }
                        orderBy: {
                            Alert__r: { 
                                Type__c:  { order: ASC } 
                                Category__c:  { order: ASC }
                                SubCategory__c:  { order: ASC }
                                StartDate__c: { order: DESC }
                            }
                        }
                    ) {
                        edges {
                            node {
                                Id
                                Alert__c { value }
                                Alert__r {
                                    Id
                                    Type__c @category(name: "record") { value }
                                    Category__c @category(name: "record") { value }
                                    SubCategory__c @category(name: "record") { value }
                                    Notes__c @category(name: "record") { value }
                                    StartDate__c @category(name: "record") { value }
                                    EndDate__c @category(name: "record") { value }
                                    Contact__c @category(name: "record") { value }
                                    Property__c @category(name: "record") { value }
                                    Tenancy__c @category(name: "record") { value }
                                    CreatedDate @category(name: "record") { value }
                                    LastModifiedDate @category(name: "record") { value }
                                }
                                Property__c @category(name: "record") { value }
                                Tenancy__c @category(name: "record") { value }
                                Member__c @category(name: "record") { value }
                                Notes__c @category(name: "record") { value }
                                CreatedDate @category(name: "record") { value }
                                LastModifiedDate @category(name: "record") { value }
                            }
                        }
                    }
                }
            }
        }`;
    }

    
}