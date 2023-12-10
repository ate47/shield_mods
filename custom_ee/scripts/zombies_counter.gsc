#include scripts\core_common\system_shared;
#include scripts\core_common\clientfield_shared;
#include scripts\core_common\callbacks_shared;

#namespace zombies_counter;

autoexec __init__system__() {
    system::register("zombies_counter", &__init__, &__post_init__, undefined);
}

__init__() {
    clientfield::register("toplayer", "" + #"zombies_counter_alive", 1, 31, "int");
    clientfield::register("toplayer", "" + #"zombies_counter_remaining", 1, 10, "int");
}
__post_init__() {
    thread update_zombies_counter();
}

update_zombies_counter() {
    level endon(#"end_game", #"game_ended");

    // wait zombie team
    while (!isdefined(level.zombie_team)) waitframe(1);

    old_count = -1;
    old_remaining = -1;

    while (true) {
        zombies = GetAITeamArray(level.zombie_team);

        count = 0;

        foreach (zmb in zombies) {
            if (isdefined(zmb.ignore_enemy_count) && zmb.ignore_enemy_count) continue;
            count++;
        }

        if (count != old_count) {
            old_count = count;
            foreach (plt in getplayers()) {
                plt clientfield::set_to_player("" + #"zombies_counter_alive", count);
            }
        }

        if (level.zombie_total != old_remaining) {
            old_remaining = level.zombie_total;
            foreach (plt in getplayers()) {
                plt clientfield::set_to_player("" + #"zombies_counter_remaining", old_remaining);
            }
        }

        wait 0.5;
    }
}
