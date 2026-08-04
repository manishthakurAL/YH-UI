@isTest
public class TA_Tenancy_AU_UpdateOccupanyEndDateTest {

    @TestSetup
    static void makeData(){
        Account personAccount = UthAccount.buildPersonAccount('fNameOne', 'lNameOne');
        insert personAccount;

        Contact ct = UthContact.getAll().get(0);

        YH_Property__c property = UthProperty.buildHousingPurposeProperty(
                PropertyDecorator.AUTHORITY_BARNSLEY,
                PropertyDecorator.AUTHCODE_E08000038,
                null);
        insert property;

        YH_Tenancy__c tenancy = UthTenancy.build(property.Id, true, TenancyDecorator.TENANCY_TYPE_SOLO, System.today());
        insert tenancy;

        Member__c member = UthMember.buildWithNullOccupancyEndDate(ct.Id, tenancy.Id, MemberDecorator.TYPE_SOLO);
        insert member;  
    }
    

    @isTest
    static void test_WhenDeactivateTenancy_WithOccupanyDateNull() {

        Contact ct = UthContact.getAll().get(0);

        YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);

        Test.startTest();

        tenancy.Active__c = false;
        update tenancy;

        Test.stopTest();

        Member__c member = UthMember.getAll().get(0);

        tenancy = UthTenancy.getAll().get(0);

        Assert.areEqual(tenancy.TenancyEndDate__c, member.OccupancyEndDate__c, 'Member Occupany Date Must be same as tenancy end date');

    }

    @isTest
    static void test_WhenDeactivateTenancy_WithOccupanyDateNotNull() {

        Contact ct = UthContact.getAll().get(0);

        YH_Tenancy__c tenancy = UthTenancy.getAll().get(0);

        Member__c member = UthMember.getAll().get(0);

        member.OccupancyEndDate__c = System.today().addDays(-1);
        update member;

        Test.startTest();

        tenancy.Active__c = false;
        update tenancy;

        Test.stopTest();

        member = UthMember.getAll().get(0);

        tenancy = UthTenancy.getAll().get(0);

        Assert.areNotEqual(tenancy.TenancyEndDate__c, member.OccupancyEndDate__c, 'Member Occupany Date should not be same as tenancy end date');

    }
}