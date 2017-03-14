attribute vec4 Position;

attribute vec4 InColor;
varying   vec4 OutColor;

attribute vec2 TexCoordIn;
varying   vec2 TexCoordOut;

void main(void) {
    
    gl_Position = Position;
    OutColor    = InColor;
    
    TexCoordOut = vec2(TexCoordIn.x, 1. - TexCoordIn.y);
}

