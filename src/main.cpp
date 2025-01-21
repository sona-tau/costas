#include "external.hpp"
#include "lib/lib.hpp"
#include "lib/fractal.hpp"
#include "test/test.hpp"
#include <algorithm>
#include <cassert>
#include <format>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <ranges>

void static foo() noexcept {
    for (auto p : vi::iota(5, 100) | vi::filter(ext::is_prime)) {
        let roots = primitive_roots((UInt(p)));
        let first_root = roots.front();
        std::cout << std::format("${}$, ${}, ", p, first_root);

        var space = "";
        for (auto root : roots | vi::drop(1)) {
            let i = find_index(seq(p, root), first_root) + 1;
            std::cout << std::format("{}{}^{}", space, first_root, i);
            space = ", ";
        }

        std::cout << "$\n";
    }
}

struct Node {
    Vec<U8> indices;
    Size x;
    Size y;
    Size left_wall = 0;

    fn children() const -> Vec<Node> {
        let level = indices.size();
        Vec<Node> v;
        v.reserve(level + 1);
        for (Size i = 1; i <= level + 1; ++i) {
            var next_indices = indices;
            next_indices.push_back(i - 1);
            std::cout << "current_indices: ";
            for (let e : indices) std::cout << e << ' ';
            std::cout << std::endl;
            std::cout << "next_indices: ";
            for (let e : next_indices) std::cout << e << ' ';
            std::cout << std::endl;

            let tmp_x = 2 * (x - left_wall);
            let next_y = y + 10;
            let next_x = (2 * i - 1) * tmp_x / ((level + 1) * 2) + left_wall;
            let next_wall = (2 * (i - 1)) *  tmp_x / ((level + 1) * 2) + left_wall;
            v.push_back(Node{next_indices, next_x, next_y, next_wall});
        }
        return v;
    }
};

fn main() noexcept -> int {
#ifndef TEST
    let WIDTH = 800;
    let HEIGHT = 800;
    static var canvas = Canvas<WIDTH, HEIGHT>();
    canvas.fill(RGB(0xEE, 0xEE, 0xEE).to_hsv());
    let r = RGB(0xFF, 0x00, 0x00);
    let g = RGB(0x00, 0xFF, 0x00);
    let b = RGB(0x00, 0x00, 0xFF);
    let gray = RGB(0x22, 0x22, 0x22);

    let a = PixelLocation(WIDTH / 2, 20);
    var v = Vec<U8>();
    v.push_back(0);
    let c1 = Node{v, WIDTH / 2, 20};
    var counter = 0;
    var color = r;
    let radius = 2;
    canvas.circle(a, radius, g.to_hsv());
    for (let& c2 : c1.children()) {
        // for (let& c3 : c2.children()) {
            // for (let& c4 : c3.children()) {
                // for (let& c5 : c4.children()) {
                    /*
                    for (let& c6 : c5.children()) {
                        for (let& c7 : c6.children()) {
                            let loc = PixelLocation{c7.x, c7.y};
                            if (is_costas(from_indices(c7.indices)))
                                canvas.circle(loc, radius, g.to_hsv());
                            else canvas.circle(loc, radius, r.to_hsv());
                        }
                        let loc = PixelLocation{c6.x, c6.y};
                        canvas.circle(loc, radius, color.to_hsv());
                    }
                    */
                    // let loc = PixelLocation{c5.x, c5.y};
                    // if (is_costas(from_indices(c5.indices)))
                        // canvas.circle(loc, radius, g.to_hsv());
                    // else canvas.circle(loc, radius, r.to_hsv());
                // }
                // let loc = PixelLocation{c4.x, c4.y};
                // if (is_costas(from_indices(c4.indices)))
                    // canvas.circle(loc, radius, g.to_hsv());
                // else canvas.circle(loc, radius, r.to_hsv());
            // }
            // let loc = PixelLocation{c3.x, c3.y};
            // if (is_costas(from_indices(c3.indices)))
                // canvas.circle(loc, radius, g.to_hsv());
            // else canvas.circle(loc, radius, r.to_hsv());
        // }
        let loc = PixelLocation{c2.x, c2.y};
        let lst = from_indices(c2.indices);
        std::cout << "indices: ";
        for (let e : c2.indices) std::cout << e << ' ';
        std::cout << std::endl;
        for (let e : lst) std::cout << e << ' ';
        std::cout << std::endl;
        if (is_costas(lst))
            canvas.circle(loc, radius, g.to_hsv());
        else canvas.circle(loc, radius, r.to_hsv());
    }
    canvas.save_to_ppm("test.ppm");
#else
    let s1 = seq(11, 2);
    Vec<UInt> s2 = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11};
    "2 is a primitive root of 11"_test = is_primitive_root(11, 2);
    "test permutation matrix for 11 for alpha 2"_test =
        is_permutation_matrix(s1);
    "test permutation matrix for 11 with increasing numbers"_test =
        not is_permutation_matrix(s2);
#endif

    return 0;
}
