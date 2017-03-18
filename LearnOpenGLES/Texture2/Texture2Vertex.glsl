attribute vec4 Position;

attribute vec2 TexCoordIn;
varying   vec2 TexCoordOut;

void main(void) {
    
    gl_Position = Position;
    
    TexCoordOut = vec2(TexCoordIn.x, 1. - TexCoordIn.y);
}
