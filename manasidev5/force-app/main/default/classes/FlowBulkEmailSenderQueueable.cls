public with sharing class FlowBulkEmailSenderQueueable implements Queueable {
    private String subject;
    private String body;
    private List<Id> userIds;
    private String caseId;
    private List<OrgWideEmailAddress> emailAddress;

    public FlowBulkEmailSenderQueueable(String subject, String body, List<Id> userIds, String caseId, List<OrgWideEmailAddress> emailAddress) {
        this.subject = subject;
        this.body = body;
        this.userIds = userIds;
        this.caseId = caseId;
        this.emailAddress = emailAddress;
    }

    public void execute(QueueableContext context) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();

        for (Id userId : userIds) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(userId);
            email.setSubject(subject);
            email.setHtmlBody(body);
            email.setWhatId(caseId);
            email.setOrgWideEmailAddressId(emailAddress[0].Id);
            email.setSaveAsActivity(false);
            messages.add(email);
        }
        
        Messaging.sendEmail(messages, false);
    }
}