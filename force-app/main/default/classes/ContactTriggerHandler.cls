// Delegator class for the ContactTrigger
public without sharing class ContactTriggerHandler {

    public static Boolean runTrigger = true;

    // Method runs in the before insert trigger context 
    public static void onAfterInsert(Map<Id,Contact> newMap){
        if(runTrigger == true){
            ContactTriggerActions.createCases(newMap);
        }
        
    }
}
