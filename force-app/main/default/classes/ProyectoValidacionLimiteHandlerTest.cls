@istest
public class ProyectoValidacionLimiteHandlerTest {
    @IsTest
    static void testTriggerExcedeLimite() {
        // Crear cuenta con límite bajo
        Account cuenta = new Account(
            Name = 'Test Account',
            Maximo_Proyectos_Activos__c = 1  // Solo permite 1 proyecto
        );
        insert cuenta;

        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;
        
        // Crear primer proyecto (dentro del límite)
        Proyecto__c proyecto1 = new Proyecto__c(
            Name = 'Proyecto 1',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso'
        );
        insert proyecto1;  // Esto disparará el trigger
        
        // Crear segundo proyecto (excedería el límite)
        Proyecto__c proyecto2 = new Proyecto__c(
            Name = 'Proyecto 2',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso'
        );
        
         Boolean fallo = false;

        Test.startTest();
        try {
            insert proyecto2;
        } catch (DmlException e) {
            fallo = true;
            System.assert(
                e.getMessage().toLowerCase().contains('limite'),
                'Mensaje inesperado: ' + e.getMessage()
            );
        }
        Test.stopTest();

        System.assert(fallo, 'Debería haber fallado por límite excedido');

    }
    
    @IsTest
    static void testTriggerDentroLimite() {
        // Crear cuenta con límite
        Account cuenta = new Account(
            Name = 'Test Account',
            Maximo_Proyectos_Activos__c = 2
        );
        insert cuenta;

        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;
        
        // Crear primer proyecto
        Proyecto__c proyecto1 = new Proyecto__c(
            Name = 'Proyecto 1',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso'
        );
        insert proyecto1;
        
        // Crear segundo proyecto (dentro del límite)
        Proyecto__c proyecto2 = new Proyecto__c(
            Name = 'Proyecto 2',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso'
        );
        
        Test.startTest();
        // Esto debería funcionar
        insert proyecto2;
        Test.stopTest();
        
        // Verificar que ambos se crearon
        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Account__c = :cuenta.Id];
        System.assertEquals(2, proyectos.size(), 'Deberían existir 2 proyectos');
    }
    
    @IsTest
    static void testTriggerProyectoNoEnProceso() {
        // Cuenta con límite muy bajo
        Account cuenta = new Account(
            Name = 'Test Account',
            Maximo_Proyectos_Activos__c = 0  // Cero proyectos "En Proceso"
        );
        insert cuenta;

        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;
        
        // Crear proyecto con estado DIFERENTE (no debería contar)
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Proyecto Completado',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado'  // NO "En Proceso"
        );
        
        Test.startTest();
        // Esto debería funcionar aunque el límite sea 0
        insert proyecto;
        Test.stopTest();
        
        // Verificar que se creó
        List<Proyecto__c> proyectos = [SELECT Id FROM Proyecto__c WHERE Account__c = :cuenta.Id];
        System.assertEquals(1, proyectos.size(), 'Debería crearse el proyecto');
    }

}