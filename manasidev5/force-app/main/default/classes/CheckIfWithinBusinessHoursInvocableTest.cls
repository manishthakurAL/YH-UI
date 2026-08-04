@isTest
public with sharing class CheckIfWithinBusinessHoursInvocableTest {
    @isTest
    static void CheckIfWithinBusinessHoursInvocableTest(){
        List<CheckIfWithinBusinessHoursInvocable.BusinessHourRequest> requests = new List<CheckIfWithinBusinessHoursInvocable.BusinessHourRequest>();
        CheckIfWithinBusinessHoursInvocable.BusinessHourRequest arequest = new CheckIfWithinBusinessHoursInvocable.BusinessHourRequest();
        arequest.startDateTime = Datetime.newInstance(Date.newInstance(01, 12, 2025), Time.newInstance(10, 0, 0, 0));
        requests.add(arequest);
        Test.startTest();
            List<CheckIfWithinBusinessHoursInvocable.BusinessHourResult> results = CheckIfWithinBusinessHoursInvocable.checkIfDateIsWorkingDay(requests);
            Assert.areEqual(results[0].withinBusinessHours, true);
        Test.stopTest();
    }

    @isTest
    static void CheckIfWithinBusinessHoursInvocableNotTest(){
        List<CheckIfWithinBusinessHoursInvocable.BusinessHourRequest> requests = new List<CheckIfWithinBusinessHoursInvocable.BusinessHourRequest>();
        CheckIfWithinBusinessHoursInvocable.BusinessHourRequest arequest = new CheckIfWithinBusinessHoursInvocable.BusinessHourRequest();
        arequest.startDateTime = Datetime.newInstance(Date.newInstance(2025, 9, 14), Time.newInstance(10, 0, 0, 0));
        requests.add(arequest);
        Test.startTest();
            List<CheckIfWithinBusinessHoursInvocable.BusinessHourResult> results = CheckIfWithinBusinessHoursInvocable.checkIfDateIsWorkingDay(requests);
            Assert.areEqual(results[0].withinBusinessHours, false);
        Test.stopTest();
    }
}