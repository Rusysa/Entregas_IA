:- module(server, [start/0]).

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_parameters)).
:- use_module(library(lists)).

% -------------------------------
% Base de conocimientos (ISC)
% -------------------------------

% materia(Clave, Nombre, Semestre, Area, Prerequisitos).
materia(mat1, 'Matematicas 1', 1, ciencias_basicas, []).
materia(mat2, 'Matematicas 2', 2, ciencias_basicas, [mat1]).
materia(prog1, 'Programacion 1', 1, programacion, []).
materia(prog2, 'Programacion 2', 2, programacion, [prog1]).
materia(estructuras, 'Estructura de Datos', 3, programacion, [prog2]).
materia(bd1, 'Bases de Datos', 3, sistemas, [prog2]).
materia(so, 'Sistemas Operativos', 4, sistemas, [estructuras]).
materia(redes, 'Redes', 4, infraestructura, [so]).
materia(ia, 'Inteligencia Artificial', 5, especialidad, [estructuras, mat2]).
materia(ing_sw, 'Ingenieria de Software', 5, especialidad, [estructuras, bd1]).

% alumno(Id, Nombre).
alumno(a1, 'Ana Perez').
alumno(a2, 'Luis Gomez').
alumno(a3, 'Marta Ruiz').
alumno(a4, 'Carlos Diaz').
alumno(a5, 'Sofia Lopez').
alumno(a6, 'Diego Cruz').
alumno(a7, 'Elena Torres').
alumno(a8, 'Pablo Romero').
alumno(a9, 'Karla Jimenez').
alumno(a10, 'Rene Salas').

% cursadas(Alumno, Materia, [Calificaciones_por_intento]).
cursadas(a1, mat1, [95]).
cursadas(a1, mat2, [92]).
cursadas(a1, prog1, [94]).
cursadas(a1, prog2, [93]).
cursadas(a1, estructuras, [96]).
cursadas(a1, bd1, [91]).

cursadas(a2, mat1, [78]).
cursadas(a2, mat2, [65, 74]).
cursadas(a2, prog1, [82]).
cursadas(a2, prog2, [79]).
cursadas(a2, estructuras, [71]).

cursadas(a3, mat1, [60, 62, 64]).
cursadas(a3, prog1, [75]).

cursadas(a4, mat1, [88]).
cursadas(a4, mat2, [81]).
cursadas(a4, prog1, [83]).
cursadas(a4, prog2, [66]).
cursadas(a4, estructuras, [58]).

cursadas(a5, mat1, [99]).
cursadas(a5, mat2, [97]).
cursadas(a5, prog1, [95]).
cursadas(a5, prog2, [96]).
cursadas(a5, estructuras, [98]).
cursadas(a5, bd1, [95]).
cursadas(a5, so, [94]).

cursadas(a6, mat1, [72]).
cursadas(a6, prog1, [70]).
cursadas(a6, prog2, [55, 68]).

cursadas(a7, mat1, [85]).
cursadas(a7, mat2, [88]).
cursadas(a7, prog1, [90]).
cursadas(a7, prog2, [89]).
cursadas(a7, estructuras, [91]).
cursadas(a7, bd1, [92]).
cursadas(a7, so, [90]).

cursadas(a8, mat1, [69]).
cursadas(a8, prog1, [64]).

cursadas(a9, mat1, [80]).
cursadas(a9, mat2, [82]).
cursadas(a9, prog1, [79]).
cursadas(a9, prog2, [85]).
cursadas(a9, estructuras, [87]).

cursadas(a10, mat1, [91]).
cursadas(a10, mat2, [90]).
cursadas(a10, prog1, [93]).
cursadas(a10, prog2, [94]).
cursadas(a10, estructuras, [92]).
cursadas(a10, bd1, [90]).
cursadas(a10, so, [93]).
cursadas(a10, redes, [89]).

% -------------------------------
% Reglas del sistema experto
% -------------------------------

