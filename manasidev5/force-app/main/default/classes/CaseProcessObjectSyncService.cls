public class CaseProcessObjectSyncService {
    private static final String FIND_PROCESS_OBJECT_SOQL_TEMPLATE = 'SELECT CaseStatus__c, CaseSubStatus__c, Case__c FROM {0} WHERE Case__c in: caseRecordIds ORDER BY CreatedDate DESC';
    private static final String FIELD_CASE_LOOKUP = 'Case__c';
    private static final String FIELD_CASE_STATUS = 'CaseStatus__c';
    private static final String FIELD_CASE_SUB_STATUS = 'CaseSubStatus__c';
    private static final String FIELD_CASE_STAGE = 'Status';
    private static final String FIELD_CASE_SUBSTATUS = 'SubStatus__c'; 


    public static CaseProcessObjectSyncService get() {
        return (new CaseProcessObjectSyncService());
    }

    public void syncCaseToProcessObject(Case[] newList, Map<Id, Case> oldList) {
        Map<String, List<SObject>> mapOfProcessRecordsByObjectName = new Map<String, 
                        List<Sobject>>();

        list<Case> caseListToQueryProcessRecs = new list<Case>();
        for (Case record : newList) {
            if (oldList.get(record.Id).Status != record.Status || oldList.get(record.Id).SubStatus__c != record.SubStatus__c){
                caseListToQueryProcessRecs.add(record);
            }
        }
        
        if(!caseListToQueryProcessRecs.isEmpty()){
            Map<Id, list<SObject>> caseProcessObjectRecordMap = getProcessObjectRecords(caseListToQueryProcessRecs);
            
            for (Case record : caseListToQueryProcessRecs) {
                if (caseProcessObjectRecordMap.containsKey(record.Id)){
                    list<SObject> processObjectRecords = caseProcessObjectRecordMap.get(record.Id);
                    for(SObject processObj : processObjectRecords){
                        String processObjectName = processObj.Id.getSObjectType() + '';
                        if(!mapOfProcessRecordsByObjectName.containsKey(processObjectName)){
                            mapOfProcessRecordsByObjectName.put(processObjectName, new List<SObject>());
                        }
                        mapOfProcessRecordsByObjectName.get(processObjectName).add(processObj);
                        sync(record, processObj);
                    }
                }
            }
        }
        
        if (!mapOfProcessRecordsByObjectName.isEmpty()) {
            Map<Id, Case> newCaseMap = new Map<Id, Case>(newList);
            for(String processObjectName: mapOfProcessRecordsByObjectName.keySet()){
                if(!mapOfProcessRecordsByObjectName.get(processObjectName).isEmpty()){
                    List<Database.SaveResult> updateResults = Database.update(mapOfProcessRecordsByObjectName.get(processObjectName), false);
                    for(Integer i=0;i<updateResults.size();i++){
                        if (!updateResults.get(i).isSuccess()){
                            String failedDML = updateResults.get(i).getErrors().get(0).getMessage();
                            Id caseId = (Id)mapOfProcessRecordsByObjectName.get(processObjectName).get(i).get(FIELD_CASE_LOOKUP);
                            newCaseMap.get(caseId).addError(failedDML);
                        }
                    }
                } 
            }
        }
        
    }

    public void sync(Case record, SObject processObjectRecord) {    
        processObjectRecord.put(FIELD_CASE_STATUS, record.get(FIELD_CASE_STAGE));
        processObjectRecord.put(FIELD_CASE_SUB_STATUS, record.get(FIELD_CASE_SUBSTATUS));            
    }

    private Map<Id, list<SObject>> getProcessObjectRecords(List<case> caseRecords) {
        Map<Id, list<SObject>> caseProcessObjectRecordMap = new Map<Id, list<SObject>>();
        Set<Id> caseRecordIds = (new Map<Id, Case>(caseRecords)).keyset();
        CaseProcessObjectMapping__mdt[] processObjectMappings = CaseProcessObjectMapping__mdt.getAll().values();
        Set<String> processObjectList = new Set<String>();
        for (case caseRecord : caseRecords) {
            String caseRecordType = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, caseRecord.RecordTypeId);
            for (CaseProcessObjectMapping__mdt mapping:processObjectMappings) {
                if (mapping.CaseRecordType__c == caseRecordType && 
                        (mapping.CaseType__c == null || mapping.CaseType__c == caseRecord.CaseType__c))  {
                    processObjectList.add(mapping.ProcessObject__c);
                }
            }
        }
        
        for (String aProcessObject : processObjectList) {
        
            String soql = String.format(FIND_PROCESS_OBJECT_SOQL_TEMPLATE, new List<String>{
                aProcessObject
            });
            for (SObject record: Database.query(soql)) {
                Id caseId = (Id)record.get(FIELD_CASE_LOOKUP);
                if (!caseProcessObjectRecordMap.containsKey(caseId)) {
                    caseProcessObjectRecordMap.put(caseId, new List<SObject>());
                }
                caseProcessObjectRecordMap.get(caseId).add(record);
            }
        }
        return caseProcessObjectRecordMap;
    }
}