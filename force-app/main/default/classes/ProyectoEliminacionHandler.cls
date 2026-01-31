/**
 * Handler que valida la eliminación de proyectos.
 * Solo permite eliminar proyectos en estado "Planeado"
 * cuya fecha de inicio sea mayor a un año.
 */
public with sharing class ProyectoEliminacionHandler {
  /**
   * Valida si los proyectos pueden ser eliminados.
   * Solo permite eliminar proyectos en estado "Planeado"
   * cuya fecha de inicio sea anterior a un año.
   *
   * Se ejecuta en contexto before delete.
   *
   * @param proyectos Lista de proyectos a validar
   */
  public static void validarEliminacionProyectos(List<Proyecto__c> proyectos) {
    Date hoy = Date.today();
    Date haceUnAnio = hoy.addYears(-1);

    for (Proyecto__c proy : proyectos) {
      // Solo aplica a proyectos Planeados
      if (proy.Estado__c != 'Planeado') {
        proy.addError(
          'No se puede eliminar el proyecto "' +
            proy.Name +
            '" porque solo se permiten eliminar proyectos en estado Planeado.'
        );
        continue;
      }

      // Debe tener fecha de inicio
      if (proy.Fecha_de_Inicio__c == null) {
        proy.addError(
          'No se puede eliminar el proyecto "' +
            proy.Name +
            '" porque no tiene fecha de inicio definida.'
        );
        continue;
      }

      // Debe ser anterior a hace un año
      if (proy.Fecha_de_Inicio__c > haceUnAnio) {
        proy.addError(
          'No se puede eliminar el proyecto "' +
            proy.Name +
            '". Solo se pueden eliminar proyectos planeados ' +
            'que deberían haber iniciado hace más de un año ' +
            '(Fecha planeada: ' +
            proy.Fecha_de_Inicio__c +
            ').'
        );
      }
    }
  }
}
