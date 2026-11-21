// Falling letters: after the reader has been idle for a while, every letter on
// screen falls to the bottom of the viewport and piles up. Any click, mouse
// move, key press, touch or scroll sends the letters back where they belong.
//
// The original text is never moved: visible text nodes are wrapped in hidden
// spans (which does not change layout) and replaced by a fixed overlay of
// per-letter clones that are animated with transforms.
(function () {
  'use strict';

  var script = document.currentScript;
  var params = new URLSearchParams(window.location.search);
  var idleSeconds = parseFloat(params.get('idle') || (script && script.dataset.idleSeconds) || '30');
  var maxLetters = 3000;
  var gravity = 2600; // px/s^2
  var skipTags = { SCRIPT: 1, STYLE: 1, NOSCRIPT: 1, TEXTAREA: 1, INPUT: 1, SELECT: 1, OPTION: 1, SVG: 1, CANVAS: 1, IFRAME: 1 };

  var copiedProperties = ['font-family', 'font-size', 'font-weight', 'font-style', 'font-stretch',
    'font-variant', 'font-feature-settings', 'font-variation-settings', 'font-kerning', 'letter-spacing',
    'color', 'text-shadow', '-webkit-font-smoothing', '-webkit-text-stroke'];

  // Clones are single letters, so apply text-transform to the character itself;
  // the measured position is of the transformed glyph that is actually on screen.
  function transformCase(text, i, transform) {
    var ch = text[i];
    if (transform === 'uppercase') return ch.toUpperCase();
    if (transform === 'lowercase') return ch.toLowerCase();
    if (transform === 'capitalize' && (i === 0 || /[\s\-]/.test(text[i - 1]))) return ch.toUpperCase();
    return ch;
  }

  if (!(idleSeconds > 0)) return;
  if (window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  var state = 'idle'; // idle | falling | returning
  var idleTimer = null;
  var overlay = null;
  var letters = [];
  var hidden = [];
  var frame = null;
  var returnTimer = null;

  function resetIdle() {
    clearTimeout(idleTimer);
    idleTimer = setTimeout(fall, idleSeconds * 1000);
  }

  function inViewport(rect) {
    return rect.width > 0 && rect.height > 0 && rect.bottom > 0 && rect.right > 0 &&
      rect.top < window.innerHeight && rect.left < window.innerWidth;
  }

  function visibleTextNodes() {
    var nodes = [];
    var walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, {
      acceptNode: function (node) {
        if (!node.nodeValue.trim()) return NodeFilter.FILTER_REJECT;
        for (var el = node.parentElement; el && el !== document.body; el = el.parentElement) {
          if (skipTags[el.tagName.toUpperCase()] || el.isContentEditable) return NodeFilter.FILTER_REJECT;
        }
        var range = document.createRange();
        range.selectNodeContents(node);
        return inViewport(range.getBoundingClientRect()) ? NodeFilter.FILTER_ACCEPT : NodeFilter.FILTER_REJECT;
      }
    });
    while (walker.nextNode()) nodes.push(walker.currentNode);
    return nodes;
  }

  function fall() {
    if (state !== 'idle') return;
    var nodes = visibleTextNodes();
    if (!nodes.length) return;

    overlay = document.createElement('div');
    overlay.setAttribute('aria-hidden', 'true');
    overlay.style.cssText = 'position:fixed;inset:0;pointer-events:none;z-index:2147483647;overflow:hidden;';
    letters = [];

    var range = document.createRange();
    nodes.forEach(function (node) {
      if (letters.length >= maxLetters) return;
      var style = window.getComputedStyle(node.parentElement);
      if (style.visibility === 'hidden' || parseFloat(style.opacity) === 0) return;
      var text = node.nodeValue;
      var found = [];
      for (var i = 0; i < text.length && letters.length + found.length < maxLetters; i++) {
        if (/\s/.test(text[i])) continue;
        range.setStart(node, i);
        range.setEnd(node, i + 1);
        var rect = range.getClientRects()[0];
        if (!rect || !inViewport(rect)) continue;
        found.push({ ch: transformCase(text, i, style.textTransform), rect: rect });
      }
      if (!found.length) return;
      // Copy font properties individually: the `font` shorthand can be empty in
      // some browsers and does not include letter-spacing or ligature settings.
      var fontStyle = copiedProperties.map(function (prop) {
        return prop + ':' + style.getPropertyValue(prop) + ';';
      }).join('');

      found.forEach(function (f) {
        var el = document.createElement('span');
        el.textContent = f.ch;
        el.style.cssText = 'position:absolute;white-space:pre;will-change:transform;margin:0;padding:0;' +
          'left:' + f.rect.left + 'px;top:' + f.rect.top + 'px;line-height:' + f.rect.height + 'px;' + fontStyle;
        overlay.appendChild(el);
        letters.push({
          el: el, x: 0, y: 0, r: 0,
          w: f.rect.width, h: f.rect.height, left: f.rect.left, top: f.rect.top,
          vx: (Math.random() - 0.5) * 260, vy: -Math.random() * 150,
          vr: (Math.random() - 0.5) * 720,
          delay: Math.random() * 1.2 + (1 - f.rect.top / window.innerHeight) * 0.4,
          settled: false, bounces: 0, slides: 0
        });
      });

      var wrapper = document.createElement('span');
      wrapper.style.visibility = 'hidden';
      node.parentNode.insertBefore(wrapper, node);
      wrapper.appendChild(node);
      hidden.push(wrapper);
    });

    if (!letters.length) { cleanup(); return; }
    document.body.appendChild(overlay);
    state = 'falling';
    simulate();
  }

  function simulate() {
    var binSize = 6;
    var bins = new Array(Math.ceil(window.innerWidth / binSize) + 1).fill(0);
    var last = performance.now();
    var elapsed = 0;

    function pileAt(a, b) {
      a = Math.max(0, a);
      b = Math.min(bins.length - 1, b);
      if (a > b) return Infinity;
      var max = 0;
      for (var i = a; i <= b; i++) max = Math.max(max, bins[i]);
      return max;
    }

    function binRange(l) {
      var a = Math.max(0, Math.floor((l.left + l.x) / binSize));
      var b = Math.min(bins.length - 1, Math.floor((l.left + l.x + l.w) / binSize));
      return [a, b];
    }

    function step(now) {
      var dt = Math.min(0.05, (now - last) / 1000);
      last = now;
      elapsed += dt;
      var moving = 0;

      letters.forEach(function (l) {
        if (l.settled || elapsed < l.delay) { if (!l.settled) moving++; return; }
        moving++;
        l.vy += gravity * dt;
        l.x += l.vx * dt;
        l.y += l.vy * dt;
        l.r += l.vr * dt;

        // Keep letters inside the screen horizontally.
        var absLeft = l.left + l.x;
        if (absLeft < 0) { l.x = -l.left; l.vx = Math.abs(l.vx) * 0.5; }
        if (absLeft + l.w > window.innerWidth) { l.x = window.innerWidth - l.w - l.left; l.vx = -Math.abs(l.vx) * 0.5; }

        var range = binRange(l);
        var pile = pileAt(range[0], range[1]);
        var floor = window.innerHeight - pile - l.h;
        if (l.top + l.y >= floor) {
          l.y = floor - l.top;
          // Slide off taller piles toward a lower neighbour, like a heap of sand.
          var span = range[1] - range[0] + 1;
          var leftPile = pileAt(range[0] - span, range[0] - 1);
          var rightPile = pileAt(range[1] + 1, range[1] + span);
          var lower = Math.min(leftPile, rightPile);
          if (pile - lower > l.h * 0.4 && l.slides < 40) {
            var dir = leftPile < rightPile || (leftPile === rightPile && Math.random() < 0.5) ? -1 : 1;
            l.vx = dir * (180 + Math.random() * 120);
            l.vy = 0;
            l.slides++;
          } else if (l.vy > 350 && l.bounces < 2) {
            l.vy = -l.vy * 0.35;
            l.vx *= 0.6;
            l.vr *= 0.5;
            l.bounces++;
          } else {
            l.settled = true;
            l.r = l.r % 360;
            var add = l.h * 0.45;
            for (var j = range[0]; j <= range[1]; j++) bins[j] = pile + add;
          }
        }
        l.el.style.transform = 'translate(' + l.x + 'px,' + l.y + 'px) rotate(' + l.r + 'deg)';
      });

      frame = moving ? requestAnimationFrame(step) : null;
    }

    frame = requestAnimationFrame(step);
  }

  function restore(instant) {
    if (state === 'idle') return;
    if (frame) cancelAnimationFrame(frame);
    frame = null;
    if (instant) { cleanup(); return; }
    if (state === 'returning') return;
    state = 'returning';
    var longest = 0;
    letters.forEach(function (l) {
      var delay = Math.random() * 250;
      var duration = 550 + Math.random() * 350;
      longest = Math.max(longest, delay + duration);
      l.el.style.transition = 'transform ' + duration + 'ms cubic-bezier(.2,1.3,.4,1) ' + delay + 'ms';
      l.el.style.transform = 'translate(0,0) rotate(0deg)';
    });
    returnTimer = setTimeout(cleanup, longest + 50);
  }

  function cleanup() {
    clearTimeout(returnTimer);
    hidden.forEach(function (wrapper) {
      var parent = wrapper.parentNode;
      if (!parent) return;
      while (wrapper.firstChild) parent.insertBefore(wrapper.firstChild, wrapper);
      parent.removeChild(wrapper);
    });
    hidden = [];
    if (overlay && overlay.parentNode) overlay.parentNode.removeChild(overlay);
    overlay = null;
    letters = [];
    state = 'idle';
  }

  function onActivity(e) {
    // Scrolling or resizing moves the real text, so letters can't fly back to stale positions.
    var instant = e.type === 'scroll' || e.type === 'resize';
    if (state !== 'idle') restore(instant);
    resetIdle();
  }

  ['mousemove', 'mousedown', 'keydown', 'touchstart', 'wheel', 'scroll', 'resize'].forEach(function (type) {
    window.addEventListener(type, onActivity, { passive: true });
  });
  document.addEventListener('visibilitychange', function () {
    if (document.hidden) clearTimeout(idleTimer); else resetIdle();
  });

  resetIdle();
})();
