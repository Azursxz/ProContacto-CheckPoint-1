/**
 * Handler encargado de validar el límite máximo de proyectos
 * en estado "En Progreso" permitidos por Cuenta.
 *
 * Se utiliza en triggers before insert y before update
 * para evitar superar el valor definido en
 * Account.Maximo_Proyectos_Activos__c.
 */
public with sharing class ProyectoValidacionLimiteHandler {
  /**
   * Valida que no se supere el límite de proyectos activos
   * por cuenta. Si el límite es excedido, se agrega un error
   * al registro de Proyecto__c correspondiente.
   *
   * @param proyectos Lista de proyectos a validar
   */
  public static void validarLimiteProyectosActivos(
    List<Proyecto__c> proyectos
  ) {
    Set<Id> cuentaIds = new Set<Id>();
    // 1. Recopilar IDs de cuenta
    for (Proyecto__c proyecto : proyectos) {
      if (proyecto.Account__c != null && proyecto.Estado__c == 'En Progreso') {
        cuentaIds.add(proyecto.Account__c);
      }
    }
    if (cuentaIds.isEmpty()) {
      return;
    }

    // 2. Contar proyectos en proceso por cuenta
    Map<Id, Integer> conteoPorCuenta = new Map<Id, Integer>();
    for (AggregateResult ar : [
      SELECT Account__c, COUNT(Id) total
      FROM Proyecto__c
      WHERE Account__c IN :cuentaIds AND Estado__c = 'En Progreso'
      WITH USER_MODE
      GROUP BY Account__c
    ]) {
      conteoPorCuenta.put((Id) ar.get('Account__c'), (Integer) ar.get('total'));
    }
    // 3. Obtener límites de cuentas
    Map<Id, Account> cuentasMap = new Map<Id, Account>(
      [
        SELECT Id, Maximo_Proyectos_Activos__c
        FROM Account
        WHERE Id IN :cuentaIds
        WITH USER_MODE
      ]
    );
    // 4. Validar cada proyecto
    for (Proyecto__c proyecto : proyectos) {
      Integer proyectosActuales = conteoPorCuenta.get(proyecto.Account__c);
      Account cuenta = cuentasMap.get(proyecto.Account__c);
      // Sumar 1 porque este proyecto también cuenta
      if (proyectosActuales + 1 > cuenta.Maximo_Proyectos_Activos__c) {
        proyecto.addError(
          'Límite excedido. Máximo permitido: ' +
          cuenta.Maximo_Proyectos_Activos__c
        );
      }
    }
  }
}
