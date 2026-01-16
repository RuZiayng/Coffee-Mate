// 主页面 - 引导流程入口
import { UserProfile } from '../model/UserProfile';
import { PreferencesService } from '../services/PreferencesService';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct MainPage {
  @State userProfile: UserProfile = new UserProfile();
  @State showWelcome: boolean = true;
  
  aboutToAppear() {
    this.checkOnboardingStatus();
  }
  
  async checkOnboardingStatus() {
    try {
      const prefsService = PreferencesService.getInstance();
      
      // 检查PreferencesService是否已初始化
      if (!prefsService.isInitialized()) {
        console.warn('PreferencesService not initialized, proceeding with default onboarding');
        // 服务未初始化，默认跳转到引导流程
        setTimeout(() => {
          router.replaceUrl({ 
            url: 'pages/onboarding/OnboardingFlow'
          });
        }, 3000);
        return;
      }
      
      this.userProfile = await prefsService.loadUserProfile();
      
      // 检查用户是否已完成引导
      if (this.userProfile && this.userProfile.isOnboardingComplete) {
        // 已完成引导，直接进入主应用
        setTimeout(() => {
          router.replaceUrl({ 
            url: 'pages/Index'
          });
        }, 1500);
      } else {
        // 未完成引导，显示欢迎界面
        this.showWelcome = true;
        
        // 3秒后自动跳转到引导流程
        setTimeout(() => {
          router.replaceUrl({ 
            url: 'pages/onboarding/OnboardingFlow'
          });
        }, 3000);
      }
    } catch (error) {
      console.error('Failed to check onboarding status:', error);
      
      // 出错时默认跳转到引导流程
      setTimeout(() => {
        router.replaceUrl({ 
          url: 'pages/onboarding/OnboardingFlow'
        });
      }, 3000);
    }
  }
  
  build() {
    Column() {
      if (this.showWelcome) {
        // 欢迎界面
        Column() {
          // 应用图标
          Text('☕')
            .fontSize(80)
            .margin({ bottom: 20 })
          
          // 应用名称
          Text('咖啡伴侣')
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ bottom: 10 })
          
          // 应用描述
          Text('智能咖啡因追踪助手')
            .fontSize(18)
            .fontColor('#B0B0B0')
            .margin({ bottom: 40 })
          
          // 加载提示
          Text('正在检查设置...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 主应用内容（备用）
        Column() {
          Text('咖啡伴侣')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
            .margin({ bottom: 20 })
          
          Text('加载中...')
            .fontSize(16)
            .fontColor('#B0B0B0')
        }
        .flexGrow(1)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
  }
}