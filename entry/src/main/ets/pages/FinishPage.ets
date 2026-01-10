import { router } from '@kit.ArkUI';
import { UserData } from '../model/UserData';

@Entry
@Component
struct FinishPage {
  @State private userData: UserData = new UserData();
  @State private saveProgress: number = 0;
  @State private showSuccess: boolean = false;
  @State private showAnimation: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, UserData>;
    if (params && params['userData']) {
      this.userData = params['userData'] as UserData;
    }
    
    // 开始保存动画
    this.startSaveAnimation();
  }

  startSaveAnimation() {
    // 显示动画
    this.showAnimation = true;
    
    // 模拟保存进度
    let progress = 0;
    const interval = setInterval(() => {
      progress += 10;
      this.saveProgress = progress;
      
      if (progress >= 100) {
        clearInterval(interval);
        
        // 保存数据到Preferences
        this.saveUserData();
        
        // 显示成功动画
        setTimeout(() => {
          this.showSuccess = true;
          
          // 3秒后跳转到登录注册页面
          setTimeout(() => {
            router.replaceUrl({ 
              url: 'pages/LoginRegisterPage',
              params: { userData: this.userData }
            });
          }, 3000);
        }, 500);
      }
    }, 100);
  }

  saveUserData() {
    // 这里应该使用Preferences保存用户数据
    // 暂时模拟保存过程
    console.log('保存用户数据:', this.userData);
  }

  build() {
    Column() {
      if (this.showSuccess) {
        // 成功完成界面
        this.buildSuccessView()
      } else {
        // 保存进度界面
        this.buildProgressView()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F8E9')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildProgressView() {
    Column({ space: 30 }) {
      // 动画图标
      if (this.showAnimation) {
        Column() {
          Circle({ width: 80, height: 80 })
            .fill('#4CAF50')
            .opacity(0.3)
          
          Circle({ width: 60, height: 60 })
            .fill('#4CAF50')
            .opacity(0.6)
            .margin({ top: -70 })
          
          Circle({ width: 40, height: 40 })
            .fill('#4CAF50')
            .margin({ top: -50 })
        }
        .animation({
          duration: 1000,
          curve: Curve.EaseInOut,
          iterations: -1,
          playMode: PlayMode.Alternate
        })
      }

      // 进度文本
      Column({ space: 10 }) {
        Text('正在保存您的设置...')
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .fontColor('#388E3C')

        Text(`${this.saveProgress}%`)
          .fontSize(16)
          .fontColor('#666666')
      }
      .alignItems(HorizontalAlign.Center)

      // 进度条
      Progress({
        value: this.saveProgress,
        total: 100,
        type: ProgressType.Linear
      })
        .width('80%')
        .height(8)
        .color('#4CAF50')
        .backgroundColor('#E0E0E0')
    }
  }

  @Builder
  buildSuccessView() {
    Column({ space: 25 }) {
      // 成功图标
      Column() {
        Circle({ width: 100, height: 100 })
          .fill('#4CAF50')
        
        Text('✓')
          .fontSize(48)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ top: -70 })
      }
      .animation({
        duration: 500,
        curve: Curve.EaseOut
      })

      // 成功文本
      Column({ space: 10 }) {
        Text('设置完成！')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#4CAF50')

        Text('您的个人资料已成功保存')
          .fontSize(16)
          .fontColor('#666666')

        Text('即将跳转到登录页面...')
          .fontSize(14)
          .fontColor('#999999')
      }
      .alignItems(HorizontalAlign.Center)
    }
  }
}