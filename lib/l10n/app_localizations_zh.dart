// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'AutoMate Pro';

  @override
  String get home => '首页';

  @override
  String get presets => '预设';

  @override
  String get settings => '设置';

  @override
  String get clickControl => '点击控制';

  @override
  String get start => '开始';

  @override
  String get stop => '停止';

  @override
  String get clickPosition => '点击位置';

  @override
  String get xCoordinate => 'X坐标';

  @override
  String get yCoordinate => 'Y坐标';

  @override
  String get pickPosition => '拾取位置';

  @override
  String get currentMouse => '当前鼠标';

  @override
  String get currentMousePos => '当前鼠标位置';

  @override
  String get randomPosition => '随机位置';

  @override
  String get randomPositionDesc => '为点击位置添加轻微随机偏移';

  @override
  String get randomness => '随机范围';

  @override
  String get randomnessValue => '随机范围: ';

  @override
  String get px => '像素';

  @override
  String get clickSettings => '点击设置';

  @override
  String get clickMode => '点击模式';

  @override
  String get singleClick => '单次点击';

  @override
  String get continuous => '连续点击';

  @override
  String get hold => '长按';

  @override
  String get doubleClick => '双击';

  @override
  String get mouseButton => '鼠标按钮';

  @override
  String get left => '左键';

  @override
  String get middle => '中键';

  @override
  String get right => '右键';

  @override
  String get clickSpeed => '点击速度';

  @override
  String get cps => 'CPS';

  @override
  String cpsValue(String cps) {
    return '$cps CPS';
  }

  @override
  String get intervalType => '间隔类型';

  @override
  String get fixed => '固定';

  @override
  String get random => '随机';

  @override
  String get fixedIntervalMs => '固定间隔 (毫秒)';

  @override
  String get minMs => '最小 (毫秒)';

  @override
  String get maxMs => '最大 (毫秒)';

  @override
  String get repeat => '重复';

  @override
  String get infiniteRepeat => '无限重复';

  @override
  String get repeatCount => '重复次数';

  @override
  String get general => '通用';

  @override
  String get theme => '主题';

  @override
  String get language => '语言';

  @override
  String get hotkeys => '快捷键';

  @override
  String get startClicking => '开始点击';

  @override
  String get stopClicking => '停止点击';

  @override
  String get about => '关于';

  @override
  String get version => '版本';

  @override
  String get systemDefault => '跟随系统';

  @override
  String get noPresets => '暂无预设';

  @override
  String get createPresetTip => '创建预设以保存您的点击配置';

  @override
  String get load => '加载';

  @override
  String get edit => '编辑';

  @override
  String get delete => '删除';

  @override
  String get newPreset => '新建预设';

  @override
  String get clickAnywhere => '点击屏幕任意位置以拾取坐标';

  @override
  String get clickStartToBegin => '点击开始按钮开始';

  @override
  String get clicks => '次点击';

  @override
  String clicksValue(int count) {
    return '$count 次点击';
  }

  @override
  String get running => '运行中';

  @override
  String runningCps(String cps) {
    return '运行中 - $cps CPS';
  }

  @override
  String get error => '错误';

  @override
  String get logs => '日志';

  @override
  String get copy => '复制';

  @override
  String get save => '保存';

  @override
  String get clear => '清除';

  @override
  String get close => '关闭';

  @override
  String get logsCopied => '日志已复制到剪贴板';

  @override
  String logsSaved(String path) {
    return '日志已保存到: $path';
  }

  @override
  String get noLogsYet => '暂无日志';

  @override
  String get autoScroll => '自动滚动';

  @override
  String get logWindow => '日志窗口';

  @override
  String get windowOpacity => '窗口透明度';

  @override
  String get mainWindowOpacity => '主窗口透明度';

  @override
  String get logWindowOpacity => '日志窗口透明度';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'AutoMate Pro';

  @override
  String get home => '首頁';

  @override
  String get presets => '預設';

  @override
  String get settings => '設定';

  @override
  String get clickControl => '點擊控制';

  @override
  String get start => '開始';

  @override
  String get stop => '停止';

  @override
  String get clickPosition => '點擊位置';

  @override
  String get xCoordinate => 'X座標';

  @override
  String get yCoordinate => 'Y座標';

  @override
  String get pickPosition => '拾取位置';

  @override
  String get currentMouse => '目前滑鼠';

  @override
  String get currentMousePos => '目前滑鼠位置';

  @override
  String get randomPosition => '隨機位置';

  @override
  String get randomPositionDesc => '為點擊位置添加輕微隨機偏移';

  @override
  String get randomness => '隨機範圍';

  @override
  String get randomnessValue => '隨機範圍: ';

  @override
  String get px => '像素';

  @override
  String get clickSettings => '點擊設定';

  @override
  String get clickMode => '點擊模式';

  @override
  String get singleClick => '單次點擊';

  @override
  String get continuous => '連續點擊';

  @override
  String get hold => '長按';

  @override
  String get doubleClick => '雙擊';

  @override
  String get mouseButton => '滑鼠按鈕';

  @override
  String get left => '左鍵';

  @override
  String get middle => '中鍵';

  @override
  String get right => '右鍵';

  @override
  String get clickSpeed => '點擊速度';

  @override
  String get cps => 'CPS';

  @override
  String cpsValue(String cps) {
    return '$cps CPS';
  }

  @override
  String get intervalType => '間隔類型';

  @override
  String get fixed => '固定';

  @override
  String get random => '隨機';

  @override
  String get fixedIntervalMs => '固定間隔 (毫秒)';

  @override
  String get minMs => '最小 (毫秒)';

  @override
  String get maxMs => '最大 (毫秒)';

  @override
  String get repeat => '重複';

  @override
  String get infiniteRepeat => '無限重複';

  @override
  String get repeatCount => '重複次數';

  @override
  String get general => '通用';

  @override
  String get theme => '主題';

  @override
  String get language => '語言';

  @override
  String get hotkeys => '快捷鍵';

  @override
  String get startClicking => '開始點擊';

  @override
  String get stopClicking => '停止點擊';

  @override
  String get about => '關於';

  @override
  String get version => '版本';

  @override
  String get systemDefault => '跟隨系統';

  @override
  String get noPresets => '暫無預設';

  @override
  String get createPresetTip => '建立預設以儲存您的點擊設定';

  @override
  String get load => '載入';

  @override
  String get edit => '編輯';

  @override
  String get delete => '刪除';

  @override
  String get newPreset => '新增預設';

  @override
  String get clickAnywhere => '點擊螢幕任意位置以拾取座標';

  @override
  String get clickStartToBegin => '點擊開始按鈕開始';

  @override
  String get clicks => '次點擊';

  @override
  String clicksValue(int count) {
    return '$count 次點擊';
  }

  @override
  String get running => '執行中';

  @override
  String runningCps(String cps) {
    return '執行中 - $cps CPS';
  }

  @override
  String get error => '錯誤';

  @override
  String get logs => '日誌';

  @override
  String get copy => '複製';

  @override
  String get save => '儲存';

  @override
  String get clear => '清除';

  @override
  String get close => '關閉';

  @override
  String get logsCopied => '日誌已複製到剪貼簿';

  @override
  String logsSaved(String path) {
    return '日誌已儲存到: $path';
  }

  @override
  String get noLogsYet => '暫無日誌';

  @override
  String get autoScroll => '自動滾動';

  @override
  String get logWindow => '日誌視窗';

  @override
  String get windowOpacity => '視窗透明度';

  @override
  String get mainWindowOpacity => '主視窗透明度';

  @override
  String get logWindowOpacity => '日誌視窗透明度';
}
