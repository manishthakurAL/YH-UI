public with sharing class TA_WorkOrder_BI_LinkCaseToWorkOrder implements TriggerAction.BeforeInsert {
    Map<String, WorkOrder> workOrderByJobNumberFilter = new Map<String, WorkOrder>();
    Map<String, WorkOrder> workOrderByJobNumber = new Map<String, WorkOrder>();
    public void beforeInsert(List<WorkOrder> newList){
        for(WorkOrder aWorkOrderRecord: newList){
            if( String.isNotBlank(aWorkOrderRecord.OrchardJobNumber__c)){
                workOrderByJobNumberFilter.put('%'+aWorkOrderRecord.OrchardJobNumber__c+'%', aWorkOrderRecord);
                workOrderByJobNumber.put(aWorkOrderRecord.OrchardJobNumber__c, aWorkOrderRecord);
            }
        }
        if( !workOrderByJobNumber.isEmpty() ){
            linkUnLinkCaseToWorkOrder();       
        }
    }

    private void linkUnLinkCaseToWorkOrder(){
        Map<String, Case> casebyJobNumber = new Map<String, Case>();
        List<Case> cases = [SELECT Id, OrchardJobNumber__c, FurtherWorksJobNumber__c   
                                FROM Case WHERE  (RecordTypeId =: CaseDecorator.RECORD_TYPE_ID_AWAABSLAW AND CaseType__c =: CaseDecorator.CASE_TYPE_DAMP_AND_MOULD)
                                AND  ( OrchardJobNumber__c IN :workOrderByJobNumber.keySet()
                                         OR FurtherWorksJobNumber__c LIKE :workOrderByJobNumberFilter.keySet() )];
        for(Case acase: cases){
            if(String.isNotBlank(acase.OrchardJobNumber__c) ){
                casebyJobNumber.put(acase.OrchardJobNumber__c, acase);
            }
            if(String.isNotBlank(acase.FurtherWorksJobNumber__c)){
                for(String jobNumber: acase.FurtherWorksJobNumber__c.split(',')){
                    casebyJobNumber.put(jobNumber, acase);
                }
            }
        }

        for(WorkOrder aWorkOrderRecord: workOrderByJobNumber.values()){
            if(String.isNotBlank(aWorkOrderRecord.OrchardJobNumber__c) && casebyJobNumber.containsKey(aWorkOrderRecord.OrchardJobNumber__c)){
                Case caseRecord = casebyJobNumber.get(aWorkOrderRecord.OrchardJobNumber__c);
                aWorkOrderRecord.CaseId = casebyJobNumber.get(aWorkOrderRecord.OrchardJobNumber__c).Id;
            }
        }
    }   

}