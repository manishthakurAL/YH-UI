trigger InspectionChecklistTrigger on YH_Inspection_Checklist__c (before insert, before update) {
    new MetadataTriggerHandler().run();
}