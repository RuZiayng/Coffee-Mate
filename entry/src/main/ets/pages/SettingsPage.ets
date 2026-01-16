import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { UserData } from '../model/UserData';
import { getUserSettings, saveUserSettings, UserSettings } from '../utils/DataManager';
import common from '@ohos.app.ability.common';

@Entry
@Component
struct SettingsPage {
  @State private userData: UserData = new UserData();
  @State private userSettings: UserSettings = new UserSettings();
  @State private isLoading: boolean = false;
  @State private hasError: boolean = false;
  @State private errorMessage: string = '';

  // 安全获取UIAbilityContext - API version 18推荐方式
  private getContext(): common.UIAbilityContext | null {
    try {
      // 通过UIContext获取HostContext（API ≥18推荐）
      const uiContext = this.getUIContext();
      if (!uiContext) {
        console.warn('UIContext not available');
        return null;
      }
      
      const hostContext = uiContext.getHostContext();
      if (hostContext && (hostContext as common.UIAbilityContext).abilityInfo) {
        return hostContext as common.UIAbilityContext;
      }
      
      console.warn('UIAbilityContext not available from host context');
      return null;
    } catch (error) {
      console.error('Error getting context:', error);
      return null;
    }
  }

  // 生命周期管理 - 页面即将显示
  aboutToAppear(): void {
    console.log('SettingsPage aboutToAppear');
    this.loadUserSettings();
  }

  // 生命周期管理 - 页面显示
  onPageShow(): void {
    console.log('SettingsPage onPageShow');
    // 可选：在这里重新加载数据
  }

  // 异步数据加载 - 增强错误处理
  async loadUserSettings(): Promise<void> {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.hasError = false;
    this.errorMessage = '';
    
    try {
      const context = this.getContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      
      // 使用Promise.race添加超时保护
      const loadPromise = getUserSettings(context);
      const timeoutPromise = new Promise<never>((_, reject) => 
        setTimeout(() => reject(new Error('数据加载超时')), 5000)
      );
      
      this.userSettings = await Promise.race([loadPromise, timeoutPromise]);
      
      // 安全地同步到旧的UserData结构
      this.safeSyncUserData();
      
    } catch (error) {
      console.error('加载用户设置失败:', error);
      this.hasError = true;
      this.errorMessage = error instanceof Error ? error.message : '未知错误';
    } finally {
      this.isLoading = false;
    }
  }

  // 安全同步用户数据
  private safeSyncUserData(): void {
    try {
      this.userData.weight = this.userSettings.weight || 0;
      this.userData.age = this.userSettings.age || 0;
      this.userData.dailyLimit = this.userSettings.dailyLimit || 400;
      this.userData.wakeUpTime = this.userSettings.wakeUpTime || '07:30';
      this.userData.bedtime = this.userSettings.bedtime || '23:00';
      this.userData.sensitivity = this.userSettings.sensitivity || '';
      this.userData.reminderLevel = this.userSettings.reminderLevel || '';
    } catch (error) {
      console.error('同步用户数据失败:', error);
    }
  }

  // 安全返回
  goBack(): void {
    try {
      router.back();
    } catch (err) {
      console.error(`返回失败：${(err as BusinessError).code}-${(err as BusinessError).message}`);
      // 备用方案：尝试其他返回方式
      this.safeNavigateBack();
    }
  }

  // 安全导航回退
  private safeNavigateBack(): void {
    try {
      // 尝试清空路由栈并返回首页
      router.clear();
      router.pushUrl({ url: 'pages/MainPage' });
    } catch (error) {
      console.error('安全导航失败:', error);
    }
  }

  // 安全跳转到编辑页面
  editProfile(): void {
    try {
      const context = this.getContext();
      if (!context) {
        console.warn('上下文不可用，延迟跳转');
        // 延迟跳转，等待上下文就绪
        setTimeout(() => this.editProfile(), 100);
        return;
      }
      
      router.pushUrl({ 
        url: 'pages/EditSettingsPage'
      });
    } catch (error) {
      console.error('跳转到编辑页面失败:', error);
    }
  }

  // 重置数据
  async resetData(): Promise<void> {
    try {
      const context = this.getContext();
      if (!context) {
        throw new Error('上下文不可用');
      }
      
      // 显示确认对话框
      // 实际实现中需要添加确认对话框
      console.log('重置用户数据');
      
      // 重新加载设置
      await this.loadUserSettings();
    } catch (error) {
      console.error('重置数据失败:', error);
    }
  }

  // 导出数据
  exportData(): void {
    try {
      console.log('导出用户数据');
    } catch (error) {
      console.error('导出数据失败:', error);
    }
  }

  // 重新加载数据
  async reloadData(): Promise<void> {
    await this.loadUserSettings();
  }

  // 文本转换方法
  getGenderText(gender: string): string {
    switch (gender) {
      case 'male': return '男';
      case 'female': return '女';
      case 'prefer_not_to_say': return '不愿透露';
      default: return '未设置';
    }
  }

  getSensitivityText(sensitivity: string): string {
    switch (sensitivity) {
      case 'low': return '低';
      case 'medium': return '中';
      case 'high': return '高';
      default: return '未设置';
    }
  }

  getReminderText(reminder: string): string {
    switch (reminder) {
      case 'gentle': return '温和';
      case 'standard': return '标准';
      case 'strict': return '严格';
      default: return '未设置';
    }
  }

