public class EmailOtpSender implements IOtpSender{
    private Id orgwideEmailAddressId{
        get{
            if(this.orgwideEmailAddressId == null){
                this.orgwideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName =: OrgWideEmailAddressDecorator.NO_REPLY LIMIT 1].Id;
            }
            return this.orgwideEmailAddressId;
        }
        private set;
    }

    public void sendOtp(String otp) {
        try {
            CustomerPortalSettingsDecorator cps = new CustomerPortalSettingsDecorator();
          
            String body = '<br/><img src = "'+cps.yhLogoSiteURL+'"/>';
            body += '<br/><br/>';
            body +='Your security code is ' + otp + '. Please enter this code on the portal within the next 10 minutes to log in.';
            body += '<br/><br/>';
            body += 'Keep your Account safe - YH will never call, text or email you to ask for this code. Never share it with anyone.';
            body +='<br/><br/>';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(UserInfo.getUserId());
            mail.setOrgWideEmailAddressId(this.orgwideEmailAddressId);
            mail.setSubject('Your YH Portal security code.');
            mail.setHtmlBody(body);
            mail.setSaveAsActivity(false);
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        } catch (Exception e) {
            throw new EmailOtpSenderException(e.getMessage());
        }
    }
    public class EmailOtpSenderException extends Exception {}
}