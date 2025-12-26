public with sharing class ProyectoPresupuestoPromedio {
       public static void calcularPromedioPresupuesto(Set<Id> cuentaIds) {
        if (cuentaIds == null || cuentaIds.isEmpty()) {
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
                update cuentasMap.values(); 
        }
    }
}