package com.dooble.phonertc;

import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.webrtc.PeerConnectionFactory;

public class PhoneRTCPlugin extends CordovaPlugin {
  private PeerConnectionFactory factory;

  @Override
  public void initialize (CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);

    factory = new PeerConnectionFactory();
  }
}
