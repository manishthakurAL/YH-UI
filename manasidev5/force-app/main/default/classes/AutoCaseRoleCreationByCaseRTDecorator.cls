public with sharing class AutoCaseRoleCreationByCaseRTDecorator {

    public static Map<String, AutoCaseRoleCreationByCaseRT__mdt> autoCaseRoleCreationByCaseRTMap{
        get{
            if(autoCaseRoleCreationByCaseRTMap == null){
                autoCaseRoleCreationByCaseRTMap = new Map<String, AutoCaseRoleCreationByCaseRT__mdt>();
                for(AutoCaseRoleCreationByCaseRT__mdt caseRoleSetupSetting : AutoCaseRoleCreationByCaseRT__mdt.getAll().values()){
                    autoCaseRoleCreationByCaseRTMap.put(caseRoleSetupSetting.CaseRecordType__c, caseRoleSetupSetting);
                }
            }
            return autoCaseRoleCreationByCaseRTMap;
        }
        private set;
    }
}