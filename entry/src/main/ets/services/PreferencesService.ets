// 用户偏好数据存储服务
import preferences from '@ohos.data.preferences';
import { UserProfile } from '../model/UserProfile';
import common from '@ohos.app.ability.common';

export class PreferencesService {
  private static instance: PreferencesService;
  private preferences: preferences.Preferences | null = null;
  private readonly PREFERENCES_NAME = 'coffee_mate_profile';
  
  static getInstance(): PreferencesService {
    if (!PreferencesService.instance) {
      PreferencesService.instance = new PreferencesService();
    }
    return PreferencesService.instance;
  }
  async initialize(context: common.UIAbilityContext): Promise<void> {
    try {
      const prefs = await preferences.getPreferences(context, { name: this.PREFERENCES_NAME });
      this.preferences = prefs;
      console.info('PreferencesService initialized successfully');
    } catch (error) {
      console.error('Failed to initialize PreferencesService:', error);
      throw new Error('PreferencesService initialization failed');
    }
  }
  
  // 保存用户配置
  async saveUserProfile(profile: UserProfile): Promise<void> {
    if (!this.preferences) {
      throw new Error('PreferencesService not initialized');
    }
    
    try {
      await this.preferences.put('weight', profile.weight);
      await this.preferences.put('age', profile.age);
      await this.preferences.put('gender', profile.gender);
      await this.preferences.put('wakeUpTime', profile.wakeUpTime);
      await this.preferences.put('bedTime', profile.bedTime);
      await this.preferences.put('caffeineSensitivity', profile.caffeineSensitivity);
      await this.preferences.put('dailyLimit', profile.dailyLimit);
      await this.preferences.put('isOnboardingCompleted', profile.isOnboardingComplete);
      await this.preferences.put('lastUpdateTime', profile.lastUpdateTime);
      
      await this.preferences.flush();
      console.info('User profile saved successfully');
    } catch (error) {
      console.error('Failed to save user profile:', error);
      throw new Error('Failed to save user profile');
    }
  }
  
  // 加载用户配置
  async loadUserProfile(): Promise<UserProfile> {
    if (!this.preferences) {
      throw new Error('PreferencesService not initialized');
    }
    
    try {
      const profileData: UserProfile = new UserProfile();
      profileData.weight = await this.preferences.get('weight', 65) as number;
      profileData.age = await this.preferences.get('age', 25) as number;
      profileData.gender = await this.preferences.get('gender', 'male') as 'male' | 'female';
      profileData.wakeUpTime = await this.preferences.get('wakeUpTime', '08:00') as string;
      profileData.bedTime = await this.preferences.get('bedTime', '23:00') as string;
      profileData.caffeineSensitivity = await this.preferences.get('caffeineSensitivity', 'medium') as 'low' | 'medium' | 'high';
      profileData.dailyLimit = await this.preferences.get('dailyLimit', 400) as number;
      profileData.isOnboardingComplete = await this.preferences.get('isOnboardingCompleted', false) as boolean;
      profileData.lastUpdateTime = await this.preferences.get('lastUpdateTime', Date.now()) as number;
      
      return new UserProfile(profileData);
    } catch (error) {
      console.error('Failed to load user profile:', error);
      // 返回默认配置
      return new UserProfile();
    }
  }
  
  // 检查是否完成引导
  async isOnboardingCompleted(): Promise<boolean> {
    if (!this.preferences) {
      return false;
    }
    
    try {
      return await this.preferences.get('isOnboardingCompleted', false) as boolean;
    } catch (error) {
      console.error('Failed to check onboarding status:', error);
      return false;
    }
  }
  
  // 标记引导完成
  async markOnboardingCompleted(): Promise<void> {
    if (!this.preferences) {
      throw new Error('PreferencesService not initialized');
    }
    
    try {
      await this.preferences.put('isOnboardingCompleted', true);
      await this.preferences.put('lastUpdateTime', Date.now());
      await this.preferences.flush();
      console.info('Onboarding marked as completed');
    } catch (error) {
      console.error('Failed to mark onboarding as completed:', error);
      throw new Error('Failed to mark onboarding as completed');
    }
  }
}