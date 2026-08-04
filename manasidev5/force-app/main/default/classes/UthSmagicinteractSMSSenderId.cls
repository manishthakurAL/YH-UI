@isTest
public class UthSmagicinteractSMSSenderId {
    public static smagicinteract__SMS_SenderId__c build() {
        smagicinteract__SMS_SenderId__c sender = new smagicinteract__SMS_SenderId__c(
            smagicinteract__Label__c = SMSMagicDecorator.SENDERIDLABEL_NOREPLY,
            smagicinteract__senderId__c = 'NOREPLY'
        );
        return sender;
    }

    public static List<smagicinteract__SMS_SenderId__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(smagicinteract__SMS_SenderId__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM smagicinteract__SMS_SenderId__c '
		);
    }

}