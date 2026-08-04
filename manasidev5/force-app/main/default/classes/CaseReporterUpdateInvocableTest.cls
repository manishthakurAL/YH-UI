@isTest
public with sharing class CaseReporterUpdateInvocableTest {
    
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        Account account = UthAccount.buildPersonAccount('fNameOne', 'lNameOne');
        insert account;
        TriggerBase.clearBypass('Account');
    }

    @isTest
    static void testUpdateCase(){
        Contact contactOne;
        for(Contact contact : UthContact.getAll()){
               if(contact.LastName == 'lNameOne'){
                   contactOne = contact;
               }
        }
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        Case caseRecord = UthCase.buildCustomerFeedbackCaseGuestPortal();
        insert caseRecord;
        MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        caseRecord.ContactId = contactOne.Id;
        caseRecord.Reporter__c = contactOne.Id;
        Test.startTest();
            	List<CaseReporterUpdateInvocable.CaseReporterWrapper> wrappers = 
                       														new  List<CaseReporterUpdateInvocable.CaseReporterWrapper>();
            	CaseReporterUpdateInvocable.CaseReporterWrapper awrapper = new CaseReporterUpdateInvocable.CaseReporterWrapper();
            	awrapper.caseRec = caseRecord;
                wrappers.add(awrapper);
            	CaseReporterUpdateInvocable.updateCase(wrappers);
        Test.stopTest();
        List<Case> casesList = UthCase.getAll();
        Assert.areEqual(contactOne.Id,casesList[0].Reporter__c,'Reporter should be updated');
        Assert.areEqual(contactOne.Id,casesList[0].ContactId,'Contact should be updated');
        
    }
}