public without sharing class CaseReporterUpdateInvocable {
    @InvocableMethod(label='Update Case and set flag')
    public static void updateCase(List<CaseReporterWrapper> CaseReporterWrapperList) {   
        List<Case> caseList = new List<Case>();
        for(CaseReporterWrapper caseWrap : CaseReporterWrapperList){
            caseList.add(caseWrap.caseRec);
        }
        if( !caseList.isEmpty() ){
                TA_Case_AI_AutoCaseRoleSetup.updateFromReporterFlow = true;
                MetadataTriggerHandler.bypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                update caseList;
                MetadataTriggerHandler.clearBypass(TA_Case_BU_ValidateUserPermissions.class.getName());
                TA_Case_AI_AutoCaseRoleSetup.updateFromReporterFlow = false;
        }
        
    }

    public class CaseReporterWrapper{
        @InvocableVariable(label='Case' description='updated case' required=true)
        public Case caseRec;
    }
}