// 数据管理工具类
import { IntakeRecord } from './CaffeineCalculator';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

// 用户设置类
export class UserSettings {
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
  
  // 应用设置
  pushNotifications: boolean = true;    // 推送提醒
  soundNotifications: boolean = true;   // 声音提醒
  vibrationNotifications: boolean = true; // 振动提醒
  nightMode: boolean = false;           // 夜间模式
  
  constructor() {
    // 默认值
  }
}

// 数据管理工具类
export class DataManager {
  private static readonly STORAGE_KEY = 'caffeine_intake_records';
  private static readonly SETTINGS_KEY = 'user_settings';
  
  // 获取Preferences实例
  private static async getPreferences(context: common.Context, key: string): Promise<preferences.Preferences> {
    return await preferences.getPreferences(context, { name: key });
  }
  
  // 获取所有摄入记录
  static async getIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
    try {
      const prefs = await this.getPreferences(context, this.STORAGE_KEY);
      const recordsJson = await prefs.get('records', '[]') as string;
      
      if (recordsJson === '[]') {
        return [];
      }
      
      const recordsData = JSON.parse(recordsJson);
      return recordsData.map((recordData: any) => 
        new IntakeRecord(recordData.amount, new Date(recordData.time), recordData.beverageName)
      );
    } catch (error) {
      console.error('获取记录失败:', error);
      return [];
    }
  }
  
  // 获取今日摄入记录
  static async getTodayIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
    try {
      const records = await DataManager.getIntakeRecords(context);
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      return records.filter(record => 
        record.time >= today
      );
    } catch (error) {
      console.error('获取今日记录失败:', error);
      return [];
    }
  }
  
  // 添加摄入记录
  static async addIntakeRecord(context: common.Context, record: IntakeRecord): Promise<boolean> {
    try {
      const records = await this.getIntakeRecords(context);
      
      // 为新记录生成ID
      record.id = records.length > 0 ? Math.max(...records.map(r => r.id)) + 1 : 1;
      
      // 添加新记录
      records.push(record);
      
      // 保存到Preferences
      const prefs = await this.getPreferences(context, this.STORAGE_KEY);
      const recordsJson = JSON.stringify(records.map(r => ({
        id: r.id,
        amount: r.amount,
        time: r.time.toISOString(),
        beverageName: r.beverageName
      })));
      
      await prefs.put('records', recordsJson);
      await prefs.flush();
      
      console.log('记录保存成功:', record);
      return true;
    } catch (error) {
      console.error('保存记录失败:', error);
      return false;
    }
  }
  
  // 获取今日摄入总量
  static async getTodayIntake(context: common.Context): Promise<number> {
    try {
      const records = await DataManager.getTodayIntakeRecords(context);
      return records.reduce((total, record) => total + record.amount, 0);
    } catch (error) {
      console.error('计算今日摄入量失败:', error);
      return 0;
    }
  }
  
  // 获取用户设置
  static async getUserSettings(context: common.Context): Promise<UserSettings> {
    try {
      const prefs = await this.getPreferences(context, this.SETTINGS_KEY);
      
      const settings = new UserSettings();
      settings.weight = await prefs.get('weight', 0) as number;
      settings.age = await prefs.get('age', 0) as number;
      settings.gender = await prefs.get('gender', '') as string;
      settings.wakeUpTime = await prefs.get('wakeUpTime', '07:30') as string;
      settings.bedtime = await prefs.get('bedtime', '23:00') as string;
      settings.sensitivity = await prefs.get('sensitivity', '') as string;
      settings.dailyLimit = await prefs.get('dailyLimit', 400) as number;
      settings.reminderLevel = await prefs.get('reminderLevel', '') as string;
      settings.pushNotifications = await prefs.get('pushNotifications', true) as boolean;
      settings.soundNotifications = await prefs.get('soundNotifications', true) as boolean;
      settings.vibrationNotifications = await prefs.get('vibrationNotifications', true) as boolean;
      settings.nightMode = await prefs.get('nightMode', false) as boolean;
      
      return settings;
    } catch (error) {
      console.error('获取用户设置失败:', error);
      return new UserSettings(); // 返回默认设置
    }
  }
  
  // 保存用户设置
  static async saveUserSettings(context: common.Context, settings: UserSettings): Promise<boolean> {
    try {
      const prefs = await this.getPreferences(context, this.SETTINGS_KEY);
      
      await prefs.put('weight', settings.weight);
      await prefs.put('age', settings.age);
      await prefs.put('gender', settings.gender);
      await prefs.put('wakeUpTime', settings.wakeUpTime);
      await prefs.put('bedtime', settings.bedtime);
      await prefs.put('sensitivity', settings.sensitivity);
      await prefs.put('dailyLimit', settings.dailyLimit);
      await prefs.put('reminderLevel', settings.reminderLevel);
      await prefs.put('pushNotifications', settings.pushNotifications);
      await prefs.put('soundNotifications', settings.soundNotifications);
      await prefs.put('vibrationNotifications', settings.vibrationNotifications);
      await prefs.put('nightMode', settings.nightMode);
      
      await prefs.flush();
      console.log('用户设置保存成功');
      return true;
    } catch (error) {
      console.error('保存用户设置失败:', error);
      return false;
    }
  }
  
  // 清除所有记录（用于测试）
  static async clearAllRecords(context: common.Context): Promise<boolean> {
    try {
      const prefs = await this.getPreferences(context, this.STORAGE_KEY);
      await prefs.put('records', '[]');
      await prefs.flush();
      console.log('所有记录已清除');
      return true;
    } catch (error) {
      console.error('清除记录失败:', error);
      return false;
    }
  }
  
  // 清除用户设置（用于测试）
  static async clearUserSettings(context: common.Context): Promise<boolean> {
    try {
      const prefs = await this.getPreferences(context, this.SETTINGS_KEY);
      await prefs.clear();
      await prefs.flush();
      console.log('用户设置已清除');
      return true;
    } catch (error) {
      console.error('清除用户设置失败:', error);
      return false;
    }
  }
}

// 导出便捷函数
export async function addIntakeRecord(context: common.Context, record: IntakeRecord): Promise<boolean> {
  return DataManager.addIntakeRecord(context, record);
}

export async function getIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
  return DataManager.getIntakeRecords(context);
}

export async function getTodayIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
  return DataManager.getTodayIntakeRecords(context);
}

export async function getTodayIntake(context: common.Context): Promise<number> {
  return DataManager.getTodayIntake(context);
}

export async function getUserSettings(context: common.Context): Promise<UserSettings> {
  return DataManager.getUserSettings(context);
}

export async function saveUserSettings(context: common.Context, settings: UserSettings): Promise<boolean> {
  return DataManager.saveUserSettings(context, settings);
}

export async function clearAllRecords(context: common.Context): Promise<boolean> {
  return DataManager.clearAllRecords(context);
}

export async function clearUserSettings(context: common.Context): Promise<boolean> {
  return DataManager.clearUserSettings(context);
}