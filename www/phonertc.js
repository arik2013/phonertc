cordova.define("com.dooble.phonertc.PhoneRTC", function(require, exports, module) { var exec = require('cordova/exec');

var videoElements;

exports.updateVideoPosition = function updateVideoPosition () {
  // This function should listen for scrolling and update the position of the elements to cordova exec
  if (videoElements) {
    var video = {
      localVideo: getLayoutParams(videoElements.localVideo),
      remoteVideo: getLayoutParams(videoElements.remoteVideo)
    };
    // Update Video Element positioning
    exec(
      null,
      null,
      'PhoneRTCPlugin',
      'updateVideoPosition',
      [video]);
  }
};

if (cordova.platformId !== 'android') {
  document.addEventListener("touchmove", exports.updateVideoPosition);
}

function getLayoutParams (videoElement) {
  var boundingRect = videoElement.getBoundingClientRect();
  if (cordova.platformId === 'android') {
    return {
      devicePixelRatio: window.devicePixelRatio || 2,
      // get these values by doing a lookup on the dom
      x : boundingRect.left + window.scrollX,
      y : boundingRect.top + window.scrollY,
      width : videoElement.offsetWidth,
      height : videoElement.offsetHeight
    };
  }
  return {
      // get these values by doing a lookup on the dom
      x : boundingRect.left,
      y : boundingRect.top,
      width : videoElement.offsetWidth,
      height : videoElement.offsetHeight
    };
}

exports.call = function (options) {
  // options should contain a video option if video is enabled
  // sets the initial video options a dom listener needs to be added to watch for movements.
  var video;
  if (options.video) {
    videoElements = {
      localVideo: options.video.localVideo,
      remoteVideo: options.video.remoteVideo
    };
    options.video = {
      localVideo: getLayoutParams(videoElements.localVideo),
      remoteVideo: getLayoutParams(videoElements.remoteVideo)
    };
  }

  exec(
    function (data) {
      if (data.type === '__answered' && options.answerCallback) {
        options.answerCallback();
      } else if (data.type === '__disconnected' && options.disconnectCallback) {
        options.disconnectCallback();
      } else {
        options.sendMessageCallback(data);
      }
    },
    null,
    'PhoneRTCPlugin',
    'call',
    [JSON.stringify(options)]);
};

exports.setDescription = function (options) {
  exec(
    options.callBack,
    null,
    'PhoneRTCPlugin',
    'setDescription',
    [JSON.stringify(options)]);
};

exports.getDescription = function (options) {
  var execOptions = options || {};
  if (options.video) {
    videoElements = {
      localVideo: options.video.localVideo,
      remoteVideo: options.video.remoteVideo
    };
    execOptions.video = {
      localVideo: getLayoutParams(videoElements.localVideo),
      remoteVideo: getLayoutParams(videoElements.remoteVideo)
    };
  }

  exec(
    function (data) {
      if (data.type === '__answered' && options.answerCallback) {
        options.answerCallback();
      } else if (data.type === '__disconnected' && options.disconnectCallback) {
        options.disconnectCallback();
      } else {
        options.sendMessageCallback(data);
      }
    },
    null,
    'PhoneRTCPlugin',
    'getDescription',
    [JSON.stringify(execOptions)]);
};

exports.setEnabledMedium = function (mediumType, enabled) {
  exec(
    function () {},
    null,
    'PhoneRTCPlugin',
    'setEnabledMedium',
    [mediumType, enabled]);
}

exports.receiveMessage = function (data) {
  exec(
    null,
    null,
    'PhoneRTCPlugin',
    'receiveMessage',
    [JSON.stringify(data)]);
};

exports.disconnect = function () {
  exec(
    null,
    null,
    'PhoneRTCPlugin',
    'disconnect',
    []);
};

});
