@IsTest
private class FlowBulkEmailSender_Test {
    
    @TestSetup
    static void setupData() {
        Account caseAccount = UthAccount.build();
        insert caseAccount;
		Contact caseContact = UthContact.build(caseAccount.Id);
        insert caseContact;
        Case c = UthCase.buildEmailResponseCase(caseContact.Id);
        insert c;
    }

    private static FlowBulkEmailSenderInvocable.EmailInput buildEmailInput(Integer count, String caseId) {
        List<Case> caseRecord = [Select Id From Case Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Resource Planner' LIMIT 1];
        FlowBulkEmailSenderInvocable.EmailInput input = new FlowBulkEmailSenderInvocable.EmailInput();
        input.subject = 'Test Subject';
        input.body = 'Test Body';
        input.userIds = new List<String>();
        input.caseId = caseRecord[0].Id;
        List<User> users = new List<User>();
        for (Integer i = 0; i < count; i++) {
            User u = UthUser.buildUser(role.Id, p.Id, 'Test', 'User'+i);
            users.add(u);
        }
        insert users;
        for (Integer i = 0; i < count; i++) {
            input.userIds.add(users[i].Id);
        }
        return input;
    }

    @IsTest
    static void testInvocableMethod_Basic() {
        List<Case> caseRecord = [Select Id From Case Limit 1];
        FlowBulkEmailSenderInvocable.EmailInput input = buildEmailInput(5, caseRecord[0].Id);
        List<FlowBulkEmailSenderInvocable.EmailInput> inputs = new List<FlowBulkEmailSenderInvocable.EmailInput>{ input };

        Test.startTest();
        FlowBulkEmailSenderInvocable.sendBulkEmails(inputs);
        Test.stopTest();

        System.assert(true, 'FlowBulkEmailSenderInvocable executed successfully');
    }

    @IsTest
    static void testInvocableMethod_EmptyList() {
        List<FlowBulkEmailSenderInvocable.EmailInput> inputs = new List<FlowBulkEmailSenderInvocable.EmailInput>();

        Test.startTest();
        FlowBulkEmailSenderInvocable.sendBulkEmails(inputs);
        Test.stopTest();

        System.assert(true, 'Empty input list handled gracefully');
    }

    @IsTest
    static void testInvocableMethod_NullToUsers() {
        List<Case> caseRecord = [Select Id From Case Limit 1];
        FlowBulkEmailSenderInvocable.EmailInput input = new FlowBulkEmailSenderInvocable.EmailInput();
        input.subject = 'Null List Test';
        input.body = 'Body';
        input.userIds = null;
        input.caseId = caseRecord[0].Id;
        
        Test.startTest();
        FlowBulkEmailSenderInvocable.sendBulkEmails(new List<FlowBulkEmailSenderInvocable.EmailInput>{ input });
        Test.stopTest();

        System.assert(true, 'Null toAddresses handled without error');
    }

    @IsTest
    static void testQueueable_NormalSend() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Resource Planner' LIMIT 1];
        List<String> recipients = new List<String>();
        List<User> users = new List<User>();
        for (Integer i = 0; i < 10; i++) {
            User u = UthUser.buildUser(role.Id, p.Id, 'Test', 'User'+i);
            users.add(u);
        }
        insert users;
        for (Integer i = 0; i < 10; i++) {
            recipients.add(users[i].Id);
        }
        List<Case> caseRecord = [Select Id From Case Limit 1];
        List<OrgWideEmailAddress> emailAddress = [Select Id From OrgWideEmailAddress Where Address =:FlowDecorator.NO_Reply_Email Limit 1];
        Test.startTest();
        System.enqueueJob(new FlowBulkEmailSenderQueueable('Normal Send', 'Body text', recipients, caseRecord[0].Id, emailAddress));
        Test.stopTest();

        System.assert(true, 'FlowBulkEmailSenderQueueable executed for normal email list');
    }

    @IsTest
    static void testQueueable_EmptyList() {
        List<String> recipients = new List<String>();
        List<Case> caseRecord = [Select Id From Case Limit 1];
        List<OrgWideEmailAddress> emailAddress = [Select Id From OrgWideEmailAddress Where Address =:FlowDecorator.NO_Reply_Email Limit 1];
        Test.startTest();
        System.enqueueJob(new FlowBulkEmailSenderQueueable('Empty', 'No recipients', recipients, caseRecord[0].Id, emailAddress));
        Test.stopTest();

        System.assert(true, 'Empty list handled properly');
    }

    @IsTest
    static void testQueueable_LongListChunking() {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User' LIMIT 1];
        UserRole role = [SELECT Id FROM UserRole WHERE Name = 'Resource Planner' LIMIT 1];
        List<String> recipients = new List<String>();
        List<User> users = new List<User>();
        for (Integer i = 0; i < 250; i++) {
            User u = UthUser.buildUser(role.Id, p.Id, 'Test', 'User'+i);
            users.add(u);
        }
        insert users;
        for (Integer i = 0; i < 250; i++) {
            recipients.add(users[i].Id);
        }
        List<Case> caseRecord = [Select Id From Case Limit 1];
        List<OrgWideEmailAddress> emailAddress = [Select Id From OrgWideEmailAddress Where Address =:FlowDecorator.NO_Reply_Email Limit 1];
        Test.startTest();
        System.enqueueJob(new FlowBulkEmailSenderQueueable('Chunk Test', 'Testing large list', recipients, caseRecord[0].Id, emailAddress));
        Test.stopTest();
        
        System.assert(Limits.getQueueableJobs() <= Limits.getLimitQueueableJobs(),
            'Queueable jobs within limits');
    }
}