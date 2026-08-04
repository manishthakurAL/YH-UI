public inherited sharing class CaseRoleSetupService {
     
    private Map<Id, List<Member__c>> memberMap{
        get{
            if(this.memberMap == null){
                this.memberMap = new Map<Id, List<Member__c>>();
                if(!this.tenancyId.isEmpty()){
                    for(YH_Tenancy__c tenancy : [SELECT Id,
                                (SELECT Id, Contact__c
                                FROM Member__r
                                WHERE  ( Type__c =: MemberDecorator.TYPE_SOLO OR Type__c =: MemberDecorator.TYPE_JOINT ) AND IsActive__c = true)
                            FROM YH_Tenancy__c
                            WHERE Id IN: this.tenancyId]){
                        if(!tenancy.Member__r.isEmpty()){
                            for(Member__c member : tenancy.Member__r){
                                if(!this.memberMap.containsKey(tenancy.Id)){
                                    this.memberMap.put(tenancy.Id, new List<Member__c>{member});
                                } else {
                                    this.memberMap.get(tenancy.Id).add(member);
                                }
                            }
                        }
                    }
                }
            }
            return this.memberMap;
        }
        private set;
    }

    Map<Id,Case> caseIdCaseMap;
    Map<Id,List<String>> fieldListByCaseId;
    private List<Id> tenancyId;

    public CaseRoleSetupService(Map<Id,Case> caseIdCaseMap){
        this.caseIdCaseMap = caseIdCaseMap;
        this.tenancyId = new List<Id>();
        for(Case cse : caseIdCaseMap.values()){
            if(cse.Tenancy__c != null){
                this.tenancyId.add(cse.Tenancy__c);
            }
        }
    }

    public CaseRoleSetupService(Map<Id,Case> caseIdCaseMap, Map<Id,List<String>> fieldListByCaseId){
        this.caseIdCaseMap = caseIdCaseMap;
        this.fieldListByCaseId = fieldListByCaseId;
        this.tenancyId = new List<Id>();
        for(Case cse : caseIdCaseMap.values()){
            if(cse.Tenancy__c != null){
                this.tenancyId.add(cse.Tenancy__c);
            }
        }
    }

    public Map<Id, String> setupCaseRoles(){
        List<CaseRole__c> caseRoleToInsert = new List<CaseRole__c>();
        Map<Id, String> caseErrorById = new Map<Id, String>();
        for(Id caseId : this.caseIdCaseMap.keySet()){
            Case caseRecord = this.caseIdCaseMap.get(caseId);
            String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
            String caseType = caseRecord.CaseType__c;

            if(AutoCaseRoleCreationByCaseRTDecorator.autoCaseRoleCreationByCaseRTMap.containsKey(caseRecordType)){
                if(AutoCaseRoleCreationByCaseTypeDecorator.autoCaseRoleCreationByCaseTypeMap.containsKey(caseRecordType)){
                    if(AutoCaseRoleCreationByCaseTypeDecorator.autoCaseRoleCreationByCaseTypeMap.get(caseRecordType).containsKey(caseType)
                            || AutoCaseRoleCreationByCaseTypeDecorator.autoCaseRoleCreationByCaseTypeMap.get(caseRecordType).containsKey(null)){
                        Boolean caseTypeMetaDataExist = AutoCaseRoleCreationByCaseTypeDecorator.autoCaseRoleCreationByCaseTypeMap.get(caseRecordType).containsKey(caseType);
                        AutoCaseRoleCreationByCaseType__mdt autoCaseRoleCreationByCaseType = caseTypeMetaDataExist ? AutoCaseRoleCreationByCaseTypeDecorator.autoCaseRoleCreationByCaseTypeMap.get(caseRecordType).get(caseType)
                                                                                                                : AutoCaseRoleCreationByCaseTypeDecorator.autoCaseRoleCreationByCaseTypeMap.get(caseRecordType).get(null);
                        if(AutoCaseRoleCreationDetailDecorator.autoCaseRoleCreationDetailMap.containsKey(autoCaseRoleCreationByCaseType.Id)){
                            caseRoleToInsert.addAll(buildCaseRole(
                                AutoCaseRoleCreationDetailDecorator.autoCaseRoleCreationDetailMap.get(autoCaseRoleCreationByCaseType.Id),
                                caseRecord

                            ));
                        } else {
                            if(caseRecord.Reporter__c != null && (this.fieldListByCaseId == null || this.fieldListByCaseId.get(caseRecord.Id).contains(CaseDecorator.FIELD_REPORTER))){
                                caseRoleToInsert.add(buildReporterCaseRole(caseRecord));
                            }
                        }
                    } else{
                        caseErrorById.put(caseId, 'Metadata record for AutoCaseRoleCreationByCaseType__mdt is missing for Case Record Type: ' + caseRecordType);
                    }
                } else {
                    caseErrorById.put(caseId, 'Metadata record for AutoCaseRoleCreationByCaseType__mdt is missing for Case Record Type: ' + caseRecordType);
                }
            }
        }

        if(!caseRoleToInsert.isEmpty()){
            TriggerBase.bypass('Case');
            Database.SaveResult[] results = Database.insert(caseRoleToInsert, false);
            TriggerBase.clearBypass('Case');

            Integer index = 0;
            for(Database.SaveResult result : results) {
                if (!result.isSuccess()) {
                    caseErrorById.put(caseRoleToInsert[index].Case__c, 'Failed to create CaseRole record with Error: ' + result.getErrors()[0].getStatusCode() + ' ' + result.getErrors()[0].getMessage());
                }
                index++;
            }
        }

        return caseErrorById;
    }

    private List<CaseRole__c> buildCaseRole(List<AutoCaseRoleCreationDetail__mdt> caseRoleMappingList, Case caseRecord){
        CaseRoleService caseRoleService = new CaseRoleService();
        List<CaseRole__c> caseRoleToInsert = new List<CaseRole__c>();
        for(AutoCaseRoleCreationDetail__mdt autoCaseRoleCreationDetail : caseRoleMappingList){
            if(autoCaseRoleCreationDetail.Option__c == AutoCaseRoleCreationDetailDecorator.OPTION_CASE_CONTACT && caseRecord.ContactId != null
                && (this.fieldListByCaseId == null || this.fieldListByCaseId.get(caseRecord.Id).contains(CaseDecorator.FIELD_CONTACT))){
                caseRoleToInsert.add(
                    caseRoleService.populateCaseRole(
                        caseRecord.Id,
                        caseRecord.ContactId,
                        autoCaseRoleCreationDetail.Role__c
                    )
                );
            } else if(autoCaseRoleCreationDetail.Option__c == AutoCaseRoleCreationDetailDecorator.OPTION_TENANCY
                        && (this.fieldListByCaseId == null || this.fieldListByCaseId.get(caseRecord.Id).contains(CaseDecorator.FIELD_TENANCY))){
                if(memberMap.containsKey(caseRecord.Tenancy__c)){
                    for(Member__c member : memberMap.get(caseRecord.Tenancy__c)){
                        caseRoleToInsert.add(
                            caseRoleService.populateCaseRole(
                                caseRecord.Id,
                                member.Contact__c,
                                autoCaseRoleCreationDetail.Role__c
                            )
                        );
                    }
                }
            }
        }
        
        if(caseRecord.Reporter__c != null && (this.fieldListByCaseId == null || this.fieldListByCaseId.get(caseRecord.Id).contains(CaseDecorator.FIELD_REPORTER))){
            caseRoleToInsert.add(buildReporterCaseRole(caseRecord));
        }

        return caseRoleToInsert;
    }

    private CaseRole__c buildReporterCaseRole(Case caseRecord){
        CaseRoleService caseRoleService = new CaseRoleService();
        return caseRoleService.populateCaseRole(
            caseRecord.Id,
            caseRecord.Reporter__c,
            CaseRoleDecorator.REPORTER_ROLE
        );
    }

}