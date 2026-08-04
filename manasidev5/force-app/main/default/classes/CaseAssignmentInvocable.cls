public with sharing class CaseAssignmentInvocable {
    
    @InvocableMethod(label='Apply Case Assignment Rules')
    public static void forceAssignmentRules(List<CaseAssignmentWrapper> caseAssignmentWrapper) {
        if( !caseAssignmentWrapper.isEmpty() ){
            Set<Id> caseIds =  new Set<Id>();
            for(CaseAssignmentWrapper caseWrap : caseAssignmentWrapper){
                caseIds.addAll(new Map<Id, Case>(caseWrap.casesList).keySet());
            }
            if (caseIds != null) {
                CaseAssignmentTriggerService.triggerCaseAssingmentRules(caseIds,caseAssignmentWrapper[0].sendEmailOnAssignment);
            }
        }
    }

    public class CaseAssignmentWrapper{
        @InvocableVariable(label='Cases' description='list of cases' required=true)
        public List<Case> casesList;
        @InvocableVariable(label='Send email on case assignment' required=false)
        public boolean sendEmailOnAssignment = false;
    }
}