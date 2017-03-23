attribute vec4 Position;

attribute vec4 InColor;
varying   vec4 OutColor;

uniform mat4 ModelView;     //new

void main(void){
    OutColor = InColor;
//    gl_Position = Position;
    gl_Position = ModelView * Position;
}
