@isTest
private class ManageAlertPersonAccountImplTest {

    private static Date getRandomBirthdate(Boolean isMinor) {
        Integer minorMaxAge = 18;
        Integer majorMinAge = 18;
        Integer majorMaxAge = 80; 

        Integer minAge;
        Integer maxAge;

        if (isMinor) {
            minAge = 0;
            maxAge = minorMaxAge - 1;
        } else {
            minAge = majorMinAge;
            maxAge = majorMaxAge;
        }

        Integer minDays = minAge * 365;
        Integer maxDays = maxAge * 365;

        Integer randomDays = Math.mod(Math.abs(Crypto.getRandomInteger()), maxDays);
        Integer finalDays = minDays + randomDays;

        return Date.today().addDays(-finalDays);
    }

    @IsTest
    static void personBirthDateInsertUnder18(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne', getRandomBirthdate(true)));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo',  getRandomBirthdate(true)));

        Test.startTest();
        insert accountList;
        Test.stopTest();

        Contact contactOne;
        Contact contactTwo;

        for(Contact contactRec : UthContact.getAll()){
            if(contactRec.FirstName == 'fNameOne'){
                contactOne = contactRec;
            }else{
                contactTwo = contactRec;
            }
        }

        List<Alert__c> alertList = UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, true);
        System.Assert.areEqual(2, alertList.size());

        for(Alert__c alertRec : alertList){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c);
            System.Assert.areEqual(AlertDecorator.CATEGORY_CUSTOMER, alertRec.Category__c);
            System.Assert.areEqual(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, alertRec.SubCategory__c);
            Contact contactRec;
            if(alertRec.Contact__c == contactOne.Id){
                contactRec = contactOne;
            }else{
                contactRec = contactTwo;
            }                    
            System.Assert.areEqual(contactRec.BirthDate, alertRec.StartDate__c, 'Start date is not set correctly');
            System.Assert.areEqual(contactRec.BirthDate.addYears(18), alertRec.EndDate__c, 'End date is not set correctly');
        }
    }

    @IsTest
    static void personBirthDateInsertNotUnder18(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne', getRandomBirthdate(false)));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo',  getRandomBirthdate(false)));

        Test.startTest();
        insert accountList;
        Test.stopTest();
        List<Alert__c> alertList = UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, true);
        System.Assert.areEqual(0, alertList.size());
    }

    @IsTest
    static void personBirthDateUpdateUnder18(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne', getRandomBirthdate(false)));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo',  getRandomBirthdate(false)));
        insert accountList;

        for(Account accountRec : accountList){
            accountRec.PersonBirthdate = getRandomBirthdate(true);
        }

        Test.startTest();
        update accountList;
        Test.stopTest();

        Contact contactOne;
        Contact contactTwo;

        for(Contact contactRec : UthContact.getAll()){
            if(contactRec.FirstName == 'fNameOne'){
                contactOne = contactRec;
            }else{
                contactTwo = contactRec;
            }
        }

        List<Alert__c> alertList = UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, true);
        System.Assert.areEqual(2, alertList.size());

        for(Alert__c alertRec : alertList){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c);
            System.Assert.areEqual(AlertDecorator.CATEGORY_CUSTOMER, alertRec.Category__c);
            System.Assert.areEqual(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, alertRec.SubCategory__c);
            Contact contactRec;
            if(alertRec.Contact__c == contactOne.Id){
                contactRec = contactOne;
            }else{
                contactRec = contactTwo;
            }                    
            System.Assert.areEqual(contactRec.BirthDate, alertRec.StartDate__c, 'Start date is not set correctly');
            System.Assert.areEqual(contactRec.BirthDate.addYears(18), alertRec.EndDate__c, 'End date is not set correctly');
        }
    }

    @IsTest
    static void personBirthDateUpdateNotUnder18(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne', getRandomBirthdate(true)));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo',  getRandomBirthdate(true)));
        insert accountList;

        for(Account accountRec : accountList){
            accountRec.PersonBirthdate = getRandomBirthdate(false);
        }

        Test.startTest();
        update accountList;
        Test.stopTest();

        System.Assert.areEqual(2, UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, false).size());
        System.Assert.areEqual(0, UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, true).size());
    }

    @IsTest
    static void blankPersonBirthDateInsert(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));

        Test.startTest();
        insert accountList;
        Test.stopTest();
        List<Alert__c> alertList = UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, true);
        System.Assert.areEqual(0, alertList.size());
    }

    @IsTest
    static void disabilityInsert(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccountDisability('fNameOne', 'lNameOne', AccountDecorator.DISABILITY_DEXTERITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameTwo', 'lNameTwo', AccountDecorator.DISABILITY_MOBILITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameThree', 'lNameThree', AccountDecorator.DISABILITY_DEXT_MOB_ISSUES));

        Test.startTest();
        insert accountList;
        Test.stopTest();

        Contact contactOne;
        Contact contactTwo;
        Contact contactThree;

        for(Contact contactRec : UthContact.getAll()){
            if(contactRec.FirstName == 'fNameOne'){
                contactOne = contactRec;
            }else if(contactRec.FirstName == 'fNameTwo'){
                contactTwo = contactRec;
            }else{
                contactThree = contactRec;
            }
        }

        List<Alert__c> alertList = UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true);
        System.Assert.areEqual(4, alertList.size());

        for(Alert__c alertRec : alertList){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c);
            System.Assert.areEqual(AlertDecorator.CATEGORY_DISABILITY, alertRec.Category__c);
            Contact contactRec;
            if(alertRec.Contact__c == contactOne.Id){
                contactRec = contactOne;
            }else if(alertRec.Contact__c == contactTwo.Id){
                contactRec = contactTwo;
            }else{
                contactRec = contactThree;
            }                    
            List<String> disabilityList = contactRec.YH_Disability__c.split(';');
            System.Assert.areEqual(contactRec.Id, alertRec.Contact__C, 'Contact is not set correctly');
            System.Assert.areEqual(System.today(), alertRec.StartDate__c, 'Start date is not set correctly');
            System.Assert.areEqual(null, alertRec.EndDate__c, 'End date should be null');
            System.Assert.isTrue(disabilityList.contains(alertRec.SubCategory__c), 'Sub category is not set correctly');
        }
    }

    @IsTest
    static void disabilityUpdate(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccountDisability('fNameOne', 'lNameOne', AccountDecorator.DISABILITY_DEXTERITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameTwo', 'lNameTwo', AccountDecorator.DISABILITY_MOBILITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameThree', 'lNameThree', AccountDecorator.DISABILITY_DEXT_MOB_ISSUES));
        insert accountList;

        for(Account aRec : accountList){
            if(aRec.FirstName == 'fNameOne'){
                aRec.YH_Disability__pc = AccountDecorator.DISABILITY_MOBILITY_ISSUES;
            }else if(aRec.FirstName == 'fNameTwo'){
                aRec.YH_Disability__pc = AccountDecorator.DISABILITY_DEXT_MOB_ISSUES;
            }else{
                aRec.YH_Disability__pc = AccountDecorator.DISABILITY_HEAR_VIS_ISSUES;
            }
        }

        Test.startTest();
        update accountList;
        Test.stopTest();

        Contact contactOne;
        Contact contactTwo;
        Contact contactThree;

        for(Contact contactRec : UthContact.getAll()){
            if(contactRec.FirstName == 'fNameOne'){
                contactOne = contactRec;
            }else if(contactRec.FirstName == 'fNameTwo'){
                contactTwo = contactRec;
            }else{
                contactThree = contactRec;
            }
        }

        System.Assert.areEqual(3, UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, false).size());
        List<Alert__c> alertList = UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true);
        System.Assert.areEqual(5, alertList.size());

        for(Alert__c alertRec : alertList){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c);
            System.Assert.areEqual(AlertDecorator.CATEGORY_DISABILITY, alertRec.Category__c);
            Contact contactRec;
            if(alertRec.Contact__c == contactOne.Id){
                contactRec = contactOne;
            }else if(alertRec.Contact__c == contactTwo.Id){
                contactRec = contactTwo;
            }else{
                contactRec = contactThree;
            }                    
            List<String> disabilityList = contactRec.YH_Disability__c.split(';');
            System.Assert.areEqual(contactRec.Id, alertRec.Contact__C, 'Contact is not set correctly');
            System.Assert.areEqual(System.today(), alertRec.StartDate__c, 'Start date is not set correctly');
            System.Assert.areEqual(null, alertRec.EndDate__c, 'End date should be null');
            System.Assert.isTrue(disabilityList.contains(alertRec.SubCategory__c), 'Sub category is not set correctly');
        }
    }    

    @IsTest
    static void disabilityRemoval(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccountDisability('fNameOne', 'lNameOne', AccountDecorator.DISABILITY_DEXTERITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameTwo', 'lNameTwo', AccountDecorator.DISABILITY_MOBILITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameThree', 'lNameThree', AccountDecorator.DISABILITY_DEXT_MOB_ISSUES));
        insert accountList;

        for(Account aRec : accountList){
            if(aRec.FirstName == 'fNameOne'){
                aRec.YH_Disability__pc = null;
            }else if(aRec.FirstName == 'fNameTwo'){
                aRec.YH_Disability__pc = null;
            }else{
                aRec.YH_Disability__pc = null;
            }
        }

        Test.startTest();
        update accountList;
        Test.stopTest();

        System.Assert.areEqual(4, UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, false).size());
        System.Assert.areEqual(0, UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true).size());
    }

    @IsTest
    static void blankDisabilityInsert(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));
        insert accountList;

        Test.startTest();
        update accountList;
        Test.stopTest();

        System.Assert.areEqual(0, UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true).size());
    }

    @IsTest
    static void disabilityToIgnoreInsert(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccountDisability('fNameOne', 'lNameOne', AccountDecorator.DISABILITY_PREFER_NOT_TO_SAY));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameTwo', 'lNameTwo', AccountDecorator.DISABILITY_NO_DISABILITY));

        Test.startTest();
        insert accountList;
        Test.stopTest();

        List<Alert__c> alertList = UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true);
        System.Assert.areEqual(0, alertList.size());
    }

    @IsTest
    static void disabilityToIgnoreAndConsiderInsert(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccountDisability('fNameOne', 'lNameOne', AccountDecorator.DISABILITY_DEXTERITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameTwo', 'lNameTwo', AccountDecorator.DISABILITY_MOBILITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameThree', 'lNameThree', AccountDecorator.DISABILITY_IGNORE_AND_CONSIDER_BOTH));

        Test.startTest();
        insert accountList;
        Test.stopTest();

        Contact contactOne;
        Contact contactTwo;
        Contact contactThree;

        for(Contact contactRec : UthContact.getAll()){
            if(contactRec.FirstName == 'fNameOne'){
                contactOne = contactRec;
            }else if(contactRec.FirstName == 'fNameTwo'){
                contactTwo = contactRec;
            }else{
                contactThree = contactRec;
            }
        }

        List<Alert__c> alertList = UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true);
        System.Assert.areEqual(4, alertList.size());

        for(Alert__c alertRec : alertList){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c);
            System.Assert.areEqual(AlertDecorator.CATEGORY_DISABILITY, alertRec.Category__c);
            Contact contactRec;
            if(alertRec.Contact__c == contactOne.Id){
                contactRec = contactOne;
            }else if(alertRec.Contact__c == contactTwo.Id){
                contactRec = contactTwo;
            }else{
                contactRec = contactThree;
            }                    
            List<String> disabilityList = contactRec.YH_Disability__c.split(';');
            System.Assert.areEqual(contactRec.Id, alertRec.Contact__C, 'Contact is not set correctly');
            System.Assert.areEqual(System.today(), alertRec.StartDate__c, 'Start date is not set correctly');
            System.Assert.areEqual(null, alertRec.EndDate__c, 'End date should be null');
            System.Assert.isTrue(disabilityList.contains(alertRec.SubCategory__c), 'Sub category is not set correctly');
        }
    }

    @IsTest
    static void disabilityToIgnoreAndConsiderUpdate(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccountDisability('fNameOne', 'lNameOne', AccountDecorator.DISABILITY_DEXTERITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameTwo', 'lNameTwo', AccountDecorator.DISABILITY_MOBILITY_ISSUES));
        accountList.add(UthAccount.buildPersonAccountDisability('fNameThree', 'lNameThree', AccountDecorator.DISABILITY_DEXT_MOB_ISSUES));
        insert accountList;

        for(Account aRec : accountList){
            if(aRec.FirstName == 'fNameOne'){
                aRec.YH_Disability__pc = AccountDecorator.DISABILITY_NO_DISABILITY;
            }else if(aRec.FirstName == 'fNameTwo'){
                aRec.YH_Disability__pc = AccountDecorator.DISABILITY_IGNORE_AND_CONSIDER_BOTH;
            }else{
                aRec.YH_Disability__pc = AccountDecorator.DISABILITY_HEAR_VIS_ISSUES;
            }
        }

        Test.startTest();
        update accountList;
        Test.stopTest();

        Contact contactOne;
        Contact contactTwo;
        Contact contactThree;

        for(Contact contactRec : UthContact.getAll()){
            if(contactRec.FirstName == 'fNameOne'){
                contactOne = contactRec;
            }else if(contactRec.FirstName == 'fNameTwo'){
                contactTwo = contactRec;
            }else{
                contactThree = contactRec;
            }
        }

        System.Assert.areEqual(3, UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, false).size());
        List<Alert__c> alertList = UthAlert.getAllByCategory(AlertDecorator.CATEGORY_DISABILITY, true);
        System.Assert.areEqual(4, alertList.size());

        for(Alert__c alertRec : alertList){
            System.Assert.areEqual(AlertDecorator.TYPE_PERSON, alertRec.Type__c);
            System.Assert.areEqual(AlertDecorator.CATEGORY_DISABILITY, alertRec.Category__c);
            Contact contactRec;
            if(alertRec.Contact__c == contactOne.Id){
                contactRec = contactOne;
            }else if(alertRec.Contact__c == contactTwo.Id){
                contactRec = contactTwo;
            }else{
                contactRec = contactThree;
            }                    
            List<String> disabilityList = contactRec.YH_Disability__c.split(';');
            System.Assert.areEqual(contactRec.Id, alertRec.Contact__C, 'Contact is not set correctly');
            System.Assert.areEqual(System.today(), alertRec.StartDate__c, 'Start date is not set correctly');
            System.Assert.areEqual(null, alertRec.EndDate__c, 'End date should be null');
            System.Assert.isTrue(disabilityList.contains(alertRec.SubCategory__c), 'Sub category is not set correctly');
        }
    }
    
    @IsTest
    static void personBirthDateUpdateNull(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne', getRandomBirthdate(true)));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo',  getRandomBirthdate(true)));
        insert accountList;

        for(Account accountRec : accountList){
            accountRec.PersonBirthdate = null;
        }
        Map<Id, Alert__c> alertActive = new Map<Id, Alert__c>(UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, true));

        Test.startTest();
        update accountList;
        Test.stopTest();

        List<Alert__c> alertList = UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, false);
        for(Alert__c anAlert: alertList){
            System.Assert.areEqual(Date.today() - 1, anAlert.EndDate__c, 'End date should be one day before today');   
            System.Assert.areEqual(alertActive.get(anAlert.Id).StartDate__c, anAlert.StartDate__c, 'Start  date should not change');    
 
        }
    }

     @IsTest
    static void personBirthDateUpdateNullFromUnder18(){
        List<Account> accountList = new List<Account>();
        accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne', getRandomBirthdate(false)));
        accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo',  getRandomBirthdate(false)));
        insert accountList;

        for(Account accountRec : accountList){
            accountRec.PersonBirthdate = null;
        }
        Map<Id, Alert__c> alertInActive = new Map<Id, Alert__c>(UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, false));

        Test.startTest();
        update accountList;
        Test.stopTest();

        List<Alert__c> alertList = UthAlert.getAllBySubCategory(AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18, false);
        for(Alert__c anAlert: alertList){
            System.Assert.areEqual(alertInActive.get(anAlert.Id).EndDate__c, anAlert.EndDate__c, 'End date should not change');   
            System.Assert.areEqual(alertInActive.get(anAlert.Id).StartDate__c, anAlert.StartDate__c, 'Start  date should not change');    
        }
    }
}