trigger ProyectoContactoTrigger on Proyecto__c (after insert, after update, after delete, after undelete) {

 if (Trigger.isAfter) {
        Set<Id> contactoIds = new Set<Id>();
        
         if (Trigger.isInsert || Trigger.isUpdate) {
            for (Proyecto__c proyecto : Trigger.new) {
                if (proyecto.Contacto__c != null) {
                    contactoIds.add(proyecto.Contacto__c);
                }
             /*   // IMPORTANTE: Si es update y cambió el contacto, también actualizar el viejo
                // es redundante
                if (Trigger.isUpdate) {
                    Proyecto__c oldProyecto = Trigger.oldMap.get(proyecto.Id);
                    if (oldProyecto.Contacto__c != null && 
                        oldProyecto.Contacto__c != proyecto.Contacto__c) {
                        contactoIds.add(oldProyecto.Contacto__c);
                    }
                }*/
            }
        }
        
        // Para delete, usar Trigger.old
        if (Trigger.isDelete) {
            for (Proyecto__c proyecto : Trigger.old) {
                if (proyecto.Contacto__c != null) {
                    contactoIds.add(proyecto.Contacto__c);
                }
            }
        }
        
        // Si hay contactos afectados, procesarlos
        if (!contactoIds.isEmpty()) {
            ProyectoContactoHandler.actualizarDescripcionContactos(contactoIds);
        }
    }

}