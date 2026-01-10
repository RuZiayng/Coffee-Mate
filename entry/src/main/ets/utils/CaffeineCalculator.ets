import { BusinessError } from '@kit.BasicServicesKit';

// 摄入记录类
export class IntakeRecord {
  id: number = 0;
  amount: number = 0; // 咖啡因含量(mg)
  time: Date = new Date(); // 摄入时间
  beverageName: string = ''; // 饮品名称

  constructor(amount: number, time: Date, beverageName: string = '') {
    this.amount = amount;
    this.time = time;
    this.beverageName = beverageName;
  }
}

// 代谢计算结果类
export class CaffeineLevel {
  currentLevel: number = 0; // 当前体内含量(mg)
  prediction: number[] = []; // 未来预测数组
  safeLimit: number = 400; // 安全上限
  percentage: number = 0; // 当前含量占上限百分比

  constructor(currentLevel: number, prediction: number[], safeLimit: number) {
    this.currentLevel = currentLevel;
    this.prediction = prediction;
    this.safeLimit = safeLimit;
    this.percentage = (currentLevel / safeLimit) * 100;
  }
}

// 常量定义
const HALF_LIFE_DEFAULT = 5; // 默认半衰期5小时
const LN2 = Math.log(2);

// 体重调整系数：体重越大，代谢越快
function getWeightAdjustment(weight: number): number {
  // 以70kg为标准体重，调整系数在0.8-1.2之间
  return Math.max(0.8, Math.min(1.2, weight / 70));
}

/**
 * 计算咖啡因代谢
 * @param amount 摄入量(mg)
 * @param hoursPassed 经过时间(小时)
 * @param halfLife 半衰期(小时)
 * @returns 剩余含量(mg)
 */
function calculateMetabolism(amount: number, hoursPassed: number, halfLife: number): number {
  if (hoursPassed <= 0) return amount;
  
  // 使用指数衰减公式：剩余量 = 摄入量 × e^(-ln(2) × 经过时间 / 半衰期)
  const exponent = -LN2 * hoursPassed / halfLife;
  return amount * Math.exp(exponent);
}

/**
 * 获取当前体内咖啡因含量
 * @param records 摄入记录数组
 * @param weight 用户体重(kg)
 * @returns 当前含量(mg)
 */
export function getCurrentLevel(records: IntakeRecord[], weight: number = 70): number {
  if (records.length === 0) return 0;
  
  const now = new Date();
  const adjustedHalfLife = HALF_LIFE_DEFAULT / getWeightAdjustment(weight);
  
  let totalLevel = 0;
  
  records.forEach(record => {
    const hoursPassed = (now.getTime() - record.time.getTime()) / (1000 * 60 * 60);
    const remaining = calculateMetabolism(record.amount, hoursPassed, adjustedHalfLife);
    totalLevel += remaining;
  });
  
  return Math.max(0, totalLevel);
}

/**
 * 获取未来预测
 * @param records 摄入记录数组
 * @param hours 预测时长(小时)
 * @param weight 用户体重(kg)
 * @returns 预测数组，每小时一个点
 */
export function getPrediction(records: IntakeRecord[], hours: number = 6, weight: number = 70): number[] {
  if (records.length === 0) return new Array(hours).fill(0);
  
  const now = new Date();
  const adjustedHalfLife = HALF_LIFE_DEFAULT / getWeightAdjustment(weight);
  const prediction: number[] = [];
  
  for (let i = 0; i <= hours; i++) {
    const futureTime = new Date(now.getTime() + i * 60 * 60 * 1000);
    let levelAtTime = 0;
    
    records.forEach(record => {
      const hoursPassed = (futureTime.getTime() - record.time.getTime()) / (1000 * 60 * 60);
      const remaining = calculateMetabolism(record.amount, hoursPassed, adjustedHalfLife);
      levelAtTime += remaining;
    });
    
    prediction.push(Math.max(0, levelAtTime));
  }
  
  return prediction;
}

/**
 * 添加摄入记录
 * @param records 现有记录数组
 * @param amount 摄入量(mg)
 * @param time 摄入时间
 * @param beverageName 饮品名称
 * @returns 新的记录数组
 */
export function addIntake(records: IntakeRecord[], amount: number, time: Date = new Date(), beverageName: string = ''): IntakeRecord[] {
  const newRecord = new IntakeRecord(amount, time, beverageName);
  newRecord.id = records.length > 0 ? Math.max(...records.map(r => r.id)) + 1 : 1;
  
  return [...records, newRecord];
}

/**
 * 每日重置（清除24小时前的记录）
 * @param records 现有记录数组
 * @returns 重置后的记录数组
 */
export function resetDaily(records: IntakeRecord[]): IntakeRecord[] {
  const now = new Date();
  const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
  
  return records.filter(record => record.time >= twentyFourHoursAgo);
}

/**
 * 获取完整的代谢信息
 * @param records 摄入记录数组
 * @param weight 用户体重(kg)
 * @param safeLimit 安全上限(mg)
 * @returns CaffeineLevel对象
 */
export function getCaffeineLevel(records: IntakeRecord[], weight: number = 70, safeLimit: number = 400): CaffeineLevel {
  const currentLevel = getCurrentLevel(records, weight);
  const prediction = getPrediction(records, 6, weight);
  
  return new CaffeineLevel(currentLevel, prediction, safeLimit);
}