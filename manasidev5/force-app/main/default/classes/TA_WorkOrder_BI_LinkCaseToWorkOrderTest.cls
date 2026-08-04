@isTest
public with sharing class TA_WorkOrder_BI_LinkCaseToWorkOrderTest {
    @TestSetup
   static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        TriggerBase.bypass('Case');

        Account account = UthAccount.build();
        insert account;

        Contact contact = UthContact.build(account.Id);
        insert contact; 

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
            'Leeds', 
            'E08000035', 
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE
        );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;

        Case caseAwaabsLaw = UthCase.buildAwaabsLawCaseWthOrcahrdJobNumber(contact.Id, tenancy.Id, '1234', '7890,0000');       
        insert caseAwaabsLaw;

        TriggerBase.clearBypass('Account');
        TriggerBase.clearBypass('Contact');
        TriggerBase.clearBypass('Case');        
    }

    @isTest
    static void insertWorkOrder(){
        Test.startTest();
            UthWorkOrder.create('1234');
        Test.stopTest();
        Assert.areEqual(UthCase.getAll()[0].Id, UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Work Order should be related to case' );
    }

     @isTest
    static void insertWorkOrderMatchFurtherWorksJobNumber(){
        Test.startTest();
            UthWorkOrder.create('7890');
        Test.stopTest();
        Assert.areEqual(UthCase.getAll()[0].Id, UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Work Order should be related to case' );
    }

    @isTest
    static void bulkinsertWorkOrder(){
        Case caseAwaabsLaw = UthCase.buildAwaabsLawCaseWthOrcahrdJobNumber(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id, '999','');       
        insert caseAwaabsLaw;
        List<WorkOrder> workOrders = new List<WorkOrder>();
        Test.startTest();
            workOrders.add(UthWorkOrder.build('1234'));
            workOrders.add(UthWorkOrder.build('7890'));
            workOrders.add(UthWorkOrder.build('999'));
            insert workOrders;
        Test.stopTest();        
        Assert.areEqual(UthCase.getAll()[0].Id, UthWorkOrder.getAllWOsWithSAs()[0].CaseId, 'Work Order should be related to case' );
        Assert.areEqual(UthCase.getAll()[0].Id, UthWorkOrder.getAllWOsWithSAs()[1].CaseId, 'Work Order should be related to case' );
        Assert.areEqual(UthCase.getAll()[1].Id, UthWorkOrder.getAllWOsWithSAs()[2].CaseId, 'Work Order should be related to case' );
   }

}