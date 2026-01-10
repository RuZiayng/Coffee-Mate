// 用户数据模型
export class UserData {
  // 基础信息
  weight: number = 0;          // 体重 (kg)
  age: number = 0;             // 年龄
  gender: string = '';         // 性别：'male'/'female'/'prefer_not_to_say'
  
  // 作息时间
  wakeUpTime: string = '07:30'; // 起床时间
  bedtime: string = '23:00';    // 就寝时间
  
  // 咖啡因相关设置
  sensitivity: string = '';    // 敏感度：'low'/'medium'/'high'
  dailyLimit: number = 400;    // 每日上限 (mg)
  reminderLevel: string = '';  // 提醒强度：'gentle'/'standard'/'strict'
  
  constructor() {
    // 默认值
  }
}

// 性别选项接口
export interface GenderOption {
  label: string;
  value: string;
}

// 性别选项
export const GENDER_OPTIONS: GenderOption[] = [
  { label: '男', value: 'male' },
  { label: '女', value: 'female' },
  { label: '不愿透露', value: 'prefer_not_to_say' }
];

// 敏感度选项接口
export interface SensitivityOption {
  label: string;
  value: string;
}

// 敏感度选项
export const SENSITIVITY_OPTIONS: SensitivityOption[] = [
  { label: '低', value: 'low' },
  { label: '中', value: 'medium' },
  { label: '高', value: 'high' }
];

// 提醒强度选项接口
export interface ReminderOption {
  label: string;
  value: string;
}

// 提醒强度选项
export const REMINDER_OPTIONS: ReminderOption[] = [
  { label: '温和', value: 'gentle' },
  { label: '标准', value: 'standard' },
  { label: '严格', value: 'strict' }
];