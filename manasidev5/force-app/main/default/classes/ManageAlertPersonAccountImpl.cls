public inherited sharing class ManageAlertPersonAccountImpl implements IManageAlertInterface{
    private Map<Id, Account> accountNewMap;
    private Map<Id, Account> accountOldMap;

    private Map<Id,Account> accountByContactId{
        get{
            if(this.accountByContactId == null){
                this.accountByContactId = new Map<Id,Account>();    
                for(Account accountRec : this.accountNewMap.values()){
                    this.accountByContactId.put(accountRec.PersonContactId, accountRec);
                }
            }
            return this.accountByContactId;    
        }
        set;
    }

    private Set<Id> birthDateContactIds{
        get{
            if(this.birthDateContactIds == null){
                this.birthDateContactIds = new Set<Id>();
                for(Account accountRec : this.accountNewMap.values()){
                    if( accountRec.PersonBirthdate != null ){
                        if(!this.accountOldMap.containskey(accountRec.Id)){
                            if(accountRec.PersonBirthdate > Date.today().addYears(-18)){
                                this.birthDateContactIds.add(accountRec.PersonContactId);
                            }
                        }else if(accountRec.PersonBirthdate != this.accountOldMap.get(accountRec.Id).PersonBirthdate){                        
                            this.birthDateContactIds.add(accountRec.PersonContactId);
                        }
                    }else{
                        if(this.accountOldMap.containskey(accountRec.Id) && accountRec.PersonBirthdate != this.accountOldMap.get(accountRec.Id).PersonBirthdate){
                            this.birthDateContactIds.add(accountRec.PersonContactId);
                        }
                    }
                }           
            }
            return this.birthDateContactIds;
        }
        set;
    }

    private Map<Id, String> disabilityByContactId{
        get{
            if(this.disabilityByContactId == null){
                this.disabilityByContactId = new Map<Id, String>();
                for(Account accountRec : this.accountNewMap.values()){
                    if(!accountOldMap.containskey(accountRec.Id)){
                        if(accountRec.YH_Disability__pc != null){
                            this.disabilityByContactId.put(accountRec.PersonContactId, accountRec.YH_Disability__pc);
                        }
                    }else if(accountRec.YH_Disability__pc != accountOldMap.get(accountRec.Id).YH_Disability__pc){
                        this.disabilityByContactId.put(accountRec.PersonContactId, accountRec.YH_Disability__pc);
                    }
                }
            }
            return this.disabilityByContactId;
        }
        set;
    }

    private List<Alert__c> existingAlertsList{
        get{
            if(this.existingAlertsList == null){
                this.existingAlertsList = new List<Alert__c>();
                for(Alert__c alertRec : [SELECT Id, Contact__c, Category__c, SubCategory__c, IsActive__c 
                            FROM Alert__c 
                            WHERE Contact__c IN: this.accountByContactId.keySet() AND
                            Type__c =: AlertDecorator.TYPE_PERSON AND
                            IsActive__c = true]){
                    this.existingAlertsList.add(alertRec);                                
                }
            }
            return this.existingAlertsList;
        }
        set;
    }

    private Map<Id, Alert__c> existingBirthDateAlertByContactId{
        get{
            if(this.existingBirthDateAlertByContactId == null){
                this.existingBirthDateAlertByContactId = new Map<Id, Alert__c>();
                for(Alert__c alertRec : this.existingAlertsList){
                    if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18){
                        this.existingBirthDateAlertByContactId.put(alertRec.Contact__c, alertRec);
                    }
                }
            }
            return this.existingBirthDateAlertByContactId;
        }
        set;
    }

    private Map<Id, List<Alert__c>> existingDisabilityAlertsByContactId{
        get{
            if(this.existingDisabilityAlertsByContactId == null){
                this.existingDisabilityAlertsByContactId = new Map<Id, List<Alert__c>>();
                for(Alert__c alertRec : this.existingAlertsList){
                    if(alertRec.Category__c == AlertDecorator.CATEGORY_DISABILITY){
                        if(!this.existingDisabilityAlertsByContactId.containsKey(alertRec.Contact__c)){
                            this.existingDisabilityAlertsByContactId.put(alertRec.Contact__c, new List<Alert__c>{alertRec});
                        }else{
                            this.existingDisabilityAlertsByContactId.get(alertRec.Contact__c).add(alertRec);
                        }
                    }
                }
            }
            return this.existingDisabilityAlertsByContactId;
        }
        set;
    }
                    

    private List<Alert__c> addBirthDateAlerts{
        get{
            if(this.addBirthDateAlerts == null){
                this.addBirthDateAlerts = new List<Alert__c>();
                for(Id contactId : this.birthDateContactIds){
                    validateBirthDateAlerts(contactId);
                }
            }
            return this.addBirthDateAlerts;
        }
        set;
    }

    private List<Alert__c> addDisabilityAlerts{
        get{
            if(this.addDisabilityAlerts == null){
                this.addDisabilityAlerts = new List<Alert__c>();
                for(Id contactId : this.disabilityByContactId.keyset()){
                    validateDisabilityAlerts(contactId);
                }
            }
            return this.addDisabilityAlerts;
        }
        set;
    }

    public void setUpAlerts(List<SObject> newList, List<SObject> oldList){
        this.accountNewMap = new Map<Id, Account>((List<Account>)newList);
        this.accountOldMap = oldList != null? new Map<Id, Account>((List<Account>)oldList) : new Map<Id, Account>();
        
        List<Alert__c> alertRecordsToUpsert = new List<Alert__c>();

        if(!this.addBirthDateAlerts.isEmpty()){
            alertRecordsToUpsert.addAll(this.addBirthDateAlerts);
        }
        
        if(!this.addDisabilityAlerts.isEmpty()){
            alertRecordsToUpsert.addAll(this.addDisabilityAlerts);
        }

        if(!alertRecordsToUpsert.isEmpty()){
            BypassFlowHandler.bypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
            upsert alertRecordsToUpsert;
            BypassFlowHandler.clearBypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
        }
    }

    private void validateBirthDateAlerts(Id contactId){
        if(!this.existingBirthDateAlertByContactId.containsKey(contactId) && this.accountByContactId.get(contactId).PersonBirthDate != null){
            this.addBirthDateAlerts.add(
                new Alert__c(
                    Contact__c = contactId,
                    Type__c = AlertDecorator.TYPE_PERSON,
                    Category__c = AlertDecorator.CATEGORY_CUSTOMER,
                    SubCategory__c = AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18,
                    StartDate__c = this.accountByContactId.get(contactId).PersonBirthDate,
                    EndDate__c = this.accountByContactId.get(contactId).PersonBirthDate?.addYears(18)                                
                )
            );
        }else{
            Alert__c alertRec = this.existingBirthDateAlertByContactId.get(contactId);
            if(alertRec != null){
                if(this.accountByContactId.get(contactId).PersonBirthDate == null){
                    alertRec.EndDate__c = Date.today() - 1;
                }else{
                    alertRec.StartDate__c = this.accountByContactId.get(contactId).PersonBirthDate;
                    alertRec.EndDate__c = this.accountByContactId.get(contactId).PersonBirthDate.addYears(18);
                }
                this.addBirthDateAlerts.add(alertRec);
            }
        }     
    }

    private void validateDisabilityAlerts(Id contactId){
        String disability = this.accountByContactId.get(contactId).YH_Disability__pc;

        if(!this.existingDisabilityAlertsByContactId.containsKey(contactId)){
            List<String> newDisabilityList = disability!=null? disability.split(';'): new List<String>();
            addNewDisabilityAlerts(disability.split(';'), contactId);
        }else{
            List<String> existingDisabilityList = getExistingDisability(contactId);
            List<String> newDisabilityList = disability!=null? disability.split(';'): new List<String>();
            List<String> disabilityToBeAdded = compareList(newDisabilityList, existingDisabilityList);
            List<String> disabilityToBeRemoved = compareList(existingDisabilityList, newDisabilityList);   
            if(!disabilityToBeAdded.isEmpty()){
                addNewDisabilityAlerts(disabilityToBeAdded, contactId);
            }
            if(!disabilityToBeRemoved.isEmpty()){
                updateExistingAlerts(disabilityToBeRemoved, contactId);
            }
        }
    }

    private void addNewDisabilityAlerts(List<String> disabilities, Id contactId){
        for(String disability : disabilities){
            if(disability!=null && !AccountDecorator.DISABILITY_TO_IGNORE_ALERTS.contains(disability)){
                this.addDisabilityAlerts.add(
                    new Alert__c(
                        Contact__c = contactId,
                        Type__c = AlertDecorator.TYPE_PERSON,
                        Category__c = AlertDecorator.CATEGORY_DISABILITY,
                        SubCategory__c = disability,
                        StartDate__c = system.today()                          
                    )
                );
            }
        }
    }

    private void updateExistingAlerts(List<String> disabilities, Id contactId){
        for(Alert__c alertRec : this.existingDisabilityAlertsByContactId.get(contactId)){
            if(disabilities.contains(alertRec.SubCategory__c)){
                alertRec.EndDate__c = system.today().addDays(-1);
                this.addDisabilityAlerts.add(alertRec);
            }
        }
    }

    private List<String> getExistingDisability(Id contactId){
        List<String> disabilityList = new List<String>();
        for(Alert__c alertRec : this.existingDisabilityAlertsByContactId.get(contactId)){
            disabilityList.add(alertRec.SubCategory__c);
        }
        return disabilityList;
    }

    private List<String> compareList(List<String> listOne, List<String> listTwo){
        List<String> returnList = new List<String>();
        for(String disValue : listOne){
            if(!listTwo.contains(disValue)){
                returnList.add(disValue);
            }
        }
        return returnList;
    }
}