  // 主构建函数
  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // 根据状态显示不同内容
      if (this.isLoading) {
        this.buildLoadingState()
      } else if (this.hasError) {
        this.buildErrorState()
      } else {
        this.buildContent()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildHeader() {
    Row() {
      Button('←')
        .fontSize(18)
        .fontColor($r('app.color.accent_color'))
        .backgroundColor('transparent')
        .onClick(() => {
          this.goBack();
        })

      Text('设置')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Blank()
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
  }

  @Builder
  buildLoadingState() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
      
      Text('加载中...')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
        .margin({ top: 10 })
    }
    .width('100%')
    .height('80%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildErrorState() {
    Column({ space: 20 }) {
      Text('加载失败')
        .fontSize(18)
        .fontColor('#FF4444')
      
      Text(this.errorMessage)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .textAlign(TextAlign.Center)
      
      Button('重试')
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.accent_color'))
        .padding({ left: 30, right: 30, top: 10, bottom: 10 })
        .borderRadius(20)
        .onClick(() => {
          this.reloadData();
        })
    }
    .width('100%')
    .height('80%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .padding(40)
  }

  @Builder
  buildContent() {
    Scroll() {
      Column({ space: 20 }) {
        // 个人信息卡片
        this.buildProfileCard()

        // 应用设置
        this.buildAppSettings()

        // 数据管理
        this.buildDataManagement()

        // 关于应用
        this.buildAboutSection()
      }
      .padding(20)
    }
    .scrollBar(BarState.Off)
    .layoutWeight(1)
  }

  @Builder
  buildProfileCard() {
    Column({ space: 15 }) {
      Row() {
        Text('个人信息')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))

        Blank()

        Button('编辑')
          .fontSize(14)
          .fontColor($r('app.color.accent_color'))
          .backgroundColor('transparent')
          .onClick(() => {
            this.editProfile();
          })
      }
      .width('100%')

      // 个人信息详情
      Column({ space: 8 }) {
        this.buildSettingItem('体重', `${this.userData.weight || 0} kg`);
        this.buildSettingItem('年龄', `${this.userData.age || 0} 岁`);
        this.buildSettingItem('性别', this.getGenderText(this.userData.gender || ''));
        this.buildSettingItem('起床时间', this.userData.wakeUpTime || '未设置');
        this.buildSettingItem('就寝时间', this.userData.bedtime || '未设置');
        this.buildSettingItem('敏感度', this.getSensitivityText(this.userData.sensitivity || ''));
        this.buildSettingItem('每日上限', `${this.userData.dailyLimit || 400} mg`);
        this.buildSettingItem('提醒强度', this.getReminderText(this.userData.reminderLevel || ''));
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildAppSettings() {
    Column({ space: 15 }) {
      Text('应用设置')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 10 }) {
        this.buildToggleItem('推送提醒', this.userSettings.pushNotifications || false);
        this.buildToggleItem('声音提醒', this.userSettings.soundNotifications || false);
        this.buildToggleItem('振动提醒', this.userSettings.vibrationNotifications || false);
        this.buildToggleItem('夜间模式', this.userSettings.nightMode || false);
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildDataManagement() {
    Column({ space: 15 }) {
      Text('数据管理')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 10 }) {
        this.buildActionItem('重置数据', '清除所有记录', this.resetData.bind(this));
        this.buildActionItem('导出数据', '备份您的记录', this.exportData.bind(this));
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildAboutSection() {
    Column({ space: 15 }) {
      Text('关于应用')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 8 }) {
        this.buildSettingItem('版本', '1.0.0');
        this.buildSettingItem('开发者', 'Coffee Mate Team');
        this.buildSettingItem('联系方式', 'support@coffeemate.com');
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildSettingItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
      
      Blank()
      
      Text(value)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  buildToggleItem(label: string, value: boolean) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
      
      Blank()
      
      Toggle({ type: ToggleType.Switch, isOn: value })
        .onChange(async (isOn: boolean) => {
          await this.handleToggleChange(label, isOn);
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }

  // 处理开关变化
  private async handleToggleChange(label: string, isOn: boolean): Promise<void> {
    try {
      console.log(`${label} 开关状态:`, isOn);
      
      // 更新对应的设置项
      switch (label) {
        case '推送提醒':
          this.userSettings.pushNotifications = isOn;
          break;
        case '声音提醒':
          this.userSettings.soundNotifications = isOn;
          break;
        case '振动提醒':
          this.userSettings.vibrationNotifications = isOn;
          break;
        case '夜间模式':
          this.userSettings.nightMode = isOn;
          break;
      }
      
      // 保存设置
      const context = this.getContext();
      if (context) {
        await saveUserSettings(context, this.userSettings);
        console.log('设置保存成功');
      } else {
        console.warn('无法获取上下文，设置保存失败');
      }
    } catch (error) {
      console.error('保存设置失败:', error);
    }
  }

  @Builder
  buildActionItem(label: string, description: string, action: () => void) {
    Button() {
      Row() {
        Column({ space: 2 }) {
          Text(label)
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .textAlign(TextAlign.Start)
          
          Text(description)
            .fontSize(12)
            .fontColor($r('app.color.text_tertiary'))
            .textAlign(TextAlign.Start)
        }
        .alignItems(HorizontalAlign.Start)
        .width('80%')

        Blank()

        Text('›')
          .fontSize(18)
          .fontColor($r('app.color.neutral_gray'))
      }
      .width('100%')
    }
    .width('100%')
    .height(60)
    .backgroundColor('transparent')
    .borderRadius(8)
    .onClick(action)
  }
}