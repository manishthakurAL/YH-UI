@IsTest
private with sharing class ManageAlertAdvocateImplTest {
    
    @testSetup
    static void setUpTestData(){

        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');
        
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));
        accountList.add(UthAccount.buildPersonAccount('fNameThree', 'lNameThree'));
        insert accountList;

        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
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
        insert memberList;  

        TriggerBase.clearBypass('Account');
    }

    @IsTest
    static void delegatedAuthority(){
        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }
        }
    
        Advocate__c advRec = UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY);
        
        Test.startTest();        
        insert advRec;
        Test.stopTest();

        System.Assert.areEqual(2, UthAlert.getAll().size());

        Alert__c authToAlertRec;
        Alert__c authByAlertRec;
        String notes = String.format(
            Label.AlertNotesByAuthorisationType,
            new List<String>{
                'fNameOne lNameOne',
                AlertDecorator.SUB_CATEGORY_GRANTED_DELEGATEDAUTHORITY,                
                'fNameTwo lNameTwo',
                AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY
            }
        );

        for(Alert__c alertRec : UthAlert.getAll()){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advRec.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advRec.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advRec.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }

        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactTwo.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');
    }    

    @IsTest
    static void delegatedAuthorityEndDate(){
        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }
        }
    
        Advocate__c advRec = UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY);
        insert advRec;

        advRec.EndDate__c = Date.today().addDays(1);
        Test.startTest();   
        update advRec;
        Test.stopTest();

        for(Alert__c alertRec : UthAlert.getAll()){
            System.Assert.areEqual(advRec.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
        }
    }    

    @IsTest
    static void delegatedAuthorityBulkified(){
        Contact contactOne;
        Contact contactTwo;    
        Contact contactThree;        

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }else if(contact.FirstName == 'fNameThree'){
                contactThree = contact;
            }
        }
        
        List<Advocate__c> advList = new List<Advocate__c>();
        advList.add(UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY));
        advList.add(UthAdvocate.build(contactOne.Id, contactThree.Id, AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY));
        
        Test.startTest();        
        insert advList;
        Test.stopTest();

        Advocate__c advOneToTwo;
        Advocate__c advOneToThree;        
        for(Advocate__c advRec : advList){
            if(advRec.AuthorisedTo__c == contactTwo.Id){
                advOneToTwo = advRec;
            }else{
                advOneToThree = advRec;
            }
        }
        System.Assert.areEqual(4, UthAlert.getAll().size());
        
        Alert__c authToAlertRec;
        Alert__c authByAlertRec; 

        // Validate Advocate contantOne ==> contactTwo        
        System.Assert.areEqual(2, UthAlert.getAllByAdvocateId(advOneToTwo.Id).size());
        for(Alert__c alertRec : UthAlert.getAllByAdvocateId(advOneToTwo.Id)){
            String notes = String.format(
                Label.AlertNotesByAuthorisationType,
                new List<String>{
                    'fNameOne lNameOne',
                    AlertDecorator.SUB_CATEGORY_GRANTED_DELEGATEDAUTHORITY,                
                    'fNameTwo lNameTwo',
                    AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY
                }
            );
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advOneToTwo.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advOneToTwo.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advOneToTwo.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }
        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactTwo.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');

        // Validate Advocate contantOne ==> contactThree       
        System.Assert.areEqual(2, UthAlert.getAllByAdvocateId(advOneToThree.Id).size());
        for(Alert__c alertRec : UthAlert.getAllByAdvocateId(advOneToThree.Id)){
            String notes = String.format(
                Label.AlertNotesByAuthorisationType,
                new List<String>{
                    'fNameOne lNameOne',
                    AlertDecorator.SUB_CATEGORY_GRANTED_DELEGATEDAUTHORITY,                
                    'fNameThree lNameThree',
                    AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY
                }
            );
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advOneToThree.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advOneToThree.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advOneToThree.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }
        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactThree.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');
    }

    @IsTest
    static void powerOfAttorney(){
        Contact contactOne;
        Contact contactTwo;        

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }
        }
    
        Advocate__c advRec = UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY);
        
        Test.startTest();        
        insert advRec;
        Test.stopTest();

        System.Assert.areEqual(2, UthAlert.getAll().size());

        Alert__c authToAlertRec;
        Alert__c authByAlertRec;
        String notes = String.format(
            Label.AlertNotesByAuthorisationType,
            new List<String>{
                'fNameOne lNameOne',
                AlertDecorator.SUB_CATEGORY_GRANTED_POWEROFATTORNEY,                
                'fNameTwo lNameTwo',
                AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY
            }
        );

        for(Alert__c alertRec : UthAlert.getAll()){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advRec.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advRec.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advRec.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }

        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactTwo.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');
    }    

    @IsTest
    static void powerOfAttorneyEndDate(){
        Contact contactOne;
        Contact contactTwo;

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }
        }
    
        Advocate__c advRec = UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY);
        insert advRec;

        advRec.EndDate__c = Date.today().addDays(1);
        Test.startTest();   
        update advRec;
        Test.stopTest();

        for(Alert__c alertRec : UthAlert.getAll()){
            System.Assert.areEqual(advRec.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
        }
    }    

    @IsTest
    static void powerOfAttorneyBulkified(){
        Contact contactOne;
        Contact contactTwo;    
        Contact contactThree;        

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }else if(contact.FirstName == 'fNameThree'){
                contactThree = contact;
            }
        }
        
        List<Advocate__c> advList = new List<Advocate__c>();
        advList.add(UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY));
        advList.add(UthAdvocate.build(contactOne.Id, contactThree.Id, AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY));
        
        Test.startTest();        
        insert advList;
        Test.stopTest();

        Advocate__c advOneToTwo;
        Advocate__c advOneToThree;        
        for(Advocate__c advRec : advList){
            if(advRec.AuthorisedTo__c == contactTwo.Id){
                advOneToTwo = advRec;
            }else{
                advOneToThree = advRec;
            }
        }
        System.Assert.areEqual(4, UthAlert.getAll().size());
        
        Alert__c authToAlertRec;
        Alert__c authByAlertRec; 

        // Validate Advocate contantOne ==> contactTwo        
        System.Assert.areEqual(2, UthAlert.getAllByAdvocateId(advOneToTwo.Id).size());
        for(Alert__c alertRec : UthAlert.getAllByAdvocateId(advOneToTwo.Id)){
            String notes = String.format(
                Label.AlertNotesByAuthorisationType,
                new List<String>{
                    'fNameOne lNameOne',
                    AlertDecorator.SUB_CATEGORY_GRANTED_POWEROFATTORNEY,                
                    'fNameTwo lNameTwo',
                    AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY
                }
            );
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advOneToTwo.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advOneToTwo.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advOneToTwo.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }
        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactTwo.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');

        // Validate Advocate contantOne ==> contactThree       
        System.Assert.areEqual(2, UthAlert.getAllByAdvocateId(advOneToThree.Id).size());
        for(Alert__c alertRec : UthAlert.getAllByAdvocateId(advOneToThree.Id)){
            String notes = String.format(
                Label.AlertNotesByAuthorisationType,
                new List<String>{
                    'fNameOne lNameOne',
                    AlertDecorator.SUB_CATEGORY_GRANTED_POWEROFATTORNEY,                
                    'fNameThree lNameThree',
                    AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY
                }
            );
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advOneToThree.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advOneToThree.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advOneToThree.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }
        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactThree.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');
    }

    @IsTest
    static void poaAndDaBulkified(){
        Contact contactOne;
        Contact contactTwo;    
        Contact contactThree;        

        for(Contact contact :UthContact.getAll()){
            if(contact.FirstName == 'fNameOne'){
                contactOne = contact;
            }else if(contact.FirstName == 'fNameTwo'){
                contactTwo = contact;
            }else if(contact.FirstName == 'fNameThree'){
                contactThree = contact;
            }
        }
        
        List<Advocate__c> advList = new List<Advocate__c>();
        advList.add(UthAdvocate.build(contactOne.Id, contactTwo.Id, AdvocateDecorator.AUTHORIZATIONTYPE_DELEGATED_AUTHORITY));
        advList.add(UthAdvocate.build(contactOne.Id, contactThree.Id, AdvocateDecorator.AUTHORIZATIONTYPE_POWER_OF_ATTORNEY));
        
        Test.startTest();        
        insert advList;
        Test.stopTest();

        Advocate__c advOneToTwo;
        Advocate__c advOneToThree;        
        for(Advocate__c advRec : advList){
            if(advRec.AuthorisedTo__c == contactTwo.Id){
                advOneToTwo = advRec;
            }else{
                advOneToThree = advRec;
            }
        }
        System.Assert.areEqual(4, UthAlert.getAll().size());
        
        Alert__c authToAlertRec;
        Alert__c authByAlertRec; 

        // Validate Advocate contantOne ==> contactTwo        
        System.Assert.areEqual(2, UthAlert.getAllByAdvocateId(advOneToTwo.Id).size());
        for(Alert__c alertRec : UthAlert.getAllByAdvocateId(advOneToTwo.Id)){
            String notes = String.format(
                Label.AlertNotesByAuthorisationType,
                new List<String>{
                    'fNameOne lNameOne',
                    AlertDecorator.SUB_CATEGORY_GRANTED_DELEGATEDAUTHORITY,                
                    'fNameTwo lNameTwo',
                    AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY
                }
            );
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advOneToTwo.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advOneToTwo.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advOneToTwo.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_DELEGATEDAUTHORITY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }
        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactTwo.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');

        // Validate Advocate contantOne ==> contactThree       
        System.Assert.areEqual(2, UthAlert.getAllByAdvocateId(advOneToThree.Id).size());
        for(Alert__c alertRec : UthAlert.getAllByAdvocateId(advOneToThree.Id)){
            String notes = String.format(
                Label.AlertNotesByAuthorisationType,
                new List<String>{
                    'fNameOne lNameOne',
                    AlertDecorator.SUB_CATEGORY_GRANTED_POWEROFATTORNEY,                
                    'fNameThree lNameThree',
                    AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY
                }
            );
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c, 'Alert Type should be Person');
            System.Assert.areEqual(advOneToThree.Id, alertRec.Advocate__c, 'Advocate is not set correctly');
            System.Assert.areEqual(advOneToThree.StartDate__c, alertRec.StartDate__c, 'StartDate is not set correctly');
            System.Assert.areEqual(advOneToThree.EndDate__c, alertRec.EndDate__c, 'EndDate is not set correctly');
            System.Assert.areEqual(notes, alertRec.Notes__c, 'Notes is not set correctly');
            if(alertRec.SubCategory__c == AlertDecorator.SUB_CATEGORY_POWEROFATTORNEY){
                authToAlertRec = alertRec;
            }else{
                authByAlertRec = alertRec;
            }
        }
        System.Assert.areEqual(contactOne.Id, authByAlertRec.Contact__c, 'Authorised By is not set correctly');
        System.Assert.areEqual(contactThree.Id, authToAlertRec.Contact__c, 'Authorised To is not set correctly');
    }
}