@isTest(seeAllData=false)
public with sharing class BusinessHourInvocableTest {
    
    @isTest
    static void testAddBusinessDaysBeforeOnePMWithHourCheck(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        BusinessHourInvocable.BusinessHourRequest businessHourRequest = new BusinessHourInvocable.BusinessHourRequest();
        businessHourRequest.startDateTime = DateTime.newInstanceGMT(Date.newInstance(2024,02,29),Time.newInstance(9,0,0,0));
        businessHourRequest.numberOfDaysToAdd = 5;
        businessHourRequest.hourToCheck = 13;
        List<BusinessHourInvocable.BusinessHourResult> businessHourResultsList = BusinessHourInvocable.addBusinessDays(new List<BusinessHourInvocable.BusinessHourRequest>{businessHourRequest});
        Test.stopTest();      
        Date expectedDate = Date.newInstance(2024,03,06);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstanceGMT(expectedDate,expectedTime);  
        Assert.areEqual(expectedDateTime,businessHourResultsList[0].targetDateTime,'It should be 06/03/2024T09:00:00Z');
    }

    @isTest
    static void testAddBusinessDaysAfterOnePMWithHourCheck(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        BusinessHourInvocable.BusinessHourRequest businessHourRequest = new BusinessHourInvocable.BusinessHourRequest();
        businessHourRequest.startDateTime = DateTime.newInstanceGMT(Date.newInstance(2024,02,29),Time.newInstance(14,0,0,0));
        businessHourRequest.numberOfDaysToAdd = 5;
        businessHourRequest.hourToCheck = 13;
        List<BusinessHourInvocable.BusinessHourResult> businessHourResultsList = BusinessHourInvocable.addBusinessDays(new List<BusinessHourInvocable.BusinessHourRequest>{businessHourRequest});
        Test.stopTest();      
        Date expectedDate = Date.newInstance(2024,03,07);
        Time expectedTime = businessHourService.businessHour.ThursdayEndTime;
        DateTime expectedDateTime = DateTime.newInstanceGMT(expectedDate,expectedTime);  
        Assert.areEqual(expectedDateTime,businessHourResultsList[0].targetDateTime,'It should be 07/03/2024T09:00:00Z');
    }

    @isTest
    static void testAddBusinessDaysAtOnePMWithHourCheck(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        BusinessHourInvocable.BusinessHourRequest businessHourRequest = new BusinessHourInvocable.BusinessHourRequest();
        businessHourRequest.startDateTime = DateTime.newInstanceGMT(Date.newInstance(2024,02,29),Time.newInstance(13,0,0,0));
        businessHourRequest.numberOfDaysToAdd = 5;
        businessHourRequest.hourToCheck = 13;
        List<BusinessHourInvocable.BusinessHourResult> businessHourResultsList = BusinessHourInvocable.addBusinessDays(new List<BusinessHourInvocable.BusinessHourRequest>{businessHourRequest});
        Test.stopTest();      
        Date expectedDate = Date.newInstance(2024,03,07);
        Time expectedTime = businessHourService.businessHour.ThursdayEndTime;
        DateTime expectedDateTime = DateTime.newInstanceGMT(expectedDate,expectedTime);  
        Assert.areEqual(expectedDateTime,businessHourResultsList[0].targetDateTime,'It should be 07/03/2024T09:00:00Z');
    }

    @isTest
    static void testAddBusinessDaysBeforeOnePMWithoutHourCheck(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        BusinessHourInvocable.BusinessHourRequest businessHourRequest = new BusinessHourInvocable.BusinessHourRequest();
        businessHourRequest.startDateTime = DateTime.newInstanceGMT(Date.newInstance(2024,02,29),Time.newInstance(9,0,0,0));
        businessHourRequest.numberOfDaysToAdd = 5;
        businessHourRequest.hourToCheck = null;
        List<BusinessHourInvocable.BusinessHourResult> businessHourResultsList = BusinessHourInvocable.addBusinessDays(new List<BusinessHourInvocable.BusinessHourRequest>{businessHourRequest});
        Test.stopTest();      
        Date expectedDate = Date.newInstance(2024,03,06);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstanceGMT(expectedDate,expectedTime);  
        Assert.areEqual(expectedDateTime,businessHourResultsList[0].targetDateTime,'It should be 06/03/2024T09:00:00Z');
    }

    @isTest
    static void testAddBusinessDaysAfterOnePMWithoutHourCheck(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        BusinessHourInvocable.BusinessHourRequest businessHourRequest = new BusinessHourInvocable.BusinessHourRequest();
        businessHourRequest.startDateTime = DateTime.newInstanceGMT(Date.newInstance(2024,02,29),Time.newInstance(14,0,0,0));
        businessHourRequest.numberOfDaysToAdd = 5;
        businessHourRequest.hourToCheck = null;
        List<BusinessHourInvocable.BusinessHourResult> businessHourResultsList = BusinessHourInvocable.addBusinessDays(new List<BusinessHourInvocable.BusinessHourRequest>{businessHourRequest});
        Test.stopTest();      
        Date expectedDate = Date.newInstance(2024,03,07);
        Time expectedTime = businessHourService.businessHour.ThursdayEndTime;
        DateTime expectedDateTime = DateTime.newInstanceGMT(expectedDate,expectedTime);  
        Assert.areEqual(expectedDateTime,businessHourResultsList[0].targetDateTime,'It should be 07/03/2024T09:00:00Z');
    }

    @isTest
    static void testAddBusinessDaysAtOnePMWithoutHourCheck(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        BusinessHourInvocable.BusinessHourRequest businessHourRequest = new BusinessHourInvocable.BusinessHourRequest();
        businessHourRequest.startDateTime = DateTime.newInstanceGMT(Date.newInstance(2024,02,29),Time.newInstance(13,0,0,0));
        businessHourRequest.numberOfDaysToAdd = 5;
        businessHourRequest.hourToCheck = null;
        List<BusinessHourInvocable.BusinessHourResult> businessHourResultsList = BusinessHourInvocable.addBusinessDays(new List<BusinessHourInvocable.BusinessHourRequest>{businessHourRequest});
        Test.stopTest();      
        Date expectedDate = Date.newInstance(2024,03,07);
        Time expectedTime = businessHourService.businessHour.ThursdayEndTime;
        DateTime expectedDateTime = DateTime.newInstanceGMT(expectedDate,expectedTime);  
        Assert.areEqual(expectedDateTime,businessHourResultsList[0].targetDateTime,'It should be 07/03/2024T09:00:00Z');
    }
}