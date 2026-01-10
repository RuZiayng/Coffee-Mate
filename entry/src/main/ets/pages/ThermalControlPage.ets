import { router } from '@kit.ArkUI';
import { UserData } from '../model/UserData';

@Entry
@Component
struct ThermalControlPage {
  @State private userData: UserData = new UserData();
  @State private thermalBypassEnabled: boolean = false;
  @State private temperatureThreshold: number = 45;
  @State private performanceMode: string = 'balanced';

  aboutToAppear() {
    const params = router.getParams() as Record<string, UserData>;
    if (params?.userData) {
      this.userData = params.userData as UserData;
    }
  }

  goBack() {
    router.back();
  }

  applySettings() {
    // 这里可以添加实际的温控设置逻辑
    console.info('温控设置已应用：', {
      bypassEnabled: this.thermalBypassEnabled,
      threshold: this.temperatureThreshold,
      mode: this.performanceMode
    });
    
    // 返回体重页面
    router.back();
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Button('< 返回')
          .fontSize(16)
          .backgroundColor(Color.Transparent)
          .fontColor($r('app.color.primary_color'))
          .onClick(() => {
            this.goBack();
          })
        
        Text('温控旁路设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 30, bottom: 20 })

      // 内容区域
      Scroll() {
        Column({ space: 20 }) {
          // 温控旁路开关
          Column({ space: 15 }) {
            Row() {
              Text('启用温控旁路')
                .fontSize(18)
                .fontColor($r('app.color.text_primary'))
                .layoutWeight(1)
              
              Toggle({ type: ToggleType.Switch, isOn: this.thermalBypassEnabled })
                .onChange((value: boolean) => {
                  this.thermalBypassEnabled = value;
                })
            }
            
            Text('开启后设备将在高温环境下保持性能，但可能增加发热和功耗')
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
          }
          .width('90%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)

          // 温度阈值设置
          Column({ space: 15 }) {
            Text('温度阈值 (°C)')
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
            
            Row() {
              Text(this.temperatureThreshold.toString())
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor($r('app.color.accent_color'))
                .layoutWeight(1)
                .textAlign(TextAlign.Center)
              
              Text('°C')
                .fontSize(16)
                .fontColor($r('app.color.text_secondary'))
            }
            
            Slider({
              value: this.temperatureThreshold,
              min: 35,
              max: 55,
              step: 1,
              style: SliderStyle.OutSet
            })
            .width('100%')
            .onChange((value: number) => {
              this.temperatureThreshold = value;
            })
            
            Text('当设备温度超过此阈值时，温控旁路将生效')
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
          }
          .width('90%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)

          // 性能模式选择
          Column({ space: 15 }) {
            Text('性能模式')
              .fontSize(18)
              .fontColor($r('app.color.text_primary'))
              .width('100%')
            
            Column({ space: 15 }) {
              Row({ space: 10 }) {
                Radio({ value: 'balanced', group: 'performanceMode' })
                  .checked(this.performanceMode === 'balanced')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.performanceMode = 'balanced';
                    }
                  })
                Text('平衡模式')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
              }
              
              Row({ space: 10 }) {
                Radio({ value: 'performance', group: 'performanceMode' })
                  .checked(this.performanceMode === 'performance')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.performanceMode = 'performance';
                    }
                  })
                Text('性能优先')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
              }
              
              Row({ space: 10 }) {
                Radio({ value: 'battery', group: 'performanceMode' })
                  .checked(this.performanceMode === 'battery')
                  .onChange((checked: boolean) => {
                    if (checked) {
                      this.performanceMode = 'battery';
                    }
                  })
                Text('省电优先')
                  .fontSize(14)
                  .fontColor($r('app.color.text_primary'))
              }
            }
            
            Text('选择适合您使用场景的性能模式')
              .fontSize(12)
              .fontColor($r('app.color.text_tertiary'))
              .width('100%')
          }
          .width('90%')
          .padding(20)
          .backgroundColor($r('app.color.card_background'))
          .borderRadius(12)

          // 应用按钮
          Button('应用设置')
            .width(280)
            .height(50)
            .backgroundColor($r('app.color.accent_color'))
            .fontColor(Color.White)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(25)
            .margin({ top: 30 })
            .onClick(() => {
              this.applySettings();
            })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
        .padding({ bottom: 30 })
      }
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }
}