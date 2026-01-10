import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct SimpleLogin {
  @State private username: string = '';
  @State private password: string = '';
  @State private isLoading: boolean = false;

  async login() {
    if (!this.username || !this.password) {
      promptAction.showToast({ message: '请输入用户名和密码', duration: 2000 });
      return;
    }

    this.isLoading = true;
    
    // 模拟登录过程
    setTimeout(() => {
      this.isLoading = false;
      
      // 简单验证
      if (this.username === 'admin' && this.password === '123456') {
        promptAction.showToast({ message: '登录成功', duration: 2000 });
        
        // 跳转到主页面
        router.replaceUrl({ 
          url: 'pages/Index'
        });
      } else {
        promptAction.showToast({ message: '用户名或密码错误', duration: 2000 });
      }
    }, 1000);
  }

  skipLogin() {
    // 跳过登录，直接进入主页面
    router.replaceUrl({ 
      url: 'pages/Index'
    });
  }

  build() {
    Column() {
      // 顶部图标
      Column({ space: 20 }) {
        Text('☕')
          .fontSize(80)
        
        Text('Coffee Mate')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.primary_color'))
        
        Text('咖啡因追踪助手')
          .fontSize(16)
          .fontColor($r('app.color.text_secondary'))
      }
      .margin({ top: 100, bottom: 50 })

      // 登录表单
      Column({ space: 20 }) {
        TextInput({ placeholder: '用户名' })
          .width('80%')
          .height(50)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(10)
          .onChange((value: string) => {
            this.username = value;
          })

        TextInput({ placeholder: '密码' })
          .width('80%')
          .height(50)
          .type(InputType.Password)
          .backgroundColor(Color.White)
          .borderRadius(8)
          .padding(10)
          .onChange((value: string) => {
            this.password = value;
          })

        Button(this.isLoading ? '登录中...' : '登录')
          .width('80%')
          .height(50)
          .backgroundColor($r('app.color.accent_color'))
          .fontColor(Color.White)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .borderRadius(25)
          .enabled(!this.isLoading)
          .onClick(() => {
            this.login();
          })
      }

      // 跳过登录
      Button('跳过登录')
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
        .backgroundColor(Color.Transparent)
        .margin({ top: 20 })
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
}