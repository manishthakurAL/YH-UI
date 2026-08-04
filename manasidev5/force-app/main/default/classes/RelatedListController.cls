public without sharing class RelatedListController {
    
    @AuraEnabled
    public static Map<String, Object> getCases(String recordTypes, Id accountId) {
        List<Account> accountsList = [SELECT Id, PersonContactId FROM Account WHERE Id =: accountId LIMIT 1];
        Id contactId = !accountsList.isEmpty() ? accountsList[0].PersonContactId : null;
        List<Case> casesList = contactId != null ? getData(recordTypes,contactId) : new List<Case>();
        Map<String, Object> objectsMap = new Map<String, Object>();
        objectsMap.put('columns',getColumns());
        objectsMap.put('data',casesList);
        return objectsMap;
    }

    private static List<Case> getData(String recordTypes, Id contactId) {
        List<String> recordTypesList = recordTypes.split(',');
        Set<Id> caseIds = new Set<Id>();
        for (String recordTypeName : recordTypesList) {
            if (recordTypeName == CaseDecorator.RECORD_TYPE_SAFEGUARDING) {
                caseIds.addAll(new SafegaurdingCases().getCases(contactId));
            } else if (recordTypeName == CaseDecorator.RECORD_TYPE_SCHEMES) {
                caseIds.addAll(new SchemeCases().getCases(contactId));
            } else if (recordTypeName == CaseDecorator.RECORD_TYPE_MANAGED_MOVE) {
                caseIds.addAll(new ManagedMoveCases().getCases(contactId));
            }
        }
        return [SELECT Id, CaseNumber, RecordType.Name, Owner.Name, Status, CreatedDate FROM Case  WHERE Id IN: caseIds 
            ORDER BY IsClosed, CreatedDate DESC];
    }

    private static List<Map<String,Object>> getColumns() {
        List<Map<String,Object>> columnsList = new List<Map<String,Object>>();
        columnsList.add(new Map<String,Object> {
            'label' => Case.CaseNumber.getDescribe().getLabel(),
            'fieldName' => 'caseUrl',
            'type' => 'url',
            'target' => '_blank',
            'typeAttributes' => new Map<String, Object>{
                'label' => new Map<String, String>{
                    'fieldName' => Case.CaseNumber.getDescribe().getName()
                }
            }
        });
        columnsList.add(new Map<String,Object> {
            'label' => 'Record Type',
            'fieldName' => 'recordType',
            'type' => 'text'
        });
        columnsList.add(new Map<String,Object> {
            'label' => 'Owner',
            'fieldName' => 'ownerName',
            'type' => 'text'
        });
        columnsList.add(new Map<String,Object> {
            'label' => Case.Status.getDescribe().getLabel(),
            'fieldName' => Case.Status.getDescribe().getName(),
            'type' => 'text'
        });
        columnsList.add(new Map<String,Object> {
            'label' => 'Date Opened',
            'fieldName' => Case.CreatedDate.getDescribe().getName(), 
            'type' => 'date',
            'typeAttributes' => new Map<String, Object>{
                'year' => 'numeric',
                'day' => 'numeric',
                'month' => 'numeric',
                'hour' => '2-digit',
                'minute' => '2-digit',
                'second' => '2-digit'
            }
        });
        return columnsList;
    }

    public class SafegaurdingCases implements ICase{

        public Set<Id> getCases(Id contactId){
            Set<Id> caseIds = new Set<Id>();
            List<CaseRole__c> caseRolesList = [SELECT Case__c FROM CaseRole__c WHERE Contact__c = :contactId 
                        AND Role__c =: CaseRoleDecorator.PERSONATRISK_ROLE
                AND Case__r.RecordTypeId =: CaseDecorator.RECORD_TYPE_ID_SAFEGUARDING];
            for(CaseRole__c caseRole : caseRolesList){
                caseIds.add(caseRole.Case__c);
            }

            List<Case> safeguardingCasesWithPersonAtRiskAsReporter = [ SELECT Id FROM Case WHERE ContactId =:contactId
                           AND ReporterType__c =: CaseRoleDecorator.PERSONATRISK_ROLE
                        AND RecordTypeId =: CaseDecorator.RECORD_TYPE_ID_SAFEGUARDING];
            for(Case acase : safeguardingCasesWithPersonAtRiskAsReporter){
                caseIds.add(acase.Id);
            }
            return caseIds;
        }
    }

    public class SchemeCases implements ICase{

        public Set<Id> getCases(Id contactId){
            Set<Id> caseIds = new Set<Id>();
            List<CaseRole__c> caseRolesList = [SELECT Case__c FROM CaseRole__c WHERE Contact__c = :contactId AND Role__c =: CaseRoleDecorator.TENANT_ROLE
                AND Case__r.RecordTypeId =: CaseDecorator.RECORD_TYPE_ID_SCHEMES];
            for(CaseRole__c caseRole : caseRolesList){
                caseIds.add(caseRole.Case__c);
            }
            return caseIds;
        }
    }

    public class ManagedMoveCases implements ICase{

        public Set<Id> getCases(Id contactId){
            Set<Id> caseIds = new Set<Id>();
            List<CaseRole__c> caseRolesList = [SELECT Case__c FROM CaseRole__c WHERE Contact__c = :contactId AND Role__c =: CaseRoleDecorator.TENANT_REQUIRING_MOVE_ROLE
                AND Case__r.RecordTypeId =: CaseDecorator.RECORD_TYPE_ID_MANAGED_MOVE];
            for(CaseRole__c caseRole : caseRolesList){
                caseIds.add(caseRole.Case__c);
            }
            return caseIds;
        }
    }
}