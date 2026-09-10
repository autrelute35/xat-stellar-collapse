<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#030303">
<title>Organizma</title>
<style>
*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:#030303;color:#eee}body{font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",Arial,sans-serif;touch-action:none;user-select:none}canvas{position:fixed;inset:0;width:100%;height:100%;display:block}#gl{z-index:0}#dust{z-index:1;pointer-events:none}#phrase{position:fixed;z-index:3;left:20px;right:20px;top:68%;text-align:center;pointer-events:none;white-space:pre-wrap;min-height:34px}#phrase span{display:inline-block;font-size:clamp(14px,4vw,20px);font-weight:300;line-height:1.7;color:#e7e7e7;letter-spacing:0;opacity:0;will-change:transform,opacity;mix-blend-mode:difference}#phrase.live span{animation:letterLife 3.2s cubic-bezier(.2,.75,.2,1) both;animation-delay:calc(var(--i)*24ms)}@keyframes letterLife{0%{opacity:0;transform:translate(var(--dx),var(--dy)) rotate(var(--rot)) scale(.75)}18%{opacity:.92;transform:translate(0,0) rotate(0) scale(1)}70%{opacity:.82;transform:translate(0,0) rotate(0) scale(1)}100%{opacity:0;transform:translate(calc(var(--dx)*-.35),calc(var(--dy)*-.35)) rotate(calc(var(--rot)*-.4)) scale(.92)}}#id{position:fixed;z-index:3;left:18px;top:max(19px,env(safe-area-inset-top));font:500 8px/1.5 ui-monospace,SFMono-Regular,Menlo,monospace;color:#5e5e5e;letter-spacing:.16em;pointer-events:none}#count{position:fixed;z-index:3;left:18px;bottom:max(24px,env(safe-area-inset-bottom));font:400 8px/1 ui-monospace,SFMono-Regular,Menlo,monospace;color:#555;font-variant-numeric:tabular-nums;pointer-events:none}#sound{position:fixed;z-index:5;right:16px;bottom:max(15px,env(safe-area-inset-bottom));width:44px;height:44px;border:0;border-radius:50%;display:grid;place-items:center;background:#05050599;color:#666;font:17px/1 sans-serif;cursor:pointer}#sound.on{color:#eee}#sound:focus-visible{outline:1px solid #999;outline-offset:2px}#flash{position:fixed;z-index:2;inset:0;background:#fff;opacity:0;pointer-events:none;mix-blend-mode:difference}@media(max-width:600px){#phrase{top:70%;left:16px;right:16px}#id,#count{left:16px}}@media(prefers-reduced-motion:reduce){#phrase.live span{animation-duration:1.8s}}
</style>
</head>
<body>
<canvas id="gl" aria-label="Dokunmaya tepki veren yaşayan dijital form" role="img"></canvas>
<canvas id="dust"></canvas>
<div id="id">SUBJECT / UNNAMED</div>
<div id="phrase" aria-live="polite"></div>
<div id="count">CONTACT 000</div>
<button id="sound" aria-label="Sesi aç" title="Sesi aç">♪</button>
<div id="flash"></div>
<script>
(() => {
  'use strict';
  const canvas=document.querySelector('#gl'),overlay=document.querySelector('#dust');
  const gl=canvas.getContext('webgl',{alpha:false,antialias:false,powerPreference:'high-performance'}),ink=overlay.getContext('2d');
  const phrase=document.querySelector('#phrase'),count=document.querySelector('#count'),sound=document.querySelector('#sound'),flashEl=document.querySelector('#flash');
  const reduced=matchMedia('(prefers-reduced-motion: reduce)').matches;
  const lines=['BANA DOKUNMA.','GEÇ KALDIN.','PARÇALAR DA HATIRLAR.','ŞEKLİMİ SEN BOZDUN.','TEKRAR BİRLEŞECEĞİM.','AYNI ŞEY DEĞİLİM.','BİZ HİÇ AYRILMADIK.','BURADA BİR ŞEY UYANDI.','ELİNİN İZİ HÂLÂ ÜZERİMDE.'];
  const clamp=(v,a=0,b=1)=>Math.max(a,Math.min(b,v)),rand=(a,b)=>a+Math.random()*(b-a),TAU=Math.PI*2;
  let w=0,h=0,dpr=1,time=0,last=0,touches=0,pointer={x:0,y:0,down:false},particles=[],shock=0,invert=0;
  let audio=null,master=null,drone=null,soundOn=false;
  const bodies=Array.from({length:11},(_,i)=>({active:i===0,x:0,y:0,vx:0,vy:0,r:i===0?.215:0,base:i===0?.215:0,born:0,returnAt:0,phase:rand(0,TAU)}));

  if(!gl){document.querySelector('#id').textContent='SUBJECT / ASLEEP';phrase.textContent='BU EKRAN UYANMADI.';return}
  const vertex=`attribute vec2 p;void main(){gl_Position=vec4(p,0.,1.);}`;
  const fragment=`
    precision highp float;
    uniform vec2 res;
    uniform float t;
    uniform float impact;
    uniform float inverse;
    uniform vec4 balls[12];
    float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
    void main(){
      vec2 uv=gl_FragCoord.xy/res.xy;
      vec2 p=(uv-.5)*vec2(res.x/res.y,1.);
      float field=0.;vec2 grad=vec2(0.);
      for(int i=0;i<12;i++){
        vec2 d=p-balls[i].xy;float rr=balls[i].z*balls[i].z;float q=max(dot(d,d),.00018);
        field+=rr/q;grad+=(-2.*rr*d)/(q*q);
      }
      float body=smoothstep(.92,1.045,field),rim=exp(-abs(field-1.)*8.5);
      vec3 n=normalize(vec3(grad*.012,1.));
      float key=max(0.,dot(n,normalize(vec3(-.55,.7,.8))));
      float side=max(0.,dot(n,normalize(vec3(.75,-.25,.55))));
      float bands=.5+.5*sin((n.y*.72+n.x*.35+p.y*.42+t*.025)*31.);
      bands=smoothstep(.18,.92,bands);
      float chrome=.055+key*.72+side*.2+bands*.2;
      chrome*=.78+.22*sin(field*2.3+t*.7);
      float grain=(hash(gl_FragCoord.xy+floor(t*24.))-.5)*.035;
      float aura=smoothstep(.3,1.,field)*.055*(1.-body);
      vec3 col=vec3(grain*.22+aura);
      col=mix(col,vec3(chrome+grain),body);
      col+=vec3(rim*(.2+impact*.5));
      float halo=exp(-length(p)*2.7)*.012;
      col+=halo;
      col=mix(col,1.-col,inverse);
      gl_FragColor=vec4(col,1.);
    }`;
  function shader(type,source){const s=gl.createShader(type);gl.shaderSource(s,source);gl.compileShader(s);if(!gl.getShaderParameter(s,gl.COMPILE_STATUS))throw Error(gl.getShaderInfoLog(s));return s}
  const program=gl.createProgram();gl.attachShader(program,shader(gl.VERTEX_SHADER,vertex));gl.attachShader(program,shader(gl.FRAGMENT_SHADER,fragment));gl.linkProgram(program);if(!gl.getProgramParameter(program,gl.LINK_STATUS))throw Error(gl.getProgramInfoLog(program));gl.useProgram(program);
  const buffer=gl.createBuffer();gl.bindBuffer(gl.ARRAY_BUFFER,buffer);gl.bufferData(gl.ARRAY_BUFFER,new Float32Array([-1,-1,1,-1,-1,1,-1,1,1,-1,1,1]),gl.STATIC_DRAW);
  const pos=gl.getAttribLocation(program,'p');gl.enableVertexAttribArray(pos);gl.vertexAttribPointer(pos,2,gl.FLOAT,false,0,0);
  const uRes=gl.getUniformLocation(program,'res'),uTime=gl.getUniformLocation(program,'t'),uBalls=gl.getUniformLocation(program,'balls'),uImpact=gl.getUniformLocation(program,'impact'),uInverse=gl.getUniformLocation(program,'inverse');

  function resize(){w=innerWidth;h=innerHeight;dpr=Math.min(devicePixelRatio||1,1.5);for(const c of [canvas,overlay]){c.width=w*dpr;c.height=h*dpr;c.style.width=w+'px';c.style.height=h+'px'}gl.viewport(0,0,canvas.width,canvas.height);ink.setTransform(dpr,0,0,dpr,0,0)}
  function coords(x,y){return {x:(x/w-.5)*(w/h),y:.5-y/h}}
  function showLine(text){
    phrase.classList.remove('live');phrase.replaceChildren();
    [...text].forEach((letter,i)=>{const s=document.createElement('span');s.textContent=letter;s.style.setProperty('--i',i);s.style.setProperty('--dx',rand(-22,22).toFixed(1)+'px');s.style.setProperty('--dy',rand(-15,15).toFixed(1)+'px');s.style.setProperty('--rot',rand(-12,12).toFixed(1)+'deg');phrase.appendChild(s)});
    void phrase.offsetWidth;phrase.classList.add('live');
  }
  function initAudio(){
    if(audio){audio.resume();return}
    audio=new (window.AudioContext||window.webkitAudioContext)();master=audio.createGain();master.gain.value=0;master.connect(audio.destination);
    const filter=audio.createBiquadFilter();filter.type='lowpass';filter.frequency.value=160;filter.Q.value=1.4;filter.connect(master);
    [41,61.5].forEach((f,i)=>{const o=audio.createOscillator(),g=audio.createGain();o.type=i?'sine':'triangle';o.frequency.value=f;g.gain.value=i?.025:.018;o.connect(g).connect(filter);o.start()});
    drone=filter;
  }
  function setSound(on){soundOn=on;initAudio();master.gain.setTargetAtTime(on?.72:0,audio.currentTime,.08);sound.classList.toggle('on',on);sound.textContent=on?'♫':'♪';sound.setAttribute('aria-label',on?'Sesi kapat':'Sesi aç');sound.title=on?'Sesi kapat':'Sesi aç'}
  function note(n){if(!audio||!soundOn)return;const o=audio.createOscillator(),g=audio.createGain();o.type=n%2?'triangle':'sine';o.frequency.value=[110,138.6,164.8,220,277.2][n%5];g.gain.setValueAtTime(.0001,audio.currentTime);g.gain.exponentialRampToValueAtTime(.08,audio.currentTime+.012);g.gain.exponentialRampToValueAtTime(.0001,audio.currentTime+.65);o.connect(g).connect(master);o.start();o.stop(audio.currentTime+.7)}
  sound.addEventListener('pointerdown',e=>e.stopPropagation());sound.addEventListener('click',e=>{e.stopPropagation();setSound(!soundOn)});

  function split(at){
    touches++;count.textContent='CONTACT '+String(touches).padStart(3,'0');showLine(lines[(touches-1)%lines.length]);note(touches);shock=1;
    const core=bodies[0],dx=at.x-core.x,dy=at.y-core.y,base=Math.atan2(dy,dx);
    core.r=Math.max(.15,core.r-.018);
    for(let n=0;n<3;n++){
      let b=bodies.slice(1).find(x=>!x.active)||bodies[1+(touches*3+n)%10],a=base+(n-1)*.72+rand(-.2,.2),speed=rand(.18,.34);
      b.active=true;b.x=core.x+Math.cos(a)*.025;b.y=core.y+Math.sin(a)*.025;b.vx=Math.cos(a)*speed+dx*.16;b.vy=Math.sin(a)*speed+dy*.16;b.r=b.base=rand(.045,.075);b.born=time;b.returnAt=time+rand(1.25,2.5);b.phase=rand(0,TAU);
    }
    const px=(at.x/(w/h)+.5)*w,py=(.5-at.y)*h;
    for(let i=0;i<34;i++){const a=rand(0,TAU),v=rand(18,105);particles.push({x:px,y:py,vx:Math.cos(a)*v,vy:Math.sin(a)*v,age:0,life:rand(.7,1.6),r:rand(.35,1.2),turn:rand(.8,1.4)})}
    if(touches%7===0){invert=1;flashEl.animate([{opacity:.7},{opacity:0}],{duration:650,easing:'ease-out'});for(let i=1;i<bodies.length;i++)if(bodies[i].active){const a=i/10*TAU;bodies[i].vx+=Math.cos(a)*.28;bodies[i].vy+=Math.sin(a)*.28;bodies[i].returnAt=time+2.8}}
  }
  function pointerDown(e){initAudio();if(!soundOn)setSound(true);pointer.down=true;pointer=Object.assign(pointer,coords(e.clientX,e.clientY));canvas.setPointerCapture(e.pointerId);split(pointer)}
  function pointerMove(e){if(!pointer.down)return;pointer=Object.assign(pointer,coords(e.clientX,e.clientY));if(Math.random()<.17)particles.push({x:e.clientX,y:e.clientY,vx:rand(-8,8),vy:rand(-8,8),age:0,life:rand(.35,.8),r:rand(.3,.8),turn:1})}
  canvas.addEventListener('pointerdown',pointerDown);canvas.addEventListener('pointermove',pointerMove);canvas.addEventListener('pointerup',()=>pointer.down=false);canvas.addEventListener('pointercancel',()=>pointer.down=false);addEventListener('blur',()=>pointer.down=false);

  function physics(dt){
    const core=bodies[0],homeX=(pointer.down?pointer.x*.18:Math.sin(time*.37)*.018),homeY=(pointer.down?pointer.y*.14:Math.cos(time*.31)*.014);
    core.vx+=(homeX-core.x)*dt*3.2;core.vy+=(homeY-core.y)*dt*3.2;core.vx*=Math.pow(.18,dt);core.vy*=Math.pow(.18,dt);core.x+=core.vx*dt;core.y+=core.vy*dt;core.r+=(core.base-core.r)*dt*.75;
    for(let i=1;i<bodies.length;i++){
      const b=bodies[i];if(!b.active)continue;
      if(time>b.returnAt){const dx=core.x-b.x,dy=core.y-b.y;b.vx+=dx*dt*2.25;b.vy+=dy*dt*2.25;b.vx*=Math.pow(.32,dt);b.vy*=Math.pow(.32,dt);if(Math.hypot(dx,dy)<.026&&time-b.returnAt>.35){b.active=false;b.r=0;core.r=Math.min(.235,core.r+b.base*.13);continue}}
      else{b.vx+=Math.cos(time*.8+b.phase)*dt*.006;b.vy+=Math.sin(time*.7+b.phase)*dt*.006;b.vx*=Math.pow(.7,dt);b.vy*=Math.pow(.7,dt)}
      b.x+=b.vx*dt;b.y+=b.vy*dt;b.r=b.base*(.94+.06*Math.sin(time*1.6+b.phase));
    }
    shock=Math.max(0,shock-dt*1.45);invert=Math.max(0,invert-dt*.72);
  }
  function drawDust(dt){
    ink.clearRect(0,0,w,h);ink.fillStyle='#fff';ink.strokeStyle='#fff';particles=particles.filter(p=>p.age<p.life);
    const coreX=(bodies[0].x/(w/h)+.5)*w,coreY=(.5-bodies[0].y)*h;
    for(const p of particles){p.age+=dt;const q=p.age/p.life;if(q>.52){p.vx+=(coreX-p.x)*dt*p.turn*.8;p.vy+=(coreY-p.y)*dt*p.turn*.8}p.x+=p.vx*dt;p.y+=p.vy*dt;p.vx*=Math.pow(.4,dt);p.vy*=Math.pow(.4,dt);ink.globalAlpha=(1-q)*.6;ink.beginPath();ink.arc(p.x,p.y,p.r*(1-q*.4),0,TAU);ink.fill()}
    ink.globalAlpha=1;
  }
  function render(now){
    requestAnimationFrame(render);const dt=last?Math.min((now-last)/1000,.04):.016;last=now;time+=dt;physics(reduced?Math.min(dt,.01):dt);drawDust(dt);
    const packed=new Float32Array(48);for(let i=0;i<11;i++){const b=bodies[i];packed.set([b.active?b.x:9,b.active?b.y:9,b.active?b.r:0,0],i*4)}
    const finger=pointer.down?Math.min(.06,.025+Math.hypot(pointer.x-bodies[0].x,pointer.y-bodies[0].y)*.04):0;packed.set([pointer.x,pointer.y,finger,0],44);
    gl.uniform2f(uRes,canvas.width,canvas.height);gl.uniform1f(uTime,time);gl.uniform1f(uImpact,shock);gl.uniform1f(uInverse,clamp(invert));gl.uniform4fv(uBalls,packed);gl.drawArrays(gl.TRIANGLES,0,6);
  }
  addEventListener('resize',resize);document.addEventListener('visibilitychange',()=>last=0);resize();requestAnimationFrame(render);
})();
</script>
</body>
</html>
