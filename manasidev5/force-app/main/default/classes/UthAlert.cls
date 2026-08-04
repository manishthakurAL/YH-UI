@isTest
public class UthAlert {

    public static Alert__c buildPersonAlert(Id personId){
        return new Alert__c(
            Type__c = AlertDecorator.TYPE_PERSON,
            Contact__c = personId,
            Category__c = AlertDecorator.CATEGORY_CUSTOMER,
            SubCategory__c = AlertDecorator.SUB_CATEGORY_VULNERABLE,
            StartDate__c = system.today(),
            Notes__c = 'Test notes'
        );
    }

    public static Alert__c buildPropertyAlert(Id propertyId){
        return new Alert__c(
            Type__c = AlertDecorator.TYPE_PROPERTY,
            Property__c = propertyId,
            StartDate__c = system.today(),
            Notes__c = 'Test notes'
        );
    }

    public static Alert__c buildTenancyAlert(Id tenancyId){
        return new Alert__c(
            Type__c = AlertDecorator.TYPE_TENANCY,
            Tenancy__c = tenancyId,
            StartDate__c = system.today(),
            Notes__c = 'Test notes'
        );
    }

    public static List<Alert__c> getAll(){
        return Database.query('SELECT '+
                String.join(new List<String>(Alert__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Alert__c');
    }

    public static List<Alert__c> getAll( String propertyId){
        return Database.query('SELECT '+
                String.join(new List<String>(Alert__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Alert__c WHERE Property__c = :propertyId Order By CreatedDate DESC');
    }

    public static List<Alert__c> getAllByCategory(String category, Boolean isActive){
        return Database.query('SELECT '+
                String.join(new List<String>(Alert__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Alert__c WHERE Category__c = :category AND IsActive__c = :isActive');
    }

    public static List<Alert__c> getAllBySubCategory(String subCategory, Boolean isActive){
        return Database.query('SELECT '+
                String.join(new List<String>(Alert__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Alert__c WHERE SubCategory__c = :subCategory AND IsActive__c = :isActive');
    }

    public static List<Alert__c> getAll( String propertyId, String category, String subCategory){
        return Database.query('SELECT '+
                String.join(new List<String>(Alert__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Alert__c WHERE Property__c = :propertyId AND Category__c = :category AND SubCategory__c = :subCategory Order By CreatedDate DESC');
    }    

    public static List<Alert__c> getAllByAdvocateId(String advocateId){
        return Database.query('SELECT '+
                String.join(new List<String>(Alert__c.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Alert__c WHERE Advocate__c = :advocateId');
    }
}