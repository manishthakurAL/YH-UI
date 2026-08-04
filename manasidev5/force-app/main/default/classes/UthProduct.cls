@isTest
public with sharing class UthProduct {
    public static  Product2 create () {
        Product2 product = new Product2(
            Name = 'Test Widget',
            ProductCode = 'TW-001',
            IsActive = true
        );
        insert product;
        return product;
    }

    public static List<Product2> getAll(){
        return Database.query('SELECT '+
            String.join(new List<String>(Product2.getSObjectType().getDescribe().fields.getMap().keySet()), ',') +
                        //add more feilds from related object as and wehn required
            ' FROM Product2 '
        );
    }
}