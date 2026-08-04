/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_YH_AdvertisementTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_YH_AdvertisementTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        //dlrs.RollupService.testHandler(new YH_Advertisement__c());
    }
    
    
    @IsTest
    private static void testCRUDCoverage()
    {
        YH_Property__c p = UthProperty.buildPropertyWithAddress('Leeds',
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
            PropertyDecorator.RENT_TYPE_MARKET_RENT,
            PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL,'Test City 1','RM8 1YQ');
            insert p;
        Case c = new Case();
        Insert c;
        
        Test.startTest();
        YH_Advertisement__c ad = new YH_Advertisement__c(Property__c=p.Id, case__c=c.Id);
        Insert ad;
        Update ad;
        Delete ad;
        Undelete ad;
        Test.stopTest();
    }
}