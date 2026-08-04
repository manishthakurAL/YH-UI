public inherited sharing class ManageAlertAdvocateImpl implements IManageAlertInterface{
    private Map<Id, Advocate__c> advocateMap;
    
    private Map<Id, List<Alert__c>> existingAlertsByAdvocateId{
        get{
            if(existingAlertsByAdvocateId == null){
                existingAlertsByAdvocateId = new Map<Id, List<Alert__c>>();
                for(Alert__c alertRec : [SELECT Id, Advocate__c 
                            FROM Alert__c 
                            WHERE Advocate__c IN : this.advocateMap.keySet()]){
                    if(existingAlertsByAdvocateId.containsKey(alertRec.Advocate__c)){
                        existingAlertsByAdvocateId.get(alertRec.Advocate__c).add(alertRec);
                    }else{
                        existingAlertsByAdvocateId.put(alertRec.Advocate__c, new List<Alert__c>{alertRec});
                    }
                }
            }
            return existingAlertsByAdvocateId;
        }
        set;
    }

    private List<Alert__c> alertRecordsToUpsert{
        get{
            if(alertRecordsToUpsert == null){
                alertRecordsToUpsert = new List<Alert__c>();
                for(Advocate__c advRec : this.advocateMap.values()){
                    if(existingAlertsByAdvocateId.containsKey(advRec.Id)){
                        addExistingAlerts(advRec);           
                    }else{
                        addNewAlerts(advRec);
                    }
                }
            }
            return alertRecordsToUpsert;
        }
        set;
    }

    public void setUpAlerts(List<SObject> newList, List<SObject> oldList){
        this.advocateMap = new Map<Id, Advocate__c>((List<Advocate__c>)newList);
        if(!this.alertRecordsToUpsert.isEmpty()){
            BypassFlowHandler.bypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
            upsert this.alertRecordsToUpsert;
            BypassFlowHandler.clearBypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
        }
    }

    private void addExistingAlerts(Advocate__c advRec){
        for(Alert__c alrtRec : existingAlertsByAdvocateId.get(advRec.Id)){
            alrtRec.EndDate__c = advRec.EndDate__c;
            alrtRec.StartDate__c = advRec.StartDate__c;
            this.alertRecordsToUpsert.add(alrtRec);
        }
    }    

    private void addNewAlerts(Advocate__c advRec){
        String toSubCategory;
        String bySubCategory;
        
        if(advRec.AuthorisationType__c == AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY){
            toSubCategory = AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY;
            bySubCategory = AlertDecorator.SUB_CATEGORY_GRANTED_DELEGATEDAUTHORITY;
        }else if(advRec.AuthorisationType__c == AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY){
            toSubCategory = AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY;
            bySubCategory = AlertDecorator.SUB_CATEGORY_GRANTED_POWEROFATTORNEY;
        }
        String notes = String.format(
            Label.AlertNotesByAuthorisationType,
            new List<String>{
                advRec.AuthorisedByFullName__c,
                bySubCategory,                
                advRec.AuthorisedToFullName__c,
                toSubCategory
            }
        );
        this.alertRecordsToUpsert.add(
            new Alert__c(
                Advocate__c = advRec.Id,
                Type__c = AlertDecorator.TYPE_PERSON,
                Category__c = AlertDecorator.CATEGORY_AUTHORISATION_TYPE,
                SubCategory__c = toSubCategory,
                StartDate__c = advRec.StartDate__c,
                EndDate__c = advRec.EndDate__c,
                Contact__c = advRec.AuthorisedTo__c,
                Notes__c = notes
            )
        );
        this.alertRecordsToUpsert.add(
            new Alert__c(
                Advocate__c = advRec.Id,
                Type__c = AlertDecorator.TYPE_PERSON,
                Category__c = AlertDecorator.CATEGORY_AUTHORISATION_TYPE,
                SubCategory__c = bySubCategory,
                StartDate__c = advRec.StartDate__c,
                EndDate__c = advRec.EndDate__c,
                Contact__c = advRec.AuthorisedBy__c,
                Notes__c = notes
            )
        );
    }
}