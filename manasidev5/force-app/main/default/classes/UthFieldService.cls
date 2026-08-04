@isTest
public with sharing class UthFieldService {

    public static void basicSetup(){

        Id technicianId;
        System.runAs(new User(Id = UserInfo.getUserId())){
            technicianId = operativeSetup();
            Id fslResourceLicenseId = UthPermissionSet.getByName(UthPermissionSet.FSL_RESOURCE_LICENSE).Id;
            UthPermissionSet.setPermissionSet(technicianId, fslResourceLicenseId);
            Id fslResourcePermissionsId = UthPermissionSet.getByName(UthPermissionSet.FSL_RESOURCE_PERMISSIONS).Id;
            UthPermissionSet.setPermissionSet(technicianId, fslResourcePermissionsId);
        }        
        
        OperatingHours opHours = new OperatingHours(Name = 'Test Hours');
        insert opHours;

        ServiceTerritory territory = new ServiceTerritory(
            Name = 'Territory1',
            OperatingHoursId = opHours.Id,
            IsActive = true
        );
        insert territory;

        ServiceResource resource = new ServiceResource(
            Name = 'Tech Resource',
            RelatedRecordId = technicianId,
            ResourceType = 'T',
            OrchardOperativeID__c = 'T001',
            IsActive = true
        );
        insert resource;

        ServiceTerritoryMember member = new ServiceTerritoryMember(
            ServiceTerritoryId = territory.Id,
            ServiceResourceId = resource.Id,
            EffectiveStartDate = System.today()
        );
        insert member;
    }    

    public static Id operativeSetup(){
         return UthUser.createNonAdminUser(UserDecorator.ROLE_OPERATIVE, UserDecorator.PROFILE_FS_SERVICE_RESOURCE);
    }
}