@isTest
public with sharing class AlertControllerTest {
    @isTest
    static void testFindDuplicates() {
        System.assertEquals(false, AlertController.getAllConfigs().isEmpty(), 'Configs should not be empty');
    }   
}