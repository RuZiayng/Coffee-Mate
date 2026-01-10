import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { getUserSettings, saveUserSettings, UserSettings } from '../utils/DataManager';

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

  async onPageShow() {
    await this.loadUserSettings();
  }

  async loadUserSettings() {
    try {
      this.userSettings = await getUserSettings(getContext());
      // 创建新的对象副本
      this.originalSettings = new UserSettings();
      this.originalSettings.weight = this.userSettings.weight;
      this.originalSettings.age = this.userSettings.age;
      this.originalSettings.dailyLimit = this.userSettings.dailyLimit;
      this.originalSettings.wakeUpTime = this.userSettings.wakeUpTime;
      this.originalSettings.bedtime = this.userSettings.bedtime;
      this.originalSettings.sensitivity = this.userSettings.sensitivity;
      this.originalSettings.reminderLevel = this.userSettings.reminderLevel;
    } catch (error) {
      console.error('加载用户设置失败:', error);
    }
  }

  async saveSettings() {
    try {
      await saveUserSettings(getContext(), this.userSettings);
      promptAction.showToast({ message: '设置已保存', duration: 2000 });
      router.back();
    } catch (error) {
      console.error('保存设置失败:', error);
      promptAction.showToast({ message: '保存失败，请重试', duration: 2000 });
    }
  }

  cancelEdit() {
    // 创建新的对象副本
    this.userSettings = new UserSettings();
    this.userSettings.weight = this.originalSettings.weight;
    this.userSettings.age = this.originalSettings.age;
    this.userSettings.dailyLimit = this.originalSettings.dailyLimit;
    this.userSettings.wakeUpTime = this.originalSettings.wakeUpTime;
    this.userSettings.bedtime = this.originalSettings.bedtime;
    this.userSettings.sensitivity = this.originalSettings.sensitivity;
    this.userSettings.reminderLevel = this.originalSettings.reminderLevel;
    router.back();
  }

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button('取消')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
          .backgroundColor('transparent')
          .onClick(() => {
            this.cancelEdit();
          })

        Text('编辑设置')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_primary'))

        Button('保存')
          .fontSize(16)
          .fontColor($r('app.color.accent_color'))
          .backgroundColor('transparent')
          .onClick(() => {
            this.saveSettings();
          })
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 10, bottom: 10 })
      .justifyContent(FlexAlign.SpaceBetween)

      // 设置内容
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
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
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
              if (!isNaN(age) && age > 0) {
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