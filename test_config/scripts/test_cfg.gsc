#include scripts\core_common\array_shared;
#include scripts\core_common\system_shared;
#include scripts\core_common\callbacks_shared;

#namespace shieldtestcfg;


autoexec __init__system__() {
	system::register(#"shield_test_cfg", &__init__, undefined, undefined);
}

__init__() {
    // register hashes for the config file lookup, this is an example, but it can also be done via a hash file

    // 0 = both
    // 1 = fnv1a
    // 2 = canon id
    ShieldRegisterHash(0, 
        "name",
        "hash",
        "michel hashed",
        "number",
        "array_test"
    );

    // register the command line command dvar
    setdvar(#"shield_test_cfg", "");
    ShieldRegisterDVarName("shield_test_cfg", "test cfg variable, r/w");

    thread test_cfg_think();
}

test_cfg_think() {
    level endon(#"end_game", #"game_ended");

    for (;;) {
        cmd = getdvarstring(#"shield_test_cfg");

        switch (cmd) {
            case #"read":
            case #"r":
                ShieldLog("reading from test_cfg...");
                val = ShieldFromJson("test_cfg");
                if (!isdefined(val)) {
                    ShieldLog("undefined");
                } else {
                    ShieldLog("name:   " + (isdefined(val.name) ? val.name : "undefined"));
                    ShieldLog("number: " + (isdefined(val.number) ? val.number : "undefined"));
                    ShieldLog("hash:   " + (isdefined(val.hash) ? val.hash : "undefined"));
                    ShieldLog("array_test: " + (isdefined(val.array_test) ? val.array_test.size : "undefined"));
                    if (isdefined(val.array_test)) {
                        foreach (key, value in val.array_test) {
                            ShieldLog("[" + key + "] = " + value);
                        }
                    }
                }
                break;
            case #"write":
            case #"w":
                val = {
                    #name: "michel",
                    #hash: "michel hashed",
                    #number: 1234,
                    #array_test: array(
                        1,
                        2,
                        3,
                        4,
                        5
                    )
                };
                val.array_test[#"michel hashed"] = 42;
                ShieldToJson("test_cfg", val);
                ShieldLog("write to test_cfg");
                break;
        }

        setdvar(#"shield_test_cfg", "");
        wait(0.5);
    }
}