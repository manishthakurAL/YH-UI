@isTest
public with sharing class CalculateTenancyEndDateInvocableTest {

     @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.insertPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.insertWithEndDate(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO, System.today()-10);
    }

    @isTest
    static void testCalculateTenancyEndDateInvocable(){ 
        Test.startTest();
            List<YH_Tenancy__c> tenancies = UthTenancy.getAll();
            CalculateTenancyEndDateInvocable.TenancyEndDateRequest req = new CalculateTenancyEndDateInvocable.TenancyEndDateRequest();
            req.aTenancy = tenancies[0];
            req.terminationNoticeRecievedDate = System.today();
            List<CalculateTenancyEndDateInvocable.TenancyEndDateRequest> requests = new List<CalculateTenancyEndDateInvocable.TenancyEndDateRequest>();
            requests.add(req);
            List<CalculateTenancyEndDateInvocable.TenancyEndDateResponse> responses = CalculateTenancyEndDateInvocable.calculateTenancyEndDate(requests);
            Date endDate = responses[0].tenancyEndDate;
        Test.stopTest();
        Assert.isNotNull(endDate, 'Tenancy end date should be calculated successfully');
    }

    
}