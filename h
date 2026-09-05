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
h1{font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif;font-size:18px;font-weight:300;line-height:1.7;color:#d2d2d2;letter-spacing:0;text-shadow:none}#words{top:19%;left:24px;right:24px}#sound{width:44px;height:44px}canvas,body{cursor:default}#mark{font-size:9px;color:#505050}@media(max-width:600px){h1{font-size:15px;font-weight:300}#words{top:20%}}
#words{position:absolute;width:1px;height:1px;overflow:hidden;clip-path:inset(50%);white-space:nowrap}
</style>
</head>
<body>
<canvas id="space" aria-label="Etkileşimli yıldız alanı. Yedi sahne arasında ilerlemek için dokun." role="img"></canvas>
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
  const captions=['Uzaktan her şey sessiz.','Yaklaştıkça değişir.','Boşluk bile nefes alır.','Bir arada. Birbirinden uzak.','Her şey bir iz bırakır.','Artık geri dönüş yok.','Geriye sessizlik kalır.'];
  const TAU=Math.PI*2,rand=(a,b)=>a+Math.random()*(b-a),clamp=v=>Math.max(0,Math.min(1,v)),smooth=v=>{v=clamp(v);return v*v*(3-2*v)};
  let w=innerWidth,h=innerHeight,time=0,last=0,stage=0,stageTime=0,previous=0,transition=1,visible=true,autoMusic=true,textToken=0,down=null;
  let stars=[],dust=[],nextMeteor=2,meteors=[],letterStars=[],letterBorn=0;
  const textCanvas=document.createElement('canvas'),textContext=textCanvas.getContext('2d',{willReadFrequently:true});
  function buildLetters(){
    const size=w<600?20:25,maxWidth=Math.min(w*.7,430),rows=[];
    textContext.font=size+'px "Helvetica Neue", Arial, sans-serif';
    let row='';
    for(const word of captions[stage].split(' ')){
      const test=row?row+' '+word:word;
      if(row&&textContext.measureText(test).width>maxWidth){rows.push(row);row=word}else row=test;
    }
    rows.push(row);
    textCanvas.width=Math.ceil(maxWidth+12);textCanvas.height=rows.length*size*1.5+12;
    textContext.font=size+'px "Helvetica Neue", Arial, sans-serif';
    textContext.textAlign='center';textContext.textBaseline='middle';textContext.fillStyle='#fff';
    rows.forEach((r,i)=>textContext.fillText(r,textCanvas.width/2,6+size*.75+i*size*1.5));
    const pixels=textContext.getImageData(0,0,textCanvas.width,textCanvas.height).data;
    letterStars=[];
    for(let y=0;y<textCanvas.height;y+=2)for(let x=0;x<textCanvas.width;x+=2){
      const a=pixels[(y*textCanvas.width+x)*4+3]/255;
      if(a>.12&&Math.random()<.78)letterStars.push({x:x-textCanvas.width/2+rand(-.8,.8),y:y-textCanvas.height/2+rand(-.8,.8),a:a*rand(.58,1),phase:rand(0,TAU),r:rand(.42,1.08)});
    }
    letterBorn=time;
  }
  function drawLetters(cx,cy,t,age){
    const fade=smooth((time-letterBorn)/1.5)*(stage===6?smooth((age-2)/1.5):1);
    const breath=1+Math.sin(t*.95)*.016;
    const size=w<600?20:25;
    ctx.save();ctx.translate(cx,cy+Math.sin(t*.45)*2);ctx.scale(breath,breath);
    ctx.font='300 '+size+'px "Helvetica Neue", Arial, sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';ctx.fillStyle=`rgba(255,255,255,${.1*fade})`;
    const rows=[];let row='';const maxWidth=Math.min(w*.7,430);
    for(const word of captions[stage].split(' ')){const test=row?row+' '+word:word;if(row&&ctx.measureText(test).width>maxWidth){rows.push(row);row=word}else row=test}rows.push(row);
    rows.forEach((r,i)=>ctx.fillText(r,0,(i-(rows.length-1)/2)*size*1.5));ctx.restore();
    ctx.save();ctx.fillStyle='#fff';ctx.shadowColor='rgba(255,255,255,.22)';ctx.shadowBlur=2;
    for(const p of letterStars){
      const shimmer=.72+.28*Math.sin(t*.6+p.phase);
      dot(cx+p.x*breath,cy+p.y*breath+Math.sin(t*.45)*2,p.r,p.a*.66*fade*shimmer);
    }
    ctx.restore();ctx.globalAlpha=1;
  }
  function resize(){w=innerWidth;h=innerHeight;const d=Math.min(devicePixelRatio||1,1.5);canvas.width=w*d;canvas.height=h*d;ctx.setTransform(d,0,0,d,0,0)}
  function seed(){stars=Array.from({length:innerWidth<600?720:1100},()=>({x:rand(-1.6,1.6),y:rand(-1.9,1.9),z:rand(.25,1.8),size:rand(.45,1.1),alpha:rand(.25,.85),phase:rand(0,TAU)}));
    dust=Array.from({length:760},(_,i)=>({a:i*2.399963,b:Math.acos(1-2*(i+.5)/760),r:rand(.85,1),phase:rand(0,TAU),size:rand(.45,1.15)}))}
  function caption(){letterStars=[];const token=++textToken;words.classList.remove('visible');setTimeout(()=>{if(token!==textToken)return;line.textContent=captions[stage];buildLetters();words.classList.add('visible')},350)}
  function audioState(){const playing=!music.paused;sound.setAttribute('aria-pressed',String(playing));sound.setAttribute('aria-label',playing?'Müziği kapat':'Müziği aç');sound.title=playing?'Müziği kapat':'Müziği aç'}
  function play(){music.volume=.65;music.play().then(audioState).catch(audioState)}
  sound.addEventListener('click',()=>{autoMusic=false;if(music.paused)play();else music.pause();audioState()});
  function advance(){
    if(stage===6&&time-stageTime<3)return;
    if(time-stageTime<.45)return;
    if(autoMusic){play();autoMusic=false}
    previous=stage;stage=(stage+1)%7;stageTime=time;transition=0;
    canvas.dataset.scene=String(stage+1);mark.textContent=String(stage+1).padStart(2,'0')+' / 07';caption();
  }
  canvas.addEventListener('pointerdown',e=>{down={x:e.clientX,y:e.clientY};canvas.setPointerCapture(e.pointerId)});
  canvas.addEventListener('pointerup',e=>{if(down&&Math.hypot(e.clientX-down.x,e.clientY-down.y)<24)advance();down=null});
  canvas.addEventListener('pointercancel',()=>down=null);
  window.addEventListener('blur',()=>down=null);
  document.addEventListener('visibilitychange',()=>{visible=!document.hidden;down=null;last=0});
  document.addEventListener('keydown',e=>{if(e.target.closest('button')||e.repeat)return;if(e.code==='Space'||e.code==='Enter'){e.preventDefault();advance()}});
  // Each constellation shares its particles, so scene transitions stay continuous.
  function position(p,scene,t,s){
    const breath=1+Math.sin(t*.95)*.055;
    const a=p.a+(reduced?0:t*.085),r=s*.285*breath;
    if(scene<=1)return {x:Math.cos(p.a)*s*p.r*1.3,y:Math.sin(p.a*1.37)*s*p.r*1.5,alpha:0};
    if(scene===2)return {x:Math.cos(a)*Math.sin(p.b)*r,y:Math.cos(p.b)*r,alpha:.3+.65*(Math.sin(a)*.5+.5)};
    if(scene===3){const side=p.phase<Math.PI?-1:1;return {x:Math.cos(a)*Math.sin(p.b)*r*.65+side*s*.15,y:Math.cos(p.b)*r*.8+Math.sin(t*.65)*side*s*.025,alpha:.35+.55*(Math.sin(a)*.5+.5)}}
    if(scene===4){const ring=Math.floor(p.phase/TAU*3),ra=s*(.2+ring*.067);const tilt=ring*.7-.7;const x=Math.cos(a)*ra,y=Math.sin(a)*ra*.38;return {x:x*Math.cos(tilt)-y*Math.sin(tilt),y:x*Math.sin(tilt)+y*Math.cos(tilt),alpha:.7}}
    const speed=reduced?0:t*.65,radius=s*(.06+p.phase/TAU*.32);return {x:Math.cos(p.a+speed)*radius,y:Math.sin(p.a+speed)*radius*.46,alpha:.45+.4*p.r};
  }
  function dot(x,y,r,a){ctx.globalAlpha=clamp(a);ctx.beginPath();ctx.arc(x,y,r,0,TAU);ctx.fill()}
  function draw(now){
    requestAnimationFrame(draw);if(!visible)return;
    const dt=last?Math.min((now-last)/1000,.05):.016;last=now;time+=dt;transition=clamp(transition+dt/(reduced?.45:1.9));
    const age=time-stageTime,s=Math.min(w,h),cx=w/2,cy=h*.54,mix=smooth(transition),t=reduced?0:time;
    ctx.globalAlpha=1;ctx.fillStyle='#000';ctx.fillRect(0,0,w,h);ctx.fillStyle='#fff';
    veil.style.opacity=String(1-smooth(time/2));
    const swallow=stage===6?smooth(age/2):0;
    if(stage===6&&age>=2){
      if(age>3){const a=smooth((age-3)/3);dot(cx,cy,1.25,a);ctx.globalAlpha=a*.16;ctx.fillRect(cx-7,cy-.3,14,.6);ctx.fillRect(cx-.3,cy-7,.6,14)}
      drawLetters(cx,cy-h*.07,t,age);ctx.globalAlpha=1;return;
    }
    for(const p of stars){
      if(!reduced){p.z-=dt*(stage===1?.065:.008);if(p.z<.25)p.z=1.8}
      let x=p.x*s/p.z*.5,y=p.y*s/p.z*.5;
      if(stage===5||stage===6){const a=Math.atan2(y,x)+(stage===6?swallow*5:t*.04),d=Math.hypot(x,y)*(1-swallow);x=Math.cos(a)*d;y=Math.sin(a)*d}
      if(Math.abs(x)>w/2||Math.abs(y)>h/2)continue;
      dot(cx+x,cy+y,p.size,p.alpha*(.8+.2*Math.sin(t+p.phase))*(stage>=2?.5:1));
      if(stage===1||stage===6){ctx.globalAlpha=p.alpha*.2;ctx.strokeStyle='#fff';ctx.lineWidth=.6;ctx.beginPath();ctx.moveTo(cx+x,cy+y);ctx.lineTo(cx+x*1.035,cy+y*1.035);ctx.stroke()}
    }
    for(const p of dust){
      const from=position(p,previous,t,s),to=position(p,stage===6?5:stage,t,s);
      let x=from.x+(to.x-from.x)*mix,y=from.y+(to.y-from.y)*mix;
      if(stage===6){const a=Math.atan2(y,x)+swallow*7,d=Math.hypot(x,y)*(1-swallow);x=Math.cos(a)*d;y=Math.sin(a)*d}
      dot(cx+x,cy+y,p.size,from.alpha+(to.alpha-from.alpha)*mix);
    }
    if(stage===5||stage===6){
      ctx.globalAlpha=1;ctx.fillStyle='#000';ctx.beginPath();ctx.arc(cx,cy,s*(.042+swallow*.035),0,TAU);ctx.fill();ctx.fillStyle='#fff';
    }
    if(!reduced&&time>nextMeteor&&stage<5){meteors.push({x:rand(w*.3,w),y:rand(0,h*.35),age:0});nextMeteor=time+rand(3,6)}
    meteors=meteors.filter(m=>m.age<1);for(const m of meteors){m.age+=dt*.65;const x=m.x-m.age*s*.8,y=m.y+m.age*s*.4;ctx.globalAlpha=Math.sin(clamp(m.age)*Math.PI)*.55;const g=ctx.createLinearGradient(x,y,x+60,y-30);g.addColorStop(0,'white');g.addColorStop(1,'transparent');ctx.strokeStyle=g;ctx.lineWidth=.8;ctx.beginPath();ctx.moveTo(x,y);ctx.lineTo(x+60,y-30);ctx.stroke()}
    drawLetters(cx,cy,t,age);ctx.globalAlpha=1;
  }
  resize();seed();canvas.dataset.scene='1';mark.textContent='01 / 07';caption();window.addEventListener('resize',()=>{resize();buildLetters()});requestAnimationFrame(draw);
})();
</script>
</body>
</html>
