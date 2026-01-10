import { relationalStore, preferences } from '@kit.ArkData';
// import { BusinessError } from '@kit.BasicServicesKit';
import { IntakeRecord } from './CaffeineCalculator';

// 用户设置类
export class UserSettings {
  weight: number = 70; // 体重(kg)
  age: number = 25; // 年龄
  dailyLimit: number = 400; // 每日上限(mg)
  wakeUpTime: string = '07:00'; // 起床时间
  bedtime: string = '23:00'; // 就寝时间
  sensitivity: string = '中等'; // 敏感度
  reminderLevel: string = '中度提醒'; // 提醒强度
  pushNotifications: boolean = true; // 推送提醒
  soundNotifications: boolean = true; // 声音提醒
  vibrationNotifications: boolean = true; // 振动提醒
  nightMode: boolean = false; // 夜间模式

  constructor(settings?: Partial<UserSettings>) {
    if (settings) {
      // 手动赋值属性
      if (settings.weight !== undefined) this.weight = settings.weight;
      if (settings.age !== undefined) this.age = settings.age;
      if (settings.dailyLimit !== undefined) this.dailyLimit = settings.dailyLimit;
      if (settings.wakeUpTime !== undefined) this.wakeUpTime = settings.wakeUpTime;
      if (settings.bedtime !== undefined) this.bedtime = settings.bedtime;
      if (settings.sensitivity !== undefined) this.sensitivity = settings.sensitivity;
      if (settings.reminderLevel !== undefined) this.reminderLevel = settings.reminderLevel;
      if (settings.pushNotifications !== undefined) this.pushNotifications = settings.pushNotifications;
      if (settings.soundNotifications !== undefined) this.soundNotifications = settings.soundNotifications;
      if (settings.vibrationNotifications !== undefined) this.vibrationNotifications = settings.vibrationNotifications;
      if (settings.nightMode !== undefined) this.nightMode = settings.nightMode;
    }
  }
}

// 数据库表结构定义
const DB_CONFIG: relationalStore.StoreConfig = {
  name: 'CoffeeMate.db',
  securityLevel: relationalStore.SecurityLevel.S1
};

const INTAKE_TABLE = 'intake_records';
const CREATE_INTAKE_TABLE_SQL = `
  CREATE TABLE IF NOT EXISTS ${INTAKE_TABLE} (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    amount REAL NOT NULL,
    time TEXT NOT NULL,
    beverage_name TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime'))
  )
`;

// Preferences键名
const PREF_WEIGHT = 'user_weight';
const PREF_AGE = 'user_age';
const PREF_DAILY_LIMIT = 'daily_limit';
const PREF_WAKE_UP_TIME = 'wake_up_time';
const PREF_BEDTIME = 'bedtime';
const PREF_SENSITIVITY = 'sensitivity';
const PREF_REMINDER_LEVEL = 'reminder_level';
const PREF_PUSH_NOTIFICATIONS = 'push_notifications';
const PREF_SOUND_NOTIFICATIONS = 'sound_notifications';
const PREF_VIBRATION_NOTIFICATIONS = 'vibration_notifications';
const PREF_NIGHT_MODE = 'night_mode';

let rdbStore: relationalStore.RdbStore | null = null;

/**
 * 初始化数据库
 */
export async function initializeDatabase(context: Context): Promise<void> {
  try {
    rdbStore = await relationalStore.getRdbStore(context, DB_CONFIG);
    await rdbStore.executeSql(CREATE_INTAKE_TABLE_SQL);
    console.info('数据库初始化成功');
  } catch (error) {
    console.error('数据库初始化失败:', error);
    // 在ArkTS中，throw语句有限制，使用return或处理错误
    return;
  }
}

// ========== Preferences 用户设置存储 ==========

/**
 * 保存用户设置
 */
