import SwiftUI

// MARK: - Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255, int>>16, int>>8 & 0xFF, int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24, int>>16 & 0xFF, int>>8 & 0xFF, int & 0xFF)
        default: (a,r,g,b) = (255, 200, 200, 200)
        }
        self.init(
            .sRGB,
            red:     Double(r) / 255,
            green:   Double(g) / 255,
            blue:    Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Palette
extension Color {
    // Backgrounds
    static let bgCream      = Color(hex: "#F6F0E6")
    static let bgCreamDeep  = Color(hex: "#EEE4D2")
    static let bgInk        = Color(hex: "#1A1512")

    // Text
    static let textPrimary   = Color(hex: "#231B15")
    static let textSecondary = Color(hex: "#231B15").opacity(0.58)
    static let textTertiary  = Color(hex: "#231B15").opacity(0.34)
    static let textOnInk     = Color(hex: "#F6F0E6")

    // Pastels
    static let pastelPeach        = Color(hex: "#FFD6BA")
    static let pastelPeachDeep    = Color(hex: "#FFA27A")
    static let pastelLavender     = Color(hex: "#D9C7F5")
    static let pastelLavenderDeep = Color(hex: "#9F7FE0")
    static let pastelMint         = Color(hex: "#BFE8D4")
    static let pastelMintDeep     = Color(hex: "#6AC89A")
    static let pastelButter       = Color(hex: "#FFE8A3")
    static let pastelButterDeep   = Color(hex: "#F5D06B")
    static let pastelRose         = Color(hex: "#FFC3D0")
    static let pastelRoseDeep     = Color(hex: "#F5859B")
    static let pastelSky          = Color(hex: "#BEDCF7")
    static let pastelSkyDeep      = Color(hex: "#82B6E8")

    // Semantic
    static let danger  = Color(hex: "#E85D5D")
    static let success = Color(hex: "#6AC89A")
    static let accent  = Color(hex: "#9F7FE0")
}

// MARK: - Spacing
enum Spacing {
    static let s1:  CGFloat = 4
    static let s2:  CGFloat = 8
    static let s3:  CGFloat = 12
    static let s4:  CGFloat = 16
    static let s5:  CGFloat = 20
    static let s6:  CGFloat = 24
    static let s8:  CGFloat = 32
    static let s10: CGFloat = 40
    static let s12: CGFloat = 48
    static let s16: CGFloat = 64
}

// MARK: - Corner Radii
enum Radius {
    static let xs:     CGFloat = 6
    static let sm:     CGFloat = 10
    static let md:     CGFloat = 14
    static let lg:     CGFloat = 20
    static let xl:     CGFloat = 26
    static let xxl:    CGFloat = 32
    static let device: CGFloat = 48
    static let pill:   CGFloat = 999
}

// MARK: - Warm shadow helpers
extension View {
    func warmShadowCard() -> some View {
        self
            .shadow(color: Color(hex: "#785028").opacity(0.08), radius: 8, x: 0, y: 2)
            .shadow(color: Color(hex: "#785028").opacity(0.04), radius: 2, x: 0, y: 1)
    }

    func warmShadowCassette() -> some View {
        self
            .shadow(color: Color(hex: "#5A3214").opacity(0.22), radius: 40, x: 0, y: 18)
            .shadow(color: Color(hex: "#5A3214").opacity(0.14), radius: 12, x: 0, y: 4)
    }
}
