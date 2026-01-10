// 用户配置文件模型
export class UserProfile {
  // 基础信息
  weight: number = 65; // 体重(kg)
  age: number = 25; // 年龄
  gender: 'male' | 'female' = 'male'; // 性别
  
  // 作息时间
  wakeUpTime: string = '08:00'; // 起床时间
  bedTime: string = '23:00'; // 就寝时间
  
  // 咖啡因相关
  caffeineSensitivity: 'low' | 'medium' | 'high' = 'medium'; // 咖啡因敏感度
  dailyLimit: number = 400; // 每日上限(mg)
  
  // 系统信息
  isOnboardingComplete: boolean = false; // 是否完成引导
  lastUpdateTime: number = Date.now(); // 最后更新时间
  constructor(partial?: UserProfile) {
    if (partial) {
      // 手动赋值代替Object.assign
      this.weight = partial.weight ?? this.weight;
      this.age = partial.age ?? this.age;
      this.gender = partial.gender ?? this.gender;
      this.wakeUpTime = partial.wakeUpTime ?? this.wakeUpTime;
      this.bedTime = partial.bedTime ?? this.bedTime;
      this.caffeineSensitivity = partial.caffeineSensitivity ?? this.caffeineSensitivity;
      this.dailyLimit = partial.dailyLimit ?? this.dailyLimit;
      this.isOnboardingComplete = partial.isOnboardingComplete ?? this.isOnboardingComplete;
      this.lastUpdateTime = partial.lastUpdateTime ?? this.lastUpdateTime;
    }
  }
  
  // 计算个性化每日上限
  calculateDailyLimit(): number {
    let baseLimit = 400; // 标准400mg
    
    // 根据体重调整
    const weightFactor = this.weight / 70; // 以70kg为标准
    baseLimit = Math.round(baseLimit * weightFactor);
    
    // 根据年龄调整
    if (this.age > 60) {
      baseLimit = Math.round(baseLimit * 0.8);
    } else if (this.age < 18) {
      baseLimit = Math.round(baseLimit * 0.6);
    }
    // 根据敏感度调整
    let sensitivityFactor = 1.0;
    if (this.caffeineSensitivity === 'low') {
      sensitivityFactor = 1.2;
    } else if (this.caffeineSensitivity === 'high') {
      sensitivityFactor = 0.8;
    }
    baseLimit = Math.round(baseLimit * sensitivityFactor);
    
    return Math.max(200, Math.min(600, baseLimit)); // 限制在200-600mg之间
  }
}