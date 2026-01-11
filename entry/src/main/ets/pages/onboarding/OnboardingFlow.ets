// 引导流程主控制器
import { router } from '@kit.ArkUI';
import { UserProfile } from '../../model/UserProfile';
import { PreferencesService } from '../../services/PreferencesService';
import { WelcomePage } from './WelcomePage';
import { WeightPage } from './WeightPage';
import { AgePage } from './AgePage';
import { GenderPage } from './GenderPage';
import { WakeUpPage } from './WakeUpPage';
import { BedTimePage } from './BedTimePage';
import { SensitivityPage } from './SensitivityPage';
import { CompletionPage } from './CompletionPage';

class StepConfig {
  name: string;
  title: string;
  
  constructor(name: string, title: string) {
    this.name = name;
    this.title = title;
  }
}

@Entry
@Component
struct OnboardingFlow {
  // 用户配置数据
  @State userProfile: UserProfile = new UserProfile();
  
  // 当前步骤状态
  @State currentStep: number = 0;
  @State isTransitioning: boolean = false;
  
  // 步骤配置
  private readonly steps: StepConfig[] = [
    new StepConfig('welcome', '欢迎使用咖啡伴侣'),
    new StepConfig('weight', '您的体重是？'),
    new StepConfig('age', '您的年龄是？'),
    new StepConfig('gender', '您的性别是？'),
    new StepConfig('wakeUp', '您通常几点起床？'),
    new StepConfig('bedTime', '您通常几点睡觉？'),
    new StepConfig('sensitivity', '您对咖啡因的敏感度？'),
    new StepConfig('complete', '设置完成')
  ];
  
  aboutToAppear(): void {
    // 初始化用户配置
    this.loadUserProfile();
  }
  
  async loadUserProfile(): Promise<void> {
    try {
      const prefsService = PreferencesService.getInstance();
      this.userProfile = await prefsService.loadUserProfile();
    } catch (error) {
      console.error('Failed to load user profile:', error);
    }
  }
  // 处理步骤数据选择
  onStepDataSelected(stepName: string, value: number | string): void {
    console.info(`Step ${stepName} selected:`, value);
    
    // 更新用户配置
    switch (stepName) {
      case 'weight':
        this.userProfile.weight = value as number;
        break;
      case 'age':
        this.userProfile.age = value as number;
        break;
      case 'gender':
        this.userProfile.gender = value as 'male' | 'female';
        break;
      case 'wakeUp':
        this.userProfile.wakeUpTime = value as string;
        break;
      case 'bedTime':
        this.userProfile.bedTime = value as string;
        break;
      case 'sensitivity':
        this.userProfile.caffeineSensitivity = value as 'low' | 'medium' | 'high';
        break;
    }
    
    // 计算个性化每日上限
    this.userProfile.dailyLimit = this.userProfile.calculateDailyLimit();
    
    // 延迟1秒后自动进入下一步
    setTimeout(() => {
      this.goToNextStep();
    }, 1000);
  }
  
  // 返回上一步
  onBackStep(): void {
    if (this.currentStep > 0) {
      this.isTransitioning = true;
      setTimeout(() => {
        this.currentStep--;
        this.isTransitioning = false;
      }, 300);
    }
  }
  
  // 进入下一步
  goToNextStep(): void {
    if (this.currentStep < this.steps.length - 1) {
      this.isTransitioning = true;
      setTimeout(() => {
        this.currentStep++;
        this.isTransitioning = false;
      }, 300);
    } else {
      // 完成引导
      this.completeOnboarding();
    }
  }
  
  // 完成引导流程
  async completeOnboarding(): Promise<void> {
    try {
      // 保存用户配置
      this.userProfile.isOnboardingComplete = true;
      this.userProfile.lastUpdateTime = Date.now();
      
      const prefsService = PreferencesService.getInstance();
      await prefsService.saveUserProfile(this.userProfile);
      
      // 跳转到主页面
      router.replaceUrl({ 
        url: 'pages/MainPage'
      });
    } catch (error) {
      console.error('Failed to complete onboarding:', error);
    }
  }
  // 构建当前步骤组件
  @Builder
  buildCurrentStepComponent() {
    if (this.steps[this.currentStep].name === 'welcome') {
      WelcomePage({
        onNext: () => this.goToNextStep(),
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'weight') {
      WeightPage({
        onDataSelected: (value: number) => this.onStepDataSelected('weight', value),
        onBack: () => this.onBackStep(),
        currentWeight: this.userProfile.weight,
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'age') {
      AgePage({
        onDataSelected: (value: number) => this.onStepDataSelected('age', value),
        onBack: () => this.onBackStep(),
        currentAge: this.userProfile.age,
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'gender') {
      GenderPage({
        onDataSelected: (value: string) => this.onStepDataSelected('gender', value),
        onBack: () => this.onBackStep(),
        currentGender: this.userProfile.gender,
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'wakeUp') {
      WakeUpPage({
        onDataSelected: (value: string) => this.onStepDataSelected('wakeUp', value),
        onBack: () => this.onBackStep(),
        currentTime: this.userProfile.wakeUpTime,
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'bedTime') {
      BedTimePage({
        onDataSelected: (value: string) => this.onStepDataSelected('bedTime', value),
        onBack: () => this.onBackStep(),
        currentTime: this.userProfile.bedTime,
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'sensitivity') {
      SensitivityPage({
        onDataSelected: (value: string) => this.onStepDataSelected('sensitivity', value),
        onBack: () => this.onBackStep(),
        currentSensitivity: this.userProfile.caffeineSensitivity,
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else if (this.steps[this.currentStep].name === 'complete') {
      CompletionPage({
        onBack: () => this.onBackStep(),
        currentStep: this.currentStep + 1,
        totalSteps: this.steps.length
      })
    } else {
      Column() {
        Text('未知步骤')
      }
    }
  }
  build() {
    Column() {
      this.buildCurrentStepComponent()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
    .opacity(this.isTransitioning ? 0.7 : 1)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
}