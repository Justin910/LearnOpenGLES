varying lowp vec4 OutColor;

uniform sampler2D ourTexture;
varying lowp vec2 TexCoordOut;

void main(void){

//    gl_FragColor = OutColor;
    
    gl_FragColor = texture2D(ourTexture, TexCoordOut);
}