export async function saveUserSettings(context: Context, settings: UserSettings): Promise<boolean> {
  try {
    // 使用Preferences API的正确方式
    const pref = await preferences.getPreferences(context, 'CoffeeMateSettings');
    
    await pref.put(PREF_WEIGHT, settings.weight.toString());
    await pref.put(PREF_AGE, settings.age.toString());
    await pref.put(PREF_DAILY_LIMIT, settings.dailyLimit.toString());
    await pref.put(PREF_WAKE_UP_TIME, settings.wakeUpTime);
    await pref.put(PREF_BEDTIME, settings.bedtime);
    await pref.put(PREF_SENSITIVITY, settings.sensitivity);
    await pref.put(PREF_REMINDER_LEVEL, settings.reminderLevel);
    await pref.put(PREF_PUSH_NOTIFICATIONS, settings.pushNotifications.toString());
    await pref.put(PREF_SOUND_NOTIFICATIONS, settings.soundNotifications.toString());
    await pref.put(PREF_VIBRATION_NOTIFICATIONS, settings.vibrationNotifications.toString());
    await pref.put(PREF_NIGHT_MODE, settings.nightMode.toString());
    
    await pref.flush();
    console.info('用户设置保存成功');
    return true;
  } catch (error) {
    console.error('保存用户设置失败:', error);
    return false;
  }
}

/**
 * 获取用户设置
 */
export async function getUserSettings(context: Context): Promise<UserSettings> {
  try {
    const settings = new UserSettings();
    const pref = await preferences.getPreferences(context, 'CoffeeMateSettings');
    const weight = await pref.get(PREF_WEIGHT, '70') as string;
    const age = await pref.get(PREF_AGE, '25') as string;
    const dailyLimit = await pref.get(PREF_DAILY_LIMIT, '400') as string;
    const wakeUpTime = await pref.get(PREF_WAKE_UP_TIME, '07:00') as string;
    const bedtime = await pref.get(PREF_BEDTIME, '23:00') as string;
    const sensitivity = await pref.get(PREF_SENSITIVITY, '中等') as string;
    const reminderLevel = await pref.get(PREF_REMINDER_LEVEL, '中度提醒') as string;
    const pushNotifications = await pref.get(PREF_PUSH_NOTIFICATIONS, 'true') as string;
    const soundNotifications = await pref.get(PREF_SOUND_NOTIFICATIONS, 'true') as string;
    const vibrationNotifications = await pref.get(PREF_VIBRATION_NOTIFICATIONS, 'true') as string;
    const nightMode = await pref.get(PREF_NIGHT_MODE, 'false') as string;
    
    settings.weight = parseFloat(weight);
    settings.age = parseInt(age);
    settings.dailyLimit = parseFloat(dailyLimit);
    settings.wakeUpTime = wakeUpTime;
    settings.bedtime = bedtime;
    settings.sensitivity = sensitivity;
    settings.reminderLevel = reminderLevel;
    settings.pushNotifications = pushNotifications === 'true';
    settings.soundNotifications = soundNotifications === 'true';
    settings.vibrationNotifications = vibrationNotifications === 'true';
    settings.nightMode = nightMode === 'false';
    
    return settings;
  } catch (error) {
    console.error('获取用户设置失败:', error);
    return new UserSettings(); // 返回默认设置
  }
}

// ========== RdbStore 摄入记录存储 ==========

/**
 * 添加摄入记录
 */
export async function addIntakeRecord(record: IntakeRecord): Promise<number> {
  if (!rdbStore) {
    console.error('数据库未初始化');
    return -1;
  }

  try {
    const valueBucket: relationalStore.ValuesBucket = {
      'amount': record.amount,
      'time': record.time.toISOString(),
      'beverage_name': record.beverageName
    };

    const rowId = await rdbStore.insert(INTAKE_TABLE, valueBucket);
    console.info(`摄入记录添加成功，ID: ${rowId}`);
    return rowId;
  } catch (error) {
    console.error('添加摄入记录失败:', error);
    return -1;
  }
}

