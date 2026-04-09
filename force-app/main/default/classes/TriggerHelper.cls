public with sharing class TriggerHelper {

    public static void handleAccountBeforeInsert(List<Account> newAccounts) {
        for (Account acc : newAccounts) {
            //Question 1
            if (String.isBlank(acc.Type)) {
                acc.Type = 'Prospect';
            }
            //Question 2 (handles CHECK)
            if (!String.isBlank(acc.ShippingStreet) ||
            !String.isBlank(acc.ShippingCity) ||
            !String.isBlank(acc.ShippingState) ||
            !String.isBlank(acc.ShippingPostalCode) ||
            !String.isBlank(acc.ShippingCountry)) {

            acc.BillingStreet     = acc.ShippingStreet;
            acc.BillingCity       = acc.ShippingCity;
            acc.BillingState      = acc.ShippingState;
            acc.BillingPostalCode = acc.ShippingPostalCode;
            acc.BillingCountry    = acc.ShippingCountry;
        }
            //Question 3
            if (!String.isBlank(acc.Phone) && !String.isBlank(acc.Website) && !String.isBlank(acc.Fax)) {
                acc.Rating = 'Hot';
            } 
        }
    }
    public static void handleAccountAfterInsert(List<Account> newAccounts){
        List<Contact> contactsToInsert = new List<Contact>();

        for (Account acc : newAccounts) {           
         //Question 4
            Contact con = new Contact();
            con.LastName = 'DefaultContact';
            con.Email = 'default@email.com';
            con.AccountId = acc.Id;
            contactsToInsert.add(con);
        }
    }

    public static void handleOpportunityBeforeUpdate(List<Opportunity> newOpps) {
       
        // Collect Account IDs
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : newOpps) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        // Map AccountId → CEO Contact
        Map<Id, Contact> accountToCEOMap = new Map<Id, Contact>();

        for (Contact con :[SELECT Id, AccountId FROM Contact WHERE Title = 'CEO' AND AccountId IN :accountIds]) {
            if (!accountToCEOMap.containsKey(con.AccountId)) {
                accountToCEOMap.put(con.AccountId, con);
            }
        }
         for (Opportunity opp : newOpps) {
            if (opp.Amount != null && opp.Amount <= 5000){
                opp.Amount.addError('Opportunity amount must be greater than 5000');
            }
            if (opp.AccountId != null && accountToCEOMap.containsKey(opp.AccountId)) {
                opp.Primary_Contact__c = accountToCEOMap.get(opp.AccountId).Id;
            }
        }

    
    }
    public static void handleOpportunityAfterDelete(List<Opportunity> deletedOpps) {
        // Collect Account IDs
        Set<Id> accountIds = new Set<Id>();
        for (Opportunity opp : deletedOpps) {
            if (opp.AccountId != null) {
                accountIds.add(opp.AccountId);
            }
        }

        // Query Accounts for Industry
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN :accountIds]);

        for (Opportunity opp : deletedOpps) {
            Account acc = accountMap.get(opp.AccountId);

            if (acc != null && acc.Industry == 'Banking' && opp.StageName == 'Closed Won') {

                opp.addError('Cannot delete closed opportunity for a banking account that is won');
            }
        }
    }
    
}
