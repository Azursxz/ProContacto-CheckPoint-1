@istest
public class ProyectoPresupuestoPromedioTest {
    
    @IsTest
    static void testCalcularPromedioBasico() {
        // Crear una cuenta
        Account cuenta = new Account(Name = 'Test');
        insert cuenta;
        
        Set<Id> cuentaIds = new Set<Id>{cuenta.Id};
        
        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;


        // Crear un proyecto en progreso con presupuesto
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id,
            Presupuesto__c = 6000,
            Estado__c = 'En Progreso'  
        );
        Proyecto__c proyecto1 = new Proyecto__c(
        Name = 'Test 1',
        Account__c = cuenta.Id,
        Contacto__c = contacto.Id,
        Presupuesto__c = 14000,
        Estado__c = 'En Progreso'  
        );
        insert new List<Proyecto__c>{proyecto1, proyecto};
        
        Test.startTest();
       
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(cuentaIds);
        Test.stopTest();
              
        // Verificar
        Account accActualizada = [SELECT Promedio__c FROM Account WHERE Id = :cuenta.Id];
        System.assertEquals(10000, accActualizada.Promedio__c);
    }

@IsTest
static void testCalcularPromedioSinProyectos() {
    // Cuenta sin proyectos
    Account cuenta = new Account(Name = 'Test');
    insert cuenta;
    
    Set<Id> cuentaIds = new Set<Id>{cuenta.Id};
    
    Test.startTest();
   
    ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(cuentaIds);
    Test.stopTest();
    
    // Verificar que se estableció en 0
    Account accActualizada = [SELECT Promedio__c FROM Account WHERE Id = :cuenta.Id];
    System.assertEquals(0, accActualizada.Promedio__c);
}

 @IsTest
    static void testCalcularPromedioPresupuesto_conNull() {
        Test.startTest();
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(null);
        Test.stopTest();

        // Si llega acá sin excepción, el test es válido
        System.assert(true, 'El método debe retornar sin error cuando el Set es null');
    }

}