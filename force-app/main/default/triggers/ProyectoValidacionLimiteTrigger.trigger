trigger ProyectoValidacionLimiteTrigger on Proyecto__c (before insert, before update) {
 if (Trigger.isBefore) {
        ProyectoValidacionLimiteHandler.validarLimiteProyectosActivos(Trigger.new);
    }
}