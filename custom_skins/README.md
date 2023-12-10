# Custom skins

Put the mod in `project-bo4/mods`. It'll set a custom camo to your weapon and custom skins.

## Config camos

To config the camo, you can edit the `configs/camos.csv` file, keep the `int` at the first line and replace the id. You can set one camo per line, the game will pick a random one.

You can have a list of the camo IDs [here](https://github.com/ate47/t8-atian-menu/blob/master/docs/weaponscustom.md#camos).

Common ids:

- Diamond 44
- Dark matter 45
- Diamond last tier 199
- Dark matter last tier 192
- PaP Voyage of despair red 147
- PaP Tag der toten 394

## Config skins

To config the camo, you can edit the `configs/skins.csv` file, keep the `hash,int,int` at the first line and replace the id. You can set one skin per line, the game will pick a random one.

I've set common skins, but you can set you own using [this list](https://github.com/ate47/t8-atian-menu/blob/master/docs/characters.md#skins).

The character id must be the same as the one described in `configs/character_ids.csv`.