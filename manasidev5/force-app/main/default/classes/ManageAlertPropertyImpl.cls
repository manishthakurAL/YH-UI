public with sharing class ManageAlertPropertyImpl implements IManageAlertInterface {

    List<YH_Property__c> properties;
    Map<Id, YH_Property__c> oldMap;

    private List<Alert__c> alertsToUpsert = new List<Alert__c>();
    public class MapperConfig {
        String category;
        String statusField;
        String startDateField;
        String endDateField;
        Map<String, Mapper> mapper;
        public MapperConfig(String category, String statusField, String startDateField, String endDateField, Map<String, Mapper> mapper) {
            this.category = category;
            this.statusField = statusField;
            this.startDateField = startDateField;
            this.endDateField = endDateField;
            this.mapper = mapper;
        }
    }

    public class Mapper {
        String type;
        String category;
        String subCategory;
        public Mapper(String type, String category, String subCategory) {
            this.type = type;
            this.category = category;
            this.subCategory = subCategory;
        }
    }

    public void setUpAlerts(List<SObject> newList, List<SObject> oldList) {
        this.properties = (List<YH_Property__c>) newList;
        this.oldMap = (oldList != null) ? new Map<Id, YH_Property__c>((List<YH_Property__c>)oldList) : new Map<Id, YH_Property__c>();       
        processAlerts();
    }

    private void processAlerts() {
        for (YH_Property__c property : this.alertedProperties) {
            YH_Property__c oldProperty = this.oldMap.get(property.Id);
            for (MapperConfig config : this.alertMapper) {
                this.processForAlerts(property, oldProperty, config);
            }
        }
        if (!alertsToUpsert.isEmpty()) {
            BypassFlowHandler.bypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
            upsert alertsToUpsert;
            BypassFlowHandler.clearBypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
        }
    }

    private void processForAlerts(YH_Property__c property, YH_Property__c oldProperty, MapperConfig config) {
        String currentStatus = (String)property.get(config.statusField);
        String oldStatus = (oldProperty != null) ? (String)oldProperty.get(config.statusField) : '-';
        Date startDt = (Date)property.get(config.startDateField);
        Date endDt = (Date)property.get(config.endDateField);
        Date oldStart = (oldProperty != null) ? (Date)oldProperty.get(config.startDateField) : null;
        Date oldEnd = (oldProperty != null) ? (Date)oldProperty.get(config.endDateField) : null;
        Boolean isStartChanged = startDt != oldStart;
        Boolean isEndChanged = endDt != oldEnd;
        Boolean isStatusChanged = currentStatus != oldStatus;

        String keyOnCurrentStatus = getKey(property.Id, currentStatus, config);
        String keyOnOldStatus = getKey(property.Id, oldStatus, config);
        Alert__c existingAlert = this.existingAlertMap.get(keyOnCurrentStatus);
        Alert__c existingAlertOldStatus = this.existingAlertMap.get(keyOnOldStatus);
 
        if (config.mapper.containsKey(currentStatus) && (isStatusChanged || isStartChanged || isEndChanged)) {
            Alert__c alert = (existingAlert != null) ? existingAlert : new Alert__c();
            alert.Property__c = property.Id; 
            alert.Type__c = config.mapper.get(currentStatus).type;
            alert.Category__c = config.mapper.get(currentStatus).category;
            alert.SubCategory__c = config.mapper.get(currentStatus).subCategory;
            alert.StartDate__c = startDt;
            alert.EndDate__c = endDt;
            alertsToUpsert.add(alert);
        } 
        if ( isStatusChanged && existingAlertOldStatus != null) {
            existingAlertOldStatus.EndDate__c = System.today().addDays(-1);
            alertsToUpsert.add(existingAlertOldStatus);
        }
    }

    private String getKey(String propertyId, String status, MapperConfig config) {
        return getKey(propertyId, config.mapper.get(status)?.category, config.mapper.get(status)?.subCategory);
    }

    private String getKey(String propertyId, String category, String subCategory) {
        return propertyId + '-' + category + '-' + subCategory;

    }

    private List<YH_Property__c> alertedProperties {
        get {
            if (this.alertedProperties == null) {
                this.alertedProperties = new List<YH_Property__c>();
                for (YH_Property__c property : this.properties) {
                    YH_Property__c oldProperty = this.oldMap.get(property.Id);
                     Boolean hasAlert = false;
                    if (oldProperty != null) {
                        hasAlert = (
                            property.AsbestosStatus__c != oldProperty.AsbestosStatus__c ||
                            property.RightToBuyOrAcquire__c != oldProperty.RightToBuyOrAcquire__c ||
                            property.Section20ConsultationRequired__c != oldProperty.Section20ConsultationRequired__c ||
                            property.AsbestosStatusStartDate__c != oldProperty.AsbestosStatusStartDate__c ||
                            property.AsbestosStatusEndDate__c != oldProperty.AsbestosStatusEndDate__c ||
                            property.RighttoBuyorAcquireStartDate__c != oldProperty.RighttoBuyorAcquireStartDate__c ||
                            property.RighttoBuyorAcquireEndDate__c != oldProperty.RighttoBuyorAcquireEndDate__c ||  
                            property.Section20ConsultationReqStartDate__c != oldProperty.Section20ConsultationReqStartDate__c ||
                            property.Section20ConsultationReqEndDate__c != oldProperty.Section20ConsultationReqEndDate__c
                        );
                    } else {
                        hasAlert = (
                            (String.isNotBlank(property.AsbestosStatus__c) && property.AsbestosStatusStartDate__c != null) ||
                            (String.isNotBlank(property.RightToBuyOrAcquire__c) && property.RighttoBuyorAcquireStartDate__c != null) ||
                            (String.isNotBlank(property.Section20ConsultationRequired__c) && property.Section20ConsultationReqStartDate__c != null)
                        );
                    }
                    if (hasAlert) {
                        this.alertedProperties.add(property);
                    }
                }
            }
            return this.alertedProperties;
        } set;
    }

    private Map<String, Alert__c> existingAlertMap {
        get {
            if (this.existingAlertMap == null) {
                this.existingAlertMap = new Map<String, Alert__c>();
                List<String> categories = new List<String>{
                    AlertDecorator.CATEGORY_PROPERTY,
                    AlertDecorator.CATEGORY_ASBESTOS
                };
                List<String> subCategories = new List<String>{
                    PropertyDecorator.ASBESTOS_ASSUMED,
                    PropertyDecorator.NO_ASBESTOS_ASSUMED,
                    PropertyDecorator.RIGHT_TO_ACQUIRE,
                    PropertyDecorator.RIGHT_TO_BUY,
                    AlertDecorator.SUB_CATEGORY_SECTION_20
                };
                for (Alert__c alertRec : [
                    SELECT 
                    Id, Property__c, Type__c, Category__c, SubCategory__c 
                    FROM Alert__c 
                    WHERE Property__c IN :this.alertedProperties AND IsActive__c = true 
                    AND Type__c = :AlertDecorator.TYPE_PROPERTY AND Category__c IN :categories AND SubCategory__c IN :subCategories
                    ORDER BY CreatedDate DESC]) {
                    this.existingAlertMap.put(this.getKey(alertRec.Property__c, alertRec.Category__c, alertRec.SubCategory__c), alertRec);
                }
            }
            return this.existingAlertMap;

        } set;
    }

    private List<MapperConfig> alertMapper {
        get {
            if (this.alertMapper == null) {
                this.alertMapper = new List<MapperConfig>();
                alertMapper.addAll(new List<MapperConfig>{
                    new MapperConfig(
                        AlertDecorator.CATEGORY_PROPERTY, 
                        PropertyDecorator.ASBESTOS_STATUS_FLD, 
                        PropertyDecorator.ASBESTOS_STATUS_START_DATE_FLD, 
                        PropertyDecorator.ASBESTOS_STATUS_END_DATE_FLD, 
                        new Map<String, Mapper>{
                            PropertyDecorator.ASBESTOS_ASSUMED => new Mapper(AlertDecorator.TYPE_PROPERTY, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.ASBESTOS_ASSUMED),
                            PropertyDecorator.NO_ASBESTOS_ASSUMED => new Mapper(AlertDecorator.TYPE_PROPERTY, AlertDecorator.CATEGORY_ASBESTOS, PropertyDecorator.NO_ASBESTOS_ASSUMED)
                        }
                    ),
                    new MapperConfig(
                        AlertDecorator.CATEGORY_PROPERTY, 
                        PropertyDecorator.RIGHT_TO_BUY_STATUS_FLD, 
                        PropertyDecorator.RIGHT_TO_BUY_START_DATE_FLD, 
                        PropertyDecorator.RIGHT_TO_BUY_END_DATE_FLD, 
                        new Map<String, Mapper>{
                            PropertyDecorator.RIGHT_TO_BUY => new Mapper(AlertDecorator.TYPE_PROPERTY, AlertDecorator.CATEGORY_PROPERTY, PropertyDecorator.RIGHT_TO_BUY),
                            PropertyDecorator.RIGHT_TO_ACQUIRE => new Mapper(AlertDecorator.TYPE_PROPERTY, AlertDecorator.CATEGORY_PROPERTY, PropertyDecorator.RIGHT_TO_ACQUIRE)
                        }
                    ),
                    new MapperConfig(
                        AlertDecorator.CATEGORY_PROPERTY, 
                        PropertyDecorator.SECTION_20_STATUS_FLD, 
                        PropertyDecorator.SECTION_20_START_DATE_FLD, 
                        PropertyDecorator.SECTION_20_END_DATE_FLD, 
                        new Map<String, Mapper>{
                            PropertyDecorator.SECTION_20_YES => new Mapper(AlertDecorator.TYPE_PROPERTY, AlertDecorator.CATEGORY_PROPERTY, AlertDecorator.SUB_CATEGORY_SECTION_20)
                        }
                    )
                });
            }
            return this.alertMapper;
        } set;
    }
}