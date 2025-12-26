trigger FechaEliminacionProyectoTrigger on Proyecto__c (before delete) {

    ProyectoEliminacionHandler.validarEliminacionProyectos(Trigger.old);

}