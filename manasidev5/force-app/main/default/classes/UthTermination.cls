@isTest
public with sharing class UthTermination { 
        public static Termination__c build(Id caseId, Id contactId){
            Termination__c termination = new Termination__c(
                Case__c = caseId,
                DetailsOfAdaptations__c = 'test'    
            );
            return termination;
        }
        
        public static List<Termination__c> getAll(){
            return Database.query('SELECT '+
                String.join(new List<String>(Termination__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                            //add more feilds from related object as and wehn required
                ' FROM Termination__c '
            );
        }  

        public static void setForwardingAddress(Termination__c terminationRecord) {
            terminationRecord.ForwardingAddress__City__s ='Test';
            terminationRecord.ForwardingAddress__Street__s ='Test Street';
            terminationRecord.ForwardingAddress__PostalCode__s = 'IOPPE';
        }   
}