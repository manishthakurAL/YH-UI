@isTest
public with sharing class UthContact {
    
    public static Contact build(Id accountId){
        return new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = accountId
        );
    }

    public static Contact build(Map<String,Object> fieldValueMap){
        Contact cont = new Contact();
        for (String fieldName: fieldValueMap.keySet()) {
            cont.put(fieldName, fieldValueMap.get(fieldName));
        }
        return cont;
    }

    public static List<Contact> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(Contact.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
            ' FROM Contact ' + 
            ' ORDER BY Id'
        );
    }

    public static List<Contact> getContactByName(String fname, String lname){
        return Database.query('SELECT '+
            String.join(new List<String>(Contact.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
            ' FROM Contact ' + 
            ' WHERE FirstName = \'' + fname + '\'' +
            ' AND LastName =\'' + lname + '\''
        );
    }
}