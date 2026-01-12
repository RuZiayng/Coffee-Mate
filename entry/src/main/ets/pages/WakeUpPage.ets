import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Component
struct WakeUpPage {
  @State private userData: UserData = new UserData();
  @State private wakeUpTime: string = '07:00';
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

  onTimeChange(value: string) {
    this.wakeUpTime = value;
    this.startAutoJump();
  }

  startAutoJump() {
    // 清除之前的计时器
    clearTimeout(this.jumpTimer);
    
    // 显示跳转提示
    this.showJumpHint = true;
    this.jumpHintText = `已选择 ${this.wakeUpTime} 起床，正在跳转到就寝时间设置...`;
    
    // 设置1.5秒后自动跳转
    this.jumpTimer = setTimeout(() => {
      this.goToNextPage();
    }, 1500);
  }

  goToNextPage() {
    this.userData.wakeUpTime = this.wakeUpTime;
    router.pushUrl({ 
      url: 'pages/BedtimePage',
      params: { userData: this.userData }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }
  build() {
    Column() {
      Column() {
        // 步骤提示
        Text('步骤 4/8')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ top: 30, bottom: 20 })

        // 标题
        Text('您通常几点起床？')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_color'))
          .margin({ bottom: 40 })

        // 当前时间显示
        Column({ space: 10 }) {
          Text(this.wakeUpTime)
            .fontSize(48)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.accent_color'))

          Text('起床时间')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 40 })

        // 时间选择区域
        Column({ space: 15 }) {
          TextPicker({
            range: this.generateTimeRange(),
            selected: this.getSelectedIndex()
          })
            .width('80%')
            .height(200)
            .onChange((value: string | string[], index: number | number[]) => {
              if (typeof value === 'string') {
                this.onTimeChange(value);
              } else if (Array.isArray(value) && value.length > 0) {
                this.onTimeChange(value[0]);
              }
            })
        }
        .alignItems(HorizontalAlign.Center)
        .margin({ bottom: 60 })

        // 起床时间建议
        Column({ space: 8 }) {
          Text('起床时间建议：')
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.primary_color'))
            .width('80%')
            .textAlign(TextAlign.Start)

          Text('• 建议起床后1小时内饮用第一杯咖啡')
            .fontSize(12)
            .fontColor($r('app.color.text_secondary'))
            .width('80%')
            .textAlign(TextAlign.Start)

          Text('• 避免空腹饮用咖啡，可搭配早餐')
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

  // 生成时间范围 (05:00 - 12:00)
  private generateTimeRange(): string[] {
    const times: string[] = [];
    for (let hour = 5; hour <= 12; hour++) {
      for (let minute = 0; minute < 60; minute += 15) {
        const timeStr = `${hour.toString().padStart(2, '0')}:${minute.toString().padStart(2, '0')}`;
        times.push(timeStr);
      }
    }
    return times;
  }

  // 获取当前选中索引
  private getSelectedIndex(): number {
    const times = this.generateTimeRange();
    return times.indexOf(this.wakeUpTime);
  }
}