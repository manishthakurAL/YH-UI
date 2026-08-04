@IsTest
public class TA_SMSMagicRequestEvent_AI_SendSMS_Test{
    @IsTest
    static void testAfterInsert_createsSMSHistory(){       
        Account account1 = UthAccount.buildPersonAccount();
        account1.PersonMobilePhone = '0734546478';
        insert account1;
		Contact contact1 = UthContact.getAll().get(0);
        SMSMagicRequestEvent__e smsEvent = new SMSMagicRequestEvent__e(
                ContactId__c = contact1.Id,
                Message__c = 'Hello Test User!',
                RequestedById__c = UserInfo.getUserId()
            );

        Test.startTest();
           	EventBus.Publish(smsEvent);
        Test.stopTest();
        
		List<smagicinteract__smsMagic__c> smsRecords = UthSMSMagic.getSMSRecords();
        System.assertEquals(1, smsRecords.size(), 'SMS record should have been created');
        smagicinteract__smsMagic__c sms = smsRecords[0];
        System.assertEquals(contact1.Id, sms.smagicinteract__Contact__c);
        System.assertEquals('Hello Test User!', sms.smagicinteract__SMSText__c);
        System.assertEquals(UserInfo.getUserId(), sms.RequestedBy__c);
        System.assertEquals(contact1.MobilePhone, sms.smagicinteract__PhoneNumber__c); 
        System.assertEquals(contact1.name, sms.smagicinteract__Name__c); 
    }
}