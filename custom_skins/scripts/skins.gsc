#include scripts\core_common\array_shared;
#include scripts\core_common\system_shared;
#include scripts\core_common\callbacks_shared;

#namespace shieldcustomskins;


autoexec __init__system__() {
	system::register(#"shield_custom_camos", &__init__, undefined, undefined);
}

__init__() {
    camo_csv = #"gamedata/shield/customskins/camos.csv";
    skins_csv = #"gamedata/shield/customskins/skins.csv";
    character_ids_csv = #"gamedata/shield/customskins/character_ids.csv";

    level._shield_custom = {
        #camos: [],
        #character_lookup: [],
        #skins: []
    };

    // load camos
    rows = tablelookuprowcount(camo_csv);

    for (i = 0; i < rows; i++) {
        cid = tablelookupcolumnforrow(camo_csv, i, 0);
        if (!isdefined(cid) || !isint(cid)) {
            continue;
        }

        array::add(level._shield_custom.camos, cid, false);
    }

    // load skins lookup
    rows = tablelookuprowcount(character_ids_csv);

    if (sessionmodeiswarzonegame()) {
        mode_idx = 2;
    } else if (sessionmodeiszombiesgame()) {
        mode_idx = 3;
    } else if (sessionmodeismultiplayergame()) {
        mode_idx = 1;
    } else {
        rows = 0;
        mode_idx = 1;
    }
    
    for (i = 0; i < rows; i++) {
        name = tablelookupcolumnforrow(character_ids_csv, i, 0);
        cid = tablelookupcolumnforrow(character_ids_csv, i, mode_idx);

        if (!isdefined(cid) || !isdefined(name) || !isint(cid) || cid == 0) {
            continue;
        }

        level._shield_custom.character_lookup[name] = cid;
    }
    
    rows = tablelookuprowcount(skins_csv);
    for (i = 0; i < rows; i++) {
        name = tablelookupcolumnforrow(skins_csv, i, 0);
        outfit = tablelookupcolumnforrow(skins_csv, i, 1);
        palette = tablelookupcolumnforrow(skins_csv, i, 2);

        if (!isdefined(outfit) || !isdefined(palette) || !isdefined(name) || !isint(outfit) || !isint(palette)) {
            continue;
        }

        skin_id = level._shield_custom.character_lookup[name];
        
        if (!isdefined(skin_id)) {
            continue; // maybe not for this mode
        }

        if (!isdefined(level._shield_custom.skins[skin_id])) {
            level._shield_custom.skins[skin_id] = [];
        }


        // use a vector because I'm lazy
        array::add(level._shield_custom.skins[skin_id], (outfit, palette, 0));
    }


    callback::on_spawned(&onPlayerSpawned);
}

onPlayerSpawned() {
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");

    if (isdefined(self.shield_custom_skin_lastskin) && self.shield_custom_skin_lastskin != self getspecialistindex()) {
        self.shield_custom_skin = undefined;
        self.shield_custom_skin_lastskin = self getspecialistindex();
    }

    if (!isdefined(self.shield_custom_skin) || !isvec(self.shield_custom_skin)) {
        skin_id = self getspecialistindex();

        skin = level._shield_custom.skins[skin_id];

        if (isdefined(skin) && skin.size) {
            self.shield_custom_skin = array::random(skin);
        } else {
            self.shield_custom_skin = false; // use false to say we didn't find the skin
        }
        self.shield_custom_skin_lastskin = self getspecialistindex();
    }

    if (isdefined(self.shield_custom_skin) && isvec(self.shield_custom_skin)) {
        self setcharacteroutfit(int(self.shield_custom_skin[0]));
        self setcharacterwarpaintoutfit(0);
        self function_ab96a9b5("head", 0);
        self function_ab96a9b5("headgear", 0);
        self function_ab96a9b5("arms", 0);
        self function_ab96a9b5("torso", 0);
        self function_ab96a9b5("legs", 0);
        self function_ab96a9b5("palette", int(self.shield_custom_skin[1]));
        self function_ab96a9b5("warpaint", 0);
        self function_ab96a9b5("decal", 0);
    }

    if (level._shield_custom.camos.size) {
        while(true) {
            weapon = self GetCurrentWeapon();
            offhand = self GetCurrentOffhand();

            if (isdefined(weapon)) {
                c = array::random(level._shield_custom.camos);
                if (isdefined(c)) {
                    self setcamo(weapon, c);
                }
            }
            if (isdefined(offhand)) {
                c = array::random(level._shield_custom.camos);
                if (isdefined(c)) {
                    self setcamo(offhand, c);
                }
            }

            result = undefined;
            result = self waittill(#"weapon_change");
        }
    }
}
