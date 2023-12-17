#include scripts\core_common\system_shared.csc;
#include scripts\core_common\clientfield_shared.csc;

#namespace zombies_counter;

autoexec __init__system__() {
    system::register("zombies_counter", &__init__, &__post_init__, undefined);
}

__init__() {
    clientfield::register("toplayer", "" + #"zombies_counter_alive", 1, 31, "int", &cf_set_zombies_count, 0, 0);
    clientfield::register("toplayer", "" + #"zombies_counter_remaining", 1, 10, "int", &cf_set_zombies_count_remaining, 0, 0);

    level.zombies_counter = {
        #count : 0,
        #remaining : 0
    };
}

__post_init__() {
    /*
       aligns
        - x, 0 = left | 1 = center | 2 = right
        - y, 0 = top  | 1 = middle | 2 = bottom
     */

    ShieldRegisterHudElem(#"zombies_counter", "^1waiting for the zombies...", 
        0xFFFF0000, // color red
        -6, 6, // x/y
        2, 0, // anchor x/y
        2, 0, // align x/y
        0.75 // scale
    );
}

update_hud() {
    ShieldHudElemSetText(#"zombies_counter", "^1Zombies: ^5" + level.zombies_counter.count + " ^1(^5" + level.zombies_counter.remaining + " ^1remaining)");
}

cf_set_zombies_count(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump) {
    level.zombies_counter.count = newval;
    update_hud();
}

cf_set_zombies_count_remaining(localclientnum, oldval, newval, bnewent, binitialsnap, fieldname, bwastimejump) {
    level.zombies_counter.remaining = newval;
    update_hud();
}