/**
 * 获取所有摄入记录
 */
export async function getAllIntakeRecords(): Promise<IntakeRecord[]> {
  if (!rdbStore) {
    console.error('数据库未初始化');
    return [];
  }

  try {
    const predicates = new relationalStore.RdbPredicates(INTAKE_TABLE);
    predicates.orderByDesc('time');

    const resultSet = await rdbStore.query(predicates, ['id', 'amount', 'time', 'beverage_name']);
    
    const records: IntakeRecord[] = [];
    while (resultSet.goToNextRow()) {
      const record = new IntakeRecord(
        resultSet.getDouble(resultSet.getColumnIndex('amount')),
        new Date(resultSet.getString(resultSet.getColumnIndex('time'))),
        resultSet.getString(resultSet.getColumnIndex('beverage_name'))
      );
      record.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      records.push(record);
    }
    
    resultSet.close();
    return records;
  } catch (error) {
    console.error('获取摄入记录失败:', error);
    return [];
  }
}

/**
 * 获取今日摄入记录
 */
export async function getTodayIntakeRecords(): Promise<IntakeRecord[]> {
  if (!rdbStore) {
    console.error('数据库未初始化');
    return [];
  }

  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const predicates = new relationalStore.RdbPredicates(INTAKE_TABLE);
    predicates.greaterThanOrEqualTo('time', today.toISOString());
    predicates.orderByDesc('time');

    const resultSet = await rdbStore.query(predicates, ['id', 'amount', 'time', 'beverage_name']);
    
    const records: IntakeRecord[] = [];
    while (resultSet.goToNextRow()) {
      const record = new IntakeRecord(
        resultSet.getDouble(resultSet.getColumnIndex('amount')),
        new Date(resultSet.getString(resultSet.getColumnIndex('time'))),
        resultSet.getString(resultSet.getColumnIndex('beverage_name'))
      );
      record.id = resultSet.getLong(resultSet.getColumnIndex('id'));
      records.push(record);
    }
    
    resultSet.close();
    return records;
  } catch (error) {
    console.error('获取今日摄入记录失败:', error);
    return [];
  }
}

/**
 * 删除摄入记录
 */
export async function deleteIntakeRecord(id: number): Promise<number> {
  if (!rdbStore) {
    console.error('数据库未初始化');
    return 0;
  }

  try {
    const predicates = new relationalStore.RdbPredicates(INTAKE_TABLE);
    predicates.equalTo('id', id);

    const rowsDeleted = await rdbStore.delete(predicates);
    console.info(`删除记录成功，删除行数: ${rowsDeleted}`);
    return rowsDeleted;
  } catch (error) {
    console.error('删除摄入记录失败:', error);
    return 0;
  }
}

/**
 * 清空所有记录
 */
export async function clearAllRecords(): Promise<number> {
  if (!rdbStore) {
    console.error('数据库未初始化');
    return 0;
  }

  try {
    const predicates = new relationalStore.RdbPredicates(INTAKE_TABLE);
    const rowsDeleted = await rdbStore.delete(predicates);
    console.info(`清空记录成功，删除行数: ${rowsDeleted}`);
    return rowsDeleted;
  } catch (error) {
    console.error('清空记录失败:', error);
    return 0;
  }
}

/**
 * 执行每日重置（删除24小时前的记录）
 */
export async function performDailyReset(): Promise<number> {
  if (!rdbStore) {
    console.error('数据库未初始化');
    return 0;
  }

  try {
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    
    const predicates = new relationalStore.RdbPredicates(INTAKE_TABLE);
    predicates.lessThan('time', twentyFourHoursAgo.toISOString());

    const rowsDeleted = await rdbStore.delete(predicates);
    console.info(`每日重置完成，删除行数: ${rowsDeleted}`);
    return rowsDeleted;
  } catch (error) {
    console.error('每日重置失败:', error);
    return 0;
  }
}