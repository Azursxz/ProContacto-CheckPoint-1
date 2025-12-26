@istest
public class ProyectoContactoHandlerTest {
    @IsTest
    static void testActualizarDescripcionContactos() {

        Account cuenta = new Account(Name = 'Test');
        insert cuenta;
        
        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;
        
        Set<Id> contactoIds = new Set<Id>{contacto.Id};
        
        // Crear proyecto con presupuesto > 50000
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta.Id,
            Presupuesto__c = 60000,  // > 50000
            Estado__c = 'En Progreso',
            Contacto__c = contacto.Id
        );
        insert proyecto;
        
        Test.startTest();
        
        
        ProyectoContactoHandler.actualizarDescripcionContactos(contactoIds);
        Test.stopTest();
        
        Contact result = [SELECT Descripcion__c FROM Contact WHERE Id = :contacto.Id];
        System.assert(result.Descripcion__c.contains('presupuesto alto'));
    }

    @IsTest
    static void testActualizarDescripcionContactosVacio() {
        // Contacto sin proyectos
        Account cuenta = new Account(Name = 'Test');
        insert cuenta;
        
        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;
        
        Set<Id> contactoIds = new Set<Id>{contacto.Id};
        
        Test.startTest();
        
        ProyectoContactoHandler.actualizarDescripcionContactos(contactoIds);
        Test.stopTest();
        
        Contact result = [SELECT Descripcion__c FROM Contact WHERE Id = :contacto.Id];
        System.assertEquals('NO tiene un proyecto con alto presupuesto.', result.Descripcion__c);
    }
}