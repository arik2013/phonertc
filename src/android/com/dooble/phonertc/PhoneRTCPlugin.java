package com.dooble.phonertc;

import java.util.LinkedList;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.webrtc.MediaConstraints;
import org.webrtc.PeerConnection;
import org.webrtc.PeerConnectionFactory;

public class PhoneRTCPlugin extends CordovaPlugin {
  private PeerConnectionFactory factory;
  private PeerConnection pc;

  @Override
  public void initialize (CordovaInterface cordova, CordovaWebView webView) {
    super.initialize(cordova, webView);

    factory = new PeerConnectionFactory();
  }

  @Override
  public boolean execute (String action, JSONArray args,
      CallbackContext callbacks) throws JSONException {
    Actions.valueOf(action.toUpperCase()).execute(this, args, callbacks);
    return true;
  }

  // see http://stackoverflow.com/a/2667671
  private enum Actions {
    CONSTRUCT {
      @Override
      public void execute (PhoneRTCPlugin self, JSONArray args,
          CallbackContext callbacks) throws JSONException {
        JSONArray servers = args.getJSONArray(0);

        // build server list
        LinkedList<PeerConnection.IceServer> iceServers =
          new LinkedList<PeerConnection.IceServer>();

        int numServers = servers.length();
        for (int i = 0; i < numServers; i++) {
          JSONObject server = servers.getJSONObject(i);
          iceServers.add(new PeerConnection.IceServer(
            server.getString("uri"),
            server.getString("username"),
            server.getString("password")
          ));
        }

        // TODO use provided constraints
        // JSONObject RTCConstraints = args.getJSONObject(1);
        MediaConstraints pcMediaConstraints = new MediaConstraints();
        pcMediaConstraints.optional.add(new MediaConstraints.KeyValuePair(
          "DtlsSrtpKeyAgreement", "true"));

        self.pc = self.factory.createPeerConnection(iceServers, pcMediaConstraints,
            // TODO pcObserver
            null);
      }
    },

    ISREADY {
      @Override
      public void execute (PhoneRTCPlugin self, JSONArray args,
          CallbackContext callbacks) throws JSONException {
        // TODO
      }
    },

    GETDESCRIPTION {
      @Override
      public void execute (PhoneRTCPlugin self, JSONArray args,
          CallbackContext callbacks) throws JSONException {
        // TODO
      }
    },

    SETDESCRIPTION {
      @Override
      public void execute (PhoneRTCPlugin self, JSONArray args,
          CallbackContext callbacks) throws JSONException {
        // TODO
      }
    },

    RENDER {
      @Override
      public void execute (PhoneRTCPlugin self, JSONArray args,
          CallbackContext callbacks) throws JSONException {
        // TODO
      }
    },

    CLOSE {
      @Override
      public void execute (PhoneRTCPlugin self, JSONArray args,
          CallbackContext callbacks) throws JSONException {
        // TODO
      }
    };

    public abstract void execute (PhoneRTCPlugin self, JSONArray args,
        CallbackContext callbacks) throws JSONException;
  }
}
