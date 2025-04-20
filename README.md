
# 🧩 Micropul2

**Micropul2** es una implementación del juego de colocación de fichas tipo puzle inspirada en patrones lógicos y colores, desarrollada con el motor **Godot 4**.

## 🎮 Características

- Sistema de fichas con colores (micropuls) y catalizadores.
- Validación dinámica de colocación según fichas adyacentes.
- Cuadrícula centrada y adaptativa al tamaño de la ventana.
- Feedback visual para errores de colocación.
- Rotación de fichas en tiempo real.
- Librería de fichas configuradas por datos (`TileLibrary.gd`).

## 🛠️ Estructura del Proyecto

```
Micropul2/
├── main.gd                 # Lógica del tablero y colocación de fichas
├── tile.gd                 # Lógica interna de cada ficha
├── TileLibrary.gd          # Base de datos de fichas disponibles
├── tile.tscn               # Escena de una ficha
├── main.tscn               # Escena principal del juego
├── project.godot           # Archivo de configuración del proyecto Godot
└── tiles/                  # Imágenes de fichas (tile_XX.png)
```

## ⌨️ Controles

- `R`: Rota la ficha seleccionada 90° en sentido horario.
- `Click Izquierdo`: Intenta colocar la ficha en la celda donde esté el mouse.

## 🚧 Requisitos

- **Godot 4.2 o superior** para ejecutar el proyecto correctamente.

## 📦 Instalación

1. Clona este repositorio o descarga el ZIP:
    ```bash
    git clone https://github.com/tu_usuario/Micropul2.git
    ```
2. Abre el proyecto en Godot.
3. Ejecuta la escena `main.tscn`.

## 📄 Licencia

Este proyecto está licenciado bajo la MIT License.

