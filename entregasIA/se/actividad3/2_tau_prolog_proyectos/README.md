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
- `server.js`: servidor estático en Node.js
- `package.json`: script de ejecución (`npm start`)

## Cómo ejecutar (JavaScript completo)

Este proyecto ahora se ejecuta con **Node.js**, sin usar Python.

1. Entrar a la carpeta del proyecto:

```bash
cd entregasIA/se/actividad3/2_tau_prolog_proyectos
```

2. Iniciar servidor estático con npm:

```bash
npm start
```

3. Abrir en navegador:

- `http://localhost:8000`

> Si desea cambiar el puerto:
>
> ```bash
> PORT=9000 npm start
> ```

## Consultas Prolog útiles

- `desarrollador_con_nivel(Nombre, Nivel).`
- `proyecto_con_nivel(Codigo, Nivel).`
- `personal_disponible_para(d).`
- `faltante_para(d, FS, FA, FJ).`
