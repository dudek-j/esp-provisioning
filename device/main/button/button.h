#ifndef BUTTON_H
#define BUTTON_H

typedef void (*callback)(void);
void configure_button(callback handler);

#endif
