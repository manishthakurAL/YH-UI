public with sharing class MarketRentTenancyEndDateCalculateImpl implements TenancyService.TenancyEndDateCalculationInterface {
   public TenancyService.Result validateTenancyEndDate(YH_Tenancy__c tenancy, Date newTenancyEndDate,
            Date previousTenancyEndDate, Date dateNoticeReceivedDate, String tenancyEndDateChangeReason, String originOfRequest)
    {
        TenancyService.Result result = new TenancyService.Result();    
            if(dateNoticeReceivedDate != null && newTenancyEndDate <= dateNoticeReceivedDate){
                result.setError(String.format(Label.EndDateCannotBeBeforeTerminationEndDate, new List<Object>{dateNoticereceiveddate}));
            }   
            if(String.isBlank(tenancyEndDateChangeReason) || tenancyEndDateChangeReason == TenancyDecorator.EXTEND_NOTICE_PERIOD_TENANCY_END_DATE_REASON
                        || tenancyEndDateChangeReason == TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON){
                if(newTenancyEndDate <= previousTenancyEndDate){
                    result.setError(String.format(Label.NewDateMustBeGreaterThanPrevTenancyEndDate, new List<Object>{previousTenancyEndDate}));
                }
                else if (originOfRequest == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL
                            && previousTenancyEndDate != null
                            && newTenancyEndDate > previousTenancyEndDate.addMonths(2)) {
                    Date endDate = previousTenancyEndDate.addMonths(2);
                    DateTime dt = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
                    String formattedEndDate = dt.format('dd/MM/yyyy');

                    result.setError(String.format(Label.TenancyEndDateCannotExceedTwoMonths, new List<Object>{formattedEndDate}));
                }
            }
        
        return result; 
    } 

    public Date calculateTenancyEndDate(YH_Tenancy__c tenancy, Date terminationNoticeReceivedDate){
        Date tenancyEndDateNew  = terminationNoticeReceivedDate.addMonths(2);
        return tenancyEndDateNew;
    }
}