// 咖啡因摄入记录模型
export class CaffeineRecord {
  id: string; // 唯一标识
  timestamp: number; // 摄入时间戳
  sourceName: string; // 来源名称
  caffeineAmount: number; // 咖啡因含量(mg)
  beverageId?: string; // 关联的饮品ID
  
  constructor(data: {
    id?: string;
    timestamp: number;
    sourceName: string;
    caffeineAmount: number;
    beverageId?: string;
  }) {
    this.id = data.id || this.generateId();
    this.timestamp = data.timestamp;
    this.sourceName = data.sourceName;
    this.caffeineAmount = data.caffeineAmount;
    this.beverageId = data.beverageId;
  }
  
  private generateId(): string {
    return `record_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
  }
  
  // 获取摄入时间格式化字符串
  getTimeString(): string {
    const date = new Date(this.timestamp);
    return `${date.getHours().toString().padStart(2, '0')}:${date.getMinutes().toString().padStart(2, '0')}`;
  }
  
  // 获取摄入日期格式化字符串
  getDateString(): string {
    const date = new Date(this.timestamp);
    return `${date.getFullYear()}-${(date.getMonth() + 1).toString().padStart(2, '0')}-${date.getDate().toString().padStart(2, '0')}`;
  }
}