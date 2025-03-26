#ifndef WIFI_H
#define WIFI_H

typedef void (*callback)(void);

void reset_provisioning();
void configure_wifi(callback connecting, callback connected,
                    callback disconnected);

#endif
