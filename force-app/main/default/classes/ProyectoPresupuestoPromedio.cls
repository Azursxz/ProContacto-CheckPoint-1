/**
 * Servicio que calcula y actualiza el promedio del presupuesto
 * de los proyectos en estado "En Progreso" por Cuenta.
 */
public with sharing class ProyectoPresupuestoPromedio {
    /**
     * Calcula el promedio de Presupuesto__c de los proyectos
     * en estado "En Progreso" y actualiza el campo Promedio__c
     * en las cuentas asociadas.
     *
     * @param proyectos Lista de proyectos (Trigger.new) para extraer las cuentas
     */
    public static void calcularPromedioPresupuesto(List<Proyecto__c> proyectos) {
        Set<Id> cuentaIds = new Set<Id>();
        if (proyectos != null) {
            for (Proyecto__c p : proyectos) {
                if (p.Account__c != null) {
                    cuentaIds.add(p.Account__c);
                }
            }
        }
        if (cuentaIds.isEmpty()) {
            return;
        }
        // 1. Crear un mapa inicial con todas las cuentas a 0
        Map<Id, Account> cuentasMap = new Map<Id, Account>();
        for (Id cuentaId : cuentaIds) {
            cuentasMap.put(cuentaId, new Account(
                Id = cuentaId,
                Promedio__c = 0
            ));
        }
        // 2. Actualizar solo las cuentas que tienen proyectos en progreso
        for (AggregateResult ar : [
            SELECT Account__c cuentaId,
                   AVG(Presupuesto__c) promedio
            FROM Proyecto__c
            WHERE Account__c IN :cuentaIds
            AND Estado__c = 'En Progreso'
            AND Presupuesto__c != null
            WITH USER_MODE
            GROUP BY Account__c
        ]) {
            Id cuentaId = (Id)ar.get('cuentaId');
            Decimal promedio = (Decimal)ar.get('promedio');
            if (cuentasMap.containsKey(cuentaId)) {
                cuentasMap.get(cuentaId).Promedio__c = promedio;
            }
        }
        // 3. Actualizar solo si hay cambios
        if (!cuentasMap.isEmpty()) {
                Database.update(cuentasMap.values(), AccessLevel.USER_MODE);
        }
    }
}