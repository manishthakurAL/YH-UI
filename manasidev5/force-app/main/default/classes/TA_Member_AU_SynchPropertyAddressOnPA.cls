public with sharing class TA_Member_AU_SynchPropertyAddressOnPA implements TriggerAction.AfterUpdate{
    public static void afterUpdate(List<Member__c> newMemberList, List<Member__c> oldMemberList) {
        Map<Id, Member__c> newMap = new Map<Id,Member__c>(newMemberList);
        Map<Id, Member__c> oldMap = new Map<Id,Member__c>(oldMemberList);
        List<Contact> contactToUpdateList = new List<Contact>();
        for(Member__c mem : newMap.values()){
            if(mem.IsActiveValue__c != oldMap.get(mem.Id).IsActiveValue__c 
                && (  (mem.IsActiveValue__c == true && !String.isBlank(mem.SynchPropertyAddressOnActivation__c)) 
                       || (mem.IsActiveValue__c == false && !String.isBlank(mem.SynchPropertyAddressOnDeactivation__c))
                   )
                && (
                        !String.isBlank(mem.SynchAddress__City__s)  ||
                        !String.isBlank(mem.SynchAddress__Street__s)  ||
                        !String.isBlank(mem.SynchAddress__PostalCode__s)
                   )
            ){
                
                Contact contactRecord = new Contact(
                    Id = mem.Contact__c,
                    MailingCity = mem.SynchAddress__City__s,
                    MailingStreet = mem.SynchAddress__Street__s,
                    MailingPostalCode = mem.SynchAddress__PostalCode__s,
                    MailingCountry = 'United Kingdom'
                );
                if(mem.SynchPropertyAddressOnDeactivation__c == MemberDecorator.SYNCH_DEACTIVATION_TERMINATION){
                    String forwardingAddress = '';
                    if( !String.isBlank( mem.SynchAddress__Street__s)){
                        forwardingAddress = mem.SynchAddress__Street__s;
                    }
                    if( !String.isBlank( mem.SynchAddress__City__s)){
                        forwardingAddress += String.isNotBlank(forwardingAddress) ? ', '+mem.SynchAddress__City__s:'';
                    }
                    if( !String.isBlank( mem.SynchAddress__PostalCode__s)){
                        forwardingAddress += String.isNotBlank(forwardingAddress) ? ', '+mem.SynchAddress__PostalCode__s:'';
                    }
                    forwardingAddress += String.isNotBlank(forwardingAddress) ? ', United Kingdom':'';
                    contactRecord.MailingAddress__c = forwardingAddress;
                }
                contactToUpdateList.add(contactRecord);
            }
        }
        if(!contactToUpdateList.isEmpty()){
            Update contactToUpdateList;
        }
    }

}