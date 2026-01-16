import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { IntakeRecord, CaffeineLevel, getCaffeineLevel } from '../utils/CaffeineCalculator';
import { getUserSettings, getTodayIntakeRecords, addIntakeRecord, UserSettings } from '../utils/DataManager';
import { PreferencesService } from '../services/PreferencesService';
import common from '@ohos.app.ability.common';

// 定义饮品选项接口
interface BeverageOption {
  name: string;
  amount: number;
}

@Entry
@Component
struct Index {
  @State private currentTime: string = '';
  @State private caffeineLevel: CaffeineLevel = new CaffeineLevel(0, [], 400);
  @State private intakeRecords: IntakeRecord[] = [];
  @State private userSettings: UserSettings = new UserSettings();
  @State private showRecordDialog: boolean = false;
  @State private customAmount: string = '';
  @State private selectedBeverage: string = '';
  
  private timeUpdateTimer: number = 0;
  private dataUpdateTimer: number = 0;

  // 常见饮品咖啡因含量
  private readonly beverageOptions: BeverageOption[] = [
    { name: '美式咖啡', amount: 150 },
    { name: '拿铁', amount: 75 },
    { name: '卡布奇诺', amount: 75 },
    { name: '浓缩咖啡', amount: 64 },
    { name: '绿茶', amount: 30 },
    { name: '红茶', amount: 47 },
    { name: '可乐', amount: 34 },
    { name: '能量饮料', amount: 80 }
  ];

  // 获取UIAbilityContext - 安全获取方法
  private getContext(): common.UIAbilityContext | null {
    const uiContext = this.getUIContext();
    if (!uiContext) {
      console.error('Failed to get UIContext');
      return null;
    }
    
    const hostContext = uiContext.getHostContext();
    if (hostContext && (hostContext as common.UIAbilityContext).abilityInfo) {
      return hostContext as common.UIAbilityContext;
    }
    
    console.error('Failed to get UIAbilityContext from host context');
    return null;
  }

  aboutToAppear() {
    this.checkOnboardingStatus();
    this.initializeData();
    this.startTimers();
  }

  aboutToDisappear() {
    this.stopTimers();
  }

  async checkOnboardingStatus() {
    try {
      const prefsService = PreferencesService.getInstance();
      const isOnboardingCompleted = await prefsService.isOnboardingCompleted();
      
      if (!isOnboardingCompleted) {
        // 跳转到引导页面
        router.replaceUrl({ 
          url: 'pages/onboarding/OnboardingFlow'
        });
      }
    } catch (error) {
      console.error('Failed to check onboarding status:', error);
    }
  }

  async initializeData() {
    try {
      const context = this.getContext();
      if (!context) {
        console.error('无法获取上下文，数据初始化失败');
        return;
      }
      
      // 获取用户设置
      this.userSettings = await getUserSettings(context);
      
      // 获取今日摄入记录
      this.intakeRecords = await getTodayIntakeRecords(context);
      
      // 计算当前咖啡因含量
      this.updateCaffeineLevel();
      
    } catch (error) {
      console.error('数据初始化失败:', error);
    }
  }

  startTimers() {
    // 更新时间显示
    this.updateTime();
    this.timeUpdateTimer = setInterval(() => {
      this.updateTime();
    }, 1000);

    // 定期更新数据（每30秒）
    this.dataUpdateTimer = setInterval(() => {
      this.updateCaffeineLevel();
    }, 30000);
  }

  stopTimers() {
    if (this.timeUpdateTimer) {
      clearInterval(this.timeUpdateTimer);
    }
    if (this.dataUpdateTimer) {
      clearInterval(this.dataUpdateTimer);
    }
  }

  updateTime() {
    const now = new Date();
    this.currentTime = now.toLocaleTimeString('zh-CN', { 
      hour: '2-digit', 
      minute: '2-digit' 
    });
  }

  updateCaffeineLevel() {
    this.caffeineLevel = getCaffeineLevel(
      this.intakeRecords,
      this.userSettings.weight || 70,
      this.userSettings.dailyLimit || 400
    );
  }

