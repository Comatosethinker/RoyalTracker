import Foundation

enum CardRarity: String, CaseIterable, Codable {
    case common = "普通"
    case rare = "稀有"
    case epic = "史诗"
    case legendary = "传奇"
    case champion = "英雄"
}

struct BattleCard: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let elixir: Int
    let rarity: CardRarity
    let category: String
}

enum CardCatalog {
    static let cards: [BattleCard] = [
        .init(id: "knight", name: "骑士", elixir: 3, rarity: .common, category: "军队"),
        .init(id: "archers", name: "弓箭手", elixir: 3, rarity: .common, category: "军队"),
        .init(id: "goblins", name: "哥布林", elixir: 2, rarity: .common, category: "军队"),
        .init(id: "spear-goblins", name: "投矛哥布林", elixir: 2, rarity: .common, category: "军队"),
        .init(id: "bomber", name: "炸弹兵", elixir: 2, rarity: .common, category: "军队"),
        .init(id: "skeletons", name: "骷髅兵", elixir: 1, rarity: .common, category: "军队"),
        .init(id: "minions", name: "亡灵", elixir: 3, rarity: .common, category: "军队"),
        .init(id: "bats", name: "蝙蝠", elixir: 2, rarity: .common, category: "军队"),
        .init(id: "fire-spirit", name: "烈焰精灵", elixir: 1, rarity: .common, category: "军队"),
        .init(id: "ice-spirit", name: "冰雪精灵", elixir: 1, rarity: .common, category: "军队"),
        .init(id: "electro-spirit", name: "电击精灵", elixir: 1, rarity: .common, category: "军队"),
        .init(id: "mortar", name: "迫击炮", elixir: 4, rarity: .common, category: "建筑"),
        .init(id: "cannon", name: "加农炮", elixir: 3, rarity: .common, category: "建筑"),
        .init(id: "arrows", name: "万箭齐发", elixir: 3, rarity: .common, category: "法术"),
        .init(id: "zap", name: "电击法术", elixir: 2, rarity: .common, category: "法术"),
        .init(id: "royal-giant", name: "皇家巨人", elixir: 6, rarity: .common, category: "军队"),
        .init(id: "elite-barbarians", name: "野蛮人精锐", elixir: 6, rarity: .common, category: "军队"),
        .init(id: "royal-recruits", name: "皇家卫队", elixir: 7, rarity: .common, category: "军队"),

        .init(id: "mini-pekka", name: "迷你皮卡", elixir: 4, rarity: .rare, category: "军队"),
        .init(id: "musketeer", name: "火枪手", elixir: 4, rarity: .rare, category: "军队"),
        .init(id: "giant", name: "巨人", elixir: 5, rarity: .rare, category: "军队"),
        .init(id: "hog-rider", name: "野猪骑士", elixir: 4, rarity: .rare, category: "军队"),
        .init(id: "valkyrie", name: "女武神", elixir: 4, rarity: .rare, category: "军队"),
        .init(id: "mega-minion", name: "重甲亡灵", elixir: 3, rarity: .rare, category: "军队"),
        .init(id: "battle-ram", name: "攻城槌", elixir: 4, rarity: .rare, category: "军队"),
        .init(id: "furnace", name: "烈焰熔炉", elixir: 4, rarity: .rare, category: "建筑"),
        .init(id: "inferno-tower", name: "地狱塔", elixir: 5, rarity: .rare, category: "建筑"),
        .init(id: "fireball", name: "火球", elixir: 4, rarity: .rare, category: "法术"),
        .init(id: "earthquake", name: "地震法术", elixir: 3, rarity: .rare, category: "法术"),
        .init(id: "royal-hogs", name: "皇家野猪", elixir: 5, rarity: .rare, category: "军队"),
        .init(id: "goblin-cage", name: "哥布林牢笼", elixir: 4, rarity: .rare, category: "建筑"),

        .init(id: "prince", name: "王子", elixir: 5, rarity: .epic, category: "军队"),
        .init(id: "baby-dragon", name: "飞龙宝宝", elixir: 4, rarity: .epic, category: "军队"),
        .init(id: "skeleton-army", name: "骷髅军团", elixir: 3, rarity: .epic, category: "军队"),
        .init(id: "witch", name: "女巫", elixir: 5, rarity: .epic, category: "军队"),
        .init(id: "pekka", name: "皮卡超人", elixir: 7, rarity: .epic, category: "军队"),
        .init(id: "golem", name: "戈仑石人", elixir: 8, rarity: .epic, category: "军队"),
        .init(id: "balloon", name: "气球兵", elixir: 5, rarity: .epic, category: "军队"),
        .init(id: "guards", name: "骷髅守卫", elixir: 3, rarity: .epic, category: "军队"),
        .init(id: "x-bow", name: "X连弩", elixir: 6, rarity: .epic, category: "建筑"),
        .init(id: "freeze", name: "冰冻法术", elixir: 4, rarity: .epic, category: "法术"),
        .init(id: "poison", name: "毒药法术", elixir: 4, rarity: .epic, category: "法术"),
        .init(id: "tornado", name: "飓风法术", elixir: 3, rarity: .epic, category: "法术"),
        .init(id: "barbarian-barrel", name: "野蛮人滚桶", elixir: 2, rarity: .epic, category: "法术"),
        .init(id: "goblin-drill", name: "哥布林钻机", elixir: 4, rarity: .epic, category: "建筑"),

        .init(id: "miner", name: "掘地矿工", elixir: 3, rarity: .legendary, category: "军队"),
        .init(id: "princess", name: "公主", elixir: 3, rarity: .legendary, category: "军队"),
        .init(id: "ice-wizard", name: "寒冰法师", elixir: 3, rarity: .legendary, category: "军队"),
        .init(id: "royal-ghost", name: "皇家幽灵", elixir: 3, rarity: .legendary, category: "军队"),
        .init(id: "bandit", name: "幻影刺客", elixir: 3, rarity: .legendary, category: "军队"),
        .init(id: "electro-wizard", name: "闪电法师", elixir: 4, rarity: .legendary, category: "军队"),
        .init(id: "inferno-dragon", name: "地狱飞龙", elixir: 4, rarity: .legendary, category: "军队"),
        .init(id: "mega-knight", name: "超级骑士", elixir: 7, rarity: .legendary, category: "军队"),
        .init(id: "lava-hound", name: "熔岩猎犬", elixir: 7, rarity: .legendary, category: "军队"),
        .init(id: "log", name: "滚木", elixir: 2, rarity: .legendary, category: "法术"),
        .init(id: "graveyard", name: "骷髅召唤", elixir: 5, rarity: .legendary, category: "法术"),

        .init(id: "golden-knight", name: "黄金骑士", elixir: 4, rarity: .champion, category: "军队"),
        .init(id: "archer-queen", name: "弓箭女皇", elixir: 5, rarity: .champion, category: "军队"),
        .init(id: "skeleton-king", name: "骷髅帝王", elixir: 4, rarity: .champion, category: "军队"),
        .init(id: "mighty-miner", name: "威猛矿工", elixir: 4, rarity: .champion, category: "军队"),
        .init(id: "monk", name: "武僧", elixir: 5, rarity: .champion, category: "军队"),
        .init(id: "little-prince", name: "小王子", elixir: 3, rarity: .champion, category: "军队")
    ].sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
}
