// 起床时间选择页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator'
import router from '@ohos.router';

interface TimeParts {
  hours: number;
  minutes: number;
}

@Component
export struct WakeUpPage {
  @Prop onDataSelected: (value: string) => void = () => {};
  @Prop onBack: () => void = () => {};
  @Prop currentTime: string = '08:00';
  @Prop currentStep: number = 1;
  @Prop totalSteps: number = 7;

  @State private localTime: string = '08:00';
  @State private isActive: boolean = false;
  private jumpTimer: number | null = null;

  aboutToAppear(): void {
    this.localTime = this.currentTime;
    this.isActive = true;
  }

  aboutToDisappear(): void {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }

  onTimeChange(hours: number, minutes: number): void {
    const selectedTime = `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}`;
    this.localTime = selectedTime;
    this.currentTime = selectedTime;

    // 重置并启动自动跳转计时器
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.goToNextPage(), 300);
    }, 1200);
  }

  goToNextPage(): void {
    this.onDataSelected(this.currentTime);
  }

  getCurrentTimeParts(): TimeParts {
    const parts = this.localTime.split(':');
    const hours = Number(parts[0]);
    const minutes = Number(parts[1]);
    return { hours, minutes };
  }

  generateHourRange(): string[] {
    const hours: string[] = [];
    for (let i = 5; i <= 12; i++) {
      hours.push(`${i}时`);
    }
    return hours;
  }

  generateMinuteRange(): string[] {
    const minutes: string[] = [];
    for (let i = 0; i <= 55; i += 5) {
      minutes.push(`${i}分`);
    }
    return minutes;
  }

  private getTimeDescription(hours: number): string {
    if (hours < 6) return '早鸟型作息';
    if (hours < 8) return '健康作息时间';
    if (hours < 10) return '标准起床时间';
    return '晚起型作息';
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
        // 问题标题
        Text('您通常几点起床？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 10 })

        // 当前选中时间的大数字显示
        Text(`${this.localTime}`)
          .fontSize(72)
          .fontWeight(FontWeight.Lighter)
          .fontColor('#FFB74D')
          .margin({ bottom: 40 })

        // 时间选择器
        Row({ space: 10 }) {
          // 小时选择
          Column() {
            Text('时')
              .fontSize(14)
              .fontColor('#B0B0B0')
              .margin({ bottom: 5 })
            TextPicker({ range: this.generateHourRange(), selected: this.getCurrentTimeParts().hours - 5 })
              .height(120)
              .width(80)
              .onChange((value: string | string[], index: number | number[]) => {
                const hours = (index as number) + 5;
                this.onTimeChange(hours, this.getCurrentTimeParts().minutes);
              })
          }

          Text(':')
            .fontSize(24)
            .fontColor('#B0B0B0')
            .margin({ top: 40 })

          // 分钟选择
          Column() {
            Text('分')
              .fontSize(14)
              .fontColor('#B0B0B0')
              .margin({ bottom: 5 })
            TextPicker({ range: this.generateMinuteRange(), selected: this.getCurrentTimeParts().minutes / 5 })
              .height(120)
              .width(80)
              .onChange((value: string | string[], index: number | number[]) => {
                const minutes = (index as number) * 5;
                this.onTimeChange(this.getCurrentTimeParts().hours, minutes);
              })
          }
        }
        .margin({ top: 30, bottom: 40 })

        // 时间描述
        Text(this.getTimeDescription(this.getCurrentTimeParts().hours))
          .fontSize(16)
          .fontColor('#B0B0B0')
          .margin({ bottom: 20 })

        // 当前选择显示
        Text(`已选择：${this.localTime} 起床`)
          .fontSize(16)
          .fontColor('#4DB6AC')
          .opacity(this.localTime ? 1 : 0)
          .animation({ duration: 300, curve: Curve.EaseInOut })
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)

      // 底部控制栏
      Column() {
        Row() {
          // "上一步"按钮
          Button('上一步', { type: ButtonType.Normal })
            .width(120)
            .height(44)
            .fontColor('#B0B0B0')
            .backgroundColor('#2A2A2A')
            .borderRadius(8)
            .onClick(() => {
              if (this.jumpTimer) clearTimeout(this.jumpTimer);
              this.onBack();
            })
        }
        .width('100%')
        .height(80)
        .justifyContent(FlexAlign.Start)
        .padding({ left: 24 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
    .opacity(this.isActive ? 1 : 0)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
}