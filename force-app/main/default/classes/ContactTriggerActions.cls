// This class contains the business logic for the ContactTriggerHandler
public without sharing class ContactTriggerActions {

    // This method calls a batch class to create a case and task for each newly inserted contact
    public static void createCases(Map<Id,Contact> newMap){
            CreateCasesBatch batch = new CreateCasesBatch(newMap.keySet());
            Id batchId = Database.executeBatch(batch);

    }
}
