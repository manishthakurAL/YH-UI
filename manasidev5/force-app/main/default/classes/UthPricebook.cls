@isTest
public with sharing class UthPricebook {
        
    public static Pricebook2 build(string name, string ptype, Date startD, Date endD){
        Pricebook2 pbRec = new Pricebook2();
        pbRec.Name = name;
        pbRec.Type__c = ptype;
        pbRec.EffectiveStartDate__c = startD;
        pbRec.EffectiveEndDate__c = endD;
        pbRec.IsActive = true;
        return pbRec;
    }

    public static Pricebook2 create(string name, string ptype, Date startD, Date endD){
        Pricebook2 pbRec = build(name, ptype, startD, endD);
        Insert pbRec;
        return pbRec;
    }

    public static List<Pricebook2> getAll(string pbName){
        return Database.query('SELECT '+
                String.join(new List<String>(Pricebook2.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Pricebook2'
                + ' WHERE Name =: pbName');
    }

    public static List<Pricebook2> getCustomPricebook(){
        return Database.query('SELECT '+
                String.join(new List<String>(Pricebook2.getSObjectType().getDescribe().fields.getMap().keySet()), ',')
                + ' FROM Pricebook2'
                + ' WHERE IsStandard = FALSE');
    }
}