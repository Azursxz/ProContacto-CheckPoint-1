public with sharing class ProyectoValidacionLimiteHandler {
     public static void validarLimiteProyectosActivos(List<Proyecto__c> Proyectos) {
        Set<Id> cuentaIds = new Set<Id>();
                
        // 1. Recopilar IDs de cuenta
        for (Proyecto__c proyecto : Proyectos) {
            if (proyecto.Account__c != null && proyecto.Estado__c == 'En Progreso') {
                cuentaIds.add(proyecto.Account__c);
            }
        }
        
        if (cuentaIds.isEmpty()) return;
        
        // 2. Contar proyectos en proceso por cuenta
        Map<Id, Integer> conteoPorCuenta = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Account__c, COUNT(Id) total
            FROM Proyecto__c 
            WHERE Account__c IN :cuentaIds 
            AND Estado__c = 'En Progreso'
            GROUP BY Account__c
        ]) {
            Id cuentaId = (Id)ar.get('Account__c');
            Integer total = (Integer)ar.get('total');
            conteoPorCuenta.put(cuentaId, total);
        }
        
        // 3. Obtener límites de cuentas
        Map<Id, Account> cuentasMap = new Map<Id, Account>([
            SELECT Id, Maximo_Proyectos_Activos__c 
            FROM Account 
            WHERE Id IN :cuentaIds
        ]);
        
        // 4. Validar cada proyecto
        for (Proyecto__c proyecto : Proyectos) {
            if (proyecto.Account__c == null || proyecto.Estado__c != 'En Progreso') continue;
            
            Account cuenta = cuentasMap.get(proyecto.Account__c);
            if (cuenta == null || cuenta.Maximo_Proyectos_Activos__c == null) continue;
            
            Integer proyectosActuales = conteoPorCuenta.get(proyecto.Account__c) != null 
                ? conteoPorCuenta.get(proyecto.Account__c) 
                : 0;
            
            // Sumar 1 porque este proyecto también cuenta
            if (proyectosActuales + 1 > cuenta.Maximo_Proyectos_Activos__c) {
                proyecto.addError('Limite excedido. Maximo permitido: ' + cuenta.Maximo_Proyectos_Activos__c);
            }
        }
}
}
