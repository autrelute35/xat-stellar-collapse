<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#050505">
<title>Kayıp Frekans</title>
<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#050505;color:#eee}body{font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif;touch-action:none;user-select:none}canvas{position:fixed;inset:0;width:100%;height:100%;display:block;cursor:grab}canvas.dragging{cursor:grabbing}.hud{position:fixed;z-index:2;pointer-events:none}#station{top:max(22px,env(safe-area-inset-top));left:22px;font:500 9px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace;color:#777;letter-spacing:.18em}#frequency{top:max(21px,env(safe-area-inset-top));right:22px;text-align:right;font:300 13px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace;color:#d7d7d7;font-variant-numeric:tabular-nums}#frequency small{display:block;margin-top:2px;font-size:7px;color:#555;letter-spacing:.12em}#message{left:22px;right:22px;top:64%;transform:translateY(-50%);text-align:center;opacity:0;transition:opacity .16s;will-change:opacity,transform}#message strong{display:block;font-size:clamp(15px,4.3vw,22px);font-weight:300;line-height:1.6;letter-spacing:0;color:#e8e8e8;text-shadow:0 0 18px #fff2}#message span{display:block;margin-top:8px;font:8px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace;color:#686868;letter-spacing:.16em}#memory{left:22px;bottom:max(25px,env(safe-area-inset-bottom));display:flex;gap:7px;align-items:center}#memory i{display:block;width:17px;height:1px;background:#3d3d3d;transition:background .35s,box-shadow .35s,transform .35s}#memory i.on{background:#e7e7e7;box-shadow:0 0 8px #fff8;transform:scaleX(.72)}#sound{position:fixed;right:18px;bottom:max(17px,env(safe-area-inset-bottom));z-index:4;width:42px;height:42px;border:0;border-radius:50%;background:#080808b8;color:#777;font:16px/1 sans-serif;display:grid;place-items:center;cursor:pointer}#sound:focus-visible{outline:1px solid #aaa;outline-offset:2px}#sound.on{color:#eee}.edge{position:fixed;z-index:3;pointer-events:none;background:#fff;opacity:.13}.edge.x{left:0;right:0;top:0;height:1px}.edge.y{top:0;bottom:0;left:0;width:1px}@media(max-width:600px){#station{left:17px}#frequency{right:17px}#message{left:20px;right:20px;top:66%}#memory{left:17px}}
@media(prefers-reduced-motion:reduce){#message{transition:none}}
</style>
</head>
<body>
<canvas id="screen" role="img" aria-label="Dokunmaya tepki veren kayıp yayın alıcısı"></canvas>
<div id="station" class="hud">NO CARRIER</div>
<div id="frequency" class="hud">079.0<small>MHZ / UNKNOWN BAND</small></div>
<div id="message" class="hud"><strong></strong><span></span></div>
<div id="memory" class="hud" aria-hidden="true"><i></i><i></i><i></i><i></i><i></i></div>
<button id="sound" aria-label="Sesi aç" title="Sesi aç">♪</button>
<div class="edge x"></div><div class="edge y"></div>
<script>
(() => {
  'use strict';
  const canvas=document.querySelector('#screen'),ctx=canvas.getContext('2d');
  const station=document.querySelector('#station'),frequency=document.querySelector('#frequency');
  const message=document.querySelector('#message'),mainText=message.querySelector('strong'),subText=message.querySelector('span');
  const memory=[...document.querySelectorAll('#memory i')],sound=document.querySelector('#sound');
  const reduced=matchMedia('(prefers-reduced-motion: reduce)').matches;
  const channels=[
    {f:82.4,text:'BİRİ BİZİ DİNLİYOR.',code:'KAYIT 01 / AÇIK HAT'},
    {f:87.9,text:'SESİN BURAYA KADAR GELDİ.',code:'KAYIT 02 / KAYNAK YOK'},
    {f:94.6,text:'EKRANIN ÖBÜR TARAFI BOŞ DEĞİL.',code:'KAYIT 03 / GÖRÜNTÜ YOK'},
    {f:101.3,text:'BU YAYIN HİÇ BAŞLAMADI.',code:'KAYIT 04 / TARİH SİLİNDİ'},
    {f:107.6,text:'FREKANS ARTIK SENİ TANIYOR.',code:'KAYIT 05 / ALICI BULUNDU'}
  ];
  const endings=[
    ['SİNYAL KESİLDİ. SEN KALDIN.','SON KAYIT / ÇIKIŞ BULUNAMADI'],
    ['BU TARAFTA KİMSE YOK.','SON KAYIT / SES HÂLÂ AÇIK'],
    ['YAYIN ARTIK SENİNLE DEVAM EDİYOR.','SON KAYIT / KAYNAK DEĞİŞTİ']
  ];
  const clamp=(v,a=0,b=1)=>Math.max(a,Math.min(b,v)),smooth=v=>{v=clamp(v);return v*v*(3-2*v)},rand=(a,b)=>a+Math.random()*(b-a),TAU=Math.PI*2;
  let w=0,h=0,dpr=1,time=0,last=0,freq=79,target=79,nearest=-1,clarity=0;
  let drag=null,captured=[],ripples=[],sparks=[],flash=0,glitch=0,phase='search',endingStart=0,ending=0;
  let audio=null,master=null,noiseGain=null,toneGain=null,tone=null,soundOn=false;

  function resize(){w=innerWidth;h=innerHeight;dpr=Math.min(devicePixelRatio||1,1.5);canvas.width=w*dpr;canvas.height=h*dpr;ctx.setTransform(dpr,0,0,dpr,0,0)}
  function initAudio(){
    if(audio){audio.resume();return}
    audio=new (window.AudioContext||window.webkitAudioContext)();master=audio.createGain();master.gain.value=0;master.connect(audio.destination);
    const length=audio.sampleRate*2,buffer=audio.createBuffer(1,length,audio.sampleRate),data=buffer.getChannelData(0);
    for(let i=0;i<length;i++)data[i]=(Math.random()*2-1)*(.65+.35*Math.sin(i*.0017));
    const noise=audio.createBufferSource(),filter=audio.createBiquadFilter();noiseGain=audio.createGain();noise.buffer=buffer;noise.loop=true;filter.type='bandpass';filter.frequency.value=920;filter.Q.value=.62;noise.connect(filter).connect(noiseGain).connect(master);noise.start();
    tone=audio.createOscillator();toneGain=audio.createGain();tone.type='sine';tone.frequency.value=74;toneGain.gain.value=0;tone.connect(toneGain).connect(master);tone.start();
  }
  function setSound(on){soundOn=on;initAudio();master.gain.setTargetAtTime(on?.72:0,audio.currentTime,.08);sound.classList.toggle('on',on);sound.textContent=on?'♫':'♪';sound.setAttribute('aria-label',on?'Sesi kapat':'Sesi aç');sound.title=on?'Sesi kapat':'Sesi aç'}
  sound.addEventListener('pointerdown',e=>e.stopPropagation());sound.addEventListener('click',e=>{e.stopPropagation();setSound(!soundOn)});

  function tune(){
    freq+=(target-freq)*.15;
    let best=99,index=-1;
    channels.forEach((c,i)=>{const d=Math.abs(c.f-freq);if(d<best){best=d;index=i}});
    nearest=index;clarity=phase==='search'?smooth(1-best/1.65):0;
    if(drag&&best<.34)target+=(channels[index].f-target)*.075;
    frequency.firstChild.nodeValue=freq.toFixed(1).padStart(5,'0');
    if(phase==='search'&&clarity>.18){
      station.textContent=captured.includes(nearest)?'SIGNAL ARCHIVED':'CARRIER DETECTED';
      mainText.textContent=channels[nearest].text;subText.textContent=channels[nearest].code;
      message.style.opacity=String(clamp((clarity-.16)/.5)*(captured.includes(nearest)?.38:1));
    }else if(phase==='search'){
      station.textContent='NO CARRIER';message.style.opacity='0';
    }
    if(audio){noiseGain.gain.setTargetAtTime(.022+(1-clarity)*.055,audio.currentTime,.05);toneGain.gain.setTargetAtTime(soundOn?clarity*.045:0,audio.currentTime,.06);tone.frequency.setTargetAtTime(58+freq*.43,audio.currentTime,.05)}
  }

  function captureSignal(){
    if(phase!=='search'||clarity<.72||captured.includes(nearest)){glitch=Math.max(glitch,.45);return}
    captured.push(nearest);memory[captured.length-1].classList.add('on');flash=1;glitch=1;
    const cx=w/2,cy=h*.42;
    for(let i=0;i<34;i++){const a=rand(0,TAU),speed=rand(12,90);sparks.push({x:cx,y:cy,vx:Math.cos(a)*speed,vy:Math.sin(a)*speed,age:0,life:rand(.5,1.4),r:rand(.3,1.15)})}
    if(captured.length===channels.length){
      phase='ending';endingStart=time;
      const ascending=captured.every((n,i)=>i===0||captured[i-1]<n),turns=captured.slice(1).reduce((n,v,i)=>n+(v<captured[i]?1:0),0);
      ending=ascending?2:turns>2?0:1;station.textContent='TRANSMISSION CLOSED';frequency.querySelector('small').textContent='MHZ / LOCKED';
      setTimeout(()=>{mainText.textContent=endings[ending][0];subText.textContent=endings[ending][1]},520);
    }
  }

  canvas.addEventListener('pointerdown',e=>{
    initAudio();if(!soundOn)setSound(true);
    drag={id:e.pointerId,x:e.clientX,start:target,moved:false};canvas.setPointerCapture(e.pointerId);canvas.classList.add('dragging');
  });
  canvas.addEventListener('pointermove',e=>{
    if(!drag||drag.id!==e.pointerId||phase!=='search')return;
    const dx=e.clientX-drag.x;if(Math.abs(dx)>5)drag.moved=true;
    target=clamp(drag.start+dx/w*37,79,111);glitch=Math.min(1,glitch+Math.abs(dx)/w*.018);
  });
  canvas.addEventListener('pointerup',e=>{
    if(!drag||drag.id!==e.pointerId)return;
    if(!drag.moved)captureSignal();
    ripples.push({x:e.clientX,y:e.clientY,age:0});drag=null;canvas.classList.remove('dragging');
  });
  canvas.addEventListener('pointercancel',()=>{drag=null;canvas.classList.remove('dragging')});

  function line(x1,y1,x2,y2,a=.5,width=1){ctx.globalAlpha=clamp(a);ctx.lineWidth=width;ctx.beginPath();ctx.moveTo(x1,y1);ctx.lineTo(x2,y2);ctx.stroke()}
  function glyph(index,cx,cy,s,a){
    if(index<0||a<=0)return;
    ctx.save();ctx.translate(cx+(Math.random()-.5)*(1-a)*13,cy);ctx.strokeStyle='#eee';ctx.fillStyle='#eee';ctx.globalAlpha=a;
    if(index===0){
      for(let i=-17;i<=17;i++){const y=i*s*.0075,shape=(1-Math.pow(Math.abs(i)/18,1.7))*s*.11,cut=Math.sin(i*2.17+time)*s*.012;line(-shape+cut,y,shape-cut,y,a*(.38+.42*Math.sin(i*.8+time*2)**2),.7)}
    }else if(index===1){
      for(let i=0;i<6;i++){ctx.globalAlpha=a*(.18+i*.08);ctx.lineWidth=.7;ctx.beginPath();ctx.arc(0,0,s*(.045+i*.024),time*(i%2?-.13:.1)+i*.8,time*(i%2?-.13:.1)+i*.8+Math.PI*1.35);ctx.stroke()}
      ctx.globalAlpha=a;ctx.fillRect(-1,-s*.18,2,s*.36);
    }else if(index===2){
      for(let row=-12;row<=12;row++){ctx.beginPath();for(let i=-34;i<=34;i++){const x=i*s*.006,y=row*s*.009+Math.sin(i*.34+time*1.4+row*.27)*s*.012*(1-Math.abs(row)/18);i===-34?ctx.moveTo(x,y):ctx.lineTo(x,y)}ctx.globalAlpha=a*(.2+.6*(1-Math.abs(row)/15));ctx.lineWidth=.65;ctx.stroke()}
    }else if(index===3){
      for(let i=0;i<8;i++){const q=i/8,r=s*(.055+q*.16),lift=s*q*.05;ctx.globalAlpha=a*(.62-q*.055);ctx.strokeRect(-r,-r-lift,r*2,r*2)}
      line(0,-s*.25,0,s*.25,a*.7,.7);
    }else{
      for(let i=0;i<54;i++){const q=i/53,y=(q-.5)*s*.42,x=Math.sin(q*17+time*.8)*s*.035+s*.13*Math.sin(q*Math.PI*2);ctx.globalAlpha=a*(.25+.7*Math.sin(q*Math.PI));ctx.beginPath();ctx.arc(x,y,rand(.35,1.05),0,TAU);ctx.fill();line(x,y,0,y*.42,a*.07,.45)}
      for(let i=0;i<3;i++){ctx.globalAlpha=a*(.2-i*.04);ctx.beginPath();ctx.arc(0,0,s*(.06+i*.05),-1.1,1.1);ctx.stroke()}
    }
    ctx.restore();
  }

  function drawTuner(){
    const y=h-58,left=22,right=w-22,range=32;
    ctx.strokeStyle='#777';line(left,y,right,y,.14,.6);
    for(let i=0;i<=16;i++){const x=left+(right-left)*i/16;line(x,y-2,x,y+2,i%4===0?.35:.14,.6)}
    channels.forEach((c,i)=>{const x=left+(right-left)*(c.f-79)/range;ctx.fillStyle=captured.includes(i)?'#ddd':'#555';ctx.globalAlpha=captured.includes(i)?.7:.22;ctx.fillRect(x-1,y-5,2,10)});
    const x=left+(right-left)*(freq-79)/range;ctx.fillStyle='#eee';ctx.globalAlpha=.85;ctx.fillRect(x-.5,y-9,1,18);
  }

  function drawEnding(cx,cy,s,age){
    const reveal=smooth(age/2.6);message.style.opacity=String(smooth((age-.45)/1.5));
    ctx.strokeStyle='#eee';ctx.fillStyle='#eee';
    for(let i=0;i<captured.length;i++){
      const a=i*1.7+time*.045,r=s*(.035+i*.026)*reveal,x=cx+Math.cos(a)*r,y=cy+Math.sin(a)*r*.55;
      ctx.globalAlpha=.18+i*.07;ctx.beginPath();ctx.arc(x,y,1+i*.18,0,TAU);ctx.fill();line(x,y,cx,cy,.055,.5);
    }
    const breathe=1+Math.sin(time*.72)*.08;ctx.shadowColor='#fff';ctx.shadowBlur=16;ctx.globalAlpha=reveal;ctx.beginPath();ctx.arc(cx,cy,2.4*breathe,0,TAU);ctx.fill();ctx.shadowBlur=0;
    if(age>2){const q=(age-2)%4/4;ctx.globalAlpha=Math.sin(q*Math.PI)*.13;ctx.lineWidth=.6;ctx.beginPath();ctx.arc(cx,cy,s*(.025+q*.18),0,TAU);ctx.stroke()}
  }

  function draw(now){
    requestAnimationFrame(draw);const dt=last?Math.min((now-last)/1000,.05):.016;last=now;time+=dt;tune();flash=Math.max(0,flash-dt*1.8);glitch=Math.max(0,glitch-dt*.8);
    const cx=w/2,cy=h*.41,s=Math.min(w,h);
    ctx.globalAlpha=1;ctx.fillStyle='#050505';ctx.fillRect(0,0,w,h);
    const interference=phase==='search'?(1-clarity):.12;
    ctx.fillStyle='#fff';
    for(let i=0;i<55+interference*80;i++){const y=Math.random()*h,x=Math.random()*w,length=rand(2,48)*(interference+.08);ctx.globalAlpha=rand(.015,.11)*interference;ctx.fillRect(x,y,length,rand(.25,1))}
    if(!reduced)for(let y=(time*17)%5;y<h;y+=5){ctx.globalAlpha=.026;ctx.fillRect(0,y,w,1)}
    if(glitch>.05){for(let i=0;i<5;i++){const y=rand(0,h),hh=rand(1,9);ctx.globalAlpha=glitch*rand(.025,.1);ctx.fillRect(0,y,w,hh)}}
    if(phase==='search')glyph(nearest,cx,cy,s,clarity*(captured.includes(nearest)?.34:1));else drawEnding(cx,cy,s,time-endingStart);
    ctx.strokeStyle='#fff';
    ripples=ripples.filter(r=>r.age<1);for(const r of ripples){r.age+=dt;ctx.globalAlpha=(1-r.age)*.15;ctx.lineWidth=.6;ctx.beginPath();ctx.arc(r.x,r.y,r.age*s*.17,0,TAU);ctx.stroke()}
    sparks=sparks.filter(p=>p.age<p.life);for(const p of sparks){p.age+=dt;p.x+=p.vx*dt;p.y+=p.vy*dt;ctx.globalAlpha=(1-p.age/p.life)*.65;ctx.fillStyle='#fff';ctx.beginPath();ctx.arc(p.x,p.y,p.r,0,TAU);ctx.fill()}
    if(flash){ctx.globalAlpha=flash*.26;ctx.fillStyle='#fff';ctx.fillRect(0,0,w,h)}
    if(phase==='search')drawTuner();ctx.globalAlpha=1;
  }
  addEventListener('resize',resize);document.addEventListener('visibilitychange',()=>{last=0});resize();requestAnimationFrame(draw);
})();
</script>
</body>
</html>
