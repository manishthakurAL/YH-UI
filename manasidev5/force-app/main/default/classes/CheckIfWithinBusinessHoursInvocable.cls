public with sharing class CheckIfWithinBusinessHoursInvocable {    
    @InvocableMethod(label='Check if Date is working day')
    public static List<BusinessHourResult> checkIfDateIsWorkingDay(List<BusinessHourRequest> businessHourRequests){
        List<BusinessHourResult> businessHourResultsList = new List<BusinessHourResult>();      
        BusinessHourService businessHourServiceInstance = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (BusinessHourRequest businessHourRequest : businessHourRequests) {
            businessHourResultsList.add(new BusinessHourResult(businessHourServiceInstance.isBusinessDay(businessHourRequest.startDateTime)));
        }
        
        return businessHourResultsList;
    }

    public class BusinessHourRequest{
        @InvocableVariable(label='Start Datetime' required=true)
        public Datetime startDateTime;

    }

    public class BusinessHourResult{
        @InvocableVariable(label='Is working day' required=true)
        public Boolean withinBusinessHours;

        public BusinessHourResult(Boolean withinBusinessHours){
            this.withinBusinessHours = withinBusinessHours;
        }
    }

}