public without sharing class SMSOtpSender implements IOtpSender{
    private User currentUser {
        get {
            if (this.currentUser == null) {
                this.currentUser = [SELECT Id, Email, Contact.MobilePhone,Contact.Id,Contact.Name
                    FROM User 
                    WHERE Id = :UserInfo.getUserId()];
            }
            return currentUser;
        }
        private set;
    }
    private String noReplySenderId{
        get{
            if(this.noReplySenderId == null){
                this.noReplySenderId = [SELECT Id,smagicinteract__senderId__c FROM smagicinteract__SMS_SenderId__c WHERE smagicinteract__Label__c =: SMSMagicDecorator.SENDERIDLABEL_NOREPLY LIMIT 1]?.smagicinteract__senderId__c;
            }
            return this.noReplySenderId;
        }
        private set;
    }
    public void sendOtp(String otp) {
        try{
			if(this.currentUser != null && String.isNotBlank(otp)){
                String body = String.format(Label.SMS_OTP_Message, new List<String>{ otp });
                SMSMagicRequestEvent__e smsEvent = new SMSMagicRequestEvent__e(
                    ContactId__c = this.currentUser.Contact.Id,
                    Message__c = body,
                    RequestedById__c = this.currentUser.Id,
                    Source__c = SMSMagicDecorator.SOURCE_HIDE,
                    SenderId__c = this.noReplySenderId
            	);
           		EventBus.Publish(smsEvent);
            }
        }
        catch (Exception e) {
            throw new SMSOtpSenderException(e.getMessage());
        }
    }
    public class SMSOtpSenderException extends Exception {}
}