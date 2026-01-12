import { router } from '@kit.ArkUI';
import { UserData } from '../model/UserData';

@Component
struct SummaryPage {
  @State private userData: UserData = new UserData();
  @State private isSaving: boolean = false;
  @State private saveSuccess: boolean = false;

  aboutToAppear() {
    const params = router.getParams() as Record<string, UserData>;
    if (params && params['userData']) {
      this.userData = params['userData'] as UserData;
    }
  }

  saveUserData() {
    this.isSaving = true;
    
    // 模拟保存过程
    setTimeout(() => {
      this.isSaving = false;
      this.saveSuccess = true;
      
      // 2秒后跳转到完成页面
      setTimeout(() => {
        router.pushUrl({ 
          url: 'pages/FinishPage',
          params: { userData: this.userData }
        });
      }, 2000);
    }, 1500);
  }

  onBackPress(): boolean {
    // 禁用返回，用户必须完成设置
    return true;
  }

  goBack() {
    router.back();
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
      if (this.saveSuccess) {
        // 保存成功界面
        Column({ space: 20 }) {
          Image($r('app.media.startIcon'))
            .width(120)
            .height(120)
            .margin({ bottom: 20 })

          Text('设置完成！')
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')

          Text('您的个人资料已保存，开始使用Coffee Mate吧！')
            .fontSize(16)
            .fontColor('#666666')
            .textAlign(TextAlign.Center)
            .width('80%')
        }
        .alignItems(HorizontalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .height('100%')
      } else {
        // 信息确认界面
        Column({ space: 15 }) {
          // 标题
          Text('确认您的设置')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#388E3C')
            .margin({ bottom: 30 })

          // 信息列表
          Column({ space: 12 }) {
            this.buildInfoItem('体重', `${this.userData.weight} kg`);
            this.buildInfoItem('年龄', `${this.userData.age} 岁`);
            this.buildInfoItem('性别', this.getGenderText(this.userData.gender));
            this.buildInfoItem('起床时间', this.userData.wakeUpTime);
            this.buildInfoItem('就寝时间', this.userData.bedtime);
            this.buildInfoItem('咖啡因敏感度', this.getSensitivityText(this.userData.sensitivity));
            this.buildInfoItem('每日上限', `${this.userData.dailyLimit} mg`);
            this.buildInfoItem('提醒强度', this.getReminderText(this.userData.reminderLevel));
          }
          .padding(20)
          .backgroundColor(Color.White)
          .borderRadius(12)
          .width('90%')
          .margin({ bottom: 40 })

          // 按钮区域
          Column({ space: 15 }) {
            Button(this.isSaving ? '保存中...' : '确认保存')
              .width(280)
              .height(50)
              .backgroundColor(this.isSaving ? '#CCCCCC' : '#4CAF50')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(25)
              .enabled(!this.isSaving)
              .onClick(() => {
                this.saveUserData();
              })

            Button('返回修改')
              .width(280)
              .height(50)
              .backgroundColor('#8BC34A')
              .fontColor(Color.White)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .borderRadius(25)
              .onClick(() => {
                this.goBack();
              })
          }
          .alignItems(HorizontalAlign.Center)
        }
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F8E9')
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }

  @Builder
  buildInfoItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(14)
        .fontColor('#666666')
        .width('40%')
      
      Text(value)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#182431')
        .width('60%')
        .textAlign(TextAlign.End)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}