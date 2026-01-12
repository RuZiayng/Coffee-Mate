import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { saveUserSettings, UserSettings } from '../../utils/DataManager';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct SimpleOnboarding {
  @State private currentStep: number = 1;
  @State private totalSteps: number = 3;
  @State private userData: UserSettings = new UserSettings();

  // 步骤标题
  private readonly stepTitles: string[] = [
    '欢迎使用Coffee Mate',
    '基本信息设置',
    '完成设置'
  ];

  // 步骤描述
  private readonly stepDescriptions: string[] = [
    '让我们开始设置您的个性化咖啡因追踪',
    '请填写您的基本信息以获得更准确的代谢预测',
    '设置完成！开始追踪您的咖啡因摄入吧'
  ];

  // 获取UIAbilityContext
  private getContext(): common.UIAbilityContext {
    const context = this.getUIContext().getHostContext();
    if (context && (context as common.UIAbilityContext).abilityInfo) {
      return context as common.UIAbilityContext;
    }
    throw new Error('Failed to get UIAbilityContext');
  }

  nextStep() {
    if (this.currentStep < this.totalSteps) {
      this.currentStep++;
    } else {
      this.completeOnboarding();
    }
  }

  prevStep() {
    if (this.currentStep > 1) {
      this.currentStep--;
    }
  }

  async completeOnboarding() {
    try {
      const context = this.getContext();
      await saveUserSettings(context, this.userData);
      promptAction.showToast({ message: '设置完成', duration: 2000 });
      
      // 跳转到主页面
      router.replaceUrl({ 
        url: 'pages/Index'
      });
    } catch (error) {
      console.error('保存设置失败:', error);
      promptAction.showToast({ message: '保存失败，请重试', duration: 2000 });
    }
  }

  skipOnboarding() {
    // 使用默认设置并跳转
    router.replaceUrl({ 
      url: 'pages/Index'
    });
  }
  private generateStepsArray(): number[] {
    const steps: number[] = [];
    for (let i = 1; i <= this.totalSteps; i++) {
      steps.push(i);
    }
    return steps;
  }

  build() {
    Column() {
      // 顶部进度指示器
      Row() {
        ForEach(this.generateStepsArray(), (step: number) => {
          Row() {
            Circle()
              .width(10)
              .height(10)
              .fill(step <= this.currentStep ? $r('app.color.accent_color') : $r('app.color.neutral_gray'))
        if (step < this.totalSteps) {
          Column()
            .width(30)
            .height(2)
            .backgroundColor(step < this.currentStep ? $r('app.color.accent_color') : $r('app.color.neutral_gray'))
        } else {
          Blank()
        }
          }
          .alignItems(VerticalAlign.Center)
        })
      }
      .margin({ top: 50, bottom: 30 })

      // 步骤内容
      Column({ space: 30 }) {
        Text(this.stepTitles[this.currentStep - 1])
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_color'))
          .textAlign(TextAlign.Center)

        Text(this.stepDescriptions[this.currentStep - 1])
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .textAlign(TextAlign.Center)
          .textAlign(TextAlign.Center)

        // 步骤特定的内容
        this.buildStepContent()
      }
      .layoutWeight(1)

      // 底部按钮
      Row({ space: 15 }) {
        if (this.currentStep > 1) {
          Button('上一步')
            .layoutWeight(1)
            .height(50)
            .backgroundColor($r('app.color.secondary_color'))
            .fontColor(Color.White)
            .borderRadius(25)
            .onClick(() => {
              this.prevStep();
            })
        } else {
          Blank()
        }

        Button(this.currentStep === this.totalSteps ? '完成' : '下一步')
          .layoutWeight(1)
          .height(50)
          .backgroundColor($r('app.color.accent_color'))
          .fontColor(Color.White)
          .borderRadius(25)
          .onClick(() => {
            this.nextStep();
          })
      }
      .width('90%')
      .margin({ bottom: 30 })
      // 跳过按钮
      if (this.currentStep === 1) {
        Button('跳过引导')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor(Color.Transparent)
          .onClick(() => {
            this.skipOnboarding();
          })
      } else {
        Blank()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .alignItems(HorizontalAlign.Center)
  }
  @Builder
  buildStepContent() {
    if (this.currentStep === 1) {
      this.buildWelcomeStep();
    } else if (this.currentStep === 2) {
      this.buildBasicInfoStep();
    } else if (this.currentStep === 3) {
      this.buildCompleteStep();
    }
  }

  @Builder
  buildWelcomeStep() {
    Column({ space: 20 }) {
      Text('☕')
        .fontSize(80)
      
      Text('咖啡因追踪助手')
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_color'))
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }

  @Builder
  buildBasicInfoStep() {
    Column({ space: 15 }) {
      // 体重设置
      Row({ space: 10 }) {
        Text('体重:')
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .width(60)
        TextInput({ text: this.userData.weight.toString(), placeholder: '请输入体重' })
          .layoutWeight(1)
          .height(40)
          .type(InputType.Number)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(10)
          .onChange((value: string) => {
            const weight = parseFloat(value);
            if (!isNaN(weight) && weight > 0) {
              this.userData.weight = weight;
            }
          })
        
        Text('kg')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }

      // 年龄设置
      Row({ space: 10 }) {
        Text('年龄:')
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .width(60)
        TextInput({ text: this.userData.age.toString(), placeholder: '请输入年龄' })
          .layoutWeight(1)
          .height(40)
          .type(InputType.Number)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(10)
          .onChange((value: string) => {
            const age = parseInt(value);
            if (!isNaN(age) && age > 0) {
              this.userData.age = age;
            }
          })
        
        Text('岁')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }

      // 每日上限
      Row({ space: 10 }) {
        Text('每日上限:')
          .fontSize(16)
          .fontColor($r('app.color.text_primary'))
          .width(80)
        TextInput({ text: this.userData.dailyLimit.toString(), placeholder: '请输入每日上限' })
          .layoutWeight(1)
          .height(40)
          .type(InputType.Number)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(10)
          .onChange((value: string) => {
            const limit = parseFloat(value);
            if (!isNaN(limit) && limit > 0) {
              this.userData.dailyLimit = limit;
            }
          })
        
        Text('mg')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
    }
    .width('90%')
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
  }

  @Builder
  buildCompleteStep() {
    Column({ space: 20 }) {
      Text('✅')
        .fontSize(60)
      
      Column({ space: 10 }) {
        Text('设置摘要:')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.primary_color'))
        
        Text(`体重: ${this.userData.weight} kg`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        
        Text(`年龄: ${this.userData.age} 岁`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
        
        Text(`每日上限: ${this.userData.dailyLimit} mg`)
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
      }
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
  }
}