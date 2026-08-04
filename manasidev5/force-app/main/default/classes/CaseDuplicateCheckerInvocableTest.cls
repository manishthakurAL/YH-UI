@isTest(seeAllData=false)
    public with sharing class CaseDuplicateCheckerInvocableTest {
        @testSetup
            static void setUpTestData(){
                UthFeatureSwitches.enableAllRT();
    
                TriggerBase.bypass('Account');
                List<Account> accountList = new List<Account>();
                accountList.add(UthAccount.buildPersonAccount('fNameOne', 'lNameOne'));
                accountList.add(UthAccount.buildPersonAccount('fNameTwo', 'lNameTwo'));
                accountList.add(UthAccount.buildPersonAccount('fNameThree', 'lNameThree'));
                accountList.add(UthAccount.buildPersonAccount('fNameFour', 'lNameFour'));
                insert accountList;
    
                Contact contactOne;
                Contact contactTwo;
                Contact contactThree;
                
                for(Contact contact : UthContact.getAll()){
                    if(contact.LastName == 'lNameOne'){
                        contactOne = contact;
                    } else if(contact.LastName == 'lNameTwo'){
                        contactTwo = contact;
                    } else if(contact.LastName == 'lNameThree'){
                        contactThree = contact;
                    }
                }
                
                YH_Property__c property = uthProperty.buildPropertyWithDesignAssumptions(
                    PropertyDecorator.AUTHORITY_BARNSLEY,
                    PropertyDecorator.HOUSINGPURPOSE_HOUSING_FOR_OLD_PEOPLE,
                    PropertyDecorator.AUTHCODE_E08000038,
                    PropertyDecorator.RENT_TYPE_INTERMEDIATE_RENT,
                    PropertyDecorator.PRODUCT_TYPE_EXTRA_CARE
                    );
                insert property;
    
                List<YH_Tenancy__c> tenancyList = new List<YH_Tenancy__c>();
                tenancyList.add(UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_JOINT));
                tenancyList.add(UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO));
                insert tenancyList;
    
                YH_Tenancy__c tenancyJoint;
                YH_Tenancy__c tenancySolo;
    
                for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                    if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                        tenancyJoint = tenancy;
                    }else if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_SOLO){
                        tenancySolo = tenancy;
                    }
                }
    
                List<Member__c> memberList = new List<Member__c>();
                memberList.add(UthMember.build(contactOne.Id, tenancyJoint.Id, MemberDecorator.TYPE_JOINT));
                memberList.add(UthMember.build(contactTwo.Id, tenancyJoint.Id, MemberDecorator.TYPE_JOINT));
                memberList.add(UthMember.build(contactThree.Id, tenancySolo.Id, MemberDecorator.TYPE_SOLO));
                insert memberList;
    
                TriggerBase.clearBypass('Account');
            }
    
            @isTest
            static void testMoneyCoachingCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getMoneyCoachingUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = caseRecord = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = caseRecord = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testMoneyCoachingCaseWithMultipeCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
    
                Contact contactFive;
                Contact contactSix;
                List<Case> additionalCaseToInsert = new List<Case>();
                Case caseRecord1;
                Case caseRecord2;
                Case caseRecord3;
                Case caseRecord4;
                
                System.runAs(UthUser.getMoneyCoachingUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = caseRecord = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                    insert caseRecord;
    
                    TriggerBase.bypass('Account');
                    TriggerBase.bypass('Case');
                    List<Account> accountList = new List<Account>();
                    accountList.add(UthAccount.buildPersonAccount('fNameFive', 'lNameFive'));
                    accountList.add(UthAccount.buildPersonAccount('fNameSix', 'lNameSix'));
                    insert accountList;
    
                    
                    
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameFive'){
                            contactFive = contact;
                        } else if(contact.LastName == 'lNameSix'){
                            contactSix = contact;
                        }
                    }
    
                    caseRecord1 = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactFive.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                    insert caseRecord1;
    
                    caseRecord2 = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactFive.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                    insert caseRecord2;
    
                    caseRecord3 = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactSix.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                    insert caseRecord3;
    
                    caseRecord4 = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactSix.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                    insert caseRecord4;
    
                    TriggerBase.clearBypass('Account');
                    TriggerBase.clearBypass('Case');
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = caseRecord = UthCase.buildMoneyCoachingCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_MONEY_COACHING);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest, caseRecord1, caseRecord4});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(3, results.size(), 'Result size should be 1');    	}
    
            @isTest
            static void testSchemeMonitoringFormCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getSchemeUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildSchemesCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_MONITORING_FORM);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildSchemesCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_MONITORING_FORM);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testSchemeIndependencePlanCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getSchemeUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildSchemesCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_INDEPENDENCE_PLAN);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildSchemesCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_INDEPENDENCE_PLAN);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testTenancyRightToRentCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.setTenancyUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildTenancyCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_RIGHT_To_RENT);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildTenancyCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_RIGHT_To_RENT);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(false, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be false');
                Assert.areEqual(null, results[0].duplicateExist, 'Duplicate exist should be null');
                Assert.areEqual(null, results[0].cases, 'Duplicate case list should be null');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testTenancyAbandonedGoodsCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.setTenancyUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildTenancyCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_ABANDONED_GOODS);
                    CaseRecord.Property__c = uthproperty.getall()[0].id;
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildTenancyCaseWithTenancyAndReporterAndType(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.TYPE_ABANDONED_GOODS);
                     		caseRecordForTest.Property__c = uthproperty.getall()[0].id;    
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testPlaceLandDisputesCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPlaceUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_LAND_DISPUTES);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_LAND_DISPUTES);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testAbandonedVehiclesCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPlaceUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildPlaceWithCaseTypeTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_ABANDONED_VEHICLES);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testPermissionForaLodgerOrSubletCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest =UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_A_LoDGER_OR_SUBLET);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testPermissionForCaravanMotorhomeBoatCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_CARAVAN_MOTORHOME_BOAT);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_CARAVAN_MOTORHOME_BOAT);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testPermissionForMobilityScooterCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_MOBILITY_SCOOTER);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_MOBILITY_SCOOTER);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testPermissionForPetAnimalCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_PET_ANIMAL);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_FOR_PET_ANIMAL);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testPermissionToRunaBusinessFromHomeCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.getPermissionUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_TO_RUN_A_BUSINESS_FROM_HOME);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildPermissionCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_PERMISSION_TO_RUN_A_BUSINESS_FROM_HOME);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testChangeJointToSole(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildJointToSoleCaseWithTenancyandReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildJointToSoleCaseWithTenancyandReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void testChangeSoleTojoint(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(UthUser.setChangeUser(UserInfo.getUserId())) {
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_SOLO){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildChangesCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_SOLE_TO_JOINT);
                    insert caseRecord;
                    
                    Test.startTest();
                        try {
                            caseRecordForTest = UthCase.buildChangesCaseWithTypeAndTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id, CaseDecorator.CASE_TYPE_SOLE_TO_JOINT);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                                actualErrorMessage = exp.getMessage();
                        }
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    
            @isTest
            static void test_SafeguardingGenericCase(){
                String actualErrorMessage;
                Contact contactOne;
                Contact contactTwo;
                YH_Tenancy__c tenancyJoint;
                Case caseRecord;
                Case caseRecordForTest;
                List<CaseDuplicateCheckerInvocable.CaseDuplicateCheckerInvocableResult> results;
                
                System.runAs(new User(Id = UserInfo.getUserId())){
                    Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_SAFEGUARDING_OFFICER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
                    Id permissionSetId = UthPermissionSet.getByName(UthPermissionSet.PROFILE_PS_CAN_UPDATE_SAFEGUARDING_CASE).Id;
                    PermissionSetAssignment permissionSetAssignment = UthPermissionSet.getPermissionSetAssignment(currentUserId, permissionSetId);
                    if (permissionSetAssignment == null) {
                        UthPermissionSet.setPermissionSet(currentUserId, permissionSetId);
                    }
    
                    for(Contact contact : UthContact.getAll()){
                        if(contact.LastName == 'lNameOne'){
                            contactOne = contact;
                        } else if(contact.LastName == 'lNameTwo'){
                            contactTwo = contact;
                        } 
                    }
    
                    for(YH_Tenancy__c tenancy : UthTenancy.getAll()){
                        if(tenancy.YH_TenancyType__c == TenancyDecorator.TENANCY_TYPE_JOINT){
                            tenancyJoint = tenancy;
                        }
                    }
                    
                    caseRecord = UthCase.buildSafeguardingCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                    insert caseRecord;
    
                    TriggerBase.bypass('Case');
                    UthCase.createCaseShareRecords(caseRecord.Id,  currentUserId, 'Edit','Manual');
                    TriggerBase.clearBypass('Case'); 
                    
                    Test.startTest();
                    System.runAs(new User(Id = currentUserId)) {
    
                        try {
                            caseRecordForTest = UthCase.buildSafeguardingCaseWithTenancyAndReporter(contactOne.Id, tenancyJoint.Id, contactTwo.Id);
                            
                            results = CaseDuplicateCheckerInvocable.getDuplicateCases(new List<Case>{caseRecordForTest});
                        } 
                        catch(Exception exp) {
                            actualErrorMessage = exp.getMessage();
                        }
                    } 
                    Test.stopTest();
                }
    
                Assert.areEqual(1, results.size(), 'Result size should be 1');
                Assert.areEqual(true, results[0].isDuplicateCheckRequired, 'Duplicate chek required should be true');
                Assert.areEqual(true, results[0].duplicateExist, 'Duplicate exist should be true');
                Assert.areEqual(1, results[0].cases.size(), 'Duplicate case list size should be 1');
                Assert.areEqual(null, results[0].errorMessage, 'Error message should be null');
            }
    }