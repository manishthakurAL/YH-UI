@isTest
public with sharing class FindDuplicateSObjectServiceTest {
   @TestSetup
   static void makeData(){
    TriggerBase.bypass('Account');
    insert UthAccount.buildPersonAccount('fname', 'lname', 'you@test.com0', '07654123780', 'Fairfield Road', 'Croydon', 'LE4 7ZF');
    TriggerBase.clearBypass('Account');
   }

   @isTest
   static void findDuplicateTest(){
    Test.startTest();  

    List<Account> accounts = new List<Account>();
    for(Integer i = 0;  i < 2; i++){
        accounts.add(UthAccount.buildPersonAccount('fname', 'lname', 'you@test.com'+i));
    }
    List<List<Sobject>> duplicateResultList = new FindDuplicateSObjectService().findDuplicates(accounts);
    Assert.areEqual(2, duplicateResultList.size(), '2 records should be returned ');
    Assert.areEqual(1, duplicateResultList[0].size(), '1 records should be returned ');
    Assert.areEqual(0, duplicateResultList[1].size(), '0 records should be returned ');
    Test.stopTest();
   }

   @isTest
   static void findDuplicateNegativeTest(){
    Test.startTest();  

    List<Account> accounts = new List<Account>();
    for(Integer i = 0;  i < 2; i++){
        accounts.add(UthAccount.buildPersonAccount('My Name', 'No Duplicate', 'example@test.com'+i));
    }
    List<List<Sobject>> duplicateResultList = new FindDuplicateSObjectService().findDuplicates(accounts);
    Assert.areEqual(0, duplicateResultList[0].size(), '0 records should be returned ');
    Assert.areEqual(0, duplicateResultList[1].size(), '0 records should be returned ');
    Test.stopTest();
   }
}