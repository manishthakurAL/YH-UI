@IsTest
private with sharing class TA_PriceBook_BIU_ValidateSORPbTest {

    @TestSetup
    static void setupData() {
        
        Pricebook2 sorPbRec1 = UthPricebook.create('SOR Pricebook1', 'SOR', Date.today(), Date.today().addDays(30));
        Pricebook2 sorPbRec2 = UthPricebook.create('SOR Pricebook2', 'SOR', Date.today().addDays(40), null);

        WorkOrder woRec1 = UthWorkOrder.create('ORCH01', sorPbRec1.Id, Date.today().addDays(20));
        WorkOrder woRec2 = UthWorkOrder.create('ORCH02', sorPbRec2.Id, Date.today().addDays(45));

    }

    @IsTest
    static void allowPBIfNotWithinRange() {       
        
        Test.startTest();
        Pricebook2 sorPbRec = UthPricebook.create('SOR Pricebook1', 'SOR', Date.today().addDays(32), Date.today().addDays(36));
        Test.stopTest();

        System.assertNotEquals(null, sorPbRec.Id, 'SOR Pricebook should insert successfully');
    }

    @IsTest
    static void doNotAllowPBIfWithinRange() {     
        string expMessage = '';  
        
        Test.startTest();
        try {
            Pricebook2 sorPbRec = UthPricebook.create('SOR Pricebook1', 'SOR', Date.today().addDays(10), Date.today().addDays(20));
        } catch (DmlException e) {
            expMessage = e.getDmlMessage(0);            
        }
        Test.stopTest();

        System.assertEquals(true,
                expMessage.contains(PricebookDecorator.ERROR_SOR_OVERLAP),
                'Expected overlap error message');
    }

    @IsTest
    static void allowPBChangeIfReportedDateWithinRange() {       
        Pricebook2 sorPbRec = UthPricebook.getAll('SOR Pricebook1')[0];
        
        Test.startTest();
            sorPbRec.EffectiveEndDate__c = Date.today().addDays(25);  
            update sorPbRec;      
        Test.stopTest();

        System.assertEquals(sorPbRec.EffectiveEndDate__c, Date.today().addDays(25), 'SOR Pricebook should update successfully');
    }

    @IsTest
    static void doNotAllowPBChangeIfReportedDateNotInRange() {       
        string expMessage = '';  
        Pricebook2 sorPbRec = UthPricebook.getAll('SOR Pricebook1')[0];
        
        Test.startTest();
        try {
            sorPbRec.EffectiveEndDate__c = Date.today().addDays(15);  
            update sorPbRec;   
        } catch (DmlException e) {
            expMessage = e.getDmlMessage(0);
        }   
        Test.stopTest();
        
        System.assertEquals(true,
                expMessage.contains(PricebookDecorator.ERROR_WORKORDER_OUTOFRANGE),
                'Expected WO out of range error message');
    }

    @IsTest
    static void allowPBChangeIfReportedDateWithinRangeNULL() {       
        Pricebook2 sorPbRec = UthPricebook.getAll('SOR Pricebook2')[0];
        
        Test.startTest();
            sorPbRec.EffectiveEndDate__c = Date.today().addDays(365);  
            update sorPbRec;      
        Test.stopTest();

        System.assertEquals(sorPbRec.EffectiveEndDate__c, Date.today().addDays(365), 'SOR Pricebook should update successfully');
    }

    @IsTest
    static void doNotAllowPBChangeIfReportedDateNotInRangeNULL() {   
        string expMessage = '';       
        Pricebook2 sorPbRec = UthPricebook.getAll('SOR Pricebook2')[0];
        
        Test.startTest();
        try {
            sorPbRec.EffectiveEndDate__c = Date.today().addDays(42);  
            update sorPbRec;   
        } catch (DmlException e) {
            expMessage = e.getDmlMessage(0);
        }   
        Test.stopTest();

        System.assertEquals(true,
                expMessage.contains(PricebookDecorator.ERROR_WORKORDER_OUTOFRANGE),
                'Expected WO out of range error message');
    }

    

    @IsTest
    static void allowPBIfNotWithinRangeBulk() {       
        List<Pricebook2> pbList = new List<Pricebook2>();
        pbList.add(UthPricebook.build('SOR Pricebook1', 'SOR', Date.today().addDays(32), Date.today().addDays(35)));
        pbList.add(UthPricebook.build('SOR Pricebook2', 'SOR', Date.today().addDays(37), Date.today().addDays(39)));
        
        Test.startTest();
        insert pbList;
        Test.stopTest();

        for(Pricebook2 sorPbRec : pbList){
            System.assertNotEquals(null, sorPbRec.Id, 'SOR Pricebook should insert successfully');
        }
    }

    @IsTest
    static void doNotAllowPBIfWithinRangeBulk() {   
        List<Pricebook2> pbList = new List<Pricebook2>();
        pbList.add(UthPricebook.build('SOR Pricebook1', 'SOR', Date.today().addDays(32), Date.today().addDays(36)));
        pbList.add(UthPricebook.build('SOR Pricebook2', 'SOR', Date.today().addDays(34), Date.today().addDays(39)));
        
        string expMessage = '';  
        
        Test.startTest();
        try {
            insert pbList;
        } catch (DmlException e) {
            expMessage = e.getDmlMessage(0);            
        }
        Test.stopTest();

        System.assertEquals(true,
                expMessage.contains(PricebookDecorator.ERROR_SOR_OVERLAP),
                'Expected overlap error message');
    }
}