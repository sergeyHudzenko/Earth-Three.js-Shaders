varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;

uniform sampler2D uDayTexture;
uniform sampler2D uNightTexture;
uniform sampler2D uSpecularCloudsTexture;
uniform vec3 uSunDirection;
uniform float uCloudsCoverage;
uniform vec3 uAtmosphereDayColor;
uniform vec3 uAtmosphereTwilightColor;

void main()
{
    // Day texture
    vec3 dayColor = texture(uDayTexture, vUv).rgb;
    // Night texture
    vec3 nightColor = texture(uNightTexture, vUv).rgb;
    // Specular clouds texture
    vec2 specularCloudsColor = texture(uSpecularCloudsTexture, vUv).rg;


    vec3 viewDirection = normalize(vPosition - cameraPosition);
    vec3 normal = normalize(vNormal);
    vec3 color = vec3(0.0);


    // SUN
    float sunOrientation = dot(uSunDirection, vNormal);
    float dayMix = smoothstep(-0.25, 0.25, sunOrientation);

    color = mix(nightColor, dayColor, dayMix);


    // Clouds
    float cloudMix =  smoothstep(uCloudsCoverage, 1.0, specularCloudsColor.g);
    cloudMix *= dayMix;
    color = mix(color, vec3(1.0), cloudMix);

    // Fresnel
    float fresnel = dot(viewDirection, normal) + 1.0;
    fresnel = pow(fresnel, 2.0);

    // Atmosphere
    float atmosphereMix = smoothstep(-0.5, 1.0, sunOrientation);
    vec3 atmosphereColor = mix(uAtmosphereTwilightColor, uAtmosphereDayColor, atmosphereMix); 
    color = mix(color, atmosphereColor, fresnel * atmosphereMix);

    // Specular
    vec3 reflection = reflect(-uSunDirection, normal);
    float specular = - dot(reflection, viewDirection);
    specular = max(specular, 0.0);
    specular = pow(specular, 32.0);
    specular *= specularCloudsColor.r;

    vec3 specularColor = mix(vec3(1.0), atmosphereColor, fresnel); 
    color += specularColor * specular;

    // Final color
    gl_FragColor = vec4(color, 1.0);
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}