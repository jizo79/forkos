#include "framebuffer.h"

#define FRAMEBUFFER             0x000B8000
#define FRAMEBUFFER_CHAR_BITS   8
#define FRAMEBUFFER_CHAR_MASK   ( ( 1u << FRAMEBUFFER_CHAR_BITS ) - 1 )
#define FRAMEBUFFER_FG_BITS     4
#define FRAMEBUFFER_FG_MASK     ( ( 1u << FRAMEBUFFER_FG_BITS ) - 1)
#define FRAMEBUFFER_BG_BITS     4
#define FRAMEBUFFER_BG_OFFSET   4
#define FRAMEBUFFER_BG_MASK     ( ( 1u << FRAMEBUFFER_BG_BITS ) - 1)

void framebuffer_write_cell( unsigned int i, char c, unsigned char fg, unsigned char bg )
{
    char *framebuffer = (char *) FRAMEBUFFER;
    framebuffer[i*2] = c & FRAMEBUFFER_CHAR_MASK;
    framebuffer[i*2 + 1] = ( ( fg & FRAMEBUFFER_FG_MASK ));
    framebuffer[i*2 + 1] |= ( ( bg & FRAMEBUFFER_BG_MASK ) << FRAMEBUFFER_BG_OFFSET );
}

void framebuffer_write_string( unsigned int i, char *string, unsigned char fg, unsigned char bg )
{
    char *first = string;
    for( unsigned int p = i; *first != '\0'; ++p, ++first )
    {
        framebuffer_write_cell( p, *first, fg, bg );
    }
}

void framebuffer_clear_screen( unsigned char bg )
{
    for( int y = 0; y < 25; ++y )
    {
        for( int x = 0; x < 80; ++x )
        {
            framebuffer_write_cell( x+80*y, "\0", bg, bg );
        }
    }
}