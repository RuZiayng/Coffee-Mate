import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Entry
@Component
struct ReminderPage {
  @State private userData: UserData = new UserData();
  @State private reminderLevel: string = '';
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

  selectReminderLevel(level: string) {
    this.reminderLevel = level;
    this.startAutoJump();
  }

  startAutoJump() {
    // 清除之前的计时器
    clearTimeout(this.jumpTimer);
    
    // 显示跳转提示
    this.showJumpHint = true;
    this.jumpHintText = `已选择 ${this.reminderLevel} 提醒，正在跳转到登录页面...`;
    
    // 设置1.5秒后自动跳转到登录页面
    this.jumpTimer = setTimeout(() => {
      this.goToLoginPage();
    }, 1500);
  }

  goToLoginPage() {
    this.userData.reminderLevel = this.reminderLevel;
    
    // 清理路由栈并跳转到主界面
    router.clear();
    router.pushUrl({
      url: 'pages/Index'
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }



  build() {
    Column() {
      // 步骤提示
      Text('步骤 8/8')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 30, bottom: 20 })

      // 标题
      Text('提醒强度设置')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ bottom: 40 })

      // 提醒强度选择区域
      Column({ space: 15 }) {
        // 轻度提醒选项
        Button('轻度提醒')
          .width(250)
          .height(60)
          .backgroundColor(this.reminderLevel === '轻度提醒' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.reminderLevel === '轻度提醒' ? Color.White : $r('app.color.primary_color'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectReminderLevel('轻度提醒');
          })

        // 中度提醒选项
        Button('中度提醒')
          .width(250)
          .height(60)
          .backgroundColor(this.reminderLevel === '中度提醒' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.reminderLevel === '中度提醒' ? Color.White : $r('app.color.primary_color'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectReminderLevel('中度提醒');
          })

        // 重度提醒选项
        Button('重度提醒')
          .width(250)
          .height(60)
          .backgroundColor(this.reminderLevel === '重度提醒' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.reminderLevel === '重度提醒' ? Color.White : $r('app.color.primary_color'))
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectReminderLevel('重度提醒');
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 60 })

      // 提醒强度说明
      Column({ space: 8 }) {
        Text('提醒强度说明：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 轻度提醒：接近上限时温和提醒')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 中度提醒：达到上限时明显提醒')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 重度提醒：超过上限时强制提醒')
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