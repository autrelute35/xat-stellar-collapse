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
  let w=innerWidth,h=innerHeight,time=0,last=0,stage=0,stageTime=0,previous=0,transition=1,visible=true,autoMusic=true,down=null;
  let stars=[],dust=[],nextMeteor=2,meteors=[],letterBorn=0,finalDust=[],lastTrail=0;
  const captionSurface=document.createElement('canvas'),captionCtx=captionSurface.getContext('2d',{willReadFrequently:true});
  let captionPieces=[],captionWidth=0,captionHeight=0,outgoingCaption=null;
  function prepareCaption(){
    const size=w<600?20:25,maxWidth=Math.min(w*.7,430),font='300 '+size+'px "Helvetica Neue", Arial, sans-serif';
    captionCtx.font=font;
    const rows=[];let row='';
    for(const word of captions[stage].split(' ')){
      const test=row?row+' '+word:word;
      if(row&&captionCtx.measureText(test).width>maxWidth){rows.push(row);row=word}else row=test;
    }
    rows.push(row);
    captionWidth=Math.ceil(maxWidth+16);captionHeight=Math.ceil(rows.length*size*1.5+16);
    captionSurface.width=captionWidth*2;captionSurface.height=captionHeight*2;
    captionCtx.setTransform(2,0,0,2,0,0);captionCtx.font=font;
    captionCtx.textAlign='center';captionCtx.textBaseline='middle';captionCtx.fillStyle='#c9c9c9';
    rows.forEach((r,i)=>captionCtx.fillText(r,captionWidth/2,captionHeight/2+(i-(rows.length-1)/2)*size*1.5));
    const data=captionCtx.getImageData(0,0,captionSurface.width,captionSurface.height).data;
    captionPieces=[];
    for(let y=0;y<captionHeight;y+=3)for(let x=0;x<captionWidth;x+=3){
      const width=Math.min(3,captionWidth-x),height=Math.min(3,captionHeight-y);
      let occupied=false;
      for(let py=0;py<height*2&&!occupied;py++)for(let px=0;px<width*2;px++){
        if(data[((y*2+py)*captionSurface.width+x*2+px)*4+3]>12){occupied=true;break}
      }
      if(occupied){const angle=rand(0,TAU),distance=rand(18,Math.min(w,h)*.19);
        captionPieces.push({x,y,width,height,dx:Math.cos(angle)*distance,dy:Math.sin(angle)*distance,phase:rand(0,TAU)});
      }
    }
  }
  function drawLetters(cx,cy,t,age){
    const elapsed=time-letterBorn;
    const outgoing=outgoingCaption&&elapsed<.8;
    const delay=stage===6?2:outgoingCaption?.8:0;
    if(!outgoing&&elapsed<delay)return;
    const progress=smooth((outgoing?elapsed:elapsed-delay)/(outgoing?.8:1.2));
    const fade=outgoing?1-progress:progress;
    const scatter=reduced?0:outgoing?progress:1-progress;
    const surface=outgoing?outgoingCaption.surface:captionSurface;
    const pieces=outgoing?outgoingCaption.pieces:captionPieces;
    const width=outgoing?outgoingCaption.width:captionWidth,height=outgoing?outgoingCaption.height:captionHeight;
    ctx.save();ctx.globalAlpha=fade;ctx.translate(cx,cy+Math.sin(t*.45)*1.2);
    if(scatter<.001){
      ctx.shadowColor='rgba(0,0,0,.8)';ctx.shadowBlur=3;
      ctx.drawImage(surface,-width/2,-height/2,width,height);
    }else{
      for(const p of pieces){
        ctx.globalAlpha=fade*(1-scatter*.3);
        const drift=Math.sin(t*.6+p.phase)*scatter*2;
        ctx.drawImage(surface,p.x*2,p.y*2,p.width*2,p.height*2,
          p.x-width/2+p.dx*scatter+drift,p.y-height/2+p.dy*scatter,p.width,p.height);
      }
    }
    ctx.restore();ctx.globalAlpha=1;
  }
  function resize(){w=innerWidth;h=innerHeight;const d=Math.min(devicePixelRatio||1,1.5);canvas.width=w*d;canvas.height=h*d;ctx.setTransform(d,0,0,d,0,0)}
  function seed(){stars=Array.from({length:innerWidth<600?720:1100},()=>({x:rand(-1.6,1.6),y:rand(-1.9,1.9),z:rand(.25,1.8),size:rand(.45,1.1),alpha:rand(.25,.85),phase:rand(0,TAU)}));
    dust=Array.from({length:760},(_,i)=>({a:i*2.399963,b:Math.acos(1-2*(i+.5)/760),r:rand(.85,1),phase:rand(0,TAU),size:rand(.45,1.15)}))}
  function caption(){letterBorn=time;line.textContent=captions[stage];prepareCaption()}
  function audioState(){const playing=!music.paused;sound.setAttribute('aria-pressed',String(playing));sound.setAttribute('aria-label',playing?'Müziği kapat':'Müziği aç');sound.title=playing?'Müziği kapat':'Müziği aç'}
  function play(){music.volume=.65;music.play().then(audioState).catch(audioState)}
  sound.addEventListener('click',()=>{autoMusic=false;if(music.paused)play();else music.pause();audioState()});
  function advance(){
    if(stage===6)return;
    if(time-stageTime<.45)return;
    if(autoMusic){play();autoMusic=false}
    const snapshot=document.createElement('canvas');
    snapshot.width=captionSurface.width;snapshot.height=captionSurface.height;
    snapshot.getContext('2d').drawImage(captionSurface,0,0);
    outgoingCaption={surface:snapshot,pieces:captionPieces,width:captionWidth,height:captionHeight};
    previous=stage;stage=(stage+1)%7;stageTime=time;transition=0;
    if(stage===6){finalDust=[];lastTrail=time}
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
  function finalStar(cx,cy,t,age,s,dt){
    if(age<=3)return;
    const born=smooth((age-3)/2.2),pulse=1+Math.sin(t*1.9)*.1;
    const moving=reduced?0:smooth((age-5.2)/1.7),u=Math.max(0,age-5.2);
    const sx=cx+moving*s*(Math.sin(u*.63)*.22+Math.sin(u*1.37)*.055);
    const sy=cy+moving*s*(Math.cos(u*.51)*.15-Math.cos(u*1.11)*.045);
    if(!reduced&&moving>.04&&time-lastTrail>.045){
      lastTrail=time;
      for(let i=0;i<2;i++)finalDust.push({x:sx+rand(-3,3),y:sy+rand(-3,3),vx:rand(-5,5),vy:rand(-5,5),age:0,life:rand(1.1,2.1),size:rand(.35,1.05),phase:rand(0,TAU)});
      if(finalDust.length>110)finalDust.splice(0,finalDust.length-110);
    }
    ctx.save();ctx.globalCompositeOperation='screen';
    ctx.fillStyle='#fff';
    finalDust=finalDust.filter(p=>p.age<p.life);
    for(const p of finalDust){p.age+=dt;p.x+=p.vx*dt;p.y+=p.vy*dt;dot(p.x,p.y,p.size*(1-p.age/p.life*.45),(1-p.age/p.life)*(.3+.25*Math.sin(t*5+p.phase)))}
    const glow=ctx.createRadialGradient(sx,sy,0,sx,sy,s*.12);
    glow.addColorStop(0,`rgba(255,255,255,${.72*born})`);
    glow.addColorStop(.055,`rgba(255,255,255,${.3*born})`);
    glow.addColorStop(.28,`rgba(255,255,255,${.07*born})`);
    glow.addColorStop(1,'rgba(255,255,255,0)');
    ctx.globalAlpha=pulse;ctx.fillStyle=glow;ctx.beginPath();ctx.arc(sx,sy,s*.12,0,TAU);ctx.fill();
    const horizontal=ctx.createLinearGradient(sx-s*.13,sy,sx+s*.13,sy);
    horizontal.addColorStop(0,'rgba(255,255,255,0)');horizontal.addColorStop(.42,`rgba(255,255,255,${.12*born})`);
    horizontal.addColorStop(.5,`rgba(255,255,255,${.92*born})`);horizontal.addColorStop(.58,`rgba(255,255,255,${.12*born})`);horizontal.addColorStop(1,'rgba(255,255,255,0)');
    ctx.fillStyle=horizontal;ctx.fillRect(sx-s*.13,sy-.55,s*.26,1.1);
    const vertical=ctx.createLinearGradient(sx,sy-s*.09,sx,sy+s*.09);
    vertical.addColorStop(0,'rgba(255,255,255,0)');vertical.addColorStop(.4,`rgba(255,255,255,${.1*born})`);
    vertical.addColorStop(.5,`rgba(255,255,255,${.88*born})`);vertical.addColorStop(.6,`rgba(255,255,255,${.1*born})`);vertical.addColorStop(1,'rgba(255,255,255,0)');
    ctx.fillStyle=vertical;ctx.fillRect(sx-.55,sy-s*.09,1.1,s*.18);
    ctx.strokeStyle=`rgba(255,255,255,${.2*born})`;ctx.lineWidth=.55;ctx.beginPath();
    ctx.moveTo(sx-s*.026,sy-s*.026);ctx.lineTo(sx+s*.026,sy+s*.026);ctx.moveTo(sx+s*.026,sy-s*.026);ctx.lineTo(sx-s*.026,sy+s*.026);ctx.stroke();
    for(let i=0;i<2;i++){
      const travel=((age-3.3+i*2.6)%5.2+5.2)%5.2/5.2,fade=Math.sin(travel*Math.PI)*.13*born;
      ctx.globalAlpha=fade;ctx.strokeStyle='#fff';ctx.lineWidth=.65;ctx.beginPath();ctx.arc(sx,sy,s*(.025+travel*.15),0,TAU);ctx.stroke();
    }
    ctx.globalAlpha=born;ctx.fillStyle='#fff';ctx.shadowColor='#fff';ctx.shadowBlur=18;
    ctx.beginPath();ctx.arc(sx,sy,(2.15+born*1.35)*pulse,0,TAU);ctx.fill();
    ctx.shadowBlur=5;ctx.globalAlpha=1;ctx.beginPath();ctx.arc(sx,sy,1.25,0,TAU);ctx.fill();ctx.restore();
  }
  function draw(now){
    requestAnimationFrame(draw);if(!visible)return;
    const dt=last?Math.min((now-last)/1000,.05):.016;last=now;time+=dt;transition=clamp(transition+dt/(reduced?.45:1.9));
    const age=time-stageTime,s=Math.min(w,h),cx=w/2,cy=h*.54,mix=smooth(transition),t=reduced?0:time;
    ctx.globalAlpha=1;ctx.fillStyle='#000';ctx.fillRect(0,0,w,h);ctx.fillStyle='#fff';
    veil.style.opacity=String(1-smooth(time/2));
    const swallow=stage===6?smooth(age/2):0;
    if(stage===6&&age>=2){
      finalStar(cx,cy,t,age,s,dt);
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
  resize();seed();canvas.dataset.scene='1';mark.textContent='01 / 07';caption();window.addEventListener('resize',()=>{resize();prepareCaption()});requestAnimationFrame(draw);
})();
</script>
</body>
</html>
