@isTest
private class ContentDocumentSAJobReportTweakTest {

    @IsTest
    private static void testSAJobRepTweak(){
        WorkOrder w1 = UthWorkOrder.create('ORCH01');
        WorkOrder w2 = UthWorkOrder.create('ORCH02');

        List<ServiceAppointment> saList = UthServiceAppointment.create(
                                            new map<Id,Integer>{
                                                w1.Id => 1,
                                                w2.Id => 3
                                            });  
        
        TriggerBase.byPass('ContentDocument');
        List<ContentVersion> cvList = new List<ContentVersion>();
        cvList.add(UthContentVersion.build('DMC Field Service Job Report One'));
        cvList.add(UthContentVersion.build('DMC Field Service Job Report Two'));
        cvList.add(UthContentVersion.build('DMC Field Service Job Report three'));
        cvList.add(UthContentVersion.build('DMC Field Service Job Report Four'));
        insert cvList;        
        TriggerBase.clearBypass('ContentDocument');

        Map<Id, ContentDocument> cdMap = new Map<Id, ContentDocument>(UthContentDocument.getAll());
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        cdlList.add(UthContentDocumentLink.build(cdMap.values()[0].Id, saList[0].Id));
        cdlList.add(UthContentDocumentLink.build(cdMap.values()[1].Id, saList[1].Id));
        cdlList.add(UthContentDocumentLink.build(cdMap.values()[2].Id, saList[2].Id));
        cdlList.add(UthContentDocumentLink.build(cdMap.values()[3].Id, w1.Id));
        insert cdlList;
        
        Test.startTest();
        System.enqueueJob(new ContentDocumentSAJobReportTweakService.ContentDocumentSAJobReportTweakQueueable(cdMap.values()), 0);
        Test.stopTest();
        
        Map<Id, ServiceAppointment> saMap = new Map<Id, ServiceAppointment>(UthServiceAppointment.getAll());
        Map<Id, WorkOrder> woMap = new Map<Id, WorkOrder>(UthWorkOrder.getAllWOsWithSAs());
        Map<Id, ContentDocument> cdMapUpdated = new Map<Id, ContentDocument>(UthContentDocument.getAll());

        for(ContentDocumentLink cdlRec : cdlList){
            if(cdlRec.LinkedEntityId != null && cdlRec.LinkedEntityId.getSObjectType().getDescribe().getName() == ServiceAppointmentDecorator.SOBJECT_APINAME){
                String title = String.format('{0} {1} {2} {3}', new List<String>{
                                        woMap.get(saMap.get(cdlRec.LinkedEntityId).ParentRecordId).WorkOrderNumber,
                                        saMap.get(cdlRec.LinkedEntityId).AppointmentNumber,
                                        ContentDocumentDecorator.FS_DMC_JOB_SERVICE_REPORT,
                                        DateTime.now().format('yyyy-MM-dd HH:mm')
                                    });
                System.Assert.areEqual(title, cdMapUpdated.get(cdlRec.contentDocumentId).Title, 'Title is not matched');
            }else{
                System.Assert.areEqual('DMC Field Service Job Report Four', cdMapUpdated.get(cdlRec.contentDocumentId).Title, 'Title is not matched');
            }
        }
    }
}