<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#000000">
<title>Olay Ufku</title>
<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#000;color:#fff}body{font-family:Georgia,'Times New Roman',serif;cursor:none;touch-action:none}canvas{display:block;width:100%;height:100%;position:fixed;inset:0}#words{position:fixed;left:22px;right:22px;top:21%;text-align:center;pointer-events:none;transition:opacity 1.2s,transform 2s;opacity:0;transform:translateY(12px)}#words.visible{opacity:1;transform:translateY(0)}h1{margin:0;font-size:25px;font-weight:400;letter-spacing:0;line-height:1.5;text-shadow:0 1px 24px #000}#sound{position:fixed;bottom:max(24px,env(safe-area-inset-bottom));right:24px;width:38px;height:38px;display:grid;place-items:center;border:1px solid #ffffff28;border-radius:50%;color:#aaa;background:#0008;cursor:pointer;z-index:4}#sound:hover,#sound:focus-visible{color:white;border-color:#aaa}#sound svg{width:17px;height:17px;fill:none;stroke:currentColor;stroke-width:1.5}#sound .off{display:none}#sound[aria-pressed=false] .off{display:block}#sound[aria-pressed=false] .on{display:none}#mark{position:fixed;left:24px;bottom:32px;font:10px/1.5 monospace;color:#555;pointer-events:none;letter-spacing:0}#veil{position:fixed;inset:0;background:black;opacity:0;pointer-events:none} @media(max-width:600px){h1{font-size:19px}#words{top:23%;left:16px;right:16px}#mark{left:18px}#sound{right:18px}}@media(prefers-reduced-motion:reduce){#words{transition:opacity .5s;transform:none}}
#words{z-index:2}#veil{z-index:1}#mark{z-index:2}body{cursor:crosshair}canvas{cursor:none}
</style>
</head>
<body>
<canvas id="space" aria-label="Etkileşimli yıldız alanı. İlerlemek için tıkla, kara deliği açmak için basılı tut." role="img"></canvas>
<div id="words"><h1 id="line"></h1></div>
<div id="veil"></div><div id="mark">EVENT HORIZON / 001</div>
<button id="sound" aria-label="Müziği aç" title="Müziği aç" aria-pressed="false"><svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 9h4l5-4v14l-5-4H4z"/><path class="on" d="M16 8q5 4 0 8m3-11q8 7 0 14"/><path class="off" d="m17 9 5 6m0-6-5 6"/></svg></button>
<audio id="music" src="https://raw.githubusercontent.com/autrelute35/xat-stellar-collapse/main/m.mp3" loop preload="none" playsinline></audio>
<script>
(() => {
  'use strict';
  const canvas=document.querySelector('#space'),ctx=canvas.getContext('2d');
  const words=document.querySelector('#words'),line=document.querySelector('#line'),veil=document.querySelector('#veil');
  const music=document.querySelector('#music'),sound=document.querySelector('#sound'),mark=document.querySelector('#mark');
  const reduced=matchMedia('(prefers-reduced-motion: reduce)').matches;
  let w=innerWidth,h=innerHeight,dpr=1,last=0,time=0,stage=0,stageTime=0,holding=false,holdStart=0,charge=0;
  let collapse=-1,ending=-1,reveal=0,eye=0,warp=0,textToken=0,autoMusic=true,visible=true;
  let pointer={x:w/2,y:h/2,active:false},trail=[],stars=[],shooters=[],nextMeteor=1;
  const rand=(a,b)=>a+Math.random()*(b-a),clamp=(v,a=0,b=1)=>Math.min(b,Math.max(a,v));
  const ease=t=>t*t*(3-2*t);
  function resize(){w=innerWidth;h=innerHeight;dpr=Math.min(devicePixelRatio||1,2);canvas.width=w*dpr;canvas.height=h*dpr;ctx.setTransform(dpr,0,0,dpr,0,0)}
  function seed(){stars=Array.from({length:w<600?950:1650},()=>({x:rand(-1.4,1.4),y:rand(-1.4,1.4),z:rand(.12,1.6),r:rand(.35,1.3),a:rand(.22,.95),p:rand(0,6.28),e:rand(0,1),angle:rand(0,6.28)}))}
  function caption(text){const token=++textToken;words.classList.remove('visible');setTimeout(()=>{if(token!==textToken)return;line.textContent=text;words.classList.add('visible')},700)}
  function audioState(){const playing=!music.paused;sound.setAttribute('aria-pressed',String(playing));sound.setAttribute('aria-label',playing?'Müziği kapat':'Müziği aç');sound.title=playing?'Müziği kapat':'Müziği aç'}
  function play(){music.volume=.65;music.play().then(audioState).catch(audioState)}
  sound.addEventListener('click',()=>{autoMusic=false;if(music.paused)play();else music.pause();audioState()});
  function advance(){if(collapse>=0||ending>=0)return;stage=Math.min(2,stage+1);stageTime=time;warp=reduced?.05:1;if(stage===1)caption('YAKLAŞTIKÇA DEĞİŞİR.');else caption('BOŞLUK BAKIYOR.')}
  function start(e){if(e.target.closest('button')||collapse>=0||ending>=0)return;holding=true;holdStart=time;if(autoMusic){play();autoMusic=false}if(e.pointerId!==undefined)canvas.setPointerCapture(e.pointerId)}
  function stop(e){if(!holding)return;const short=time-holdStart<.35;holding=false;if(short&&e?.type!=='pointercancel')advance()}
  canvas.addEventListener('pointerdown',start);canvas.addEventListener('pointerup',stop);canvas.addEventListener('pointercancel',stop);
  canvas.addEventListener('pointermove',e=>{pointer={x:e.clientX,y:e.clientY,active:true}});
  canvas.addEventListener('pointerleave',()=>{pointer.active=false});
  window.addEventListener('blur',()=>{holding=false;pointer.active=false});
  document.addEventListener('visibilitychange',()=>{visible=!document.hidden;holding=false;last=0});
  document.addEventListener('keydown',e=>{if(e.target.closest('button')||e.repeat)return;if(e.code==='Space'){e.preventDefault();start(e)}else if(e.code==='Enter')advance()});
  document.addEventListener('keyup',e=>{if(e.code==='Space')stop(e)});
  function reset(){collapse=-1;ending=-1;stage=0;stageTime=time;charge=0;eye=0;reveal=0;mark.textContent='EVENT HORIZON / 001';caption('UZAKTAN HER ŞEY SESSİZ.')}
  function draw(now){requestAnimationFrame(draw);if(!visible)return;const dt=last?Math.min((now-last)/1000,.04):.016;last=now;time+=dt;
    ctx.clearRect(0,0,w,h);ctx.fillStyle='#000';ctx.fillRect(0,0,w,h);
    const scale=Math.min(w,h),cx=w*.5,cy=h*.55;
    charge=clamp(charge+dt*(holding?.34:-.6));warp=Math.max(0,warp-dt*.5);
    if(charge>=1&&collapse<0&&ending<0){collapse=time;holding=false;caption('');mark.textContent='EVENT HORIZON / ∞'}
    const swallowing=collapse<0?0:clamp((time-collapse)/2),pull=Math.pow(swallowing,2.4);
    if(swallowing>=1&&ending<0){ending=time;caption('BURADA OLDUĞUNU KİMSE BİLMEYECEK.')}
    if(ending>=0){const age=time-ending;veil.style.opacity=age<4?'1':String(1-clamp((age-4)/3));
      if(age>4){const a=clamp((age-4)/2);ctx.fillStyle=`rgba(255,255,255,${a})`;ctx.beginPath();ctx.arc(cx,cy,1.2,0,Math.PI*2);ctx.fill();}
      if(age>8){veil.style.opacity='0';reset()}return;
    }
    reveal=Math.min(1,reveal+dt*.35);veil.style.opacity=String(1-reveal);
    const targetEye=stage===2&&time-stageTime<9?1:0;eye+=(targetEye-eye)*Math.min(1,dt*.9);const eyeAmount=eye*(1-charge);
    const radius=scale*(.018+charge*.15+pull*.7);
    for(let i=0;i<stars.length;i++){
      const s=stars[i];if(!reduced){s.z-=dt*(.008+warp*.19);if(s.z<.1){s.z=1.6;s.x=rand(-1.4,1.4);s.y=rand(-1.4,1.4)}}
      let x=cx+s.x*scale/s.z*.52,y=cy+s.y*scale/s.z*.52;
      if(eyeAmount>.001&&i<650){const u=s.e*2-1,ex=cx+u*scale*.37;const lid=Math.sin((u+1)*Math.PI/2)*scale*.13;let ey=cy+(i%2?1:-1)*lid;if(i%4===0){const a=s.angle; x=x; y=y;const px=cx+Math.cos(a)*scale*.067+(pointer.x-cx)*.025,py=cy+Math.sin(a)*scale*.067+(pointer.y-cy)*.025;x+=(px-x)*eyeAmount;y+=(py-y)*eyeAmount}else{x+=(ex-x)*eyeAmount;y+=(ey-y)*eyeAmount}}
      let dx=x-cx,dy=y-cy,d=Math.hypot(dx,dy),angle=Math.atan2(dy,dx);
      const lens=radius*radius/(d+radius+1)*(.3+charge*.8);angle+=charge*.25*Math.exp(-d/(scale*.5))+pull*7;
      d=(d+lens)*(1-pull);x=cx+Math.cos(angle)*d;y=cy+Math.sin(angle)*d;
      if(x<0||x>w||y<0||y>h||d<radius*(collapse>=0?.65:.88))continue;
      const twinkle=reduced?1:.76+.24*Math.sin(time*(.7+s.a)+s.p);ctx.globalAlpha=s.a*twinkle*(1-swallowing*.4);ctx.fillStyle='#fff';
      const size=Math.min(2,s.r/s.z*.65);ctx.beginPath();ctx.arc(x,y,size,0,6.283);ctx.fill();
      if(warp>.08||swallowing>.02){const length=(warp*14+pull*scale*.14);ctx.strokeStyle='#fff';ctx.lineWidth=size*.55;ctx.globalAlpha*=.45;ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(x+Math.cos(angle+.5*pull)*length,y+Math.sin(angle+.5*pull)*length);ctx.stroke()}
      if(s.a>.92&&s.z<.55){ctx.globalAlpha*=.35;ctx.fillRect(x-4,y-.35,8,.7);ctx.fillRect(x-.35,y-4,.7,8)}
    }
    ctx.globalAlpha=1;
    if(charge>.01||collapse>=0){ctx.save();ctx.translate(cx,cy);ctx.rotate(-.3);ctx.scale(1,.32);for(let i=0;i<5;i++){ctx.beginPath();ctx.ellipse(0,0,radius*(1.2+i*.08),radius*(1.2+i*.08),0,0,6.283);ctx.strokeStyle=`rgba(255,255,255,${charge*(.5-i*.08)*(1-swallowing)})`;ctx.lineWidth=i===0?2:1;ctx.stroke()}ctx.restore();ctx.fillStyle='#000';ctx.beginPath();ctx.arc(cx,cy,radius*.88,0,6.283);ctx.fill();}
    if(!reduced&&time>nextMeteor&&charge<.15){shooters.push({x:rand(w*.2,w),y:rand(0,h*.4),life:0});nextMeteor=time+rand(2,5)}
    shooters=shooters.filter(s=>s.life<1);for(const m of shooters){m.life+=dt*.7;const x=m.x-m.life*scale*.8,y=m.y+m.life*scale*.38;const g=ctx.createLinearGradient(x,y,x+100,y-48);g.addColorStop(0,`rgba(255,255,255,${Math.sin(m.life*Math.PI)*.7})`);g.addColorStop(1,'transparent');ctx.strokeStyle=g;ctx.lineWidth=1;ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(x+100,y-48);ctx.stroke()}
    if(pointer.active&&!reduced){trail.push({x:pointer.x,y:pointer.y,t:time});trail=trail.filter(p=>time-p.t<.32);for(let i=1;i<trail.length;i++){ctx.strokeStyle=`rgba(255,255,255,${i/trail.length*.45})`;ctx.lineWidth=i/trail.length*1.4;ctx.beginPath();ctx.moveTo(trail[i-1].x,trail[i-1].y);ctx.lineTo(trail[i].x,trail[i].y);ctx.stroke()}ctx.fillStyle='white';ctx.beginPath();ctx.arc(pointer.x,pointer.y,1.6,0,6.283);ctx.fill()}
  }
  resize();seed();reset();window.addEventListener('resize',resize);requestAnimationFrame(draw);
})();
</script>
</body>
</html>
