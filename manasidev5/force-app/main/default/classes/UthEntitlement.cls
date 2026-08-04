@isTest
public with sharing class UthEntitlement {

    private static SlaProcess complaintSLAProcess {
        get {
            if(complaintSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.COMPLAINT_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    complaintSLAProcess = slaProcessList[0];
                }
            }
            return complaintSLAProcess;
        }
        set;
    }

    private static SlaProcess moneyCoachingSLAProcess {
        get {
            if(moneyCoachingSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.MONEY_COACHNONG_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    moneyCoachingSLAProcess = slaProcessList[0];
                }
            }
            return moneyCoachingSLAProcess;
        }
        set;
    }

    private static SlaProcess tenancyCoachingSLAProcess {
        get {
            if(tenancyCoachingSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.TENANCY_COACHING_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    tenancyCoachingSLAProcess = slaProcessList[0];
                }
            }
            return tenancyCoachingSLAProcess;
        }
        set;
    }

    private static SlaProcess changesSLAProcess {
        get {
            if(changesSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.CHANGES_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    changesSLAProcess = slaProcessList[0];
                }
            }
            return changesSLAProcess;
        }
        set;
    }

    private static SlaProcess permissionSLAProcess {
        get {
            if(permissionSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.PERMISSION_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    permissionSLAProcess = slaProcessList[0];
                }
            }
            return permissionSLAProcess;
        }
        set;
    }

    private static SlaProcess placeSLAProcess {
        get {
            if(placeSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.PLACE_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    placeSLAProcess = slaProcessList[0];
                }
            }
            return placeSLAProcess;
        }
        set;
    }
    
    private static SlaProcess tenancySLAProcess {
        get {
            if(tenancySLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.TENANCY_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    tenancySLAProcess = slaProcessList[0];
                }
            }
            return tenancySLAProcess;
        }
        set;
    }
    
    private static SlaProcess awaabsStdSLAProcess {
        get {
            if(awaabsStdSLAProcess == null){
                List<SlaProcess> slaProcessList = [
                    SELECT FIELDS(Standard)
                    FROM SlaProcess 
                    WHERE Name =: EntitlementDecorator.AWAABS_STD_ENTITLEMENT_PROCESS_NAME
                    AND IsActive = true
                    ORDER BY VersionNumber DESC
                    LIMIT 1
                ];
                if(!slaProcessList.isEmpty()){
                    awaabsStdSLAProcess = slaProcessList[0];
                }
            }
            return awaabsStdSLAProcess;
        }
        set;
    }
    
    public static Entitlement buildComplaintEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement complaintEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.COMPLAINT_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = complaintSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return complaintEntitlement;
    }

    public static Entitlement buildMoneyCoachingEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement moneyCoachingEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.MONEY_COACHNONG_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = moneyCoachingSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return moneyCoachingEntitlement;
    }

    public static Entitlement buildTenancyCoachingEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement tenancyCoachingEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.TENANCY_COACHING_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = tenancyCoachingSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return tenancyCoachingEntitlement;
    }

    public static Entitlement buildChangeEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement changeEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.CHANGES_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = changesSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return changeEntitlement;
    }

    public static Entitlement buildPermissionEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement permissionEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.PERMISSION_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = permissionSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return permissionEntitlement;
    }

    public static Entitlement buildPlaceEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement placeEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.PLACE_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = placeSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return placeEntitlement;
    }

    public static Entitlement buildTenancyEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement tenancyEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.TENANCY_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = tenancySLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return tenancyEntitlement;
    }

    public static Entitlement buildAwaabsStandardEntitlement(Id accountId){
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Entitlement awaabsEntitlement = new Entitlement(
            AccountId = accountId,
            BusinessHoursId = businessHourService.businessHour.Id,
            Name = EntitlementDecorator.AWAABS_STD_ENTITLEMENT_PROCESS_NAME,
            SlaProcessId = awaabsStdSLAProcess.Id,
            StartDate = System.today(),
            EndDate = System.today().addYears(10)
        );
        return awaabsEntitlement;
    }

    public static Entitlement get(String entitlementName){
        return Database.query('SELECT '+
            String.join(new List<String>(Entitlement.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
            ' FROM Entitlement ' + 
            ' WHERE Name = \'' + entitlementName + '\'' +
            ' ORDER BY Id'
        );
    }
}