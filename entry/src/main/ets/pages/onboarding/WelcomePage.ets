// 欢迎页面 - 按照新设计标准优化（无下一步按钮，自动跳转）
import { StepIndicator } from './components/StepIndicator';

@Component
export struct WelcomePage {
  private onNext: () => void = () => {};
  private currentStep: number = 1;
  private totalSteps: number = 7;
  
  @State private titleOpacity: number = 0;
  @State private subtitleOpacity: number = 0;
  @State private descriptionOpacity: number = 0;
  @State private isActive: boolean = false;
  private jumpTimer: number | null = null;
  
  aboutToAppear() {
    this.isActive = true;
    this.startAnimation();
    
    // 自动启动跳转计时器
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.onNext(), 300);
    }, 5000); // 5秒后自动跳转
  }
  
  aboutToDisappear() {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }
  
  startAnimation() {
    // 标题淡入
    setTimeout(() => {
      this.titleOpacity = 1;
    }, 300);
    
    // 副标题淡入
    setTimeout(() => {
      this.subtitleOpacity = 1;
    }, 600);
    
    // 描述淡入
    setTimeout(() => {
      this.descriptionOpacity = 1;
    }, 900);
  }
  
  // 手动跳过等待
  onSkipWait() {
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.isActive = false;
    setTimeout(() => this.onNext(), 300);
  }
  
  build() {
    Column() {
      // 步骤指示器
      StepIndicator({
        currentStep: this.currentStep,
        totalSteps: this.totalSteps
      })
      
      // 主要内容区域
      Column() {
        // 应用图标区域
        Column() {
          Image($r('app.media.coffee_cup_icon'))
            .width(120)
            .height(120)
            .objectFit(ImageFit.Contain)
            .margin({ bottom: 30 })
          
          // 标题
          Text('咖啡伴侣')
            .fontSize(42)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .opacity(this.titleOpacity)
            .animation({ duration: 600, curve: Curve.EaseOut })
            .margin({ bottom: 10 })
          
          // 副标题
          Text('您的个人咖啡因健康管家')
            .fontSize(20)
            .fontColor('#FFB74D')
            .opacity(this.subtitleOpacity)
            .animation({ duration: 500, curve: Curve.EaseOut, delay: 200 })
            .margin({ bottom: 40 })
          
          // 描述文本
          Column({ space: 12 }) {
            Text('• 基于科学代谢模型')
              .fontSize(16)
              .fontColor('#B0B0B0')
              .opacity(this.descriptionOpacity)
              .animation({ duration: 400, curve: Curve.EaseOut, delay: 100 })
            
            Text('• 实时监控咖啡因水平')
              .fontSize(16)
              .fontColor('#B0B0B0')
              .opacity(this.descriptionOpacity)
              .animation({ duration: 400, curve: Curve.EaseOut, delay: 200 })
            
            Text('• 智能睡眠保护提醒')
              .fontSize(16)
              .fontColor('#B0B0B0')
              .opacity(this.descriptionOpacity)
              .animation({ duration: 400, curve: Curve.EaseOut, delay: 300 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ bottom: 60 })
        }
        .alignItems(HorizontalAlign.Center)
        
        // 跳过等待提示
        Text('自动进入设置...')
          .fontSize(14)
          .fontColor('#4DB6AC')
          .margin({ bottom: 16 })
        
        // 点击跳过按钮
        Button('跳过等待', { type: ButtonType.Normal })
          .width(120)
          .height(36)
          .fontColor('#B0B0B0')
          .backgroundColor('#2A2A2A')
          .borderRadius(8)
          .onClick(() => this.onSkipWait())
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ left: 24, right: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
    .opacity(this.isActive ? 1 : 0)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
}