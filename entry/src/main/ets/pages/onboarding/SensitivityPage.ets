// 咖啡因敏感度选择页面 - 按照新设计标准优化
import { StepIndicator } from './components/StepIndicator';

interface CardInfo {
  title: string;
  description: string;
  tip: string;
}

@Component
export struct SensitivityPage {
  private onDataSelected: (value: string) => void = (value: string) => {};
  private onBack: () => void = () => {};
  private currentSensitivity: string = 'medium';
  private currentStep: number = 1;
  private totalSteps: number = 6;
  
  @State private localSensitivity: string = 'medium';
  @State private isActive: boolean = false;
  private jumpTimer: number | null = null;
  
  aboutToAppear() {
    this.localSensitivity = this.currentSensitivity;
    this.isActive = true;
  }
  
  aboutToDisappear() {
    if (this.jumpTimer) {
      clearTimeout(this.jumpTimer);
    }
  }
  
  onSensitivitySelect(sensitivity: string) {
    this.localSensitivity = sensitivity;
    
    // 重置并启动自动跳转计时器
    if (this.jumpTimer) clearTimeout(this.jumpTimer);
    this.jumpTimer = setTimeout(() => {
      this.isActive = false;
      setTimeout(() => this.onDataSelected(sensitivity), 300);
    }, 1200);
  }
  
  build() {
    Column() {
      // 步骤指示器
      StepIndicator({
        currentStep: this.currentStep,
        totalSteps: this.totalSteps
      })
      
      // 主内容区
      Column() {
        // 问题标题
        Text('您对咖啡因的敏感度？')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.White)
          .margin({ bottom: 10 })
        
        // 敏感度选择卡片
        Column({ space: 16 }) {
          // 低敏感度卡片
          this.buildSensitivityCard('low')
          
          // 中敏感度卡片
          this.buildSensitivityCard('medium')
          
          // 高敏感度卡片
          this.buildSensitivityCard('high')
        }
        .width('90%')
        .margin({ top: 30, bottom: 40 })
        
        // 当前选择描述
        Text(this.getSensitivityDescription())
          .fontSize(16)
          .fontColor('#B0B0B0')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 20 })
        
        // 当前选择显示
        Text(`已选择：${this.getSensitivityText()}`)
          .fontSize(16)
          .fontColor('#4DB6AC')
          .opacity(this.localSensitivity ? 1 : 0)
          .animation({ duration: 300, curve: Curve.EaseInOut })
      }
      .flexGrow(1)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      
      // 底部控制栏
      Row() {
        // "上一步"按钮
        Button('上一步', { type: ButtonType.Normal })
          .width(120)
          .height(44)
          .fontColor('#B0B0B0')
          .backgroundColor('#2A2A2A')
          .borderRadius(8)
          .onClick(() => {
            if (this.jumpTimer) clearTimeout(this.jumpTimer);
            this.onBack();
          })
      }
      .width('100%')
      .height(80)
      .justifyContent(FlexAlign.Start)
      .padding({ left: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
    .opacity(this.isActive ? 1 : 0)
    .animation({ duration: 300, curve: Curve.EaseInOut })
  }
  
  @Builder
  buildSensitivityCard(type: string) {
    // Note: In @Builder methods, we cannot declare variables with const/let
    // We'll use the values directly in the UI components

    Column() {
      Row() {
        // 选择指示器
        Circle({ width: 20, height: 20 })
          .fill(this.localSensitivity === type ? '#FFB74D' : '#3A3A3A')
          .stroke(this.localSensitivity === type ? '#FFB74D' : '#5A5A5A')
          .strokeWidth(2)
          .margin({ right: 12 })
        
        Column({ space: 4 }) {
          Text(this.getCardInfo(type).title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(this.localSensitivity === type ? '#FFB74D' : Color.White)
          
          Text(this.getCardInfo(type).description)
            .fontSize(14)
            .fontColor(this.localSensitivity === type ? '#B0B0B0' : '#666666')
        }
        .alignItems(HorizontalAlign.Start)
        .flexGrow(1)
      }
      
      // 提示文本
      Text(this.getCardInfo(type).tip)
        .fontSize(12)
        .fontColor('#4DB6AC')
        .alignSelf(ItemAlign.Start)
        .margin({ top: 8, left: 32 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.localSensitivity === type ? '#1E2A3A' : '#2A2A2A')
    .borderRadius(12)
    .border({
      width: this.localSensitivity === type ? 2 : 1,
      color: this.localSensitivity === type ? '#FFB74D' : '#3A3A3A'
    })
    .onClick(() => this.onSensitivitySelect(type))
  }

  private getCardInfo(type: string): CardInfo {
    switch (type) {
      case 'low':
        return {
          title: '低敏感度',
          description: '喝完咖啡后几乎无影响，可以正常入睡',
          tip: '适合经常饮用咖啡的用户'
        };
      case 'medium':
        return {
          title: '中敏感度',
          description: '下午3点后饮用可能影响睡眠',
          tip: '大多数人的标准敏感度'
        };
      case 'high':
        return {
          title: '高敏感度',
          description: '少量咖啡因就会影响睡眠和心率',
          tip: '建议严格控制摄入时间和剂量'
        };
      default:
        return {
          title: '未知',
          description: '',
          tip: ''
        };
    }
  }
  
  private getSensitivityDescription(): string {
    switch (this.localSensitivity) {
      case 'low':
        return '您的身体对咖啡因耐受性较强，每日建议上限较高';
      case 'medium':
        return '您的咖啡因敏感度适中，建议遵循标准摄入指南';
      case 'high':
        return '您对咖啡因较为敏感，建议严格控制摄入时间和剂量';
      default:
        return '请选择您的咖啡因敏感度';
    }
  }
  
  private getSensitivityText(): string {
    switch (this.localSensitivity) {
      case 'low': return '低敏感度';
      case 'medium': return '中敏感度';
      case 'high': return '高敏感度';
      default: return '未知';
    }
  }
}