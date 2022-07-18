public class CreateCasesBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    // Set to store Ids of contacts from trigger context
    public Set<Id> contactIds = new Set<Id>();

    // Constructor to set contactIds variable using parameter
    public CreateCasesBatch(Set<Id> contacts){
        contactIds = contacts;
    }

    // Querying essential fields from Contact object using parameter Ids as filter
    public database.QueryLocator start(database.BatchableContext bc) {
        String query = 'SELECT Id, AccountId, OwnerId, Name, Level__c FROM Contact WHERE ID IN: contactIds';
        return Database.getQueryLocator(query);
    }

    public void execute(database.BatchableContext bc, list<Contact> Scope) {
        
        List<Case> casesToBeInserted = new List<Case>(); // List of cases to be inserted later
        List<Id> insertedCaseIds = new List<Id>(); // List of Ids for cases that have successfully been inserted
        
        // Looping through cases from the trigger context and creating a new case and task for each 
        for(Contact con: scope){
            
            // Assigning case attributes based on reqs
            Case newCase = new Case();
            newCase.Subject = con.Name + ' Case';
            newCase.Status = 'Working';
            newCase.Origin = 'New Contact';
            newCase.OwnerId = con.OwnerId;
            newCase.ContactId = con.Id;
            if(con.AccountId != null){
                newCase.AccountId = con.AccountId;
            }

            // Assigning case priority based on contact level
            if(con.Level__c == 'Primary'){
                newCase.Priority = 'High';
            } else if(con.Level__c == 'Secondary'){
                newCase.Priority = 'Medium';
            } else if(con.Level__c == 'Tertiary'){
                newCase.Priority = 'Low';
            }

            // Adding case to list to be inserted outside of loop 
            casesToBeInserted.add(newCase);
        }

        // Inserting cases
        Database.SaveResult[] srList = Database.insert(casesToBeInserted, False);

        // Looping through save results to retrieve successfully inserted cases and add them to list
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                insertedCaseIds.add(sr.getId());
            }
        }
        
        // Querying newly inserted cases to retrieve the CaseNumber
        List<Case> insertedCases = [SELECT Id, CaseNumber, OwnerId, Priority FROM Case Where ID IN: insertedCaseIds];
        List<Task> tasksToBeInserted = new List<Task>(); //List of tasks to be inserted later
        
        // Looping through successfully inserted cases to create a task for each 
        for(Case cs: insertedCases){

            // Assigning task fileds based on reqs
            Task newTask = new Task();
            newTask.WhatId = cs.Id;
            newTask.Status = 'Not Started';
            newTask.Subject = 'Welcome Call for ' + cs.CaseNumber;
            newTask.Priority = 'Normal';
            newTask.OwnerId = cs.OwnerId;

            // Assigning task Due Date based on Case Priority
            if(cs.Priority == 'High'){
                newTask.ActivityDate = Date.today().addDays(7);
            } else if(cs.Priority == 'Medium'){
                newTask.ActivityDate = Date.today().addDays(14);
            } else if(cs.Priority == 'Low'){
                newTask.ActivityDate = Date.today().addDays(21);
            }

            // Adding task to list for insertion outside of loop 
            tasksToBeInserted.add(newTask);
        }

        // Inserting tasks
        Database.insert(tasksToBeInserted, False);
    }

    public void finish(database.BatchableContext bc) {

    }
}
