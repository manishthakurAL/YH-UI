public with sharing class AutoCaseRoleCreationDetailDecorator {
    public static final String OPTION_CASE_CONTACT = 'Case Contact';
    public static final String OPTION_TENANCY = 'Tenancy';

    public static Map<Id, List<AutoCaseRoleCreationDetail__mdt>> autoCaseRoleCreationDetailMap{
        get{
            if(autoCaseRoleCreationDetailMap == null){
                autoCaseRoleCreationDetailMap = new Map<Id, List<AutoCaseRoleCreationDetail__mdt>>();
                for(AutoCaseRoleCreationDetail__mdt autoCaseRoleCreationDetail : AutoCaseRoleCreationDetail__mdt.getAll().values()){
                    if(!autoCaseRoleCreationDetailMap.containsKey(autoCaseRoleCreationDetail.AutoCaseRoleCreationByCaseType__c)){
                        autoCaseRoleCreationDetailMap.put(autoCaseRoleCreationDetail.AutoCaseRoleCreationByCaseType__c, new List<AutoCaseRoleCreationDetail__mdt>{
                            autoCaseRoleCreationDetail
                        });
                    } else{
                        autoCaseRoleCreationDetailMap.get(autoCaseRoleCreationDetail.AutoCaseRoleCreationByCaseType__c).add(autoCaseRoleCreationDetail);
                    }
                }
            }
            return autoCaseRoleCreationDetailMap;
        }
        private set;
    }
}