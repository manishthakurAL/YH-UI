public inherited sharing class PricebookDecorator {
    public static final String TYPE_SOR = 'SOR';
    public static final String ERROR_SOR_OVERLAP = 'There can be one and only one SOR type PriceBook in the system within the given period';
    public static final String ERROR_WORKORDER_OUTOFRANGE = 'There are Work Orders associated with this Price Book where the Reported Date falls outside the Price Book’s effective date range.';
}