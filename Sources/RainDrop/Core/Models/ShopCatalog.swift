import Foundation

enum ShopCatalog {
    static let allItems: [ShopItem] = [
        // 기본
        ShopItem(id: "sticker_star", name: "별", description: "반짝이는 별 스티커", price: 1, emoji: "⭐", category: "기본"),
        ShopItem(id: "sticker_heart", name: "하트", description: "따뜻한 하트 스티커", price: 1, emoji: "❤️", category: "기본"),
        ShopItem(id: "sticker_fire", name: "불꽃", description: "열정의 불꽃", price: 2, emoji: "🔥", category: "기본"),
        ShopItem(id: "sticker_sparkle", name: "반짝", description: "빛나는 반짝이", price: 1, emoji: "✨", category: "기본"),

        // 자연
        ShopItem(id: "sticker_flower", name: "꽃", description: "아름다운 꽃", price: 2, emoji: "🌸", category: "자연"),
        ShopItem(id: "sticker_rainbow", name: "무지개", description: "행운의 무지개", price: 3, emoji: "🌈", category: "자연"),
        ShopItem(id: "sticker_leaf", name: "나뭇잎", description: "싱그러운 나뭇잎", price: 1, emoji: "🍀", category: "자연"),
        ShopItem(id: "sticker_sun", name: "해", description: "밝은 태양", price: 2, emoji: "☀️", category: "자연"),

        // 동물
        ShopItem(id: "sticker_cat", name: "고양이", description: "귀여운 고양이", price: 3, emoji: "🐱", category: "동물"),
        ShopItem(id: "sticker_dog", name: "강아지", description: "충성스러운 강아지", price: 3, emoji: "🐶", category: "동물"),
        ShopItem(id: "sticker_fish", name: "물고기", description: "양동이 속 물고기", price: 2, emoji: "🐟", category: "동물"),
        ShopItem(id: "sticker_butterfly", name: "나비", description: "예쁜 나비", price: 2, emoji: "🦋", category: "동물"),
    ]

    static let categories: [String] = Array(Set(allItems.map(\.category))).sorted()

    static func item(for id: String) -> ShopItem? {
        allItems.first { $0.id == id }
    }
}
