// 数据管理工具类
import { IntakeRecord } from './CaffeineCalculator';
import common from '@ohos.app.ability.common';
import preferences from '@ohos.data.preferences';

// 偏好设置配置接口
interface PreferencesOptions {
  name: string;
}

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

// 存储记录接口
interface StoredRecord {
  id: number;
  amount: number;
  time: string;
  beverageName: string;
}

// 数据验证结果接口
interface ValidationResult {
  isValid: boolean;
  error?: string;
}

// 备份数据接口
interface BackupData {
  records: IntakeRecord[];
  settings: UserSettings;
  backupTime: string;
  version: string;
}

// 数据管理类
export class DataManager {
  private static readonly STORAGE_KEY = 'caffeine_intake_records';
  private static readonly SETTINGS_KEY = 'user_settings';
  private static readonly MAX_RECORDS = 1000; // 最大记录数限制

  // 验证上下文
  private static validateContext(context: common.Context): ValidationResult {
    if (!context) {
      return { isValid: false, error: '上下文为空' };
    }
    
    if (!context.resourceManager) {
      return { isValid: false, error: '资源管理器不可用' };
    }
    
    return { isValid: true };
  }

  // 验证记录数据
  private static validateRecord(record: IntakeRecord): ValidationResult {
    if (!record) {
      return { isValid: false, error: '记录为空' };
    }
    
    if (record.amount <= 0) {
      return { isValid: false, error: '摄入量必须大于0' };
    }
    
    if (!record.time || isNaN(record.time.getTime())) {
      return { isValid: false, error: '时间无效' };
    }
    
    if (!record.beverageName || record.beverageName.trim() === '') {
      return { isValid: false, error: '饮料名称不能为空' };
    }
    
    return { isValid: true };
  }

  // 获取所有摄入记录
  static async getIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
    // 验证上下文
    const contextValidation = DataManager.validateContext(context);
    if (!contextValidation.isValid) {
      console.error('上下文验证失败:', contextValidation.error);
      return [];
    }

    try {
      const options: PreferencesOptions = { name: DataManager.STORAGE_KEY };
      const prefs = await preferences.getPreferences(context, options);
      const recordsJson = await prefs.get('records', '[]') as string;
      
      if (!recordsJson || recordsJson === '[]') {
        return [];
      }
      
      // 安全解析JSON
      let recordsData: StoredRecord[];
      try {
        recordsData = JSON.parse(recordsJson);
      } catch (parseError) {
        console.error('JSON解析失败:', parseError);
        // 尝试恢复数据
        await prefs.delete('records');
        await prefs.flush();
        return [];
      }
      
      // 验证并转换记录数据
      const validRecords: IntakeRecord[] = [];
      for (const record of recordsData) {
        try {
          const intakeRecord = new IntakeRecord(record.amount, new Date(record.time), record.beverageName);
          intakeRecord.id = record.id;
          
          // 验证记录
          const validation = DataManager.validateRecord(intakeRecord);
          if (validation.isValid) {
            validRecords.push(intakeRecord);
          } else {
            console.warn('跳过无效记录:', validation.error);
          }
        } catch (error) {
          console.warn('记录转换失败:', error);
        }
      }
      
      return validRecords;
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
    // 验证上下文
    const contextValidation = DataManager.validateContext(context);
    if (!contextValidation.isValid) {
      console.error('上下文验证失败:', contextValidation.error);
      return false;
    }

    // 验证记录
    const recordValidation = DataManager.validateRecord(record);
    if (!recordValidation.isValid) {
      console.error('记录验证失败:', recordValidation.error);
      return false;
    }

    try {
      const options: PreferencesOptions = { name: DataManager.STORAGE_KEY };
      const prefs = await preferences.getPreferences(context, options);
      const existingRecords = await DataManager.getIntakeRecords(context);
      
      // 检查记录数量限制
      if (existingRecords.length >= DataManager.MAX_RECORDS) {
        console.warn('达到最大记录数限制，自动清理旧记录');
        // 保留最近500条记录
        const recentRecords = existingRecords.slice(-500);
        await DataManager.saveRecords(context, recentRecords);
        return false;
      }
      
      // 为新记录生成ID
      if (record.id === 0) {
        const maxId = existingRecords.length > 0 ? Math.max(...existingRecords.map(r => r.id)) : 0;
        record.id = maxId + 1;
      }
      
      const updatedRecords = [...existingRecords, record];
      
      return await DataManager.saveRecords(context, updatedRecords);
    } catch (error) {
      console.error('保存记录失败:', error);
      return false;
    }
  }

