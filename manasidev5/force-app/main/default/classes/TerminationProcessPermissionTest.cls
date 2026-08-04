@isTest
public with sharing class TerminationProcessPermissionTest {
    @TestSetup
    static void makeData(){
        UthFeatureSwitches.enableCaseTerminationRT(); 
        UthFeatureSwitches.enableCaseLettingRT();
        TriggerBase.bypass('Account');
        Account account1 = UthAccount.buildPersonAccount();
        insert account1;
        TriggerBase.clearBypass('Account');    
        
        YH_Property__c aproperty = uthProperty.buildPropertyWithDesignAssumptions(
            PropertyDecorator.AUTHORITY_BARNSLEY,
            PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
            PropertyDecorator.AUTHCODE_E08000038,
            PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
            PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
            );
        insert aproperty;

        YH_Tenancy__c tenancy = UthTenancy.build(aproperty.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
        insert tenancy;


    }

    @isTest 
    static void testTerminationProcessCreatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
                    insert caseRec; 
               }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Money Coach')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains('Money Coach'), 'Should not throw an error when creating a Termination process record');
    } 

    @isTest 
    static void testTerminationProcessCreateAndUpdateAmendment(){
        YH_Tenancy__c tenancy = UthTenancy.getAll()[0]; 
        Assert.areEqual(null, tenancy.TenancyEndDate__c, 'Tenancy End Date should be null');
        Boolean errorThown = false;
        List<Contact> contactList = UthContact.getAll();
        Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
        Date terminationNoticeReceivedDatePlus7Days = System.today() + 7;
        integer remainder = Math.MOD((Date.newInstance(1900,1,7)).daysbetween(terminationNoticeReceivedDatePlus7Days), 7);
        Integer deltaDays = remainder == 0 ? 0 : 7 - remainder;
        TerminationAmendment__c ta = UthTerminationAmendment.buildChangeTenancyEndDate(caseRec.Id, contactList[0].Id); 
        ta.ReasonTenancyEndDateChanged__c = TenancyDecorator.TRANSFER_TENANCY_END_DATE_REASON;
        ta.AmendedTenancyEndDate__c = terminationNoticeReceivedDatePlus7Days.adddays(deltaDays);
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_CREATE).Id;
        PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }
        permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
        permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
        if (permissionSetAssignment == null) {
            UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
        }

        Test.startTest(); 
        System.runAs(new User(Id = currentUserId)) {
            try {
                insert caseRec; 
                ta.Case__c = caseRec.Id;
                insert ta; 
                ta.Decision__c = 'Approved'; 
                update ta; 
            }catch (Exception exp){
                    errorThown = true; 
                }    
        }
        Test.stopTest();
        Assert.areEqual(false, errorThown, 'An exception was incorrectly thrown');
        Date endDate = UthTenancy.getTenancyById(caseRec.Tenancy__c).TenancyEndDate__c;
        Assert.areEqual(ta.AmendedTenancyEndDate__c, endDate, 'The tenancy end date should be amended');
    } 

    @isTest 
    static void testTerminationProcessCreatePermissionError(){
        Boolean errorThown = false;
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
                    insert caseRec; 
               }catch (Exception exp){
                    errorThown = true;     
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(true, errorThown, 'Should throw an error when creating a Termination process record with incorrect permissions');
    } 

    @isTest 
    static void testTerminationProcessUpdatePermission(){
        String actualErrorMsg = '';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){

            Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);

            Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_CREATE).Id;
            PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_TERMINATION_CASE_UPDATE).Id;
            permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
            if (permissionSetAssignment == null) {
                UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
            }

            System.runAs(new User(Id = currentUserId)) {
                try {
                    List<Contact> contactList = UthContact.getAll();
                    Case caseRec = UthCase.buildTerminationCase(contactList[0].Id, UthTenancy.getAll()[0].Id);
                    insert caseRec; 
                    caseRec.Subject = 'Updated subject'; 
                    update caseRec;
               }catch (Exception exp){
                    actualErrorMsg = exp.getMessage();
                    if(!actualErrorMsg.contains('Termination')){
                        throw new StringException(exp.getMessage());
                    }
                }    
            }
            Test.stopTest();
        }
        Assert.areEqual(false, actualErrorMsg.contains('Termination'), 'Should not throw an error when updating a Termination process record');
    } 
}