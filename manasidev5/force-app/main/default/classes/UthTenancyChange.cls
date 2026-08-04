@isTest
public with sharing class UthTenancyChange {

    public static TenancyChange__c updateRequiredDetailsForTenancyChangeForSoleToJoint(Id caseId){
        TenancyChange__c tcRec = [SELECT Id, JointToSoleDate__c FROM TenancyChange__c WHERE Case__c =: caseId][0];
        tcRec.SoleToJointDate__c = Date.today();
        tcRec.DeedOfAssignmentDayMonthYear__c = '12 July 2024';
        update tcRec ;
        return tcRec;
    }

    public static TenancyChange__c updateRequiredDetailsForTenancyChangeForJointToSole(Id caseId){
        TenancyChange__c tcRec = [SELECT Id, JointToSoleDate__c FROM TenancyChange__c WHERE Case__c =: caseId][0];
        tcRec.JointToSoleDate__c = Date.today();
        tcRec.DeedOfAssignmentDayMonthYear__c = '12 July 2024';
        update tcRec ;
        return tcRec;
    }

    public static TenancyChange__c updateRequiredDetailsForTenancyChangeForDeathOfaTenantSurvivor(Id caseId){
        TenancyChange__c tcRec = [SELECT Id, SurvivorshipDate__c FROM TenancyChange__c WHERE Case__c =: caseId][0];
        tcRec.SurvivorshipDate__c = Date.today();
        tcRec.DeedOfAssignmentDayMonthYear__c = '12 July 2024';
        update tcRec ;
        return tcRec;
    }

    public static TenancyChange__c updateRequiredDetailsForTenancyChangeForDeathOfaTenantSuccessor(Id caseId){
        TenancyChange__c tcRec = [SELECT Id, SuccessionDate__c FROM TenancyChange__c WHERE Case__c =: caseId][0];
        tcRec.SuccessionDate__c = Date.today();
        tcRec.DeedOfAssignmentDayMonthYear__c = '12 July 2024';
        update tcRec ;
        return tcRec;
    }

    public static TenancyChange__c updateRequiredDetailsForTenancyChangeForDeathOfaTenantNoSuccessor(Id caseId){
        TenancyChange__c tcRec = [SELECT Id, NTQExpiredDate__c FROM TenancyChange__c WHERE Case__c =: caseId][0];
        tcRec.NTQExpiredDate__c = Date.today();
        tcRec.DeedOfAssignmentDayMonthYear__c = '12 July 2024';
        update tcRec ;
        return tcRec;
    }

    public static List<TenancyChange__c> getAll(){
        return Database.query('SELECT '+
			String.join(new List<String>(TenancyChange__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
			' FROM TenancyChange__c '
		);
    }
}