  async addIntake(amount: number, beverageName: string) {
    try {
      const context = this.getContext();
      if (!context) {
        console.error('无法获取上下文，记录添加失败');
        promptAction.showToast({ message: '记录失败，请重试', duration: 2000 });
        return;
      }
      
      const record = new IntakeRecord(amount, new Date(), beverageName);
      await addIntakeRecord(context, record);
      
      // 更新本地记录
      this.intakeRecords = await getTodayIntakeRecords(context);
      this.updateCaffeineLevel();
      
      promptAction.showToast({ message: `已记录 ${beverageName} ${amount}mg`, duration: 2000 });
      
    } catch (error) {
      console.error('添加摄入记录失败:', error);
      promptAction.showToast({ message: '记录失败，请重试', duration: 2000 });
    }
  }

  openSettings() {
    router.pushUrl({
      url: 'pages/SettingsPage'
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }

  // 获取进度条颜色
  getProgressColor(percentage: number): string {
    if (percentage <= 60) return '#4CAF50'; // 绿色
    if (percentage <= 85) return '#FFC107'; // 黄色
    return '#F44336'; // 红色
  }

  build() {
    Column() {
      // 1. 顶部状态栏
      this.buildTopBar()

      // 2. 中央可视化区域 - 半圆形进度条
      this.buildProgressCircle()

      // 3. 时间轴区域 - 代谢预测曲线
      this.buildPredictionChart()

      // 4. 底部操作区域
      this.buildBottomActions()

      // 5. 记录摄入对话框
      this.buildRecordDialog()

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
  }

  @Builder
  buildTopBar() {
    Row() {
      // 当前时间
      Text(this.currentTime)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))

      Blank()

      // 设置按钮
      Button('')
        .width(40)
        .height(40)
        .backgroundColor(Color.Transparent)
        .backgroundImage($r('app.media.settings_icon'))
        .backgroundImageSize({ width: 24, height: 24 })
        .onClick(() => {
          this.openSettings();
        })
    }
    .width('90%')
    .height(60)
    .margin({ top: 30 })
  }

  @Builder
  buildProgressCircle() {
    Column({ space: 10 }) {
      // 进度条容器
      Stack({ alignContent: Alignment.Center }) {
        // 背景圆环
        Circle({ width: 200, height: 200 })
          .fill(Color.Transparent)
          .stroke($r('app.color.neutral_gray'))
          .strokeWidth(12)

        // 进度圆环
        Circle({ width: 200, height: 200 })
          .fill(Color.Transparent)
          .stroke(this.getProgressColor(this.caffeineLevel.percentage))
          .strokeWidth(12)
          .strokeDashArray([Math.PI * 100 * (this.caffeineLevel.percentage / 100), Math.PI * 100])
          .strokeDashOffset(Math.PI * 100 * 0.25)

        // 中央文字
        Column({ space: 5 }) {
          Text(`${Math.round(this.caffeineLevel.currentLevel)}mg`)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_color'))

          Text(`/ ${this.userSettings.dailyLimit || 400}mg`)
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
        }
      }
      .margin({ top: 20, bottom: 10 })

      // 状态提示
      Text(this.getStatusText(this.caffeineLevel.percentage))
        .fontSize(16)
        .fontColor(this.getProgressColor(this.caffeineLevel.percentage))
    }
    .alignItems(HorizontalAlign.Center)
    .width('100%')
    .margin({ top: 20, bottom: 30 })
  }

  @Builder
  buildPredictionChart() {
    Column({ space: 15 }) {
      Text('未来6小时代谢预测')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.primary_color'))
        .width('90%')
        .textAlign(TextAlign.Start)

      // 简化的预测图表（使用矩形条表示）
      Row({ space: 8 }) {
        ForEach(this.caffeineLevel.prediction, (value: number, index: number) => {
          Column({ space: 5 }) {
            // 柱子
            Column()
              .width(30)
              .height(Math.max(10, value / (this.userSettings.dailyLimit || 400) * 80))
              .backgroundColor(this.getProgressColor((value / (this.userSettings.dailyLimit || 400)) * 100))
              .borderRadius(4)

            // 时间标签
            Text(`${index}h`)
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Center)
        })
      }
      .width('90%')
      .height(100)
      .justifyContent(FlexAlign.End)
      .alignItems(VerticalAlign.Bottom)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: 30 })
  }

