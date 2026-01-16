
// 年龄输入页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator';

interface PickerValue {
  newSelected: number;
}

@Component
export struct AgePage {
  private onDataSelected: (value: number) => void = (value: number) => {};
  private onBack: () => void = () => {};
  private currentAge: number = 25;
  private currentStep: number = 1;
  private totalSteps: number = 6;
  

  
  @State private localAge: number = 25;
  @State private isActive: boolean = false;
  private jumpTimer: number | null = null;
  
  aboutToAppear() {
    this.localAge = this.currentAge;
    this.isActive = true;
  }
  
  aboutToDisappear() {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }
  
  // 生成年龄范围数组
  generateAgeRange(): string[] {
    const ages: string[] = [];
    for (let i = 18; i <= 80; i++) {
      ages.push(`${i}岁`);
    }
    return ages;
  }
  
  onAgeChange(newIndex: number) {
    const selectedAge = newIndex + 18; // Picker范围18-80岁
    this.localAge = selectedAge;
    this.currentAge = selectedAge;
    
    // 重置并启动自动跳转计时器
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.onDataSelected(selectedAge), 300);
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
        Text('您的年龄是？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 10 })
        
        // 当前选中值的大数字显示
        Text(`${this.localAge}`)
          .fontSize(72)
          .fontWeight(FontWeight.Lighter)
          .fontColor('#FFB74D')
          .margin({ bottom: 5 })
        Text('岁')
          .fontSize(18)
          .fontColor('#B0B0B0')
          .margin({ bottom: 40 })
        // 滚轮选择器
        TextPicker({ range: this.generateAgeRange(), selected: this.localAge - 18 })
        .height(180)
        .width('90%')
        .onChange((value: string | string[], index: number | number[]) => this.onAgeChange(index as number))
        .margin({ top: 30, bottom: 40 })
        
        // 当前选择显示
        Text(`已选择：${this.localAge}岁`)
          .fontSize(16)
          .fontColor('#4DB6AC')
          .opacity(this.localAge ? 1 : 0)
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