// 步骤指示器组件 - 按照新设计标准优化
@Component
export struct StepIndicator {
  private currentStep: number = 1;
  private totalSteps: number = 7;
  
  build() {
    Row() {
      ForEach(Array.from({length: this.totalSteps}), (item: number, index: number) => {
        Circle({ width: 8, height: 8 })
          .fill(index + 1 === this.currentStep ? '#FFB74D' : '#3A3A3A')
          .margin({ right: 8 })
          .animation({ duration: 300, curve: Curve.EaseInOut })
      })
    }
    .width('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ top: 40, bottom: 30 })
  }
}