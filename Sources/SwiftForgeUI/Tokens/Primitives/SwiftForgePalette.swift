//
//  SwiftForgePalette.swift
//  SwiftForgeUI
//
//  The primitive token layer: named raw sRGB values the built-in themes are
//  composed from. Steps run from light (50) to dark (950); in-between steps
//  exist where a theme tuned a value for contrast. Primitives carry no
//  meaning — a theme maps them to semantic roles — and are internal, so the
//  public API never promises a palette.
//

enum Palette {

    static let white: UInt32 = 0xFFFFFF
    static let black: UInt32 = 0x000000

    /// Apple's system grays.
    enum Gray {
        static let s50: UInt32 = 0xF2F2F7
        static let s100: UInt32 = 0xE5E5EA
        static let s200: UInt32 = 0xD1D1D6
        static let s300: UInt32 = 0xAEAEB2
        static let s400: UInt32 = 0x8E8E93
        static let s450: UInt32 = 0x7C7C80
        static let s500: UInt32 = 0x5E5E63
        static let s550: UInt32 = 0x545458
        static let s600: UInt32 = 0x48484A
        static let s700: UInt32 = 0x3A3A3C
        static let s750: UInt32 = 0x38383A
        static let s800: UInt32 = 0x2C2C2E
        static let s900: UInt32 = 0x1C1C1E
    }

    enum Blue {
        static let s50: UInt32 = 0xE6F0FC
        static let s100: UInt32 = 0xD3E4FA
        static let s300: UInt32 = 0x8CC4FF
        static let s350: UInt32 = 0x6CB4FF
        static let s400: UInt32 = 0x5AA9FF
        static let s550: UInt32 = 0x1A6FE0
        static let s600: UInt32 = 0x0062D1
        static let s700: UInt32 = 0x004FA8
        static let s900: UInt32 = 0x11305A
        static let s950: UInt32 = 0x0D2440
    }

    enum Green {
        static let s50: UInt32 = 0xEAF6EE
        static let s100: UInt32 = 0xD2EEDB
        static let s300: UInt32 = 0x7EE79A
        static let s400: UInt32 = 0x4CD964
        static let s450: UInt32 = 0x3DD068
        static let s600: UInt32 = 0x1A7F37
        static let s650: UInt32 = 0x1A7D35
        static let s700: UInt32 = 0x177A33
        static let s800: UInt32 = 0x126429
        static let s900: UInt32 = 0x123620
        static let s950: UInt32 = 0x0F2A17
    }

    enum Amber {
        static let s50: UInt32 = 0xFFF4DB
        static let s100: UInt32 = 0xFFE9B8
        static let s200: UInt32 = 0xFFD08A
        static let s250: UInt32 = 0xFFC870
        static let s300: UInt32 = 0xFFB340
        static let s350: UInt32 = 0xFFB020
        static let s500: UInt32 = 0xE89A00
        static let s700: UInt32 = 0x9A5B00
        static let s800: UInt32 = 0x7A4700
        static let s900: UInt32 = 0x40300C
        static let s950: UInt32 = 0x33260A
    }

    enum Red {
        static let s50: UInt32 = 0xFDECEC
        static let s100: UInt32 = 0xFBDADA
        static let s200: UInt32 = 0xFF9C96
        static let s300: UInt32 = 0xFF6B63
        static let s350: UInt32 = 0xFF6961
        static let s550: UInt32 = 0xD42A22
        static let s600: UInt32 = 0xD70015
        static let s650: UInt32 = 0xC4001A
        static let s700: UInt32 = 0xB0000F
        static let s750: UInt32 = 0x9E0012
        static let s900: UInt32 = 0x4A1A17
        static let s950: UInt32 = 0x3A1513
    }
}
