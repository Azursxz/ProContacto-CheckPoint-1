trigger ProyectoTrigger on Proyecto__c (before insert, before update, before delete , after insert, after update, after delete, after undelete) {
     // --- BLOQUE BEFORE ---
    if (Trigger.isBefore) {
        // Validar límites solo en Insert y Update (donde existe Trigger.new y el proyecto está "vivo")
        if (Trigger.isInsert || Trigger.isUpdate) {
            ProyectoValidacionLimiteHandler.validarLimiteProyectosActivos(Trigger.new);
        }
        // Validar eliminación solo en Delete (usando Trigger.old)
        if (Trigger.isDelete) {
            ProyectoEliminacionHandler.validarEliminacionProyectos(Trigger.old);
        }
    }
    // --- BLOQUE AFTER ---
    if (Trigger.isAfter) {
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(Trigger.new);
        ProyectoContactoHandler.actualizarDescripcionContactos(Trigger.new);
    }
}