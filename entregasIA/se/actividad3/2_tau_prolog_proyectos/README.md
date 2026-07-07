# Sistema experto de proyectos (Tau-Prolog)

Este proyecto implementa un sistema experto con Tau-Prolog para controlar la asignación de proyectos según niveles de programadores.

## Incluye

- 10 desarrolladores ficticios con niveles: `junior`, `avanzado`, `senior`
- 10 proyectos ficticios con niveles: `bajo`, `medio`, `alto`, `muy_alto`
- reglas de requerimientos por nivel de proyecto
- consultas para:
  1. listar desarrolladores con nivel
  2. listar proyectos con nivel
  3. validar si existe personal suficiente para un proyecto
  4. calcular qué personal falta contratar

## Estructura

- `proyectos_tau.pl`: base de conocimiento y reglas
- `index.html`: interfaz simple en navegador con Tau-Prolog

## Cómo ejecutar

Puede abrir `index.html` directamente en navegador. Si el navegador bloquea el `fetch` local, use un servidor estático:

```bash
python3 -m http.server 8000
```

Luego abra `http://localhost:8000` y entre a la carpeta del proyecto.

## Consultas Prolog útiles

- `desarrollador_con_nivel(Nombre, Nivel).`
- `proyecto_con_nivel(Codigo, Nivel).`
- `personal_disponible_para(d).`
- `faltante_para(d, FS, FA, FJ).`
