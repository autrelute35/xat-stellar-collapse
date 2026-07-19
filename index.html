<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <meta name="theme-color" content="#010102">
    <meta name="robots" content="noindex, nofollow">
    <meta name="description" content="A dense monochrome starfield consumed by an interactive black hole.">
    <title>Stellar Collapse</title>
    <style>
      :root {
        color-scheme: dark;
        background: #010102;
      }

      * {
        box-sizing: border-box;
      }

      html,
      body {
        width: 100%;
        min-width: 320px;
        height: 100%;
        min-height: 100%;
        margin: 0;
        overflow: hidden;
        background: #010102;
      }

      .star-shell {
        position: relative;
        width: 100%;
        height: 100vh;
        min-height: 320px;
        overflow: hidden;
        background: #010102;
        cursor: crosshair;
        isolation: isolate;
        touch-action: none;
      }

      canvas {
        position: absolute;
        inset: 0;
        z-index: 1;
        display: block;
        width: 100%;
        height: 100%;
      }

      .vignette {
        position: absolute;
        inset: 0;
        z-index: 2;
        pointer-events: none;
        background: radial-gradient(ellipse at center, transparent 48%, rgba(0, 0, 0, 0.56) 100%);
      }
    </style>
  </head>
  <body>
    <main class="star-shell" aria-label="Interactive monochrome starfield with a page-swallowing black hole">
      <canvas aria-hidden="true"></canvas>
      <div class="vignette" aria-hidden="true"></div>
    </main>

    <script>
      (() => {
        const canvas = document.querySelector("canvas");
        const ctx = canvas.getContext("2d");
        const palette = { white: "#f7f9fb", silver: "#aeb4ba" };
        const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)");

        let width = 0;
        let height = 0;
        let dpr = 1;
        let stars = [];
        let meteors = [];
        let blackHole = null;
        let fieldOpacity = 1;
        let last = performance.now();
        let spawn = 0;
        let nextSpawn = random(1.4, 2.8);
        let pointer = { x: 0.5, y: 0.5 };
        let frame = 0;

        function rgb(hex) {
          const value = hex.replace("#", "");
          return [
            Number.parseInt(value.slice(0, 2), 16),
            Number.parseInt(value.slice(2, 4), 16),
            Number.parseInt(value.slice(4, 6), 16),
          ];
        }

        function rgba(hex, alpha) {
          const [red, green, blue] = rgb(hex);
          return `rgba(${red}, ${green}, ${blue}, ${alpha})`;
        }

        function random(min, max) {
          return min + Math.random() * (max - min);
        }

        function clamp(value, min = 0, max = 1) {
          return Math.min(max, Math.max(min, value));
        }

        function easeInCubic(value) {
          return value ** 3;
        }

        function easeOutCubic(value) {
          return 1 - (1 - value) ** 3;
        }

        function makeField() {
          const starCount = Math.round((width * height) / 880);
          stars = Array.from({ length: starCount }, () => {
            const depth = Math.random();
            return {
              x: Math.random() * width,
              y: Math.random() * height,
              r: 0.32 + depth * depth * 1.55,
              a: random(0.18, 0.92),
              tw: random(0.0007, 0.0032),
              phase: random(0, Math.PI * 2),
              depth,
            };
          });
        }

        function resize() {
          const rect = canvas.getBoundingClientRect();
          width = Math.max(320, rect.width);
          height = Math.max(320, rect.height);
          dpr = Math.min(2, window.devicePixelRatio || 1);
          canvas.width = Math.round(width * dpr);
          canvas.height = Math.round(height * dpr);
          ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
          blackHole = null;
          fieldOpacity = 1;
          canvas.style.cursor = "crosshair";
          makeField();
        }

        function makeMeteor(instant = false) {
          const max = random(0.8, 1.12);
          meteors.push({
            x: random(width * 0.22, width * 1.16),
            y: random(-height * 0.2, height * 0.38),
            vx: random(-470, -720),
            vy: random(220, 345),
            len: random(125, 245),
            life: instant ? random(0.22, max) : max,
            max,
            color: Math.random() > 0.25 ? palette.white : palette.silver,
          });
        }

        function openBlackHole(x, y) {
          if (blackHole) return;
          blackHole = {
            x,
            y,
            age: 0,
            max: 4.6,
            spin: Math.random() > 0.5 ? 1 : -1,
          };
          meteors = [];
          spawn = 0;
          canvas.style.cursor = "none";
        }

        function drawStars(now, activeHole) {
          const farthestCorner = activeHole
            ? Math.hypot(
                Math.max(activeHole.x, width - activeHole.x),
                Math.max(activeHole.y, height - activeHole.y),
              )
            : 1;

          for (const star of stars) {
            const pulse = 0.72 + Math.sin(now * star.tw + star.phase) * 0.28;
            const pointerDx = star.x / width - pointer.x;
            const pointerDy = star.y / height - pointer.y;
            const near = activeHole ? 0 : Math.max(0, 1 - Math.hypot(pointerDx, pointerDy) * 3.6);
            const driftX = activeHole ? 0 : (pointer.x - 0.5) * star.depth * 3.4;
            const driftY = activeHole ? 0 : (pointer.y - 0.5) * star.depth * 2.6;
            let drawX = star.x + driftX;
            let drawY = star.y + driftY;
            let size = star.r + near * 0.2;
            let alpha = Math.min(1, star.a * pulse + near * 0.16) * fieldOpacity;
            let stretch = 0;
            let angle = 0;

            if (activeHole) {
              const dx = star.x - activeHole.x;
              const dy = star.y - activeHole.y;
              const distance = Math.max(1, Math.hypot(dx, dy));
              const delay = (distance / farthestCorner) * 0.92;
              const travel = clamp((activeHole.age - 0.38 - delay) / 1.72);
              const collapse = easeInCubic(travel);
              angle = Math.atan2(dy, dx) + activeHole.spin * collapse * (3.2 + star.depth * 4.8);
              const radius = distance * (1 - collapse);
              drawX = activeHole.x + Math.cos(angle) * radius;
              drawY = activeHole.y + Math.sin(angle) * radius;
              size *= 1 - travel * 0.78;
              alpha *= 1 - travel ** 1.65;
              stretch = Math.sin(travel * Math.PI) * (1.4 + star.depth * 2.8);
            }

            if (alpha <= 0.01 || size <= 0.05) continue;
            ctx.beginPath();
            ctx.fillStyle = rgba(palette.white, alpha);
            if (activeHole && stretch > 0.05) {
              ctx.ellipse(
                drawX,
                drawY,
                size * (1 + stretch),
                Math.max(0.12, size * (1 - stretch * 0.16)),
                angle + Math.PI / 2,
                0,
                Math.PI * 2,
              );
            } else {
              ctx.arc(drawX, drawY, size, 0, Math.PI * 2);
            }
            ctx.fill();
          }
        }

        function drawMeteor(meteor) {
          const angle = Math.atan2(meteor.vy, meteor.vx);
          const tailX = meteor.x - Math.cos(angle) * meteor.len;
          const tailY = meteor.y - Math.sin(angle) * meteor.len;
          const alpha = clamp(meteor.life / meteor.max);
          const gradient = ctx.createLinearGradient(meteor.x, meteor.y, tailX, tailY);
          gradient.addColorStop(0, rgba(meteor.color, 0.94 * alpha));
          gradient.addColorStop(0.16, rgba(meteor.color, 0.46 * alpha));
          gradient.addColorStop(1, rgba(meteor.color, 0));

          ctx.strokeStyle = gradient;
          ctx.lineWidth = 1.6;
          ctx.lineCap = "round";
          ctx.shadowBlur = 13;
          ctx.shadowColor = meteor.color;
          ctx.beginPath();
          ctx.moveTo(meteor.x, meteor.y);
          ctx.lineTo(tailX, tailY);
          ctx.stroke();
          ctx.shadowBlur = 0;
        }

        function drawBlackHole(hole) {
          const opening = easeOutCubic(clamp(hole.age / 0.46));
          const feeding = clamp((hole.age - 0.28) / 2.4);
          const engulfing = easeInCubic(clamp((hole.age - 2.65) / 0.95));
          const farthestCorner = Math.hypot(
            Math.max(hole.x, width - hole.x),
            Math.max(hole.y, height - hole.y),
          ) + 24;
          const baseRadius = 7 + opening * 26 + feeding * 20;
          const coreRadius = baseRadius + engulfing * (farthestCorner - baseRadius);
          const ringFade = opening * (1 - engulfing);

          if (ringFade > 0.01) {
            const halo = ctx.createRadialGradient(
              hole.x,
              hole.y,
              baseRadius * 0.72,
              hole.x,
              hole.y,
              baseRadius * 2.8,
            );
            halo.addColorStop(0, rgba(palette.white, 0));
            halo.addColorStop(0.4, rgba(palette.white, 0.15 * ringFade));
            halo.addColorStop(0.58, rgba(palette.white, 0.035 * ringFade));
            halo.addColorStop(1, rgba(palette.white, 0));
            ctx.fillStyle = halo;
            ctx.beginPath();
            ctx.arc(hole.x, hole.y, baseRadius * 2.8, 0, Math.PI * 2);
            ctx.fill();

            ctx.save();
            ctx.translate(hole.x, hole.y);
            ctx.rotate(hole.age * 0.72 * hole.spin);
            ctx.scale(1, 0.34);
            ctx.lineCap = "round";

            for (let index = 0; index < 4; index += 1) {
              const orbitRadius = baseRadius * (1.32 + index * 0.24);
              const start = hole.age * (0.9 + index * 0.16) * hole.spin + index * 1.4;
              ctx.beginPath();
              ctx.arc(0, 0, orbitRadius, start, start + Math.PI * (0.72 + index * 0.08));
              ctx.strokeStyle = rgba(index === 0 ? palette.white : palette.silver, ringFade * (0.7 - index * 0.12));
              ctx.lineWidth = Math.max(0.7, 2.2 - index * 0.4);
              ctx.shadowBlur = 14;
              ctx.shadowColor = palette.white;
              ctx.stroke();
            }
            ctx.restore();
          }

          ctx.fillStyle = "#000";
          ctx.beginPath();
          ctx.arc(hole.x, hole.y, coreRadius, 0, Math.PI * 2);
          ctx.fill();

          if (ringFade > 0.01) {
            ctx.strokeStyle = rgba(palette.white, 0.82 * ringFade);
            ctx.lineWidth = 1.15;
            ctx.shadowBlur = 11;
            ctx.shadowColor = palette.white;
            ctx.beginPath();
            ctx.arc(hole.x, hole.y, baseRadius, 0, Math.PI * 2);
            ctx.stroke();
            ctx.shadowBlur = 0;
          }
        }

        function draw(now) {
          const dt = Math.min(0.033, (now - last) / 1000);
          last = now;
          ctx.clearRect(0, 0, width, height);

          if (!blackHole && fieldOpacity < 1) {
            fieldOpacity = Math.min(1, fieldOpacity + dt / 1.2);
          }
          drawStars(now, blackHole);

          if (!reduceMotion.matches && !blackHole) {
            spawn += dt;
            if (spawn > nextSpawn) {
              makeMeteor();
              spawn = 0;
              nextSpawn = random(1.4, 2.8);
            }

            for (const meteor of meteors) {
              meteor.x += meteor.vx * dt;
              meteor.y += meteor.vy * dt;
              meteor.life -= dt;
              drawMeteor(meteor);
            }
            meteors = meteors.filter((meteor) => meteor.life > 0 && meteor.x > -meteor.len && meteor.y < height + meteor.len);
          } else if (reduceMotion.matches) {
            meteors.slice(0, 2).forEach(drawMeteor);
          }

          if (blackHole) {
            blackHole.age += dt;
            drawBlackHole(blackHole);
            if (blackHole.age >= blackHole.max) {
              blackHole = null;
              fieldOpacity = 0;
              spawn = 0;
              nextSpawn = random(1.4, 2.8);
              canvas.style.cursor = "crosshair";
              makeField();
            }
          }

          frame = requestAnimationFrame(draw);
        }

        function move(event) {
          const rect = canvas.getBoundingClientRect();
          pointer = {
            x: (event.clientX - rect.left) / rect.width,
            y: (event.clientY - rect.top) / rect.height,
          };
        }

        function press(event) {
          if (reduceMotion.matches) return;
          const rect = canvas.getBoundingClientRect();
          openBlackHole(event.clientX - rect.left, event.clientY - rect.top);
        }

        function leave() {
          pointer = { x: 0.5, y: 0.5 };
        }

        resize();
        for (let index = 0; index < 3; index += 1) makeMeteor(true);
        window.addEventListener("resize", resize);
        canvas.addEventListener("pointermove", move);
        canvas.addEventListener("pointerdown", press);
        canvas.addEventListener("pointerleave", leave);
        frame = requestAnimationFrame(draw);

        window.addEventListener("pagehide", () => cancelAnimationFrame(frame), { once: true });
      })();
    </script>
  </body>
</html>
