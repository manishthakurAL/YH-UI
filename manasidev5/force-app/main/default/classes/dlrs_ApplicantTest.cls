/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ApplicantTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ApplicantTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Applicant__c());
    }
    
    
    @IsTest
    private static void testCRUDCoverage()
    {
        Contact con = new Contact(LastName='Test01');
        Insert con;
        YH_Property__c p = UthProperty.buildPropertyWithAddress('Leeds',
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
            PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
            PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL,'Test City 1','RM8 1YQ');
            insert p;
        Case c = new Case();
        Insert c;
        
        YH_Application__c ap = new YH_Application__c(Case__c=c.Id, Property__c=p.Id);
        Insert ap;
        
        Test.startTest();
        Applicant__c a = new Applicant__c(contact__c=con.Id, Application__c=ap.Id, ApplicantType__c=MemberDecorator.TYPE_SOLO);
        Insert a;
        Update a;
        delete [SELECT Id FROM Vetting__c WHERE Applicant__c =: a.Id];
        Delete a;
        Undelete a;
        Test.stopTest();
    }
}