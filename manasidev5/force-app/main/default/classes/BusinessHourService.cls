public with sharing class BusinessHourService {

    private String businessHourName;
    public BusinessHours businessHour {
        get {
            if(this.businessHour == null){
                List<BusinessHours> businessHoursList = [
                    SELECT FIELDS(Standard)
                    FROM BusinessHours 
                    WHERE Name =: this.businessHourName
                    LIMIT 1
                ];
                if(!businessHoursList.isEmpty()){
                    this.businessHour = businessHoursList[0];
                }
            }
            return this.businessHour;
        }
        set;
    }

    public BusinessHourService(String businessHourName) {
        this.businessHourName = businessHourName;
    }

    public DateTime getNextBusinessDay(DateTime startDateTime, Integer hourCheck) {
        DateTime nextBusinessHr = startDateTime;
        if (!BusinessHours.isWithin(this.businessHour.Id, startDateTime)) {
            nextBusinessHr = BusinessHours.add(this.businessHour.Id, startDateTime, 1);
        } else if (hourCheck != null && startDateTime.hour() >= hourCheck) {
            Time endTime = getBusinessEndTime(startDateTime.format('EEEE').toLowerCase());
            startDateTime = DateTime.newInstance(startDateTime.date(), endTime);
            nextBusinessHr = BusinessHours.add(this.businessHour.Id, startDateTime, 1);
        }
        // reconstruct to remove extra millisecond
        nextBusinessHr = DateTime.newInstance(nextBusinessHr.year(), nextBusinessHr.month(), nextBusinessHr.day(), nextBusinessHr.hour(), nextBusinessHr.minute(), nextBusinessHr.second());
        return nextBusinessHr;
    }
    
    public DateTime add(DateTime startDateTime, Long timeToAdd) {
        return BusinessHours.add(this.businessHour.Id, startDateTime, timeToAdd);
    }

    public Time getBusinessStartTime(String dayOfTheWeek) {
        Time startTime = null;
        switch on dayOfTheWeek {
            when 'sunday' {     
                startTime = this.businessHour.SundayStartTime;
            }   
            when 'monday' {     
                startTime = this.businessHour.MondayStartTime;
            }   
            when 'tuesday' {        
                startTime = this.businessHour.TuesdayStartTime;
            }   
            when 'wednesday' {      
                startTime = this.businessHour.WednesdayStartTime;
            }   
            when 'thursday' {       
                startTime = this.businessHour.ThursdayStartTime;
            }   
            when 'friday' {     
                startTime = this.businessHour.FridayStartTime;
            }   
            when 'saturday' {       
                startTime = this.businessHour.SaturdayStartTime;
            }   
        }
        return startTime;
    }

    public DateTime calculateTargetDate(Integer daysToAdd, DateTime startDateTime) {
        return addBusinessDays(startDateTime, daysToAdd);
    }

    /**
     * Used only in the test classes
     */
    public DateTime calculatePreviousTargetDate(Integer daysToAdd, DateTime startDateTime) {
        DateTime targetDateTime = startDateTime;
        if (this.businessHour.Id != null) {
            while (daysToAdd < 0) {
                targetDateTime = targetDateTime.addDays(-1);
                Time startTime = getBusinessStartTime(targetDateTime.format('EEEE').toLowerCase());
                if (startTime != null) {
                    targetDateTime = DateTime.newInstance(targetDateTime.date(),startTime);
                    if (BusinessHours.isWithin(this.businessHour.Id, targetDateTime)) {
                        daysToAdd++;
                    }
                }
            }
        }
        return targetDateTime;
    }

    public Time getBusinessEndTime(String dayOfTheWeek) {
        Time startTime = null;
        switch on dayOfTheWeek {
            when 'sunday' {     
                startTime = this.businessHour.SundayEndTime;
            }   
            when 'monday' {     
                startTime = this.businessHour.MondayEndTime;
            }   
            when 'tuesday' {        
                startTime = this.businessHour.TuesdayEndTime;
            }   
            when 'wednesday' {      
                startTime = this.businessHour.WednesdayEndTime;
            }   
            when 'thursday' {       
                startTime = this.businessHour.ThursdayEndTime;
            }   
            when 'friday' {     
                startTime = this.businessHour.FridayEndTime;
            }   
            when 'saturday' {       
                startTime = this.businessHour.SaturdayEndTime;
            }   
        }
        return startTime;
    }


    public Integer getTimeDifferenceInMinutes(DateTime startDateTime, Boolean useStartDateTime) {
        if (this.businessHour != null) {
            switch on startDateTime.format('EEEE').toLowerCase() {
                when 'monday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.MondayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.MondayStartTime)).getTime())/1000)/60);
                }
                when 'tuesday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.TuesdayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.TuesdayStartTime)).getTime())/1000)/60);
                }
                when 'wednesday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.WednesdayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.WednesdayStartTime)).getTime())/1000)/60);
                }
                when 'thursday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.ThursdayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.ThursdayStartTime)).getTime())/1000)/60);
                }
                when 'friday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.FridayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.FridayStartTime)).getTime())/1000)/60);
                }
                when 'saturday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.SaturdayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.SaturdayStartTime)).getTime())/1000)/60);
                }
                when 'sunday' {
                    return Integer.valueOf(((DateTime.newInstance(startDateTime.date(),this.businessHour.SundayEndTime).getTime() - DateTime.newInstance(startDateTime.date(), 
                        (useStartDateTime ? Time.newInstance(startDateTime.hour(),startDateTime.minute(),0,0) : this.businessHour.SundayStartTime)).getTime())/1000)/60);
                }
            }
        }
        return 0;
    }


    /*
    public Integer calculateTargetDateInMinutes(Integer daysToAdd, DateTime startDateTime) {
        Integer totalMinutes = 0;
        Integer counter = 1;
        while (daysToAdd > 0) {
            Time startTime = getBusinessStartTime(startDateTime.addDays(counter).format('EEEE').toLowerCase());
            if (startTime != null) {
                DateTime businessDayStartTime = DateTime.newInstance(startDateTime.addDays(counter).date(), getBusinessStartTime(startDateTime.addDays(counter).format('EEEE').toLowerCase()));
                if (BusinessHours.isWithin(this.businessHour.Id, businessDayStartTime)) {
                    daysToAdd -= 1;
                    totalMinutes += getTimeDifferenceInMinutes(
                        businessDayStartTime,
                        false
                    );
                }
            }
            counter++;
        }
        return totalMinutes;
    }*/

    /**
     * since this method is used in the test class, this can't commented out easily
     */
    public Integer calculateBusinessDays(DateTime targetDateTime) {
        Integer noOfBusinessDays = 1;
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        Datetime nextBusinessDayDateTime = businessHourService.getNextBusinessDay(System.now(),null);
        Time businessHourStartTime = businessHourService.getBusinessStartTime(System.now().format('EEEE').toLowerCase()); 
        DateTime startDateTime = DateTime.newInstance(
            nextBusinessDayDateTime.date(),
            businessHourStartTime != null ? businessHourStartTime : Time.newInstance(9,0,0,0)
        );   
        if (this.businessHour.Id != null) {
            while (startDateTime.date() < targetDateTime.date()) {
                startDateTime = startDateTime.addDays(1);
                if (startDateTime.date() <= targetDateTime.date()) {
                    Time startTime = getBusinessStartTime(startDateTime.format('EEEE').toLowerCase());
                    if (startTime != null) {
                        startDateTime = DateTime.newInstance(startDateTime.date(),startTime);
                        if (BusinessHours.isWithin(this.businessHour.Id, startDateTime)) {
                            noOfBusinessDays++;
                        }
                    }
                }
            }
        }
        return noOfBusinessDays;
    }

    public Boolean isBusinessDay(Date dateToCheck) {
        BusinessHourService businessHourService = new BusinessHourService(BusinessHourDecorator.DEFAULT_BUSINESS_HOUR);
        return BusinessHours.isWithin(businessHourService.businessHour.Id, DateTime.newInstance(dateToCheck, Time.newInstance(12,0,0,000)));
    }

    public Boolean isBusinessDay(Datetime datetimeToCheck) {
        return BusinessHours.isWithin(this.businessHour.Id, datetimeToCheck);
    }

    public Boolean isOutsideBusinessHourTime(DateTime startDateTime) {
        if (this.businessHour != null) {
            switch on startDateTime.format('EEEE').toLowerCase() {
                when 'monday' {
                    return startDateTime.time() <= this.businessHour.MondayStartTime || startDateTime.time() >= this.businessHour.MondayEndTime;
                }
                when 'tuesday' {
                    return startDateTime.time() <= this.businessHour.TuesdayStartTime || startDateTime.time() >= this.businessHour.TuesdayEndTime;
                }
                when 'wednesday' {
                    return startDateTime.time() <= this.businessHour.WednesdayStartTime || startDateTime.time() >= this.businessHour.WednesdayEndTime;
                }
                when 'thursday' {
                    return startDateTime.time() <= this.businessHour.ThursdayStartTime || startDateTime.time() >= this.businessHour.ThursdayEndTime;
                }
                when 'friday' {
                    return startDateTime.time() <= this.businessHour.FridayStartTime || startDateTime.time() >= this.businessHour.FridayEndTime;
                }
                when 'saturday' {
                    return startDateTime.time() <= this.businessHour.SaturdayStartTime || startDateTime.time() >= this.businessHour.SaturdayEndTime;
                }
                when 'sunday' {
                    return startDateTime.time() <= this.businessHour.SundayStartTime || startDateTime.time() >= this.businessHour.SundayEndTime;
                }
            }
        }
        return false;
    }

    public Integer getMinutesBetween( DateTime startDateTime, DateTime targetDateTime) {
        Decimal remainingTime = (BusinessHours.diff(businessHour.Id, startDateTime, targetDateTime)/ 60000.00).round(System.RoundingMode.UP);
        return remainingTime.intValue();
    }

    public DateTime addBusinessDays( DateTime startDate, Integer noOfDays) {
        Long daysInMillisecond = (Long) noOfDays * (Long) 28800000;
        DateTime targetDateTime = BusinessHours.add(businessHour.Id, startDate, daysInMillisecond); 
        // YH specific logic to mark target date as end of business hour of that day.
        Time targetDateDayEndTime = getBusinessEndTime(targetDateTime.format('EEEE').toLowerCase());
        return DateTime.newInstance(targetDateTime.date(), targetDateDayEndTime);
    }
}