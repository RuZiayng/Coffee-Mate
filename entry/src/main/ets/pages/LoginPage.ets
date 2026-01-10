import { router } from '@kit.ArkUI';
import { authentication } from '@kit.AccountKit';
import { promptAction } from '@kit.ArkUI';
import { UserData } from '../model/UserData';

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Entry
@Component
struct LoginPage {
  @State private userData: UserData = new UserData();
  @State private phoneNumber: string = '';
  @State private password: string = '';
  @State private isRegisterMode: boolean = false;
  @State private confirmPassword: string = '';
  @State private verificationCode: string = '';
  @State private countdown: number = 0;
  @State private isHuaweiLoginLoading: boolean = false;
  @State private agreementChecked: boolean = false;
  
  private countdownTimer: number = 0;

  onPageShow() {
    // 清理路由栈，防止返回设置页面
    router.clear();
    
    const params = router.getParams() as RouteParams;
    if (params?.userData) {
      this.userData = params.userData;
    }
  }

  onBackPress(): boolean {
    // 禁用返回，用户必须完成登录或跳过
    return true;
  }

  // 发送验证码
  sendVerificationCode() {
    if (this.phoneNumber.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }
    
    // 开始倒计时
    this.countdown = 60;
    this.startCountdown();
    
    // 实际项目中这里调用发送验证码的API
    promptAction.showToast({ message: '验证码已发送', duration: 2000 });
  }

