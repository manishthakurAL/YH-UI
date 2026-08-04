@isTest
private class TA_WorkStep_AU_FileNameTweakingTest {

    @TestSetup
    static void dataSetup(){
        
        TriggerBase.bypass('ServiceAppointment');
        WorkOrder wo1 = UthWorkOrder.create('ORCH01');
        ServiceAppointment saRec = UthServiceAppointment.create(wo1.Id);
        

        WorkPlan wp1 = UthWorkPlan.createWorkPlanWithoutTemplate(wo1);
        wp1.ServiceAppointment__c = saRec.Id;
        update wp1;

        List<WorkStep> wsList = new List<WorkStep>();
        wsList.add(UthWorkStep.build(wp1, 'Access'));
        wsList.add(UthWorkStep.build(wp1, 'Wrapup'));
        insert wsList;      
        TriggerBase.clearBypass('ServiceAppointment');

        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(UthContentVersion.build('FileUploadOne'));
        cvList.add(UthContentVersion.build('FileUploadTwo'));
        cvList.add(UthContentVersion.build('FileUploadThree'));
        insert cvList;

        List<ContentVersion> cvQueriedList = UthContentVersion.getAll();

        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cvRec : cvQueriedList){
            cdlList.add(UthContentDocumentLink.build(cvRec.ContentDocumentId, saRec.Id));
        }
        insert cdlList;
    }

    @IsTest
    static void fileNameSingleUpdate(){
        List<WorkStep> wsList = UthWorkStep.getAll();
        for(WorkStep wsRec : wsList){
            if(wsRec.Name == 'Access'){
                wsRec.UploadedFileNames__c = 'FileUploadOne;';
            }
        }

        Test.StartTest();
        update wsList;
        Test.StopTest();

        List<ServiceAppointment> saList = UthServiceAppointment.getAll();
        
        for(ContentDocumentLink cdlRec : UthContentDocumentLink.getAllLinked(new Map<Id, ServiceAppointment>(saList).keyset())){                            
            String expectedTitle;
            if(cdlRec.ContentDocument.Title.startsWith('Access')){
                expectedTitle = 'Access'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_1';                
            }else if(cdlRec.ContentDocument.Title.endsWith('Two')){
                expectedTitle = 'FileUploadTwo';
            }else{
                expectedTitle = 'FileUploadThree';
            }
            System.Assert.areEqual(expectedTitle, cdlRec.ContentDocument.Title);
        }
    }

    @IsTest
    static void fileNameSingleUpdateNoMatch(){
        List<WorkStep> wsList = UthWorkStep.getAll();
        for(WorkStep wsRec : wsList){
            if(wsRec.Name == 'Access'){
                wsRec.UploadedFileNames__c = 'FileUploadFive;';
            }
        }

        Test.StartTest();
        update wsList;
        Test.StopTest();

        List<ServiceAppointment> saList = UthServiceAppointment.getAll();
        
        for(ContentDocumentLink cdlRec : UthContentDocumentLink.getAllLinked(new Map<Id, ServiceAppointment>(saList).keyset())){                            
            String expectedTitle;
            if(cdlRec.ContentDocument.Title.endsWith('One')){
                expectedTitle = 'FileUploadOne';             
            }else if(cdlRec.ContentDocument.Title.endsWith('Two')){
                expectedTitle = 'FileUploadTwo';
            }else{
                expectedTitle = 'FileUploadThree';
            }
            System.Assert.areEqual(expectedTitle, cdlRec.ContentDocument.Title);
        }
    }

    @IsTest
    static void fileNameMultipleUpdate(){
        List<WorkStep> wsList = UthWorkStep.getAll();
        for(WorkStep wsRec : wsList){
            if(wsRec.Name == 'Access'){
                wsRec.UploadedFileNames__c = 'FileUploadOne;';
            }else{
                wsRec.UploadedFileNames__c = 'FileUploadTwo;';
            }
        }    
        Test.StartTest();    
        update wsList;

        List<ServiceAppointment> saList = UthServiceAppointment.getAll();

        for(WorkStep wsRec : wsList){
            if(wsRec.UploadedFileNames__c == 'FileUploadTwo;'){
                wsRec.UploadedFileNames__c = 'FileUploadTwo;FileUploadThree;';
            }
        }

        update wsList;
        Test.StopTest();

        saList = UthServiceAppointment.getAll();
        
        for(ContentDocumentLink cdlRec : UthContentDocumentLink.getAllLinked(new Map<Id, ServiceAppointment>(saList).keyset())){                            
            String expectedTitle;
            if(cdlRec.ContentDocument.Title.startsWith('Access')){
                expectedTitle = 'Access'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_1';
            }else if(cdlRec.ContentDocument.Title.startsWith('Wrapup')){
                if(cdlRec.ContentDocument.Title.endsWith('1')){
                    expectedTitle = 'Wrapup'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_1';
                }else{
                    expectedTitle = 'Wrapup'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_2';
                }
            }
            System.Assert.areEqual(expectedTitle, cdlRec.ContentDocument.Title);
            System.Assert.areEqual(expectedTitle, cdlRec.ContentDocument.Description);
        }
    }

    @IsTest
    static void fileNameMultipleUpdatePartialMatch(){
        List<WorkStep> wsList = UthWorkStep.getAll();
        for(WorkStep wsRec : wsList){
            if(wsRec.Name == 'Access'){
                wsRec.UploadedFileNames__c = 'FileUploadOne;';
            }else{
                wsRec.UploadedFileNames__c = 'FileUploadTwo;FileUploadFive';
            }
        }

        Test.StartTest();
        update wsList;
        Test.StopTest();

        List<ServiceAppointment> saList = UthServiceAppointment.getAll();
        
        for(ContentDocumentLink cdlRec : UthContentDocumentLink.getAllLinked(new Map<Id, ServiceAppointment>(saList).keyset())){                            
            String expectedTitle;
            if(cdlRec.ContentDocument.Title.startsWith('Access')){
                expectedTitle = 'Access'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_1';                
            }else if(cdlRec.ContentDocument.Title.startsWith('Wrapup')){
                expectedTitle = 'Wrapup'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_1';
            }else{
                expectedTitle = 'FileUploadThree';
            }
            System.Assert.areEqual(expectedTitle, cdlRec.ContentDocument.Title);
        }
    }

    @IsTest
    static void fileNameMultipleUpdateNoMatch(){
        List<WorkStep> wsList = UthWorkStep.getAll();
        for(WorkStep wsRec : wsList){
            if(wsRec.Name == 'Access'){
                wsRec.UploadedFileNames__c = 'FileUploadOne;';
            }else{
                wsRec.UploadedFileNames__c = 'FileUploadFour;FileUploadFive';
            }
        }

        Test.StartTest();
        update wsList;
        Test.StopTest();

        List<ServiceAppointment> saList = UthServiceAppointment.getAll();
        
        for(ContentDocumentLink cdlRec : UthContentDocumentLink.getAllLinked(new Map<Id, ServiceAppointment>(saList).keyset())){                            
            String expectedTitle;
            if(cdlRec.ContentDocument.Title.startsWith('Access')){
                expectedTitle = 'Access'+'_'+saList[0].AppointmentNumber+'_'+getDateTimeFormat()+'_1';                
            }else if(cdlRec.ContentDocument.Title.endsWith('Two')){
                expectedTitle = 'FileUploadTwo';
            }else{
                expectedTitle = 'FileUploadThree';
            }
            System.Assert.areEqual(expectedTitle, cdlRec.ContentDocument.Title);
        }
    }

    private static String getDateTimeFormat(){
        return System.Now().format('dd') +
        System.Now().format('MM') +
        System.Now().format('yy') +
        System.Now().format('HH') +
        System.Now().format('mm');
    }    
}