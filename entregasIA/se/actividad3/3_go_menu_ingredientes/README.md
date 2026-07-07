# Sistema experto de menú e ingredientes (Go)

Sistema experto para cocina que permite:

- consultar qué ingredientes lleva cada platillo
- validar si existen todos los ingredientes para un platillo
- obtener lista de ingredientes faltantes para un platillo dado

## Requisitos

- Go 1.22+

## Ejecutar

```bash
go run .
```

Servidor disponible en `http://localhost:8090`.

## Endpoints

- `GET /` estado del servicio
- `GET /dishes` lista de platillos
- `GET /dish/{id}/ingredients` ingredientes de un platillo
- `GET /dish/{id}/availability` disponibilidad de ingredientes y faltantes
- `GET /inventory` inventario actual

## Ejemplos

- `GET /dish/tacos_al_pastor/ingredients`
- `GET /dish/tacos_al_pastor/availability`
