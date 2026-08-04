/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_MemberTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_MemberTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Member__c());
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
            Insert p;
        YH_Tenancy__c  t = new YH_Tenancy__c (
            StartDate__c = Date.Today(),
            Property__c = p.Id,
            Active__c = true,
            YH_TenancyType__c = 'Sole');
        Insert t;
        Case c = new Case();
        Insert c;
        
        YH_Application__c ap = new YH_Application__c(Case__c=c.Id, Property__c=p.Id);
        Insert ap;
        Applicant__c a = new Applicant__c(contact__c=con.Id, Application__c=ap.Id, ApplicantType__c=MemberDecorator.TYPE_SOLO);
        
        test.startTest();
        Member__c m = new Member__c(Tenancy__c=t.Id, contact__c=con.Id);
        Insert m;
        Update m;
        Delete m;
        Undelete m;
        test.stopTest();
    }
}