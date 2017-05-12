
uniform sampler2D ourTexture;
uniform sampler2D ourTexture1;

varying lowp vec2 TexCoordOut;

void main(void){
    
//    gl_FragColor = texture2D(ourTexture, TexCoordOut);
    
    gl_FragColor = mix(texture2D(ourTexture, TexCoordOut), texture2D(ourTexture1, TexCoordOut), 0.1);
}
