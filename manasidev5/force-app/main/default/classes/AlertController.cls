public with sharing class AlertController {
    @AuraEnabled(cacheable=true)
    public static List<AlertConfig__mdt> getAllConfigs() {
        return AlertConfig__mdt.getAll().values();
    }
}