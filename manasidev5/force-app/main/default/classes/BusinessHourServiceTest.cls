@isTest(seeAllData=false)
public with sharing class BusinessHourServiceTest {
    
    @isTest
    static void testBusinessHourServiceForFriday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,23),Time.newInstance(14,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,26);
        Time expectedTime = businessHourService.businessHour.MondayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day (monday) and monday start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForSaturday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,24),Time.newInstance(14,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,26);
        Time expectedTime = businessHourService.businessHour.MondayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day (monday) and monday start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForSunday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,25),Time.newInstance(14,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,26);
        Time expectedTime = businessHourService.businessHour.MondayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day (monday) and monday start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForWeekDay(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(14,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForWeekDayBeforeOnePM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(9,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = Time.newInstance(9,0,0,0);
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same business day and current time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForWeekDayAtOnePM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(13,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForWeekDayAfterOnePM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(14,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourStartTime(){     
        BusinessHourService businessHourService = new BusinessHourService('');
        Test.startTest();        
        Assert.areEqual(businessHourService.businessHour.SundayStartTime,businessHourService.getBusinessStartTime('sunday'),'It should be sunday start time');
        Assert.areEqual(businessHourService.businessHour.MondayStartTime,businessHourService.getBusinessStartTime('monday'),'It should be monday start time');
        Assert.areEqual(businessHourService.businessHour.TuesdayStartTime,businessHourService.getBusinessStartTime('tuesday'),'It should be tuesday start time');
        Assert.areEqual(businessHourService.businessHour.WednesdayStartTime,businessHourService.getBusinessStartTime('wednesday'),'It should be wednesday start time');
        Assert.areEqual(businessHourService.businessHour.ThursdayStartTime,businessHourService.getBusinessStartTime('thursday'),'It should be thursday start time');
        Assert.areEqual(businessHourService.businessHour.FridayStartTime,businessHourService.getBusinessStartTime('friday'),'It should be friday start time');
        Assert.areEqual(businessHourService.businessHour.SaturdayStartTime,businessHourService.getBusinessStartTime('saturday'),'It should be saturday start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForHoliday(){      
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,29),Time.newInstance(12,0,0,0));
        Date expectedDate = Date.newInstance(2024,04,02);
        Time expectedTime = businessHourService.businessHour.TuesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day (tuesday) and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForBeforeBusinessHourStartTime(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(5,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceForAfterBusinessHourEndTime(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(21,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testCalculateTargetDateWithStartDateAsAWeekDay(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(21,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,28);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculateTargetDate(5,startDateTime),'It should be 28/02/2024');
        Test.stopTest();        
    }

    @isTest
    static void testCalculateTargetDateWithStartDateAsFriday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,23),Time.newInstance(21,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,28);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculateTargetDate(3,startDateTime),'It should be 28/02/2024');
        Test.stopTest();        
    }

    @isTest
    static void testCalculateTargetDateWithStartDateAsSaturday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,24),Time.newInstance(21,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,28);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculateTargetDate(3,startDateTime),'It should be 28/02/2024');
        Test.stopTest();        
    }

    @isTest
    static void testCalculateTargetDateWithStartDateAsSunday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,25),Time.newInstance(21,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,28);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculateTargetDate(3,startDateTime),'It should be 28/02/2024');
        Test.stopTest();        
    }

    @isTest
    static void testCalculateTargetDateWithStartDateOnAHoliday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,03,29),Time.newInstance(9,0,0,0));
        Date expectedDate = Date.newInstance(2024,04,03);
        Time expectedTime = businessHourService.businessHour.WednesdayEndTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculateTargetDate(2,startDateTime),'It should be 03/04/2024');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt12AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(0,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt1AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(1,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt2AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(2,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt3AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(3,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt4AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(4,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt5AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(5,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt6AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(6,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt7AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(7,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt8AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(8,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt9AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(9,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = businessHourService.businessHour.WednesdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt10AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(10,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = Time.newInstance(10,0,0,0);
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and time should be 10 am');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt11AM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(11,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = Time.newInstance(11,0,0,0);
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be same day and time should be 11 am');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt12PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(12,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = Time.newInstance(12,0,0,0);
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime.millisecond(),businessHourService.getNextBusinessDay(startDateTime,13).millisecond(),'It should be same day and time should be 12 pm');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt1230PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(12,30,0,0));
        Date expectedDate = Date.newInstance(2024,02,21);
        Time expectedTime = Time.newInstance(12,30,0,0);
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime.millisecond(),businessHourService.getNextBusinessDay(startDateTime,13).millisecond(),'It should be same day and time should be 12:30 pm');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt1PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(13,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt2PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(14,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt3PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(15,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt4PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(16,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt5PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(17,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt6PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(18,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt7PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(19,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt8PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(20,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt9PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(21,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt10PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(22,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourServiceAt11PM(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(23,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,22);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.getNextBusinessDay(startDateTime,13),'It should be next business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourEndTime(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();        
        Assert.areEqual(businessHourService.businessHour.SundayEndTime,businessHourService.getBusinessEndTime('sunday'),'It should be sunday end time');
        Assert.areEqual(businessHourService.businessHour.MondayEndTime,businessHourService.getBusinessEndTime('monday'),'It should be monday end time');
        Assert.areEqual(businessHourService.businessHour.TuesdayEndTime,businessHourService.getBusinessEndTime('tuesday'),'It should be tuesday end time');
        Assert.areEqual(businessHourService.businessHour.WednesdayEndTime,businessHourService.getBusinessEndTime('wednesday'),'It should be wednesday end time');
        Assert.areEqual(businessHourService.businessHour.ThursdayEndTime,businessHourService.getBusinessEndTime('thursday'),'It should be thursday end time');
        Assert.areEqual(businessHourService.businessHour.FridayEndTime,businessHourService.getBusinessEndTime('friday'),'It should be friday end time');
        Assert.areEqual(businessHourService.businessHour.SaturdayEndTime,businessHourService.getBusinessEndTime('saturday'),'It should be saturday end time');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourTimeDifferenceInMinutes(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();        
        Assert.areEqual(420,businessHourService.getTimeDifferenceInMinutes(DateTime.newInstance(2024,03,04,10,0,0),true),'It should be 420');
        Assert.areEqual(375,businessHourService.getTimeDifferenceInMinutes(DateTime.newInstance(2024,03,05,10,45,0),true),'It should be 375');
        Assert.areEqual(334,businessHourService.getTimeDifferenceInMinutes(DateTime.newInstance(2024,03,06,11,26,0),true),'It should be 334');
        Assert.areEqual(133,businessHourService.getTimeDifferenceInMinutes(DateTime.newInstance(2024,03,07,14,47,0),true),'It should be 133');
        Assert.areEqual(48,businessHourService.getTimeDifferenceInMinutes(DateTime.newInstance(2024,03,08,16,12,0),true),'It should be 48');
        Test.stopTest();        
    }

    @isTest
    static void testBusinessHourisOutsideBusinessHourTime(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();        
        Assert.areEqual(true,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,04,7,0,0)),'It should be true');
        Assert.areEqual(false,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,05,10,45,0)),'It should be false');
        Assert.areEqual(true,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,06,2,26,0)),'It should be true');
        Assert.areEqual(true,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,07,4,47,0)),'It should be true');
        Assert.areEqual(false,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,08,15,12,0)),'It should be false');
        Assert.areEqual(true,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,08,19,12,0)),'It should be true');
        Assert.areEqual(true,businessHourService.isOutsideBusinessHourTime(DateTime.newInstance(2024,03,08,19,12,0)),'It should be true');
        Test.stopTest();        
    }

    @isTest
    static void testCalculatePreviousTargetDateOnAWeekday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,21),Time.newInstance(23,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,20);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculatePreviousTargetDate(-1,startDateTime),'It should be previous business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testCalculatePreviousTargetDateOnAWeekend(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,02,19),Time.newInstance(20,0,0,0));
        Date expectedDate = Date.newInstance(2024,02,16);
        Time expectedTime = businessHourService.businessHour.FridayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculatePreviousTargetDate(-1,startDateTime),'It should be previous business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testCalculatePreviousTargetDateOnABankHoliday(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Test.startTest();  
        DateTime startDateTime = DateTime.newInstance(Date.newInstance(2024,04,03),Time.newInstance(15,0,0,0));
        Date expectedDate = Date.newInstance(2024,03,28);
        Time expectedTime = businessHourService.businessHour.ThursdayStartTime;
        DateTime expectedDateTime = DateTime.newInstance(expectedDate,expectedTime);
        Assert.areEqual(expectedDateTime,businessHourService.calculatePreviousTargetDate(-2,startDateTime),'It should be previous business day and its start time');
        Test.stopTest();        
    }

    @isTest
    static void testcalculateBusinessDaysFor5Days(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
        Time businessHourStartTime = businessHourService.getBusinessStartTime(System.now().format('EEEE').toLowerCase()); 
        DateTime startDateTime = DateTime.newInstance(
            nextBusinessDayDateTime.date(),
            businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
        );   
        Test.startTest();  
        DateTime targetDateTime = businessHourService.calculateTargetDate(5,startDateTime);
        Assert.areEqual(5,businessHourService.calculateBusinessDays(targetDateTime),'It should be 5 days');
        Test.stopTest();        
    }

    @isTest
    static void testcalculateBusinessDaysFor10Days(){     
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
        Time businessHourStartTime = businessHourService.getBusinessStartTime(System.now().format('EEEE').toLowerCase()); 
        DateTime startDateTime = DateTime.newInstance(
            nextBusinessDayDateTime.date(),
            businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
        );  
        Test.startTest();  
        DateTime targetDateTime = businessHourService.calculateTargetDate(10,startDateTime);
        Assert.areEqual(10,businessHourService.calculateBusinessDays(targetDateTime),'It should be 10 days');
        Test.stopTest();        
    }
}