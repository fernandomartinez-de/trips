# trips

Static HTML trip planning sites, one per trip, hosted with GitHub Pages.

## Trips

- **Japón · Noviembre 2026** — [/japan](./japan/) · [ver en Pages](https://fernandomartinez-de.github.io/trips/japan/)

## Cómo agregar un viaje nuevo

1. Duplicar la carpeta de un viaje existente (ej. `japan/`) con el nombre del nuevo destino.
2. Editar `index.html` con las fechas, ciudades y actividades del viaje nuevo.
3. Actualizar la lista en este README.
4. `git add .`, `git commit`, `git push`.

## Cómo funciona

Cada viaje vive en su propia subcarpeta con un `index.html` autocontenido. El HTML incluye Tailwind (via CDN), Leaflet (para el mapa) y las fotos embebidas como data URLs. No hay backend por ahora: los datos que edite cada persona (votos, notas, palomeadas) viven en su localStorage del navegador.

## Desarrollo local

Basta con abrir el `index.html` directamente en un navegador. No hay build step.

## Pages

Para hostear:

1. En GitHub → Settings → Pages
2. Source: **Deploy from a branch**
3. Branch: `main`, folder: `/ (root)`
4. Guardar. La URL será `https://<usuario>.github.io/trips/<viaje>/`.
