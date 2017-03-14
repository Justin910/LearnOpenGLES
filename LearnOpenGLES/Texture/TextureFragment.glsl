varying lowp vec4 OutColor;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

varying lowp vec2 TexCoordOut;

void main(void){

//    gl_FragColor = OutColor;
    
//    gl_FragColor = OutColor * texture2D(ourTexture1, TexCoordOut);
    
    gl_FragColor = OutColor * mix(texture2D(ourTexture1, TexCoordOut), texture2D(ourTexture2, TexCoordOut), 0.7);
}
