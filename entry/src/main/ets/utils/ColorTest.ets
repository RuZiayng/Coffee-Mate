/**
 * 配色方案测试工具
 * 用于验证暖咖 + 鲜黄配色方案是否正确应用
 */
import { ThemeColors } from './ThemeColors';

export class ColorTest {
  /**
   * 打印当前配色方案信息
   */
  static printColorScheme(): void {
    console.log('=== Coffee Mate 配色方案测试 ===');
    console.log('主色 (浅咖): ' + ThemeColors.PRIMARY);
    console.log('重点色 (鲜黄): ' + ThemeColors.ACCENT);
    console.log('辅助色 (浅青): ' + ThemeColors.SECONDARY);
    console.log('背景色 (奶白): ' + ThemeColors.PAGE_BACKGROUND);
    console.log('卡片背景: ' + ThemeColors.CARD_BACKGROUND);
    console.log('主文本色: ' + ThemeColors.TEXT_PRIMARY);
    console.log('次文本色: ' + ThemeColors.TEXT_SECONDARY);
    console.log('弱文本色: ' + ThemeColors.TEXT_TERTIARY);
    console.log('================================');
  }

  /**
   * 验证颜色资源是否正确加载
   */
  static validateColorResources(): boolean {
    try {
      const colors = [
        'primary_color',
        'accent_color', 
        'secondary_color',
        'page_background',
        'card_background',
        'text_primary',
        'text_secondary',
        'text_tertiary',
        'neutral_white',
        'neutral_gray',
        'success_color',
        'warning_color'
      ];

      let allValid = true;
      colors.forEach(colorName => {
        try {
          const resource = ThemeColors.getColorResource(colorName);
          console.log(`✓ ${colorName}: 资源加载成功`);
        } catch (error) {
          console.error(`✗ ${colorName}: 资源加载失败 - ${error}`);
          allValid = false;
        }
      });

      return allValid;
    } catch (error) {
      console.error('颜色资源验证失败:', error);
      return false;
    }
  }

  /**
   * 测试状态颜色逻辑
   */
  static testStatusColors(): void {
    console.log('=== 状态颜色逻辑测试 ===');
    
    const testCases = [
      { current: 300, threshold: 400, expected: ThemeColors.SUCCESS },
      { current: 400, threshold: 400, expected: ThemeColors.WARNING },
      { current: 500, threshold: 400, expected: ThemeColors.WARNING }
    ];

    testCases.forEach((testCase, index) => {
      const actual = ThemeColors.getStatusColor(testCase.current, testCase.threshold);
      const status = actual === testCase.expected ? '✓' : '✗';
      console.log(`${status} 测试 ${index + 1}: ${testCase.current}/${testCase.threshold} -> ${actual} (预期: ${testCase.expected})`);
    });
  }

  /**
   * 运行完整测试套件
   */
  static runFullTest(): void {
    console.log('开始配色方案测试...\n');
    
    this.printColorScheme();
    console.log('');
    
    const resourcesValid = this.validateColorResources();
    console.log(`\n资源验证: ${resourcesValid ? '✓ 全部通过' : '✗ 存在问题'}`);
    
    console.log('');
    this.testStatusColors();
    
    console.log('\n=== 测试完成 ===');
    console.log('请检查控制台输出，确保所有颜色资源正确加载');
    console.log('如果发现问题，请检查 color.json 文件格式和资源引用');
  }
}