import Foundation

// MARK: - Track Library (15 tracks)
let trackLibrary: [Track] = [
    Track(id: "t1",  title: "Velvet Static",      artist: "Marina Lune",      dur: 214),
    Track(id: "t2",  title: "Парус",               artist: "Ария Зимы",        dur: 278),
    Track(id: "t3",  title: "Analog Afternoon",   artist: "The Softlines",    dur: 195),
    Track(id: "t4",  title: "Медленный Рассвет",   artist: "Океан Шёпота",     dur: 342),
    Track(id: "t5",  title: "Tape Hiss Lullaby",  artist: "Jules Cartier",    dur: 261),
    Track(id: "t6",  title: "Orange Room",        artist: "Hanna Vale",       dur: 228),
    Track(id: "t7",  title: "Полночная плёнка",    artist: "Нина Волк",        dur: 312),
    Track(id: "t8",  title: "Solstice Drive",     artist: "Paper Pilots",     dur: 246),
    Track(id: "t9",  title: "Июньский дождь",      artist: "Кислород",         dur: 198),
    Track(id: "t10", title: "Postcards",          artist: "Low Tide Choir",   dur: 233),
    Track(id: "t11", title: "Мягкий свет",         artist: "Тёплый Сигнал",    dur: 287),
    Track(id: "t12", title: "Ferris Wheel",       artist: "Sara Ono",         dur: 204),
    Track(id: "t13", title: "Ночной троллейбус",   artist: "Полночь 68",       dur: 256),
    Track(id: "t14", title: "Honey Radio",        artist: "Brine & Co.",      dur: 221),
    Track(id: "t15", title: "Первый снег",         artist: "Листопад",         dur: 308),
]

private let t = trackLibrary

// MARK: - Seed Cassettes
let seedCassettes: [Cassette] = [
    Cassette(
        id: "cas1",
        title: "Летний микс",
        subtitle: "для долгой дороги",
        type: .c90,
        cover: CassetteCover(style: .peach, label: "летний\nмикс", year: "26"),
        sideA: [t[0], t[2], t[5], t[7], t[11]],
        sideB: [t[9], t[13], t[4], t[3]],
        updatedAt: Date().addingTimeInterval(-172800)   // 2 days ago
    ),
    Cassette(
        id: "cas2",
        title: "Тихий вечер",
        subtitle: "для чтения",
        type: .c60,
        cover: CassetteCover(style: .lavender, label: "тихий\nвечер", year: "26"),
        sideA: [t[1], t[6], t[8]],
        sideB: [t[10], t[12]],
        updatedAt: Date().addingTimeInterval(-86400)    // yesterday
    ),
    Cassette(
        id: "cas3",
        title: "Ноябрь",
        subtitle: "мягкая осень",
        type: .c60,
        cover: CassetteCover(style: .mint, label: "ноябрь\n26", year: "26"),
        sideA: [t[14], t[3], t[6]],
        sideB: [t[1], t[10]],
        updatedAt: Date().addingTimeInterval(-432000)   // 5 days ago
    ),
]
