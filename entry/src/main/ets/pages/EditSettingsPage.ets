import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { getUserSettings, saveUserSettings, UserSettings } from '../utils/DataManager';
import common from '@ohos.app.ability.common';

// 定义选项接口
interface Option {
  label: string;
  value: string;
}

@Entry
@Component
struct EditSettingsPage {
  @State private userSettings: UserSettings = new UserSettings();
  @State private originalSettings: UserSettings = new UserSettings();
  @State private isLoading: boolean = false;
  @State private hasError: boolean = false;
  @State private isSaving: boolean = false;

  // 敏感度选项
  private readonly sensitivityOptions: Option[] = [
    { label: '低敏感度', value: 'low' },
    { label: '中等敏感度', value: 'medium' },
    { label: '高敏感度', value: 'high' }
  ];

  // 提醒强度选项
  private readonly reminderOptions: Option[] = [
    { label: '温和提醒', value: 'gentle' },
    { label: '标准提醒', value: 'standard' },
    { label: '严格提醒', value: 'strict' }
  ];

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

  // 生命周期管理
  aboutToAppear(): void {
    console.log('EditSettingsPage aboutToAppear');
    this.loadUserSettings();
  }

  // 异步数据加载
  async loadUserSettings(): Promise<void> {
    if (this.isLoading) return;
    
    this.isLoading = true;
    this.hasError = false;
    
    try {
      const context = this.getContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      
      // 添加超时保护
      const loadPromise = getUserSettings(context);
      const timeoutPromise = new Promise<never>((_, reject) => 
        setTimeout(() => reject(new Error('数据加载超时')), 5000)
      );
      
      this.userSettings = await Promise.race([loadPromise, timeoutPromise]);
      
      // 创建新的对象副本
      this.originalSettings = this.deepCopySettings(this.userSettings);
      
    } catch (error) {
      console.error('加载用户设置失败:', error);
      this.hasError = true;
      promptAction.showToast({ 
        message: '加载设置失败，请重试', 
        duration: 2000 
      });
    } finally {
      this.isLoading = false;
    }
  }

  // 深拷贝设置对象
  private deepCopySettings(settings: UserSettings): UserSettings {
    const copy = new UserSettings();
    copy.weight = settings.weight;
    copy.age = settings.age;
    copy.gender = settings.gender;
    copy.dailyLimit = settings.dailyLimit;
    copy.wakeUpTime = settings.wakeUpTime;
    copy.bedtime = settings.bedtime;
    copy.sensitivity = settings.sensitivity;
    copy.reminderLevel = settings.reminderLevel;
    copy.pushNotifications = settings.pushNotifications;
    copy.soundNotifications = settings.soundNotifications;
    copy.vibrationNotifications = settings.vibrationNotifications;
    copy.nightMode = settings.nightMode;
    return copy;
  }

  // 保存设置
  async saveSettings(): Promise<void> {
    if (this.isSaving) return;
    
    this.isSaving = true;
    
    try {
      // 验证数据
      if (!this.validateSettings()) {
        return;
      }
      
      const context = this.getContext();
      if (!context) {
        throw new Error('无法获取应用上下文');
      }
      
      // 添加超时保护
      const savePromise = saveUserSettings(context, this.userSettings);
      const timeoutPromise = new Promise<never>((_, reject) => 
        setTimeout(() => reject(new Error('保存超时')), 5000)
      );
      
      await Promise.race([savePromise, timeoutPromise]);
      
      promptAction.showToast({ 
        message: '设置已保存', 
        duration: 2000 
      });
      
      // 延迟返回，确保Toast显示完整
      setTimeout(() => {
        this.safeNavigateBack();
      }, 500);
      
    } catch (error) {
      console.error('保存设置失败:', error);
      promptAction.showToast({ 
        message: '保存失败，请重试', 
        duration: 2000 
      });
    } finally {
      this.isSaving = false;
    }
  }

  // 验证设置
  private validateSettings(): boolean {
    if (this.userSettings.weight <= 0) {
      promptAction.showToast({ 
        message: '体重必须大于0', 
        duration: 2000 
      });
      return false;
    }
    
    if (this.userSettings.age <= 0 || this.userSettings.age > 150) {
      promptAction.showToast({ 
        message: '年龄必须在1-150之间', 
        duration: 2000 
      });
      return false;
    }
    
    if (this.userSettings.dailyLimit <= 0) {
      promptAction.showToast({ 
        message: '每日上限必须大于0', 
        duration: 2000 
      });
      return false;
    }
    
    return true;
  }

  // 取消编辑
  cancelEdit(): void {
    try {
      // 恢复原始设置
      this.userSettings = this.deepCopySettings(this.originalSettings);
      this.safeNavigateBack();
    } catch (error) {
      console.error('取消编辑失败:', error);
      this.safeNavigateBack();
    }
  }

  // 安全导航回退
  private safeNavigateBack(): void {
    try {
      router.back();
    } catch (err) {
      console.error(`返回失败：${(err as BusinessError).code}-${(err as BusinessError).message}`);
      
      // 备用方案
      try {
        router.clear();
        router.pushUrl({ url: 'pages/SettingsPage' });
      } catch (error) {
        console.error('安全导航失败:', error);
      }
    }
  }

