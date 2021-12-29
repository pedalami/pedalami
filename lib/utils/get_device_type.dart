import 'package:universal_html/html.dart' as html;

const appleType = "apple";
const androidType = "android";
const desktopType = "desktop";

String getSmartPhoneOrTablet() {
  final userAgent = html.window.navigator.userAgent.toString().toLowerCase();
  // smartphone
  if( userAgent.contains("iphone"))  return appleType;
  if( userAgent.contains("android"))  return androidType;

  // tablet
  if( userAgent.contains("ipad")) return appleType;
  if( html.window.navigator.platform!.toLowerCase().contains("macintel") && html.window.navigator.maxTouchPoints! > 0 ) return appleType;

  return desktopType;
}