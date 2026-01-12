// 引导流程容器页面 - 按照新设计标准优化
import { WelcomePage } from './WelcomePage';
import { WeightPage } from './WeightPage';
import { GenderPage } from './GenderPage';
import { AgePage } from './AgePage';
import { WakeUpPage } from './WakeUpPage';
import { BedTimePage } from './BedTimePage';
import { CompletionPage } from './CompletionPage';

@Component
export struct OnboardingPage {
  @State private currentStep: number = 1;
  @State private totalSteps: number = 6;
  
  // 用户数据状态
  @State private userWeight: number = 65;
  @State private userGender: string = 'male';
  @State private userAge: number = 25;
  @State private wakeUpTime: string = '08:00';
  @State private bedTime: string = '23:00';
  
  build() {
    Stack() {
      // 根据当前步骤显示对应的页面
      if (this.currentStep === 1) {
        WelcomePage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          onNext: () => this.goToNextStep()
        })
      } else if (this.currentStep === 2) {
        WeightPage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          currentWeight: this.userWeight,
          onDataSelected: (weight: number) => this.onDataSelected(weight),
          onBack: () => this.goToPreviousStep()
        })
      } else if (this.currentStep === 3) {
        GenderPage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          currentGender: this.userGender,
          onDataSelected: (gender: string) => this.onDataSelected(gender),
          onBack: () => this.goToPreviousStep()
        })
      } else if (this.currentStep === 4) {
        AgePage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          currentAge: this.userAge,
          onDataSelected: (age: number) => this.onDataSelected(age),
          onBack: () => this.goToPreviousStep()
        })
      } else if (this.currentStep === 5) {
        WakeUpPage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          currentTime: this.wakeUpTime,
          onDataSelected: (time: string) => this.onDataSelected(time),
          onBack: () => this.goToPreviousStep()
        })
      } else if (this.currentStep === 6) {
        BedTimePage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          currentTime: this.bedTime,
          onDataSelected: (time: string) => this.onDataSelected(time),
          onBack: () => this.goToPreviousStep()
        })
      } else if (this.currentStep === 7) {
        CompletionPage({
          currentStep: this.currentStep,
          totalSteps: this.totalSteps,
          onBack: () => this.goToPreviousStep()
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
  }
  
  // 处理数据选择
  private onDataSelected(value: number | string): void {
    console.log(`Step ${this.currentStep} data selected:`, value);
    
    // 延迟跳转到下一步，让动画完成
    setTimeout(() => {
      this.goToNextStep();
    }, 100);
  }
  
  // 跳转到下一步
  private goToNextStep(): void {
    if (this.currentStep < 7) {
      this.currentStep++;
      console.log(`前进到步骤 ${this.currentStep}`);
    }
  }
  
  // 返回上一步
  private goToPreviousStep(): void {
    if (this.currentStep > 1) {
      this.currentStep--;
      console.log(`返回到步骤 ${this.currentStep}`);
    }
  }
  
  // 保存用户数据到本地存储
  private saveUserData(): void {
    interface UserData {
      weight: number;
      gender: string;
      age: number;
      wakeUpTime: string;
      bedTime: string;
      onboardingCompleted: boolean;
    }
    
    const userData: UserData = {
      weight: this.userWeight,
      gender: this.userGender,
      age: this.userAge,
      wakeUpTime: this.wakeUpTime,
      bedTime: this.bedTime,
      onboardingCompleted: true
    };
    
    // 这里可以添加保存到本地存储的逻辑
    console.log('保存用户数据:', userData);
  }
}