public with sharing class SourceMappingByCaseRecordTypeAndType {

    private String recordType;
    private String caseType;
    private Id recordId;
    private Boolean validateIdWithCreateFromSobject;

    private List<String> relationOfRecordToCase;
    private Boolean isAllowedToCreateCaseFromRecord = true;
    private Boolean createNotAllowedForRT;

    public SourceMappingByCaseRecordTypeAndType(String recordType, String caseType, Id recordId, 
            Boolean validateIdWithCreateFromSobject){
        this.recordType = recordType;
        this.caseType = caseType;
        this.recordId = recordId;
        this.validateIdWithCreateFromSobject = validateIdWithCreateFromSobject == null ? false : true;

        this.relationOfRecordToCase = new List<String>();
        this.isAllowedToCreateCaseFromRecord = true;
    }

    @TestVisible private static List<SourceMappingbyCaseRTandTypeDetail__mdt> mappingDetails;
    @TestVisible private static List<SourceMappingbyCaseRTandType__mdt> mappingRecord;

    private String recordObjectType{
        get{
            if(String.isBlank(this.recordObjectType)){
                this.recordObjectType = this.recordId.getSobjectType() + '';
                if(this.recordId.getSobjectType() == Account.SobjectType){
                    List<Account> accountRecord = [SELECT ID FROM Account WHERE Id=:recordId AND 
                            IsPersonAccount = true ];
                    if(!accountRecord.isEmpty() ){
                        this.recordObjectType = SourceMappingbyCaseRTandTypeDecorator.PERSONACCOUNT;
                    }
                }
            }
            return this.recordObjectType;
        }
        set;
    }

    @InvocableMethod(label = 'Fetch releavant case source details')
    public static List<Response> fetchTheRelevantCaseSourceDetails(List<SourceMappingByCaseRecordTypeAndType.Request> inputs){
        SourceMappingByCaseRecordTypeAndType.Response output;
        List<SourceMappingByCaseRecordTypeAndType.Response> outputs = 
                    new List<SourceMappingByCaseRecordTypeAndType.Response>();
        if(inputs != null && !inputs.isEmpty()){
            SourceMappingByCaseRecordTypeAndType.Request arequest = inputs[0];
            SourceMappingByCaseRecordTypeAndType srcMappingByCaseRTandType = new SourceMappingByCaseRecordTypeAndType(
                arequest.recordType, arequest.caseType, arequest.recordId, arequest.validateIdWithCreateFromSobject
            );
            output = srcMappingByCaseRTandType.fetchTheCaseSourceDetails();
            outputs.add(output);
        }
        return outputs;
    }

    public SourceMappingByCaseRecordTypeAndType.Response fetchTheCaseSourceDetails(){
        Boolean isCaseTypeFound = false;
        SourceMappingByCaseRecordTypeAndType.Response output;
        if(SourceMappingByCaseRecordTypeAndType.mappingRecord == null){
            SourceMappingByCaseRecordTypeAndType.mappingRecord = [
                SELECT RecordType__c,
                CreateFromSObject__c, RelationoftheRecordtoCase__c                   
                        FROM SourceMappingbyCaseRTandType__mdt  
                        WHERE  DeveloperName =: this.recordType
            ];
        }

        if(SourceMappingByCaseRecordTypeAndType.mappingRecord.isEmpty() ){          
            output  = new SourceMappingByCaseRecordTypeAndType.Response(
                null, false, true
            );
            return output;
        }

        if(SourceMappingByCaseRecordTypeAndType.mappingDetails == null){
            SourceMappingByCaseRecordTypeAndType.mappingDetails = [SELECT 
            CreateFromSObject__c, RelationoftheRecordtoCase__c, CaseType__c                   
                                FROM SourceMappingbyCaseRTandTypeDetail__mdt 
                        WHERE SourceMappingbyCaseRTandType__r.DeveloperName = :this.recordType and CaseType__c
                                    = :this.caseType];
        }
       
       
        for(SourceMappingbyCaseRTandTypeDetail__mdt inputRequest : SourceMappingByCaseRecordTypeAndType.mappingDetails){           
                this.relationOfRecordToCase.addAll(inputRequest.RelationoftheRecordtoCase__c.split(';'));
                isCaseTypeFound = true;
                if(this.validateIdWithCreateFromSobject){
                    if(this.recordObjectType != inputRequest.CreateFromSObject__c ){
                        this.isAllowedToCreateCaseFromRecord = false;
                    }
                }else{
                    this.isAllowedToCreateCaseFromRecord = true;
                }

                if( inputRequest.RelationoftheRecordtoCase__c == SourceMappingbyCaseRTandTypeDecorator.RELATIONOFRECORDTOCASESYSTEM){
                    this.createNotAllowedForRT = true;
                }
        }
    
        if(!isCaseTypeFound){
            if(!SourceMappingByCaseRecordTypeAndType.mappingRecord.isEmpty() ){
                this.relationOfRecordToCase.addAll(mappingRecord[0].RelationoftheRecordtoCase__c.split(';'));
                if(this.validateIdWithCreateFromSobject){
                    if(this.recordObjectType != mappingRecord[0].CreateFromSObject__c){
                        this.isAllowedToCreateCaseFromRecord = false;
                    }
                }else{
                    this.isAllowedToCreateCaseFromRecord = true;
                }

                if( mappingRecord[0].RelationoftheRecordtoCase__c == SourceMappingbyCaseRTandTypeDecorator.RELATIONOFRECORDTOCASESYSTEM){
                    this.createNotAllowedForRT = true;
                }
            }
        }
        output  = new SourceMappingByCaseRecordTypeAndType.Response(
            this.relationOfRecordToCase,this.isAllowedToCreateCaseFromRecord, this.createNotAllowedForRT
        );
        return output;
    }

    public class Request{
        @InvocableVariable(label='Case record type' required=true)
        public String recordType;
        @InvocableVariable(label='Case type' required=false)
        public String caseType;
        @InvocableVariable(label='Record ID' required=false)
        public String recordId;
        @InvocableVariable(label='Validate Record ID with Create from Sobject' required=false)
        public Boolean validateIdWithCreateFromSobject;
    }

    public class Response{
        @InvocableVariable(label='Relation of record to case' required=false)
        public List<String> relationOfRecordToCase;
        @InvocableVariable(label='Validate Record ID with Create from Sobject' required=false)
        public Boolean isAllowedToCreateCaseFromRecord;
        @InvocableVariable(label = 'Cannot create case for the specified Record Type' required = false)
        public Boolean createNotAllowedForRT;

        public Response(List<String> relationOfRecordToCase, Boolean isAllowedToCreateCaseFromRecord, Boolean createNotAllowedForRT){
            this.relationOfRecordToCase = relationOfRecordToCase;
            this.isAllowedToCreateCaseFromRecord = isAllowedToCreateCaseFromRecord;
            this.createNotAllowedForRT = createNotAllowedForRT;
        }
    }
}