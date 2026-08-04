public with sharing class TA_Case_AU_TerminationCaseProcessClosure implements TriggerAction.AfterUpdate {
    
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        Map<Id, Case> oldMap = new Map<Id, Case>(oldList);
        Map<Id, Case> newMap = new Map<Id, Case>(newList);
        Map<Id, Case> terminationCaseMap = new Map<Id, Case>();
        List<Id> tenancyIds = new List<Id>();
        List<Id> contactIds = new List<Id>();
        Map<Id, Termination__c> terminationRecordByCaseIds  = new Map<Id, Termination__c>();


        for(Case caseRec : newList){
            if(TriggerBase.idToNumberOfTimesSeenAfterUpdate.get(caseRec.id) == 1
                && caseRec.recordTypeId == CaseDecorator.RECORD_TYPE_ID_TERMINATION
                && caseRec.status != oldMap.get(caseRec.Id).status 
                && caseRec.status == CaseDecorator.STATUS_COMPLETE_CASE
                && (caseRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_TENANCY_ENDED  ||
                        caseRec.CaseOutcome__c == CaseDecorator.CASE_OUTCOME_CLOSED_WITH_DISPUTE)){
                    terminationCaseMap.put(caseRec.Id, caseRec);
                    tenancyIds.add(caseRec.Tenancy__c);
                    contactIds.add(caseRec.ContactId);
            }
        }
        if( !terminationCaseMap.isEmpty()){ 
            List<Termination__c> terminationRecords = [SELECT Case__c, ForwardingAddress__City__s, ForwardingAddress__PostalCode__s, ForwardingAddress__Street__s
                    FROM Termination__c WHERE Case__c IN :terminationCaseMap.keySet()];
            for(Termination__c terminationRecord: terminationRecords){
                terminationRecordByCaseIds.put(terminationRecord.Case__c, terminationRecord);
            }
            updateMemberSynchAddress(terminationCaseMap, tenancyIds, contactIds, terminationRecordByCaseIds);
        }
    }

    private void updateMemberSynchAddress(Map<Id, Case> terminationCaseMap, List<Id> tenancyIds, List<Id> contactIds, Map<Id, Termination__c> terminationRecordByCaseIds){
        
        List<Member__c> members = [SELECT Id, Tenancy__c, Tenancy__r.YH_TenancyType__c, Contact__c
                FROM Member__c
                WHERE Tenancy__c IN :tenancyIds AND 
                Contact__c IN :contactIds AND
                IsActive__c = true AND
                (Type__c = :MemberDecorator.TYPE_JOINT OR  Type__c = :MemberDecorator.TYPE_SOLO)
                ];
        
        if(!members.isEmpty()){
            Map<String, Member__c> mapOfMemberByTenancyContact = new Map<String, Member__c>();

            for(Member__c aMember: members){
                String key = (String)aMember.Tenancy__c+(String)aMember.Contact__c;
                mapOfMemberByTenancyContact.put(key, aMember);
            }
            
            List<Member__c>membersToUpdate = new List<Member__c>();
            for(Case aCase: terminationCaseMap.values()){
                String key = (String)aCase.Tenancy__c+(String)aCase.ContactId;
                Member__c memberRecord = mapOfMemberByTenancyContact.get(key);
                if(memberRecord != null){
                    MemberService memService = new MemberService();
                    memService.setSynchAddressOnDeactivation(memberRecord,CaseDecorator.TYPE_TERMINATION,
                    terminationRecordByCaseIds.get(aCase.Id).ForwardingAddress__City__s, 
                    terminationRecordByCaseIds.get(aCase.Id).ForwardingAddress__Street__s,  
                    terminationRecordByCaseIds.get(aCase.Id).ForwardingAddress__PostalCode__s);    
                    membersToUpdate.add(memberRecord);
                }else{
                    NoDataFoundException exceptionMesssage = new NoDataFoundException();
                    exceptionMesssage.setMessage('Active member associated with Case contact not found');
                }
            }
            update membersToUpdate;
        }else{
            NoDataFoundException exceptionMesssage = new NoDataFoundException();
            exceptionMesssage.setMessage('Active member associated with Case contact not found');
        }
    }
}