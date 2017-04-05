attribute vec4 Position;

attribute vec4 InColor;
varying   vec4 OutColor;

uniform mat4 ModelView;

attribute vec2 TexCoordIn;
varying   vec2 TexCoordOut;

void main(void){
    
    OutColor = InColor;
    
    gl_Position = ModelView * Position;
    
    TexCoordOut = vec2(TexCoordIn.x, 1. - TexCoordIn.y);
}
