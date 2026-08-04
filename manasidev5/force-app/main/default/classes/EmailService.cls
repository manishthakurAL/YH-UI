public without sharing class EmailService {
    @future
    public static void sendEmail(Id contactId, Id templateId, Id orgWideEmailId) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(contactId);
        mail.setTemplateId(templateId);
        mail.setOrgWideEmailAddressId(orgWideEmailId);
        mail.setSaveAsActivity(true);
        Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}