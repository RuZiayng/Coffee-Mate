// 自定义咖啡因输入页面
import { router } from '@kit.ArkUI';
import { IntakeRecord } from '../utils/CaffeineCalculator';
import { addIntakeRecord } from '../utils/DataManager';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct CustomInputPage {
  @State caffeineAmount: number = 100;
  @State customName: string = '';
  @State isRecording: boolean = false;
  
  // 记录饮品摄入
  async onRecordDrink() {
    if (this.isRecording) return;
    
    this.isRecording = true;
    
    try {
      const sourceName = this.customName.trim() || `自定义饮品 (${this.caffeineAmount}mg)`;
      
      // 创建咖啡因记录
      const record = new IntakeRecord(this.caffeineAmount, new Date(), sourceName);
      
      // 保存记录
      await addIntakeRecord(record);
      
      // 显示成功提示
      this.showSuccessToast(`已记录：${sourceName}`);
      
      // 延迟后返回主页
      setTimeout(() => {
        router.back();
      }, 1000);
      
    } catch (error) {
      console.error('记录饮品失败:', error);
      this.showErrorToast('记录失败，请重试');
    } finally {
      this.isRecording = false;
    }
  }
  
  // 显示成功提示
  showSuccessToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: '80%'
    });
  }
  
  // 显示错误提示
  showErrorToast(message: string) {
    promptAction.showToast({
      message: message,
      duration: 2000,
      bottom: '80%'
    });
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button('取消', { type: ButtonType.Normal })
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor('transparent')
          .onClick(() => router.back())
        
        Text('自定义输入')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          
        // 占位元素，保持对称
        Text('')
          .width(60)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      
      // 主内容区 - 使用Scroll容器确保内容可滚动
      Scroll() {
        Column({ space: 16 }) {
          // 咖啡因含量选择
          Column() {
            Text('咖啡因含量')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 8 })
            
            Text(`${this.caffeineAmount} mg`)
              .fontSize(48)
              .fontWeight(FontWeight.Lighter)
              .fontColor($r('app.color.accent_color'))
              .margin({ bottom: 20 })
            
            // 滑块选择器
            Slider({
              value: this.caffeineAmount,
              min: 0,
              max: 500,
              step: 5,
              style: SliderStyle.OutSet
            })
            .width('90%')
            .blockColor($r('app.color.accent_color'))
            .trackColor($r('app.color.slider_track'))
            .selectedColor($r('app.color.accent_color'))
            .onChange((value: number) => {
              this.caffeineAmount = Math.round(value);
            })
            
            // 快捷选择按钮
            Row({ space: 8 }) {
              ForEach([50, 100, 150, 200, 300], (amount: number) => {
                Text(`${amount}mg`)
                  .fontSize(12)
                  .fontColor(this.caffeineAmount === amount ? $r('app.color.accent_color') : $r('app.color.text_secondary'))
                  .backgroundColor(this.caffeineAmount === amount ? $r('app.color.card_background') : $r('app.color.button_background'))
                  .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                  .borderRadius(16)
                  .onClick(() => {
                    this.caffeineAmount = amount;
                  })
              })
            }
            .margin({ top: 16 })
          }
          .width('100%')
          .padding(24)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
        
          // 自定义名称输入
          Column() {
            Text('饮品名称（可选）')
              .fontSize(16)
              .fontColor($r('app.color.text_primary'))
              .margin({ bottom: 12 })
            
            TextInput({
              placeholder: '例如：自制拿铁、绿茶...',
              text: this.customName
            })
            .width('100%')
            .height(48)
            .fontColor($r('app.color.text_primary'))
            .backgroundColor($r('app.color.button_background'))
            .caretColor($r('app.color.accent_color'))
            .borderRadius(8)
            .padding({ left: 12, right: 12 })
            .onChange((value: string) => {
              this.customName = value;
            })
          }
          .width('100%')
          .padding(24)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(16)
          
          // 参考值提示
          Column() {
            Text('参考值')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
              .margin({ bottom: 8 })
            
            Row() {
              Text('• 浓缩咖啡（单份）：约75mg')
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .flexGrow(1)
              
              Text('• 美式咖啡：约150-200mg')
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .flexGrow(1)
            }
            .margin({ bottom: 4 })
            
            Row() {
              Text('• 能量饮料：约80-160mg')
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .flexGrow(1)
              
              Text('• 茶饮：约30-50mg')
                .fontSize(12)
                .fontColor($r('app.color.text_tertiary'))
                .flexGrow(1)
            }
          }
          .width('100%')
          .padding(16)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 16 })
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Auto)
      .scrollBarColor('#E8E5E1')
      .scrollBarWidth(4)
      .flexGrow(1)
      
      // 记录按钮
      Button(this.isRecording ? '记录中...' : '记录饮品', { type: ButtonType.Capsule })
        .width('92%')
        .height(52)
        .fontSize(16)
        .fontColor('#FFFFFF')
        .backgroundColor(this.isRecording ? $r('app.color.button_background') : $r('app.color.accent_color'))
        .borderRadius(26)
        .onClick(() => this.onRecordDrink())
        .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}