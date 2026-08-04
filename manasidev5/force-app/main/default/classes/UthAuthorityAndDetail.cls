@isTest
public with sharing class UthAuthorityAndDetail {
    public static AuthorityAndDetail__c setRequiredDetailsForAuthorityDetailsOfPANew(Id caseId){
        AuthorityAndDetail__c authRec = [SELECT id FROM AuthorityAndDetail__c WHERE Case__c =: caseId][0];
        authRec.DocumentsReceived__c = CaseDecorator.YES;
        authRec.DocumentsVerified__c = CaseDecorator.YES;
        authRec.UpdatesCompletedInSystem__c = CaseDecorator.YES;
        authRec.PowerOfAttorneyStartDate__c = System.Today();
        return authRec;
    }
    public static AuthorityAndDetail__c setRequiredDetailsForAuthorityDetailsOfDANew(Id caseId){
        AuthorityAndDetail__c authRec = [SELECT id FROM AuthorityAndDetail__c WHERE Case__c =: caseId][0];
        authRec.DocumentsReceived__c = CaseDecorator.YES;
        authRec.DocumentsVerified__c = CaseDecorator.YES;
        authRec.UpdatesCompletedInSystem__c = CaseDecorator.YES;
        authRec.DelegatedAuthorityStartDate__c = System.Today();
        return authRec;
    }
    public static AuthorityAndDetail__c setRequiredDetailsForAuthorityDetailsOfPARemove(Id caseId){
        AuthorityAndDetail__c authRec = [SELECT id FROM AuthorityAndDetail__c WHERE Case__c =: caseId][0];
        authRec.DocumentsReceived__c = CaseDecorator.YES;
        authRec.DocumentsVerified__c = CaseDecorator.YES;
        authRec.UpdatesCompletedInSystem__c = CaseDecorator.YES;
        authRec.ReasonForRemovalOfPoa__c = 'Test';
        return authRec;
    }
    public static AuthorityAndDetail__c updateRequiredDetailsForAuthorityDetailsOfPARemove(Id caseId){
        AuthorityAndDetail__c authRec = setRequiredDetailsForAuthorityDetailsOfPARemove(caseId);
        authRec.CaseType__c = AuthorityAndDetailDecorator.CASETYPE_POA_REMOVE;
        authRec.Request2__c = AuthorityAndDetailDecorator.REQUEST_POA_CASE;
        update authRec ;
        return authRec;
    }
    public static AuthorityAndDetail__c updateRequiredDetailsForAuthorityDetailsOfDANew(Id caseId){
        AuthorityAndDetail__c authRec = setRequiredDetailsForAuthorityDetailsOfDANew(caseId);
        authRec.CaseType__c = AuthorityAndDetailDecorator.CASETYPE_DA_NEW;
        authRec.Request2__c = AuthorityAndDetailDecorator.REQUEST_DA;
        update authRec ;
        return authRec;
    }
    public static AuthorityAndDetail__c updateRequiredDetailsForAuthorityDetailsOfPANew(Id caseId){
        AuthorityAndDetail__c authRec = setRequiredDetailsForAuthorityDetailsOfPANew(caseId);
        authRec.CaseType__c = AuthorityAndDetailDecorator.CASETYPE_POA_NEW;
        authRec.Request2__c = AuthorityAndDetailDecorator.REQUEST_POA_CASE;
        update authRec ;
        return authRec;
    }
    
     public static List<AuthorityAndDetail__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(AuthorityAndDetail__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM AuthorityAndDetail__c ');
    }
}