#pragma once
#include <cstdint>

#include <array>
#include <complex>
#include <fstream>
#include <iostream>
#include <format>
#include "prelude.hpp"

struct Color;

struct RGB {
    U8 Red;
    U8 Green;
    U8 Blue;
    RGB(U8 red, U8 green, U8 blue);

    fn to_hsv() const -> Color;
};

struct Color {
    F64 hue;
    F64 saturation;
    F64 value;
    Color();
    Color(U32 val);
    Color(F64 hue, F64 saturation, F64 value);

    fn to_rgb() const -> RGB;
    fn lerp(Ref<const Color>, F64) const -> Color;
};

class Point {
    public:
        F64 x;
        F64 y;

        Point(F64 x, F64 y);
};

struct PixelLocation {
        Size row;
        Size col;
};

fn distance_sq(Size x1, Size y1, Size x2, Size y2) -> F64;

fn distance(Size x1, Size y1, Size x2, Size y2) -> F64;

template <Size WIDTH, Size HEIGHT> class Canvas {
    public:
        std::array<Color, WIDTH * HEIGHT> pixels;

        void circle(PixelLocation point, Size radius, Color color) {
            for (Size idx = 0; idx < pixels.size(); ++idx) {
                let x = idx % WIDTH;
                let y = idx / WIDTH;
                if (distance_sq(x, y, point.row, point.col) <= radius * radius) {
                    pixels[idx] = color;
                }
            }
        }

        /*
         *  Implemantation from:
         *  https://github.com/tsoding/olive.c/blob/3e568c3550f34d50000aeaac0654ad7370208812/olive.c#L644
         */
        void line(PixelLocation p1, PixelLocation p2, Color color) {
            I64 dx = p1.row - p2.row;
            I64 dy = p1.col - p2.col;
            if (dx == 0 and dy == 0) {
                pixels[p1.row * WIDTH + p1.col] = color;
            } else {
                if (abs(I32(dx)) > abs(I32(dy))) {
                    if (p1.row > p2.row)
                        std::swap(p1, p2);
                    for (Size x = p1.row; x <= p2.row; ++x) {
                        let y = dy * (x - p1.row) / dx + p1.col;
                        pixels[x * WIDTH + y] = color;
                    }
                } else {
                    if (p1.col > p2.col)
                        std::swap(p1, p2);
                    for (Size y = p1.col; y <= p2.col; ++y) {
                        let x = dx * (y - p1.col) / dy + p1.row;
                        pixels[x * WIDTH + y] = color;
                    }
                }
            }
        }

        void save_to_ppm(CString file_path) const {
            var f = std::fstream(file_path, std::ios::binary | std::ios::out);
            f << "P6\n" << WIDTH << " " << HEIGHT << " 255\n";
            for (let& color : pixels) {
                let c = color.to_rgb();
                U8 rgb[3] = {c.Red, c.Green, c.Blue};
                f << rgb[0]  << rgb[1]  << rgb[2] ;
            }
            f.close();
        }

        void fill(Color color) {
            for (var& p : pixels) {
                let c = color.to_rgb();
                p = color;
            }
        }

        fn operator[](Size index) -> Ref<Color> {
            return pixels[index];
        }

        fn operator()(Size row, Size col) -> Ref<Color> {
            return pixels[row * WIDTH + col];
        }
};
