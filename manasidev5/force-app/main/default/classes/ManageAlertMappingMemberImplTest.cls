@isTest
private class ManageAlertMappingMemberImplTest {

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

        List<Alert__c> alertList = new List<Alert__c>();
        alertList.add(UthAlert.buildPersonAlert(contactOne.Id));
        alertList.add(UthAlert.buildPersonAlert(contactTwo.Id));
        alertList.add(UthAlert.buildPropertyAlert(property.Id));
        alertList.add(UthAlert.buildTenancyAlert(tenancy.Id));
        for(Alert__c alert : alertList){
            alert.IsActiveValue__c = true;
        }
        insert alertList;

        TriggerBase.clearBypass('Account');
    }

    @IsTest
    static void testActiveMemberInsert(){
        Id contactId = UthContact.getAll()[0].Id;
        Id tenancyId = UthTenancy.getAll()[0].Id;
        Id propertyId = UthProperty.getAll()[0].Id;
        List<Id> alertIds = new List<Id>();

        Member__c memRec = UthMember.build(contactId, tenancyId, MemberDecorator.TYPE_SOLO, true);
        
        Test.startTest();
        insert memRec;
        Test.stopTest();

        for(Alert__c aRec : UthAlert.getAll()){
            alertIds.add(aRec.Id);
        }

        Assert.areEqual(3, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alert not linked correctly');
            Assert.areEqual(propertyId, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(tenancyId, amRec.Tenancy__c, 'Tenancy not linked correctly');
            Assert.areEqual(memRec.Id, amRec.Member__c, 'Member not linked correctly');
            Assert.areEqual(contactId, amRec.Contact__c, 'Contact not linked correctly');
        }
    }

    @IsTest
    static void testActiveMemberInsertBulkified(){
        List<Id> contactIds = new List<Id>();
        List<Id> alertIds = new List<Id>();
        List<Id> memberIds = new List<Id>();
        List<Member__c> memberList = new List<Member__c>();
        Id tenancyId = UthTenancy.getAll()[0].Id;
        Id propertyId = UthProperty.getAll()[0].Id;

        for(Contact contact :UthContact.getAll()){
            contactIds.add(contact.Id);
        }
        
        memberList.add(UthMember.build(contactIds[0], tenancyId, MemberDecorator.TYPE_SOLO, true));
        memberList.add(UthMember.build(contactIds[1], tenancyId, MemberDecorator.TYPE_JOINT, true));

        Test.startTest();
        insert memberList;
        Test.stopTest();

        for(Alert__c aRec : UthAlert.getAll()){
            alertIds.add(aRec.Id);
        }

        for(Member__c memRec : memberList){
            memberIds.add(memRec.Id);
        }

        Assert.areEqual(6, UthAlertMap.getAll().size(), 'Alerts not created');
        
        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alert not linked correctly');
            Assert.isTrue(memberIds.contains(amRec.Member__c), 'Member not linked correctly');
            Assert.isTrue(contactIds.contains(amRec.Contact__c), 'Contact not linked correctly');
            Assert.areEqual(propertyId, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(tenancyId, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }  

    @IsTest
    static void testInActiveMemberInsert(){

        Member__c memRec = UthMember.build(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id, MemberDecorator.TYPE_SOLO, false);
        
        Test.startTest();
        insert memRec;
        Test.stopTest();

        Assert.areEqual(0, UthAlertMap.getAll().size(), 'Alerts not created');
    }

    @IsTest
    static void testInActiveMemberInsertBulkified(){
        List<Member__c> memberList = new List<Member__c>();
        memberList.add(UthMember.build(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id, MemberDecorator.TYPE_SOLO, false));
        memberList.add(UthMember.build(UthContact.getAll()[1].Id, UthTenancy.getAll()[0].Id, MemberDecorator.TYPE_JOINT, false));
        
        Test.startTest();
        insert memberList;
        Test.stopTest();

        Assert.areEqual(0, UthAlertMap.getAll().size(), 'Alerts not created');
    }    
    
    @IsTest
    static void testActiveMemberUpdate(){
        
        Id contactId = UthContact.getAll()[0].Id;
        Id tenancyId = UthTenancy.getAll()[0].Id;
        Id propertyId = UthProperty.getAll()[0].Id;
        List<Id> alertIds = new List<Id>();

        Member__c memRec = UthMember.build(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id, MemberDecorator.TYPE_SOLO, false);
        insert memRec;
        memRec.IsActiveValue__c = true;

        Test.startTest();
        update memRec;
        Test.stopTest();

        for(Alert__c aRec : UthAlert.getAll()){
            alertIds.add(aRec.Id);
        }

        Assert.areEqual(3, UthAlertMap.getAll().size(), 'Alerts not created');

        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alert not linked correctly');
            Assert.areEqual(propertyId, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(tenancyId, amRec.Tenancy__c, 'Tenancy not linked correctly');
            Assert.areEqual(memRec.Id, amRec.Member__c, 'Member not linked correctly');
            Assert.areEqual(contactId, amRec.Contact__c, 'Contact not linked correctly');
        }
    }

    @IsTest
    static void testActiveMemberUpdateBulkified(){
        
        List<Id> contactIds = new List<Id>();
        Id tenancyId = UthTenancy.getAll()[0].Id;
        Id propertyId = UthProperty.getAll()[0].Id;
        List<Id> memberIds = new List<Id>();
        List<Member__c> memberList = new List<Member__c>();
        List<Id> alertIds = new List<Id>();
        
        for(Contact contact :UthContact.getAll()){
            contactIds.add(contact.Id);
        }

        for(Alert__c aRec : UthAlert.getAll()){
            alertIds.add(aRec.Id);
        }

        memberList.add(UthMember.build(UthContact.getAll()[0].Id, UthTenancy.getAll()[0].Id, MemberDecorator.TYPE_SOLO, false));
        memberList.add(UthMember.build(UthContact.getAll()[1].Id, UthTenancy.getAll()[0].Id, MemberDecorator.TYPE_JOINT, false));
        insert memberList;

        for(Member__c memRec : memberList){
            memRec.IsActiveValue__c = true;
            memberIds.add(memRec.Id);
        }

        Test.startTest();
        update memberList;
        Test.stopTest();        

        Assert.areEqual(6, UthAlertMap.getAll().size(), 'Alerts not created');
        
        for(AlertMap__c amRec : UthAlertMap.getAll()){
            Assert.isTrue(alertIds.contains(amRec.Alert__c), 'Alert not linked correctly');
            Assert.isTrue(memberIds.contains(amRec.Member__c), 'Member not linked correctly');
            Assert.isTrue(contactIds.contains(amRec.Contact__c), 'Contact not linked correctly');
            Assert.areEqual(propertyId, amRec.Property__c, 'Property not linked correctly');
            Assert.areEqual(tenancyId, amRec.Tenancy__c, 'Tenancy not linked correctly');
        }
    }  
}