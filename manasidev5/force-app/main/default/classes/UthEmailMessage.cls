@isTest
public with sharing class UthEmailMessage {
    public static EmailMessage build(Id parentId){
        return new EmailMessage(
            FromAddress = 'test@example.com',
            ToAddress = 'recipient@example.com',
            Subject = 'Test Email',
            HtmlBody = 'This is a test email.',
            ParentId = parentId
        );
    }

    public static EmailMessage build(Id parentId, String fromAddress, String toAddress, String ccAddress, Boolean incoming){
        EmailMessage em = build(parentId);
        em.ToAddress = toAddress;
        em.CcAddress = ccAddress;
        em.Incoming = incoming;
        return em;
    }

    public static List<EmailMessage> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(EmailMessage.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM EmailMessage');
    }
}