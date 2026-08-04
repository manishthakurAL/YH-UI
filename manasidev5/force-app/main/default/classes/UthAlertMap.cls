@isTest
public class UthAlertMap {

    public static List<AlertMap__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(AlertMap__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM AlertMap__c');
    }
}