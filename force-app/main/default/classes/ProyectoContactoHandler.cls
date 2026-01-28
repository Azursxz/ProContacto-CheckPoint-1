/**
 * Handler que actualiza la descripción de los contactos según
 * si poseen proyectos en progreso con presupuesto mayor a 50000.
 */
public with sharing class ProyectoContactoHandler {
      /**
     * Actualiza el campo Descripcion__c de los contactos asociados a los proyectos recibidos.
     * Sobrecarga para aceptar List<Proyecto__c> directamente desde el trigger.
     *
     * @param proyectos Lista de proyectos (Trigger.new)
     */
    public static void actualizarDescripcionContactos(List<Proyecto__c> proyectos) {
        if (proyectos == null || proyectos.isEmpty()) {
            return;
        }
        Set<Id> contactoIds = new Set<Id>();
        for (Proyecto__c p : proyectos) {
            if (p.Contacto__c != null) {
                contactoIds.add(p.Contacto__c);
            }
        }
        if (!contactoIds.isEmpty()) {
            actualizarDescripcionContactos(contactoIds);
        }
    }

    /**
     * Actualiza el campo Descripcion__c de los contactos recibidos.
     * - Si el contacto tiene al menos un proyecto con presupuesto alto,
     *   se indica en la descripción.
     * - Caso contrario, se informa que no posee proyectos de alto presupuesto.
     *
     * @param contactoIds Conjunto de Ids de Contact a procesar
     */
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
            with USER_MODE
        ]) {
            contactoConProyectoAlto.put(proyecto.Contacto__c, true);
        }
        /* 3. Preparar actualización de contactos*/
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
            Database.update(contactosAActualizar,AccessLevel.USER_MODE);
            //update contactosAActualizar;
        }
    }
}