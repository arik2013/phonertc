package com.dooble.phonertc;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.webrtc.PeerConnectionFactory;

public class PhoneRTCPlugin extends CordovaPlugin {
  private PeerConnectionFactory factory;

  @Override
  public void initialize (CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);

    factory = new PeerConnectionFactory();
  }

  @Override
  public boolean execute (String action, JSONArray args,
      CallbackContext callbacks) throws JSONException {
    Actions.valueOf(action.toUpperCase()).execute(args, callbacks);
    return true;
  }

  // see http://stackoverflow.com/a/2667671
  private enum Actions {
    CONSTRUCT {
      @Override
      public void execute (JSONArray args, CallbackContext callbacks) {
        // TODO
      }
    },

    ISREADY {
      @Override
      public void execute (JSONArray args, CallbackContext callbacks) {
        // TODO
      }
    },

    GETDESCRIPTION {
      @Override
      public void execute (JSONArray args, CallbackContext callbacks) {
        // TODO
      }
    },

    SETDESCRIPTION {
      @Override
      public void execute (JSONArray args, CallbackContext callbacks) {
        // TODO
      }
    },

    RENDER {
      @Override
      public void execute (JSONArray args, CallbackContext callbacks) {
        // TODO
      }
    },

    CLOSE {
      @Override
      public void execute (JSONArray args, CallbackContext callbacks) {
        // TODO
      }
    };

    public abstract void execute (JSONArray args, CallbackContext callbacks);
  }
}
