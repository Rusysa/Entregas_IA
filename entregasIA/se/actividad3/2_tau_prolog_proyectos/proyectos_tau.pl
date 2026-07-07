% ----------------------------------
% Sistema experto en Tau-Prolog
% Control de asignacion de proyectos
% ----------------------------------

% desarrollador(Nombre, Nivel).
desarrollador(ana, junior).
desarrollador(bruno, avanzado).
desarrollador(carla, senior).
desarrollador(diego, avanzado).
desarrollador(elena, junior).
desarrollador(fernando, senior).
desarrollador(gabriela, avanzado).
desarrollador(hector, junior).
desarrollador(irene, avanzado).
desarrollador(jorge, senior).

% proyecto(Codigo, Nivel).
proyecto(a, bajo).
proyecto(b, medio).
proyecto(c, alto).
proyecto(d, muy_alto).
proyecto(e, bajo).
proyecto(f, medio).
proyecto(g, alto).
proyecto(h, muy_alto).
proyecto(i, medio).
proyecto(j, bajo).

% requerimiento_nivel(NivelProyecto, CantSenior, CantAvanzado, CantJunior).
requerimiento_nivel(bajo, 0, 1, 1).
requerimiento_nivel(medio, 1, 1, 0).
requerimiento_nivel(alto, 1, 1, 1).
requerimiento_nivel(muy_alto, 1, 2, 2).

% ------------------------------
% Listados
% ------------------------------

desarrollador_con_nivel(Nombre, Nivel) :-
    desarrollador(Nombre, Nivel).

proyecto_con_nivel(Codigo, Nivel) :-
    proyecto(Codigo, Nivel).

% ------------------------------
% Conteos disponibles
% ------------------------------

contar_senior(Count) :-
    findall(N, desarrollador(N, senior), L),
    contar_lista(L, Count).

contar_avanzado(Count) :-
    findall(N, desarrollador(N, avanzado), L),
    contar_lista(L, Count).

contar_junior(Count) :-
    findall(N, desarrollador(N, junior), L),
    contar_lista(L, Count).

contar_lista([], 0).
contar_lista([_|T], Count) :-
    contar_lista(T, C1),
    Count is C1 + 1.

% ------------------------------
% Evaluacion de capacidad
% ------------------------------

personal_disponible_para(Proyecto) :-
    proyecto(Proyecto, Nivel),
    requerimiento_nivel(Nivel, ReqS, ReqA, ReqJ),
    contar_senior(S),
    contar_avanzado(A),
    contar_junior(J),
    S >= ReqS,
    A >= ReqA,
    J >= ReqJ.

faltante_para(Proyecto, FaltanteSenior, FaltanteAvanzado, FaltanteJunior) :-
    proyecto(Proyecto, Nivel),
    requerimiento_nivel(Nivel, ReqS, ReqA, ReqJ),
    contar_senior(S),
    contar_avanzado(A),
    contar_junior(J),
    diff_no_negativo(ReqS, S, FaltanteSenior),
    diff_no_negativo(ReqA, A, FaltanteAvanzado),
    diff_no_negativo(ReqJ, J, FaltanteJunior).

diff_no_negativo(Requerido, Disponible, 0) :-
    Disponible >= Requerido, !.
diff_no_negativo(Requerido, Disponible, Faltante) :-
    Faltante is Requerido - Disponible.

% Regla util para consulta directa
% ?- personal_faltante_detalle(d, Lista).
personal_faltante_detalle(Proyecto, Lista) :-
    faltante_para(Proyecto, FS, FA, FJ),
    Lista = [senior-FS, avanzado-FA, junior-FJ].
