@IsTest
public class ProyectoPresupuestoPromedioTest {
    @IsTest
    static void testCalcularPromedioBasico() {
        // Crear una cuenta
        Account cuenta = new Account(Name = 'Test');
        insert cuenta;
        Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
        insert contacto;
        // Crear un proyecto en progreso con presupuesto
        List<Proyecto__c> proyectos = new List<Proyecto__c>();
        proyectos.add(new Proyecto__c(
            Name = 'P1',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id, // Asignar contacto válido
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso',
            Fecha_de_Inicio__c = Date.today()
        ));
        proyectos.add(new Proyecto__c(
            Name = 'P2',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id, // Asignar contacto válido
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso',
            Fecha_de_Inicio__c = Date.today()
        ));
        insert proyectos;
        Test.startTest();
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(proyectos);
        Test.stopTest();
        // Verificar
        Account accActualizada = [SELECT Promedio__c FROM Account WHERE Id = :cuenta.Id];
        System.assertEquals(5000, accActualizada.Promedio__c);
    }

@IsTest
static void testCalcularPromedioSinProyectos() {
    // Cuenta sin proyectos
    Account cuenta = new Account(Name = 'Test');
    insert cuenta;
    Contact contacto = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            AccountId = cuenta.Id
        );
    insert contacto;
     List<Proyecto__c> proyectos = new List<Proyecto__c>();
        // Este proyecto NO debe contar para el promedio
        proyectos.add(new Proyecto__c(
            Name = 'P_Cancelado',
            Account__c = cuenta.Id,
            Contacto__c = contacto.Id, // Asignar contacto válido
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado',
            Fecha_de_Inicio__c = Date.today()
        ));
        insert proyectos;
    Test.startTest();
    ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(proyectos);
    Test.stopTest();
    // Verificar que se estableció en 0
    Account accActualizada = [SELECT Promedio__c FROM Account WHERE Id = :cuenta.Id];
    System.assertEquals(0, accActualizada.Promedio__c);
}

 @IsTest
    static void testCalcularPromedioPresupuestoConNull() {
        Test.startTest();
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(null);
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(new List<Proyecto__c>());
        Test.stopTest();
        // Si llega acá sin excepción, el test es válido
        System.assert(true, 'El método debe retornar sin error cuando el Set es null');
    }

}