{{flutter_js}}
{{flutter_build_config}}

// 使用本地打包的 CanvasKit，避免从 Google CDN（gstatic.com）加载导致国内白屏
_flutter.loader.load({
  config: {
    canvasKitBaseUrl: "canvaskit/"
  }
});
