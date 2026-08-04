public with sharing class ComplaintCaseSLACalculationService {

    public static void calculateSLAStartDate(List<Case> casesList, Map<Id, Case> oldCasesMap) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        for (Case caseRecord : casesList) {
            if (caseRecord.RecordTypeId == CaseDecorator.RECORD_TYPE_ID_COMPLAINTS) {
                if (oldCasesMap == null && caseRecord.OriginalReceivedDateTime__c != null) {
                    DateTime startDateTime = businessHourService.getNextBusinessDay(caseRecord.OriginalReceivedDateTime__c,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR);
                    caseRecord.SLAStartDate__c = startDateTime;
                    DateTime initialComplaintSLABreachStartDateTime = businessHourService.add(
                        startDateTime,
                        BusinessHourDecorator.FOUR_HOUR_IN_MILLISECONDS
                    );

                    if (System.now() >= initialComplaintSLABreachStartDateTime && caseRecord.StageOneEscalatedDate__c == null) {
                        caseRecord.BreachOf4hrSLA__c = true;
                        caseRecord.Status = CaseDecorator.STATUS_STAGE_ONE;
                        caseRecord.SubStatus__c = CaseDecorator.SUB_STATUS_NEW;
                        caseRecord.SLAStartDate__c = initialComplaintSLABreachStartDateTime;
                        caseRecord.StageOneEscalatedDate__c = initialComplaintSLABreachStartDateTime;
                        caseRecord.EscalatedToStage1By__c = UserInfo.getUserId();
                        caseRecord.Stage1RequestedDate__c = initialComplaintSLABreachStartDateTime;
                        caseRecord.InitialComplaintOutcome__c = CaseDecorator.INITIAL_COMPLAINT_OUTCOME_ESCALATED;
                    } 
                }

                if (caseRecord.Status == CaseDecorator.STATUS_STAGE_ONE && caseRecord.StageOneEscalatedDate__c != null && String.isBlank(caseRecord.AcknowledgementSentFor__c)) {
                    if (caseRecord.StageOneEscalatedDate__c.hour() < 13) {
                        DateTime startDateTime = businessHourService.getNextBusinessDay(caseRecord.StageOneEscalatedDate__c,null);
                        Time businessHourStartTime = businessHourService.getBusinessStartTime(startDateTime.format('EEEE').toLowerCase());
                        caseRecord.SLAStartDate__c = DateTime.newInstance(
                            startDateTime.date(),
                            businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
                        );
                    } else {
                        caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(caseRecord.StageOneEscalatedDate__c,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR);
                    }
                }
                if (oldCasesMap != null && caseRecord.Status == CaseDecorator.STATUS_STAGE_ONE && caseRecord.AcknowledgementSentFor__c == CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_ONE
                    && caseRecord.AcknowledgementSentFor__c != oldCasesMap.get(caseRecord.Id).AcknowledgementSentFor__c) {
                    Datetime startDateTime = businessHourService.getNextBusinessDay(System.now(),null);
                    Time businessHourStartTime = businessHourService.getBusinessStartTime(startDateTime.format('EEEE').toLowerCase());
                    caseRecord.SLAStartDate__c = DateTime.newInstance(
                        startDateTime.date(),
                        businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
                    );
                }
                if (oldCasesMap != null && caseRecord.Status == CaseDecorator.STATUS_STAGE_TWO && caseRecord.StageTwoEscalatedDate__c != null 
                    && caseRecord.AcknowledgementSentFor__c != CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO) {
                    if (caseRecord.StageTwoEscalatedDate__c.hour() < 13) {
                        DateTime startDateTime = businessHourService.getNextBusinessDay(caseRecord.StageTwoEscalatedDate__c,null);
                        Time businessHourStartTime = businessHourService.getBusinessStartTime(startDateTime.format('EEEE').toLowerCase());
                        caseRecord.SLAStartDate__c = DateTime.newInstance(
                            startDateTime.date(),
                            businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
                        );
                    } else {
                        caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(caseRecord.StageTwoEscalatedDate__c,CaseDecorator.COMPLAINTS_CASE_INITIAL_STAGE_SLA_BASELINE_HOUR);
                    }
                }
                if (oldCasesMap != null && caseRecord.Status == CaseDecorator.STATUS_STAGE_TWO && caseRecord.AcknowledgementSentFor__c == CaseDecorator.ACKNOWLEDGEMENT_SENT_FOR_STAGE_TWO
                    && caseRecord.AcknowledgementSentFor__c != oldCasesMap.get(caseRecord.Id).AcknowledgementSentFor__c) {
                    Datetime startDateTime = businessHourService.getNextBusinessDay(System.now(),null);
                    Time businessHourStartTime = businessHourService.getBusinessStartTime(startDateTime.format('EEEE').toLowerCase());
                    caseRecord.SLAStartDate__c = DateTime.newInstance(
                        startDateTime.date(),
                        businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
                    );
                }
                if (oldCasesMap != null && caseRecord.Status == CaseDecorator.STATUS_STAGE_ONE && caseRecord.SubStatus__c == CaseDecorator.SUB_STATUS_ON_HOLD 
                    && caseRecord.SubStatus__c != oldCasesMap.get(caseRecord.Id).SubStatus__c) {
                    Datetime startDateTime = businessHourService.getNextBusinessDay(System.now(),null);
                    caseRecord.OnHoldBreachDateTime__c = DateTime.newInstance(
                        businessHourService.calculateTargetDate(CaseDecorator.COMPLAINTS_CASE_STAGE_ONE_ON_HOLD_MAX_DAYS, startDateTime).date(),
                        System.now().time()
                    );
                } 
                if (oldCasesMap != null && caseRecord.Status == CaseDecorator.STATUS_STAGE_TWO && caseRecord.SubStatus__c == CaseDecorator.SUB_STATUS_ON_HOLD 
                    && caseRecord.SubStatus__c != oldCasesMap.get(caseRecord.Id).SubStatus__c) {
                    Datetime startDateTime = businessHourService.getNextBusinessDay(System.now(),null);
                    caseRecord.OnHoldBreachDateTime__c = DateTime.newInstance(
                        businessHourService.calculateTargetDate(CaseDecorator.COMPLAINTS_CASE_STAGE_TWO_ON_HOLD_MAX_DAYS, startDateTime).date(),
                        System.now().time()
                    );
                } 
                if (oldCasesMap != null && caseRecord.SubStatus__c != CaseDecorator.SUB_STATUS_ON_HOLD && caseRecord.SubStatus__c != oldCasesMap.get(caseRecord.Id).SubStatus__c) {
                    caseRecord.OnHoldBreachDateTime__c = null;
                } 
                if (oldCasesMap != null && caseRecord.Status == CaseDecorator.STATUS_STAGE_OMBUDSMAN && caseRecord.OmbudsmanDeadlineDate__c != null) {
                    caseRecord.SLAStartDate__c = businessHourService.getNextBusinessDay(System.now(),null);
                }
            }
        }
    }
}