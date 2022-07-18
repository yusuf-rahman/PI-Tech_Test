trigger ContactTrigger on Contact (after insert) {

    if( Trigger.isInsert ){
        if(Trigger.isAfter){
            ContactTriggerHandler.onAfterInsert(trigger.newMap);
        }
    }    
}