@isTest
public class UthFSOrgSettings {

    public static FSOrgSettings__c build(){
        FSOrgSettings__c orgsetting = FSOrgSettings__c.getInstance();
        orgsetting.SACreationJobExcludeScopeInHours__c = -1;
        orgsetting.SACreationJobIncludeScopeInHours__c = -48;
        orgsetting.SACreationJobRecordScope__c = 10;
        orgsetting.setupOwnerId = Userinfo.getOrganizationId();
        return orgsetting;
    }
    
    public static void create(){
        FSOrgSettings__c orgsetting = build();
        Upsert orgsetting;
    }
}