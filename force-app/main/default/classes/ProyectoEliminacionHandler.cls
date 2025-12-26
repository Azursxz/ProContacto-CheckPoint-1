public with sharing class ProyectoEliminacionHandler {
    public static void validarEliminacionProyectos(List<Proyecto__c> proyectos) {
        // Solo validar en contexto de DELETE antes de la operación
        if (Trigger.isDelete && Trigger.isBefore) {
            Date hoy = Date.today();
            Date haceUnAnio = hoy.addYears(-1);
            
            for (Proyecto__c proy : proyectos) {
                // Solo validar proyectos con estatus "Planeado"
                if (proy.Estado__c == 'Planeado') {
                    Date fechaReferencia = proy.Fecha_de_Inicio__c;
                                                 
                    if (fechaReferencia != null) {
                        // Verificar si la fecha de referencia es MÁS RECIENTE que hace un año
                        // (es decir, si NO ha pasado más de un año)
                        if (fechaReferencia > haceUnAnio) {
                            proy.addError('No se puede eliminar el proyecto "' + 
                                         proy.Name + 
                                         '". Solo se pueden eliminar proyectos planeados ' +
                                         'que deberían haber iniciado hace más de un año ' +
                                         '(Fecha planeada: ' + fechaReferencia + ').');
                        }
                    } else {
                        // Si no hay fecha de referencia
                        proy.addError('No se puede eliminar el proyecto "' + 
                                     proy.Name + 
                                     '" porque no tiene fecha de inicio definida.');
                    }
                }
            }
        }
    }
}