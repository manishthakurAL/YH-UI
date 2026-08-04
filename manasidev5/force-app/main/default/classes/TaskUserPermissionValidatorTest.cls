@isTest(seeAllData=false)
public with sharing class TaskUserPermissionValidatorTest {

    private static String SUBJECT = 'Sample';
    private static String FIRST_NAME = 'testFName';
    private static String LAST_NAME = 'testLName';
    private static String PROFILE_CUSTOMER_SUCCESS = 'Customer Success';
    
    @testSetup
    static void setUpTestData(){

        UthFeatureSwitches.enableCaseOmbudsmanFirstRequestRT();
        Id customSuccessProfileId = UthProfile.getProfileUsingName(PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.buildUser(null, customSuccessProfileId, FIRST_NAME, LAST_NAME);
        insert runAsUser;

        System.runAs(runAsUser){
            TriggerBase.bypass('Account');
            TriggerBase.bypass('Contact');
            TriggerBase.bypass('Case');
            Account account = UthAccount.build();
            insert account;

            Contact contact = UthContact.build(account.Id);
            contact.Email = 'test@test.com';
            insert contact;

            Case caseRecord = UthCase.buildOmbudsmanFirstRequestForActionCase(contact.Id, account.Id);
            insert caseRecord;

            TriggerBase.clearBypass('Account');
            TriggerBase.clearBypass('Contact');
            TriggerBase.clearBypass('Case');
        }
    }

    @isTest
    static void testUserWithCreateTaskPermission_Success(){

        Id customSuccessProfileId = UthProfile.getProfileUsingName(PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.getUser(customSuccessProfileId, FIRST_NAME, LAST_NAME)[0];
        
        Id permissionSetOmbudsmanFirstReqCreateId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_OMBUDSMAN_FIRSTREQFORACTION_CASE_CREATE).Id;
        UthPermissionAssigner.assignPermissionSet(runAsUser.Id, permissionSetOmbudsmanFirstReqCreateId);

        Case caseRecord = UthCase.getAll()[0];
        Contact conRecord = UthContact.getAll()[0];
        Test.startTest();
            System.runAs(runAsUser) {
                Task task = UthTask.createTaskWithAllFields(caseRecord.Id, conRecord.Id, SUBJECT, TaskDecorator.STATUS_NEW);
                insert task;
            }
        Test.stopTest();

        Integer size = UthTask.getAll().size();
        Assert.areEqual(1,size,'Should be able to insert successfully');
    }

    @isTest
    static void testUserWithCreateTaskPermission_WithoutWhatIdSuccess(){

        Id customSuccessProfileId = UthProfile.getProfileUsingName(PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.getUser(customSuccessProfileId, FIRST_NAME, LAST_NAME)[0];

        Case caseRecord = UthCase.getAll()[0];
        Contact conRecord = UthContact.getAll()[0];
        Test.startTest();
            System.runAs(runAsUser) {
                Task task = UthTask.createTaskWithAllFields(null, conRecord.Id, SUBJECT, TaskDecorator.STATUS_NEW);
                insert task;
            }
        Test.stopTest();

        Integer size = UthTask.getAll().size();
        Assert.areEqual(1,size,'Should be able to insert successfully');
    }

    @isTest
    static void testUserWithUpdateTaskPermission_Success(){

        Id customSuccessProfileId = UthProfile.getProfileUsingName(PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.getUser(customSuccessProfileId, FIRST_NAME, LAST_NAME)[0];
        
        Id permissionSetOmbudsmanFirstReqCreateId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_OMBUDSMAN_FIRSTREQFORACTION_CASE_CREATE).Id;
        Id permissionSetOmbudsmanFirstReqUpdateId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_NAME_OMBUDSMAN_FIRSTREQFORACTION_CASE_UPDATE).Id;
        UthPermissionAssigner.assignPermissionSet(runAsUser.Id, permissionSetOmbudsmanFirstReqCreateId);
        UthPermissionAssigner.assignPermissionSet(runAsUser.Id, permissionSetOmbudsmanFirstReqUpdateId);

        Case caseRecord = UthCase.getAll()[0];
        Contact conRecord = UthContact.getAll()[0];
        Test.startTest();
            System.runAs(runAsUser) {
                Task task = UthTask.createTaskWithAllFields(caseRecord.Id, conRecord.Id, SUBJECT, TaskDecorator.STATUS_NEW);
                insert task;
                task.Priority = TaskDecorator.PRIPRITY_NORMAL;
                update task;
            }
        Test.stopTest();

        Integer size = UthTask.getAll().size();
        Assert.areEqual(1,size,'Should be able to update successfully');
    }

    @isTest
    static void testOmbudsmanFirstReqAction_Failure(){

        Id customSuccessProfileId = UthProfile.getProfileUsingName(PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.getUser(customSuccessProfileId, FIRST_NAME, LAST_NAME)[0];

        Case caseRecord = UthCase.getAll()[0];
        Contact conRecord = UthContact.getAll()[0];
        String errorMessage;
        Test.startTest();
            System.runAs(runAsUser) {
                try{
                    Task task = UthTask.createTaskWithAllFields(caseRecord.Id, conRecord.Id, SUBJECT, TaskDecorator.STATUS_NEW);
                    insert task;
                } catch(Exception e){
                    errorMessage = e.getMessage();
                }
            }
        Test.stopTest();

        Integer size = UthTask.getAll().size();
        Assert.areEqual(0,size,'Should NOT be able to insert successfully');
        Assert.isTrue(errorMessage.contains(Label.TaskPermissionValidationError), 'Should NOT be able to insert successfully');
    }

    @isTest
    static void testOmbudsmanFirstReqAction_ByPassFforEmailAction(){

        Id customSuccessProfileId = UthProfile.getProfileUsingName(PROFILE_CUSTOMER_SUCCESS)[0].Id;
        User runAsUser = UthUser.getUser(customSuccessProfileId, FIRST_NAME, LAST_NAME)[0];

        Case caseRecord = UthCase.getAll()[0];
        Contact conRecord = UthContact.getAll()[0];
        String errorMessage;
        List<string> toAddress = new List<string>();
        Boolean emailDeliverabilityEnabled = true;
        toAddress.add('addleemanish@test.com');
        Test.startTest();
            System.runAs(runAsUser) {
                try {
                    Messaging.reserveSingleEmailCapacity(1);
                } catch (System.NoAccessException e) {
                    emailDeliverabilityEnabled = false;
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setToAddresses(toAddress);
                    mail.setSubject('Sample');
                    mail.setHTMLBody('Smaple Body');
                    mail.setTargetObjectId(conRecord.Id);
                    mail.setWhatId(caseRecord.Id);
                    mail.setSaveAsActivity(true);
                    mail.setUseSignature(false);
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
                allmsg.add(mail);

                try {
                    Messaging.sendEmail(allmsg,true);
                } catch (Exception e) {
                    errorMessage = e.getMessage();
                }
            }
        Test.stopTest();

        Integer size = UthTask.getAll().size();
        if(!emailDeliverabilityEnabled){
            Assert.areEqual(0,size,'Email activity task should not be created as deliverability is not set');
        }else{
            Assert.areEqual(1,size,'Email activity task should be created');
        }
    }
}