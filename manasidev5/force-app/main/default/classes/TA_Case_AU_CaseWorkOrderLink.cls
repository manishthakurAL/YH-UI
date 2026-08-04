public with sharing class TA_Case_AU_CaseWorkOrderLink implements TriggerAction.AfterUpdate{
    Map<String, Case> caseByJobNumber = new Map<String, Case>();
    public void afterUpdate(List<Case> newList, List<Case> oldList){
        Map<Id, Case> oldMap = new Map<Id, Case>(oldList);
        for(Case acase : newList){
            if(acase.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_AWAABSLAW && acase.CaseType__c == CaseDecorator.CASE_TYPE_DAMP_AND_MOULD){
                if(String.isNotBlank(acase.OrchardJobNumber__c)  && acase.OrchardJobNumber__c != oldMap.get(acase.Id).OrchardJobNumber__c){
                    caseByJobNumber.put(acase.OrchardJobNumber__c, acase);

                }
                if(String.isNotBlank(acase.FurtherWorksJobNumber__c) && acase.FurtherWorksJobNumber__c != oldMap.get(acase.Id).FurtherWorksJobNumber__c){
                    List<String> individualJobNumbers = acase.FurtherWorksJobNumber__c.split(',');
                    caseByJobNumber.put(individualJobNumbers[individualJobNumbers.size() - 1], acase);
                }
            }
        }
        if( !caseByJobNumber.isEmpty()){
            linkUnlinkCaseToWorkOrder();
        }
    }

    private void linkUnlinkCaseToWorkOrder(){
        List<WorkOrder> workOrders = [SELECT Id, CaseId, OrchardJobNumber__c FROM WorkOrder WHERE OrchardJobNumber__c IN :caseByJobNumber.keySet()];
        for(WorkOrder aworkOrder : workOrders){
            if( !String.isEmpty(aworkOrder.OrchardJobNumber__c) ){
                Case caseRecord = caseByJobNumber.get(aworkOrder.OrchardJobNumber__c);
                aworkOrder.CaseId = caseRecord.Id;
            }
        }
        if( !workOrders.isEmpty() ){ 
            update workOrders;
        }
    }
}