# Metadatos de mods — GTA Mod Organizer (SAMT)

Repositorio **solo de metadatos** de los mods gestionados con
[SAMT / GTA Mod Organizer](https://github.com/XardecQs/samt-nix).

Aquí se versionan únicamente los archivos que describen cada mod —manifiestos,
carátulas y capturas—, **no su contenido**. El contenido de los mods sigue
viviendo solo en local (bajo `content/` y compañía), porque no es de mi
propiedad y en muchos casos sus licencias prohíben redistribuirlo.

## Qué se versiona

Para cada mod, dentro de `mods/<slug>/`:

| Ruta               | Descripción                                        |
|--------------------|----------------------------------------------------|
| `mod.toml`         | Manifiesto (metadatos, `mount`, dependencias, etc.) |
| `cover.<ext>`      | Carátula del mod (`cover.avif`) |
| `screenshots/**`   | Galería de capturas (AVIF; algún `.gif` animado) |

Todo lo demás se ignora (ver `.gitignore`): `content/`, `modloader/`,
`extras/`, `guides/`, etc.

## Qué NO se versiona (y por qué)

- **`content/`**: el contenido del mod que se monta sobre el juego.
- **`guides/`**: readmes y documentación del autor (texto con copyright).
- **`extras/`**: opciones, presets y variantes que aporta el mod.

Nada de esto se redistribuye. Para instalar un mod hay que descargarlo desde su
web original; la URL está en el campo `url` de su `mod.toml`.

## Estructura canónica de un mod

```
mods/<slug>/
├── mod.toml            # manifiesto (siempre)
├── cover.<ext>         # carátula única, basename fijo "cover"
├── screenshots/        # galería de capturas
├── guides/             # readmes del autor (no versionado)
├── content/            # archivos que se montan sobre el juego (no versionado)
├── options/<grupo>/<valor>/  # opciones por perfil que se montan sobre content (no versionado)
└── extras/             # material auxiliar no montado (no versionado)
    ├── optional/       # extras añadidos (planes, umbrella, bonus…)
    ├── docs/           # API para devs, avisos de terceros
    └── source/         # originales sin modificar y conversores
```

## Convenciones de nombres

- **Carpeta del mod**: `slug` en minúsculas, kebab-case, sin versión, sin
  espacios, paréntesis, guiones bajos ni acentos. La versión va solo en
  `mod.toml`.
- **Carátula**: siempre `cover.avif` (el nombre base es siempre `cover`). Las
  imágenes se convierten con `./to-avif.sh` (avifenc, calidad 75).
- **Capturas**: siempre la carpeta `screenshots/`, y en el manifiesto
  `screenshots = ["screenshots"]`.
- **Opciones**: `options/<grupo>/<valor>/` con el contenido game-relative que se
  monta encima de `content/`; se declaran (o autodescubren) en `[[options]]` del
  `mod.toml` y se eligen por perfil con `gta-mo ctl option`.
- **`extras/`**: material auxiliar no montado, en subcarpetas por tipo
  (`optional/`, `docs/`, `source/`).
- **`id`**: identificador estable `autor:slug` en minúsculas; sobrevive a
  renombrados de carpeta o de nombre visible.
- **`version`**: el número del autor (semver si existe); si no, fecha
  `YYYY-MM-DD` con ceros.

## Uso

Este repositorio es la carpeta `mods/` del `game_root` de SAMT. Para usarlo en
otra máquina:

1. Clona el repo dentro de `game_root` con el nombre `mods`:
   ```bash
   git clone <url> "$GAME_ROOT/mods"
   ```
2. Descarga cada mod desde su `url` (campo de `mod.toml`) y coloca su contenido
   donde indique `mount` (normalmente `mods/<slug>/content/`).
3. Registra y activa:
   ```bash
   gta-mo ctl discover
   gta-mo ctl enable <mod>
   ```

Los `mod.toml` son la fuente canónica de metadatos: editarlos se refleja al
instante en `gta-mo ctl` y en la GUI.

## Autoría y licencias

- Los `mod.toml` y la documentación de este repo están bajo **CC0 1.0**
  (ver [`LICENSE`](LICENSE)).
- Las carátulas y capturas **no** están cubiertas por CC0: son obra de los
  autores de cada mod y se incluyen solo para identificarlos. Ver
  [`NOTICE.md`](NOTICE.md).

## Agradecimientos

Gracias a [MixMods](https://www.mixmods.com.br/) y a Junior_Djjr por tantos años
compartiendo mods, código y conocimiento. Sigo su web desde hace años (2018
aprox), y buena parte de los mods de este catálogo son suyos. Además, varias
ideas de `mod.toml` (etiquetas, opciones, dependencias) están inspiradas
directamente en su forma de trabajar.
