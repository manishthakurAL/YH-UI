public with sharing class IdentifyCustomerDetailsChangeInvocable {

    @InvocableMethod(label='Identify changes to Customer Details')
    public static List<CustomerDetailsChangeResult> identifyChanges(List<IdentifyCustomerChangesInput> params) {
        CustomerDetailsInput oldCustomerDetails = params[0].oldCustomerDetails;
        CustomerDetailsInput newCustomerDetails = params[0].newCustomerDetails;
        Map<String, Boolean> changes = compareInstances(oldCustomerDetails, newCustomerDetails);
        CustomerDetailsChangeResult result = buildResult(changes);
        return New List<CustomerDetailsChangeResult>{result}; 
    }

    private static Map<String, Boolean> compareInstances(Object oldInstance, Object newInstance) {
        if (oldInstance == null || newInstance == null) {
            throw new IdentifyCustomerDetailsChangeException('Both instances must be non-null.');
        }
        Map<String, Object> oldValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(oldInstance));
        Map<String, Object> newValues = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(newInstance));
        Map<String, Boolean> changes = new Map<String, Boolean>();

        for (String key : newValues.keySet()) {
            Object oldValue = oldValues.get(key);
            Object newValue = newValues.get(key);
            if(key == CustomerDetailsDecorator.YH_DISABILITY){
                List<Object> disabilityListOld = new List<Object>();
                List<Object> disabilityListNew = new List<Object>();
                if(oldValue != null){
                    Boolean isBlankOldValue = String.isBlank(oldValue.toString());
                    if(!isBlankOldValue){
                        disabilityListOld = oldValue.toString().split(';');
                    }
                }
                if(newValue != null){
                    Boolean isBlankNewValue = String.isBlank(newValue.toString());
                    if(!isBlankNewValue){
                        disabilityListNew = newValue.toString().split(';');
                    }
                }
                disabilityListNew.sort();
                disabilityListOld.sort();
                if( !disabilityListNew.equals(disabilityListOld)){
                    changes.put(key, true);
                }
            }
            else if (!isEqual(oldValue, newValue)) {
                changes.put(key, true);
            }
        }
        return changes;
    }

    private static Boolean isEqual(Object val1, Object val2) {
        Boolean bEqual = false;
        if (String.isBlank((String)val1) && String.isBlank((String)val2)) {
            bEqual = true;
        } else if (String.isBlank((String)val1) || String.isBlank((String)val2)) {
            bEqual = false;
        }
        if (val1 != null && val2 != null) {
            bEqual = String.valueOf(val1).equals(String.valueOf(val2));
        }
        return bEqual;
    }

    private static CustomerDetailsChangeResult buildResult(Map<String, Boolean> changes) {
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(new CustomerDetailsChangeResult()));
        String[] otherChanges = new List<String>();
        for (String key : resultMap.keySet()) {
            Boolean hasChanges = false;
            if (!inputResultMapping.containsKey(key)) {
                continue;
            }
            for (String changeName : inputResultMapping.get(key)) {
                Boolean hasChangedCurrentProperty = (changes.containsKey(changeName) && changes.get(changeName));
                hasChanges = hasChanges || hasChangedCurrentProperty;
                if ('hasOtherChanges'.equals(key) && hasChangedCurrentProperty) {
                    otherChanges.add(changeName);
                }
            }
            resultMap.put(key, hasChanges);
        }
        resultMap.put('otherChangeDetails', String.join(otherChanges, ';').toUpperCase());
        miscellaneousResultMapping(resultMap);
        return (CustomerDetailsChangeResult) JSON.deserialize(JSON.serialize(resultMap), CustomerDetailsChangeResult.class);
    }

    private static void miscellaneousResultMapping(Map<String, Object> resultMap) {
        Boolean isTitleChanged = ((Boolean)resultMap.get('isTitleChanged') == true);
        Boolean isGenderChanged = ((Boolean)resultMap.get('isGenderChanged') == true);
        Boolean hasNameChanges = ((Boolean)resultMap.get('hasNameChanges') == true);
        resultMap.put('isNameAndTitleChanged', isTitleChanged && hasNameChanges);
        resultMap.put('isNameAndGenderChanged', isGenderChanged && hasNameChanges);
        if (isGenderChanged && !hasNameChanges) {
            resultMap.put('otherChangeDetails',  'GENDER;' + String.valueOf(resultMap.get('otherChangeDetails')));
        }
        if (isTitleChanged && !hasNameChanges) {
            resultMap.put('otherChangeDetails',  'TITLE;' + String.valueOf(resultMap.get('otherChangeDetails')));
        }
    }

    private static Map<String, List<String>> inputResultMapping = new Map<String, List<String>>{
        'isFNChanged'                          => new List<String>{'firstName'},
        'isLNChanged'                          => new List<String>{'lastName'},
        'isMNChanged'                          => new List<String>{'middleName'},
        'isDOBChanged'                         => new List<String>{'birthdate'},
        'isEmailChanged'                       => new List<String>{'email'},
        'isMobileChanged'                      => new List<String>{'mobilePhone'},
        'isTitleChanged'                       => new List<String>{'title'},
        'isDisabilityChanged'                  => new List<String>{'yhDisability'},
        'isGenderChanged'                      => new List<String>{'genderIdentity'},
        'isPronounsChanged'                    => new List<String>{'pronouns'},
        'isHomePhoneChanged'                   => new List<String>{'homePhone'},
        'isOtherPhoneChanged'                  => new List<String>{'OtherPhone'},
        'isYhReligionOrBeliefChanged'          => new List<String>{'yhReligionOrBelief'},
        'isYhMainLanguageChanged'              => new List<String>{'yhMainLanguage'},
        'isYhMaritalStatusChanged'             => new List<String>{'yhMaritalStatus'},
        'isYhEthnicityChanged'                 => new List<String>{'yhEthnicity'},
        'isMailingAddressChanged'              => new List<String>{'mailingAddress'},
        'isYhSexualOrientationChanged'         => new List<String>{'yhSexualOrientation'},
        'hasNameChanges'                       => new List<String>{'firstName', 'lastName', 'middleName'},
        'hasOtherChanges'                      => new List<String>{'pronouns', 'homePhone', 'OtherPhone', 'yhReligionOrBelief',  'yhMainLanguage', 'mailingAddress', 'yhMaritalStatus', 'yhEthnicity', 'yhSexualOrientation'}
    };

    public class IdentifyCustomerDetailsChangeException extends Exception{}  
}