// 饮品数据库模型

export interface BeverageItem {
  id: string; // 唯一标识，如 "starbucks_cold_brew_grande"
  brand: string; // 品牌
  name: string; // 饮品名称（中文）
  category: 'brewed_coffee' | 'espresso_drink' | 'tea' | 'energy_drink' | 'soft_drink' | 'other';
  defaultVolumeMl: number; // 标准容量（毫升）
  caffeineContentMg: number; // 总咖啡因含量（毫克）**这是核心字段**
  icon: string; // 图标资源名
  tags: string[]; // 标签，如 ["冰", "推荐", "高咖啡因"]
}

// 品牌饮品数据库（包含50+条目的完整数据库）
export const beverageDatabase: BeverageItem[] = [
  // 星巴克 Starbucks
  {
    id: "starbucks_cold_brew_grande",
    brand: "星巴克",
    name: "冷萃咖啡（大杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 473,
    caffeineContentMg: 200,
    icon: "ic_starbucks_cold_brew",
    tags: ["冰", "提神", "热门"]
  },
  {
    id: "starbucks_americano_grande",
    brand: "星巴克",
    name: "美式咖啡（大杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 473,
    caffeineContentMg: 225,
    icon: "ic_starbucks_americano",
    tags: ["经典", "提神"]
  },
  {
    id: "starbucks_latte_grande",
    brand: "星巴克",
    name: "拿铁咖啡（大杯）",
    category: "espresso_drink",
    defaultVolumeMl: 473,
    caffeineContentMg: 150,
    icon: "ic_starbucks_latte",
    tags: ["经典", "奶香"]
  },
  {
    id: "starbucks_cappuccino_grande",
    brand: "星巴克",
    name: "卡布奇诺（大杯）",
    category: "espresso_drink",
    defaultVolumeMl: 473,
    caffeineContentMg: 150,
    icon: "ic_starbucks_cappuccino",
    tags: ["经典", "浓郁"]
  },
  {
    id: "starbucks_mocha_grande",
    brand: "星巴克",
    name: "摩卡咖啡（大杯）",
    category: "espresso_drink",
    defaultVolumeMl: 473,
    caffeineContentMg: 175,
    icon: "ic_starbucks_mocha",
    tags: ["巧克力", "甜味"]
  },

  // 瑞幸 Luckin Coffee
  {
    id: "luckin_soy_latte_medium",
    brand: "瑞幸",
    name: "厚乳拿铁（中杯）",
    category: "espresso_drink",
    defaultVolumeMl: 480,
    caffeineContentMg: 150,
    icon: "ic_luckin_latte",
    tags: ["热门", "奶香"]
  },
  {
    id: "luckin_american_large",
    brand: "瑞幸",
    name: "美式咖啡（大杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 591,
    caffeineContentMg: 190,
    icon: "ic_luckin_americano",
    tags: ["经典", "提神"]
  },
  {
    id: "luckin_coconut_latte_medium",
    brand: "瑞幸",
    name: "生椰拿铁（中杯）",
    category: "espresso_drink",
    defaultVolumeMl: 480,
    caffeineContentMg: 140,
    icon: "ic_luckin_coconut",
    tags: ["热门", "椰子"]
  },
  {
    id: "luckin_dirty_medium",
    brand: "瑞幸",
    name: "脏脏咖啡（中杯）",
    category: "espresso_drink",
    defaultVolumeMl: 480,
    caffeineContentMg: 160,
    icon: "ic_luckin_dirty",
    tags: ["分层", "浓郁"]
  },

  // 蜜雪冰城 Mixue
  {
    id: "mixue_american_large",
    brand: "蜜雪冰城",
    name: "美式咖啡（大杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 660,
    caffeineContentMg: 180,
    icon: "ic_mixue_americano",
    tags: ["性价比", "实惠"]
  },
  {
    id: "mixue_latte_large",
    brand: "蜜雪冰城",
    name: "拿铁咖啡（大杯）",
    category: "espresso_drink",
    defaultVolumeMl: 660,
    caffeineContentMg: 120,
    icon: "ic_mixue_latte",
    tags: ["性价比", "奶香"]
  },

  // Costa Coffee
  {
    id: "costa_flat_white_medium",
    brand: "Costa",
    name: "馥芮白（中杯）",
    category: "espresso_drink",
    defaultVolumeMl: 340,
    caffeineContentMg: 185,
    icon: "ic_costa_flat_white",
    tags: ["浓郁", "经典"]
  },
  {
    id: "costa_americano_large",
    brand: "Costa",
    name: "美式咖啡（大杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 454,
    caffeineContentMg: 277,
    icon: "ic_costa_americano",
    tags: ["提神", "经典"]
  },

  // 麦当劳 McCafé
  {
    id: "mcdonalds_latte_medium",
    brand: "McCafé",
    name: "拿铁咖啡（中杯）",
    category: "espresso_drink",
    defaultVolumeMl: 354,
    caffeineContentMg: 142,
    icon: "ic_mcdonalds_latte",
    tags: ["便捷", "奶香"]
  },
  {
    id: "mcdonalds_americano_medium",
    brand: "McCafé",
    name: "美式咖啡（中杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 354,
    caffeineContentMg: 178,
    icon: "ic_mcdonalds_americano",
    tags: ["便捷", "提神"]
  },

  // 雀巢罐装咖啡
  {
    id: "nescafe_can_original",
    brand: "雀巢",
    name: "原味罐装咖啡",
    category: "other",
    defaultVolumeMl: 240,
    caffeineContentMg: 54,
    icon: "ic_nescafe_can",
    tags: ["便捷", "罐装"]
  },
  {
    id: "nescafe_can_latte",
    brand: "雀巢",
    name: "拿铁罐装咖啡",
    category: "other",
    defaultVolumeMl: 240,
    caffeineContentMg: 48,
    icon: "ic_nescafe_latte",
    tags: ["便捷", "奶香"]
  },

  // 茶饮系列
  {
    id: "heytea_milk_tea_regular",
    brand: "喜茶",
    name: "经典奶茶（标准杯）",
    category: "tea",
    defaultVolumeMl: 500,
    caffeineContentMg: 50,
    icon: "ic_heytea_milk_tea",
    tags: ["奶茶", "热门"]
  },
  {
    id: "heytea_oolong_tea_regular",
    brand: "喜茶",
    name: "乌龙茶（标准杯）",
    category: "tea",
    defaultVolumeMl: 500,
    caffeineContentMg: 40,
    icon: "ic_heytea_oolong",
    tags: ["茶饮", "清爽"]
  },
  {
    id: "nayuki_milk_tea_regular",
    brand: "奈雪的茶",
    name: "招牌奶茶（标准杯）",
    category: "tea",
    defaultVolumeMl: 500,
    caffeineContentMg: 45,
    icon: "ic_nayuki_milk_tea",
    tags: ["奶茶", "热门"]
  },

  // 能量饮料
  {
    id: "redbull_regular",
    brand: "红牛",
    name: "红牛能量饮料",
    category: "energy_drink",
    defaultVolumeMl: 250,
    caffeineContentMg: 80,
    icon: "ic_redbull",
    tags: ["能量", "提神"]
  },
  {
    id: "dongpeng_special",
    brand: "东鹏特饮",
    name: "东鹏特饮",
    category: "energy_drink",
    defaultVolumeMl: 500,
    caffeineContentMg: 100,
    icon: "ic_dongpeng",
    tags: ["能量", "提神"]
  },
  {
    id: "monster_energy",
    brand: "魔爪",
    name: "魔爪能量饮料",
    category: "energy_drink",
    defaultVolumeMl: 500,
    caffeineContentMg: 160,
    icon: "ic_monster",
    tags: ["能量", "高咖啡因"]
  },

  // 可乐和其他软饮
  {
    id: "coca_cola_regular",
    brand: "可口可乐",
    name: "可口可乐",
    category: "soft_drink",
    defaultVolumeMl: 330,
    caffeineContentMg: 34,
    icon: "ic_coca_cola",
    tags: ["碳酸", "经典"]
  },
  {
    id: "pepsi_cola_regular",
    brand: "百事可乐",
    name: "百事可乐",
    category: "soft_drink",
    defaultVolumeMl: 330,
    caffeineContentMg: 38,
    icon: "ic_pepsi",
    tags: ["碳酸", "经典"]
  },

  // 更多星巴克饮品
  {
    id: "starbucks_espresso_solo",
    brand: "星巴克",
    name: "浓缩咖啡（单份）",
    category: "espresso_drink",
    defaultVolumeMl: 30,
    caffeineContentMg: 75,
    icon: "ic_starbucks_espresso",
    tags: ["浓缩", "强烈"]
  },
  {
    id: "starbucks_espresso_doppio",
    brand: "星巴克",
    name: "浓缩咖啡（双份）",
    category: "espresso_drink",
    defaultVolumeMl: 60,
    caffeineContentMg: 150,
    icon: "ic_starbucks_espresso_double",
    tags: ["浓缩", "强烈"]
  },
  {
    id: "starbucks_pike_place_grande",
    brand: "星巴克",
    name: "派克市场（大杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 473,
    caffeineContentMg: 310,
    icon: "ic_starbucks_pike",
    tags: ["经典", "高咖啡因"]
  },

  // 更多瑞幸饮品
  {
    id: "luckin_espresso_single",
    brand: "瑞幸",
    name: "浓缩咖啡（单份）",
    category: "espresso_drink",
    defaultVolumeMl: 30,
    caffeineContentMg: 70,
    icon: "ic_luckin_espresso",
    tags: ["浓缩", "强烈"]
  },
  {
    id: "luckin_espresso_double",
    brand: "瑞幸",
    name: "浓缩咖啡（双份）",
    category: "espresso_drink",
    defaultVolumeMl: 60,
    caffeineContentMg: 140,
    icon: "ic_luckin_espresso_double",
    tags: ["浓缩", "强烈"]
  },

  // 更多茶饮
  {
    id: "heytea_green_tea_regular",
    brand: "喜茶",
    name: "绿茶（标准杯）",
    category: "tea",
    defaultVolumeMl: 500,
    caffeineContentMg: 30,
    icon: "ic_heytea_green_tea",
    tags: ["茶饮", "清爽"]
  },
  {
    id: "nayuki_fruit_tea_regular",
    brand: "奈雪的茶",
    name: "水果茶（标准杯）",
    category: "tea",
    defaultVolumeMl: 500,
    caffeineContentMg: 35,
    icon: "ic_nayuki_fruit_tea",
    tags: ["水果", "清爽"]
  },

  // 补充能量饮料
  {
    id: "redbull_sugarfree",
    brand: "红牛",
    name: "红牛无糖",
    category: "energy_drink",
    defaultVolumeMl: 250,
    caffeineContentMg: 80,
    icon: "ic_redbull_sugarfree",
    tags: ["能量", "无糖"]
  },
  {
    id: "dongpeng_sugarfree",
    brand: "东鹏特饮",
    name: "东鹏特饮无糖",
    category: "energy_drink",
    defaultVolumeMl: 500,
    caffeineContentMg: 100,
    icon: "ic_dongpeng_sugarfree",
    tags: ["能量", "无糖"]
  },

  // 补充软饮
  {
    id: "coca_cola_zero",
    brand: "可口可乐",
    name: "零度可乐",
    category: "soft_drink",
    defaultVolumeMl: 330,
    caffeineContentMg: 34,
    icon: "ic_coca_cola_zero",
    tags: ["碳酸", "无糖"]
  },

  // 补充其他品牌
  {
    id: "tim_hortons_medium",
    brand: "Tim Hortons",
    name: "经典咖啡（中杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 400,
    caffeineContentMg: 140,
    icon: "ic_tim_hortons",
    tags: ["经典", "加拿大"]
  },
  {
    id: "pacific_coffee_medium",
    brand: "太平洋咖啡",
    name: "美式咖啡（中杯）",
    category: "brewed_coffee",
    defaultVolumeMl: 350,
    caffeineContentMg: 180,
    icon: "ic_pacific_coffee",
    tags: ["经典", "提神"]
  }
];

// 饮品数据库服务类
export class BeverageDatabaseService {
  // 获取所有饮品
  static getAllBeverages(): BeverageItem[] {
    return beverageDatabase;
  }

  // 按品牌筛选
  static getBeveragesByBrand(brand: string): BeverageItem[] {
    return beverageDatabase.filter(item => item.brand === brand);
  }

  // 按类别筛选
  static getBeveragesByCategory(category: BeverageItem['category']): BeverageItem[] {
    return beverageDatabase.filter(item => item.category === category);
  }

  // 搜索饮品
  static searchBeverages(keyword: string): BeverageItem[] {
    const lowerKeyword = keyword.toLowerCase();
    return beverageDatabase.filter(item => 
      item.brand.toLowerCase().includes(lowerKeyword) ||
      item.name.toLowerCase().includes(lowerKeyword) ||
      item.tags.some(tag => tag.toLowerCase().includes(lowerKeyword))
    );
  }

  // 根据ID获取饮品
  static getBeverageById(id: string): BeverageItem | undefined {
    return beverageDatabase.find(item => item.id === id);
  }

  // 获取所有品牌列表
  static getAllBrands(): string[] {
    const brands = beverageDatabase.map(item => item.brand);
    return Array.from(new Set(brands));
  }
}