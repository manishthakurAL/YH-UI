@isTest
public with sharing class TA_ServiceAppointment_BU_SAValidTest {

    @TestSetup
    static void makeData(){
        FSorgSettings__c fs = FSOrgSettings__c.getOrgDefaults();
        fs.FSServiceResourceProfileID__c = UthProfile.getProfileUsingName(UserDecorator.PROFILE_FS_SERVICE_RESOURCE)[0].Id;
        upsert fs;
        FSL.GlobalAPIS.addStatusTransition(ServiceAppointmentDecorator.STATUS_NONE, ServiceAppointmentDecorator.STATUS_DISPATCHED);
        FSL.GlobalAPIS.addStatusTransition(ServiceAppointmentDecorator.STATUS_NONE, ServiceAppointmentDecorator.STATUS_SCHEDULED);
        FSL.GlobalAPIS.addStatusTransition(ServiceAppointmentDecorator.STATUS_SCHEDULED, ServiceAppointmentDecorator.STATUS_DISPATCHED);

        Id fsOperativeUserId;
        System.runAs(new User(Id=UserInfo.getUserId())){
            fsOperativeUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_OPERATIVE, UserDecorator.PROFILE_FS_SERVICE_RESOURCE, 'fnam1','lnam1');
            Id fslResourceLicenseId = UthPermissionSet.getByName(UthPermissionSet.FSL_RESOURCE_LICENSE).Id;
            UthPermissionSet.setPermissionSet(fsOperativeUserId, fslResourceLicenseId);
            Id fslResourcePermissionsId = UthPermissionSet.getByName(UthPermissionSet.FSL_RESOURCE_PERMISSIONS).Id;
            UthPermissionSet.setPermissionSet(fsOperativeUserId, fslResourcePermissionsId);
             
        }
        System.runAs(new User(Id = fsOperativeUserId)){
            TriggerBase.bypass('ServiceAppointment');
            OperatingHours opHours = new OperatingHours(Name = 'TestHours');
            insert opHours;
    
            ServiceTerritory territory = new ServiceTerritory(
                Name = 'Territory1',
                OperatingHoursId = opHours.Id,
                IsActive = true
            );
            insert territory;
            ServiceResource sr = UthServiceResource.create();
            sr.OrchardOperativeID__c ='Test00010';
            update sr;
            ServiceTerritoryMember member = new ServiceTerritoryMember(
                ServiceTerritoryId = territory.Id,
                ServiceResourceId = sr.Id,
                EffectiveStartDate = System.today()
            );
            insert member;
            WorkOrder wo = UthWorkOrder.create('12345');
            WorkOrder wo1 = UthWorkOrder.create('12346');

            ServiceAppointment sa = UthServiceAppointment.create(wo.Id);
            sa.AssignedOperativeOrchardIdInFS__c = 'Test00010';
            update sa;
            ServiceAppointment sa2 = UthServiceAppointment.create(wo1.Id, Datetime.now() + 5);
            sa2.AssignedOperativeOrchardIdInFS__c = 'Test00010';
            update sa2;

            ServiceResourceStep__c srs = UthServiceResourceStep.create(sr.Id);
            UthAssignedResource.create(new Set<Id>{sa.Id, sa2.Id}, sr.Id);
            TriggerBase.clearBypass('ServiceAppointment');
        }
    }
    @isTest
    static void validateTestAbsenceReporting(){ 
        List<ServiceResource> sr = UthServiceResource.getAll();
        system.runAs(new User(Id=sr[0].RelatedRecordId	)){

        Test.startTest();
                try{
                    List<ServiceAppointment> appointments = UthServiceAppointment.getAll();
                    appointments[0].Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
                    update appointments[0];
                }
                catch(Exception e){
                    Assert.isNotNull(e.getMessage());
                    Assert.isTrue( e.getMessage().contains(Label.AbsenceReporting));
                }
            
        Test.stopTest();
        }
    }

    @isTest
    static void validateTestBypassvalidation(){ 
        List<ServiceResource> sr = UthServiceResource.getAll();
        sr[0].BypassOperativeWorkStepValidations__c = true;
        update sr;
        ServiceResourceStep__c srs = UthServiceResourceStep.getAll()[0];
        srs.VanCheckDT__c = Datetime.now();
        srs.AbsOrIssueReportingCheckDT__c = Datetime.now();
        update srs;
        system.runAs(new User(Id=sr[0].RelatedRecordId	)){
        Test.startTest();
                try{
                    List<ServiceAppointment> appointments = UthServiceAppointment.getAll();
                    for(ServiceAppointment saRec: appointments){
                        saRec.Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
                    }
                    update appointments;
                    
                    appointments = UthServiceAppointment.getAll();
                    for(ServiceAppointment saRec: appointments){
                        Assert.areEqual(saRec.Status,ServiceAppointmentDecorator.STATUS_DISPATCHED);
                    }
                }
                catch(Exception e){
                    
                }
            
        Test.stopTest();
        }
    }

    @isTest
    static void validateTestProceedable(){ 
        List<ServiceResource> sr = UthServiceResource.getAll();
        ServiceResourceStep__c srs = UthServiceResourceStep.getAll()[0];
        srs.VanCheckDT__c = Datetime.now();
        srs.AbsOrIssueReportingCheckDT__c = Datetime.now();
        update srs;
        system.runAs(new User(Id=sr[0].RelatedRecordId	)){
        Test.startTest();
                try{
                    List<ServiceAppointment> appointments = UthServiceAppointment.getAll();
                    appointments[0].Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
                    update appointments[0];
                    appointments = UthServiceAppointment.getAll();
                    Assert.areEqual(appointments[0].Status,ServiceAppointmentDecorator.STATUS_DISPATCHED);
                    appointments[1].Status = ServiceAppointmentDecorator.STATUS_DISPATCHED;
                    update appointments[1];
                }
                catch(Exception e){
                    Assert.isNotNull(e.getMessage());
                    Assert.isTrue( e.getMessage().contains(Label.IncorrectServiceAppointmentUpdate));
                }
            
        Test.stopTest();
        }
    }
}