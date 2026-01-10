/**
 * 应用颜色主题管理
 * 暖咖 + 鲜黄配色方案
 */
export class ThemeColors {
  // 主色：浅咖 #D2B48C
  static readonly PRIMARY = '#D2B48C';
  
  // 重点色：鲜黄 #FFD166
  static readonly ACCENT = '#FFD166';
  
  // 辅助色：浅青 #74C69D
  static readonly SECONDARY = '#74C69D';
  
  // 中性色：奶白 #FAF6F0
  static readonly NEUTRAL_WHITE = '#FAF6F0';
  
  // 中性色：浅灰 #E8E5E1
  static readonly NEUTRAL_GRAY = '#E8E5E1';
  
  // 文本色
  static readonly TEXT_PRIMARY = '#182431';
  static readonly TEXT_SECONDARY = '#666666';
  static readonly TEXT_TERTIARY = '#999999';
  
  // 状态色
  static readonly SUCCESS = '#FFD166'; // 检测合格标黄
  static readonly WARNING = '#74C69D'; // 异常标浅青
  
  // 背景色
  static readonly CARD_BACKGROUND = '#FFFFFF';
  static readonly PAGE_BACKGROUND = '#FAF6F0';
  
  /**
   * 获取颜色资源引用
   */
  static getColorResource(colorName: string): Resource {
    return $r(`app.color.${colorName}`);
  }
  
  /**
   * 检查是否超过阈值并返回相应的状态颜色
   * @param currentValue 当前值
   * @param threshold 阈值
   * @returns 状态颜色
   */
  static getStatusColor(currentValue: number, threshold: number): string {
    return currentValue >= threshold ? this.WARNING : this.SUCCESS;
  }
  
  /**
   * 获取状态颜色资源引用
   * @param currentValue 当前值
   * @param threshold 阈值
   * @returns 状态颜色资源
   */
  static getStatusColorResource(currentValue: number, threshold: number): Resource {
    const colorName = currentValue >= threshold ? 'warning_color' : 'success_color';
    return this.getColorResource(colorName);
  }
}