@isTest
private class ManageAlertMappingAlertImplTest {

    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));
        insert accountList;

        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else{
                contactTwo = contact;
            }
        }
        
        YH_Property__c property = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT);
        insert tenancy;

        List<Member__c> memberList = new List<Member__c>();
        memberList.add(UthMember.build(contactOne.Id, tenancy.Id, MemberDecorator.TYPE_SOLO));
        memberList.add(UthMember.build(contactTwo.Id, tenancy.Id, MemberDecorator.TYPE_SOLO));
        insert memberList;  

        TriggerBase.clearBypass('Account');
    }

    @isTest
    static void testPersonAlertMapCreation(){
        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else{
                contactTwo = contact;
            }
        }
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPersonAlert(contactOne.Id));
        alertList.add(UthAlert.buildPersonAlert(contactTwo.Id));        
        insert alertList;

        List<Id> alertIds = new List<Id>();
        for(Alert__c aRec : alertList){
            aRec.IsActiveValue__c = true;
            alertIds.add(aRec.Id);
        }

        Test.startTest(); 
        update alertList;
        Test.stopTest(); 

        Assert.areEqual(2, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alerts not mapped correctly');
            Assert.areEqual(UthProperty.getAll()[0].Id, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(UthTenancy.getAll()[0].Id, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }

    @isTest
    static void testPersonAlertMapCreationNegative(){
        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else{
                contactTwo = contact;
            }
        }
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPersonAlert(contactOne.Id));
        alertList.add(UthAlert.buildPersonAlert(contactTwo.Id));     
        for(Alert__c aRec : alertList){
            aRec.StartDate__c = system.today()+3;
        }

        Test.startTest(); 
        insert alertList;
        Test.stopTest(); 

        Assert.areEqual(0, UthAlertMap.getAll().size(), 'Alerts should not be created');
    }

    @isTest
    static void testPropertyAlertMapCreation(){

        List<Id> personIds = new List<Id>();
        for(Contact contact :UthContact.getAll()){
            personIds.add(contact.Id);
        }

        Id propertyId = UthProperty.getAll()[0].Id;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPropertyAlert(propertyId));
        alertList.add(UthAlert.buildPropertyAlert(propertyId));        
        insert alertList;
        List<Id> alertIds = new List<Id>();

        for(Alert__c aRec : alertList){
            aRec.IsActiveValue__c = true;
            alertIds.add(aRec.Id);
        }

        Test.startTest(); 
        update alertList;
        Test.stopTest(); 

        Assert.areEqual(4, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alerts not mapped correctly');
            Assert.isTrue(personIds.contains(amRec.Contact__c), 'Person Account not mapped correctly');
            Assert.areEqual(UthProperty.getAll()[0].Id, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(UthTenancy.getAll()[0].Id, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }

    @isTest
    static void testPropertyAlertMapCreationNegative(){

        List<Id> personIds = new List<Id>();
        for(Contact contact :UthContact.getAll()){
            personIds.add(contact.Id);
        }

        Id propertyId = UthProperty.getAll()[0].Id;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPropertyAlert(propertyId));
        alertList.add(UthAlert.buildPropertyAlert(propertyId));    
        for(Alert__c aRec : alertList){
            aRec.StartDate__c = system.today()+3;
        }    

        Test.startTest(); 
        insert alertList;
        Test.stopTest(); 

        Assert.areEqual(0, UthAlertMap.getAll().size(), 'Alerts not created');
    }    

    @isTest
    static void testTenancyAlertMapCreation(){

        List<Id> personIds = new List<Id>();
        for(Contact contact :UthContact.getAll()){
            personIds.add(contact.Id);
        }

        Id tenancyId = UthTenancy.getAll()[0].Id;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildTenancyAlert(tenancyId));
        alertList.add(UthAlert.buildTenancyAlert(tenancyId));        
        insert alertList;

        List<Id> alertIds = new List<Id>();
        for(Alert__c aRec : alertList){
            aRec.IsActiveValue__c = true;
            alertIds.add(aRec.Id);
        }

        Test.startTest(); 
        update alertList;
        Test.stopTest(); 

        Assert.areEqual(4, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alerts not mapped correctly');
            Assert.isTrue(personIds.contains(amRec.Contact__c), 'Person Account not mapped correctly');
            Assert.areEqual(UthProperty.getAll()[0].Id, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(UthTenancy.getAll()[0].Id, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }    

    @isTest
    static void testTenancyAlertMapCreationNegative(){

        List<Id> personIds = new List<Id>();
        for(Contact contact :UthContact.getAll()){
            personIds.add(contact.Id);
        }

        Id tenancyId = UthTenancy.getAll()[0].Id;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildTenancyAlert(tenancyId));
        alertList.add(UthAlert.buildTenancyAlert(tenancyId));    
        for(Alert__c aRec : alertList){
            aRec.StartDate__c = system.today()+3;
        }      

        Test.startTest(); 
        insert alertList;
        Test.stopTest(); 

        Assert.areEqual(0, UthAlertMap.getAll().size(), 'Alerts not created');
    }      

    @isTest
    static void testCombinationAlertMapCreation(){
        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }
        }

        Id tenancyId = UthTenancy.getAll()[0].Id;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPersonAlert(contactOne.Id));
        alertList.add(UthAlert.buildTenancyAlert(tenancyId));        
        insert alertList;

        List<Id> alertIds = new List<Id>();
        for(Alert__c aRec : alertList){
            aRec.IsActiveValue__c = true;
            alertIds.add(aRec.Id);
        }

        Test.startTest(); 
        update alertList;
        Test.stopTest(); 

        Assert.areEqual(3, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alerts not mapped correctly');
            Assert.areEqual(UthProperty.getAll()[0].Id, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(UthTenancy.getAll()[0].Id, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }     

    @isTest
    static void testPropertyAlertMapCreationToCoverInsertTrigger(){

        List<Id> personIds = new List<Id>();
        for(Contact contact :UthContact.getAll()){
            personIds.add(contact.Id);
        }

        Id propertyId = UthProperty.getAll()[0].Id;
        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPropertyAlert(propertyId));
        alertList.add(UthAlert.buildPropertyAlert(propertyId));        
        List<Id> alertIds = new List<Id>();

        for(Alert__c aRec : alertList){
            aRec.IsActiveValue__c = true;
        }

        Test.startTest();
        insert alertList;
        Test.stopTest(); 

        for(Alert__c aRec : alertList){
            alertIds.add(aRec.Id);
        }

        Assert.areEqual(4, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alerts not mapped correctly');
            Assert.isTrue(personIds.contains(amRec.Contact__c), 'Person Account not mapped correctly');
            Assert.areEqual(UthProperty.getAll()[0].Id, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(UthTenancy.getAll()[0].Id, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }
}