  startCountdown() {
    this.countdownTimer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        clearInterval(this.countdownTimer);
      }
    }, 1000);
  }

  // 手机号快速登录
  async quickLogin() {
    if (this.phoneNumber.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }
    
    if (this.verificationCode.length !== 6) {
      promptAction.showToast({ message: '请输入6位验证码', duration: 2000 });
      return;
    }
    
    if (!this.agreementChecked) {
      promptAction.showToast({ message: '请先同意用户协议', duration: 2000 });
      return;
    }
    
    // 模拟登录API调用
    promptAction.showToast({ message: '登录中...', duration: 1000 });
    
    // 实际项目中这里调用登录API
    await this.simulateApiCall();
    this.loginSuccess(true);
  }

  // 账号密码登录
  async passwordLogin() {
    if (!this.phoneNumber || this.phoneNumber.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }
    
    if (!this.password || this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位', duration: 2000 });
      return;
    }
    
    if (!this.agreementChecked) {
      promptAction.showToast({ message: '请先同意用户协议', duration: 2000 });
      return;
    }
    
    // 模拟登录API调用
    promptAction.showToast({ message: '登录中...', duration: 1000 });
    
    // 实际项目中这里调用登录API
    await this.simulateApiCall();
    this.loginSuccess(true);
  }

  // 注册
  async register() {
    if (!this.phoneNumber || this.phoneNumber.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }
    
    if (!this.password || this.password.length < 6) {
      promptAction.showToast({ message: '密码至少6位', duration: 2000 });
      return;
    }
    
    if (this.password !== this.confirmPassword) {
      promptAction.showToast({ message: '两次密码不一致', duration: 2000 });
      return;
    }
    
    if (!this.agreementChecked) {
      promptAction.showToast({ message: '请先同意用户协议', duration: 2000 });
      return;
    }
    
    // 模拟注册API调用
    promptAction.showToast({ message: '注册中...', duration: 1000 });
    
    // 实际项目中这里调用注册API
    await this.simulateApiCall();
    this.loginSuccess(true);
  }

  // 华为账号一键登录
  async huaweiAccountLogin() {
    if (!this.agreementChecked) {
      promptAction.showToast({ message: '请先同意用户协议', duration: 2000 });
      return;
    }
    
    this.isHuaweiLoginLoading = true;
    
    try {
      // 创建华为账号授权请求
      const request = authentication.createAuthorizationWithHuaweiIDRequest();
      request.setScope('quickLoginAnonymousPhone');
      
      // 执行授权请求
      const response = await authentication.executeRequest(request);
      
      if (response.quickLoginAnonymousPhone) {
        // 获取匿名手机号，实际项目中需要传递到服务端获取完整手机号
        const anonymousPhone = response.quickLoginAnonymousPhone;
        console.info('华为账号登录成功，匿名手机号:', anonymousPhone);
        
        // 模拟服务端交互
        await this.simulateApiCall();
        this.loginSuccess(true);
      }
    } catch (error) {
      console.error('华为账号登录失败:', error);
      promptAction.showToast({ message: '华为账号登录失败', duration: 2000 });
    } finally {
      this.isHuaweiLoginLoading = false;
    }
  }

  // 跳过登录
  skipLogin() {
    promptAction.showToast({ message: '跳过登录，进入主页面', duration: 2000 });
    this.loginSuccess(false);
  }

  loginSuccess(isLoggedIn: boolean) {
    // 如果已登录，同步数据到云端
    if (isLoggedIn) {
      this.syncDataToCloud();
    }
    
    // 跳转到主界面
    router.replaceUrl({
      url: 'pages/Index'
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }

  // 同步数据到云端
  syncDataToCloud() {
    // 实际项目中这里调用云同步API
    console.info('同步用户数据到云端:', this.userData);
  }

  // 模拟API调用
  simulateApiCall(): Promise<void> {
    return new Promise((resolve) => {
      setTimeout(() => {
        resolve();
      }, 1500);
    });
  }

  toggleMode() {
    this.isRegisterMode = !this.isRegisterMode;
    this.phoneNumber = '';
    this.password = '';
    this.confirmPassword = '';
    this.verificationCode = '';
  }

  build() {
    Column() {
      // 标题
      Text(this.isRegisterMode ? '注册账号' : '登录账号')
        .fontSize(28)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ top: 60, bottom: 40 })

      // 登录表单
      Column({ space: 20 }) {
        // 手机号输入
        TextInput({ placeholder: '请输入手机号' })
          .width('80%')
          .height(50)
          .type(InputType.Number)
          .maxLength(11)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(10)
          .onChange((value: string) => {
            this.phoneNumber = value;
          })

        if (this.isRegisterMode) {
          // 注册模式：密码输入
          TextInput({ placeholder: '请输入密码（至少6位）' })
            .width('80%')
            .height(50)
            .type(InputType.Password)
            .backgroundColor(Color.White)
            .borderRadius(10)
            .padding(10)
            .onChange((value: string) => {
              this.password = value;
            })

          TextInput({ placeholder: '请确认密码' })
            .width('80%')
            .height(50)
            .type(InputType.Password)
            .backgroundColor(Color.White)
            .borderRadius(10)
            .padding(10)
            .onChange((value: string) => {
              this.confirmPassword = value;
            })
        } else {
          // 登录模式：验证码
          Row({ space: 10 }) {
            TextInput({ placeholder: '请输入验证码' })
              .layoutWeight(1)
              .height(50)
              .type(InputType.Number)
              .maxLength(6)
              .backgroundColor(Color.White)
              .borderRadius(10)
              .padding(10)
              .onChange((value: string) => {
                this.verificationCode = value;
              })

            Button(this.countdown > 0 ? `${this.countdown}秒` : '获取验证码')
              .width(120)
              .height(50)
              .backgroundColor(this.countdown > 0 ? $r('app.color.secondary_color') : $r('app.color.accent_color'))
              .fontColor(Color.White)
              .fontSize(14)
              .borderRadius(10)
              .enabled(this.countdown === 0 && this.phoneNumber.length === 11)
              .onClick(() => {
                this.sendVerificationCode();
              })
          }
          .width('80%')
        }

        // 用户协议
        Row({ space: 10 }) {
          Checkbox()
            .select(this.agreementChecked)
            .onChange((checked: boolean) => {
              this.agreementChecked = checked;
            })
            .size({ width: 20, height: 20 })
          
          Row() {
            Text('我已阅读并同意')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Text('《用户协议》')
              .fontSize(12)
              .fontColor($r('app.color.accent_color'))
              .onClick(() => {
                // 打开用户协议页面
                promptAction.showToast({ message: '打开用户协议', duration: 1000 });
              })
            Text('和')
              .fontSize(12)
              .fontColor($r('app.color.text_secondary'))
            Text('《隐私政策》')
              .fontSize(12)
              .fontColor($r('app.color.accent_color'))
              .onClick(() => {
                // 打开隐私政策页面
                promptAction.showToast({ message: '打开隐私政策', duration: 1000 });
              })
          }
        }
        .width('80%')
        .margin({ top: 10 })

        // 登录/注册按钮
        Button(this.isRegisterMode ? '注册' : '登录')
          .width('80%')
          .height(50)
          .backgroundColor($r('app.color.accent_color'))
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(25)
          .margin({ top: 20 })
          .onClick(() => {
            if (this.isRegisterMode) {
              this.register();
            } else {
              this.quickLogin();
            }
          })

        // 切换模式
        Text(this.isRegisterMode ? '已有账号？立即登录' : '没有账号？立即注册')
          .fontSize(14)
          .fontColor($r('app.color.accent_color'))
          .margin({ top: 10 })
          .onClick(() => {
            this.toggleMode();
          })
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ bottom: 40 })

      // 分割线
      Row() {
        Divider()
          .width('30%')
        Text('或')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .margin({ left: 10, right: 10 })
        Divider()
          .width('30%')
      }
      .width('80%')
      .margin({ bottom: 30 })

      // 华为账号一键登录
      Button(this.isHuaweiLoginLoading ? '登录中...' : '华为账号一键登录')
        .width('80%')
        .height(50)
        .backgroundColor(Color.Red)
        .fontColor(Color.White)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .borderRadius(25)
        .enabled(!this.isHuaweiLoginLoading)
        .onClick(() => {
          this.huaweiAccountLogin();
        })

      // 账号密码登录（仅在登录模式下显示）
      if (!this.isRegisterMode) {
        Button('账号密码登录')
          .width('80%')
          .height(50)
          .backgroundColor($r('app.color.secondary_color'))
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(25)
          .margin({ top: 15 })
          .onClick(() => {
            this.passwordLogin();
          })
      }

      Blank()

      // 跳过登录按钮
      Button('跳过登录')
        .width('80%')
        .height(45)
        .backgroundColor(Color.Transparent)
        .fontColor($r('app.color.text_secondary'))
        .fontSize(14)
        .border({
          width: 1,
          color: $r('app.color.text_secondary')
        })
        .borderRadius(25)
        .margin({ bottom: 30 })
        .onClick(() => {
          this.skipLogin();
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .justifyContent(FlexAlign.Start)
    .alignItems(HorizontalAlign.Center)
  }

  aboutToDisappear() {
    // 清理计时器
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
    }
  }
}