import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Component
struct WeightPage {
  @State private userData: UserData = new UserData();
  @State private weight: number = 65;
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
    this.weight = value;
    this.startAutoJump();
  }

  startAutoJump() {
    // 清除之前的计时器
    clearTimeout(this.jumpTimer);
    
    // 显示跳转提示
    this.showJumpHint = true;
    this.jumpHintText = `已选择 ${this.weight}kg，正在跳转到年龄设置...`;
    
    // 设置1.5秒后自动跳转
    this.jumpTimer = setTimeout(() => {
      this.goToNextPage();
    }, 1500);
  }

  goToNextPage() {
    this.userData.weight = this.weight;
    router.pushUrl({ 
      url: 'pages/AgePage',
      params: { userData: this.userData }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }

  build() {
    Column() {
      // 步骤提示
      Text('开始：设置您的体重')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 30, bottom: 20 })

      // 标题
      Text('您的体重？')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ bottom: 40 })

      // 当前体重显示
      Column({ space: 10 }) {
        Text(`${this.weight} kg`)
          .fontSize(48)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.accent_color'))

        Text('当前体重')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 40 })

      // 滑块区域
      Column({ space: 15 }) {
        // 体重说明
        Text('选项一：设置您的体重')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
          .textAlign(TextAlign.Center)
          .width('85%')
          .margin({ bottom: 5 })
        
        Text('请拖动滑块设置您的体重，这是计算咖啡因摄入量的重要依据')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .width('85%')
          .margin({ bottom: 10 })
        
        Slider({
          value: this.weight,
          min: 40,
          max: 120,
          step: 1,
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
          Text('40 kg')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
          Blank()
          Text('120 kg')
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
        }
        .width('80%')
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 60 })

      // 体重相关建议
      Column({ space: 8 }) {
        Text('体重相关建议：')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 体重较重者代谢较慢，建议控制咖啡因摄入')
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        Text('• 体重较轻者对咖啡因更敏感，建议适量饮用')
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

      // 底部空白区域（无下一步按钮）
      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
}