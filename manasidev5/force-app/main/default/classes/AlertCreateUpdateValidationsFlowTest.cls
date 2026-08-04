@isTest
public with sharing class AlertCreateUpdateValidationsFlowTest {

    @isTest
    static void alertRestricted(){
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        System.runAs(new User(Id = currentUserId)) {
            List<Alert__c> alertList = new List<Alert__c>();
            for(Integer i=0; i<300; i++){
                alertList.add(
                    new Alert__c(
                        Type__c = AlertDecorator.TYPE_PERSON,
                        StartDate__c = System.Today(),
                        Category__c = AlertDecorator.CATEGORY_CUSTOMER,
                        SubCategory__c = AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18
                    )
                );
            }
            String expectedMsg = 'You do not have permission to add this alert.';
            String actualMsg = '';
            Test.startTest();
            try{
                upsert alertList;
            }catch(DmlException e){
                actualMsg = e.getMessage();
            }
            Test.stopTest();

            System.Assert.isTrue(actualMsg.contains(expectedMsg), 'Exception message is not as expected');
        }
    }

    @isTest
    static void alertAllowed(){
        Id currentUserId = UthUser.createNonAdminUser(UserDecorator.ROLE_CUSTOMER_EXPERIENCE_MANAGER, UserDecorator.PROFILE_CUSTOMER_SUCCESS);
        
        System.runAs(new User(Id = currentUserId)) {
            List<Alert__c> alertList = new List<Alert__c>();
            for(Integer i=0; i<500; i++){
                alertList.add(
                    new Alert__c(
                        Type__c = AlertDecorator.TYPE_PERSON,
                        StartDate__c = System.Today(),
                        Category__c = AlertDecorator.CATEGORY_CUSTOMER,
                        SubCategory__c = AlertDecorator.SUB_CATEGORY_PERSON_UNDER_18
                    )
                );
            }
            Test.startTest();
            BypassFlowHandler.bypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
            insert alertList;
            BypassFlowHandler.clearBypassFlow(AlertDecorator.BTF_ALERT_CREATE_UPDATE_VALIDATION_FLOW_NAME);
            Test.stopTest();

            System.Assert.isTrue(alertList.size() == 500, 'Alerts should have created');
        }
    }


}