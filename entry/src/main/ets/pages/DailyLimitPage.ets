import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Entry
@Component
struct DailyLimitPage {
  @State private userData: UserData = new UserData();
  @State private dailyLimit: number = 400;
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

  onSliderChange(value: number) {
    this.dailyLimit = value;
    this.startAutoJump();
  }

  startAutoJump() {
    // 清除之前的计时器
    clearTimeout(this.jumpTimer);
    
    // 显示跳转提示
    this.showJumpHint = true;
    this.jumpHintText = `已设置 ${this.dailyLimit}mg 上限，正在跳转到提醒强度设置...`;
    
    // 设置1.5秒后自动跳转
    this.jumpTimer = setTimeout(() => {
      this.goToNextPage();
    }, 1500);
  }

  goToNextPage() {
    this.userData.dailyLimit = this.dailyLimit;
    router.pushUrl({ 
      url: 'pages/ReminderPage',
      params: { userData: this.userData }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }



  build() {
    Column() {
      // 步骤提示
      Text('步骤 7/8')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 30, bottom: 20 })

      // 标题
      Text('每日咖啡因安全上限？')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ bottom: 40 })

      // 当前值显示
      Column({ space: 10 }) {
        Text(`${this.dailyLimit} mg`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.accent_color'))

        Text('每日咖啡因摄入量上限')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 40 })

      // 滑块区域
      Column({ space: 15 }) {
        Slider({
          value: this.dailyLimit,
          min: 0,
          max: 1000,
          step: 10,
          style: SliderStyle.OutSet
        })
          .width('80%')
          .height(40)
          .trackColor($r('app.color.progress_background'))
          .selectedColor($r('app.color.accent_color'))
          .blockColor($r('app.color.accent_color'))
          .showSteps(true)
          .showTips(true)
          .onChange((value: number) => {
            this.onSliderChange(value);
          })

        // 范围提示
        Row() {
          Text('0 mg')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
          Blank()
          Text('1000 mg')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }
        .width('80%')
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 60 })

      // 安全建议
      Column({ space: 8 }) {
        Text('安全摄入建议：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 健康成人每日不超过400mg')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 孕妇和敏感人群建议控制在200mg以内')
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