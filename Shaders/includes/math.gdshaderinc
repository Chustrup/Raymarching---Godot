// https://www.shadertoy.com/view/lt3BW2

vec2 s_union( float a, float b, float k )
{
    float h = 1.0 - min( abs(a-b)/(4.0*k), 1.0 );
    float w = h*h;
    float m = w*0.5;
    float s = w*k;
    return (a<b) ? vec2(a-s,m) : vec2(b-s,1.0-m);
}

float s_subtraction( float d1, float d2, float k )
{
    return -s_union(d1,-d2,k).x;
}

float s_intersection( float d1, float d2, float k )
{
    return -s_union(-d1,-d2,k).x;
}