public with sharing class CaseDuplicateCheckerInvocable {

    public class CaseDuplicateCheckerInvocableResult{
        @InvocableVariable
        public List<Case> cases;

        @InvocableVariable
        public Boolean duplicateExist;

        @InvocableVariable
        public Boolean isDuplicateCheckRequired;

        @InvocableVariable
        public String errorMessage;
    }

    @InvocableMethod(
        label = 'Get Dupliate Case Invocable'
        description = 'Get Dupliate Case Invocable Using Record Type and Case Type '
    )
    public static List<CaseDuplicateCheckerInvocableResult> getDuplicateCases(List<Case> cases){
        List<CaseDuplicateCheckerInvocableResult> results = new List<CaseDuplicateCheckerInvocableResult>();
        CaseDuplicateCheckerInvocableResult result = new CaseDuplicateCheckerInvocableResult();

        if(!cases.isEmpty()){
            for(Case caseRecord : cases){
                try{
                    CaseDuplicateCheckerService caseDuplicateCheckerService = new CaseDuplicateCheckerService();
                    Map<Id, List<Case>> caseDuplicateCheckerServiceResponse = caseDuplicateCheckerService.getDuplicate(new List<Case>{caseRecord});
                    if(caseDuplicateCheckerServiceResponse.get(caseRecord?.Id) == null){
                        result.isDuplicateCheckRequired = false;
                    } else if(caseDuplicateCheckerServiceResponse.get(caseRecord?.Id).isEmpty()){
                        result.duplicateExist = false;
                        result.isDuplicateCheckRequired = true;
                    } else {
                        result.duplicateExist = true;
                        result.isDuplicateCheckRequired = true;
                        result.cases = caseDuplicateCheckerServiceResponse.get(caseRecord?.Id);
                    }
                } catch(exception e){
                    result.errorMessage = e.getMessage();
                }
                results.add(result);
            }
        }

        return results;
    }
}