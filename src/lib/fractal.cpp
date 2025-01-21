#include "fractal.hpp"
#include <cmath>
#include <array>
#include "prelude.hpp"


fn distance_sq(Size x1, Size y1, Size x2, Size y2) -> F64 {
    let rise = y2 - y1;
    let run = x2 - x1;
    return rise * rise + run * run;
}

fn distance(Size x1, Size y1, Size x2, Size y2) -> F64 {
    return sqrt(distance_sq(x1, y1, x2, y2));
}

RGB::RGB(U8 red, U8 green, U8 blue) : Red(red) , Green(green), Blue(blue)
{
}

fn RGB::to_hsv() const -> Color {
    let r = Red / 255.0;
    let g = Green / 255.0;
    let b = Blue / 255.0;
    let x_max = std::max(r, std::max(g, b));
    let v = x_max;
    let x_min = std::min(r, std::min(g, b));
    let c = x_max - x_min;
    let l = v - c / 2.0;
    let h = v == r ? 60.0 * (I64((g - b) / c) % 6) :
            v == g ? 60.0 * ((b - r) / c + 2) :
            v == b ? 60.0 * ((r - g) / c + 4) : 0.0;
    let s = v == 0 ? 0.0 : c / v;

    return Color(h, s, v);
}

Color::Color() : hue(0.0), saturation(0.0), value(0.0)
{
}

Color::Color(F64 hue, F64 saturation, F64 value) : hue(hue)
    , saturation(saturation), value(value)
{
}

Color::Color(U32 val)
    : hue(0.0), saturation(0.0)
{
    value = (double) val / 255.0;
}

fn Color::to_rgb() const -> RGB {
    let chroma = saturation * value;
    let cube_hue = hue / 60.0;
    let tmp = chroma * (1.0 - fabs(fmod(cube_hue, 2.0) - 1.0));

    var components = std::array{ 0.0, 0.0, 0.0 };
    if (cube_hue < 1.0)
        components = { chroma, tmp, 0.0 };
    else if (cube_hue < 2.0)
        components = { tmp, chroma, 0.0 };
    else if(cube_hue < 3.0)
        components = { 0.0, chroma, tmp };
    else if(cube_hue < 4.0)
        components = { 0.0, tmp, chroma };
    else if(cube_hue < 5.0)
        components = { tmp, 0.0, chroma };
    else
        components = { chroma, 0.0, tmp };

    let match = value - chroma;
    for (var& component : components)
        component += match, component *= 255;

    const auto c = RGB(round(components[0]), round(components[1]), round(components[2]));
    return c;
}

fn Color::lerp(Ref<const Color> rhs, double t) const -> Color
{
    return Color(std::lerp(hue, rhs.hue, t), std::lerp(saturation, rhs.saturation, t), std::lerp(value, rhs.value, t));
}

Point::Point(F64 x, F64 y)
    : x(x), y(y)
{
}
