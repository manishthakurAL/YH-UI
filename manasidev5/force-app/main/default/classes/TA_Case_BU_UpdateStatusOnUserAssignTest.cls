@isTest
private class TA_Case_BU_UpdateStatusOnUserAssignTest {

    @IsTest
    private static void assigningOwnerFromQueueShouldUpdateStatus() { 
      Id socialQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SocialAffordableRentTerminati__c = socialQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      List <Case> newList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, UserInfo.getUserId())};
      List <Case> oldList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, socialQueueId)};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(CaseDecorator.STATUS_ADMINISTRATION, newList[0].Status,'Status is incorrect');
      System.assertEquals(CaseDecorator.SUB_STATUS_IN_PROGRESS, newList[0].SubStatus__c, 'Sub Status is incorrect');
      System.assertEquals(UserInfo.getUserId(), newList[0].OwnerId, 'Incorrect Owner Id');
    }

    @IsTest
    private static void assigningOwnerFromQueueShouldUpdateSchemesStatus() { 
      Id schemeQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SchemesManager__c = schemeQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      List <Case> newList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, UserInfo.getUserId())};
      List <Case> oldList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, schemeQueueId)};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(CaseDecorator.STATUS_IN_PROGRESS, newList[0].Status,'Status is incorrect');
      System.assertEquals(null, newList[0].SubStatus__c, 'Sub Status is incorrect');
      System.assertEquals(UserInfo.getUserId(), newList[0].OwnerId, 'Incorrect Owner Id');
    }

    @IsTest
    private static void assigningOwnerFromUserToQueueShouldNotUpdateStatus() { 
      Id socialQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SocialAffordableRentTerminati__c = socialQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      List <Case> newList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, socialQueueId)};
      List <Case> oldList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, UserInfo.getUserId())};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(null, newList[0].Status,'Status is incorrect');
      System.assertEquals(null, newList[0].SubStatus__c, 'Sub Status is incorrect');
      System.assertEquals(socialQueueId, newList[0].OwnerId, 'Incorrect Owner Id');
    }

    @IsTest
    private static void assigningOwnerFromQueueIdNotBeingTrackedToUserShouldNotUpdateStatus() { 
      Id socialQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SocialAffordableRentTerminati__c = socialQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      Id someOtherQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      List <Case> newList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, UserInfo.getUserId())};
      List <Case> oldList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, someOtherQueueId)};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(null, newList[0].Status,'Status is incorrect');
      System.assertEquals(null, newList[0].SubStatus__c, 'Sub Status is incorrect');
      System.assertEquals(UserInfo.getUserId(), newList[0].OwnerId, 'Incorrect Owner Id');
    }

    @IsTest
    private static void assigningOwnerFromUserToOtherUserShouldNotUpdateStatus() { 
      Id socialQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SocialAffordableRentTerminati__c = socialQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      Id OtherUserId = TriggerTestUtility.getFakeId(User.SObjectType);
      List <Case> newList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, UserInfo.getUserId())};
      List <Case> oldList = new List <Case>{UthCase.buildFake(caseRecId, contactRecId, OtherUserId)};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(null, newList[0].Status,'Status is incorrect');
      System.assertEquals(null, newList[0].SubStatus__c, 'Sub Status is incorrect');
      System.assertEquals(UserInfo.getUserId(), newList[0].OwnerId, 'Incorrect Owner Id');
    }

    @IsTest
    private static void ownerAssignmentNotApplicableGuestPortal() { 
      Id socialQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SocialAffordableRentTerminati__c = socialQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      Id OtherUserId = TriggerTestUtility.getFakeId(User.SObjectType);
      Case newCaseRec = UthCase.buildFakeCaseWithType(caseRecId, contactRecId, UserInfo.getUserId(), CaseDecorator.TYPE_TERMINATION, CaseDecorator.RECORD_TYPE_ID_TERMINATION);
      newCaseRec.Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL;
      newCaseRec.Tenancy__c = null;
      newCaseRec.Status = CaseDecorator.STATUS_NEW;
      List <Case> newList = new List <Case>{newCaseRec};
      List <Case> oldList = new List <Case>{UthCase.buildFakeCaseWithType(caseRecId, contactRecId, UserInfo.getUserId(), CaseDecorator.TYPE_TERMINATION, CaseDecorator.RECORD_TYPE_ID_TERMINATION)};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(CaseDecorator.STATUS_NEW, newList[0].Status,'Status is incorrect');
      System.assertEquals(UserInfo.getUserId(), newList[0].OwnerId, 'Incorrect Owner Id');
    }

    @IsTest
    private static void ownerAssignmentWithTenancyIdGuestPortal() { 
      YH_Property__c property = UthProperty.buildPropertyWithDesignAssumptions('Leeds',
      PropertyDecorator.HOUSINGPURPOSE_GENERAL_NEEDS, 'E08000035', 
      PropertyDecorator.RENT_TYPE_SOCIAL_RENT,
      PropertyDecorator.PRODUCT_TYPE_LOW_COST_RENTAL);
      insert property;
      TriggerBase.bypass('YH_Tenancy__c');
      YH_Tenancy__c atenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO);
      atenancy.StartDate__c = System.today()-10; 
      insert atenancy;
      TriggerBase.clearBypass('YH_Tenancy__c');
      Id socialQueueId = TriggerTestUtility.getFakeId(Group.SObjectType);
      OrgSetting__c orgSetting = OrgSetting__c.getInstance();
      orgSetting.QueueId_SocialAffordableRentTerminati__c = socialQueueId;
      upsert orgSetting; 

      Id caseRecId = TriggerTestUtility.getFakeId(Case.SObjectType);
      Id contactRecId = TriggerTestUtility.getFakeId(Contact.SObjectType);
      Id OtherUserId = TriggerTestUtility.getFakeId(User.SObjectType);
      Case newCaseRec = UthCase.buildFakeCaseWithType(caseRecId, contactRecId, UserInfo.getUserId(), CaseDecorator.TYPE_TERMINATION, CaseDecorator.RECORD_TYPE_ID_TERMINATION);
      newCaseRec.Origin = CaseDecorator.CASE_ORIGIN_GUEST_PORTAL;
      newCaseRec.Tenancy__c = atenancy.Id;
      newCaseRec.Status = CaseDecorator.STATUS_NEW;
      List <Case> newList = new List <Case>{newCaseRec};
      List <Case> oldList = new List <Case>{UthCase.buildFakeCaseWithType(caseRecId, contactRecId, socialQueueId, CaseDecorator.TYPE_TERMINATION, CaseDecorator.RECORD_TYPE_ID_TERMINATION)};

      Test.startTest();
      new TA_Case_BU_UpdateStatusOnUserAssignment().beforeUpdate(newList, oldList);
      Test.stopTest();

      System.assertEquals(false, newList[0].hasErrors(),'The record should have no errors');
      System.assertEquals(CaseDecorator.STATUS_ADMINISTRATION, newList[0].Status,'Status is incorrect');
      System.assertEquals(UserInfo.getUserId(), newList[0].OwnerId, 'Incorrect Owner Id');
    }
}