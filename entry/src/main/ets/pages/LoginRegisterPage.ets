import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { LoginWithHuaweiIDButton, loginComponentManager } from '@kit.AccountKit';
import { UserData } from '../model/UserData';
import { promptAction } from '@kit.ArkUI';

// 华为账号登录响应类型定义
class HuaweiLoginResponse {
  authorizationCode?: string;
  openID?: string;
  unionID?: string;
  displayName?: string;
  email?: string;
  profilePictureUri?: string;
}

// 路由参数类型定义
class RouteParams {
  userData?: UserData;
}

@Entry
@Component
struct LoginRegisterPage {
  @State private userData: UserData = new UserData();
  @State private loginType: string = 'quick'; // quick: 手机号快速登录, password: 账号密码注册
  @State private phoneNumber: string = '';
  @State private verificationCode: string = '';
  @State private username: string = '';
  @State private password: string = '';
  @State private confirmPassword: string = '';
  @State private countdown: number = 0;
  @State private isCounting: boolean = false;

  // 华为账号登录控制器
  controller: loginComponentManager.LoginWithHuaweiIDButtonController = 
    new loginComponentManager.LoginWithHuaweiIDButtonController()
    .onClickLoginWithHuaweiIDButton((error: BusinessError, response: HuaweiLoginResponse) => {
      if (error) {
        this.handleHuaweiLoginError(error);
        return;
      }
      if (response) {
        this.handleHuaweiLoginSuccess(response);
      }
    });

  onPageShow() {
    const params = router.getParams() as RouteParams;
    if (params?.userData) {
      this.userData = params.userData;
    }
    
    // 禁用返回
    router.clear();
  }

  onBackPress(): boolean {
    // 禁用返回
    return true;
  }

  // 华为账号登录成功处理
  handleHuaweiLoginSuccess(response: HuaweiLoginResponse) {
    const authCode = response.authorizationCode;
    const openID = response.openID;
    const unionID = response.unionID;
    
    console.log('华为账号登录成功:', { authCode, openID, unionID });
    
    // 同步数据到云端
    this.syncDataToCloud();
    
    // 跳转到主页面
    this.goToMainPage();
  }

  // 华为账号登录错误处理
  handleHuaweiLoginError(error: BusinessError) {
    let errorMessage = '登录失败，请重试';
    
    switch (error.code) {
      case 1001502001:
        errorMessage = '华为账号未登录';
        break;
      case 1001502005:
        errorMessage = '网络异常，请重试';
        break;
      default:
        errorMessage = `服务异常 (${error.code})`;
        break;
    }
    
    promptAction.showToast({ message: errorMessage, duration: 3000 });
  }

  // 发送验证码
  sendVerificationCode() {
    if (!this.phoneNumber || this.phoneNumber.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }

    this.isCounting = true;
    this.countdown = 60;

    // 模拟发送验证码
    console.log(`向 ${this.phoneNumber} 发送验证码`);
    
    const timer = setInterval(() => {
      this.countdown--;
      if (this.countdown <= 0) {
        this.isCounting = false;
        clearInterval(timer);
      }
    }, 1000);
  }

  // 手机号快速登录
  quickLogin() {
    if (!this.phoneNumber || this.phoneNumber.length !== 11) {
      promptAction.showToast({ message: '请输入正确的手机号', duration: 2000 });
      return;
    }

    if (!this.verificationCode) {
      promptAction.showToast({ message: '请输入验证码', duration: 2000 });
      return;
    }

    // 模拟登录验证
    console.log('手机号快速登录:', this.phoneNumber);
    
    // 同步数据到云端
    this.syncDataToCloud();
    
    // 跳转到主页面
    this.goToMainPage();
  }

