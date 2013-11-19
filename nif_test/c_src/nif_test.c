#include <erl_nif.h>
#include <stdio.h>

static ERL_NIF_TERM
clean_nif_spin(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {

    int remaining_spin_count;
    int spin_count_per_ten_percent;
    int i;

    enif_get_int(env, argv[0], &remaining_spin_count);
    enif_get_int(env, argv[1], &spin_count_per_ten_percent);

    for (i = 0; i < remaining_spin_count; i++) {
        if (i % spin_count_per_ten_percent == 0 && enif_consume_timeslice(env, 10))
            break;
    }

    return enif_make_int(env, remaining_spin_count - i);
}

static ERL_NIF_TERM __attribute__((optimize("O0")))
dirty_nif_spin(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
    int n;

    enif_get_int(env, argv[0], (int*)&n);

    while (n > 0)
        n--;

    return enif_make_int(env, 0);
}

static ErlNifFunc nif_functions[] = {
    {"clean_nif_spin", 2, clean_nif_spin},
    {"dirty_nif_spin", 1, dirty_nif_spin}
};

ERL_NIF_INIT(nif_test, nif_functions, NULL, NULL, NULL, NULL);
