/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_ChargesTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_ChargesTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Charges__c());
    }

    @IsTest
    private static void testCRUDCoverage()
    {
        YH_Property__c p = UthProperty.buildPropertyWithAddress('Leeds',
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
            PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
            PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL,'Test City 1','RM8 1YQ');
            insert p;
        Charges__c c = new Charges__c(Property__c=p.Id);
        Insert c;
        Update c;
        Delete c;
        Undelete c;
    }
}