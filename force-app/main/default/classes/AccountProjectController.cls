public with sharing class AccountProjectController {

    //obtenemos la cuenta de un id en particular
    @AuraEnabled(cacheable=true)
    public static Account getAccount(Id accountId) {
        return [
            SELECT Id, Name
            FROM Account
            WHERE Id = :accountId
        ];
    }

    //obtenemos los recursos y el presupuesto total de los proyectos asociados a una cuenta
    @AuraEnabled(cacheable=true)
    public static Map<String, Decimal> getAccountSummary(Id accountId, Integer refreshKey) {
        AggregateResult ar = [
            SELECT
                SUM(Presupuesto__c) totalBudget,
                SUM(Recursos__c) totalResources
            FROM Proyecto__c
            WHERE Account__c = :accountId
        ];

        Map<String, Decimal> result = new Map<String, Decimal>();
        result.put('totalBudget', (Decimal) ar.get('totalBudget'));
        result.put('totalResources', (Decimal) ar.get('totalResources'));
        return result;
    }


    //obtenemos los proyectos asociados al id de una cuenta

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getProjects(Id accountId) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    for (Proyecto__c p : [
        SELECT Id, Name, Presupuesto__c, Estado__c, Contacto__r.Name
        FROM Proyecto__c
        WHERE Account__c = :accountId
    ]) {
        Map<String, Object> row = new Map<String, Object>();
        row.put('Id', p.Id);
        row.put('Name', p.Name);
        row.put('Presupuesto__c', p.Presupuesto__c);
        row.put('Estado__c', p.Estado__c);
        row.put('ContactoName', p.Contacto__r != null ? p.Contacto__r.Name : '');

        result.add(row);
    }

    return result;
}


    //eliminamos un proyecto usando su Id
    @AuraEnabled
    public static void deleteProject(Id projectId) {
        delete [SELECT Id FROM Proyecto__c WHERE Id = :projectId];
    }
}
