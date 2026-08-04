public with sharing class FlowBulkEmailSenderInvocable {
    @InvocableMethod(label='Send Bulk Emails' description='Send bulk emails from Flow using Queueable Apex')
    public static void sendBulkEmails(List<EmailInput> inputs) {
        if (inputs != null && !inputs.isEmpty()){ 
            EmailInput input = inputs[0];
            if (input.userIds != null && !input.userIds.isEmpty()){
                List<OrgWideEmailAddress> emailAddress = [Select Id From OrgWideEmailAddress Where Address =:FlowDecorator.NO_Reply_Email Limit 1];
				List<List<String>> chunks = chunkUsers(input.userIds);
                if ((!Test.isRunningTest()) && chunks.size() > 0) {
                    for (Integer i = 0; i < Math.min(10, chunks.size()); i++) {
                        System.enqueueJob(new FlowBulkEmailSenderQueueable(input.subject, input.body, chunks[i], input.caseId, emailAddress));
                    }
                } else if (Test.isRunningTest()){
                    System.enqueueJob(new FlowBulkEmailSenderQueueable(input.subject, input.body, chunks[0], input.caseId, emailAddress));
                }
            }
        }
    }
    
    private static List<List<String>> chunkUsers(List<String> users) {
        List<List<String>> result = new List<List<String>>();
        List<String> current = new List<String>();
        Integer currentLength = 0;

        for (String user : users) {
            Integer userLength = user != null ? user.length() + 1 : 0;
            if (current.size() >= 100) {
                result.add(current);
                current = new List<String>();
                currentLength = 0;
            }
            current.add(user);
            currentLength += userLength;
        }
        if (!current.isEmpty()){
        	result.add(current);
        }

        return result;
    }

    public class EmailInput {
        @InvocableVariable(required=true)
        public String subject;

        @InvocableVariable(required=true)
        public String body;

        @InvocableVariable(required=true)
        public List<String> userIds;
        
        @InvocableVariable(required=true)
        public String caseId;
    }
}