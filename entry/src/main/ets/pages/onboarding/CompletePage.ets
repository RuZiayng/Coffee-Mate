// 引导完成页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator';

@Component
export struct CompletePage {
  private userProfile: UserProfile;
  private onComplete: () => void;
  private currentStep: number;
  private totalSteps: number;
  
  @State private animationProgress: number = 0;
  @State private showContent: boolean = false;
  @State private showButton: boolean = false;
  @State private isActive: boolean = true;
  
  aboutToAppear() {
    this.startAnimation();
  }
  
  startAnimation() {
    // 进度动画
    const animateProgress = () => {
      if (this.animationProgress < 100) {
        this.animationProgress += 2;
        setTimeout(animateProgress, 20);
      } else {
        // 显示内容
        setTimeout(() => {
          this.showContent = true;
          
          // 显示按钮
          setTimeout(() => {
            this.showButton = true;
          }, 300);
        }, 500);
      }
    };
    
    animateProgress();
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
        // 完成图标和动画
        Stack() {
          // 进度圆环背景
          Circle({ width: 120, height: 120 })
            .fill('#2A2A2A')
          
          // 进度圆环
          Circle({ width: 120, height: 120 })
            .fill(Color.Transparent)
            .stroke({
              width: 8,
              color: '#FFB74D'
            })
            .strokeDashArray([Math.PI * 120 * this.animationProgress / 100, Math.PI * 120])
            .strokeDashOffset(0)
          
          // 完成图标
          Image($r('app.media.coffee_bean_icon'))
            .width(60)
            .height(60)
            .objectFit(ImageFit.Contain)
            .opacity(this.animationProgress === 100 ? 1 : 0)
            .animation({ duration: 300, curve: Curve.EaseOut })
        }
        .margin({ bottom: 40 })
        
        // 完成标题
        Text('设置完成！')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 20 })
          .opacity(this.showContent ? 1 : 0)
          .animation({ duration: 400, curve: Curve.EaseOut })
        
        // 个性化设置摘要
        Column({ space: 12 }) {
          Text(`个性化每日上限：${this.userProfile.dailyLimit}mg`)
            .fontSize(16)
            .fontColor('#FFB74D')
          
          Text(`体重：${this.userProfile.weight}kg`)
            .fontSize(14)
            .fontColor('#B0B0B0')
          
          Text(`年龄：${this.userProfile.age}岁`)
            .fontSize(14)
            .fontColor('#B0B0B0')
          
          Text(`作息：${this.userProfile.wakeUpTime} - ${this.userProfile.bedTime}`)
            .fontSize(14)
            .fontColor('#B0B0B0')
          
          Text(`敏感度：${this.getSensitivityText()}`)
            .fontSize(14)
            .fontColor('#B0B0B0')
        }
        .opacity(this.showContent ? 1 : 0)
        .animation({ duration: 400, curve: Curve.EaseOut, delay: 100 })
        .margin({ bottom: 40 })
        
        // 功能提示
        Column({ space: 8 }) {
          Text('现在您可以：')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ bottom: 10 })
          
          Text('• 记录咖啡因摄入')
            .fontSize(12)
            .fontColor('#4DB6AC')
          
          Text('• 查看实时代谢进度')
            .fontSize(12)
            .fontColor('#4DB6AC')
          
          Text('• 接收智能提醒')
            .fontSize(12)
            .fontColor('#4DB6AC')
        }
        .opacity(this.showContent ? 1 : 0)
        .animation({ duration: 400, curve: Curve.EaseOut, delay: 200 })
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 底部按钮
      Column() {
        Button('开始使用咖啡伴侣', { type: ButtonType.Capsule })
          .width(280)
          .height(50)
          .backgroundColor('#FFB74D')
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .opacity(this.showButton ? 1 : 0)
          .animation({ duration: 500, curve: Curve.EaseOut })
          .onClick(() => {
            this.isActive = false;
            setTimeout(() => this.onComplete(), 300);
          })
      }
      .width('100%')
      .height(100)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
    .opacity(this.isActive ? 1 : 0)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
  
  private getSensitivityText(): string {
    switch (this.userProfile.caffeineSensitivity) {
      case 'low': return '低敏感度';
      case 'medium': return '中敏感度';
      case 'high': return '高敏感度';
      default: return '未知';
    }
  }
}