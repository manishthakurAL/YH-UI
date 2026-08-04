@isTest
public with sharing class UthTerminationAmendment {
    
    public static TerminationAmendment__c buildRetractNotice(Id caseId, Id contactId) {
        return new TerminationAmendment__c(
            DateOfRequest__c = Date.today(),
            TypeOfAmendment__c = TerminationAmendmentDecorator.TYPE_RETRACT_NOTICE,
            RequestedBy__c = contactId,
            Case__c = caseId,
            ReasonRetractionRequested__c = TerminationAmendmentDecorator.REASON_YH_RETRACTED_NOTICE
        );
    }

    public static TerminationAmendment__c buildChangeTenancyEndDate(Id caseId, Id contactId) {
        return new TerminationAmendment__c(
            DateOfRequest__c = Date.today(),
            AmendedTenancyEndDate__c = Date.today().addMonths(1),
            TypeOfAmendment__c = TerminationAmendmentDecorator.TYPE_CHANGE_TENANCY_END_DATE,
            RequestedBy__c = contactId,
            ReasonTenancyEndDateChanged__c = 'Transfer',
            Case__c = caseId
        );
    }

    public static List<TerminationAmendment__c> getAll() {
        Map<String, Schema.SObjectField> fieldMap = TerminationAmendment__c.SObjectType.getDescribe().fields.getMap();
        String query = 'SELECT ' + 
                       String.join(new List<String>(fieldMap.keySet()), ', ') + 
                       ' FROM TerminationAmendment__c';
        return Database.query(query);
    }
}