@isTest
public class FlowCasePDF_Test {

    @isTest
    static void testGeneratePdfForCase() {
        Account caseAccount = UthAccount.build();
        insert caseAccount;
		Contact caseContact = UthContact.build(caseAccount.Id);
        insert caseContact;
        Case c = UthCase.buildEmailResponseCase(caseContact.Id);
        insert c;
        AwaabsLaw__c aw = UthAwaabsLaw.createTestAwaabsLaw(c.Id, true);
        insert aw;
        
        FlowCasePdfGeneratorInvocable.CasePdfRequest req = new FlowCasePdfGeneratorInvocable.CasePdfRequest();
        req.caseId = c.Id;

        Test.startTest();
        FlowCasePdfGeneratorInvocable.generatePdfForCase(new List<FlowCasePdfGeneratorInvocable.CasePdfRequest>{ req });
        Test.stopTest();

        List<ContentDocumentLink> links = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :c.Id];
        System.assertEquals(1, links.size(), 'Should have one ContentDocumentLink for the Case');
        
        PageReference pageRef = Page.FlowCasePdfVisualforce;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('key', aw.Id);
    
        FlowCasePdfVFController controller = new FlowCasePdfVFController();
        System.assert(controller.inputs.contains('Assessment Info'), 'Should set inputs to AssessmentInformation__c');
    }

    @isTest
    static void testControllerWithAssessmentInfo() {
        Account caseAccount = UthAccount.build();
        insert caseAccount;
		Contact caseContact = UthContact.build(caseAccount.Id);
        insert caseContact;
        Case c = UthCase.buildEmailResponseCase(caseContact.Id);
        insert c;
        AwaabsLaw__c aw = UthAwaabsLaw.createTestAwaabsLaw(c.Id, true);
        insert aw;

        PageReference pageRef = Page.FlowCasePdfVisualforce;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('key', aw.Id);

        FlowCasePdfVFController controller = new FlowCasePdfVFController();
        System.assert(controller.inputs.contains('Assessment Info'), 'Controller should populate inputs with AssessmentInformation__c');
    }

    @isTest
    static void testControllerWithoutAssessmentInfo() {
        Account caseAccount = UthAccount.build();
        insert caseAccount;
		Contact caseContact = UthContact.build(caseAccount.Id);
        insert caseContact;
        Case c = UthCase.buildEmailResponseCase(caseContact.Id);
        insert c;
        AwaabsLaw__c aw = UthAwaabsLaw.createTestAwaabsLaw(c.Id, false);
        insert aw;

        PageReference pageRef = Page.FlowCasePdfVisualforce;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('key', aw.Id);

        FlowCasePdfVFController controller = new FlowCasePdfVFController();
        System.assertEquals('<h2>Error</h2>', controller.inputs, 'Controller should return error message if no AssessmentInformation__c');
    }
}