  // 账号密码注册
  registerWithPassword() {
    if (!this.username || this.username.length < 3) {
      promptAction.showToast({ message: '用户名至少3位', duration: 2000 });
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

    // 模拟注册
    console.log('账号密码注册:', this.username);
    
    // 同步数据到云端
    this.syncDataToCloud();
    
    // 跳转到主页面
    this.goToMainPage();
  }

  // 同步数据到云端
  syncDataToCloud() {
    console.log('同步用户数据到云端:', this.userData);
    // 这里应该调用云端API同步数据
  }

  // 跳过登录
  skipLogin() {
    console.log('用户选择跳过登录');
    
    // 数据保存在本地
    this.saveDataLocally();
    
    // 跳转到主页面
    this.goToMainPage();
  }

  // 保存数据到本地
  saveDataLocally() {
    console.log('保存数据到本地:', this.userData);
    // 这里应该使用Preferences保存数据
  }

  // 跳转到主页面
  goToMainPage() {
    router.replaceUrl({ 
      url: 'pages/MainPage',
      params: { userData: this.userData }
    }).catch((err: BusinessError) => {
      console.error(`跳转失败：${err.code}-${err.message}`);
    });
  }

  build() {
    Column() {
      // 顶部标题
      Text('登录/注册')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.primary_color'))
        .margin({ top: 50, bottom: 40 })

      // 登录方式选择
      Row({ space: 0 }) {
        Button('手机号快速登录')
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontColor(this.loginType === 'quick' ? Color.White : $r('app.color.text_secondary'))
          .backgroundColor(this.loginType === 'quick' ? $r('app.color.accent_color') : Color.Transparent)
          .borderRadius(0)
          .onClick(() => {
            this.loginType = 'quick';
          })

        Button('账号密码注册')
          .layoutWeight(1)
          .height(50)
          .fontSize(16)
          .fontColor(this.loginType === 'password' ? Color.White : $r('app.color.text_secondary'))
          .backgroundColor(this.loginType === 'password' ? $r('app.color.accent_color') : Color.Transparent)
          .borderRadius(0)
          .onClick(() => {
            this.loginType = 'password';
          })
      }
      .width('80%')
      .borderRadius(10)
      .border({
        width: 1,
        color: $r('app.color.neutral_gray'),
        style: BorderStyle.Solid
      })
      .margin({ bottom: 30 })

      // 手机号快速登录表单
      if (this.loginType === 'quick') {
        this.buildQuickLoginForm()
      }

      // 账号密码注册表单
      if (this.loginType === 'password') {
        this.buildPasswordRegisterForm()
      }

      // 华为账号一键登录
      Column({ space: 20 }) {
        Text('或使用以下方式登录')
          .fontSize(14)
          .fontColor($r('app.color.text_tertiary'))
          .margin({ top: 30, bottom: 10 })

        LoginWithHuaweiIDButton({
          params: {
            style: loginComponentManager.Style.BUTTON_RED,
            borderRadius: 24,
            loginType: loginComponentManager.LoginType.ID
          },
          controller: this.controller
        })
        .width('80%')
        .height(50)
      }
      .alignItems(HorizontalAlign.Center)

      // 跳过登录
      Button('跳过登录，仅本地使用')
        .width('80%')
        .height(50)
        .fontSize(16)
        .fontColor($r('app.color.text_secondary'))
        .backgroundColor(Color.Transparent)
        .border({
          width: 1,
          color: $r('app.color.neutral_gray'),
          style: BorderStyle.Solid
        })
        .borderRadius(10)
        .margin({ top: 30 })
        .onClick(() => {
          this.skipLogin();
        })

      Blank()
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.page_background'))
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildQuickLoginForm() {
    Column({ space: 20 }) {
      // 手机号输入
      Column({ space: 8 }) {
        Text('手机号')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '请输入手机号' })
          .width('80%')
          .height(50)
          .type(InputType.Number)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(10)
          .onChange((value: string) => {
            this.phoneNumber = value;
          })
      }

      // 验证码输入
      Row({ space: 10 }) {
        TextInput({ placeholder: '请输入验证码' })
          .layoutWeight(1)
          .height(50)
          .type(InputType.Number)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(10)
          .onChange((value: string) => {
            this.verificationCode = value;
          })

        Button(this.isCounting ? `${this.countdown}秒后重发` : '获取验证码')
          .width(120)
          .height(50)
          .fontSize(14)
          .fontColor(Color.White)
          .backgroundColor(this.isCounting ? $r('app.color.neutral_gray') : $r('app.color.accent_color'))
          .borderRadius(10)
          .enabled(!this.isCounting)
          .onClick(() => {
            this.sendVerificationCode();
          })
      }
      .width('80%')

      // 登录按钮
      Button('快速登录')
        .width('80%')
        .height(50)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.accent_color'))
        .borderRadius(10)
        .onClick(() => {
          this.quickLogin();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  buildPasswordRegisterForm() {
    Column({ space: 20 }) {
      // 用户名输入
      Column({ space: 8 }) {
        Text('用户名')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '请输入用户名（至少3位）' })
          .width('80%')
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(10)
          .onChange((value: string) => {
            this.username = value;
          })
      }

      // 密码输入
      Column({ space: 8 }) {
        Text('密码')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

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
      }

      // 确认密码
      Column({ space: 8 }) {
        Text('确认密码')
          .fontSize(14)
          .fontColor($r('app.color.text_secondary'))
          .width('80%')
          .textAlign(TextAlign.Start)

        TextInput({ placeholder: '请再次输入密码' })
          .width('80%')
          .height(50)
          .type(InputType.Password)
          .backgroundColor(Color.White)
          .borderRadius(10)
          .padding(10)
          .onChange((value: string) => {
            this.confirmPassword = value;
          })
      }

      // 注册按钮
      Button('注册并登录')
        .width('80%')
        .height(50)
        .fontSize(16)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.accent_color'))
        .borderRadius(10)
        .onClick(() => {
          this.registerWithPassword();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
  }
}