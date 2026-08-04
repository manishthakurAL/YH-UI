@isTest
public class TenancyServiceTest {

    @TestSetup
    static void makeData(){
        TriggerBase.bypass('Account');
        TriggerBase.bypass('Contact');

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
    }

    

    @isTest
    static void test_checkStarterTenancyCreation(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
                    
            List<Contact> contactsList = UthContact.getAll();
            YH_Property__c property = UthProperty.buildPropertyWithAddress('Leeds',
            PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
            PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
            PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL,'Test City 1','RM8 1YQ');
            insert property;
           
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id, property.Id);
            insert caseRecord;

            YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, ApplicationDecorator.STARTER_TENANCY, System.now().addDays(1).date());
            insert application;

            Applicant__c applicant = UthApplicant.buildApplicant(UthContact.getAll()[0].Id, application.Id);
            insert applicant;

            Test.startTest();
            application.TenancyAgreementSigned__c = ApplicationDecorator.YES;
            application.MailingAddressUpdate__c = ApplicationDecorator.MAILING_ADDRESS_UPDATE_UPDATE_TO_PROPERTY_ADDRESS;
            update application;
            Test.stopTest();        
        }

        YH_Application__c application = UthApplication.getAll().get(0);
        Applicant__c applicant = UthApplicant.getAll().get(0);
        Member__c member = UthMember.getAll().get(0);
        YH_Tenancy__c[] tenancies = UthTenancy.getAll();
        Assert.areEqual(FALSE, tenancies.isEmpty(),  'Tenancy must be created' );
        Assert.areEqual(TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER, tenancies[0].YH_AgreementType__c, 'Starter Tenancy must be created' );
        Assert.areEqual(application.ApplicationMethod__c, tenancies[0].YH_ApplicationMethod__c, 'Application Method must be equal' );
        Assert.areEqual(application.ReasonForTenancy__c, tenancies[0].YH_TenancyReason__c, 'Reason For Tenancy must be equal' );
        Assert.areEqual(application.TypeOfTenancy__c, tenancies[0].YH_TenancyType__c, 'Type Of Tenancy must be equal' );
        Assert.areEqual(application.TenancyStartDate__c, tenancies[0].StartDate__c, 'Tenancy Start Date must be equal' );
        Assert.areEqual(null, tenancies[0].FixedTermEndDateFromLettings__c, 'Date of occupancy must be equal to tenancy start date' );
        Assert.areEqual(applicant.Contact__c, member.Contact__c, 'Tenant must be equal' );
        Assert.areEqual(application.TenancyStartDate__c, member.dateOfOccupancy__c, 'Date of occupancy must be equal to tenancy start date' );
        Assert.areEqual(member.SynchAddress__City__s, 'Test City 1', 'Synch Address should be populated.' );
        Assert.areEqual(member.SynchAddress__PostalCode__s, 'RM8 1YQ', 'Synch Address should be populated.' );
        Assert.areEqual(member.SynchAddress__CountryCode__s, 'GB', 'Synch Address should be populated.' );
        Assert.areEqual(member.SynchPropertyAddressOnActivation__c, 'Letting', 'Synch Property Address flag should be populated' );
    }

    @isTest
    static void test_checkStarterTenancyCreationConversionDate(){
        
        Id currentUserId = UserInfo.getUserId();
        
        MetadataTriggerHandler.bypass(TA_Case_BI_ValidateUserPermissions.class.getName());
        MetadataTriggerHandler.bypass(TA_TenancyIncident_BI_CheckPermission.class.getName());
        System.runAs(new User(Id = currentUserId)) {
                    
            List<Contact> contactsList = UthContact.getAll();
            YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
                        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
                        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
                        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
                        insert property;
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id, property.Id);
            caseRecord.Property__c = property.Id;
            insert caseRecord;
            MetadataTriggerHandler.clearBypass(TA_Case_BI_ValidateUserPermissions.class.getName());
            MetadataTriggerHandler.clearBypass(TA_TenancyIncident_BI_CheckPermission.class.getName());
            YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, ApplicationDecorator.STARTER_TENANCY, System.now().addDays(1).date());
            insert application;

            Applicant__c applicant = UthApplicant.buildApplicant(UthContact.getAll()[0].Id, application.Id);
            insert applicant;
            MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
            Test.startTest();
            application = UthApplication.signApplication(application);
            update application;
            Test.stopTest();  
            MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
        }

        YH_Application__c application = UthApplication.getAll().get(0);
        Applicant__c applicant = UthApplicant.getAll().get(0);
        Member__c member = UthMember.getAll().get(0);
        YH_Tenancy__c[] tenancies = UthTenancy.getAll();
        Assert.areEqual(FALSE, tenancies.isEmpty(),  'Tenancy must be created' );
        Assert.areEqual(TenancyDecorator.TENANCY_AGREEMENT_TYPE_STARTER, tenancies[0].YH_AgreementType__c, 'Starter Tenancy must be created' );
        Assert.areEqual(application.ApplicationMethod__c, tenancies[0].YH_ApplicationMethod__c, 'Application Method must be equal' );
        Assert.areEqual(application.ReasonForTenancy__c, tenancies[0].YH_TenancyReason__c, 'Reason For Tenancy must be equal' );
        Assert.areEqual(application.TypeOfTenancy__c, tenancies[0].YH_TenancyType__c, 'Type Of Tenancy must be equal' );
        Assert.areEqual(application.TenancyStartDate__c, tenancies[0].StartDate__c, 'Tenancy Start Date must be equal' );
        Assert.areEqual(applicant.Contact__c, member.Contact__c, 'Tenant must be equal' );
        Assert.areEqual(application.StarterTenancyConversionDate__c, tenancies[0].ConversionDate__c, 'Dates must be equal' );
        Assert.areEqual(member.SynchPropertyAddressOnActivation__c, null , 'Synch Property Address flag should not be populated' );

    }


    @isTest
    static void test_checkAssuredTenancyCreation(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
                    
            List<Contact> contactsList = UthContact.getAll();
            YH_Property__c property = UthProperty.getAll().get(0);
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id, property.Id);
            insert caseRecord;

            YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, ApplicationDecorator.ASSURED_TENANCY, System.now().addDays(1).date());
            insert application;

            Applicant__c applicant = UthApplicant.buildApplicant(UthContact.getAll()[0].Id, application.Id);
            insert applicant;

            Test.startTest();
            application = UthApplication.signApplication(application);
            update application;
            Test.stopTest();         
        }

        YH_Application__c application = UthApplication.getAll().get(0);
        Applicant__c applicant = UthApplicant.getAll().get(0);
        Member__c member = UthMember.getAll().get(0);
        YH_Tenancy__c[] tenancies = UthTenancy.getAll();
        Assert.areEqual(FALSE, tenancies.isEmpty(),  'Tenancy must be created' );
        Assert.areEqual(TenancyDecorator.TENANCY_AGREEMENT_TYPE_ASSURED, tenancies[0].YH_AgreementType__c, 'Assured Tenancy must be created' );
        Assert.areEqual(application.ApplicationMethod__c, tenancies[0].YH_ApplicationMethod__c, 'Application Method must be equal' );
        Assert.areEqual(application.ReasonForTenancy__c, tenancies[0].YH_TenancyReason__c, 'Reason For Tenancy must be equal' );
        Assert.areEqual(application.TypeOfTenancy__c, tenancies[0].YH_TenancyType__c, 'Type Of Tenancy must be equal' );
        Assert.areEqual(application.TenancyStartDate__c, tenancies[0].StartDate__c, 'Tenancy Start Date must be equal' );
        Assert.areEqual(applicant.Contact__c, member.Contact__c, 'Tenant must be equal' );
    }

    @isTest
    static void test_checkRentToBuyTenancyCreation(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
                    
            List<Contact> contactsList = UthContact.getAll();
            YH_Property__c property = UthProperty.getAll()[0];
            property.YH_ProductType__c = TenancyDecorator.TENANCY_AGREEMENT_TYPE_RENT_TO_BUY;
            update property;
            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id, property.Id);
            insert caseRecord;

            YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, null, System.now().addDays(1).date());
            insert application;

            Applicant__c applicant = UthApplicant.buildApplicant(UthContact.getAll()[0].Id, application.Id);
            insert applicant;

            Test.startTest();
            application = UthApplication.signApplication(application);
            update application;
            Test.stopTest();         
        }

        YH_Application__c application = UthApplication.getAll().get(0);
        Applicant__c applicant = UthApplicant.getAll().get(0);
        Member__c member = UthMember.getAll().get(0);
        YH_Tenancy__c[] tenancies = UthTenancy.getAll();
        Assert.areEqual(FALSE, tenancies.isEmpty(),  'Tenancy must be created' );
        Assert.areEqual(TenancyDecorator.TENANCY_AGREEMENT_TYPE_RENT_TO_BUY, tenancies[0].YH_AgreementType__c, 'Rent to Buy must be created' );
        Assert.areEqual(application.ApplicationMethod__c, tenancies[0].YH_ApplicationMethod__c, 'Application Method must be equal' );
        Assert.areEqual(application.ReasonForTenancy__c, tenancies[0].YH_TenancyReason__c, 'Reason For Tenancy must be equal' );
        Assert.areEqual(application.TypeOfTenancy__c, tenancies[0].YH_TenancyType__c, 'Type Of Tenancy must be equal' );
        Assert.areEqual(application.TenancyStartDate__c, tenancies[0].StartDate__c, 'Tenancy Start Date must be equal' );
        Assert.areEqual(applicant.Contact__c, member.Contact__c, 'Tenant must be equal' );
    }

    @isTest
    static void test_checkAssuredShortholdTenancyCreation(){
        
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_CREATE_AT_NEW).Id;
        Id currentUserId = UserInfo.getUserId();
        
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TENANCY_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        System.runAs(new User(Id = currentUserId)) {
                    
            List<Contact> contactsList = UthContact.getAll();
            YH_Property__c property = UthProperty.getAll()[0];
            property.YH_RentType__c = PropertyDecorator.RENT_TYPE_MARKET_RENT;
            update property;

            Case caseRecord = UthCase.buildTenancyCase(contactsList[0].Id, property.Id);
            insert caseRecord;

            YH_Application__c application = UthApplication.buildApplication(caseRecord.Id, property.Id, null, System.now().addDays(1).date());
            insert application;

            Applicant__c applicant = UthApplicant.buildApplicant(UthContact.getAll()[0].Id, application.Id);
            insert applicant;

            Test.startTest();
            application = UthApplication.signApplication(application);
            update application;
            Test.stopTest();        
        }

        YH_Application__c application = UthApplication.getAll().get(0);
        Applicant__c applicant = UthApplicant.getAll().get(0);
        Member__c member = UthMember.getAll().get(0);
        YH_Tenancy__c[] tenancies = UthTenancy.getAll();
        Assert.areEqual(FALSE, tenancies.isEmpty(),  'Tenancy must be created' );
        Assert.areEqual(TenancyDecorator.TENANCY_AGREEMENT_TYPE_ASSURED_SHORT_HOLD, tenancies[0].YH_AgreementType__c, 'Rent to Buy must be created' );
        Assert.areEqual(application.ApplicationMethod__c, tenancies[0].YH_ApplicationMethod__c, 'Application Method must be equal' );
        Assert.areEqual(application.ReasonForTenancy__c, tenancies[0].YH_TenancyReason__c, 'Reason For Tenancy must be equal' );
        Assert.areEqual(application.TypeOfTenancy__c, tenancies[0].YH_TenancyType__c, 'Type Of Tenancy must be equal' );
        Assert.areEqual(application.TenancyStartDate__c, tenancies[0].StartDate__c, 'Tenancy Start Date must be equal' );
        Assert.areEqual(applicant.Contact__c, member.Contact__c, 'Tenant must be equal' );
    }

    @isTest
    static void test_validateTenancyEndDatesuucessSocialRent(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today();
        Date adate28days = Date.newInstance((system.today() + 28).year(), (system.today() + 28).month(), (system.today() + 28).day());
        Integer subtractdate = (Date.newInstance(1900,1,7)).daysbetween(adate28days);
        Integer remminder = Math.Mod(subtractdate,7);
        if(remminder != 0){
            remminder = 7 - Math.MOD(subtractdate,7);
        }
        adate28days +=remminder;
        atenancy.TenancyEndDate__c = adate28days;
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0], null, atenancy.TenancyEndDate__c, null, Date.today() - 30, null).message;
        Test.stopTest();
        Assert.areEqual(null, message);
    }

    @isTest
    static void test_validateTenancyEndDateerrorenddatebeforecreateddateSocialRent(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today();
        atenancy.TenancyEndDate__c = Date.today()-40;
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] , null, atenancy.TenancyEndDate__c, TenancyDecorator.TRANSFER_TENANCY_END_DATE_REASON, Date.today() - 30, null).message;
        Test.stopTest();
        Assert.areEqual(true, message.contains('End date cannot be before the date the termination notice recieved date'), 'Tenancy cannot end before terminationnotice recieved date');
    }

    @isTest
    static void test_validateTenancyEndDateEndOnSundaySocialRent(){
        Date terminationnoticerecieveddate = System.today()-10;
        Date tenancyEndOldDate = System.today().addMonths(-5);
        Datetime dt1 = (DateTime)System.today().addMonths(1);
        Date tenancyendnewenddate;
        if(String.valueOf(dt1.format('EEEE')) == TenancyDecorator.TENANCY_END_DATE_ON_SUNDAY)
        {
            tenancyendnewenddate = dt1.date() + 1;
        }else {
            tenancyendnewenddate = dt1.date();
        }
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-12);
        insert atenancy;
        
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0],tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate, null).message;
        Test.stopTest();
        Assert.areEqual(true, message.containsIgnoreCase('sunday'), 'Tenancy must always end on sunday');
    }

    @isTest
    static void test_validateNewDateMustBeGreaterThanPrevTenancyEndDateSocialRent(){
        Date terminationnoticerecieveddate = System.today()-10;
        Date currentDate = Date.today();
        Date startOfWeek = currentDate.toStartofWeek(); 
        Integer daysToAdd = 0;    
        Date sunday = startOfWeek.addDays(6);
        Date tenancyendnewenddate = sunday;
        Date tenancyEndOldDate = sunday - 3;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-12);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate, null).message;
        Test.stopTest();
        Assert.areEqual(true, message.containsIgnoreCase('The new end date must be greater than the previous end date + 7 days'), 'The new end date must be greater than the previous end date + 7 day');
    }

    @isTest
    static void test_validatedateformarketrent(){
        Date terminationnoticerecieveddate = System.today()-10;
        Date currentDate = System.today(); 
        Date tenancyendnewenddate =  currentDate - 3; 
        Date tenancyEndOldDate = currentDate-1;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
        PropertyDecorator.RENT_TYPE_RENTTOBUY);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-1);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate, null).message;
        Test.stopTest();
        Assert.areEqual(true, message.contains('The new end date must be greater than the previous end date'), 'The new end date must be greater than the previous end date');
    }

    @isTest
    static void test_validatedateforgaragerentsuccess(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.NON_RESEDENTIAL_STOCK, 'E08000035', 
        PropertyDecorator.GARAGE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today();
        Date adate7days = Date.newInstance((system.today() + 7).year(), (system.today() + 7).month(), (system.today() + 7).day());
        Integer subtractdate = (Date.newInstance(1900,1,7)).daysbetween(adate7days);
        Integer remminder = Math.Mod(subtractdate,7);
        if(remminder != 0){
            remminder = 7 - Math.MOD(subtractdate,7);
        }
        adate7days +=remminder;
        atenancy.TenancyEndDate__c = adate7days;
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0], null, atenancy.TenancyEndDate__c, null, Date.today() - 30, null).message;
        Test.stopTest();
        Assert.areEqual(null, message);
    }

    @isTest
    static void test_calculateforgaragerentsuccess(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.NON_RESEDENTIAL_STOCK, 'E08000035', 
        PropertyDecorator.GARAGE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            Date calculatedEndDate  = atenancyservice.calculateTenancyEndDate(UthTenancy.getAllWithPropertyDetails()[0], System.today());
        Test.stopTest();
        Date adate7days = Date.newInstance((system.today() + 6).year(), (system.today() + 6).month(), (system.today() + 6).day());
        Integer subtractdate = (Date.newInstance(1900,1,7)).daysbetween(adate7days);
        Integer remminder = Math.Mod(subtractdate,7);
        if(remminder != 0){
            remminder = 7 - Math.MOD(subtractdate,7);
        }
        adate7days +=remminder;
        Assert.areEqual(calculatedEndDate, adate7days);
    }

    @isTest
    static void test_calculateforsocialrentsuccess(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            Date calculatedEndDate  = atenancyservice.calculateTenancyEndDate(UthTenancy.getAllWithPropertyDetails()[0], System.today());
        Test.stopTest();
        Date adate28days = Date.newInstance((system.today() + 27).year(), (system.today() + 27).month(), (system.today() + 27).day());
        Integer subtractdate = (Date.newInstance(1900,1,7)).daysbetween(adate28days);
        Integer remminder = Math.Mod(subtractdate,7);
        if(remminder != 0){
            remminder = 7 - Math.MOD(subtractdate,7);
        }
        adate28days +=remminder;
        Assert.areEqual(calculatedEndDate, adate28days);
    }

    @isTest
    static void test_calculateformarketrentsuccess(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
        PropertyDecorator.RENT_TYPE_RENTTOBUY);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today()-10;
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            Date calculatedEndDate  = atenancyservice.calculateTenancyEndDate(UthTenancy.getAllWithPropertyDetails()[0], System.today().addMonths(2));
        Test.stopTest();
       
        Assert.areEqual(calculatedEndDate, UthTenancy.getall()[0].FixedTermEndDate__c + 1);
    }

    @isTest
    static void test_bypassValidateDateforgaragerentMutualExchange(){
        String message;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.NON_RESEDENTIAL_STOCK, 'E08000035', 
        PropertyDecorator.GARAGE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today();
        Date adate7days = Date.newInstance((system.today() + 7).year(), (system.today() + 7).month(), (system.today() + 7).day());
        Integer subtractdate = (Date.newInstance(1900,1,7)).daysbetween(adate7days);
        Integer remminder = Math.Mod(subtractdate,7);
        if(remminder != 0){
            remminder = 7 - Math.MOD(subtractdate,7);
        }
        adate7days +=remminder;
        atenancy.PrimaryReasonForLeaving__c = TenancyDecorator.TENANCY_REASON_FOR_MUTUAL_EXCHANGE;
        insert atenancy;
        TriggerBase.clearBypass('YH_Tenancy__c');
        Test.startTest();
        try{
            atenancy.TenancyEndDate__c = adate7days + 1;
            update atenancy;
        }catch(Exception e){
            message = e.getMessage();
        }
        Test.stopTest();
        Assert.areEqual(null, message, 'Validations should be bypassed for mutual exchange primary reason for leaving');
    }
    @isTest
    static void test_validateNewDateMustBeLessThanPrevTenancyEndDatePlusFourWeeksSocialRent(){
        Date terminationnoticerecieveddate = System.today()-10;
        Date currentDate = Date.today();
        Date startOfWeek = currentDate.toStartofWeek(); 
        Integer daysToAdd = 0;    
        Date sunday = startOfWeek.addDays(6);
        Date tenancyendnewenddate = sunday;
        Date tenancyEndOldDate = sunday - 29;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-12);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate,CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
        Assert.areEqual(true, message.containsIgnoreCase('The new end date can\'t be more than 4 weeks after the previous end date. Please go back to select another date before'), 'The new end date can\'t be more than 4 weeks after the previous end date. Please go back to select another date before');
    }
    
    @isTest
    static void test_validateNewDateMustBeLessThanPrevTenancyEndDatePlusFourWeeksSocialRentSuccess(){
        Date terminationnoticerecieveddate = System.today()-10;
        Date currentDate = Date.today();
        Date startOfWeek = currentDate.toStartofWeek(); 
        Integer daysToAdd = 0;    
        Date sunday = startOfWeek.addDays(6);
        Date tenancyendnewenddate = sunday;
        Date tenancyEndOldDate = sunday - 28;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_AFFORDABLE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-12);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate,CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
        Assert.areEqual(null, message);
    }
    @isTest
    static void test_validatedateformarketrentFourWeeksNegative(){
        Date terminationnoticerecieveddate = System.today()-40;
        Date currentDate = System.today(); 
        Date tenancyendnewenddate =  currentDate+30; 
        Date tenancyEndOldDate = currentDate+1;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
        PropertyDecorator.RENT_TYPE_RENTTOBUY);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-6);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate, CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
        Assert.areEqual(true, message.contains('The new end date can\'t be more than 4 weeks after the previous end date. Please go back to select another date before'), 'The new end date can\'t be more than 4 weeks after the previous end date. Please go back to select another date before');
    }
    @isTest
    static void test_validatedateformarketrentTwoMonthsNegative(){
        Date terminationnoticerecieveddate = System.today()-40;
        Date currentDate = System.today(); 
        Date tenancyendnewenddate =  currentDate.addMonths(3); 
        Date tenancyEndOldDate = currentDate+1;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_MARKET_RENT,
        PropertyDecorator.PRODUCT_TYPE_MARKETRENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-6);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate, CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
        Assert.areEqual(true, message.contains('The new end date can\'t be more than 2 calendar months after the previous end date. Please go back to select another date before'), 'The new end date can\'t be more than 2 calendar months after the previous end date. Please go back to select another date before');
    }
    @isTest
    static void test_validatedateformarketrentFourWeeksSuccess(){
        Date terminationnoticerecieveddate = System.today()-40;
        Date currentDate = System.today(); 
        Date tenancyendnewenddate =  currentDate+29; 
        Date tenancyEndOldDate = currentDate+1;
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
        PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
        PropertyDecorator.RENT_TYPE_RENTTOBUY);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        atenancy.StartDate__c = System.today().addMonths(-6);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate, CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
		Assert.areEqual(null, message);    
    }
    @isTest
    static void test_validatedateforGarageRent4Weekssuccess(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.NON_RESEDENTIAL_STOCK, 'E08000035', 
        PropertyDecorator.GARAGE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        Date terminationnoticerecieveddate = System.today()-10;
        Date currentDate = Date.today();
        Date startOfWeek = currentDate.toStartofWeek(); 
        Integer daysToAdd = 0;    
        Date sunday = startOfWeek.addDays(6);
        Date tenancyendnewenddate = sunday;
        Date tenancyEndOldDate = sunday - 28;
        atenancy.StartDate__c = System.today().addMonths(-12);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate,CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
        Assert.areEqual(null, message);
    }
    @isTest
    static void test_validatedateforGarageRent4WeeksFailure(){
        YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
        PropertyDecorator.NON_RESEDENTIAL_STOCK, 'E08000035', 
        PropertyDecorator.GARAGE_RENT,
        PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
        insert property;
        TriggerBase.bypass('YH_Tenancy__c');
        YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        Date terminationnoticerecieveddate = System.today()-10;
        Date currentDate = Date.today();
        Date startOfWeek = currentDate.toStartofWeek(); 
        Integer daysToAdd = 0;    
        Date sunday = startOfWeek.addDays(6);
        Date tenancyendnewenddate = sunday;
        Date tenancyEndOldDate = sunday - 29;
        atenancy.StartDate__c = System.today().addMonths(-12);
        insert atenancy;
        Test.startTest();
            TenancyService atenancyservice = new TenancyService();
            String message = atenancyservice.validateEndDate(UthTenancy.getAllWithPropertyDetails()[0] ,tenancyEndOldDate, tenancyendnewenddate, TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON, terminationnoticerecieveddate,CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL).message;
        Test.stopTest();
        Assert.areEqual(true, message.containsIgnoreCase('The new end date can\'t be more than 4 weeks after the previous end date.'), 'The new end date can\'t be more than 4 weeks after the previous end date. Please go back to select another date before');
    }

}