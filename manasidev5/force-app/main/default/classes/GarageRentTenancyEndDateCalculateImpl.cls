public with sharing class GarageRentTenancyEndDateCalculateImpl implements TenancyService.TenancyEndDateCalculationInterface{
    public TenancyService.Result validateTenancyEndDate(YH_Tenancy__c tenancy, Date newTenancyEndDate,
            Date previousTenancyEndDate, Date dateNoticeReceivedDate, String tenancyEndDateChangeReason, String originOfRequest)
    {
        TenancyService.Result result = new TenancyService.Result(); 
            if(dateNoticeReceivedDate != null && newTenancyEndDate <= dateNoticeReceivedDate){
                result.setError(String.format(Label.EndDateCannotBeBeforeTerminationEndDate, new List<Object>{dateNoticereceiveddate}));
            }      
            if(String.isBlank(tenancyEndDateChangeReason) || tenancyEndDateChangeReason == TenancyDecorator.EXTEND_NOTICE_PERIOD_TENANCY_END_DATE_REASON
                        || tenancyEndDateChangeReason == TenancyDecorator.NO_CONF_KEY_ARE_RETURNED_TENANCY_END_DATE_REASON){
                String dayOfWeek = ((DateTime) newTenancyEndDate).format('EEEE');
                if(newTenancyEndDate <= dateNoticeReceivedDate){
                    result.setError(String.format(Label.EndDateCannotBeBeforeTerminationEndDate, new List<Object>{dateNoticereceiveddate}));
                } 
                else if(previousTenancyEndDate != null && newTenancyEndDate < previousTenancyEndDate + 7 ){
                    result.setError(String.format(Label.NewDateMustBeGreaterThanPrevTenancyEndDate, new List<Object>{previousTenancyEndDate + 7}));
                
                }
                else if (originOfRequest == CaseDecorator.CASE_ORIGIN_CUSTOMER_PORTAL
                            && previousTenancyEndDate != null
                            && newTenancyEndDate > previousTenancyEndDate.addDays(28)) {
                    Date endDate = previousTenancyEndDate.addDays(28);
                    DateTime dt = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());
                    String formattedEndDate = dt.format('dd/MM/yyyy');

                    result.setError(String.format(Label.TenancyEndDateCannotExceedFourWeeks, new List<Object>{formattedEndDate}));
                }
                else if(!dayOfWeek.containsIgnoreCase(TenancyDecorator.TENANCY_END_DATE_ON_SUNDAY)){
                    result.setError(Label.TenancyMustBeOnSunday);
                } 
            }
        return result;
    }

    public Date calculateTenancyEndDate(YH_Tenancy__c tenancy, Date terminationNoticeReceivedDate){
        Date tenancyEndDateNew;
        Date terminationNoticeReceivedDatePlus7Days = terminationNoticeReceivedDate + 6;
        integer remainder = Math.MOD((Date.newInstance(1900,1,7)).daysbetween(terminationNoticeReceivedDatePlus7Days), 7);
        Integer deltaDays = remainder == 0 ? 0 : 7 - remainder;
        tenancyEndDateNew = terminationNoticeReceivedDatePlus7Days.adddays(deltaDays);
        return tenancyEndDateNew;
    }
}