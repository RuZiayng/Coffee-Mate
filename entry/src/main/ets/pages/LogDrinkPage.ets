// 智能饮品记录页面
import { router } from '@kit.ArkUI';
import { BeverageItem, BeverageDatabaseService } from '../model/BeverageItem';
import { CaffeineRecord } from '../model/CaffeineRecord';
import { PreferencesService } from '../services/PreferencesService';
import { addIntakeRecord } from '../utils/DataManager';
import { IntakeRecord } from '../utils/CaffeineCalculator';

@Component
struct LogDrinkPage {
  // 饮品数据
  @State beverages: BeverageItem[] = [];
  @State filteredBeverages: BeverageItem[] = [];
  
  // 搜索和筛选状态
  @State searchText: string = '';
  @State selectedBrand: string = '全部';
  @State selectedCategory: string = '全部';
  
  // 加载状态
  @State isLoading: boolean = true;
  
  aboutToAppear() {
    this.loadBeverages();
  }
  
  // 加载饮品数据
  loadBeverages() {
    this.beverages = BeverageDatabaseService.getAllBeverages();
    this.filteredBeverages = this.beverages;
    this.isLoading = false;
  }
  
  // 搜索饮品
  onSearchChange(value: string) {
    this.searchText = value;
    this.applyFilters();
  }
  
  // 品牌筛选
  onBrandSelect(brand: string) {
    this.selectedBrand = brand;
    this.applyFilters();
  }
  
  // 类别筛选
  onCategorySelect(category: string) {
    this.selectedCategory = category;
    this.applyFilters();
  }
  
  // 应用所有筛选条件
  applyFilters() {
    let filtered = this.beverages;
    
    // 品牌筛选
    if (this.selectedBrand !== '全部') {
      filtered = filtered.filter(item => item.brand === this.selectedBrand);
    }
    
    // 类别筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(item => item.category === this.selectedCategory);
    }
    
    // 搜索筛选
    if (this.searchText.trim() !== '') {
      filtered = BeverageDatabaseService.searchBeverages(this.searchText);
    }
    
