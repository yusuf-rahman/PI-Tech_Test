@isTest
public without sharing class ContactTriggerActionsTest {

    // Validates that a batch job is triggered
    @isTest
    private static void createCasesTest(){

        //Creating dummy account to relate to contact
        Account acc = new Account(Name='Test Account');
        insert acc;
        
        // Inserting dummy contact to trigger logic
        Test.startTest();
        Contact con = new Contact(LastName='Test Contact', AccountId = acc.Id);
        insert con;
        Test.stopTest();

        // Querying async jobs and validating one was called
        AsyncApexJob[] jobs = [SELECT Id FROM AsyncApexJob WHERE JobType = 'BatchApex'];
        System.assertEquals(1, jobs.size(), 'An async job should have been triggered');
    }

}
