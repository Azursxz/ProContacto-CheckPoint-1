/**
 * @description
 * Clase de test para validar la actualización de la descripción
 * de contactos en función de los proyectos asociados.
 *
 * Se verifica el comportamiento del método
 * ProyectoContactoHandler.actualizarDescripcionContactos,
 * el cual evalúa si un contacto tiene proyectos
 * con presupuesto alto.
 */
@IsTest
public class ProyectoContactoHandlerTest {
/**
 * @description
 * Método @TestSetup que crea los datos base compartidos
 * por todos los métodos de test.
 *
 * - Crea un usuario de prueba para ejecutar los tests con System.runAs
 * - Crea una cuenta base
 * - Crea un contacto asociado a la cuenta
 *
 * Estos datos se reutilizan en todos los escenarios.
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
 * Verifica que la descripción del contacto se actualice
 * correctamente cuando existe al menos un proyecto
 * en estado "En Progreso" con presupuesto alto (> 50000).
 *
 * Escenario:
 * - Contacto con un proyecto asociado
 * - Presupuesto del proyecto mayor a 50000
 *
 * Resultado esperado:
 * - El campo Descripcion__c del contacto contiene
 *   el texto "presupuesto alto".
 */
    @IsTest
    static void testActualizarDescripcionContactos() {
        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        Set<Id> contactoIds = new Set<Id>{contacto[0].Id};
        // Crear proyecto con presupuesto > 50000
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta[0].Id,
            Presupuesto__c = 60000,  // > 50000
            Estado__c = 'En Progreso',
            Contacto__c = contacto[0].Id
        );
        insert proyecto;
        Test.startTest();
        ProyectoContactoHandler.actualizarDescripcionContactos(contactoIds);
        Test.stopTest();
        List<Contact> result = [SELECT Descripcion__c FROM Contact WHERE Id = :contacto[0].Id];
        Assert.isTrue(
    result[0].Descripcion__c.contains('presupuesto alto'),
    'La descripción debería contener "presupuesto alto"');
    }
}
/**
 * @description
 * Verifica el comportamiento del método cuando el contacto
 * NO tiene proyectos asociados con presupuesto alto.
 *
 * Escenario:
 * - Contacto sin proyectos que cumplan la condición
 *
 * Resultado esperado:
 * - El campo Descripcion__c del contacto se establece en:
 *   "NO tiene un proyecto con alto presupuesto."
 */
    @IsTest
    static void testActualizarDescripcionContactosVacio() {
         // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        Set<Id> contactoIds = new Set<Id>{contacto[0].Id};
        Test.startTest();
        ProyectoContactoHandler.actualizarDescripcionContactos(contactoIds);
        Test.stopTest();
       List<Contact> result = [SELECT Descripcion__c FROM Contact WHERE Id = :contacto[0].Id];
        Assert.areEqual('NO tiene un proyecto con alto presupuesto.', result[0].Descripcion__c);
    }
}
}