// 性别选择页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator';
@Component
export struct GenderPage {
  private onDataSelected: (value: string) => void = () => {};
  private onBack: () => void = () => {};
  @Link currentGender: string;
  private currentStep: number = 1;
  private totalSteps: number = 6;
  
  @State private localGender: string = 'male';
  @State private isActive: boolean = false;
  private jumpTimer: number | null = null;
  
  aboutToAppear() {
    this.localGender = this.currentGender;
    this.isActive = true;
  }
  
  aboutToDisappear() {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }
  
  onGenderSelect(gender: string) {
    this.localGender = gender;
    this.currentGender = gender;
    
    // 重置并启动自动跳转计时器
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.onDataSelected(gender), 300);
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
        Text('您的性别是？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 40 })
        
        // 性别选择按钮
        Row({ space: 30 }) {
          // 男性按钮
          Column() {
            Button('', { type: ButtonType.Circle })
              .width(140)
              .height(140)
              .backgroundColor(this.localGender === 'male' ? '#FFB74D' : '#2A2A2A')
              .onClick(() => this.onGenderSelect('male'))
            
            Text('男性')
              .fontSize(18)
              .fontColor(this.localGender === 'male' ? '#FFB74D' : '#B0B0B0')
              .margin({ top: 15 })
          }
          
          // 女性按钮
          Column() {
            Button('', { type: ButtonType.Circle })
              .width(140)
              .height(140)
              .backgroundColor(this.localGender === 'female' ? '#FFB74D' : '#2A2A2A')
              .onClick(() => this.onGenderSelect('female'))
            
            Text('女性')
              .fontSize(18)
              .fontColor(this.localGender === 'female' ? '#FFB74D' : '#B0B0B0')
              .margin({ top: 15 })
          }
        }
        .margin({ bottom: 60 })
        
        // 当前选择显示
        Text(this.localGender === 'male' ? '已选择：男性' : '已选择：女性')
          .fontSize(16)
          .fontColor('#4DB6AC')
          .opacity(this.localGender ? 1 : 0)
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