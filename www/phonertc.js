var exec = require('cordova/exec');

var nativeService = 'PhoneRTCPlugin';

function MediaHandler (session, options) {
  // TODO get STUN/TURN servers and RTCConstraints from session.ua and options,
  // and pass them to a native method so it can create the PeerConnection
  var
    servers = [],
    config = session.ua.configuration,
    stunServers = options.stunServers || config.stunServers,
    turnServers = options.turnServers || config.turnServers;
  this.RTCConstraints = options.RTCConstraints || {};

  stunServers.forEach(function (stunURI) {
    servers.push({
      'uri': stunURI,
      'username': '',
      'password': ''
    });
  });

  turnServers.forEach(function (turn) {
    turn.urls.forEach(function (uri) {
      servers.push({
        'uri': uri,
        'username': turn.username,
        'password': turn.password
      });
    });
  });

  exec(null, null, nativeService, 'construct', [servers, this.RTCConstraints]);
}

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
