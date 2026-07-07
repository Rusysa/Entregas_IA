# Sistema experto ISC (SWI-Prolog + servidor HTTP)

Este proyecto implementa un sistema experto para apoyar al alumno/tutor/gestor en la elección de materias, respetando:

- seriación (prerrequisitos)
- reglas de carga académica por rendimiento
- historial de intentos y calificaciones
- detección de baja por 3 reprobaciones
- detección de alto rendimiento (promedio >= 90)
- consulta de materias por semestre y área
- conteo de aspirantes para abrir curso

## Requisitos

- SWI-Prolog 8+

## Ejecución

```bash
swipl -q -l server.pl -g start
```

Servidor en `http://localhost:8080`.

## Endpoints

### Estado
- `GET /`

### Materias
- `GET /materias`
- `GET /materias?semestre=3`
- `GET /materias?area=programacion`

### Alumnos
- `GET /alumnos`
- `GET /alumnos/alto_rendimiento`

### Historial y reglas por alumno
- `GET /alumno/{id}/historial`
- `GET /alumno/{id}/baja`
- `GET /alumno/{id}/recomendacion`

### Evaluar selección de materias
- `POST /alumno/{id}/elegir`

Body JSON de ejemplo:

```json
{
  "solicitud": ["mat2", "ia", "ing_sw"]
}
```

### Aspirantes para abrir curso
- `GET /materia/{clave}/aspirantes`

## Notas

- La calificación aprobatoria se considera `>= 70`.
- Si el promedio general es menor a 80 o tiene más de una reprobada actual, la carga máxima sugerida es de 4 materias.
- En caso contrario, la carga máxima sugerida es de 6 materias.
