extends Node

# Lista de datos de fichas predefinidas. Cada ficha es un diccionario con:
# - id: identificador único de la ficha
# - micropuls: posiciones (Vector2i) con un color asociado ("white" o "black")
# - catalysts: propiedades especiales (símbolos como "+", ".", "*")
# - big: indica si la ficha es una de las cuatro especiales (bool)

var TILE_DATA := [
	{"id": 0, "micropuls": {Vector2i(0,0): "white"}, "catalysts": {}, "big": false},
	{"id": 1, "micropuls": {Vector2i(0,0): "black"}, "catalysts": {}, "big": false},
	{"id": 2, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "black"}, "catalysts": {Vector2i(0,1): "+"}, "big": false},
	{"id": 3, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "white"}, "catalysts": {Vector2i(0,1): "+"}, "big": false},
	{"id": 4, "micropuls": {Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,0): "+"}, "big": false},
	{"id": 5, "micropuls": {Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,0): "+"}, "big": false},
	{"id": 6, "micropuls": {Vector2i(0,0): "white"}, "catalysts": {Vector2i(1,1): "."}, "big": false},
	{"id": 7, "micropuls": {Vector2i(0,0): "black"}, "catalysts": {Vector2i(1,1): "."}, "big": false},
	{"id": 8, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "black"}, "catalysts": {Vector2i(1,1): "."}, "big": false},
	{"id": 9, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "white"}, "catalysts": {Vector2i(1,1): "."}, "big": false},
	{"id": 10, "micropuls": {Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,0): "."}, "big": false},
	{"id": 11, "micropuls": {Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,0): "."}, "big": false},
	{"id": 12, "micropuls": {Vector2i(0,0): "white"}, "catalysts": {Vector2i(0,1): "."}, "big": false},
	{"id": 13, "micropuls": {Vector2i(0,0): "black"}, "catalysts": {Vector2i(0,1): "."}, "big": false},
	{"id": 14, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white"}, "catalysts": {Vector2i(1,1): "."}, "big": false},
	{"id": 15, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black"}, "catalysts": {Vector2i(1,1): "."}, "big": false},
	{"id": 16, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,1): "."}, "big": false},
	{"id": 17, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,1): "."}, "big": false},
	{"id": 18, "micropuls": {Vector2i(0,0): "white"}, "catalysts": {Vector2i(0,1): "+"}, "big": false},
	{"id": 19, "micropuls": {Vector2i(0,0): "black"}, "catalysts": {Vector2i(0,1): "+"}, "big": false},
	{"id": 20, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white"}, "catalysts": {Vector2i(0,1): "*"}, "big": false},
	{"id": 21, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black"}, "catalysts": {Vector2i(0,1): "*"}, "big": false},
	{"id": 22, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,1): "*"}, "big": false},
	{"id": 23, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,1): "*"}, "big": false},
	{"id": 24, "micropuls": {Vector2i(0,0): "white"}, "catalysts": {Vector2i(1,0): ".", Vector2i(1,1): "."}, "big": false},
	{"id": 25, "micropuls": {Vector2i(0,0): "black"}, "catalysts": {Vector2i(1,0): ".", Vector2i(1,1): "."}, "big": false},
	{"id": 26, "micropuls": {Vector2i(0,0): "white", Vector2i(1,1): "white"}, "catalysts": {}, "big": false},
	{"id": 27, "micropuls": {Vector2i(0,0): "black", Vector2i(1,1): "black"}, "catalysts": {}, "big": false},
	{"id": 28, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "black"}, "catalysts": {}, "big": false},
	{"id": 29, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "white"}, "catalysts": {}, "big": false},
	{"id": 30, "micropuls": {Vector2i(0,0): "white"}, "catalysts": {Vector2i(1,0): "*", Vector2i(1,1): "."}, "big": false},
	{"id": 31, "micropuls": {Vector2i(0,0): "black"}, "catalysts": {Vector2i(1,0): "*", Vector2i(1,1): "."}, "big": false},
	{"id": 32, "micropuls": {Vector2i(0,0): "white", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,1): "."}, "big": false},
	{"id": 33, "micropuls": {Vector2i(0,0): "black", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,1): "."}, "big": false},
	{"id": 34, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "white"}, "catalysts": {}, "big": false},
	{"id": 35, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "black"}, "catalysts": {}, "big": false},
	{"id": 36, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,0): "+"}, "big": true},
	{"id": 37, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,0): "+"}, "big": true},
	{"id": 38, "micropuls": {Vector2i(0,0): "white", Vector2i(1,1): "white"}, "catalysts": {Vector2i(1,0): "+", Vector2i(0,1): "."}, "big": false},
	{"id": 39, "micropuls": {Vector2i(0,0): "black", Vector2i(1,1): "black"}, "catalysts": {Vector2i(1,0): "+", Vector2i(0,1): "."}, "big": false},
	{"id": 40, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(0,1): "black", Vector2i(1,1): "black"}, "catalysts": {}, "big": false},
	{"id": 41, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(0,1): "white", Vector2i(1,1): "white"}, "catalysts": {}, "big": false},
	{"id": 42, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "white"}, "catalysts": {Vector2i(0,0): "."}, "big": true},
	{"id": 43, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "black"}, "catalysts": {Vector2i(0,0): "."}, "big": true},
	{"id": 44, "micropuls": {Vector2i(0,0): "white", Vector2i(1,1): "black"}, "catalysts": {Vector2i(1,0): ".", Vector2i(0,1): "."}, "big": false},
	{"id": 45, "micropuls": {Vector2i(0,0): "black", Vector2i(1,1): "white"}, "catalysts": {Vector2i(1,0): ".", Vector2i(0,1): "."}, "big": false},
	{"id": 46, "micropuls": {Vector2i(0,0): "white", Vector2i(1,0): "white", Vector2i(0,1): "white", Vector2i(1,1): "white"}, "catalysts": {}, "big": false},
	{"id": 47, "micropuls": {Vector2i(0,0): "black", Vector2i(1,0): "black", Vector2i(0,1): "black", Vector2i(1,1): "black"}, "catalysts": {}, "big": false},
]
