public with sharing class TA_Case_BU_SystemOriginValidation implements TriggerAction.BeforeUpdate {
    public void beforeUpdate(List<Case> newList,  List<Case> oldList){
        Map<Id, Case> oldCaseMap = new Map<Id, Case>(oldList);
        List<Case> originUpdatedCases = new List<Case>();
        for(Case newCase: newList){
            if(newCase.Origin != null && newCase.Origin != oldCaseMap.get(newCase.Id).Origin){
                originUpdatedCases.add(newCase);
            }
        }
        new CaseService().checkSystemOriginValidation(originUpdatedCases);
    }
}