<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#050505">
<title>Sohbet Live</title>
<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#050505;color:#eee}body{font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif;touch-action:manipulation}canvas{position:fixed;inset:0;width:100%;height:100%;display:block}#bg{z-index:0}header{position:fixed;z-index:3;top:max(18px,env(safe-area-inset-top));left:18px;right:18px;display:flex;align-items:flex-start;justify-content:space-between;pointer-events:none}.brand{font:500 9px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace;color:#888;letter-spacing:.16em}.brand b{display:block;color:#ededed;font:400 12px/1.5 -apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif;letter-spacing:0}.presence{text-align:right;font:8px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace;color:#666;letter-spacing:.11em}.presence i{display:inline-block;width:5px;height:5px;margin-right:6px;border-radius:50%;background:#555}.presence.live i{background:#eee;box-shadow:0 0 9px #fff}.feed{position:fixed;z-index:2;inset:14% 17px 11%;display:flex;flex-direction:column;justify-content:flex-end;gap:0;overflow:hidden;perspective:700px}.msg{position:relative;display:grid;grid-template-columns:54px minmax(58px,100px) 1fr;gap:10px;align-items:baseline;padding:8px 2px;border-bottom:1px solid #ffffff0b;opacity:var(--alpha,.7);transform:translateZ(0);transition:opacity .35s,transform .35s,filter .35s;cursor:pointer;min-height:36px}.msg time,.msg .name{font:8px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace;color:#606060;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.msg .name{color:#a9a9a9}.msg .text{font-size:clamp(11px,3.25vw,15px);font-weight:300;line-height:1.45;color:#d8d8d8;overflow-wrap:anywhere}.msg.new{animation:arrive .75s cubic-bezier(.16,.78,.18,1) both}@keyframes arrive{0%{opacity:0;transform:translateY(34px) scale(.97);filter:blur(7px)}100%{opacity:var(--alpha,.7);transform:none;filter:none}}.msg.focus{opacity:1!important;transform:translateY(-3px) scale(1.025);filter:none}.msg.breaking .text{color:transparent}.shard{position:fixed;z-index:5;pointer-events:none;color:#eee;font:300 13px/1 sans-serif;animation:shatter 1.45s cubic-bezier(.15,.72,.2,1) both}@keyframes shatter{0%{opacity:.95;transform:translate(0,0) rotate(0)}62%{opacity:.7;transform:translate(var(--x),var(--y)) rotate(var(--r))}100%{opacity:0;transform:translate(calc(var(--x)*.18),calc(var(--y)*.18)) rotate(0)}}#empty{position:fixed;z-index:2;left:20px;right:20px;top:49%;text-align:center;font:300 13px/1.6 -apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif;color:#555;opacity:0;transition:opacity .4s;pointer-events:none}#sound{position:fixed;z-index:5;right:15px;bottom:max(14px,env(safe-area-inset-bottom));width:44px;height:44px;border:0;border-radius:50%;display:grid;place-items:center;background:#050505aa;color:#666;font:16px/1 sans-serif;cursor:pointer}#sound.on{color:#eee}#sound:focus-visible{outline:1px solid #999;outline-offset:2px}.stamp{position:fixed;z-index:3;left:18px;bottom:max(23px,env(safe-area-inset-bottom));font:7px/1 ui-monospace,SFMono-Regular,Menlo,monospace;color:#444;letter-spacing:.12em;pointer-events:none}@media(max-width:480px){.feed{inset:13% 14px 10%}.msg{grid-template-columns:44px 68px 1fr;gap:7px;padding:7px 1px}.msg .text{font-size:11px}.msg time,.msg .name{font-size:7px}header{left:15px;right:15px}.stamp{left:15px}}@media(prefers-reduced-motion:reduce){.msg.new,.shard{animation-duration:.2s}}
</style>
</head>
<body>
<canvas id="bg" aria-hidden="true"></canvas>
<header><div class="brand">XAT STREAM<b>sohbet / canlı kayıt</b></div><div id="presence" class="presence"><i></i><span>BAĞLANIYOR</span></div></header>
<main id="feed" class="feed" aria-live="polite"></main>
<div id="empty">Akış sessiz.</div>
<div id="stamp" class="stamp">PUBLIC MAIN / NO ARCHIVE</div>
<button id="sound" aria-label="Sesi aç" title="Sesi aç">♪</button>
<script>
(() => {
  'use strict';
  const API='https://45-43-152-155.sslip.io/live';
  const feed=document.querySelector('#feed'),presence=document.querySelector('#presence'),empty=document.querySelector('#empty'),canvas=document.querySelector('#bg'),ctx=canvas.getContext('2d'),sound=document.querySelector('#sound');
  const seen=new Set();let w=0,h=0,dpr=1,time=0,last=0,pulses=[],dust=[],first=true,failures=0,audio=null,master=null,soundOn=false;
  const rand=(a,b)=>a+Math.random()*(b-a),clamp=v=>Math.max(0,Math.min(1,v)),TAU=Math.PI*2;
  function resize(){w=innerWidth;h=innerHeight;dpr=Math.min(devicePixelRatio||1,1.5);canvas.width=w*dpr;canvas.height=h*dpr;ctx.setTransform(dpr,0,0,dpr,0,0);if(!dust.length)dust=Array.from({length:w<600?65:95},()=>({x:rand(0,w),y:rand(0,h),v:rand(3,12),a:rand(.03,.15),r:rand(.3,1)}))}
  function initAudio(){if(audio){audio.resume();return}audio=new(window.AudioContext||window.webkitAudioContext)();master=audio.createGain();master.gain.value=0;master.connect(audio.destination)}
  function setSound(on){soundOn=on;initAudio();master.gain.setTargetAtTime(on?.8:0,audio.currentTime,.06);sound.classList.toggle('on',on);sound.textContent=on?'♫':'♪';sound.setAttribute('aria-label',on?'Sesi kapat':'Sesi aç');sound.title=on?'Sesi kapat':'Sesi aç'}
  function ping(){if(!audio||!soundOn)return;const o=audio.createOscillator(),g=audio.createGain();o.type='sine';o.frequency.value=rand(170,230);g.gain.setValueAtTime(.0001,audio.currentTime);g.gain.exponentialRampToValueAtTime(.045,audio.currentTime+.01);g.gain.exponentialRampToValueAtTime(.0001,audio.currentTime+.38);o.connect(g).connect(master);o.start();o.stop(audio.currentTime+.4)}
  sound.addEventListener('click',e=>{e.stopPropagation();setSound(!soundOn)});
  document.addEventListener('pointerdown',()=>{if(!audio)setSound(true)},{once:true});
  function row(message,index,total,isNew){
    const el=document.createElement('article');el.className='msg'+(isNew?' new':'');el.dataset.id=message.id;el.style.setProperty('--alpha',String(.3+.7*(index+1)/total));
    const when=document.createElement('time');when.textContent=message.time.slice(0,5);
    const name=document.createElement('div');name.className='name';name.textContent=message.name;
    const text=document.createElement('div');text.className='text';text.textContent=message.text;
    el.append(when,name,text);el.addEventListener('click',()=>breakMessage(el,text));return el;
  }
  function breakMessage(el,text){
    if(el.classList.contains('breaking'))return;document.querySelectorAll('.msg.focus').forEach(x=>x.classList.remove('focus'));el.classList.add('focus','breaking');
    const rect=text.getBoundingClientRect(),chars=[...text.textContent].filter(x=>x.trim());
    chars.slice(0,70).forEach((ch,i)=>{const s=document.createElement('span');s.className='shard';s.textContent=ch;s.style.left=rect.left+rand(0,rect.width)+'px';s.style.top=rect.top+rand(0,rect.height)+'px';s.style.setProperty('--x',rand(-42,42)+'px');s.style.setProperty('--y',rand(-35,35)+'px');s.style.setProperty('--r',rand(-60,60)+'deg');s.style.animationDelay=i*5+'ms';document.body.appendChild(s);setTimeout(()=>s.remove(),1600)});
    pulses.push({x:rect.left+rect.width/2,y:rect.top+rect.height/2,age:0,power:1});setTimeout(()=>el.classList.remove('breaking','focus'),1250);
  }
  function render(messages){
    const old=new Set([...feed.children].map(x=>x.dataset.id));feed.replaceChildren();
    messages.forEach((m,i)=>feed.appendChild(row(m,i,messages.length,!first&&!old.has(m.id))));
    const fresh=!first?messages.filter(m=>!seen.has(m.id)):[];messages.forEach(m=>seen.add(m.id));while(seen.size>80)seen.delete(seen.values().next().value);
    if(fresh.length){pulses.push({x:w*.5,y:h*.72,age:0,power:1});fresh.forEach(()=>ping())}
    first=false;empty.style.opacity=messages.length?'0':'1';
  }
  async function poll(){
    try{const res=await fetch(API,{cache:'no-store'});if(!res.ok)throw Error(String(res.status));const data=await res.json();render(Array.isArray(data.messages)?data.messages:[]);presence.classList.add('live');presence.querySelector('span').textContent=String(data.online||0).padStart(2,'0')+' ÇEVRİMİÇİ';failures=0}
    catch{failures++;presence.classList.remove('live');presence.querySelector('span').textContent=failures>2?'AKIŞ KESİLDİ':'YENİDEN BAĞLANIYOR'}
  }
  canvas.addEventListener('pointerdown',e=>pulses.push({x:e.clientX,y:e.clientY,age:0,power:.7}));
  function draw(now){
    requestAnimationFrame(draw);const dt=last?Math.min((now-last)/1000,.05):.016;last=now;time+=dt;ctx.fillStyle='#050505';ctx.globalAlpha=1;ctx.fillRect(0,0,w,h);
    ctx.fillStyle='#fff';for(const p of dust){p.y-=p.v*dt;if(p.y<0){p.y=h;p.x=rand(0,w)}ctx.globalAlpha=p.a*(.65+.35*Math.sin(time+p.x));ctx.beginPath();ctx.arc(p.x,p.y,p.r,0,TAU);ctx.fill()}
    pulses=pulses.filter(p=>p.age<1);ctx.strokeStyle='#fff';for(const p of pulses){p.age+=dt*.55;const q=clamp(p.age);for(let i=0;i<3;i++){const r=(q+i*.14)*Math.min(w,h)*.32;ctx.globalAlpha=(1-q)*(.12-i*.025)*p.power;ctx.lineWidth=.6;ctx.beginPath();ctx.arc(p.x,p.y,r,0,TAU);ctx.stroke()}}
    const grad=ctx.createLinearGradient(0,0,0,h);grad.addColorStop(0,'rgba(255,255,255,.025)');grad.addColorStop(.5,'rgba(255,255,255,0)');grad.addColorStop(1,'rgba(255,255,255,.018)');ctx.globalAlpha=1;ctx.fillStyle=grad;ctx.fillRect(0,0,w,h)
  }
  addEventListener('resize',resize);document.addEventListener('visibilitychange',()=>{last=0;if(!document.hidden)poll()});resize();poll();setInterval(poll,2500);requestAnimationFrame(draw);
})();
</script>
</body>
</html>
