trigger AccountTrigger on Account (before insert ,after insert) {
if(Trigger.isBefore && Trigger.isInsert){
    TriggerHelper.handleAccountBeforeInsert(Trigger.new);
}
if(Trigger.isAfter && Trigger.isInsert){
    TriggerHelper.handleAccountAfterInsert(Trigger.new);
}

}