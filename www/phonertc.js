var exec = require('cordova/exec');

function MediaHandler (session, options) {
  // TODO get STUN/TURN servers and RTCConstraints from session.ua and options,
  // and pass them to a native method so it can create the PeerConnection
}

var nativeService = 'PhoneRTCPlugin';

MediaHandler.prototype = {
  'isReady': function isReady () {
    // TODO implement like SIP.WebRTC.MediaHandler
    return true;
  },

  'getDescription': function getDescription (onSuccess, onFailure, mediaHint) {
    exec(onSuccess, onFailure, nativeService, 'getDescription', [mediaHint]);
  },

  'setDescription': function setDescription (sdp, onSuccess, onFailure) {
    exec(onSuccess, onFailure, nativeService, 'setDescription', [sdp]);
  },

  'render': function render (renderHint) {
    // TODO This will need to pass coordinates from the DOM to the native method.
    // Updating on scroll/orientationchange/zoom also needs to be accounted
    // for, and will be faster if done natively when possible.
    throw 'not implemented';
  },

  'close': function close () {
    // TODO This may need to be async to support being referred, unless we
    // first support multiple calls
    exec(null, null, nativeService, 'close');
  }
};

// adapted from http://git.io/v1mMfg
function newer (constructor) {
  return function() {
    var instance = Object.create(constructor.prototype);
    var result = constructor.apply(instance, arguments);
    return typeof result === 'object' ? result : instance;
  };
}

module.exports = newer(MediaHandler);
