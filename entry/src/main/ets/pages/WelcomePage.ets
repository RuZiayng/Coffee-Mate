import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct WelcomePage {
  // 动画状态管理
  @State private title1Opacity: number = 0;
  @State private title2Opacity: number = 0;
  @State private subtitle1Opacity: number = 0;
  @State private subtitle2Opacity: number = 0;
  @State private buttonOpacity: number = 0;
  @State private buttonTranslateY: number = 100;
  @State private showButton: boolean = false;
  @State private coffeeCupOpacity: number = 0;
  @State private coffeeBeansOpacity: number = 0;

  aboutToAppear() {
    // 文字依次显示动画序列
    this.startTextAnimation();
  }

  startTextAnimation() {
    // 咖啡杯图标淡入
    setTimeout(() => {
      this.coffeeCupOpacity = 1;
    }, 200);

    // 第一行文字淡入
    setTimeout(() => {
      this.title1Opacity = 1;
    }, 400);

    // 第二行文字延迟200ms淡入
    setTimeout(() => {
      this.title2Opacity = 1;
    }, 600);

    // 副标题第一行延迟显示
    setTimeout(() => {
      this.subtitle1Opacity = 1;
    }, 900);

    // 副标题第二行延迟显示
    setTimeout(() => {
      this.subtitle2Opacity = 1;
    }, 1100);

    // 咖啡豆图标淡入
    setTimeout(() => {
      this.coffeeBeansOpacity = 1;
    }, 1300);

    // 1.8秒后显示按钮
    setTimeout(() => {
      this.showButton = true;
      // 按钮动画：从下方滑动进入带弹跳效果
      this.buttonOpacity = 1;
      this.buttonTranslateY = 0;
    }, 1800);
  }

  goToNextPage() {
    router.pushUrl({ 
      url: 'pages/WeightPage'
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }

  build() {
    Column() {
      // 顶部咖啡杯图标
      Image($r('app.media.coffee_cup_icon'))
        .width(120)
        .height(120)
        .objectFit(ImageFit.Contain)
        .opacity(this.coffeeCupOpacity)
        .animation({
          duration: 800,
          curve: Curve.EaseOut,
          delay: 0
        })
        .margin({ bottom: 40 })

      // 主标题区域
      Column({ space: 8 }) {
        // 第一行文字
        Text('掌控每一杯')
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.welcome_title'))
          .opacity(this.title1Opacity)
          .animation({
            duration: 600,
            curve: Curve.EaseOut,
            delay: 0
          })

        // 第二行文字
        Text('掌握每一天')
          .fontSize(38)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.welcome_title'))
          .opacity(this.title2Opacity)
          .animation({
            duration: 600,
            curve: Curve.EaseOut,
            delay: 200
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 30 })

      // 副标题区域
      Column({ space: 4 }) {
        // 应用名称
        Text('Coffee Mate')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.welcome_subtitle'))
          .opacity(this.subtitle1Opacity)
          .animation({
            duration: 500,
            curve: Curve.EaseOut,
            delay: 400
          })

        // 描述文字
        Text('您的个人咖啡因健康管家')
          .fontSize(18)
          .fontColor($r('app.color.welcome_subtitle'))
          .opacity(this.subtitle2Opacity)
          .animation({
            duration: 500,
            curve: Curve.EaseOut,
            delay: 600
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 40 })

      // 咖啡豆装饰元素
      Image($r('app.media.coffee_bean_icon'))
        .width(120)
        .height(60)
        .objectFit(ImageFit.Contain)
        .opacity(this.coffeeBeansOpacity)
        .animation({
          duration: 600,
          curve: Curve.EaseOut,
          delay: 0
        })
        .margin({ bottom: 40 })

      // 开始按钮（动画完成后显示）
      if (this.showButton) {
        Button('开始设置')
          .width('100%')
          .height(56)
          .margin({ left: 24, right: 24 })
          .backgroundColor($r('app.color.welcome_button'))
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .borderRadius(16)
          .opacity(this.buttonOpacity)
          .translate({ y: this.buttonTranslateY })
          .animation({
            duration: 800,
            curve: Curve.EaseOut,
            iterations: 1
          })
          .onClick(() => {
            this.goToNextPage();
          })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.welcome_background'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding({ left: 24, right: 24 })
  }
}