public with sharing class ProyectoContactoHandler {
    
    public static void actualizarDescripcionContactos(Set<Id> contactoIds) {
     
       
        // 1. Inicializar todos como false
        Map<Id, Boolean> contactoConProyectoAlto = new Map<Id, Boolean>();
        for (Id contactoId : contactoIds) {
            contactoConProyectoAlto.put(contactoId, false);
        }

        // 2. Buscar TODOS los proyectos con presupuesto alto, y marcarlos como true
        for (Proyecto__c proyecto : [
            SELECT Contacto__c
            FROM Proyecto__c
            WHERE Contacto__c IN :contactoIds
            AND Presupuesto__c > 50000
        ]) {
            contactoConProyectoAlto.put(proyecto.Contacto__c, true);
        }

        // 3. Preparar actualización de contactos
        List<Contact> contactosAActualizar = new List<Contact>();

        for (Id contactoId : contactoIds) {
            String nuevaDescripcion = contactoConProyectoAlto.get(contactoId)
                ? 'Este contacto está asociado con un proyecto con presupuesto alto.'
                : 'NO tiene un proyecto con alto presupuesto.';

            contactosAActualizar.add(new Contact(
                Id = contactoId,
                Descripcion__c = nuevaDescripcion
            ));
        }

        // 4. Update
        if (!contactosAActualizar.isEmpty()) {
            update contactosAActualizar;
        }
    }
}