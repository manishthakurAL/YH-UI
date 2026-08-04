public with sharing class IdentifyCustomerChangesInput {
    @InvocableVariable(label='Customer Details Old' required=true)
    public CustomerDetailsInput oldCustomerDetails;
    @InvocableVariable(label='Customer Details New' required=true)
    public CustomerDetailsInput newCustomerDetails;
}