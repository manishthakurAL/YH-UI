public class FlowCasePdfVFController {
    public String inputs { get; set; }

    public FlowCasePdfVFController() {
        String key = ApexPages.currentPage().getParameters().get('key');
        List<AwaabsLaw__c> ab = [SELECT Id, AssessmentInformation__c FROM AwaabsLaw__c WHERE Id = :key];
        if(ab[0].AssessmentInformation__c== null){
            inputs = FlowDecorator.H2_ERROR;
        }else {
        	inputs = ab[0].AssessmentInformation__c;
        }
    }
}