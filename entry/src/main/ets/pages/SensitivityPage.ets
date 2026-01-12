import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Component
struct SensitivityPage {
  @State private userData: UserData = new UserData();
  @State private sensitivity: string = '';
  @State private showJumpHint: boolean = false;
  @State private jumpHintText: string = '';
  
  private jumpTimer: number = 0;

  onPageShow() {
    const params = router.getParams() as RouteParams;
    if (params?.userData) {
      this.userData = params.userData;
    }
  }

  onBackPress(): boolean {
    // 禁用侧滑返回
    return true;
  }

  selectSensitivity(level: string) {
    this.sensitivity = level;
    this.startAutoJump();
  }

  startAutoJump() {
    // 清除之前的计时器
    clearTimeout(this.jumpTimer);
    
    // 显示跳转提示
    this.showJumpHint = true;
    this.jumpHintText = `已选择 ${this.sensitivity}，正在跳转到每日上限设置...`;
    
    // 设置1.5秒后自动跳转
    this.jumpTimer = setTimeout(() => {
      this.goToNextPage();
    }, 1500);
  }

  goToNextPage() {
    this.userData.sensitivity = this.sensitivity;
    router.pushUrl({ 
      url: 'pages/DailyLimitPage',
      params: { userData: this.userData }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }



  build() {
    Column() {
      // 步骤提示
      Text('步骤 6/8')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 30, bottom: 20 })

      // 标题
      Text('您对咖啡因的敏感度？')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ bottom: 40 })

      // 敏感度选择区域
      Column({ space: 15 }) {
        // 低敏感度选项
        Button('低敏感度')
          .width(250)
          .height(60)
          .backgroundColor(this.sensitivity === '低敏感度' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.sensitivity === '低敏感度' ? Color.White : $r('app.color.primary_color'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectSensitivity('低敏感度');
          })

        // 中等敏感度选项
        Button('中等敏感度')
          .width(250)
          .height(60)
          .backgroundColor(this.sensitivity === '中等敏感度' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.sensitivity === '中等敏感度' ? Color.White : $r('app.color.primary_color'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectSensitivity('中等敏感度');
          })

        // 高敏感度选项
        Button('高敏感度')
          .width(250)
          .height(60)
          .backgroundColor(this.sensitivity === '高敏感度' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.sensitivity === '高敏感度' ? Color.White : $r('app.color.primary_color'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectSensitivity('高敏感度');
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 60 })

      // 敏感度说明
      Column({ space: 8 }) {
        Text('敏感度说明：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 低敏感度：饮用咖啡后无不适，睡眠不受影响')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 中等敏感度：偶尔有心悸，建议适量饮用')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 高敏感度：饮用后易失眠、心悸，需严格控制')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)
      }
      .alignItems(HorizontalAlign.Start)
      .margin({ bottom: 40 })

      // 跳转提示
      if (this.showJumpHint) {
        Text(this.jumpHintText)
          .fontSize(14)
          .fontColor($r('app.color.accent_color'))
          .margin({ bottom: 20 })
          .opacity(0.8)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}