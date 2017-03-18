precision highp float;


uniform sampler2D ourTexture;

varying vec2 TexCoordOut;

mediump float PI = 3.1415926535;

uniform vec2 uCoordinateOffset;

void main(void){
//    gl_FragColor = texture2D(ourTexture, TexCoordOut);

    float aperture = 178.0;
    float apertureHalf = 0.5 * aperture * (PI / 180.0);
    float maxFactor = sin(apertureHalf);
    
    vec2 uv;
    vec2 xy = vec2(0.,0.);
    xy.x = 2.0 * TexCoordOut.x - 1.0 - uCoordinateOffset.x * 2.;
    xy.y = 2.0 * TexCoordOut.y - 1.0;
    
    float d = length(xy);
    
    if (d < (2.0-maxFactor)){
        
        d = length(xy * maxFactor);
        float z   = sqrt(1.0 - d * d);
        float r   = atan(d, z) / PI;
        float phi = atan(xy.y, xy.x);
        
        uv.x = r * cos(phi) + 0.5 + uCoordinateOffset.x;
        uv.y = r * sin(phi) + 0.5;
    
    }else{
        
        uv = TexCoordOut.xy ;
    }
    vec4 c = texture2D(ourTexture, uv * 3.0 - 1.0);
    gl_FragColor = c;

}
