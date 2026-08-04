public with sharing class TA_Case_BI_SystemOriginValidation implements TriggerAction.BeforeInsert{
    public void beforeInsert(List<Case> newList){
        new CaseService().checkSystemOriginValidation(newList);
    }
}