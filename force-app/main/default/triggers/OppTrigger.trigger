trigger OppTrigger on Opportunity (before Update,after Delete) {
    if (Trigger.isBefore && Trigger.isUpdate) {
    TriggerHelper.handleOpportunityBeforeUpdate(Trigger.new);
}
if (Trigger.isAfter && Trigger.isDelete) {
    TriggerHelper.handleOpportunityAfterDelete(Trigger.old);
}

}