attribute vec4 Position;

attribute vec4 InColor;
varying vec4 OutColor;

void main(void){
    OutColor = InColor;
    gl_Position = Position;
}
