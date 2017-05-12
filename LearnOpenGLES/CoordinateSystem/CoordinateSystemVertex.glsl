attribute vec4 Position;

attribute vec2 TexCoordIn;
varying   vec2 TexCoordOut;


uniform mat4 Projection;   
uniform mat4 View;         
uniform mat4 Model;        

void main(void){
    
//    gl_Position = Position;
    gl_Position = Projection * View * Model * Position;
    
    TexCoordOut    = vec2(TexCoordIn.x, 1.0 - TexCoordIn.y);
}
