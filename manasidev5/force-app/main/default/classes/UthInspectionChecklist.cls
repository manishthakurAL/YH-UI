public with sharing class UthInspectionChecklist {
    public static List<YH_Inspection_Checklist__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(YH_Inspection_Checklist__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM YH_Inspection_Checklist__c');
    }
}