calificacion_actual(Alumno, Materia, Calif) :-
    cursadas(Alumno, Materia, Historial),
    last(Historial, Calif).

veces_cursada(Alumno, Materia, Veces) :-
    cursadas(Alumno, Materia, Historial),
    length(Historial, Veces).

aprobada(Alumno, Materia) :-
    cursadas(Alumno, Materia, Historial),
    member(C, Historial),
    C >= 70,
    !.

reprobada_actual(Alumno, Materia) :-
    calificacion_actual(Alumno, Materia, C),
    C < 70.

materias_reprobadas_actuales(Alumno, Cant) :-
    findall(M, reprobada_actual(Alumno, M), L),
    length(L, Cant).

promedio_general(Alumno, Promedio) :-
    findall(C, calificacion_actual(Alumno, _, C), Califs),
    Califs \= [],
    sum_list(Califs, Suma),
    length(Califs, N),
    Promedio is Suma / N,
    !.
promedio_general(_, 0).

prerequisitos_faltantes(Alumno, Materia, Faltantes) :-
    materia(Materia, _, _, _, Prereqs),
    findall(P, (member(P, Prereqs), \+ aprobada(Alumno, P)), Faltantes).

puede_cursar_materia(Alumno, Materia) :-
    materia(Materia, _, _, _, _),
    \+ aprobada(Alumno, Materia),
    prerequisitos_faltantes(Alumno, Materia, []),
    !.

max_carga(Alumno, 4) :-
    promedio_general(Alumno, Prom),
    ( Prom < 80 ; materias_reprobadas_actuales(Alumno, R), R > 1 ),
    !.
max_carga(_, 6).

de_baja(Alumno, Materia) :-
    cursadas(Alumno, Materia, Historial),
    length(Historial, Veces),
    Veces >= 3,
    forall(member(C, Historial), C < 70).

alto_rendimiento(Alumno) :-
    promedio_general(Alumno, P),
    P >= 90.

alumno_resumen(Alumno, Dict) :-
    alumno(Alumno, Nombre),
    promedio_general(Alumno, Prom),
    materias_reprobadas_actuales(Alumno, Repr),
    Dict = _{
        id: Alumno,
        nombre: Nombre,
        promedio_general: Prom,
        reprobadas_actuales: Repr
    }.

historial_materia_dict(Alumno, Materia, Dict) :-
    cursadas(Alumno, Materia, Historial),
    length(Historial, Veces),
    ( aprobada(Alumno, Materia) -> Aprob = @(true) ; Aprob = @(false) ),
    Dict = _{
        materia: Materia,
        veces_cursada: Veces,
        calificaciones: Historial,
        aprobada: Aprob
    }.

% -------------------------------
% Endpoints HTTP
% -------------------------------

:- http_handler(root(.), status_handler, []).
:- http_handler(root(materias), materias_handler, [method(get)]).
:- http_handler(root(alumnos), alumnos_handler, [method(get)]).
:- http_handler(root(alumnos/alto_rendimiento), alto_rendimiento_handler, [method(get)]).
:- http_handler(root(alumno/Alumno/historial), historial_handler(Alumno), [method(get)]).
:- http_handler(root(alumno/Alumno/baja), baja_handler(Alumno), [method(get)]).
:- http_handler(root(alumno/Alumno/recomendacion), recomendacion_handler(Alumno), [method(get)]).
:- http_handler(root(alumno/Alumno/elegir), elegir_handler(Alumno), [method(post)]).
:- http_handler(root(materia/Materia/aspirantes), aspirantes_handler(Materia), [method(get)]).

start :-
    Port = 8080,
    http_server(http_dispatch, [port(Port)]).

status_handler(_Request) :-
    reply_json_dict(_{estado: 'ok', servicio: 'sistema_experto_isc', puerto: 8080}).

