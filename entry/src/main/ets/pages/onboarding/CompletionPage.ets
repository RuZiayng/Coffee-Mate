// 引导完成页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator';
import { router } from '@kit.ArkUI';

@Component
export struct CompletionPage {
  private onBack: () => void = () => {};
  private currentStep: number = 1;
  private totalSteps: number = 7;
  
  @State private isActive: boolean = false;
  @State private progressValue: number = 0;
  private jumpTimer: number | null = null;
  
  aboutToAppear() {
    this.isActive = true;
    this.startProgressAnimation();
    
    // 自动启动跳转计时器
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.navigateToMainPage(), 500);
    }, 3000); // 3秒后自动跳转
  }
  
  aboutToDisappear() {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }
  
  startProgressAnimation(): void {
    // 进度条动画
    let progress = 0;
    const interval = setInterval(() => {
      progress += 0.1;
      if (progress >= 1) {
        progress = 1;
        clearInterval(interval);
      }
      this.progressValue = progress;
    }, 30);
  }
  
  navigateToMainPage(): void {
    // 保存引导完成状态
    // 这里可以添加保存到本地存储的逻辑
    
    // 跳转到主页面
    router.replaceUrl({
      url: 'pages/MainPage'
    });
  }
  
  onSkipWait() {
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.isActive = false;
    setTimeout(() => this.navigateToMainPage(), 300);
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
        // 完成图标
        Column() {
          Circle({ width: 120, height: 120 })
            .fill('#4CAF50')
            .margin({ bottom: 30 })
          
          // 完成文本
          Text('设置完成！')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ bottom: 20 })
          
          // 描述文本
          Text('您的个人咖啡因健康档案已创建')
            .fontSize(16)
            .fontColor('#B0B0B0')
            .textAlign(TextAlign.Center)
            .margin({ bottom: 40 })
        }
        .alignItems(HorizontalAlign.Center)
        
        // 进度条
        Column() {
          Text('正在初始化应用...')
            .fontSize(14)
            .fontColor('#B0B0B0')
            .margin({ bottom: 10 })
          
          Progress({
            value: this.progressValue,
            total: 1,
            type: ProgressType.Linear
          })
          .width('80%')
          .height(4)
          .backgroundColor('#2A2A2A')
          .color('#4CAF50')
          .margin({ bottom: 30 })
        }
        .alignItems(HorizontalAlign.Center)
        
        // 跳过等待按钮
        Button('立即进入', { type: ButtonType.Normal })
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