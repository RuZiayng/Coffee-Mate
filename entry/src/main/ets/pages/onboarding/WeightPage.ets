
// 体重输入页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator';

interface PickerValue {
  newSelected: number;
}

@Component
export struct WeightPage {
  private onDataSelected: (value: number) => void = () => {};
  private onBack: () => void = () => {};
  @Link currentWeight: number;
  private currentStep: number = 1;
  private totalSteps: number = 6;
  
  @State private localWeight: number = 65;
  @State private isActive: boolean = false;
  private jumpTimer: number | null = null;
  
  aboutToAppear() {
    this.localWeight = this.currentWeight;
    this.isActive = true;
  }
  
  aboutToDisappear() {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }
  
  // 生成体重范围数组
  generateWeightRange(): string[] {
    const weights: string[] = [];
    for (let i = 40; i <= 90; i++) {
      weights.push(`${i}公斤`);
    }
    return weights;
  }
  
  onWeightChange(newIndex: number) {
    const selectedWeight = newIndex + 40; // Picker范围40-90kg
    this.localWeight = selectedWeight;
    this.currentWeight = selectedWeight;
    
    // 重置并启动自动跳转计时器
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.onDataSelected(selectedWeight), 300);
    }, 1200);
  }
  
  build() {
    Column() {
      // 步骤指示器
      StepIndicator({
        currentStep: this.currentStep,
        totalSteps: this.totalSteps
      })
      
      // 主内容区
      Column() {
        // 问题标题
        Text('您的体重是？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 10 })
        
        // 当前选中值的大数字显示
        Text(`${this.localWeight}`)
          .fontSize(72)
          .fontWeight(FontWeight.Lighter)
          .fontColor('#FFB74D')
          .margin({ bottom: 5 })
        Text('公斤')
          .fontSize(18)
          .fontColor('#B0B0B0')
          .margin({ bottom: 40 })
        // 滚轮选择器
        TextPicker({ range: this.generateWeightRange(), selected: this.localWeight - 40 })
        .height(180)
        .width('90%')
        .onChange((value: string | string[], index: number | number[]) => this.onWeightChange(index as number))
        .margin({ top: 30, bottom: 40 })
        
        // 当前选择显示
        Text(`已选择：${this.localWeight}公斤`)
          .fontSize(16)
          .fontColor('#4DB6AC')
          .opacity(this.localWeight ? 1 : 0)
          .animation({ duration: 300, curve: Curve.EaseInOut })
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 底部控制栏
      Row() {
        // "上一步"按钮
        Button('上一步', { type: ButtonType.Normal })
          .width(120)
          .height(44)
          .fontColor('#B0B0B0')
          .backgroundColor('#2A2A2A')
          .borderRadius(8)
          .onClick(() => {
            if (this.jumpTimer) clearTimeout(this.jumpTimer);
            this.onBack();
          })
      }
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
    .opacity(this.isActive ? 1 : 0)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
}