// Generated by CoffeeScript 1.6.1

/*
  FPS AND MS COUNTER (STATS)
*/


(function() {
  var MAX_RENDER_DT, PHYSICS_DT, accumulator, currentTime, fpsStats, gameLoop, msStats, niceColor, player, render, resizeWindow, update;

  fpsStats = new Stats();

  fpsStats.setMode(0);

  fpsStats.domElement.style.position = "absolute";

  fpsStats.domElement.style.left = "0px";

  fpsStats.domElement.style.top = "0px";

  document.body.appendChild(fpsStats.domElement);

  msStats = new Stats();

  msStats.setMode(1);

  msStats.domElement.style.position = "absolute";

  msStats.domElement.style.left = "80px";

  msStats.domElement.style.top = "0px";

  document.body.appendChild(msStats.domElement);

  /*
    THE GAME
  */


  resizeWindow = function() {
    canvas.width = $(window).width();
    return canvas.height = $(window).height();
  };

  $(window).bind("resize", resizeWindow);

  window.canvas = $("canvas").get(0);

  resizeWindow();

  window.ctx = canvas.getContext("2d");

  niceColor = function() {
    var color, i, letters, _i;
    letters = "56789abcdef".split("");
    color = "#";
    for (i = _i = 0; _i <= 5; i = ++_i) {
      color += letters[Math.floor(Math.random() * (letters.length - 1))];
    }
    return color;
  };

  player = new MC.Snake(new MC.Vec2(canvas.width / 2, canvas.height / 2), niceColor(), "Mike");

  update = function(dt) {
    return player.update(dt);
  };

  render = function(blending) {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    return player.render(blending);
  };

  PHYSICS_DT = 2;

  MAX_RENDER_DT = 1000 / 30;

  window.t = 0;

  currentTime = performance.now();

  accumulator = 0;

  gameLoop = function() {
    var blending, frameTime, newTime;
    fpsStats.begin();
    msStats.begin();
    newTime = performance.now();
    frameTime = Math.min(newTime - currentTime, MAX_RENDER_DT);
    currentTime = newTime;
    accumulator += frameTime;
    while (accumulator >= PHYSICS_DT) {
      update(PHYSICS_DT);
      t += PHYSICS_DT;
      accumulator -= PHYSICS_DT;
    }
    blending = accumulator / PHYSICS_DT;
    render(blending);
    fpsStats.end();
    msStats.end();
    return requestAnimationFrame(gameLoop);
  };

  requestAnimationFrame(gameLoop);

  /*
    KEYBOARD
  */


  MC.Keyboard.bind("press", {
    key: 38,
    callback: (function() {
      return player.move = true;
    })
  });

  MC.Keyboard.bind("release", {
    key: 38,
    callback: (function() {
      return player.move = false;
    })
  });

  MC.Keyboard.bind("press", {
    key: 39,
    callback: (function() {
      return player.right = true;
    })
  });

  MC.Keyboard.bind("release", {
    key: 39,
    callback: (function() {
      return player.right = false;
    })
  });

  MC.Keyboard.bind("press", {
    key: 37,
    callback: (function() {
      return player.left = true;
    })
  });

  MC.Keyboard.bind("release", {
    key: 37,
    callback: (function() {
      return player.left = false;
    })
  });

}).call(this);