  // 重新加载数据
  async reloadData(): Promise<void> {
    await this.loadUserSettings();
  }

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
      Button('取消')
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
        .backgroundColor('transparent')
        .enabled(!this.isSaving)
        .onClick(() => {
          this.cancelEdit();
        })

      Text('编辑设置')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))

      Button(this.isSaving ? '保存中...' : '保存')
        .fontSize(16)
        .fontColor(this.isSaving ? $r('app.color.text_secondary') : $r('app.color.accent_color'))
        .backgroundColor('transparent')
        .enabled(!this.isSaving)
        .onClick(() => {
          this.saveSettings();
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, top: 10, bottom: 10 })
    .justifyContent(FlexAlign.SpaceBetween)
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
      
      Text('无法加载设置，请检查网络连接后重试')
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
        // 基础信息
        this.buildBasicSettings()

        // 时间设置
        this.buildTimeSettings()

        // 敏感度设置
        this.buildSensitivitySettings()

        // 提醒设置
        this.buildReminderSettings()
      }
      .padding(20)
    }
    .scrollBar(BarState.Off)
  }

  @Builder
  buildBasicSettings() {
    Column({ space: 15 }) {
      Text('基础信息')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 10 }) {
        // 体重设置
        Row({ space: 10 }) {
          Text('体重')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .width(80)
          
          TextInput({ text: this.userSettings.weight.toString() })
            .layoutWeight(1)
            .height(40)
            .type(InputType.Number)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onChange((value: string) => {
              const weight = parseFloat(value);
              if (!isNaN(weight) && weight > 0) {
                this.userSettings.weight = weight;
              }
            })
          
          Text('kg')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }

        // 年龄设置
        Row({ space: 10 }) {
          Text('年龄')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .width(80)
          
          TextInput({ text: this.userSettings.age.toString() })
            .layoutWeight(1)
            .height(40)
            .type(InputType.Number)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onChange((value: string) => {
              const age = parseInt(value);
              if (!isNaN(age) && age > 0 && age <= 150) {
                this.userSettings.age = age;
              }
            })
          
          Text('岁')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }

        // 每日上限
        Row({ space: 10 }) {
          Text('每日上限')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .width(80)
          
          TextInput({ text: this.userSettings.dailyLimit.toString() })
            .layoutWeight(1)
            .height(40)
            .type(InputType.Number)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onChange((value: string) => {
              const limit = parseFloat(value);
              if (!isNaN(limit) && limit > 0) {
                this.userSettings.dailyLimit = limit;
              }
            })
          
          Text('mg')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildTimeSettings() {
    Column({ space: 15 }) {
      Text('作息时间')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 10 }) {
        // 起床时间
        Row({ space: 10 }) {
          Text('起床时间')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .width(80)
          
          TextInput({ text: this.userSettings.wakeUpTime })
            .layoutWeight(1)
            .height(40)
            .type(InputType.Normal)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onChange((value: string) => {
              this.userSettings.wakeUpTime = value;
            })
        }

        // 就寝时间
        Row({ space: 10 }) {
          Text('就寝时间')
            .fontSize(14)
            .fontColor($r('app.color.text_primary'))
            .width(80)
          
          TextInput({ text: this.userSettings.bedtime })
            .layoutWeight(1)
            .height(40)
            .type(InputType.Normal)
            .backgroundColor(Color.White)
            .borderRadius(8)
            .padding(10)
            .onChange((value: string) => {
              this.userSettings.bedtime = value;
            })
        }
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildSensitivitySettings() {
    Column({ space: 15 }) {
      Text('咖啡因敏感度')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 8 }) {
        ForEach(this.sensitivityOptions, (option: Option) => {
          Row({ space: 10 }) {
            Radio({ value: option.value, group: 'sensitivity' })
              .checked(this.userSettings.sensitivity === option.value)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.userSettings.sensitivity = option.value;
                }
              })
            
            Text(option.label)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .onClick(() => {
                this.userSettings.sensitivity = option.value;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        })
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }

  @Builder
  buildReminderSettings() {
    Column({ space: 15 }) {
      Text('提醒设置')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
        .width('100%')
        .textAlign(TextAlign.Start)

      Column({ space: 8 }) {
        ForEach(this.reminderOptions, (option: Option) => {
          Row({ space: 10 }) {
            Radio({ value: option.value, group: 'reminder' })
              .checked(this.userSettings.reminderLevel === option.value)
              .onChange((checked: boolean) => {
                if (checked) {
                  this.userSettings.reminderLevel = option.value;
                }
              })
            
            Text(option.label)
              .fontSize(14)
              .fontColor($r('app.color.text_primary'))
              .onClick(() => {
                this.userSettings.reminderLevel = option.value;
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
        })
      }
    }
    .padding(20)
    .backgroundColor($r('app.color.card_background'))
    .borderRadius(12)
    .width('100%')
  }
}