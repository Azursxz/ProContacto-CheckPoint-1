trigger ProyectoPresupuestoPromedioTrigger on Proyecto__c (after insert, after update, after delete, after undelete) {
if (Trigger.isAfter) {
        Set<Id> cuentaIds = new Set<Id>();
        
        // Recopilar IDs de cuenta afectados en todas las operaciones
        if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
            for (Proyecto__c proyecto : Trigger.new) {
                if (proyecto.Account__c != null) {
                    cuentaIds.add(proyecto.Account__c);
                }
             /*   // Si es update y cambió la cuenta, también actualizar la cuenta anterior
                // de echo es redundante ya que el otro proyecto tambien tendria que recalcular el promedio
                if (Trigger.isUpdate) {
                    Proyecto__c oldProyecto = Trigger.oldMap.get(proyecto.Id);
                    if (oldProyecto.Account__c != null && 
                        oldProyecto.Account__c != proyecto.Account__c) {
                        cuentaIds.add(oldProyecto.Account__c);
                    }
                }*/
            }
        }
        
        // Para delete
        if (Trigger.isDelete) {
            for (Proyecto__c proyecto : Trigger.old) {
                if (proyecto.Account__c != null) {
                    cuentaIds.add(proyecto.Account__c);
                }
            }
        }
        
        // Si hay cuentas afectadas, procesarlas
        if (!cuentaIds.isEmpty()) {
            ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(cuentaIds);
        }
    }
}