/**
 * Controller AuraEnabled para gestionar cuentas y proyectos asociados.
 * Provee métodos para obtener información de la cuenta, resúmenes
 * y operaciones sobre proyectos.
 */
public with sharing class AccountProjectController {
  /**
   * Obtiene una cuenta a partir de su Id.
   *
   * @param accountId Id de la cuenta
   * @return Account con Id y Name
   */
  @AuraEnabled(cacheable=true)
  public static Account getAccount(Id accountId) {
    return [
      SELECT Id, Name
      FROM Account
      WHERE Id = :accountId
      WITH USER_MODE
    ];
  }
  /**
   * Obtiene el resumen de presupuesto y recursos de los proyectos
   * asociados a una cuenta.
   *
   * @param accountId Id de la cuenta
   * @param refreshKey Clave para forzar refresco desde LWC
   * @return Mapa con totalBudget y totalResources
   */
  @AuraEnabled(cacheable=true)
  public static Map<String, Decimal> getAccountSummary(
    Id accountId,
    Long refreshKey
  ) {
    AggregateResult ar = [
      SELECT SUM(Presupuesto__c) totalBudget, SUM(Recursos__c) totalResources
      FROM Proyecto__c
      WHERE Account__c = :accountId
      WITH USER_MODE
    ];

    Map<String, Decimal> result = new Map<String, Decimal>();

    Decimal budget = (Decimal) ar.get('totalBudget');
    Decimal resources = (Decimal) ar.get('totalResources');

    // Usamos lógica ternaria: ¿Es null? pon 0, si no, pon el valor.
    result.put('totalBudget', budget == null ? 0 : budget);
    result.put('totalResources', resources == null ? 0 : resources);
    return result;
  }

  /**
   * Obtiene los proyectos asociados a una cuenta.
   *
   * @param accountId Id de la cuenta
   * @return Lista de mapas con los datos del proyecto
   */
  @AuraEnabled(cacheable=true)
  public static List<Map<String, Object>> getProjects(Id accountId) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();

    for (Proyecto__c p : [
      SELECT Id, Name, Presupuesto__c, Estado__c, Contacto__r.Name
      FROM Proyecto__c
      WHERE Account__c = :accountId
      WITH USER_MODE
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

  /**
   * Elimina un proyecto a partir de su Id.
   *
   * @param projectId Id del proyecto a eliminar
   */
  @AuraEnabled
  public static void deleteProject(Id projectId) {
    List<Proyecto__c> proyectos = [
      SELECT Id
      FROM Proyecto__c
      WHERE Id = :projectId
      WITH USER_MODE
    ];

    if (!proyectos.isEmpty()) {
      Database.delete(proyectos, AccessLevel.USER_MODE);
    }
  }
}
