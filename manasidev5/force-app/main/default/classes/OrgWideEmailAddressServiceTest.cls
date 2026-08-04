@isTest
public class OrgWideEmailAddressServiceTest {

    @isTest
    static void testOrgWideEmailAddressService(){

        List<OrgWideEmailAddress> orgWideEmailAddresses = UthOrgWideEmailAddress.getAll();
        String emailString = 'Firsttest@test.com;Secondtest@test.com;Thirdtest@test.com;Fourthtest@test.com';
        emailString = emailString + ';' + orgWideEmailAddresses[0].Address;

        List<OrgWideEmailAddressService.Input> inputs= new List<OrgWideEmailAddressService.Input>();
        List<OrgWideEmailAddressService.Output> outputs;

        Test.startTest();
                EmailMessage em = UthEmailMessage.build(null, 'fromAddress@test.com', emailString, null, true);
                insert em;

                OrgWideEmailAddressService.Input input = new OrgWideEmailAddressService.Input();
                input.emailMessageRecord = em;
                inputs.add(input);

                outputs = OrgWideEmailAddressService.getOrgWideEmailAddress(inputs);
            Test.stopTest();

        Assert.areEqual(outputs[0].orgWideEmailAddress.Id,orgWideEmailAddresses[0].Id);
    }

    @isTest
    static void testOrgWideEmailAddressServiceWithCCAddress(){

        List<OrgWideEmailAddress> orgWideEmailAddresses = UthOrgWideEmailAddress.getAll();
        String emailString = 'Firsttest@test.com;Secondtest@test.com;Thirdtest@test.com;Fourthtest@test.com';
        emailString = emailString + ';' + orgWideEmailAddresses[0].Address;

        String ccEmailString = 'Firsttestcc@test.com;Secondtestcc@test.com;Thirdtestcc@test.com;Fourthtestcc@test.com';
        ccEmailString = ccEmailString + ';' + orgWideEmailAddresses[1].Address;

        List<OrgWideEmailAddressService.Input> inputs= new List<OrgWideEmailAddressService.Input>();
        List<OrgWideEmailAddressService.Output> outputs;

        Test.startTest();
        EmailMessage em = UthEmailMessage.build(null, 'fromAddress@test.com', emailString, ccEmailString, true);
        insert em;

        OrgWideEmailAddressService.Input input = new OrgWideEmailAddressService.Input();
        input.emailMessageRecord = em;
        inputs.add(input);

        outputs = OrgWideEmailAddressService.getOrgWideEmailAddress(inputs);
    Test.stopTest();

        Assert.areEqual(outputs[0].orgWideEmailAddress.Id,orgWideEmailAddresses[0].Id);
    }

    @isTest
    static void testOrgWideEmailAddressServiceWithCCAddressAndNoMatchToAddress(){

        List<OrgWideEmailAddress> orgWideEmailAddresses = UthOrgWideEmailAddress.getAll();
        String emailString = 'Firsttest@test.com;Secondtest@test.com;Thirdtest@test.com;Fourthtest@test.com';

        String ccEmailString = 'Firsttestcc@test.com;Secondtestcc@test.com;Thirdtestcc@test.com;Fourthtestcc@test.com';
        ccEmailString = ccEmailString + ';' + orgWideEmailAddresses[0].Address;

        List<OrgWideEmailAddressService.Input> inputs= new List<OrgWideEmailAddressService.Input>();
        List<OrgWideEmailAddressService.Output> outputs;

        Test.startTest();

            EmailMessage em = UthEmailMessage.build(null, 'fromAddress@test.com', emailString, ccEmailString, true);
            insert em;

            OrgWideEmailAddressService.Input input = new OrgWideEmailAddressService.Input();
            input.emailMessageRecord = em;
            inputs.add(input);

            outputs = OrgWideEmailAddressService.getOrgWideEmailAddress(inputs);
        Test.stopTest();

        Assert.areEqual(outputs[0].orgWideEmailAddress.Id,orgWideEmailAddresses[0].Id);
    }

    @isTest
    static void testOrgWideEmailAddressServiceNoMatch(){

        List<OrgWideEmailAddress> orgWideEmailAddresses = UthOrgWideEmailAddress.getAll();
        String emailString = 'Firsttest@test.com;Secondtest@test.com;Thirdtest@test.com;Fourthtest@test.com';

        List<OrgWideEmailAddressService.Input> inputs= new List<OrgWideEmailAddressService.Input>();
        List<OrgWideEmailAddressService.Output> outputs;

        Test.startTest();
            EmailMessage em = UthEmailMessage.build(null, 'fromAddress@test.com', emailString, null, true);
            insert em;

            OrgWideEmailAddressService.Input input = new OrgWideEmailAddressService.Input();
            input.emailMessageRecord = em;
            inputs.add(input);

            outputs = OrgWideEmailAddressService.getOrgWideEmailAddress(inputs);
        Test.stopTest();

        Assert.areEqual(outputs[0].orgWideEmailAddress.Id, null);
    }
}