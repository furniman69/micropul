# 🎴 Micropul - Godot Game

Micropul es una implementación del juego de mesa para 2 jugadores *Micropul*, desarrollado con Godot Engine 4.4. El proyecto simula la colocación de losetas sobre una cuadrícula con reglas específicas de emparejamiento y conexión.

## 🧩 Características

- Motor: **Godot 4.4**
- Juego por turnos para 2 jugadores
- Tablero interactivo con fichas que se arrastran y rotan
- Validación automática de posiciones válidas
- UI de selección de fichas en mano
- Fichas con propiedades especiales: *micropuls* (colores) y *catalizadores*

## 🚀 Cómo ejecutar

1. Descarga o clona el repositorio.
2. Abre la carpeta `Micropul` con Godot 4.4.
3. Ejecuta la escena principal: `main.tscn`.

## 📁 Estructura

```
Micropul/
├── main.gd                # Lógica principal del juego
├── tile.gd                # Script para cada loseta
├── TileLibrary.gd         # Base de datos de losetas
├── tile_preview.gd        # Vista previa para la mano
├── *.tscn                 # Escenas (main, tile, preview)
├── tiles/                 # Imágenes de losetas
```

## 🛠️ Créditos

Juego de mesa original: [Jean-François Lassonde](https://boardgamegeek.com/boardgame/10345/micropul)

Implementación Godot: desarrollada por Jordi Fornaguera aka furniman

## 📜 Licencia

Este proyecto es libre. Puedes modificarlo y distribuirlo, pero por favor acredita al creador original del juego.