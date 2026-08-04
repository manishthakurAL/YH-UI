public without sharing class CalculateTenancyEndDateInvocable {
    @InvocableMethod(label='Calculate Tenancy End date')
    public static List<TenancyEndDateResponse> calculateTenancyEndDate(List<TenancyEndDateRequest> requests) {
        List<TenancyEndDateResponse> endDateTenancies = new List<TenancyEndDateResponse>();
        TenancyEndDateResponse response;
        if(requests.size() > 1){
            throw new AuraHandledException('Only one tenancy is accepted as input based on current implementation');
        }
        if (requests != null && !requests.isEmpty()) {
            try{
                TenancyService tenancyService = new TenancyService();
                Date tenancyEndDate = tenancyService.calculateTenancyEndDate(requests[0].aTenancy, requests[0].terminationNoticeRecievedDate);
                response = new TenancyEndDateResponse(tenancyEndDate, '');
                endDateTenancies.add(response);
            }catch(Exception e){
                response = new TenancyEndDateResponse(null, e.getMessage());
                endDateTenancies.add(response);
            }
        }
        return endDateTenancies;
    } 

    public class TenancyEndDateResponse{
        @InvocableVariable
        public Date tenancyEndDate;
        @InvocableVariable
        public String errorMessage;

        public TenancyEndDateResponse(Date endDate, String errorMessage){
            this.tenancyEndDate = endDate;
            this.errorMessage = errorMessage;
        }
    }

    public class TenancyEndDateRequest{
        @InvocableVariable
        public Date terminationNoticeRecievedDate;
        @InvocableVariable
        public YH_Tenancy__c aTenancy;

    }
}