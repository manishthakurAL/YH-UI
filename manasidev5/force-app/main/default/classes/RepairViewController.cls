public with sharing class RepairViewController {
    
    @AuraEnabled(cacheable=true)
    public static List<TenancyGroupWrapper> getTenancies(String recordId) {
        List<TenancyGroupWrapper> tenancyList = new List<TenancyGroupWrapper>();
        if(String.isBlank(recordId)){
            User currentUser =  [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            if(currentUser.ContactId != null){
                List<Member__c> memberList = new MemberService().getActiveMembersByContactId(currentUser.ContactId);
                for(Member__c mem : memberList) {
                        TenancyGroupWrapper tenancy = new TenancyGroupWrapper(mem);
                        tenancyList.add(tenancy);
                }
            }
        }else{
            List<Case> cases = new CaseService().getCaseAndTenancyDetails(recordId);
            for(Case caseRecord : cases) {
                    TenancyGroupWrapper tenancy = new TenancyGroupWrapper(caseRecord);
                    tenancyList.add(tenancy);
            }
        }
        return tenancyList;
    }
    
   @AuraEnabled(cacheable=true)
    public static List<RepairHistoryWrapper> getRepairsRelatedTenancy(String tenancyNumber, String propertyNumber, String status, Date fromDate, Date toDate){
        List<RepairHistoryWrapper> repairList = new List<RepairHistoryWrapper>();
        try{
            ExternalService.ExtSvcGetRepairHistoryListV1 service = new ExternalService.ExtSvcGetRepairHistoryListV1(); 
            ExternalService.ExtSvcGetRepairHistoryListV1.getRepairHistoryList_Request request = new ExternalService.ExtSvcGetRepairHistoryListV1.getRepairHistoryList_Request(); 
            request.tenancyNumber = Integer.valueOf(tenancyNumber);
            request.status = status;
            request.propertyNumber = Integer.valueOf(propertyNumber);
            if(fromDate == null && toDate == null){
                request.dateTo = Date.today();
                request.dateFrom = Date.today().addMonths(-24); 
            }
            else{
                request.dateTo = toDate;
                request.dateFrom = fromDate; 
            }
            ExternalService.ExtSvcGetRepairHistoryListV1.getRepairHistoryList_Response res = service.getRepairHistoryList(request);
            if(res != null && res.responseCode == HTTPRequestResponseDecorator.SUCCESS_CODE &&  res.Code200 != null){
                    for(ExternalService.ExtSvcGetRepairHistoryListV1_getRepairsHistoryResponse response : res.Code200){
                        repairList.add(new RepairHistoryWrapper(
                                                response.jobNumber,
                                                response.dateReported,
                                                response?.contractor,
                                                response?.status,
                                                response.jobDescription
                        ));
                    }
                }
                else {
                    throwAnException();
                }
            }  
            catch (Exception ex) {
            	throwAnException();
        }
        return repairList;             
    }

    @AuraEnabled(cacheable=true)
    public static RepairDetailDataWrapper getRepairDetails(String jobNumber){
        RepairDetailDataWrapper repairWrapRes;
        try{
            ExternalService.ExtSvcGetRepairDetailsV1 service = new ExternalService.ExtSvcGetRepairDetailsV1();
            ExternalService.ExtSvcGetRepairDetailsV1.getRepairDetails_Request request = new ExternalService.ExtSvcGetRepairDetailsV1.getRepairDetails_Request(); 
            request.jobNumber = Integer.valueOf(jobNumber);
            ExternalService.ExtSvcGetRepairDetailsV1.getRepairDetails_Response res = service.getRepairDetails(request); 
            if(res != null && res.responseCode == HTTPRequestResponseDecorator.SUCCESS_CODE &&  res.Code200 != null){
                    ExternalService.ExtSvcGetRepairDetailsV1_getRepairDetailsResponse response = res.Code200;
                    List<AppointmentsWrapper> appointmentWrapList = new List<AppointmentsWrapper>();
                    for(ExternalService.ExtSvcGetRepairDetailsV1_appointment appointment :response?.appointments){
                            appointmentWrapList.add(
                                                    new AppointmentsWrapper(
                                                        appointment.appointmentDate,
                                                        appointment.timeslot,
                                                        appointment.appointmentStatus 
                                                    )
                            );
                    }
                    repairWrapRes = new RepairDetailDataWrapper(
                                                response?.jobNumber,
                                                response?.dateReported,
                                                response?.mainTrade,
                                                response?.location,
                                                response?.priority,
                                                response?.overallTargetDate,
                                                response?.completionDate,
                                                response?.contractor,
                                                response?.description,
                                                appointmentWrapList
                    );
                        

                }
                else {
                    throwAnException();
                }
            }  
            catch (Exception ex) {
            		throwAnException();
        	}
        return repairWrapRes;             
    }
    
	static void throwAnException() {
        String exMsg = 'Oops! Something did not load quite right. Please try again later.';
        AuraHandledException auraException = new AuraHandledException(exMsg);
        auraException.setMessage(exMsg);
        throw auraException;
	}
    public class TenancyGroupWrapper {
        @AuraEnabled public String tenancyId { get; set; }
        @AuraEnabled public String propertyAddress { get; set; }
        @AuraEnabled public Boolean isActive { get; set; }
        @AuraEnabled public String tenancyNumber { get; set; }
        @AuraEnabled public String propertyNumber { get; set; }
        @AuraEnabled public Date occupancyStartDate {get; set;}

        public TenancyGroupWrapper(Member__c member) {
            this.tenancyId = member.Tenancy__c;
            this.propertyAddress = member.Tenancy__r.PropertyAddress__c;
            this.isActive = member.IsActive__c;
            this.tenancyNumber = member.Tenancy__r.YH_TenancyNumber__c;
            this.propertyNumber = member.Tenancy__r.OrchardPropertyReferenceNumber__c;
            this.occupancyStartDate = member.DateOfOccupancy__c;
        }

        public TenancyGroupWrapper(Case caseRecord) {
            this.tenancyId = caseRecord.Tenancy__c;
            this.propertyAddress = caseRecord.Tenancy__r.PropertyAddress__c;
            this.isActive = caseRecord.Tenancy__r.Active__c;
            this.tenancyNumber = caseRecord.Tenancy__r.YH_TenancyNumber__c;
            this.propertyNumber = caseRecord.Tenancy__r.OrchardPropertyReferenceNumber__c;
        }
    }

    List<RepairDetailDataWrapper> repairsData { get; set; }

    public class RepairDetailsDataWrapper {
        @AuraEnabled public List<RepairDetailDataWrapper> repairsDetails { get; set; }
        @AuraEnabled public Integer totalCount { get; set; }
        
        public RepairDetailsDataWrapper() {
            this.repairsDetails = new List<RepairDetailDataWrapper>();
            this.totalCount = 0;
        }
    }
    
    public class RepairHistoryWrapper{
        @AuraEnabled public Integer jobNumber { get; set; }
        @AuraEnabled public String DateReported { get; set; }
        @AuraEnabled public String contractor { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String description { get; set; }
        public RepairHistoryWrapper(Integer jobNumber, String DateReported, String contractor, 
                                        String status, String description) {
            this.jobNumber = jobNumber;
            this.DateReported = DateReported;
            this.contractor = contractor;
            this.status = status;
            this.description = description;                                
        }
    }
    public class RepairDetailDataWrapper {
        @AuraEnabled public Integer jobNumber { get; set; }
        @AuraEnabled public String reportedOn { get; set; }
        @AuraEnabled public String repairType {get;set;}
        @AuraEnabled public String locationOfRepair {get;set;}
        @AuraEnabled public String priority { get; set; }
        @AuraEnabled public String targetDate { get; set; }
        @AuraEnabled public String completionDate {get;set;}
        @AuraEnabled public String contractor { get; set; }  
        @AuraEnabled public String description {get;set;}      
        
        @AuraEnabled public List<AppointmentsWrapper> appointments {get;set;}

        public RepairDetailDataWrapper(Integer jobNumber, String reportedOn, String repairType, String locationofrepair,
                                        String priority, String targetDate, String completionDate, String contractor, 
                                        String description,
                                        List<AppointmentsWrapper> appointments ) {

            this.jobNumber = jobNumber;
            this.reportedOn = reportedOn;
            this.targetDate = targetDate;
            this.contractor = contractor;
            this.priority = priority;
            this.completionDate = completionDate;
            this.locationOfRepair = locationofrepair;
            this.repairType = repairType;
            this.description = description;
            this.appointments = appointments;
        }
    }

    public class AppointmentsWrapper{
        @AuraEnabled
        public String  appointmentDate {get;set;}
        @AuraEnabled
        public String timeSlot{get;set;}
        @AuraEnabled
        public String status {get;set;}

        public AppointmentsWrapper(String appointmentDate, String timeSlot, String status){
            this.appointmentDate = appointmentDate;
            this.timeSlot = timeSlot;
            this.status = status;
        }
    }
}