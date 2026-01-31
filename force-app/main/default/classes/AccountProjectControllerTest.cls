/**
 * @description
 * Clase de test para validar los métodos del controlador
 * AccountProjectController.
 *
 * Se cubren los siguientes métodos:
 * - getAccount
 * - getAccountSummary
 * - getProjects
 * - deleteProject
 *
 * Los tests verifican tanto el correcto funcionamiento
 * como la integridad de los datos retornados o modificados.
 */
@IsTest
public class AccountProjectControllerTest {
  /**
   * @description
   * Método @TestSetup que crea los datos base compartidos
   * por todos los métodos de test.
   *
   * - Crea un usuario de prueba para ejecutar los métodos con System.runAs
   * - Crea una cuenta base
   * - Crea un contacto asociado a la cuenta
   *
   * Estos datos se reutilizan en todos los escenarios de test.
   */
  @TestSetup
  static void setupData() {
    // Usuario de prueba
    List<Profile> p = [
      SELECT Id
      FROM Profile
      WHERE Id = :UserInfo.getProfileId()
    ];
    User u = new User(
      Alias = 'standt',
      Email = 'standarduser@testorg.com',
      EmailEncodingKey = 'UTF-8',
      LastName = 'Testing',
      LanguageLocaleKey = 'en_US',
      LocaleSidKey = 'en_US',
      ProfileId = p[0].Id,
      TimeZoneSidKey = 'America/Los_Angeles',
      UserName = 'unique' + System.currentTimeMillis() + '@testorg.com'
    );
    insert u;

    System.runAs(u) {
      Account acc = new Account(Name = 'Test');

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
   * Verifica que el método getAccount retorne correctamente
   * la cuenta solicitada.
   *
   * Escenario:
   * - Se solicita una cuenta existente por Id
   *
   * Resultado esperado:
   * - El método retorna un objeto Account no nulo
   * - El Id y el Name coinciden con la cuenta creada
   */
  @IsTest
  static void testGetAccount() {
    List<User> u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
    Assert.areEqual(1, u.size(), 'Debería existir el usuario de prueba');

    System.runAs(u[0]) {
      List<Account> cuenta = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test'
        LIMIT 1
      ];
      Test.startTest();
      Account result = AccountProjectController.getAccount(cuenta[0].Id);
      Test.stopTest();
      Assert.areNotEqual(null, result, 'La cuenta no debería ser null');
      Assert.areEqual(cuenta[0].Id, result.Id, 'El ID debería coincidir');
      Assert.areEqual('Test', result.Name, 'El nombre debería coincidir');
    }
  }
  /**
   * @description
   * Verifica el método getAccountSummary, el cual devuelve
   * un resumen de los proyectos asociados a una cuenta.
   *
   * Escenario:
   * - Dos proyectos finalizados asociados a la cuenta
   * - Presupuestos y recursos definidos
   *
   * Resultado esperado:
   * - El mapa contiene los totales correctos:
   *   - totalBudget = suma de Presupuesto__c
   *   - totalResources = suma de Recursos__c
   */

  @IsTest
  static void testGetAccountSummary() {
    List<User> u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
    Assert.areEqual(1, u.size(), 'Debería existir el usuario de prueba');

    System.runAs(u[0]) {
      List<Account> cuenta = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test'
        LIMIT 1
      ];
      List<Contact> contacto = [
        SELECT Id
        FROM Contact
        WHERE AccountId = :cuenta[0].Id
        LIMIT 1
      ];
      Proyecto__c proyecto1 = new Proyecto__c(
        Name = 'Proyecto 1',
        Account__c = cuenta[0].Id,
        Contacto__c = contacto[0].Id,
        Presupuesto__c = 5000,
        Estado__c = 'Finalizado',
        Recursos__c = 5
      );
      Proyecto__c proyecto2 = new Proyecto__c(
        Name = 'Proyecto 2',
        Account__c = cuenta[0].Id,
        Contacto__c = contacto[0].Id,
        Presupuesto__c = 8000,
        Estado__c = 'Finalizado',
        Recursos__c = 3
      );
      insert new List<Proyecto__c>{ proyecto1, proyecto2 };
      Test.startTest();
      Map<String, Decimal> result = AccountProjectController.getAccountSummary(
        cuenta[0].Id
      );
      Test.stopTest();
      Assert.areNotEqual(null, result, 'El resultado no debería ser null');
      Assert.areEqual(2, result.size(), 'Debería tener 2 valores en el mapa');
      Assert.areEqual(
        13000,
        result.get('totalBudget'),
        'Total budget debería ser 13000'
      );
      Assert.areEqual(
        8,
        result.get('totalResources'),
        'Total recursos debería ser 8'
      );
    }
  }
  /**
   * @description
   * Verifica que el método getProjects retorne la lista
   * de proyectos asociados a una cuenta.
   *
   * Escenario:
   * - Se crean múltiples proyectos para la misma cuenta
   *
   * Resultado esperado:
   * - El método retorna una lista no nula
   * - La cantidad de proyectos retornados es correcta
   */
  @IsTest
  static void testGetProjects() {
    List<User> u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
    Assert.areEqual(1, u.size(), 'Debería existir el usuario de prueba');

    System.runAs(u[0]) {
      List<Account> cuenta = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test'
        LIMIT 1
      ];
      List<Contact> contacto = [
        SELECT Id
        FROM Contact
        WHERE AccountId = :cuenta[0].Id
        LIMIT 1
      ];
      List<Proyecto__c> proyectos = new List<Proyecto__c>();
      proyectos.add(
        new Proyecto__c(
          Name = 'Proyecto Test 1',
          Account__c = cuenta[0].Id,
          Presupuesto__c = 5000,
          Estado__c = 'En Progreso',
          Contacto__c = contacto[0].Id
        )
      );
      proyectos.add(
        new Proyecto__c(
          Name = 'Proyecto Test 2',
          Account__c = cuenta[0].Id,
          Presupuesto__c = 10000,
          Estado__c = 'Finalizado',
          Contacto__c = contacto[0].Id
        )
      );
      insert proyectos;
      Test.startTest();
      List<Map<String, Object>> result = AccountProjectController.getProjects(
        cuenta[0].Id
      );
      Test.stopTest();
      Assert.areNotEqual(null, result, 'El resultado no debe ser nulo');
      Assert.areEqual(2, result.size(), 'Debe haber 2 proyectos');
    }
  }
  /**
   * @description
   * Verifica que el método deleteProject no elimine
   * un proyecto existente si este no es Planeado
   * y esta hace mas de 1 año.
   *
   * Escenario:
   * - Se crea un proyecto asociado a una cuenta
   * - Se invoca el método deleteProject con su Id
   *
   * Resultado esperado:
   * - El proyecto no se elimina de la base de datos
   */
  @IsTest
  static void testDeleteProject() {
    List<User> u = [SELECT Id FROM User WHERE Alias = 'standt' LIMIT 1];
    Assert.areEqual(1, u.size(), 'Debería existir el usuario de prueba');

    System.runAs(u[0]) {
      List<Account> cuenta = [
        SELECT Id
        FROM Account
        WHERE Name = 'Test'
        LIMIT 1
      ];
      List<Contact> contacto = [
        SELECT Id
        FROM Contact
        WHERE AccountId = :cuenta[0].Id
        LIMIT 1
      ];

      Proyecto__c proyecto = new Proyecto__c(
        Name = 'Proyecto Test',
        Account__c = cuenta[0].Id,
        Presupuesto__c = 5000,
        Estado__c = 'En Progreso',
        Contacto__c = contacto[0].Id
      );
      insert proyecto;
      List<Proyecto__c> proyectosAntes = [
        SELECT Id
        FROM Proyecto__c
        WHERE Id = :proyecto.Id
      ];
      Assert.areEqual(
        1,
        proyectosAntes.size(),
        'Debería existir 1 proyecto antes'
      );
      Test.startTest();
      try {
        AccountProjectController.deleteProject(proyecto.Id);
        System.assert(
          false,
          'Se esperaba una excepción al eliminar el proyecto'
        );
      } catch (DmlException e) {
        System.assert(
          e.getMessage()
            .contains('solo se permiten eliminar proyectos en estado Planeado'),
          'El mensaje de error no es el esperado'
        );
      }
      Test.stopTest();
      List<Proyecto__c> proyectosDespues = [
        SELECT Id
        FROM Proyecto__c
        WHERE Id = :proyecto.Id
      ];
      Assert.areEqual(
        1,
        proyectosDespues.size(),
        'El proyecto no debería estar eliminado'
      );
    }
  }
}