  // 保存记录列表
  private static async saveRecords(context: common.Context, records: IntakeRecord[]): Promise<boolean> {
    try {
      const options: PreferencesOptions = { name: DataManager.STORAGE_KEY };
      const prefs = await preferences.getPreferences(context, options);
      
      const storedRecords: StoredRecord[] = records.map((r): StoredRecord => {
        return {
          id: r.id,
          amount: r.amount,
          time: r.time.toISOString(),
          beverageName: r.beverageName
        };
      });
      
      const recordsJson = JSON.stringify(storedRecords);
      
      await prefs.put('records', recordsJson);
      await prefs.flush();
      
      console.log('记录保存成功，当前记录数:', records.length);
      return true;
    } catch (error) {
      console.error('保存记录列表失败:', error);
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
    // 验证上下文
    const contextValidation = DataManager.validateContext(context);
    if (!contextValidation.isValid) {
      console.error('上下文验证失败:', contextValidation.error);
      return new UserSettings();
    }

    try {
      const options: PreferencesOptions = { name: DataManager.SETTINGS_KEY };
      const prefs = await preferences.getPreferences(context, options);

      const settings = new UserSettings();
      
      // 安全获取设置值
      settings.weight = Number(await prefs.get('weight', 0)) || 0;
      settings.age = Number(await prefs.get('age', 0)) || 0;
      settings.gender = String(await prefs.get('gender', '')) || '';
      settings.wakeUpTime = String(await prefs.get('wakeUpTime', '07:30')) || '07:30';
      settings.bedtime = String(await prefs.get('bedtime', '23:00')) || '23:00';
      settings.sensitivity = String(await prefs.get('sensitivity', '')) || '';
      settings.dailyLimit = Number(await prefs.get('dailyLimit', 400)) || 400;
      settings.reminderLevel = String(await prefs.get('reminderLevel', '')) || '';
      settings.pushNotifications = Boolean(await prefs.get('pushNotifications', true));
      settings.soundNotifications = Boolean(await prefs.get('soundNotifications', true));
      settings.vibrationNotifications = Boolean(await prefs.get('vibrationNotifications', true));
      settings.nightMode = Boolean(await prefs.get('nightMode', false));

      return settings;
    } catch (error) {
      console.error('获取用户设置失败:', error);
      return new UserSettings(); // 返回默认设置
    }
  }

  // 保存用户设置
  static async saveUserSettings(context: common.Context, settings: UserSettings): Promise<boolean> {
    // 验证上下文
    const contextValidation = DataManager.validateContext(context);
    if (!contextValidation.isValid) {
      console.error('上下文验证失败:', contextValidation.error);
      return false;
    }

    // 验证设置数据
    if (!settings) {
      console.error('设置数据为空');
      return false;
    }

    try {
      const options: PreferencesOptions = { name: DataManager.SETTINGS_KEY };
      const prefs = await preferences.getPreferences(context, options);

      // 安全设置值
      await prefs.put('weight', Math.max(0, settings.weight));
      await prefs.put('age', Math.max(0, Math.min(150, settings.age)));
      await prefs.put('gender', settings.gender || '');
      await prefs.put('wakeUpTime', settings.wakeUpTime || '07:30');
      await prefs.put('bedtime', settings.bedtime || '23:00');
      await prefs.put('sensitivity', settings.sensitivity || '');
      await prefs.put('dailyLimit', Math.max(0, settings.dailyLimit));
      await prefs.put('reminderLevel', settings.reminderLevel || '');
      await prefs.put('pushNotifications', Boolean(settings.pushNotifications));
      await prefs.put('soundNotifications', Boolean(settings.soundNotifications));
      await prefs.put('vibrationNotifications', Boolean(settings.vibrationNotifications));
      await prefs.put('nightMode', Boolean(settings.nightMode));

      await prefs.flush();
      console.log('用户设置保存成功');
      return true;
    } catch (error) {
      console.error('保存用户设置失败:', error);
      return false;
    }
  }

  // 清除所有记录
  static async clearAllRecords(context: common.Context): Promise<boolean> {
    // 验证上下文
    const contextValidation = DataManager.validateContext(context);
    if (!contextValidation.isValid) {
      console.error('上下文验证失败:', contextValidation.error);
      return false;
    }

    try {
      const options: PreferencesOptions = { name: DataManager.STORAGE_KEY };
      const prefs = await preferences.getPreferences(context, options);
      await prefs.delete('records');
      await prefs.flush();
      console.log('所有记录已清除');
      return true;
    } catch (error) {
      console.error('清除记录失败:', error);
      return false;
    }
  }
  
  // 清除过期记录（24小时前的记录）
  static async clearExpiredRecords(context: common.Context): Promise<boolean> {
    // 验证上下文
    const contextValidation = DataManager.validateContext(context);
    if (!contextValidation.isValid) {
      console.error('上下文验证失败:', contextValidation.error);
      return false;
    }

    try {
      const records = await DataManager.getIntakeRecords(context);
      const now = new Date();
      const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
      
      const activeRecords = records.filter(record => record.time >= twentyFourHoursAgo);
      
      return await DataManager.saveRecords(context, activeRecords);
    } catch (error) {
      console.error('清除过期记录失败:', error);
      return false;
    }
  }

  // 备份数据
  static async backupData(context: common.Context): Promise<string> {
    try {
      const records = await DataManager.getIntakeRecords(context);
      const settings = await DataManager.getUserSettings(context);
      
      const backupData: BackupData = {
        records: records,
        settings: settings,
        backupTime: new Date().toISOString(),
        version: '1.0.0'
      };
      
      return JSON.stringify(backupData);
    } catch (error) {
      console.error('备份数据失败:', error);
      throw new Error(`备份数据失败: ${error}`);
    }
  }
}

// 导出便捷函数 - 修复独立函数中的this使用问题
export async function addIntakeRecord(context: common.Context, record: IntakeRecord): Promise<boolean> {
  return await DataManager.addIntakeRecord(context, record);
}

export async function getIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
  return await DataManager.getIntakeRecords(context);
}

export async function getTodayIntakeRecords(context: common.Context): Promise<IntakeRecord[]> {
  return await DataManager.getTodayIntakeRecords(context);
}

export async function getTodayIntake(context: common.Context): Promise<number> {
  return await DataManager.getTodayIntake(context);
}

export async function getUserSettings(context: common.Context): Promise<UserSettings> {
  return await DataManager.getUserSettings(context);
}

export async function saveUserSettings(context: common.Context, settings: UserSettings): Promise<boolean> {
  return await DataManager.saveUserSettings(context, settings);
}

export async function clearAllRecords(context: common.Context): Promise<boolean> {
  return await DataManager.clearAllRecords(context);
}

export async function clearExpiredRecords(context: common.Context): Promise<boolean> {
  return await DataManager.clearExpiredRecords(context);
}

export async function backupData(context: common.Context): Promise<string> {
  return await DataManager.backupData(context);
}