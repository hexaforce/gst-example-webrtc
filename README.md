# gst-example-webrtc

## 公式のGStreamer WebRTC demosを動かすサンプル

Gstreamerは最新のものを試したいため、
パッケージマネージャを使わず現時点で最新の ver 1.24.10 をビルドして使います

Gstreamerの公式にあるWebRTCサンプルコードは2種類あるようです

* 1つはgst-examplesにあるサンプルコードで、pythonで書かれたシグナリングサーバを使う方法です
こちらにあります
https://gitlab.freedesktop.org/gstreamer/gstreamer/-/tree/1.24/subprojects/gst-examples/webrtc/


* もう一つのサンプルコードは、jsのクライアントライブラリであるgstwebrtc-apiを使った例です
これは、上記とは別のrustで書かれたシグナリングサーバを使います
こちらにあります
https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs/-/tree/gstreamer-1.24.10/net/webrtc/


実行は独自ドメインを用いてAWS上で構築することを想定しています
ローカル環境で動作させるには独自にコードを調整してください

コードは読みやすいようにフォーマットをしています。
公式から取得してフォーマットしただけのピュアコードはFormattedPlainCodeにあります。
差分はそれと比べて確認してください。

1.初めにGstreamerをビルドします、依存も含めた問題を回避するために debian12(bookworm)のコンテナイメージを使用して統一しています
コンテナ名は自由に変えてください

```bash
cd Docker/1.builder
docker build . -t hexaforce/gstreamer-builder:1.24.10

cd Docker/2.base
docker build . -t hexaforce/gstreamer-base:1.24.10

cd Docker/3.main
docker build . -t hexaforce/gstreamer:1.24.10
# ※このビルドは時間を要します

cd Docker/4.gst-webrtc-signalling-server
docker build . -t hexaforce/gst-webrtc-signalling-server:1.24.10
```

