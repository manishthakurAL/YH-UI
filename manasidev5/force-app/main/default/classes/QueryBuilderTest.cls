@isTest
public with sharing class QueryBuilderTest {
    
 @TestSetup
    public static void init() {
        Account acc = createAccount(1);
        createLead();        
        createContact(acc.Id);
    }

    @IsTest
    public static void testFrom1() {
        List<Account> accounts = (List<Account>) new QueryBuilder('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom4() {
        List<Account> accounts = (List<Account>) new QueryBuilder(new Account().getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom5() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom('Account')
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom6() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom(Account.class)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom7() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom(new Account())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFrom8() {
        List<Account> accounts = (List<Account>) new QueryBuilder()
                .addFrom(new Account().getSObjectType())
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testFieldSingleStringField() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFieldsWithSobjectField() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField(Account.Name)
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testStringFieldsCommaSeprated() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Id, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFieldsFromSObject() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new Account(Name = 'test'))
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testStringFields_1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields('Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testStringFields_2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields('Id, Name')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

//     @IsTest
//     public static void testFields23() {
//         List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
//                 .addFields('Name, Name')
//                 .toList();
//         System.assertEquals(1, accounts.size());
//         System.assertNotEquals(null, accounts[0].Name);
//     }

//     @IsTest
//     public static void testFields31() {
//         List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
//                 .addFields(new List<String>{
//                         'Name'
//                 })
//                 .toList();
//         System.assertEquals(1, accounts.size());
//         System.assertNotEquals(null, accounts[0].Name);
//     }

    @IsTest
    public static void testListStringFields() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new List<String>{
                        'Id', 'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testListStringFields_2() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new List<String>{
                        'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testSetStringFields() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFields(new Set<String>{
                        'Name'
                })
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFieldsAll() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAll()
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFieldsAll_PassingObjectName() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAll('Account')
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    @IsTest
    public static void testFieldsAllCreatable() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addFieldsAllCreatable()
                .toList();
        System.assertEquals(1, accounts.size());
        System.assertNotEquals(null, accounts[0].Name);
    }

    // @IsTest
    // public static void testFieldsUsingFieldset() {
    //     List<Account> accounts = (List<Account>)  new QueryBuilder(Account.class)
    //                                             .addFieldSet('UnitTest')
    //                                             .toList();

    //     List<Account> accounts2 = (List<Account>) new QueryBuilder(Account.class)
    //                                             .addFieldSet(SObjectType.Account.FieldSets.UnitTest)
    //                                             .toList();
    // }

    @IsTest
    public static void textExtractFields() {
        List<Object> recordIds = new QueryBuilder(Account.class)
                                .extractField(Account.Id);  
        System.assertEquals(1, recordIds.size());      
    }

    @IsTest
    public static void textExtractFields_String() {
        List<Object> recordIds = new QueryBuilder(Account.class)
                                .extractField('Id');  
        System.assertEquals(1, recordIds.size());      
    }

    @IsTest
    public static void testConditionManager() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.SimpleCondition())
                .preview()
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testConditions_asArray() {
        QueryBuilder.Condition[] conditions = new List<QueryBuilder.Condition>{
                new QueryBuilder.LiteralCondition(Account.CreatedDate).eq('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').ne('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').gt('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').gte('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').lte('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').lt('TODAY')
        };

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditionsWithOrder('1 OR 2 OR 3 OR 4 OR 5 OR 6')
                .add(conditions)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testConditions_asArray_SimpleCondition() {
        QueryBuilder.Condition[] conditions = new List<QueryBuilder.Condition>{
                new QueryBuilder.LiteralCondition('CreatedDate').eq('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').ne('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').gt('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').gte('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').lte('TODAY'),
                new QueryBuilder.LiteralCondition('CreatedDate').lt('TODAY')
        };

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(conditions)
                .addSimpleAndConditions()
                .endConditions()
                .toList();
        System.assertEquals(0, accounts.size());
    }

    @IsTest
    public static void testSimpleCondition() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.SimpleCondition('Name = \'Account-1\''))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testSimpleCondition_Empty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.SimpleCondition())
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testNullConditionNull_StringFld() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').isNull())
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testNullConditionNull_Field() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition(Account.Name).isNull())
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testNullConditionNotNull_Fld() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition(Account.Name).notNull())
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareConditionNotNull_StringFld() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('Name').eq('Account-1'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareConditionString_Fld() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.Name).eq('Account-1'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareConditionString_StringFld() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('Name').ne('Account-1'))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionBoolean_Equal() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('PersonDoNotCall').eq(false))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testCompareConditionBoolean_NotEqual() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('PersonDoNotCall').ne(true))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDecimalEqual() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').eq(1))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDecimalNotEqual() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').ne(0))
                .endConditions()
                .toList();
        // System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDecimalGreaterThan() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').gt(0))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDecimalGreaterThanEqual() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').gte(1))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDecimalLessThan() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').lt(0))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDecimalLessThanEqual() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('NumberOfEmployees').lte(-1))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testCompareConditionDateTimeEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).eq(System.now().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateTimeNotEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).ne(System.now().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateTimeLessThan() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).lt(System.now().addDays(1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateTimeLessThanEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).lte(System.now().addDays(1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateTimeGreaterThan() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).gt(System.now().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateTimeGreaterThanEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).gte(System.now().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.LastActivityDate).eq(System.today().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateNotEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.LastActivityDate).ne(System.today().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateLessThan() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.LastActivityDate).lt(System.today().addDays(1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateLessThanEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.LastActivityDate).lte(System.today().addDays(1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateGreaterThan() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.LastActivityDate).gt(System.today().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDateGreaterThanEqual() {

        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.LastActivityDate).gte(System.today().addDays(-1)))
                .endConditions()
                .preview()
                .toList();
        System.assert(accounts.isEmpty());
        
    }

    @IsTest
    public static void testCompareConditionDecimal_All() {
        List<Account> accounts1 = (List<Account>) (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.AnnualRevenue).eq(100000))
                .endConditions()
                .toList();
        System.assert(!accounts1.isEmpty());

        List<Account> accounts2 = (List<Account>) (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.AnnualRevenue).ne(100000))
                .endConditions()
                .toList();
        System.assert(accounts2.isEmpty());

        List<Account> accounts3 = (List<Account>) (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.AnnualRevenue).lt(100000))
                .endConditions()
                .toList();
        System.assert(accounts3.isEmpty());

        List<Account> accounts4 = (List<Account>) (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.AnnualRevenue).lte(100000))
                .endConditions()
                .toList();
        System.assert(!accounts4.isEmpty());

        List<Account> accounts5 = (List<Account>) (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.AnnualRevenue).gt(100000))
                .endConditions()
                .toList();
        System.assert(accounts5.isEmpty());

        List<Account> accounts6 = (List<Account>) (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.AnnualRevenue).gte(100000))
                .endConditions()
                .toList();
        System.assert(!accounts6.isEmpty());
    }

    @IsTest
    public static void testLikeCondition_likeAnyBoth() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition('Name').likeAnyBoth('ccount-'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition_notLikeAnyBoth() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition(Account.Name).notLikeAnyBoth('ramees'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition_likeAnyLeft() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition('Name').likeAnyLeft('ccount-1'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testLikeCondition_likeAnyRight() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.LikeCondition('Name').likeAnyRight('Account-'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInCondition_SetIdEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new Set<Id>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInCondition_IdListEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new List<Id>()))
                .endConditions()
                .preview()
                .toList();
        System.assert(!accounts.isEmpty());
    }
    
    @IsTest
    public static void testInConditionInCollection_ListIds() {
        List<Id> recordIds = ( new List<Id>( new QueryBuilder(Account.class).toIdSet()));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(recordIds))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testNotInCondition_ListIds() {
        List<Id> recordIds = ( new List<Id>( new QueryBuilder(Account.class).toIdSet()));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(recordIds))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testNotInCondition_SetIds() {
        Account acc = createAccount(2);
        Contact ct = createContact(acc.Id);
        Set<Id> recordIds = (new QueryBuilder(Contact.class).toIdSet());
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(recordIds))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testNotInCondition_SetIdsEmpty() {
        Set<Id> recordIds = (new QueryBuilder(Contact.class).toIdSet());
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').notIn(new Set<Id>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_ListSObject() {
        List<SObject> records =  new QueryBuilder(Account.class).toList();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(records))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_MapSObject() {
        Map<Id, SObject> records =  new QueryBuilder(Account.class).toMap();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(records))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }



    @IsTest
    public static void testInConditionInCollection_StringEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new List<String>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_SetEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(new Set<String>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_DecimalEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('AnnualRevenue').inCollection(new List<Decimal>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_Decimal() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('AnnualRevenue').inCollection(new List<Decimal>{30.1, 40.1}))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_SetDecimalEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('AnnualRevenue').inCollection(new Set<Decimal>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_SetDecimal() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('AnnualRevenue').inCollection(new Set<Decimal>{30.1, 40.1}))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_PicklistEntryEmpty() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('AccountSource').inCollection(new List<PicklistEntry>()))
                .endConditions()
                .toList();
        System.assert(!accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_PicklistEntry() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('AccountSource').inCollection(Account.AccountSource.getDescribe().getPicklistValues()))
                .endConditions()
                .toList();
        System.assert(accounts.isEmpty());
    }

    @IsTest
    public static void testInConditionInCollection_String() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Name').inCollection(new List<String>{
                        'Account-1'
                }))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInConditionInCollection_StringWithField() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition(Account.Name).inCollection(new List<String>{
                        'Account-1'
                }))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInConditionInCollection_SetString() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Name').inCollection(new Set<String>{
                        'Account-1'
                }))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInConditionInCollection_IdSet() {
        Set<Id> accIds = new QueryBuilder('Account').toIdSet();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(accIds))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInConditionInCollection_IdList() {
        List<String> accIds = new List<Id>(new QueryBuilder('Account').toIdSet());
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(accIds))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testInConditionInCollection_SubQuery_WithSecurity() {
        Account acc = createAccount(2);
        Contact ct = createContact(acc.Id);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition('Id').inCollection(
                        new QueryBuilder(Contact.class)
                        .addField(Contact.AccountId)
                ))
                .endConditions()
                .setWithSecurityEnforced()
                .setCheckCRUD()
                .setCheckCRUDAndFLS()
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testSetForReference() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setForReference()
                .toList();
    }

    @IsTest
    public static void testComplexCondition0() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        System.assertEquals('', complex.toString());
    }

    @IsTest
    public static void testComplexCondition1() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.startCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition2() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition3() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.orCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition4() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .add(complex)
                .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
                .endConditions()
                .preview()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition5() {
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .add(complex)
                .setConditionOrder('1' + complex.addOrderIfNotEmpty('AND 2'))
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition6() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-1'));
        complex.andCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testComplexCondition7() {
        Id accId = new QueryBuilder('Account').toSObject().Id;
        createAccount(2);

        QueryBuilder.ComplexCondition complex = new QueryBuilder.ComplexCondition();
        complex.andCondition(new QueryBuilder.CompareCondition('Name').eq('Account-2'));
        complex.orCondition(new QueryBuilder.CompareCondition('Id').eq(accId));
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(complex)
                .endConditions()
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testLimit1() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setLimit(-1)
                .toList();
        System.assertEquals(2, accounts.size());
    }

    @IsTest
    public static void testLimit2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .setLimit(1)
                .toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testOrderAscStringField() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderAsc('Name')
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrderAscWithField() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderAsc(Account.Id)
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrderDescStringField() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc('Name')
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrderDescWithField() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc(Account.Id)
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrder2() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc('Name')
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrder3() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderAsc('Name')
                .addOrderAsc('Id')
                .toList();
        System.assertEquals('Account-1', accounts[0].Name);
    }

    @IsTest
    public static void testOrder4() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc('Name')
                .addOrderDesc('Id')
                .setOffset(0)
                .addOrder(
                    new List<QueryBuilder.Order>{
                        (new QueryBuilder.AscOrder('CreatedDate'))
                    }
                )
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

    @IsTest
    public static void testOrderDesc5() {
        createAccount(2);
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addField('Name')
                .addOrderDesc('Name')
                .addOrderDesc('Id')
                .setOffset(0)
                .addOrder(
                    new List<QueryBuilder.Order>{
                        (new QueryBuilder.Order('CreatedDate')).setSortingOrderDesc().setNullsOrderFirst()
                    }
                )
                .toList();
        System.assertEquals('Account-2', accounts[0].Name);
    }

        @IsTest
        public static void testOrderAscWithNullOrderLast(){
                List<Account> accounts = (new QueryBuilder(Account.class)
                                        .addOrder(
                                        new QueryBuilder.Order(Account.Id)
                                                .setSortingOrderAsc()
                                                .setNullsOrderLast()))
                                        .toList();
        }

    @IsTest
    public static void testGroupbyStringField() {
        List<SObject> aggr = new QueryBuilder(Account.class)
         .addField('ParentId')
         .addGroupBy('ParentId')
         .toList();
    }

    @IsTest
    public static void testGroupbyField() {
        List<SObject> aggr = new QueryBuilder(Account.class)
         .addField(Account.ParentId)
         .addGroupBy(Account.ParentId)
         .toList();
    }

    @IsTest
    public static void testScope1() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition(Account.Name).inCollection(new List<String>{
                        'Account-1'
                }))
                .endConditions()
                .setScope(QueryBuilder.FilterScope.Everything)
                .toList();
    }


    @IsTest
    public static void testScope3() {
        List<Account> accounts = (List<Account>) new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.InCondition(Account.Name).inCollection(new List<String>{
                        'Account-1'
                }))
                .endConditions()
                .setScope(QueryBuilder.FilterScope.Mine)
                .toList();
    }


    @IsTest
    public static void testPreview() {
        new QueryBuilder(Account.class)
                .preview();
    }

    @IsTest
    public static void testPreviewCount() {
        new QueryBuilder(Account.class)
                .previewCount();
    }

    @IsTest
    public static void testToString() {
        String queryString = new QueryBuilder(Account.class)
                .toString();
        System.assertEquals('SELECT Id \nFROM Account', queryString);
    }

    @IsTest
    public static void testToCountString() {
        String queryString = new QueryBuilder(Account.class)
                .setLimit(10000)
                .setOffset(1)
                .setScope(QueryBuilder.FilterScope.Mine)
                .toStringCount();
        System.assertEquals('SELECT count() FROM Account USING SCOPE Mine LIMIT 10000 OFFSET 1', queryString);
    }

    @IsTest
    public static void testToCountString2() {
        String queryString = new QueryBuilder(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition('Name').eq('Account-1'))
                .endConditions()
                .toStringCount();
        System.assertEquals('SELECT count() FROM Account WHERE Name = \'Account-1\'', queryString);
    }

    @IsTest
    public static void testResetResult() {
       QueryBuilder accountQueryBuilder = new QueryBuilder('Account');
        List<Account> accounts = (List<Account>) accountQueryBuilder
                .toList();
        System.assertEquals(1, accounts.size());

        createAccount(2);
        accounts = (List<Account>) accountQueryBuilder.toList();
        System.assertEquals(1, accounts.size());

        accountQueryBuilder.resetResult();
        accounts = (List<Account>) accountQueryBuilder.setOffset(1).toList();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToMap1() {
        Map<Id, SObject> accounts = new QueryBuilder('Account')
                .addField('Name')
                .toMap();
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToMap2() {
        Map<Id, Account> accounts = new Map<Id, Account>();
        new QueryBuilder('Account')
                .addField('Name')
                .toMap(accounts);
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    public static void testToSobject() {
        Account account = (Account) new QueryBuilder('Account')
                .toSObject();
        System.assertNotEquals(null, account);
    }

    @IsTest
    public static void testToSobject2() {
        SObject account = (Account) new QueryBuilder('Account')
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').isNull())
                .endConditions()
                .toSObject();
        System.assertEquals(null, account);
    }

    @IsTest
    public static void testToIdSet() {
        Set<Id> accountIds = new QueryBuilder('Account')
                .toIdSet();
        System.assertEquals(1, accountIds.size());
    }

    @IsTest
    public static void testExtractIds() {
        final Id ACCOUNT_ID = new QueryBuilder('Account').toSObject().Id;
        createContact(ACCOUNT_ID);
        Set<Id> extractedIds = new QueryBuilder('Contact')
                .addField('AccountId')
                .extractIds('AccountId');
        System.assertEquals(1, extractedIds.size());
        System.assert(extractedIds.contains(ACCOUNT_ID));
    }

    @IsTest
    public static void testForViewAndReference() {
        List<SObject> result1 = new QueryBuilder(Account.class)
                                .setForView(true)
                                .toList();

        List<SObject> result2 = new QueryBuilder(Account.class)
                                .setForView()
                                .toList();
        
        List<SObject> result3 = new QueryBuilder(Account.class)
                                .setForReference(true)
                                .toList();

        List<SObject> result4 = new QueryBuilder(Account.class)
                                .setForReference()
                                .toList();
        
                                // testing knowlege article enabled org please uncomment and commment account.class
        List<SObject> result5 = new QueryBuilder(Account.class/*KnowledgeArticle.class*/)
                                .setUpdateTracking(true)
                                .toList();

        List<SObject> result6 = new QueryBuilder(Account.class/*KnowledgeArticle.class*/)
                                .setUpdateTracking()
                                .toList();

        List<SObject> result7 = new QueryBuilder(Account.class/*KnowledgeArticle.class*/)
                                .setUpdateViewstat(true)
                                .toList();

        List<SObject> result8 = new QueryBuilder(Account.class/*KnowledgeArticle.class*/)
                                .setUpdateViewstat()
                                .toList();
    }

    @IsTest
    public static void testClone1() {
       QueryBuilder qb1 = new QueryBuilder('Account');
        System.assertEquals('SELECT Id \nFROM Account', qb1.toString());

       QueryBuilder qb2 = qb1.cloneQueryBuilder();
        qb2.addField('Name');

        qb1.resetResult();
        System.assertEquals('SELECT Id \nFROM Account', qb1.toString());
        System.assertEquals('SELECT Name \nFROM Account', qb2.toString());
    }

    @IsTest
    public static void testClone2() {
       QueryBuilder qb1 = new QueryBuilder('Account');
        qb1.toList();

       QueryBuilder qb2 = qb1.cloneQueryBuilder(true);
        createAccount(2);

        System.assertEquals(qb1.toList(), qb2.toList());
    }

    @isTest
    static void testCrudFls() {

        List<SObject> records = (new QueryBuilder(Account.class))
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .endConditions()
                .setCheckCRUDAndFLS(true)
                .toList();
    }

    // @isTest
    // static void testCrudFlsWithParentRelation() {
    //     List<SObject> records = (new QueryBuilder(Contact.class))
    //             .addFields('Id, FirstName, LastName, Account.Name, Account.Id, Account.AnnualRevenue')
    //             .setCheckCRUDAndFLS(true)
    //             .toList();
    // }

    @isTest
    static void testCrudFlsWithChildRelation_NoAccess_Exp() {
        User chtterUser = createChatterExternalUser();
        System.runAs(chtterUser) {
                Test.startTest();

                try {
                        List<SObject> records = (new QueryBuilder(Account.class)
                                .addSubQuery(new QueryBuilder('Contacts')
                                                .addField(Contact.Name)
                                                .setCheckCRUDAndFLS(true)))
                                .setCheckCRUDAndFLS(true)
                                .setWithSecurityEnforced(false)
                                .preview()
                                .toList();
                } catch(Exception exp) {
                        System.assert(true, 'Expected to throw no access exception');
                }

                Test.stopTest();
        }
    }


    @isTest
    static void testCrudFls_NoFldAccess_Exp() {
        User stdUser = createStandardUser();
        System.runAs(stdUser) {
                Test.startTest();

                try {
                        List<SObject> records = new QueryBuilder(Lead.class)
                                .addField(Lead.HasOptedOutOfEmail)
                                .setCheckCRUDAndFLS(true)
                                .preview()
                                .toList();
                } catch(Exception exp) {
                        System.debug('##### exception ' + exp.getMessage() + ' => ' );
                        System.assert(true, 'Expected to throw no access exception');
                }

                Test.stopTest();
        }
    }

    @isTest
    static void testCrudFlsWithChildRelation_NoFldAccess_Exp() {
        User stdUser = createStandardUser();
        Account acc2;
        Contact ct2;
        System.runAs(stdUser) {
                acc2 = createAccount(2);
                ct2 = createContact(acc2.Id);
                createOpportunity(acc2.Id, ct2.Id);
        }
        User contextUser = new User(Id = UserInfo.getUserId());

        System.runAs(contextUser) {
                createOpportunity(acc2.Id, ct2.Id);
        }

        System.runAs(stdUser) {
                Test.startTest();
                try {

                        List<SObject> records = new QueryBuilder(Account.class)
                        .addSubQuery(new QueryBuilder('Opportunities')
                                        .addFields('TotalOpportunityQuantity, Account.AnnualRevenue')
                                        .setCheckCRUDAndFLS(true))
                        .addSubQuery(new QueryBuilder('Contacts')
                                                .addField(Contact.Name)
                                                .setCheckCRUDAndFLS(true))
                        .setCheckCRUDAndFLS(true)
                        .preview()
                        .toList();
                     
                } catch(Exception exp) {
                        System.debug('##### exception ' + exp.getMessage() + ' => ' );
                        System.assert(true, 'Expected to throw no access exception');
                }

                Test.stopTest();
        }
    }

    @isTest
    static void testCrudFlsWithParentRelation_NoFldAccess_Exp() {
        User stdUser = createStandardUser();
        System.runAs(stdUser) {
                Test.startTest();
                Account acc2 = createAccount(1);
                Contact ct = createContact(acc2.Id);
                try {

                        List<SObject> records = new QueryBuilder(Contact.class)
                        .addFields('Id, Account.AnnualRevenue, Account.Name ')
                        .setCheckCRUDAndFLS(true)
                        .preview()
                        .toList();
                     
                } catch(Exception exp) {
                        System.debug('##### exception ' + exp.getMessage() + ' => ' );
                        System.assert(true, 'Expected to throw no access exception');
                }

                Test.stopTest();
        }
    }

    @IsTest 
    static void testQueryLocator() {
        Database.QueryLocator locator = (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.CreatedDate).gte(System.now()))
                .endConditions()
                .toQueryLocator();
    }

    @IsTest 
    static void testNotInAndInCollection() {

        Account acc = createAccount(2);
        Contact ct = createContact(acc.Id);

        List<SObject> records = (new QueryBuilder(Account.class))
        .addConditionsWithOrder('1')
        .add(new QueryBuilder.InCondition('Id').notIn((new QueryBuilder(Contact.class)).addField('Id').toList()))
        .endConditions()
        .toList();

        List<SObject> records2 = (new QueryBuilder(Account.class))
        .addConditionsWithOrder('1')
        .add(new QueryBuilder.InCondition('Id').notIn((new QueryBuilder(Contact.class)).addField('Id').toMap()))
        .endConditions()
        .toList();

        List<SObject> records3 = (new QueryBuilder(Account.class))
        .addConditionsWithOrder('1 AND 2')
        .add(new QueryBuilder.InCondition('Name').inCollection(new List<String>{'Test'}))
        .add(new QueryBuilder.InCondition('Id').notIn((new QueryBuilder(Contact.class)).addField('AccountId')))
        .endConditions()
        .toList();

        List<SObject> records4 = (new QueryBuilder(Account.class))
        .addConditionsWithOrder('1 AND 2')
        .add(new QueryBuilder.InCondition('AnnualRevenue').inCollection(new List<Decimal>{12.12,13.34}))
        .add(new QueryBuilder.InCondition('Id').notIn((new QueryBuilder(Contact.class)).addField('AccountId')))
        .endConditions()
        .toList();

        Set<Id> contactIds = (new QueryBuilder(Contact.class)).addField('Id').toMap().keySet();

        List<SObject> records5 = (new QueryBuilder(Contact.class))
        .addConditionsWithOrder('1')
        .add(new QueryBuilder.InCondition('Id').notIn(contactIds))
        .endConditions()
        .toList();
    }

    @IsTest
    private static void testInterfaceMethod() {

        (new QueryBuilder(Account.class)).newQuery();
        //SELECT Id FROM Account
         (new QueryBuilder(Account.class).toString());

        //SELECT count() FROM Account
         (new QueryBuilder(Account.class).toStringCount());

        //1
         (new QueryBuilder(Account.class).toCount());

        //[Account:(...)]
         (new QueryBuilder(Account.class).toList());


         (new QueryBuilder(Account.class).toMap());

        //Account:(...)
         (new QueryBuilder(Account.class).toSObject());

        //[account_id]
         (new QueryBuilder(Account.class).toIdSet());

        //[account_id]
         (new QueryBuilder(Account.class).extractIds('Id'));

        //[account_name]
         (new QueryBuilder(Account.class).addField(Account.Name).extractField('Name'));
    }

    @IsTest
    private static void testSubQueryWithDefaults() {

        (new QueryBuilder(Account.class)
        .addSubQuery(new QueryBuilder('Contacts').addField(Contact.Name))).toList();

        (new QueryBuilder(Account.class)
        .addSubQuery('SELECT LastName FROM Contacts')).toList();
    }

    @IsTest
    private static void testAdditionalFieldMethods() {

        (new QueryBuilder().addFieldsAll(Account.class));

        (new QueryBuilder()
          .addFieldsAll(Account.getSObjectType()));

        (new QueryBuilder()
          .addFieldsAll(new Account()));

        (new QueryBuilder()
           .addFieldsAllCreatable(Account.class));

        (new QueryBuilder()
           .addFieldsAll(Account.getSObjectType()));

        (new QueryBuilder()
           .addFieldsAll(new Account()));

        (new QueryBuilder(Account.class)
           .addFieldsAllUpdatable());

        (new QueryBuilder()
           .addFieldsAllUpdatable('Account'));

        (new QueryBuilder()
           .addFieldsAllUpdatable(Account.class));

        (new QueryBuilder()
           .addFieldsAllUpdatable(Account.getSObjectType()));

        (new QueryBuilder()
           .addFieldsAllUpdatable(new Account()));

        (new QueryBuilder())
           .addFieldsAllCreatable(Account.getSObjectType());
  
        (new QueryBuilder())
            .addFieldsAllCreatable(new Account());
    }

    @IsTest
    private static void testRecordTypeCondition() {

        List<SObject> result = (new QueryBuilder(Case.class))
        .addConditions()
        .add(new QueryBuilder.RecordTypeCondition('Changes'))
        .endConditions()
        .toList();
    }

    @IsTest
    private static void testPreviewWithCompareCondition() {
        (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.Name).eq('Account-1'))
                .endConditions()
                .preview();

        (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.CompareCondition(Account.Name).ne('Account-1'))
                .endConditions()
                .preview();
    }


    @IsTest
    private static void testAdditionalNullCondition() {

        (new QueryBuilder(Account.class)).addField('Name')
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .endConditions()
                .setCheckCRUDAndFLS(true)
                .setUpdateViewstat()
                .preview();
        (new QueryBuilder(Account.class)).addFieldsAll(Account.class)
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .endConditions()
                .setCheckCRUD(false)
                .preview();
        (new QueryBuilder(Account.class)).addField('Name')
                .addConditions()
                .add(new QueryBuilder.NullCondition('Name').notNull())
                .endConditions()
                .setCheckFLS()
                .preview();
       
    }

    //Utility methods
    private static Account createAccount(Integer i) {

        Account result = UthAccount.build(); 
        result.Name = 'Account-'+i;
        result.AnnualRevenue = 100000;
        result.NumberOfEmployees = 100;
        insert result;
        return result;
    }

    private static Contact createContact(Id accId) {
        Contact con = UthContact.build(accId); 
        con.FirstName = con.FirstName + String.valueof((Math.random() * 1000));
        con.LastName = con.LastName + String.valueof((Math.random() * 1000));
        con.Email = 'Test'+ String.valueof((Math.random() * 1000)) +'@123global.com';
        con.Phone = '1234' +  String.valueof((Math.random() * 1000));
        con.MailingCity = 'City' +  String.valueof((Math.random() * 1000));
        con.MailingPostalCode = 'P' +  String.valueof((Math.random() * 1000));
        insert con;
        return con;
    }

    private static Lead createLead() {
        Lead ld = new Lead(Company = 'JohnMiller', LastName = 'Mike', Status = 'Open', HasOptedOutOfEmail = true);
        insert ld;
        return ld;
    }

    private static Opportunity createOpportunity(Id accId, Id ctId) {
        Opportunity opp = new Opportunity();
       
       // Do you recognize these fields?
       opp.StageName = 'Sourcing Demand';
       opp.CloseDate = System.today();
       opp.AccountId = accId;
       opp.ContactId = ctId;
       opp.TotalOpportunityQuantity = 10;
       opp.Name = 'Test Opportunity Triggers';       
       insert opp;

       return opp;
    }

    private static User createStandardUser() {
            Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

            User usr = new User(LastName = 'RAMEES',
                    FirstName='MHD',
                    Alias = 'MRSH',
                    Email = 'm.ramees@testlive.com',
                    Username = 'm.ramees@testlive.com.sfdc',
                    ProfileId = profileId.id,
                    TimeZoneSidKey = 'GMT',
                    LanguageLocaleKey = 'en_US',
                    EmailEncodingKey = 'UTF-8',
                    LocaleSidKey = 'en_US'
                    );
            insert usr;
            return usr;
    }

    private static User createChatterExternalUser() {
            // Can only proceed with test if we have a suitable profile - Chatter External license has no access to Opportunity
            List<Profile> testProfiles = [Select Id From Profile where UserLicense.Name='Chatter External' limit 1];
            if(testProfiles.size()!=1)
                    return null; 		

            // Can only proceed with test if we can successfully insert a test user 
            String testUsername = System.now().format('yyyyMMddhhmmss') + '@testorg.com';
            User testUser = new User(Alias = 'test1', Email='testuser1@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = testProfiles[0].Id, TimeZoneSidKey='America/Los_Angeles', UserName=testUsername);
            try {
                    insert testUser;
            } catch (Exception e) {
                    return null;
            }		
            return testUser;
    }


}