  @Builder
  buildBottomActions() {
    Column({ space: 15 }) {
      // 记录摄入按钮
      Button('记录摄入')
        .width('90%')
        .height(50)
        .backgroundColor($r('app.color.accent_color'))
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(25)
        .onClick(() => {
          this.showRecordDialog = true;
        })

      // 快捷操作按钮组
      Row({ space: 20 }) {
        ForEach(this.beverageOptions.slice(0, 3), (beverage: BeverageOption) => {
          Column({ space: 5 }) {
            Button(beverage.name)
              .width(80)
              .height(40)
              .backgroundColor($r('app.color.secondary_color'))
              .fontColor(Color.White)
              .fontSize(12)
              .borderRadius(20)
              .onClick(() => {
                this.addIntake(beverage.amount, beverage.name);
              })
            Text(`${beverage.amount}mg`)
              .fontSize(10)
              .fontColor($r('app.color.text_secondary'))
          }
        })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  // 获取状态文本
  getStatusText(percentage: number): string {
    if (percentage <= 60) return '安全范围';
    if (percentage <= 85) return '接近上限';
    if (percentage <= 100) return '超过上限';
    return '严重超标';
  }

  // 记录摄入对话框
  @Builder
  buildRecordDialog() {
    if (this.showRecordDialog) {
      Column() {
        // 遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor(Color.Black)
          .opacity(0.5)
          .onClick(() => {
            this.showRecordDialog = false;
          })

        // 对话框内容
        Column({ space: 20 }) {
          Text('记录咖啡因摄入')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.primary_color'))

          // 饮品选择
          Text('选择饮品：')
            .fontSize(14)
            .fontColor($r('app.color.text_secondary'))
            .width('100%')
            .textAlign(TextAlign.Start)

          Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.Start }) {
            ForEach(this.beverageOptions, (beverage: BeverageOption) => {
              Button(beverage.name)
                .padding(10)
                .backgroundColor(this.selectedBeverage === beverage.name ? $r('app.color.accent_color') : $r('app.color.button_background'))
                .fontColor(this.selectedBeverage === beverage.name ? Color.White : $r('app.color.primary_color'))
                .borderRadius(15)
                .margin(5)
                .onClick(() => {
                  this.selectedBeverage = beverage.name;
                  this.customAmount = beverage.amount.toString();
                })
            })
          }
          .width('100%')

          // 自定义输入
          Row({ space: 10 }) {
            TextInput({ placeholder: '自定义含量(mg)' })
              .layoutWeight(1)
              .height(40)
              .type(InputType.Number)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .padding(10)
              .onChange((value: string) => {
                this.customAmount = value;
                this.selectedBeverage = '自定义';
              })

            Text('mg')
              .fontSize(14)
              .fontColor($r('app.color.text_secondary'))
          }
          .width('100%')

          // 操作按钮
          Row({ space: 15 }) {
            Button('取消')
              .layoutWeight(1)
              .height(40)
              .backgroundColor($r('app.color.secondary_color'))
              .fontColor(Color.White)
              .borderRadius(20)
              .onClick(() => {
                this.showRecordDialog = false;
                this.selectedBeverage = '';
                this.customAmount = '';
              })

            Button('确认')
              .layoutWeight(1)
              .height(40)
              .backgroundColor($r('app.color.accent_color'))
              .fontColor(Color.White)
              .borderRadius(20)
              .onClick(() => {
                if (this.customAmount && parseFloat(this.customAmount) > 0) {
                  this.addIntake(parseFloat(this.customAmount), this.selectedBeverage || '自定义饮品');
                  this.showRecordDialog = false;
                  this.selectedBeverage = '';
                  this.customAmount = '';
                } else {
                  promptAction.showToast({ message: '请输入有效的含量', duration: 2000 });
                }
              })
          }
          .width('100%')
        }
        .width('80%')
        .padding(20)
        .backgroundColor(Color.White)
        .borderRadius(15)
        .position({ x: '10%', y: '20%' })
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
    }
  }
}