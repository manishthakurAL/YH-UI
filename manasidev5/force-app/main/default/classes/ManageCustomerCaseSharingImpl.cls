public with sharing class ManageCustomerCaseSharingImpl implements IManageCustomerDataSharing{
    private static final String USER_PREFIX = '005';
    private List<Id> recordIds;

    private Map<Id, Case> caseMap{
        get{
            if(this.caseMap == null){
                this.caseMap = new Map<Id, Case>();
                if(this.recordIds != null && !this.recordIds.isEmpty()){
                    this.caseMap = new Map<Id, Case>([SELECT Id, ContactID, Reporter__c, RecordType.DeveloperName, CaseType__c, CustomerSharingReasons__c
                                                        FROM Case 
                                                        WHERE Id IN : this.recordIds]);
                }
            }
            return this.caseMap;
        }
        set;
    }

    private Map<Id, Id> contactIdByCaseIdMap{
        get{
            if(this.contactIdByCaseIdMap == null){
                this.contactIdByCaseIdMap = new Map<Id, Id>();
                if(!this.caseMap.isEmpty()){
                    for(Case c: this.caseMap.values()){
                        if(c.ContactID != null){
                            this.contactIdByCaseIdMap.put(c.Id, c.ContactID);
                        }
                    }
                }
            }
            
            return this.contactIdByCaseIdMap;
        }
        set;
    }

    private Map<Id, Id> reporterIdByCaseIdMap{
        get{
            if(this.reporterIdByCaseIdMap == null){
                this.reporterIdByCaseIdMap = new Map<Id, Id>();
                if(!this.caseMap.isEmpty()){
                    for(Case c: this.caseMap.values()){
                        if(c.Reporter__c != null){
                            this.reporterIdByCaseIdMap.put(c.Id, c.Reporter__c);
                        }
                    }
                }
            }
            
            return this.reporterIdByCaseIdMap;
        }
        set;
    }

    private Map<Id, User> userByContactIdMap{
        get{
            if(this.userByContactIdMap == null){
                this.userByContactIdMap = new Map<Id, User>();
                if(!this.contactIdByCaseIdMap.isEmpty()){
                    for(User user : [SELECT Id, ContactId, IsActive
                                        FROM User 
                                        WHERE ContactId IN: this.contactIdByCaseIdMap.values() AND 
                                            Profile.Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN]){
                        this.userByContactIdMap.put(user.ContactId, user);
                    }
                }
            }
            return this.userByContactIdMap;
        }
        set;
    }

    private List<CaseShare> caseShares{
        get{
            if(this.caseShares == null){
                this.caseShares = new List<CaseShare>();
                if(!this.caseMap.isEmpty() && !this.userByContactIdMap.isEmpty()){
                    for(CaseShare caseShare : [SELECT Id, CaseId, UserOrGroupId
                                                FROM CaseShare
                                                WHERE CaseId IN : this.caseMap.keySet() AND
                                                 RowCause =: Schema.CaseShare.RowCause.Manual]){
                        this.caseShares.add(caseShare);
                    }
                }
            }
            return this.caseShares;
        }
        set;
    }

    private List<Id> userIds{
        get{
            if(this.userIds == null){
                this.userIds = new List<Id>();
                if(!this.caseShares.isEmpty()){
                    for(CaseShare caseShare : this.caseShares){
                        if(String.valueOf(caseShare.UserOrGroupId).startsWith(USER_PREFIX)){
                            this.userIds.add(caseShare.UserOrGroupId);
                        }
                    }
                }
            }
            return this.userIds;
        }
        set;
    }

    private Set<Id> customerPortalUserIds{
        get{
            if(this.customerPortalUserIds == null){
                this.customerPortalUserIds = new Set<Id>();
                for(User user : [SELECT Id, ContactId
                                    FROM User 
                                    WHERE Id IN: this.userIds AND 
                                        Profile.Name =: UserDecorator.PROFILE_CUSTOMER_COMMUNITY_PLUS_LOGIN ]){
                    this.customerPortalUserIds.add(user.Id);
                }
            }
            return this.customerPortalUserIds;
        }
        set;
    }

    private List<CaseShare> caseSharesToDelete{
        get{
            if(this.caseSharesToDelete == null){
                this.caseSharesToDelete = new List<CaseShare>();
                if(!this.caseShares.isEmpty()){
                    for(CaseShare caseShare : this.caseShares){
                        if(this.customerPortalUserIds.contains(caseShare.UserOrGroupId)){
                            caseSharesToDelete.add(caseShare);
                        }
                    }
                }
            }
            return this.caseSharesToDelete;
        }
        set;
    }

    public void manageRecordSharing(List<Id> recordIds, ManageCustomerDataSharingService.CHANGE_TYPE changeType, ManageCustomerDataSharingService.TRIGGER_CONTEXT triggerContext){
        this.recordIds = recordIds;
        if(!this.recordIds.isEmpty()){
            switch on changeType{
                when RECORD_OWNERSHIP_CHANGED{
                    handleOwnershipChangedCases(recordIds);
                }
                when RECORD_RECALCULATE_SHARING{
                    handleRecalculateSharingCases(recordIds);
                }
                when RECORD_REMOVE_SHARING{
                    handleRemoveSharingCases(recordIds);
                }
                when else {
                    // TODO logger logic
                }
            }
        }
    }

    private void handleOwnershipChangedCases(List<Id> recordIds){
        List<CaseShare> caseSharesToInsert = new List<CaseShare>();

        if(!this.caseMap.isEmpty()){
            for(Id caseid : this.caseMap.keySet()){
                Case caserecord = this.caseMap.get(caseid);
                if(String.isNotBlank(caserecord.CustomerSharingReasons__c) && String.isNotBlank(caserecord.ContactID)){
                    List<CaseShare> caseShareToInsert = buildCaseShareRecords(caserecord);
                    if(!caseShareToInsert.isEmpty()){
                        caseSharesToInsert.addAll(caseShareToInsert);
                    }
                }
            }
        }

        if(!caseSharesToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(caseSharesToInsert, false);
        }
    }

    private void handleRecalculateSharingCases(List<Id> recordIds){
        List<CaseShare> caseSharesToInsert = new List<CaseShare>();

        if(!this.caseSharesToDelete.isEmpty()){
            Database.DeleteResult[] drList = Database.delete(this.caseSharesToDelete, false);
        }

        if(!this.caseMap.isEmpty()){
            for(Id caseid : this.caseMap.keySet()){
                Case caserecord = this.caseMap.get(caseid);
                if(String.isNotBlank(caserecord.CustomerSharingReasons__c) && String.isNotBlank(caserecord.ContactID)){
                    List<CaseShare> caseShareToInsert = buildCaseShareRecords(caserecord);
                    if(!caseShareToInsert.isEmpty()){
                        caseSharesToInsert.addAll(caseShareToInsert);
                    }
                }
            }
        }

        if(!caseSharesToInsert.isEmpty()){
            Database.SaveResult[] srList = Database.insert(caseSharesToInsert, false);
        }
    }

    private void handleRemoveSharingCases(List<Id> recordIds){
        if(!this.caseSharesToDelete.isEmpty()){
            Database.DeleteResult[] drList = Database.delete(this.caseSharesToDelete, false);
        }
    }

    private List<CaseShare> buildCaseShareRecords(Case caserecord){
        List<CaseShare> caseShareToInsert = new List<CaseShare>();
        string caseRecordType = caserecord.RecordType.DeveloperName;
        String caseType = caseRecord.CaseType__c;
        CaseExternalSharingMetaDataService caseExtSharingMetadata = new CaseExternalSharingMetaDataService(caseRecordType);
        if(caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.containsKey(caseType) && 
                userByContactIdMap.containsKey(caserecord.ContactID) &&
                userByContactIdMap.get(caserecord.ContactID).IsActive == TRUE){
            List<String> sharingReason = caserecord.CustomerSharingReasons__c.split(';');
            List<CaseExternalSharingDetail__mdt> caseSharingDetails = caseExtSharingMetadata.caseExtSharingDetailByCaseTypeMap.get(caseType);
            for(String reason : sharingReason){
                for(CaseExternalSharingDetail__mdt detail : caseSharingDetails){
                    if(reason == detail.ShareWith__c){
                        Id caseId = caserecord.Id;
                        Id userId;
                        if(reason == CaseDecorator.CASESHARINGREASON_TENANT){
                            userId = userByContactIdMap.get(caserecord.ContactID).Id;
                        } else if(reason == CaseDecorator.CASESHARINGREASON_ACCUSEDPARTY){
                            userId = userByContactIdMap.get(caserecord.ContactID).Id;
                        }
                        if(userId != null){
                            caseShareToInsert.add(
                                new CaseService().buildCaseShareWithManualSharing(
                                    caseId,
                                    userId,
                                    detail.AccessLevel__c,
                                    Schema.CaseShare.RowCause.Manual
                                )
                            );
                        }
                    }
                }
            }
        }
        
        return caseShareToInsert;
    }
}