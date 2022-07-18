@isTest
public without sharing class CreateCasesBatchTest {

    // Create test data for use across methods
    @TestSetup
    static void makeData(){
        
        // Creating dummy account to relate to contacts
        Account acc = new Account(Name='Test Account');
        insert acc;

        // List to store contacts for insertion 
        List<Contact> ContactsToInsert = new List<Contact>();

        // Creating 200 contacts and adding them to a list
        for(integer i=1; i<=200; i++){

            Contact con = new Contact(LastName = 'Contact ' + i, AccountId = acc.Id, Level__c = 'Primary');
            ContactsToInsert.add(con);
        }

        // Disabling the contact trigger so that it can be triggered manually later on in tests
        ContactTriggerHandler.runTrigger = false;
        insert ContactsToInsert;
    }

    // Validate that a case and task are correctly created for a 'Primary' level contact 
    @isTest 
    private static void createCasesTestA(){

        // Querying an existing contact and adding them to a set
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Contact 1' LIMIT 1];
        Set<Id> contactList = new Set<Id>{con.Id};
        
        // Running the batch 
        Test.startTest();
        CreateCasesBatch batch = new CreateCasesBatch(contactList);
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Validating that a single case was created and that its Priority is High 
        List<Case> resultantCases = [SELECT Id, Priority FROM Case];
        System.assertEquals(1, resultantCases.size(), 'One case should have been created');
        System.assertEquals('High', resultantCases[0].Priority, 'The priority of the case should be High');

        // Validating that a single Task was created and its Due Date is in 7 days
        List<Task> resultantTasks = [SELECT ID, ActivityDate FROM Task];
        System.assertEquals(1, resultantTasks.size(), 'One task should have been created');
        System.assertEquals(Date.today().addDays(7), resultantTasks[0].ActivityDate, 'The Due Date for the activity should have been 1 week in the future');
    }

    // Validate that a case and task are correctly created for a 'Secondary' level contact 
    @isTest 
    private static void createCasesTestB(){

        // Querying an existing contact and changing its priority
        Contact con = [SELECT Id, Level__c FROM Contact WHERE LastName = 'Contact 1' LIMIT 1];
        con.Level__c = 'Secondary';
        update con;

        // Creating a new set and adding the contact from above
        Set<Id> contactList = new Set<Id>{con.Id};
        
        // Running the batch 
        Test.startTest();
        CreateCasesBatch batch = new CreateCasesBatch(contactList);
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Validating that a single case was created and that its Priority is Medium 
        List<Case> resultantCases = [SELECT Id, Priority FROM Case];
        System.assertEquals(1, resultantCases.size(), 'One case should have been created');
        System.assertEquals('Medium', resultantCases[0].Priority, 'The priority of the case should be Medium');

        // Validating that a single Task was created and its Due Date is in 7 days
        List<Task> resultantTasks = [SELECT ID, ActivityDate FROM Task];
        System.assertEquals(1, resultantTasks.size(), 'One task should have been created');
        System.assertEquals(Date.today().addDays(14), resultantTasks[0].ActivityDate, 'The Due Date for the activity should have been 2 weeks in the future');
    }

    // Validate that a case and task are correctly created for a 'Tertiary' level contact 
    @isTest 
    private static void createCasesTestC(){

        // Querying an existing contact and changing its priority
        Contact con = [SELECT Id, Level__c FROM Contact WHERE LastName = 'Contact 1' LIMIT 1];
        con.Level__c = 'Tertiary';
        update con;
        
        // Creating a new set and adding the contact from above
        Set<Id> contactList = new Set<Id>{con.Id};
        
        // Running the batch 
        Test.startTest();
        CreateCasesBatch batch = new CreateCasesBatch(contactList);
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Validating that a single case was created and that its Priority is Medium 
        List<Case> resultantCases = [SELECT Id, Priority FROM Case];
        System.assertEquals(1, resultantCases.size(), 'One case should have been created');
        System.assertEquals('Low', resultantCases[0].Priority, 'The priority of the case should be Low');

        // Validating that a single Task was created and its Due Date is in 7 days
        List<Task> resultantTasks = [SELECT ID, ActivityDate FROM Task];
        System.assertEquals(1, resultantTasks.size(), 'One task should have been created');
        System.assertEquals(Date.today().addDays(21), resultantTasks[0].ActivityDate, 'The Due Date for the activity should have been 3 weeks in the future');
    }

    // Validate cases and tasks are created in bulk
    @isTest 
    private static void createCaseBulkTest(){

        // Querying all 200 contacts and adding them to a map 
        Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id FROM Contact]);

        // Running the batch
        Test.startTest();
        CreateCasesBatch batch = new CreateCasesBatch(contactMap.keySet());
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();

        // Asserting that 200 cases and tasks were created
        System.assertEquals(200, [SELECT Count() FROM Case], '200 Cases should have been created');
        System.assertEquals(200, [SELECT Count() FROM Task], '200 Cases should have been created');
    }
}
