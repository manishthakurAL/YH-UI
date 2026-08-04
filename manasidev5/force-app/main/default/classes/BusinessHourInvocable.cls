public with sharing class BusinessHourInvocable {
    
    @InvocableMethod(label='Add Business Days')
    public static List<BusinessHourResult> addBusinessDays(List<BusinessHourRequest> businessHourRequests) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        List<BusinessHourResult> businessHourResultsList = new List<BusinessHourResult>();
        for (BusinessHourRequest businessHourRequest : businessHourRequests) {
            DateTime startDateTime = businessHourService.getNextBusinessDay(businessHourRequest.startDateTime,businessHourRequest.hourToCheck);
            BusinessHourResult businessHourResult = new BusinessHourResult();
            businessHourResult.targetDateTime = businessHourService.calculateTargetDate(businessHourRequest.numberOfDaysToAdd, startDateTime);
            businessHourResultsList.add(businessHourResult);
        }
        return businessHourResultsList;
    }

    public class BusinessHourRequest{
        @InvocableVariable(label='Start Date Time' required=true)
        public DateTime startDateTime;

        @InvocableVariable(label='Number of Days To Add' required=true)
        public Integer numberOfDaysToAdd;

        @InvocableVariable(label='Hour Check' required=false)
        public Integer hourToCheck;
    }

    public class BusinessHourResult{
        @InvocableVariable(label='Target Date Time' required=true)
        public DateTime targetDateTime;
    }
}