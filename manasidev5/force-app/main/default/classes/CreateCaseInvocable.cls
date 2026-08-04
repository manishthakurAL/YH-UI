public without sharing class CreateCaseInvocable {
    
    @InvocableMethod(label='Create Case & Apply Assignment Rules')
    public static List<Case> create(List<Case> casesList) {

        if (casesList != null && !casesList.isEmpty()) {
            Database.DMLOptions dmlOption = new Database.DMLOptions();
            dmlOption.assignmentRuleHeader.useDefaultRule = true;
            for (Case newCase : casesList) {
                newCase.setOptions(dmlOption);
            }
            upsert casesList;
        }
        return casesList;
    } 

}