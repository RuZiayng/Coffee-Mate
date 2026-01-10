import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Entry
@Component
struct GenderPage {
  @State private userData: UserData = new UserData();
  @State private selectedGender: string = '';
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

  selectGender(gender: string) {
    this.selectedGender = gender;
    this.startAutoJump();
  }

  startAutoJump() {
    // 清除之前的计时器
    clearTimeout(this.jumpTimer);
    
    // 显示跳转提示
    this.showJumpHint = true;
    this.jumpHintText = `已选择 ${this.selectedGender}，正在跳转到起床时间设置...`;
    
    // 设置0.5秒后自动跳转（立即感）
    this.jumpTimer = setTimeout(() => {
      this.goToNextPage();
    }, 500);
  }

  goToNextPage() {
    this.userData.gender = this.selectedGender;
    router.pushUrl({ 
      url: 'pages/WakeUpPage',
      params: { userData: this.userData }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }



  build() {
    Column() {
      // 步骤提示
      Text('步骤 3/8')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 30, bottom: 20 })

      // 标题
      Text('您的性别？')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ bottom: 40 })

      // 性别选择区域
      Column({ space: 20 }) {
        // 男性选项
        Button('男性')
          .width(200)
          .height(60)
          .backgroundColor(this.selectedGender === '男性' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.selectedGender === '男性' ? Color.White : $r('app.color.primary_color'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectGender('男性');
          })

        // 女性选项
        Button('女性')
          .width(200)
          .height(60)
          .backgroundColor(this.selectedGender === '女性' ? $r('app.color.accent_color') : $r('app.color.button_background'))
          .fontColor(this.selectedGender === '女性' ? Color.White : $r('app.color.primary_color'))
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .borderRadius(30)
          .onClick(() => {
            this.selectGender('女性');
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 60 })

      // 性别相关建议
      Column({ space: 8 }) {
        Text('性别相关建议：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 男性通常代谢较快，可适量增加咖啡因摄入')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 女性在特殊时期建议控制咖啡因摄入')
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