/**
 * @description
 * Clase de test para validar el cálculo del promedio de presupuesto
 * de proyectos activos por cuenta.
 *
 * Se prueban los siguientes escenarios:
 * - Cálculo correcto del promedio con proyectos en progreso
 * - Comportamiento cuando no hay proyectos válidos
 * - Manejo seguro de listas nulas o vacías
 *
 * Esta clase garantiza la cobertura del método
 * ProyectoPresupuestoPromedio.calcularPromedioPresupuesto.
 */
@IsTest
public class ProyectoPresupuestoPromedioTest {
/**
 * @description
 * Método @TestSetup que crea los datos base para los tests.
 *
 * - Crea un usuario de prueba para ejecutar los métodos con System.runAs
 * - Crea una cuenta base
 * - Crea un contacto asociado a la cuenta
 *
 * Los datos creados aquí son reutilizados por todos los tests.
 */
     @TestSetup
    static void setupData() {
        // Usuario de prueba
        Profile p = [SELECT Id FROM Profile WHERE Id = :UserInfo.getProfileId()];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'unique' + System.currentTimeMillis() + '@testorg.com'
        );
        insert u;

        System.runAs(u) {
            // Cuenta límite 1
            Account acc = new Account(
                Name = 'Test'
            );


            insert acc;

            Contact con = new Contact(
                FirstName = 'Test',
                LastName = 'Contact',
                AccountId = acc.Id
            );
            insert con;

        }
    }

/**
 * @description
 * Verifica el cálculo básico del promedio de presupuesto
 * cuando existen proyectos activos ("En Progreso").
 *
 * Escenario:
 * - Dos proyectos activos con presupuesto 5000 cada uno
 *
 * Resultado esperado:
 * - El campo Promedio__c de la cuenta se actualiza a 5000
 */
    @IsTest
    static void testCalcularPromedioBasico() {
        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        // Crear un proyecto en progreso con presupuesto
        List<Proyecto__c> proyectos = new List<Proyecto__c>();
        proyectos.add(new Proyecto__c(
            Name = 'P1',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id, // Asignar contacto válido
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso',
            Fecha_de_Inicio__c = Date.today()
        ));
        proyectos.add(new Proyecto__c(
            Name = 'P2',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id, // Asignar contacto válido
            Presupuesto__c = 5000,
            Estado__c = 'En Progreso',
            Fecha_de_Inicio__c = Date.today()
        ));
        insert proyectos;
        Test.startTest();
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(proyectos);
        Test.stopTest();
        // Verificar
        List<Account> accActualizada = [SELECT Promedio__c FROM Account WHERE Id = :cuenta[0].Id];
        Assert.areEqual(5000, accActualizada[0].Promedio__c);
    }
}
/**
 * @description
 * Verifica que los proyectos que NO están en estado "En Progreso"
 * no sean considerados para el cálculo del promedio.
 *
 * Escenario:
 * - Se crea un proyecto en estado "Finalizado"
 *
 * Resultado esperado:
 * - El promedio de presupuesto de la cuenta se establece en 0
 */
@IsTest
static void testCalcularPromedioSinProyectos() {
        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
        List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
        List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];

        List<Proyecto__c> proyectos = new List<Proyecto__c>();
        // Este proyecto NO debe contar para el promedio
        proyectos.add(new Proyecto__c(
            Name = 'P_Cancelado',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id, // Asignar contacto válido
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado',
            Fecha_de_Inicio__c = Date.today()
        ));
        insert proyectos;
    Test.startTest();
    ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(proyectos);
    Test.stopTest();
    // Verificar que se estableció en 0
    List<Account> accActualizada = [SELECT Promedio__c FROM Account WHERE Id = :cuenta[0].Id];
    Assert.areEqual(0, accActualizada[0].Promedio__c);
}
}
/**
 * @description
 * Verifica que el método calcularPromedioPresupuesto
 * maneje correctamente valores nulos o listas vacías
 * sin lanzar excepciones.
 *
 * Escenario:
 * - Se llama al método con null
 * - Se llama al método con una lista vacía
 *
 * Resultado esperado:
 * - El método finaliza sin errores
 */
 @IsTest
    static void testCalcularPromedioPresupuestoConNull() {

        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        Test.startTest();
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(null);
        ProyectoPresupuestoPromedio.calcularPromedioPresupuesto(new List<Proyecto__c>());
        Test.stopTest();
        // Si llega acá sin excepción, el test es válido
        Assert.isTrue(true, 'El método debe retornar sin error cuando el Set es null');
    }
}

}