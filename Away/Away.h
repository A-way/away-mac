//

#ifndef Away_h
#define Away_h
#include <stdio.h>

struct settings {
    const char *remote;
    const char *passkey;
    const char *port;
};

enum away_mode {
    AWAY_MODE_RULE = 42,  // *
    AWAY_MODE_AWAY = 126, // ~
    AWAY_MODE_PASS = 64,  // @
    AWAY_MODE_DROP = 33   // !
};


extern int away_initialize(char *dir);
extern int away_start(void);

extern int  away_settings_exist(void);
extern void away_settings_get(struct settings *s);
extern int  away_settings_change(struct settings s);
extern void away_settings_free(struct settings *s);

extern int away_rule_add(char *r);
extern int away_rule_del(char *r);
extern char** away_rules_get(void);

extern int away_mode_change(enum away_mode m);

#endif /* Away_h */
