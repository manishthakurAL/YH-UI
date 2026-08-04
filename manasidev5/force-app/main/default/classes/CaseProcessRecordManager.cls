public class CaseProcessRecordManager {
    
    public static final String CASE_LOOKUP_FIELD = 'Case__c';
    private static final String FIELD_CASE_STATUS = 'CaseStatus__c';
    private static final String FIELD_CASE_STAGE = 'Status';
    
    public static void createProcessRecord( List<Case> caseList) {
        Map<String, list<CaseProcessObjectMapping__mdt>> caseProcessMap = getProcessObjectMapping();
        List<sObject> recordsToInsert = new List<sObject>();
        Map<String, List<Sobject>> processRecordsByObjectName = new Map<String, List<Sobject>>();
        for (Case record : caseList) {
            String recordTypeName = RecordTypeUtility.getRecordTypeDeveloperNameById(CaseDecorator.SOBJECT_TYPE_CASE, record.RecordTypeId);
            list<CaseProcessObjectMapping__mdt> mdtlist = new list<CaseProcessObjectMapping__mdt>();
            if(caseProcessMap.containskey(recordTypeName)){
                mdtlist.addAll(caseProcessMap.get(recordTypeName));
            }
            if(caseProcessMap.containskey(recordTypeName+'-'+record.CaseType__c)){
                mdtlist.addAll(caseProcessMap.get(recordTypeName+'-'+record.CaseType__c));
            }
            for(CaseProcessObjectMapping__mdt mdt : mdtlist){
                if(mdt.ProcessObject__c != null ){
                    List<Sobject> processRecords = processRecordsByObjectName.get(mdt.ProcessObject__c);
                    if(processRecords == null){
                        processRecords = new List<Sobject>();
                        processRecordsByObjectName.put(mdt.ProcessObject__c, processRecords);
                    }
                    Type t = Type.forName(mdt.ProcessObject__c);
                    SObject processObjRec = (SObject)t.newInstance();
                    processObjRec.put(CASE_LOOKUP_FIELD, record.Id);
                    processObjRec.put(FIELD_CASE_STATUS, record.get(FIELD_CASE_STAGE)); 
                    processRecordsByObjectName.get(mdt.ProcessObject__c).add(processObjRec);
                }
            }
        }

        if(!processRecordsByObjectName.isEmpty()){
            for(String objectName : processRecordsByObjectName.keySet()){
                recordsToInsert = processRecordsByObjectName.get(objectName);
                if( !recordsToInsert.isEmpty()){
                    insert recordsToInsert;
                }
            }
        }
    }
    public static Map<String, list<CaseProcessObjectMapping__mdt>> getProcessObjectMapping () {
        Map<String, list<CaseProcessObjectMapping__mdt>> caseProcessObjectMapping = new Map<String, list<CaseProcessObjectMapping__mdt>>();
        for(CaseProcessObjectMapping__mdt CaseProcessObjectMappingRec : CaseProcessObjectMapping__mdt.getAll().values()){
            string caseTypeIdentifier = '';
            if(CaseProcessObjectMappingRec.CaseType__c == null){
                caseTypeIdentifier = CaseProcessObjectMappingRec.CaseRecordType__c;
            }else{
                caseTypeIdentifier = CaseProcessObjectMappingRec.CaseRecordType__c+'-'+CaseProcessObjectMappingRec.CaseType__c;
            }
            if(!caseProcessObjectMapping.containskey(caseTypeIdentifier)){
                caseProcessObjectMapping.put(caseTypeIdentifier,new list<CaseProcessObjectMapping__mdt>());
            }
            caseProcessObjectMapping.get(caseTypeIdentifier).add(CaseProcessObjectMappingRec);
        }
        return caseProcessObjectMapping;
    }
}