    this.filteredBeverages = filtered;
  }
  
  // 记录饮品摄入
  async onBeverageSelect(beverage: BeverageItem) {
    try {
      // 创建咖啡因记录
      const record = new CaffeineRecord({
        timestamp: Date.now(),
        sourceName: `${beverage.brand} ${beverage.name}`,
        caffeineAmount: beverage.caffeineContentMg
      });
      
      // 保存记录 - 将CaffeineRecord转换为IntakeRecord
      const intakeRecord = new IntakeRecord(
        record.caffeineAmount,
        new Date(record.timestamp),
        record.sourceName
      );
      await addIntakeRecord(intakeRecord);
      
      // 显示成功提示
      this.showSuccessToast(`已记录：${beverage.name}`);
      
      // 延迟后返回主页
      setTimeout(() => {
        router.back();
      }, 800);
      
    } catch (error) {
      console.error('记录饮品失败:', error);
      this.showErrorToast('记录失败，请重试');
    }
  }
  
  // 显示成功提示
  @Builder
  showSuccessToast(message: string) {
    // 这里可以添加更精美的Toast组件
    Text(message)
      .fontSize(14)
      .fontColor(Color.White)
      .backgroundColor('#4CAF50')
      .padding(12)
      .borderRadius(8)
      .position({ x: '50%', y: '80%' })
      .translate({ x: -50, y: -50 })
  }
  
  // 显示错误提示
  @Builder
  showErrorToast(message: string) {
    Text(message)
      .fontSize(14)
      .fontColor(Color.White)
      .backgroundColor('#F44336')
      .padding(12)
      .borderRadius(8)
      .position({ x: '50%', y: '80%' })
      .translate({ x: -50, y: -50 })
  }
  
  // 自定义输入
  onCustomInput() {
    // 跳转到自定义输入页面
    router.pushUrl({
      url: 'pages/CustomInputPage'
    });
  }
  
  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Button('取消', { type: ButtonType.Normal })
          .fontColor('#B0B0B0')
          .backgroundColor('transparent')
          .onClick(() => router.back())
        
        Text('记录饮品')
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.White)
          .flexGrow(1)
          .textAlign(TextAlign.Center)
          
        // 占位元素，保持对称
        Text('')
          .width(60)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 12 })
      // 搜索栏
      Search({
        value: this.searchText,
        placeholder: '搜索饮品或品牌...'
      })
      .onChange((value: string) => this.onSearchChange(value))
      .width('92%')
      .margin({ top: 8, bottom: 16 })
      
      // 品牌筛选标签
      Scroll() {
        Row({ space: 8 }) {
          // "全部"标签
          Text('全部')
            .fontSize(14)
            .fontColor(this.selectedBrand === '全部' ? '#FFB74D' : '#B0B0B0')
            .backgroundColor(this.selectedBrand === '全部' ? '#2A3A4A' : '#1A1A1A')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(20)
            .onClick(() => this.onBrandSelect('全部'))
          
          // 品牌标签
          ForEach(BeverageDatabaseService.getAllBrands(), (brand: string) => {
            Text(brand)
              .fontSize(14)
              .fontColor(this.selectedBrand === brand ? '#FFB74D' : '#B0B0B0')
              .backgroundColor(this.selectedBrand === brand ? '#2A3A4A' : '#1A1A1A')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(20)
              .onClick(() => this.onBrandSelect(brand))
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollBar(BarState.Off)
      .height(44)
      .margin({ bottom: 16 })
      
      // 饮品网格
      if (this.isLoading) {
        // 加载状态
        Column() {
          LoadingProgress()
            .width(40)
            .height(40)
            .color('#FFB74D')
          
          Text('加载中...')
            .fontSize(14)
            .fontColor('#B0B0B0')
            .margin({ top: 8 })
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.filteredBeverages.length === 0) {
        // 无结果状态
        Column() {
          Image($r('app.media.coffee_cup_icon'))
            .width(80)
            .height(80)
            .margin({ bottom: 16 })
          
          Text('未找到相关饮品')
            .fontSize(16)
            .fontColor('#B0B0B0')
            .margin({ bottom: 8 })
          
          Text('请尝试其他搜索词或筛选条件')
            .fontSize(12)
            .fontColor('#666666')
        }
        .width('100%')
        .height(200)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else {
        // 饮品网格
        Grid() {
          ForEach(this.filteredBeverages, (beverage: BeverageItem) => {
            GridItem() {
              this.buildBeverageCard(beverage)
            }
          })
        }
        .columnsTemplate('1fr 1fr')
        .columnsGap(12)
        .rowsGap(12)
        .padding({ left: 16, right: 16, bottom: 80 })
      }
      
      // 底部自定义输入按钮
      Button('自定义输入咖啡因含量', { type: ButtonType.Normal })
        .width('92%')
        .height(48)
        .fontColor('#FFB74D')
        .backgroundColor('#2A3A4A')
        .border({
          width: 1,
          color: '#FFB74D'
        })
        .borderRadius(8)
        .onClick(() => this.onCustomInput())
        .margin({ bottom: 24 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#0F1A2F')
  }
  
  @Builder
  buildBeverageCard(beverage: BeverageItem) {
    Column() {
      // 饮品图标
      Image($r(`app.media.${beverage.icon}`))
        .width(60)
        .height(60)
        .objectFit(ImageFit.Contain)
        .margin({ bottom: 8 })
      
      // 品牌名称
      Text(beverage.brand)
        .fontSize(10)
        .fontColor('#B0B0B0')
        .margin({ bottom: 4 })
      
      // 饮品名称
      Text(beverage.name)
        .fontSize(12)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Medium)
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .margin({ bottom: 8 })
      
      // 咖啡因含量
      Text(`≈${beverage.caffeineContentMg}mg`)
        .fontSize(11)
        .fontColor('#4DB6AC')
        .backgroundColor('#1E2A3A')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderRadius(4)
    }
    .width('100%')
    .padding(12)
    .backgroundColor('#1A2A3A')
    .borderRadius(12)
    .onClick(() => this.onBeverageSelect(beverage))
  }
}