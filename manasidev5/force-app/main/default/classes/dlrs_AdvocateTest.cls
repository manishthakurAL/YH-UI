/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_AdvocateTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_AdvocateTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Advocate__c());
    }
    
    
    @IsTest
    private static void testCRUDCoverage()
    {
        Contact c = new Contact(LastName='Test01');
        Insert c;
        Advocate__c a = new Advocate__c(AuthorisedBy__c = c.Id, AuthorisedTo__c = c.Id, StartDate__c = System.today().addDays(-1));
        Insert a;
        Update a;
        Delete a;
        Undelete a;
    }
}