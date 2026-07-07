package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"sort"
	"strings"
)

type Dish struct {
	Name        string   `json:"name"`
	Ingredients []string `json:"ingredients"`
}

type Inventory map[string]bool

var menu = map[string]Dish{
	"tacos_al_pastor": {
		Name:        "Tacos al Pastor",
		Ingredients: []string{"tortilla", "carne_al_pastor", "pina", "cebolla", "cilantro", "salsa_roja"},
	},
	"enchiladas_verdes": {
		Name:        "Enchiladas Verdes",
		Ingredients: []string{"tortilla", "pollo", "salsa_verde", "crema", "queso", "cebolla"},
	},
	"chiles_rellenos": {
		Name:        "Chiles Rellenos",
		Ingredients: []string{"chile_poblano", "queso", "huevo", "harina", "salsa_jitomate"},
	},
	"pozole": {
		Name:        "Pozole",
		Ingredients: []string{"maiz_pozolero", "carne_cerdo", "oregano", "lechuga", "rabano", "cebolla"},
	},
	"mole_poblano": {
		Name:        "Mole Poblano",
		Ingredients: []string{"pollo", "mole", "ajonjoli", "arroz"},
	},
	"sopa_tortilla": {
		Name:        "Sopa de Tortilla",
		Ingredients: []string{"tortilla", "jitomate", "caldo_pollo", "aguacate", "queso", "crema"},
	},
}

var inventory = Inventory{
	"tortilla":       true,
	"carne_al_pastor": true,
	"cebolla":        true,
	"cilantro":       true,
	"salsa_roja":     true,
	"pollo":          true,
	"salsa_verde":    true,
	"queso":          true,
	"huevo":          true,
	"harina":         true,
	"salsa_jitomate": false,
	"maiz_pozolero":  true,
	"carne_cerdo":    false,
	"oregano":        true,
	"lechuga":        true,
	"rabano":         false,
	"mole":           true,
	"ajonjoli":       true,
	"arroz":          true,
	"jitomate":       true,
	"caldo_pollo":    true,
	"aguacate":       false,
	"crema":          true,
	"pina":           false,
	"chile_poblano":  true,
}

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("/", healthHandler)
	mux.HandleFunc("/dishes", dishesHandler)
	mux.HandleFunc("/dish/", dishRouter)
	mux.HandleFunc("/inventory", inventoryHandler)

	addr := ":8090"
	log.Printf("Servidor Go activo en http://localhost%s", addr)
	if err := http.ListenAndServe(addr, mux); err != nil {
		log.Fatal(err)
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	writeJSON(w, http.StatusOK, map[string]any{
		"status":  "ok",
		"service": "se_menu_ingredientes",
		"port":    8090,
	})
}

func dishesHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Metodo no permitido"})
		return
	}

	keys := make([]string, 0, len(menu))
	for k := range menu {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	resp := make([]Dish, 0, len(keys))
	for _, k := range keys {
		resp = append(resp, menu[k])
	}

	writeJSON(w, http.StatusOK, map[string]any{"dishes": resp})
}

func dishRouter(w http.ResponseWriter, r *http.Request) {
	// /dish/{id}/ingredients
	// /dish/{id}/availability
	parts := strings.Split(strings.Trim(r.URL.Path, "/"), "/")
	if len(parts) != 3 || parts[0] != "dish" {
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "Ruta no encontrada"})
		return
	}

	id := parts[1]
	action := parts[2]

	dish, ok := menu[id]
	if !ok {
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "Platillo no encontrado"})
		return
	}

	if r.Method != http.MethodGet {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Metodo no permitido"})
		return
	}

	switch action {
	case "ingredients":
		writeJSON(w, http.StatusOK, map[string]any{
			"dish_id":     id,
			"dish_name":   dish.Name,
			"ingredients": dish.Ingredients,
		})
	case "availability":
		missing := missingIngredients(dish)
		writeJSON(w, http.StatusOK, map[string]any{
			"dish_id":               id,
			"dish_name":             dish.Name,
			"all_ingredients_exists": len(missing) == 0,
			"missing_ingredients":   missing,
		})
	default:
		writeJSON(w, http.StatusNotFound, map[string]string{"error": "Accion no valida"})
	}
}

func inventoryHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		writeJSON(w, http.StatusMethodNotAllowed, map[string]string{"error": "Metodo no permitido"})
		return
	}
	writeJSON(w, http.StatusOK, map[string]any{"inventory": inventory})
}

func missingIngredients(d Dish) []string {
	missing := []string{}
	for _, ing := range d.Ingredients {
		if !inventory[ing] {
			missing = append(missing, ing)
		}
	}
	return missing
}

func writeJSON(w http.ResponseWriter, status int, payload any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(payload); err != nil {
		http.Error(w, fmt.Sprintf("error serializando JSON: %v", err), http.StatusInternalServerError)
	}
}
