/**
 * @description
 * Clase de test para validar la lógica de eliminación de proyectos.
 *
 * Se prueban las reglas de negocio relacionadas con:
 * - Proyectos planeados recientes que NO pueden eliminarse
 * - Proyectos no planeados que SÍ pueden eliminarse
 * - Proyectos planeados antiguos
 * - Proyectos sin fecha de inicio
 *
 * Esta clase cubre el comportamiento del handler/trigger
 * encargado de controlar la eliminación de registros Proyecto__c.
 */
@IsTest
public with sharing class ProyectoEliminacionHandlerTest {
/**
 * @description
 * Método @TestSetup que crea los datos base compartidos por todos los tests.
 *
 * - Crea un usuario de prueba para ejecutar los tests con System.runAs
 * - Crea una cuenta base
 * - Crea un contacto asociado a la cuenta
 *
 * Los datos creados aquí se reutilizan en todos los métodos
 * para mejorar performance y consistencia.
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
 * Verifica que un proyecto en estado "Planeado" con fecha de inicio reciente
 * (menor a un año) NO pueda ser eliminado.
 *
 * Escenario:
 * - Proyecto en estado "Planeado"
 * - Fecha de inicio = hoy
 *
 * Resultado esperado:
 * - Se lanza una excepción al intentar eliminar
 * - El proyecto permanece en la base de datos
 */
    @IsTest
    static void testNoEliminarPlaneadoReciente() {
        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        // Crear un proyecto en progreso con presupuesto
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id,
            Presupuesto__c = 50000,
            Estado__c = 'Planeado',
            Fecha_de_Inicio__c = Date.today()  // HOY (< 1 año)
        );
        insert proyecto;
        Test.startTest();
         try {
            delete proyecto;
            Assert.fail('Deberia fallar');
        } catch (Exception e) {
            String msg = e.getMessage();
             Assert.isTrue(
        msg.contains('No se puede eliminar'),
        'Mensaje inesperado: ' + msg);
        }
        Test.stopTest();

        List<Proyecto__c> listaResultado = [SELECT Id FROM Proyecto__c WHERE Id = :proyecto.Id];
        Assert.areEqual(1, listaResultado.size());
    }
}
/**
 * @description
 * Verifica que un proyecto cuyo estado NO sea "Planeado"
 * pueda eliminarse correctamente.
 *
 * Escenario:
 * - Proyecto en estado "Finalizado"
 *
 * Resultado esperado:
 * - El delete se ejecuta sin errores
 * - El proyecto se elimina de la base de datos
 */
    @IsTest
    static void testEliminarNoPlaneado() {
        // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        // Crear un proyecto en progreso con presupuesto
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id,
            Presupuesto__c = 5000,
            Estado__c = 'Finalizado',  // DIFERENTE de 'Planeado'
            Fecha_de_Inicio__c = Date.today()
        );
        insert proyecto;
        Test.startTest();
        // Esto deberia funcionar sin error
        delete proyecto;
        Test.stopTest();

        Assert.areEqual(0, [SELECT COUNT() FROM Proyecto__c WHERE Id = :proyecto.Id]);
    }
}
/**
 * @description
 * Verifica que un proyecto en estado "Planeado" con fecha de inicio
 * anterior a un año pueda eliminarse.
 *
 * Escenario:
 * - Proyecto en estado "Planeado"
 * - Fecha de inicio mayor a 1 año
 *
 * Resultado esperado:
 * - El proyecto se elimina correctamente
 *
 * Nota:
 * - Se utiliza un registro de bypass de validaciones
 *   para habilitar el escenario específico del test.
 */
    @IsTest
    static void testEliminarPlaneadoAntiguo() {
        // Activar bypass SOLO para este test
        Bypass_Validations__c bypass = new Bypass_Validations__c(
            SetupOwnerId = UserInfo.getOrganizationId(), //activa bypass a nivel org solo dentro del test
            Bypass__c = true
        );
        insert bypass;

         // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
        // Crear un proyecto en progreso con presupuesto
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test Antiguo',
            Account__c = cuenta[0].Id,
            Contacto__c = contacto[0].Id,
            Presupuesto__c = 5000,
            Estado__c = 'Planeado',
            Fecha_de_Inicio__c = Date.today().addYears(-1).addDays(-10)
        );
        insert proyecto;
        Test.startTest();
        delete proyecto;
        Test.stopTest();
        Assert.areEqual(0, [SELECT COUNT() FROM Proyecto__c WHERE Id = :proyecto.Id]);
    }
}
/**
 * @description
 * Verifica que un proyecto en estado "Planeado" sin fecha de inicio
 * NO pueda eliminarse.
 *
 * Escenario:
 * - Proyecto en estado "Planeado"
 * - Fecha_de_Inicio__c = null
 *
 * Resultado esperado:
 * - Se lanza una DmlException con un mensaje descriptivo
 * - El proyecto no se elimina de la base de datos
 */

    @IsTest
static void testNoEliminarSinFechaInicio() {
     // Create a user to run the test as, ensuring we avoid Mixed DML errors and satisfy best practices
        User u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];

        System.runAs(u) {

        // Crear una cuenta
       List<Account> cuenta = [SELECT Id FROM Account WHERE Name = 'Test' LIMIT 1];
       List<Contact> contacto = [SELECT Id FROM Contact WHERE AccountId = :cuenta[0].Id LIMIT 1];
    // Proyecto SIN Fecha_de_Inicio__c
    Proyecto__c proyecto = new Proyecto__c(
        Name = 'Proyecto Sin Fecha',
        Account__c = cuenta[0].Id,
        Contacto__c = contacto[0].Id,
        Presupuesto__c = 5000,
        Estado__c = 'Planeado'
    );
    insert proyecto;
    // Intentar eliminar
    Test.startTest();
        try {
        delete proyecto;
        Assert.fail('Debería lanzar error por no tener fecha de inicio');
    } catch (DmlException e) {
        // Validar mensaje de error
        Assert.isTrue(
            e.getMessage().contains('no tiene fecha de inicio definida'),
            'El mensaje de error no es el esperado'
        );
    Test.stopTest();

    Assert.areEqual(1, [SELECT COUNT() FROM Proyecto__c WHERE Id = :proyecto.Id]);
  }
}
}
}