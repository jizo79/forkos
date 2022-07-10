#include "framebuffer.h"

void kmain()
{
    framebuffer_clear_screen( FB_COLOR_BLACK );
    framebuffer_write_string( 0, "hello world!", FB_COLOR_WHITE, FB_COLOR_BLACK );
}
