public with sharing class CaseAssignmentRuleService {
    public static Map<Id, CaseAssignmentRule__mdt> CaseAssignmentRulesById{
        get{
            if(CaseAssignmentRulesById == null){
                CaseAssignmentRulesById = new Map<Id, CaseAssignmentRule__mdt>();
                OrgSetting__c orgDetting = OrgSetting__c.getInstance();
                for(CaseAssignmentRule__mdt caseAssRuleMD : CaseAssignmentRule__mdt.getAll().values()){
                    CaseAssignmentRulesById.put((Id)orgDetting.get(caseAssRuleMD.CustomSettingFieldAPIName__c), caseAssRuleMD);
                }
            }
            return CaseAssignmentRulesById;
        }
        set;
    }
}