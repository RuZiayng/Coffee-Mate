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

  // 获取UIAbilityContext
  private getContext(): common.UIAbilityContext {
    const context = this.getUIContext().getHostContext();
    if (context && (context as common.UIAbilityContext).abilityInfo) {
      return context as common.UIAbilityContext;
    }
    throw new Error('Failed to get UIAbilityContext');
  }

  async onPageShow() {
    await this.loadUserSettings();
  }

  async loadUserSettings() {
    try {
      const context = this.getContext();
      this.userSettings = await getUserSettings(context);
      
      // 同步到旧的UserData结构（兼容性）
      this.userData.weight = this.userSettings.weight;
      this.userData.age = this.userSettings.age;
      this.userData.dailyLimit = this.userSettings.dailyLimit;
      this.userData.wakeUpTime = this.userSettings.wakeUpTime;
      this.userData.bedtime = this.userSettings.bedtime;
      this.userData.sensitivity = this.userSettings.sensitivity;
      this.userData.reminderLevel = this.userSettings.reminderLevel;
    } catch (error) {
      console.error('加载用户设置失败:', error);
    }
  }

  goBack() {
    try {
      router.back();
    } catch (err) {
      console.error(`返回失败：${(err as BusinessError).code}-${(err as BusinessError).message}`);
    }
  }

  editProfile() {
    // 跳转到设置编辑页面（需要创建）
    router.pushUrl({ 
      url: 'pages/EditSettingsPage'
    });
  }

  resetData() {
    // 重置数据逻辑
    console.log('重置用户数据');
  }

  exportData() {
    // 导出数据逻辑
    console.log('导出用户数据');
  }

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

  build() {
    Column() {
      // 顶部标题栏
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

      // 设置内容
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
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
        this.buildSettingItem('体重', `${this.userData.weight} kg`);
        this.buildSettingItem('年龄', `${this.userData.age} 岁`);
        this.buildSettingItem('性别', this.getGenderText(this.userData.gender));
        this.buildSettingItem('起床时间', this.userData.wakeUpTime);
        this.buildSettingItem('就寝时间', this.userData.bedtime);
        this.buildSettingItem('敏感度', this.getSensitivityText(this.userData.sensitivity));
        this.buildSettingItem('每日上限', `${this.userData.dailyLimit} mg`);
        this.buildSettingItem('提醒强度', this.getReminderText(this.userData.reminderLevel));
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
        this.buildActionItem('重置数据', '清除所有记录', this.resetData);
        this.buildActionItem('导出数据', '备份您的记录', this.exportData);
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
          try {
            const context = this.getContext();
            await saveUserSettings(context, this.userSettings);
          } catch (error) {
            console.error('保存设置失败:', error);
          }
        })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
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