<!doctype html>
<html lang="tr">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
    <title>Audio</title>
    <style>
      :root {
        color-scheme: dark;
      }

      * {
        box-sizing: border-box;
      }

      html,
      body {
        width: 100%;
        height: 100%;
        margin: 0;
        overflow: hidden;
        background: transparent !important;
      }

      body {
        font-family: Arial, sans-serif;
      }

      .player {
        position: fixed;
        right: max(16px, env(safe-area-inset-right));
        bottom: max(16px, env(safe-area-inset-bottom));
        z-index: 1;
        width: 46px;
        height: 46px;
        padding: 0;
        border: 1px solid rgba(255, 255, 255, 0.72);
        border-radius: 50%;
        color: #fff;
        background: rgba(0, 0, 0, 0.66);
        box-shadow: 0 4px 18px rgba(0, 0, 0, 0.36);
        cursor: pointer;
        -webkit-tap-highlight-color: transparent;
        transition: background 160ms ease, border-color 160ms ease, transform 160ms ease;
      }

      .player:hover,
      .player:focus-visible {
        border-color: #fff;
        background: rgba(0, 0, 0, 0.82);
        outline: none;
        transform: scale(1.04);
      }

      .player::before {
        content: "";
        position: absolute;
        top: 50%;
        left: 52%;
        width: 0;
        height: 0;
        border-top: 7px solid transparent;
        border-bottom: 7px solid transparent;
        border-left: 11px solid currentColor;
        transform: translate(-50%, -50%);
      }

      .player::after {
        content: "";
        position: absolute;
        inset: -7px;
        border: 1px solid rgba(255, 255, 255, 0.34);
        border-radius: 50%;
        animation: signal 2.1s ease-out infinite;
        pointer-events: none;
      }

      .player.is-playing::before {
        width: 12px;
        height: 14px;
        border: 0;
        background: linear-gradient(90deg, currentColor 0 4px, transparent 4px 8px, currentColor 8px 12px);
        transform: translate(-52%, -50%);
      }

      .player.is-playing::after {
        animation: none;
        opacity: 0;
      }

      @keyframes signal {
        0% {
          opacity: 0.68;
          transform: scale(0.78);
        }
        72%,
        100% {
          opacity: 0;
          transform: scale(1.28);
        }
      }

      @media (prefers-reduced-motion: reduce) {
        .player,
        .player::after {
          animation: none;
          transition: none;
        }
      }
    </style>
  </head>
  <body>
    <audio id="track" src="https://raw.githubusercontent.com/autrelute35/xat-stellar-collapse/main/b.mp3" preload="metadata" loop></audio>
    <button class="player" type="button" aria-label="Müziği oynat" aria-pressed="false" title="Müziği oynat"></button>

    <script>
      (() => {
        const track = document.querySelector("#track");
        const player = document.querySelector(".player");

        track.volume = 0.42;

        const sync = () => {
          const playing = !track.paused;
          player.classList.toggle("is-playing", playing);
          player.setAttribute("aria-pressed", String(playing));
          player.setAttribute("aria-label", playing ? "Müziği duraklat" : "Müziği oynat");
          player.title = playing ? "Müziği duraklat" : "Müziği oynat";
        };

        const toggle = async () => {
          if (track.paused) {
            try {
              await track.play();
            } catch (_) {
              return;
            }
          } else {
            track.pause();
          }
          sync();
        };

        const startFromPage = async (event) => {
          if (event.target.closest(".player") || !track.paused) return;
          try {
            await track.play();
          } catch (_) {
            return;
          }
          sync();
        };

        player.addEventListener("click", toggle);
        document.addEventListener("click", startFromPage);
        track.addEventListener("play", sync);
        track.addEventListener("pause", sync);
        track.addEventListener("ended", sync);
        sync();
      })();
    </script>
  </body>
</html>
