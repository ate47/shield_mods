#include scripts\core_common\array_shared;
#include scripts\core_common\system_shared;
#include scripts\core_common\callbacks_shared;

#namespace testlua;

autoexec __init_system__() {
	system::register(#"test_lua", &__init__, &__post_init__, undefined);
}
__init__() {
    callback::on_spawned(&onPlayerSpawned);
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
        notify_value = false;
        zombies = GetAITeamArray(level.zombie_team);

        count = 0;

        foreach (zmb in zombies) {
            if (isdefined(zmb.ignore_enemy_count) && zmb.ignore_enemy_count) continue;
            count++;
        }

        if (count != old_count) {
            old_count = count;
            notify_value = true;
        }

        if (level.zombie_total != old_remaining) {
            old_remaining = level.zombie_total;
            notify_value = true;
        }

        if (notify_value) {
            luinotifyevent(#"testlua_update_counter", 2, old_count, old_remaining);
        }

        wait 0.5;
    }
}

onPlayerSpawned() {
    self endon(#"disconnect", #"spawned_player");
    level endon(#"end_game", #"game_ended");

    wait 10;

    self iprintln(#"shield/custom_message_test");

    for (;;) {
        result = undefined;
        result = self waittilltimeout(2, #"earned_points", #"spent_points");

        if (isdefined(result._notify) && result._notify == #"earned_points") {
            if (isdefined(result.n_points)) {
                self luinotifyevent(#"testlua_points", 2, 1, result.n_points);
            }
        } else if (isdefined(result._notify) && result._notify == #"spent_points") {
            if (isdefined(result.points)) {
                self luinotifyevent(#"testlua_points", 2, 2, result.points);
            }
        } else {
            self luinotifyevent(#"testlua_points", 1, 0);
        }
    }
}