materias_handler(Request) :-
    http_parameters(Request,
        [ semestre(Sem, [optional(true), integer]),
          area(Area, [optional(true), atom])
        ]),
    findall(_{
            clave: Clave,
            nombre: Nombre,
            semestre: Semestre,
            area: AreaM,
            prerequisitos: Prereqs
        },
        ( materia(Clave, Nombre, Semestre, AreaM, Prereqs),
          ( var(Sem) -> true ; Semestre =:= Sem ),
          ( var(Area) -> true ; AreaM == Area )
        ),
        Materias),
    reply_json_dict(_{materias: Materias}).

alumnos_handler(_Request) :-
    findall(D, (alumno(A, _), alumno_resumen(A, D)), Alumnos),
    reply_json_dict(_{alumnos: Alumnos}).

alto_rendimiento_handler(_Request) :-
    findall(_{id: A, nombre: N, promedio: P},
        (alumno(A, N), promedio_general(A, P), P >= 90),
        Lista),
    reply_json_dict(_{alto_rendimiento: Lista}).

historial_handler(Alumno, _Request) :-
    ( alumno(Alumno, Nombre) ->
        findall(D, historial_materia_dict(Alumno, _, D), Historial),
        reply_json_dict(_{id: Alumno, nombre: Nombre, historial: Historial})
    ; reply_json_dict(_{error: 'Alumno no encontrado'}, [status(404)])
    ).

baja_handler(Alumno, _Request) :-
    ( alumno(Alumno, Nombre) ->
        findall(M, de_baja(Alumno, M), MateriasBaja),
        ( MateriasBaja == [] -> Baja = @(false) ; Baja = @(true) ),
        reply_json_dict(_{
            id: Alumno,
            nombre: Nombre,
            debe_darse_baja: Baja,
            materias_causantes: MateriasBaja
        })
    ; reply_json_dict(_{error: 'Alumno no encontrado'}, [status(404)])
    ).

recomendacion_handler(Alumno, _Request) :-
    ( alumno(Alumno, Nombre) ->
        max_carga(Alumno, Max),
        findall(M, puede_cursar_materia(Alumno, M), Candidatas),
        reply_json_dict(_{
            id: Alumno,
            nombre: Nombre,
            carga_maxima_sugerida: Max,
            materias_recomendadas: Candidatas
        })
    ; reply_json_dict(_{error: 'Alumno no encontrado'}, [status(404)])
    ).

elegir_handler(Alumno, Request) :-
    ( \+ alumno(Alumno, _) ->
        reply_json_dict(_{error: 'Alumno no encontrado'}, [status(404)])
    ; http_read_json_dict(Request, Body),
      Solicitud = Body.get(solicitud),
      ( is_list(Solicitud) ->
          max_carga(Alumno, Max),
          length(Solicitud, N),
          Excede = (N > Max),
          findall(_{materia: M, permitida: Perm, razon: Razon},
              ( member(M, Solicitud),
                ( \+ materia(M, _, _, _, _) -> Perm = @(false), Razon = 'Materia inexistente'
                ; aprobada(Alumno, M) -> Perm = @(false), Razon = 'Ya aprobada'
                ; prerequisitos_faltantes(Alumno, M, F), F \= [] -> Perm = @(false), Razon = _{prerequisitos_faltantes: F}
                ; Perm = @(true), Razon = 'OK'
                )
              ),
              Evaluacion),
          reply_json_dict(_{
              alumno: Alumno,
              carga_maxima_permitida: Max,
              materias_solicitadas: N,
              excede_carga: @(Excede),
              evaluacion: Evaluacion
          })
      ; reply_json_dict(_{error: 'El campo solicitud debe ser lista'}, [status(400)])
      )
    ).

aspirantes_handler(Materia, _Request) :-
    ( \+ materia(Materia, _, _, _, _) ->
        reply_json_dict(_{error: 'Materia no encontrada'}, [status(404)])
    ; findall(A, (alumno(A, _), puede_cursar_materia(A, Materia)), Aspirantes),
      length(Aspirantes, Cantidad),
      reply_json_dict(_{materia: Materia, posibles_aspirantes: Cantidad, alumnos: Aspirantes})
    ).
