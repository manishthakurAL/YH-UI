@isTest
public with sharing class UthCronTrigger {

    public static CronTrigger getCronTriggerRecord(String jobId){
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime 
                          FROM CronTrigger WHERE Id = :jobId];
        return ct;
    }
}