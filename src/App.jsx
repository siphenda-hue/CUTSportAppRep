import React, { useEffect, useRef, useState } from 'react';
import { Link, Route, Routes, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Bell, CalendarDays, ChevronRight, ClipboardList, FileText, Handshake, LogOut, MapPin, Newspaper, Package, ShieldCheck, ShoppingBag, Ticket, Trophy, Users, CalendarClock, Settings2 } from 'lucide-react';
import BottomNav from './components/BottomNav';
import { api, money, dateLabel } from './lib/api';
import { supabase } from './lib/supabase';

const fallback = ['Athletics & Cross Country','Basketball','Cheerleading','Cricket','E-Sport','Football','Golf','Hockey','Netball','Rugby','Volleyball'].map((name,i)=>({id:String(i),name,slug:name.toLowerCase().replaceAll(' ','-')}));
function Empty({title,body}) { return <div className="empty"><Trophy/><b>{title}</b><p>{body}</p></div>; }
function Header({title='CUT Sport',back=false}) { const nav=useNavigate(); return <header className="topbar">{back?<button className="icon-btn" onClick={()=>nav(-1)}><ArrowLeft/></button>:<Link className="brand-mark" to="/"><b>CUT</b><small>SPORT</small></Link>}<div className="topbar-title"><b>{title}</b><small>HERITAGE · CULTURE · COMMUNITY</small></div><Link className="icon-btn" to="/notifications"><Bell/></Link></header>; }
function Section({title,children,link}) { return <section className="section"><div className="section-head"><h2>{title}</h2>{link&&<Link to={link}>View all <ChevronRight size={15}/></Link>}</div>{children}</section>; }
function App() {
 const [sports,setSports]=useState(fallback),[teams,setTeams]=useState([]),[competitions,setCompetitions]=useState([]),[products,setProducts]=useState([]),[fixtures,setFixtures]=useState([]),[articles,setArticles]=useState([]),[events,setEvents]=useState([]),[ticketTypes,setTicketTypes]=useState([]),[sponsors,setSponsors]=useState([]),[athletes,setAthletes]=useState([]);
 const [user,setUser]=useState(null),[profile,setProfile]=useState(null),[roles,setRoles]=useState([]),[cart,setCart]=useState(()=>{try{return JSON.parse(localStorage.getItem('cut-cart')||'[]')}catch{return []}}),[toast,setToast]=useState('');
 useEffect(()=>{Promise.all([api.sports(),api.teams(),api.competitions(),api.products(),api.fixtures(),api.articles(),api.events(),api.ticketTypes(),api.sponsors(),api.athletes()]).then(([s,t,c,p,f,a,e,tt,sp,ath])=>{if(s.data?.length)setSports(s.data);setTeams(t.data||[]);setCompetitions(c.data||[]);setProducts(p.data||[]);setFixtures(f.data||[]);setArticles(a.data||[]);setEvents(e.data||[]);setTicketTypes(tt.data||[]);setSponsors(sp.data||[]);setAthletes(ath.data||[])})},[]);
 useEffect(()=>{localStorage.setItem('cut-cart',JSON.stringify(cart))},[cart]);
 useEffect(()=>{if(!supabase)return;supabase.auth.getSession().then(({data})=>setUser(data.session?.user||null));const {data:{subscription}}=supabase.auth.onAuthStateChange((_e,session)=>setUser(session?.user||null));return()=>subscription.unsubscribe()},[]);
 useEffect(()=>{if(!user){setProfile(null);setRoles([]);return}Promise.all([api.profile(user.id),api.roles(user.id)]).then(([p,r])=>{setProfile(p.data);setRoles((r.data||[]).map(x=>x.role))})},[user]);
 const add=p=>{setCart(old=>{const found=old.find(x=>x.id===p.id);return found?old.map(x=>x.id===p.id?{...x,qty:x.qty+1}:x):[...old,{id:p.id,name:p.name,price_cents:p.price_cents,image_url:p.image_url,qty:1}]});setToast('Added to your bag');setTimeout(()=>setToast(''),2200)};
 const common={sports,teams,competitions,products,fixtures,articles,events,ticketTypes,sponsors,athletes,user,profile,roles,cart,setCart,add};
 return <div className="app-shell"><div className="app-frame"><Routes>
 <Route path="/" element={<Home {...common}/>}/><Route path="/shop" element={<Shop {...common}/>}/><Route path="/shop/:slug" element={<Product {...common}/>}/><Route path="/cart" element={<Cart {...common}/>}/><Route path="/checkout" element={<Checkout cart={cart} setCart={setCart} user={user}/>}/><Route path="/payment/:result" element={<PaymentReturn user={user} result="success" cart={cart} setCart={setCart}/>}/><Route path="/events/:id" element={<EventTickets events={events} ticketTypes={ticketTypes} user={user}/>}/><Route path="/sport" element={<Sport {...common}/>}/><Route path="/sport/:slug" element={<Hub {...common}/>}/><Route path="/news" element={<News {...common}/>}/><Route path="/news/:slug" element={<Story {...common}/>}/><Route path="/sponsors" element={<Sponsors {...common}/>}/><Route path="/profile" element={<Profile {...common}/>}/><Route path="/admin" element={<AdminDashboard {...common}/>}/><Route path="/admin/sports" element={<AdminSports roles={roles} user={user} setSports={setSports}/>}/><Route path="/admin/sponsors" element={<AdminSponsors user={user} roles={roles}/>}/><Route path="/admin/products" element={<AdminProducts roles={roles} products={products} setProducts={setProducts}/>}/><Route path="/admin/shop-orders" element={<AdminShopOrders roles={roles}/>}/><Route path="/admin/athletes" element={<AdminAthletes roles={roles}/>}/><Route path="/admin/performance" element={<AdminPerformance roles={roles}/>}/><Route path="/admin/operations" element={<AdminOperations roles={roles} user={user}/>}/><Route path="/admin/approvals" element={<AdminApprovals roles={roles} user={user}/>}/><Route path="/admin/ticket-gate" element={<AdminTicketGate roles={roles}/>}/><Route path="/admin/event-reports" element={<AdminEventReports roles={roles}/>}/><Route path="/admin/editorial" element={<AdminEditorial roles={roles} user={user} sports={sports}/>}/><Route path="/notifications" element={<Personal title="Notifications" user={user} kind="notifications"/>}/><Route path="/tickets" element={<Personal title="My tickets" user={user} kind="tickets"/>}/><Route path="/orders" element={<Personal title="My orders" user={user} kind="orders"/>}/><Route path="*" element={<Home {...common}/>}/>
 </Routes><BottomNav/><Link className="cart-fab" to="/cart"><ShoppingBag size={18}/>{cart.reduce((n,x)=>n+x.qty,0)>0&&<span>{cart.reduce((n,x)=>n+x.qty,0)}</span>}</Link>{toast&&<div className="toast">{toast}</div>}</div></div>;
}
function Home({sports,products,fixtures,articles,events,sponsors}) {
 const upcoming=fixtures.filter(x=>['scheduled','live'].includes(x.status)).slice(0,3);
 return <><Header/><main className="page"><section className="hero"><span className="eyebrow">THE BLUES · CUT SPORT</span><h1>ONE CAMPUS.<br/><em>ONE TEAM.</em><br/>ONE BLUE.</h1><p>Every athlete. Every story. Every moment.</p><Link className="btn light" to="/sport">Explore CUT Sport <ChevronRight/></Link></section><div className="quick-links"><Link to="/sport"><Trophy/>Sport</Link><Link to="/shop"><ShoppingBag/>Shop</Link><Link to="/tickets"><Ticket/>Tickets</Link><Link to="/news"><Newspaper/>News</Link></div>
 <Section title="Sport codes" link="/sport"><div className="sport-grid">{sports.map((s,i)=><Link className="sport-tile" to={'/sport/'+s.slug} key={s.id}><small>{String(i+1).padStart(2,'0')}</small><b>{s.name}</b><ChevronRight/></Link>)}</div></Section>
 <Section title="Matchday" link="/sport">{upcoming.length?upcoming.map(f=><Fixture key={f.id} f={f}/>):<Empty title="Fixtures coming soon" body="Official fixtures and live scores will appear here when published by CUT Sport."/>}</Section>
 <Section title="Heritage Collection" link="/shop"><div className="catalogue">{products.slice(0,4).map(p=><ProductCard key={p.id} p={p}/>)}</div>{!products.length&&<Empty title="The shop is being stocked" body="The official collection will appear here soon."/>}</Section>
 <Section title="Latest stories" link="/news">{articles.length?articles.slice(0,3).map(a=><StoryCard key={a.id} a={a}/>):<Empty title="No stories published yet" body="News, results and athlete stories will appear here."/>}</Section>
 <Section title="Upcoming events">{events.length?events.map(e=><div className="event-card" key={e.id}><b>{e.title}</b><p>{dateLabel(e.starts_at)} · {e.venue||'Venue TBC'}</p>{e.ticketed&&<Link to={"/events/"+e.id}>View tickets <ChevronRight size={15}/></Link>}</div>):<Empty title="No events announced" body="Watch this space for CUT Sport events."/>}</Section>
 <Section title="Our partners" link="/sponsors">{sponsors.length?sponsors.map(s=><div className="sponsor-card" key={s.id}>{s.name}</div>):<p className="muted">Official partner profiles will be published here.</p>}</Section><footer className="footer"><b>CUT SPORT</b><small>Central University of Technology · Free State</small></footer></main></>;
}
function Fixture({f}) {return <div className="fixture-card"><div className="fixture-meta"><span>{f.sports?.name||'CUT Sport'}</span><span>{f.status}</span></div><div className="fixture-teams"><b>{f.teams?.name||'CUT'}</b><strong>{f.status==='completed'?String(f.home_score??0)+' – '+String(f.away_score??0):'VS'}</strong><b>{f.opponent}</b></div><div className="fixture-foot"><span><CalendarDays size={14}/>{dateLabel(f.starts_at)}</span><span><MapPin size={14}/>{f.venue||'Venue TBC'}</span></div></div>}
function ProductCard({p}) {return <Link to={'/shop/'+p.slug} className="product-card"><div className="product-image">{p.image_url?<img src={p.image_url} alt={p.name}/>:<ShoppingBag/>}</div><b>{p.name}</b><span>{money(p.price_cents)}</span></Link>}
function StoryCard({a}) {return <Link to={'/news/'+a.slug} className="story-card">{a.cover_image_url&&<img src={a.cover_image_url} alt=""/>}<div><small>{a.sports?.name||'CUT SPORT'} · {dateLabel(a.published_at)}</small><b>{a.title}</b><p>{a.excerpt}</p></div></Link>}
function Shop({products}) {return <><Header title="Heritage Collection"/><main className="page"><h1>Shop CUT Sport.</h1>{products.length?<div className="catalogue">{products.map(p=><ProductCard key={p.id} p={p}/>)}</div>:<Empty title="The shop is being stocked" body="Products will appear when the official catalogue is published."/>}</main></>}
function Product({products,add}) {const {slug}=useParams();const p=products.find(x=>x.slug===slug);return <><Header title="Product" back/><main className="page">{p?<div className="product-detail">{p.image_url&&<img src={p.image_url} alt={p.name}/>}<h1>{p.name}</h1><h2>{money(p.price_cents)}</h2><p>{p.description}</p><button className="btn primary" onClick={()=>add(p)}>Add to bag</button></div>:<Empty title="Product not found" body="This product is not currently available."/>}</main></>}
function Cart({cart,setCart}) {const total=cart.reduce((n,x)=>n+x.price_cents*x.qty,0);return <><Header title="Your bag" back/><main className="page"><h1>Shopping bag</h1>{cart.length?cart.map(x=><div className="cart-row" key={x.id}><b>{x.name}</b><span>{money(x.price_cents)} × {x.qty}</span><button onClick={()=>setCart(c=>c.map(y=>y.id===x.id?{...y,qty:y.qty-1}:y).filter(y=>y.qty>0))}>−</button><button onClick={()=>setCart(c=>c.map(y=>y.id===x.id?{...y,qty:y.qty+1}:y))}>+</button></div>):<Empty title="Your bag is empty" body="Explore the Heritage Collection to add an item."/>}{cart.length>0&&<><h2>Total {money(total)}</h2><Link className="btn primary" to="/checkout">Continue to checkout</Link></>}</main></>}
function Checkout({cart,setCart,user}) {
 const [busy,setBusy]=useState(false),[error,setError]=useState("");
 const total=cart.reduce((n,x)=>n+x.price_cents*x.qty,0);
 async function pay(){if(!user){setError("Sign in before checkout.");return}if(!cart.length)return;if(!supabase){setError("Payment service is unavailable.");return}setBusy(true);setError("");const {data,error:invokeError}=await supabase.functions.invoke("yoco-checkout",{body:{orderKind:"shop",requestId:crypto.randomUUID(),lines:cart.map(x=>({product_id:x.id,quantity:x.qty}))}});if(invokeError||data?.error){setError(data?.error||invokeError?.message||"Unable to start checkout.");setBusy(false);return}if(!data?.redirectUrl){setError("Yoco did not return a checkout link.");setBusy(false);return}window.location.assign(data.redirectUrl);}
 return <><Header title="Secure checkout" back/><main className="page"><div className="page-intro"><span className="eyebrow">YOCO SECURE CHECKOUT</span><h1>Review your order.</h1><p>Your payment is handled on Yoco’s secure hosted checkout. CUT Sport never receives or stores your card details.</p></div>{!user?<><Empty title="Sign in to continue" body="Your order will be linked to your CUT Sport account."/><Link className="btn primary" to="/profile">Sign in</Link></>:cart.length? <><Section title="Order summary">{cart.map(x=><div className="cart-row" key={x.id}><b>{x.name}</b><span>{x.qty} × {money(x.price_cents)}</span></div>)}</Section><h2>Total {money(total)}</h2><button className="btn primary" disabled={busy||total<200} onClick={pay}>{busy?"Preparing secure checkout…":"Continue to Yoco"}</button>{total<200&&<p className="muted">Yoco card checkout has a minimum payment of R2.00.</p>}</>:<Empty title="Your bag is empty" body="Add items from the Heritage Collection before checking out."/>}{error&&<p className="form-error">{error}</p>}</main></>;
}
function PaymentReturn({user,result,cart,setCart}) {
 const [params]=useSearchParams(),route=useParams(),[order,setOrder]=useState(null),[error,setError]=useState("");
 const orderNumber=params.get("order");
 useEffect(()=>{\n  let active=true,attempts=0,timer=null;\n  if(!user||!orderNumber||!supabase){setOrder(null);return}\n  const load=async()=>{\n   const {data,error}=await supabase.from("orders").select("order_number,status,payment_status,total_cents,currency").eq("user_id",user.id).eq("order_number",orderNumber).maybeSingle();\n   if(!active)return;\n   if(error)setError(error.message);\n   else{\n    setOrder(data);\n    if(data?.payment_status==="succeeded"){setError("");setCart([]);return}\n   }\n   attempts+=1;\n   if(active&&attempts<24)timer=setTimeout(load,2500);\n  };\n  load();\n  return()=>{active=false;if(timer)clearTimeout(timer)};\n },[user,orderNumber,setCart]);
 const paid=order?.payment_status==="succeeded";
 return <><Header title="Payment status" back/><main className="page"><div className="page-intro"><span className="eyebrow">YOCO PAYMENT</span><h1>{paid?"Payment confirmed":(route.result||result)==="cancelled"?"Checkout cancelled":(route.result||result)==="failed"?"Payment not completed":"Confirming your payment"}</h1><p>{paid?"Your payment has been verified. Your order is now recorded in CUT Sport.":(route.result||result)==="cancelled"?"You left the Yoco checkout. If you completed payment before returning, allow the secure notification to update your order.":(route.result||result)==="failed"?"The checkout did not complete. If your bank shows a debit, do not pay again until the order status has been checked.":"Yoco sends a signed notification to confirm payment. This return page is not itself proof of payment."}</p></div>{order&&<div className="personal-card"><b>Order {order.order_number}</b><p>{money(order.total_cents)} · {order.payment_status||order.status}</p></div>}{!orderNumber&&<p className="muted">No order reference was supplied.</p>}{error&&<p className="form-error">{error}</p>}<Link className="btn primary" to="/orders">View my orders</Link></main></>;
}
function EventTickets({events,ticketTypes,user}) {
 const {id}=useParams(),nav=useNavigate(),[quantity,setQuantity]=useState(1),[typeId,setTypeId]=useState(""),[busy,setBusy]=useState(false),[error,setError]=useState("");
 const event=events.find(x=>x.id===id),options=ticketTypes.filter(x=>x.event_id===id&&x.quantity_available>0),selected=options.find(x=>x.id===(typeId||options[0]?.id));
 useEffect(()=>{if(options.length&&!options.some(x=>x.id===typeId))setTypeId(options[0].id)},[id,options.map(x=>x.id).join("|")]);
 async function buy(){if(!user){nav("/profile");return}if(!selected||!supabase)return;setBusy(true);setError("");const {data,error:invokeError}=await supabase.functions.invoke("yoco-checkout",{body:{orderKind:"event",requestId:crypto.randomUUID(),lines:[{ticket_type_id:selected.id,quantity:Number(quantity)}]}});if(invokeError||data?.error){setError(data?.error||invokeError?.message||"Unable to start ticket checkout.");setBusy(false);return}if(data?.redirectUrl)window.location.assign(data.redirectUrl);else{setError("Yoco did not return a checkout link.");setBusy(false)}}
 if(!event)return <><Header title="Event tickets" back/><main className="page"><Empty title="Event not found" body="This event may no longer be available."/></main></>;
 return <><Header title="Event tickets" back/><main className="page"><div className="page-intro"><span className="eyebrow">CUT SPORT · EVENT ACCESS</span><h1>{event.title}</h1><p>{dateLabel(event.starts_at)} · {event.venue||"Venue TBC"}</p></div>{options.length? <div className="form-card"><label>Ticket type<select value={selected?.id||""} onChange={e=>setTypeId(e.target.value)}>{options.map(x=><option key={x.id} value={x.id}>{x.name} · {money(x.price_cents)} · {x.quantity_available} available</option>)}</select></label><label>Quantity<input type="number" min="1" max={Math.min(selected?.max_per_order||1,selected?.quantity_available||1)} value={quantity} onChange={e=>setQuantity(Math.max(1,Math.min(Number(e.target.value)||1,selected?.max_per_order||1,selected?.quantity_available||1)))}/></label><h2>Total {money((selected?.price_cents||0)*quantity)}</h2><button className="btn primary" disabled={busy||!selected} onClick={buy}>{busy?"Preparing Yoco checkout…":"Buy tickets with Yoco"}</button>{error&&<p className="form-error">{error}</p>}</div>:<Empty title="Tickets are not on sale" body="Ticket types will appear here once CUT Sport publishes them."/>}</main></>;
}
function Sport({sports,fixtures}) {return <><Header title="Sport Updates"/><main className="page"><h1>Follow the action.</h1><div className="sport-grid">{sports.map(s=><Link className="sport-tile" to={'/sport/'+s.slug} key={s.id}>{s.name}<ChevronRight/></Link>)}</div><Section title="Fixtures & results">{fixtures.length?fixtures.map(f=><Fixture f={f} key={f.id}/>):<Empty title="Fixtures coming soon" body="Official match information will appear here when released."/>}</Section></main></>}
function Hub({sports,teams,competitions,fixtures,articles,athletes}) {const {slug}=useParams();const s=sports.find(x=>x.slug===slug),ts=teams.filter(t=>t.sport_id===s?.id),cs=competitions.filter(c=>c.sport_id===s?.id),fs=fixtures.filter(f=>f.sport_id===s?.id),as=articles.filter(a=>a.sport_id===s?.id),players=athletes.filter(a=>a.sport_id===s?.id);return <><Header title={s?.name||'Sport hub'} back/><main className="page">{s?<><h1>{s.name}</h1><p>{s.description||'Follow teams, fixtures and stories from this CUT Sport code.'}</p><Section title="Competitions">{cs.length?cs.map(c=><article className="competition-card" key={c.id}><div><b>{c.name}</b><small>{[c.season,c.status].filter(Boolean).join(' · ')}</small></div><p>{c.description||'Official competition information.'}</p><small>{c.start_date?dateLabel(c.start_date):'Start date TBC'}{c.end_date?` – ${dateLabel(c.end_date)}`:''}{c.venue?` · ${c.venue}`:''}</small></article>):<Empty title="Competition details coming soon" body="Official competition names, dates and venues will appear here when published."/>}</Section><Section title="Teams & squads">{ts.length?<div className="team-grid">{ts.map(t=><article className="team-card" key={t.id}>{t.image_url&&<img src={t.image_url} alt=""/>}<div><b>{t.name}</b><small>{[t.category,t.season].filter(Boolean).join(' · ')||'CUT Sport team'}</small>{t.coach_name&&<small>Coach: {t.coach_name}</small>}<small>{players.filter(a=>a.team_id===t.id).length} approved athlete profiles</small></div></article>)}</div>:<Empty title="Team details coming soon" body="Official team names and squad information will appear here when published by CUT Sport staff."/>}</Section><Section title="Athletes & squads">{players.length?<div className="athlete-grid">{players.map(a=><div className="athlete-card" key={a.id}>{a.photo_url?<img src={a.photo_url} alt={a.full_name}/>:<div className="athlete-avatar">{(a.preferred_name||a.full_name).slice(0,1)}</div>}<div><b>{a.preferred_name||a.full_name}</b><small>{a.position||"CUT athlete"}{a.squad_number?` · #${a.squad_number}`:""}</small>{a.teams?.name&&<small>{a.teams.name}</small>}</div></div>)}</div>:<Empty title="Squad information coming soon" body="Approved athlete profiles will appear here once published by CUT Sport staff."/>}</Section><Section title="Fixtures">{fs.length?fs.map(f=><Fixture key={f.id} f={f}/>):<Empty title="No verified fixtures yet" body="Fixture details will be added by CUT Sport staff."/>}</Section><Section title="News & highlights">{as.length?as.map(a=><StoryCard key={a.id} a={a}/>):<Empty title="No stories published" body="New stories will appear here."/>}</Section></>:<Empty title="Sport code not found" body="Choose a sport from the Sport Updates page."/>}</main></>}
function News({articles}) {return <><Header title="Articles & news"/><main className="page"><h1>Stories that move us.</h1>{articles.length?articles.map(a=><StoryCard key={a.id} a={a}/>):<Empty title="No stories published yet" body="The latest CUT Sport news will appear here."/>}</main></>}
function Story({articles}) {const {slug}=useParams();const a=articles.find(x=>x.slug===slug);return <><Header title="Article" back/><main className="page">{a?<article><small>{dateLabel(a.published_at)}</small><h1>{a.title}</h1>{a.cover_image_url&&<img className="article-cover" src={a.cover_image_url} alt=""/>}<p>{a.excerpt}</p><div className="article-body">{a.body}</div></article>:<Empty title="Story not found" body="This story is no longer available."/>}</main></>}
function Sponsors({sponsors}) {return <><Header title="Our sponsors" back/><main className="page"><h1>Stronger together.</h1>{sponsors.length?sponsors.map(s=><div className="sponsor-card" key={s.id}><b>{s.name}</b><p>{s.description}</p>{s.website_url&&<a href={s.website_url} target="_blank" rel="noreferrer">Visit partner</a>}</div>):<Empty title="Partner directory coming soon" body="Official sponsor profiles will be published here."/>}</main></>}
function Profile({user,profile,roles}) {const [mode,setMode]=useState('login'),[email,setEmail]=useState(''),[password,setPassword]=useState(''),[name,setName]=useState(profile?.full_name||''),[message,setMessage]=useState('');useEffect(()=>setName(profile?.full_name||''),[profile]);async function submit(e){e.preventDefault();if(!supabase){setMessage('Connect Supabase environment variables first.');return}const r=mode==='login'?await supabase.auth.signInWithPassword({email,password}):await supabase.auth.signUp({email,password,options:{data:{full_name:name}}});setMessage(r.error?.message||'Request submitted. Check your email if confirmation is required.')}async function save(e){e.preventDefault();const {error}=await supabase.from('profiles').upsert({id:user.id,full_name:name,email:user.email},{onConflict:'id'});setMessage(error?.message||'Profile updated.')}return <><Header title="Profile"/><main className="page">{user?<><h1>{profile?.full_name||user.email}</h1><form className="form-card" onSubmit={save}><label>Full name<input value={name} onChange={e=>setName(e.target.value)}/></label><label>Email<input value={user.email||''} disabled/></label><button className="btn primary">Save profile</button></form><div className="account-links"><Link to="/orders"><Package/> My orders</Link><Link to="/tickets"><Ticket/> My tickets</Link><Link to="/notifications"><Bell/> Notifications</Link>{roles.some(r=>["sport_admin","super_admin","coach","shop_admin"].includes(r))&&<Link to="/admin">CUT Sport admin dashboard</Link>}{roles.some(r=>["sport_admin","super_admin","coach"].includes(r))&&<Link to="/admin/athletes">Athlete profiles</Link>}<p>Roles: {roles.join(', ')||'Member'}</p><button onClick={()=>supabase.auth.signOut()}><LogOut/> Sign out</button></div></>:<><h1>Join the Blues.</h1><div className="tabs"><button onClick={()=>setMode('login')}>Log in</button><button onClick={()=>setMode('signup')}>Create account</button></div><form className="form-card" onSubmit={submit}>{mode==='signup'&&<label>Full name<input required value={name} onChange={e=>setName(e.target.value)}/></label>}<label>Email<input type="email" required value={email} onChange={e=>setEmail(e.target.value)}/></label><label>Password<input type="password" minLength="8" required value={password} onChange={e=>setPassword(e.target.value)}/></label><button className="btn primary">Continue</button>{message&&<p>{message}</p>}</form><p className="muted">Student and staff discounts require verified institutional eligibility.</p></>}</main></>}
let cutQrCodeLoader=null;
function loadCutQrCode(){
 if(window.QRCode)return Promise.resolve();
 if(cutQrCodeLoader)return cutQrCodeLoader;
 cutQrCodeLoader=new Promise((resolve,reject)=>{
  const script=document.createElement("script");
  script.src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js";
  script.async=true;
  script.onload=resolve;
  script.onerror=()=>{script.remove();reject(new Error("QR code library could not be loaded."))};
  document.head.appendChild(script);
 }).catch(error=>{cutQrCodeLoader=null;throw error});
 return cutQrCodeLoader;
}
function TicketQr({value}) {
 const target=useRef(null),[error,setError]=useState("");
 useEffect(()=>{
  let active=true;
  if(!value||!target.current)return;
  loadCutQrCode().then(()=>{
   if(!active||!target.current)return;
   target.current.innerHTML="";
   new window.QRCode(target.current,{text:value,width:216,height:216,colorDark:"#10213a",colorLight:"#ffffff",correctLevel:window.QRCode.CorrectLevel.M});
  }).catch(()=>{if(active)setError("QR preview unavailable. The secure ticket code below can still be entered manually.")});
  return()=>{active=false;if(target.current)target.current.innerHTML=""};
 },[value]);
 return <div className="ticket-qr-block"><div ref={target} className="ticket-qr" style={{display:"inline-block",background:"#ffffff",padding:10,borderRadius:12,minHeight:216,minWidth:216}}/>{error&&<small>{error}</small>}</div>;
}

function Personal({title,user,kind}) {
 const [items,setItems]=useState([]),[busy,setBusy]=useState(false),[error,setError]=useState("");
 const isNotifications=kind==="notifications";
 async function load(){
  if(!user){setItems([]);return}
  setBusy(true);setError("");
  const fn=isNotifications?api.notifications:kind==="tickets"?api.tickets:api.orders;
  const result=await fn(user.id);
  if(result.error)setError(result.error.message||"Unable to load your records.");
  setItems(result.data||[]);setBusy(false);
 }
 useEffect(()=>{load()},[user,kind]);
 const unread=items.filter(x=>!x.read_at);
 async function markRead(id){
  if(!supabase||!user)return;
  const now=new Date().toISOString();
  const {error}=await supabase.from("notifications").update({read_at:now}).eq("id",id).eq("user_id",user.id).is("read_at",null);
  if(error)setError(error.message);else setItems(old=>old.map(x=>x.id===id?{...x,read_at:now}:x));
 }
 async function markAllRead(){
  if(!supabase||!user||!unread.length)return;
  setBusy(true);setError("");const now=new Date().toISOString();
  const {error}=await supabase.from("notifications").update({read_at:now}).eq("user_id",user.id).is("read_at",null);
  if(error)setError(error.message);else setItems(old=>old.map(x=>({...x,read_at:x.read_at||now})));
  setBusy(false);
 }
 return <><Header title={title} back/><main className="page">
  {isNotifications?<div className="notifications-heading"><div><span className="eyebrow">CUT SPORT · YOUR UPDATES</span><h1>Notifications</h1><p>{unread.length} unread update(s)</p></div><div><button type="button" onClick={load} disabled={busy}>Refresh</button>{unread.length>0&&<button type="button" onClick={markAllRead} disabled={busy}>Mark all read</button>}</div></div>:<h1>{title}</h1>}
  {!user?<Empty title="Sign in to continue" body="Your personal information will appear here after you sign in."/>:null}
  {error&&<p className="form-error">{error}</p>}
  {user&&items.length?items.map(x=>isNotifications?<article className={"personal-card notification-card "+(x.read_at?"is-read":"is-unread")} key={x.id}><div className="notification-card-head"><b>{x.title||"CUT Sport update"}</b><small>{dateLabel(x.created_at)}</small></div><p>{x.body}</p><div className="notification-card-foot"><span>{x.read_at?"Read":"Unread"}</span>{!x.read_at&&<button type="button" onClick={()=>markRead(x.id)}>Mark as read</button>}</div></article>:<div className="personal-card" key={x.id}><b>{x.title||x.event?.title||x.order_number||"CUT Sport update"}</b><p>{x.body||x.payment_status||x.status||dateLabel(x.created_at)}</p>{x.ticket_code&&<><small>Scan this QR code at the event entrance</small><TicketQr value={x.ticket_code}/><small>If scanning is unavailable, staff can enter this secure code manually</small><code className="ticket-code">{x.ticket_code}</code>{x.redeemed_at&&<small>Redeemed · {dateLabel(x.redeemed_at)}</small>}</>}</div>):null}
  {user&&!items.length&&!busy&&<Empty title={isNotifications?"No notifications yet":"Nothing here yet"} body={isNotifications?"Payment confirmations and important CUT Sport updates will appear here.":"Your updates will appear here when available."}/>}
  {busy&&!items.length&&<p className="muted">Loading…</p>}
 </main></>;
}

function AdminTicketGate({roles}) {
 const allowed=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const [ticketCode,setTicketCode]=useState(""),[busy,setBusy]=useState(false),[result,setResult]=useState(null),[error,setError]=useState("");
 const [scannerActive,setScannerActive]=useState(false),[scannerBusy,setScannerBusy]=useState(false);
 const scannerRef=useRef(null),startingRef=useRef(false);
 async function stopScanner(){
  const scanner=scannerRef.current;
  if(scanner){
   try{await scanner.stop()}catch{}
   try{await scanner.clear()}catch{}
   scannerRef.current=null;
  }
  setScannerActive(false);startingRef.current=false;
 }
 useEffect(()=>()=>{const scanner=scannerRef.current;if(scanner){try{scanner.stop().catch(()=>{}).finally(()=>scanner.clear().catch(()=>{}))}catch{}}},[]);
 async function startScanner(){
  if(!allowed||startingRef.current||scannerRef.current)return;
  startingRef.current=true;setScannerBusy(true);setError("");
  try{
   if(!window.isSecureContext){throw new Error("Camera scanning requires a secure HTTPS address.")}
   if(!navigator.mediaDevices?.getUserMedia){throw new Error("This browser does not provide camera access. Use the ticket-code field instead.")}
   if(!window.Html5Qrcode){
    await new Promise((resolve,reject)=>{
     const existing=document.querySelector('script[data-cut-qr-scanner="true"]');
     if(existing){existing.addEventListener("load",resolve,{once:true});existing.addEventListener("error",()=>reject(new Error("The QR scanner could not be loaded.")),{once:true});return}
     const script=document.createElement("script");
     script.src="https://cdn.jsdelivr.net/npm/html5-qrcode@2.3.8/html5-qrcode.min.js";
     script.async=true;script.crossOrigin="anonymous";script.dataset.cutQrScanner="true";
     script.onload=resolve;script.onerror=()=>reject(new Error("The QR scanner library could not be loaded. Check your internet connection."));
     document.head.appendChild(script);
    });
   }
   if(!window.Html5Qrcode)throw new Error("QR scanner is unavailable in this browser.");
   const scanner=new window.Html5Qrcode("cut-ticket-reader",{verbose:false});
   scannerRef.current=scanner;
   await scanner.start({facingMode:"environment"},{fps:10,qrbox:{width:240,height:240},aspectRatio:1},async(decodedText)=>{
    const value=String(decodedText||"").trim();
    if(!value)return;
    setTicketCode(value);setResult(null);setError("Ticket code scanned. Review it, then select Validate and admit.");
    await stopScanner();
   },()=>{});
   setScannerActive(true);
  }catch(e){
   await stopScanner();
   setError(e?.message||"Unable to start the camera. Check browser camera permissions.");
  }finally{startingRef.current=false;setScannerBusy(false)}
 }
 async function scanImage(event){
  const file=event.target.files?.[0];if(!file)return;
  if(scannerActive)await stopScanner();
  setScannerBusy(true);setError("");
  try{
   if(!window.Html5Qrcode){
    await new Promise((resolve,reject)=>{
     const existing=document.querySelector('script[data-cut-qr-scanner="true"]');
     if(existing){existing.addEventListener("load",resolve,{once:true});existing.addEventListener("error",()=>reject(new Error("The QR scanner could not be loaded.")),{once:true});return}
     const script=document.createElement("script");script.src="https://cdn.jsdelivr.net/npm/html5-qrcode@2.3.8/html5-qrcode.min.js";script.async=true;script.crossOrigin="anonymous";script.dataset.cutQrScanner="true";script.onload=resolve;script.onerror=()=>reject(new Error("The QR scanner library could not be loaded."));document.head.appendChild(script);
    });
   }
   const scanner=new window.Html5Qrcode("cut-ticket-reader",{verbose:false});scannerRef.current=scanner;
   const decoded=await scanner.scanFile(file,true);
   setTicketCode(String(decoded||"").trim());setResult(null);setError("QR code decoded locally. Review the code, then select Validate and admit.");
   await scanner.clear();scannerRef.current=null;
  }catch(e){await stopScanner();setError(e?.message||"No readable QR code was found in that image.")}
  finally{setScannerBusy(false);event.target.value=""}
 }
 async function redeem(e){
  e.preventDefault();if(!supabase||!ticketCode.trim())return;
  setBusy(true);setError("");setResult(null);
  const {data,error:invokeError}=await supabase.functions.invoke("redeem-ticket",{body:{ticketCode:ticketCode.trim()}});
  if(invokeError||data?.error)setError(data?.error||invokeError?.message||"Ticket could not be redeemed.");
  else{setResult(data);setTicketCode("");}
  setBusy(false);
 }
 if(!allowed)return <><Header title="Staff access required" back/><main className="page"><Empty title="Restricted area" body="Only authorised sport administrators can redeem tickets."/></main></>;
 return <><Header title="Event entry" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · GATE CHECK-IN</span><h1>Validate a ticket.</h1><p>Use the device camera to scan a ticket QR code, or enter the ticket code manually. A successful redemption is recorded securely and each ticket can only be used once.</p></div>
  <div className="scanner-card">
   <div className="scanner-head"><b>QR ticket scanner</b><span>{scannerActive?"Camera active":"Camera stopped"}</span></div>
   <div id="cut-ticket-reader" className="qr-reader" aria-label="Camera QR code scanner"/>
   <label className="scanner-file">Scan from a photo or screenshot<input type="file" accept="image/*" onChange={scanImage} disabled={scannerBusy}/></label>
   <div className="scanner-actions">
    {!scannerActive?<button className="btn primary" type="button" disabled={scannerBusy} onClick={startScanner}>{scannerBusy?"Starting camera…":"Open camera scanner"}</button>:<button className="btn primary" type="button" onClick={stopScanner}>Stop camera</button>}
   </div>
   <small>Camera access requires HTTPS and your permission. The camera is used only to read the QR code; the code is checked by CUT Sport's secure ticket service.</small>
  </div>
  <form className="form-card" onSubmit={redeem}>
   <label>Ticket code<input autoComplete="off" required value={ticketCode} onChange={e=>setTicketCode(e.target.value)} placeholder="Scanned code appears here, or paste it"/></label>
   <button className="btn primary" disabled={busy||!ticketCode.trim()}>{busy?"Checking ticket…":"Validate and admit"}</button>
   {error&&<p className="form-error">{error}</p>}
   {result&&<div className="admin-notice"><ShieldCheck/><div><b>Ticket accepted</b><p>{result.event} · Ticket {result.ticketId}</p></div></div>}
  </form>
 </main></>;
}

function AdminDashboard({sports,teams,competitions,fixtures,articles,events,sponsors,athletes,roles}) {
 const sportAdmin=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const coach=roles.includes("coach");
 const shopAdmin=roles.includes("shop_admin");
 const allowed=sportAdmin||coach||shopAdmin;
 const modules=[
  ...(sportAdmin?[{title:"Sport codes",description:"Manage the official sport directory; create new codes or edit/archive assigned sports.",to:"/admin/sports",icon:Settings2,state:"Available"},{title:"Sponsor directory",description:"Create, update and archive official partner profiles.",to:"/admin/sponsors",icon:Handshake,state:"Available"},{title:"Sport operations",description:"Team, competition and fixture publishing tools.",to:"/admin/operations",icon:CalendarClock,state:"Available"},{title:"News & events",description:"Editorial publishing and event management.",to:"/admin/editorial",icon:FileText,state:"Available"}]:[]),
  ...((sportAdmin||coach)?[{title:"Athlete profiles",description:"Register and update profiles within your assigned sport or team scope.",to:"/admin/athletes",icon:Users,state:"Available"},{title:"Performance dashboards",description:"Compare approved athlete statistics by sport, athlete, season and metric.",to:"/admin/performance",icon:Trophy,state:"Available"}]:[]),
  ...(sportAdmin?[{title:"Athlete approvals",description:"Review athlete profiles before publication.",to:"/admin/approvals",icon:ShieldCheck,state:"Available"},{title:"Event ticket gate",description:"Validate and redeem paid event tickets at entry.",to:"/admin/ticket-gate",icon:Ticket,state:"Available"},{title:"Event sales & attendees",description:"Review ticket sales, revenue, attendee registers and check-ins.",to:"/admin/event-reports",icon:ClipboardList,state:"Available"}]:[]),
  ...((shopAdmin||roles.includes("super_admin"))?[{title:"Shop catalogue",description:"Create, update and archive products and manage published stock.",to:"/admin/products",icon:ShoppingBag,state:"Available"},{title:"Shop orders",description:"Review paid shop orders, line items and fulfilment status.",to:"/admin/shop-orders",icon:Package,state:"Available"}]:[])
 ];
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="A CUT Sport administrator, coach or shop administrator role is required."/></main></>;
 return <><Header title="Admin dashboard" back/><main className="page"><div className="page-intro"><span className="eyebrow">CUT SPORT · MANAGEMENT</span><h1>Admin dashboard</h1><p>Manage the information published in the CUT Sport app. Access to each record is still enforced by Supabase policies.</p></div><div className="admin-stats"><div><b>{sports.length}</b><small>Sport codes</small></div><div><b>{teams.length}</b><small>Teams</small></div><div><b>{competitions.length}</b><small>Competitions</small></div><div><b>{fixtures.length}</b><small>Fixtures</small></div><div><b>{articles.length}</b><small>Published stories</small></div><div><b>{events.length}</b><small>Events</small></div><div><b>{athletes.length}</b><small>Public athletes</small></div><div><b>{sponsors.length}</b><small>Active sponsors</small></div></div><Section title="Management tools"><div className="admin-module-grid">{modules.map(m=><article className="admin-module" key={m.title}><div className="admin-module-icon"><m.icon size={20}/></div><div className="admin-module-copy"><b>{m.title}</b><p>{m.description}</p><small>{m.state}</small></div>{m.to?<Link to={m.to} aria-label={"Open "+m.title}><ChevronRight/></Link>:<ShieldCheck size={18} className="muted-icon"/>}</article>)}</div></Section><div className="admin-notice"><ShieldCheck size={18}/><div><b>Security-first publishing</b><p>Planned management tools remain read-only or unavailable until their role scopes, Row Level Security policies and server-side workflows are reviewed and tested. This dashboard does not grant new permissions.</p></div></div></main></> ;
}

function AdminAthletes({roles}) {
 const allowed=roles.some(r=>["sport_admin","super_admin","coach"].includes(r));
 const [sports,setSports]=useState([]),[teams,setTeams]=useState([]),[items,setItems]=useState([]);
 const [busy,setBusy]=useState(false),[error,setError]=useState(""),[editing,setEditing]=useState(null);
 const blank={sport_id:"",team_id:"",full_name:"",preferred_name:"",position:"",squad_number:"",bio:"",photo_url:"",is_featured:false,profile_visibility:"public"};
 const [form,setForm]=useState(blank);
 async function load(){if(!supabase||!allowed)return;const [s,t,a]=await Promise.all([supabase.from("sports").select("id,name").eq("is_active",true).order("display_order"),supabase.from("teams").select("id,name,sport_id").eq("is_active",true).order("name"),supabase.from("athletes").select("id,sport_id,team_id,full_name,preferred_name,position,squad_number,bio,photo_url,is_featured,approval_status,profile_visibility,sports(name),teams(name)").order("full_name")]);const failure=s.error||t.error||a.error;if(failure)setError(failure.message);else{setSports(s.data||[]);setTeams(t.data||[]);setItems(a.data||[]);}}
 useEffect(()=>{load()},[allowed]);
 const availableTeams=teams.filter(t=>!form.sport_id||t.sport_id===form.sport_id);
 function edit(item){setEditing(item.id);setForm({...blank,...item,squad_number:item.squad_number??"",team_id:item.team_id||""});setError("");}
 function reset(){setEditing(null);setForm(blank);setError("");}
 async function save(e){e.preventDefault();if(!allowed||!supabase)return;setBusy(true);setError("");const payload={sport_id:form.sport_id,team_id:form.team_id||null,full_name:form.full_name.trim(),preferred_name:form.preferred_name.trim()||null,position:form.position.trim()||null,squad_number:form.squad_number===""?null:Number(form.squad_number),bio:form.bio.trim()||null,photo_url:form.photo_url.trim()||null,is_featured:Boolean(form.is_featured),profile_visibility:form.profile_visibility};const result=editing?await supabase.from("athletes").update(payload).eq("id",editing):await supabase.from("athletes").insert({...payload,approval_status:"pending"});if(result.error)setError(result.error.message);else{reset();await load();}setBusy(false);}
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="An assigned sport administrator, coach or super administrator role is required."/></main></>;
 return <><Header title="Athlete management" back/><main className="page"><div className="page-intro"><span className="eyebrow">ASSIGNED SPORT ACCESS</span><h1>Athlete profiles</h1><p>Profiles are visible here only where your database assignment allows it. New profiles start pending and are not publicly listed until approved.</p></div>
 <form className="form-card" onSubmit={save}><h3>{editing?"Update athlete profile":"Register athlete profile"}</h3>
 <label>Sport code<select required value={form.sport_id} onChange={e=>setForm({...form,sport_id:e.target.value,team_id:""})}><option value="">Choose sport</option>{sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
 <label>Team<select value={form.team_id} onChange={e=>setForm({...form,team_id:e.target.value})}><option value="">No team selected</option>{availableTeams.map(t=><option key={t.id} value={t.id}>{t.name}</option>)}</select></label>
 <label>Full name<input required value={form.full_name} onChange={e=>setForm({...form,full_name:e.target.value})}/></label>
 <label>Preferred name<input value={form.preferred_name||""} onChange={e=>setForm({...form,preferred_name:e.target.value})}/></label>
 <label>Playing position / event<input value={form.position||""} onChange={e=>setForm({...form,position:e.target.value})}/></label>
 <label>Squad number<input type="number" min="0" value={form.squad_number} onChange={e=>setForm({...form,squad_number:e.target.value})}/></label>
 <label>Short biography<textarea value={form.bio||""} onChange={e=>setForm({...form,bio:e.target.value})}/></label>
 <label>Photo URL<input type="url" value={form.photo_url||""} onChange={e=>setForm({...form,photo_url:e.target.value})}/></label>
 <label>Profile visibility<select value={form.profile_visibility} onChange={e=>setForm({...form,profile_visibility:e.target.value})}><option value="public">Public after approval</option><option value="private">Private</option></select></label>
 <label className="check-label"><input type="checkbox" checked={Boolean(form.is_featured)} onChange={e=>setForm({...form,is_featured:e.target.checked})}/> Feature on sport profile</label>
 <button className="btn primary" disabled={busy||!sports.length}>{busy?"Saving…":editing?"Save athlete":"Register athlete"}</button>{editing&&<button type="button" onClick={reset}>Cancel edit</button>}{error&&<p className="form-error">{error}</p>}</form>
 <Section title="Athlete records">{items.length?items.map(a=><div className="sponsor-card admin-sponsor" key={a.id}><div><b>{a.preferred_name||a.full_name}</b><small>{a.sports?.name||"Sport not set"} · {a.teams?.name||"No team"} · {a.approval_status}</small></div><button onClick={()=>edit(a)}>Edit</button></div>):<Empty title="No athlete records" body="No athlete profiles are currently available within your assigned sport or team permissions."/>}</Section>
 </main></>;
}



function AdminSports({roles,user,setSports}) {
 const sportAdmin=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const superAdmin=roles.includes("super_admin");
 const blank={name:"",slug:"",description:"",image_url:"",display_order:"0",is_active:true};
 const [items,setItems]=useState([]),[editableIds,setEditableIds]=useState([]);
 const [form,setForm]=useState(blank),[editing,setEditing]=useState(null);
 const [busy,setBusy]=useState(false),[error,setError]=useState("");
 async function load(){
  if(!supabase||!sportAdmin||!user){setItems([]);setEditableIds([]);return}
  setBusy(true);setError("");
  const {data,error}=await supabase.from("sports")
   .select("id,name,slug,description,image_url,is_active,display_order")
   .order("display_order",{ascending:true}).order("name",{ascending:true});
  if(error){setError(error.message);setBusy(false);return}
  const rows=data||[];
  setItems(rows);setSports(rows.filter(x=>x.is_active));
  if(superAdmin){setEditableIds(rows.map(x=>x.id));setBusy(false);return}
  const {data:assignments,error:assignmentError}=await supabase.from("sport_admin_assignments")
   .select("sport_id,starts_on,ends_on")
   .eq("admin_profile_id",user.id).eq("assignment_role","sport_admin")
   .is("team_id",null).eq("is_active",true);
  if(assignmentError){setError(assignmentError.message);setEditableIds([])}
  else{
   const today=new Date().toISOString().slice(0,10);
   setEditableIds((assignments||[]).filter(x=>(!x.starts_on||x.starts_on<=today)&&(!x.ends_on||x.ends_on>=today)).map(x=>x.sport_id));
  }
  setBusy(false);
 }
 useEffect(()=>{load()},[sportAdmin,superAdmin,user?.id]);
 const canEdit=id=>superAdmin||editableIds.includes(id);
 function reset(){setEditing(null);setForm(blank);setError("")}
 function edit(item){
  if(!canEdit(item.id))return;
  setEditing(item.id);
  setForm({name:item.name,slug:item.slug,description:item.description||"",image_url:item.image_url||"",display_order:String(item.display_order??0),is_active:Boolean(item.is_active)});
  setError("");
 }
 async function save(e){
  e.preventDefault();
  if(!supabase||!sportAdmin||(!editing&&!superAdmin))return;
  if(editing&&!canEdit(editing)){setError("You do not have an active full-sport assignment for this sport.");return}
  const name=form.name.trim();
  const slug=(form.slug||name).trim().toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
  const displayOrder=Number(form.display_order);
  if(!name||!slug){setError("A sport name and valid URL slug are required.");return}
  if(!Number.isInteger(displayOrder)||displayOrder<0){setError("Display order must be a non-negative whole number.");return}
  const payload={name,slug,description:form.description.trim()||null,image_url:form.image_url.trim()||null,display_order:displayOrder,is_active:Boolean(form.is_active)};
  setBusy(true);setError("");
  const result=editing
   ?await supabase.from("sports").update(payload).eq("id",editing).select("id").maybeSingle()
   :await supabase.from("sports").insert(payload).select("id").single();
  if(result.error)setError(result.error.message);
  else if(!result.data)setError("No sport record was changed. Check that your administrator assignment is still active.");
  else{reset();await load()}
  setBusy(false);
 }
 async function setActive(item,isActive){
  if(!supabase||!canEdit(item.id))return;
  setBusy(true);setError("");
  const {data,error}=await supabase.from("sports").update({is_active:isActive}).eq("id",item.id).select("id").maybeSingle();
  if(error)setError(error.message);
  else if(!data)setError("No sport record was changed. Check that your administrator assignment is still active.");
  else await load();
  setBusy(false);
 }
 if(!sportAdmin)return <><Header title="Sport administration access required" back/><main className="page"><Empty title="Restricted area" body="A sport administrator or super administrator role is required."/></main></>;
 return <><Header title="Sport codes" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · DIRECTORY MANAGEMENT</span><h1>Official sport codes.</h1><p>Maintain the sport directory used across the app. Super administrators can add codes; assigned sport administrators can edit or archive only the sports in their active full-sport assignment.</p></div>
  {error&&<p className="form-error">{error}</p>}
  {(superAdmin||editing)&&<form className="form-card" onSubmit={save}>
   <h3>{editing?"Edit sport code":"Add sport code"}</h3>
   <label>Sport name<input required maxLength="100" value={form.name} onChange={e=>setForm({...form,name:e.target.value})}/></label>
   <label>URL slug<input maxLength="120" value={form.slug} onChange={e=>setForm({...form,slug:e.target.value})} placeholder="generated-from-name"/></label>
   <label>Description<textarea maxLength="1000" value={form.description} onChange={e=>setForm({...form,description:e.target.value})}/></label>
   <label>Image URL<input type="url" value={form.image_url} onChange={e=>setForm({...form,image_url:e.target.value})}/></label>
   <label>Display order<input type="number" min="0" step="1" required value={form.display_order} onChange={e=>setForm({...form,display_order:e.target.value})}/></label>
   <label className="check-label"><input type="checkbox" checked={Boolean(form.is_active)} onChange={e=>setForm({...form,is_active:e.target.checked})}/> Published in the public sport directory</label>
   <button className="btn primary" disabled={busy}>{busy?"Saving…":editing?"Save sport code":"Create sport code"}</button>
   {editing&&<button type="button" onClick={reset}>Cancel edit</button>}
  </form>}
  <Section title="Official sport codes">{items.length?items.map(item=><div className="sponsor-card admin-sponsor" key={item.id}>
   <div><b>{item.name}</b><small>{item.slug} · {item.is_active?"Active":"Archived"} · Display order {item.display_order}</small></div>
   {canEdit(item.id)&&<button type="button" disabled={busy} onClick={()=>edit(item)}>Edit</button>}
   {canEdit(item.id)&&<button type="button" disabled={busy} onClick={()=>setActive(item,!item.is_active)}>{item.is_active?"Archive":"Restore"}</button>}
  </div>):<Empty title={busy?"Loading sport codes":"No sport codes available"} body={busy?"The official directory is being retrieved.":"Sport codes will appear here when available to your account."}/>}</Section>
  <p className="muted">Archiving hides a sport from the public directory without deleting linked teams, fixtures, competitions or athlete records. Database RLS remains authoritative for every change.</p>
 </main></>;
}

function AdminOperations({roles,user}) {
 const admin=roles.some(r=>["sport_admin","super_admin"].includes(r)), allowed=admin||roles.includes("coach");
 const [sports,setSports]=useState([]),[teams,setTeams]=useState([]),[competitions,setCompetitions]=useState([]),[fixtures,setFixtures]=useState([]),[submissions,setSubmissions]=useState([]),[error,setError]=useState(""),[busy,setBusy]=useState(false),[editing,setEditing]=useState(null);
 const blankTeam={sport_id:"",name:"",category:"",season:""};
 const blankComp={sport_id:"",name:"",season:"",start_date:"",end_date:"",venue:"",description:""};
 const blankFixture={sport_id:"",team_id:"",competition_id:"",opponent:"",venue:"",starts_at:"",status:"scheduled"};
 const [team,setTeam]=useState(blankTeam),[comp,setComp]=useState(blankComp),[fixture,setFixture]=useState(blankFixture);
 const [result,setResult]=useState({fixture_id:"",home_score:"",away_score:"",result_summary:""});
 async function load(){
  if(!supabase||!allowed)return;
  setBusy(true);setError("");
  const rs=await Promise.all([
   supabase.from("sports").select("id,name").eq("is_active",true).order("display_order"),
   supabase.from("teams").select("id,name,sport_id,is_active,category,season").order("name"),
   supabase.from("competitions").select("id,name,sport_id,season,status,start_date,end_date,venue,description").order("name"),
   supabase.from("fixtures").select("id,sport_id,team_id,competition_id,opponent,venue,starts_at,status,home_score,away_score,teams(name)").order("starts_at"),
   supabase.from("fixture_result_submissions").select("id,fixture_id,home_score,away_score,review_status,created_at,fixtures(opponent,teams(name))").order("created_at",{ascending:false})
  ]);
  const fail=rs.find(x=>x.error);
  if(fail)setError(fail.error.message);
  else{setSports(rs[0].data||[]);setTeams(rs[1].data||[]);setCompetitions(rs[2].data||[]);setFixtures(rs[3].data||[]);setSubmissions(rs[4].data||[]);}
  setBusy(false);
 }
 useEffect(()=>{load()},[allowed]);
 function resetEditor(){
  setEditing(null);setTeam(blankTeam);setComp(blankComp);setFixture(blankFixture);setError("");
 }
 function editRecord(kind,item){
  if(!admin)return;
  setEditing({kind,id:item.id});
  setError("");
  if(kind==="team")setTeam({sport_id:item.sport_id||"",name:item.name||"",category:item.category||"",season:item.season||""});
  if(kind==="competition")setComp({sport_id:item.sport_id||"",name:item.name||"",season:item.season||"",start_date:item.start_date||"",end_date:item.end_date||"",venue:item.venue||"",description:item.description||""});
  if(kind==="fixture")setFixture({sport_id:item.sport_id||"",team_id:item.team_id||"",competition_id:item.competition_id||"",opponent:item.opponent||"",venue:item.venue||"",starts_at:item.starts_at?new Date(item.starts_at).toISOString().slice(0,16):"",status:item.status||"scheduled"});
  window.scrollTo({top:0,behavior:"smooth"});
 }
 async function saveRecord(kind,payload,reset){
  if((kind==="fixture_result_submission"?!allowed:!admin)||!supabase)return;
  setBusy(true);setError("");
  const currentEdit=editing?.kind===kind?editing:null;
  const table=kind==="team"?"teams":kind==="competition"?"competitions":kind==="fixture"?"fixtures":"fixture_result_submissions";
  const query=currentEdit
   ?supabase.from(table).update(payload).eq("id",currentEdit.id).select("id").maybeSingle()
   :supabase.from(table).insert(payload).select("id").single();
  const {data,error}=await query;
  if(error)setError(error.message);
  else if(!data)setError("No record was changed. Confirm that your administrator assignment is still active for this sport.");
  else{reset();await load();}
  setBusy(false);
 }
 async function archiveRecord(kind,item){
  if(!admin||!supabase)return;
  const label=kind==="team"?"team":kind==="competition"?"competition":"fixture";
  if(!window.confirm("Archive this "+label+"? This keeps linked records and history; nothing will be permanently deleted."))return;
  setBusy(true);setError("");
  const table=kind==="team"?"teams":kind==="competition"?"competitions":"fixtures";
  const patch=kind==="team"?{is_active:false}:kind==="competition"?{status:"archived"}:{status:"cancelled"};
  const {data,error}=await supabase.from(table).update(patch).eq("id",item.id).select("id").maybeSingle();
  if(error)setError(error.message);
  else if(!data)setError("No record was changed. Confirm that your administrator assignment is still active for this sport.");
  else{if(editing?.id===item.id)resetEditor();await load();}
  setBusy(false);
 }
 async function review(item,status){
  if(!admin||!supabase)return;
  setBusy(true);setError("");
  const response=status==="accepted"
   ?await supabase.rpc("publish_fixture_result_submission",{p_submission_id:item.id,p_review_note:null})
   :await supabase.from("fixture_result_submissions").update({review_status:"rejected",reviewed_by:user.id,reviewed_at:new Date().toISOString()}).eq("id",item.id).select("id").maybeSingle();
  if(response.error)setError(response.error.message);else await load();
  setBusy(false);
 }
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="Only assigned sport staff can access operations."/></main></>;
 const sportOptions=sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>);
 const canEditArticle=item=>isSuper||!item.author_id||item.author_id===user?.id;
 const teamForm=editing?.kind==="team",compForm=editing?.kind==="competition",fixtureForm=editing?.kind==="fixture";
 return <><Header title="Sport operations" back/><main className="page"><div className="page-intro"><span className="eyebrow">ASSIGNED SPORT SCOPE</span><h1>Sport operations</h1><p>Administrators can create, edit and archive teams, competitions and fixtures within their assigned sport scope. Coaches can submit scores for review; submissions do not overwrite published results.</p></div>
 {admin&&<>{editing&&<div className="admin-notice"><ShieldCheck/><div><b>Editing {editing.kind}</b><p>Changes are checked by Supabase row-level security against your active sport assignment.</p></div><button type="button" onClick={resetEditor}>Cancel</button></div>}
 <form className="form-card" onSubmit={e=>{e.preventDefault();saveRecord("team",{sport_id:team.sport_id,name:team.name.trim(),category:team.category.trim()||null,season:team.season.trim()||null},()=>{setEditing(null);setTeam(blankTeam);});}}><h3>{teamForm?"Edit team":"Create team"}</h3><label>Sport<select required value={team.sport_id} onChange={e=>setTeam({...team,sport_id:e.target.value})}><option value="">Choose sport</option>{sportOptions}</select></label><label>Team name<input required maxLength="120" value={team.name} onChange={e=>setTeam({...team,name:e.target.value})}/></label><label>Category<input maxLength="100" value={team.category} onChange={e=>setTeam({...team,category:e.target.value})}/></label><label>Season<input maxLength="40" value={team.season} onChange={e=>setTeam({...team,season:e.target.value})}/></label><button className="btn primary" disabled={busy}>{busy?"Saving…":teamForm?"Save team":"Create team"}</button>{teamForm&&<button type="button" onClick={resetEditor}>Cancel edit</button>}</form>
 <form className="form-card" onSubmit={e=>{e.preventDefault();if(comp.start_date&&comp.end_date&&comp.end_date<comp.start_date){setError("Competition end date cannot be earlier than its start date.");return;}saveRecord("competition",{sport_id:comp.sport_id,name:comp.name.trim(),season:comp.season.trim()||null,start_date:comp.start_date||null,end_date:comp.end_date||null,venue:comp.venue.trim()||null,description:comp.description.trim()||null},()=>{setEditing(null);setComp(blankComp);});}}><h3>{compForm?"Edit competition":"Create competition"}</h3><label>Sport<select required value={comp.sport_id} onChange={e=>setComp({...comp,sport_id:e.target.value})}><option value="">Choose sport</option>{sportOptions}</select></label><label>Name<input required maxLength="160" value={comp.name} onChange={e=>setComp({...comp,name:e.target.value})}/></label><label>Season<input maxLength="40" value={comp.season} onChange={e=>setComp({...comp,season:e.target.value})}/></label><label>Start date<input type="date" value={comp.start_date} onChange={e=>setComp({...comp,start_date:e.target.value})}/></label><label>End date<input type="date" min={comp.start_date||undefined} value={comp.end_date} onChange={e=>setComp({...comp,end_date:e.target.value})}/></label><label>Venue<input maxLength="160" value={comp.venue} onChange={e=>setComp({...comp,venue:e.target.value})}/></label><label>Description<textarea maxLength="2000" value={comp.description} onChange={e=>setComp({...comp,description:e.target.value})}/></label><button className="btn primary" disabled={busy}>{busy?"Saving…":compForm?"Save competition":"Create competition"}</button>{compForm&&<button type="button" onClick={resetEditor}>Cancel edit</button>}</form>
 <form className="form-card" onSubmit={e=>{e.preventDefault();if(!fixture.starts_at){setError("Choose a fixture date and time.");return;}saveRecord("fixture",{sport_id:fixture.sport_id,team_id:fixture.team_id||null,competition_id:fixture.competition_id||null,opponent:fixture.opponent.trim(),venue:fixture.venue.trim()||null,starts_at:new Date(fixture.starts_at).toISOString(),status:fixture.status},()=>{setEditing(null);setFixture(blankFixture);});}}><h3>{fixtureForm?"Edit fixture":"Create fixture"}</h3><label>Sport<select required value={fixture.sport_id} onChange={e=>setFixture({...fixture,sport_id:e.target.value,team_id:"",competition_id:""})}><option value="">Choose sport</option>{sportOptions}</select></label><label>Team<select value={fixture.team_id} onChange={e=>setFixture({...fixture,team_id:e.target.value})}><option value="">No team</option>{teams.filter(t=>t.sport_id===fixture.sport_id&&t.is_active).map(t=><option key={t.id} value={t.id}>{t.name}</option>)}</select></label><label>Competition<select value={fixture.competition_id} onChange={e=>setFixture({...fixture,competition_id:e.target.value})}><option value="">No competition</option>{competitions.filter(c=>c.sport_id===fixture.sport_id&&c.status!=="archived").map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label><label>Opponent<input required maxLength="160" value={fixture.opponent} onChange={e=>setFixture({...fixture,opponent:e.target.value})}/></label><label>Venue<input maxLength="160" value={fixture.venue} onChange={e=>setFixture({...fixture,venue:e.target.value})}/></label><label>Date/time<input type="datetime-local" required value={fixture.starts_at} onChange={e=>setFixture({...fixture,starts_at:e.target.value})}/></label><label>Status<select value={fixture.status} onChange={e=>setFixture({...fixture,status:e.target.value})}>{["scheduled","live","completed","postponed","cancelled"].map(x=><option key={x} value={x}>{x}</option>)}</select></label><button className="btn primary" disabled={busy}>{busy?"Saving…":fixtureForm?"Save fixture":"Publish fixture"}</button>{fixtureForm&&<button type="button" onClick={resetEditor}>Cancel edit</button>}</form></>}
 <form className="form-card" onSubmit={e=>{e.preventDefault();if(!supabase||!user)return;saveRecord("fixture_result_submission",{fixture_id:result.fixture_id,submitted_by:user.id,home_score:Number(result.home_score),away_score:Number(result.away_score),result_summary:result.result_summary||null},()=>setResult({fixture_id:"",home_score:"",away_score:"",result_summary:""}));}}><h3>Submit result for review</h3><label>Fixture<select required value={result.fixture_id} onChange={e=>setResult({...result,fixture_id:e.target.value})}><option value="">Choose fixture</option>{fixtures.filter(f=>f.team_id&&f.status!=="cancelled").map(f=><option key={f.id} value={f.id}>{(f.teams?.name||"CUT")+" vs "+f.opponent+" · "+dateLabel(f.starts_at)}</option>)}</select></label><label>CUT score<input type="number" min="0" required value={result.home_score} onChange={e=>setResult({...result,home_score:e.target.value})}/></label><label>Opponent score<input type="number" min="0" required value={result.away_score} onChange={e=>setResult({...result,away_score:e.target.value})}/></label><label>Notes<textarea maxLength="1000" value={result.result_summary} onChange={e=>setResult({...result,result_summary:e.target.value})}/></label><button className="btn primary" disabled={busy}>Submit result</button></form>
 {error&&<p className="form-error">{error}</p>}
 <Section title="Official teams">{teams.length?teams.map(t=><div className="sponsor-card admin-sponsor" key={t.id}><div><b>{t.name}</b><small>{sports.find(s=>s.id===t.sport_id)?.name||"Sport"} · {t.category||"Category not set"} · {t.season||"Season not set"} · {t.is_active?"Active":"Archived"}</small></div>{admin&&<><button type="button" disabled={busy||!t.is_active} onClick={()=>editRecord("team",t)}>Edit</button>{t.is_active&&<button type="button" disabled={busy} onClick={()=>archiveRecord("team",t)}>Archive</button>}</>}</div>):<Empty title="No teams yet" body="No official team records have been entered."/>}</Section>
 <Section title="Competitions">{competitions.length?competitions.map(c=><div className="sponsor-card admin-sponsor" key={c.id}><div><b>{c.name}</b><small>{sports.find(s=>s.id===c.sport_id)?.name||"Sport"} · {c.season||c.status} · {c.status}</small></div>{admin&&<><button type="button" disabled={busy||c.status==="archived"} onClick={()=>editRecord("competition",c)}>Edit</button>{c.status!=="archived"&&<button type="button" disabled={busy} onClick={()=>archiveRecord("competition",c)}>Archive</button>}</>}</div>):<Empty title="No competitions yet" body="No official competitions have been entered."/>}</Section>
 <Section title="Fixtures">{fixtures.length?fixtures.map(f=><div className="sponsor-card admin-sponsor" key={f.id}><div><b>{(f.teams?.name||"CUT")+" vs "+f.opponent}</b><small>{dateLabel(f.starts_at)} · {f.status}{f.home_score!==null&&f.away_score!==null?" · "+f.home_score+"–"+f.away_score:""}</small></div>{admin&&<><button type="button" disabled={busy||f.status==="cancelled"} onClick={()=>editRecord("fixture",f)}>Edit</button>{f.status!=="cancelled"&&<button type="button" disabled={busy} onClick={()=>archiveRecord("fixture",f)}>Cancel fixture</button>}</>}</div>):<Empty title="No fixtures yet" body="No fixtures have been entered."/>}</Section>
 <Section title="Submitted results">{submissions.length?submissions.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.fixtures?.teams?.name||"CUT")+" vs "+x.fixtures?.opponent+" · "+x.home_score+"–"+x.away_score}</b><small>{x.review_status}</small></div>{admin&&x.review_status==="pending"&&<><button disabled={busy} onClick={()=>review(x,"accepted")}>Accept</button><button disabled={busy} onClick={()=>review(x,"rejected")}>Reject</button></>}</div>):<Empty title="No submissions" body="Coach result submissions will appear here."/>}</Section>
 <p className="muted">Archiving is non-destructive: teams are deactivated, competitions are marked archived, and fixtures are cancelled. Published results remain in the fixture record. Coaches can submit results only; administrators review and publish them through the atomic database workflow.</p>
 </main></>;
}

function AdminApprovals({roles,user}) {
 const allowed=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const [items,setItems]=useState([]),[stats,setStats]=useState([]),[achievements,setAchievements]=useState([]),[media,setMedia]=useState([]),[error,setError]=useState("");
 async function load(){if(!supabase||!allowed)return;const [a,s,g,m]=await Promise.all([supabase.from("athletes").select("id,full_name,preferred_name,approval_status,sports(name),teams(name)").neq("approval_status","approved").order("created_at",{ascending:false}),supabase.from("athlete_statistics").select("id,athlete_id,season,period_label,metrics,approval_status,athletes(full_name)").neq("approval_status","approved").order("created_at",{ascending:false}),supabase.from("athlete_achievements").select("id,athlete_id,title,description,is_verified,athletes(full_name)").eq("is_verified",false).order("created_at",{ascending:false}),supabase.from("athlete_media").select("id,athlete_id,title,media_type,visibility,approved_at,athletes(full_name)").is("approved_at",null).order("created_at",{ascending:false})]);const fail=[a,s,g,m].find(x=>x.error);if(fail)setError(fail.error.message);else{setItems(a.data||[]);setStats(s.data||[]);setAchievements(g.data||[]);setMedia(m.data||[]);}}
 useEffect(()=>{load()},[allowed]);
 async function approve(table,id,payload){const {error}=await supabase.from(table).update(payload).eq("id",id);if(error)setError(error.message);else load();}
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="Only sport administrators and super administrators can approve records."/></main></>;
 return <><Header title="Athlete approvals" back/><main className="page"><div className="page-intro"><span className="eyebrow">VERIFICATION QUEUE</span><h1>Athlete approvals</h1><p>Profile and performance approval is separate from athlete editing. The database prevents coaches from changing verification fields.</p></div>{error&&<p className="form-error">{error}</p>}
 <Section title="Athlete profiles">{items.length?items.map(a=><div className="sponsor-card admin-sponsor" key={a.id}><div><b>{a.preferred_name||a.full_name}</b><small>{a.sports?.name||"Sport"} · {a.teams?.name||"No team"} · {a.approval_status}</small></div><button onClick={()=>approve("athletes",a.id,{approval_status:"approved",verified_by:user.id,verified_at:new Date().toISOString()})}>Approve</button><button onClick={()=>approve("athletes",a.id,{approval_status:"rejected",verified_by:user.id,verified_at:new Date().toISOString()})}>Reject</button></div>):<Empty title="No athlete profiles awaiting approval" body="New registrations will appear here."/>}</Section>
 <Section title="Performance statistics">{stats.length?stats.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.athletes?.full_name||"Athlete")+" · "+(x.season||x.period_label||"Statistics")}</b><small>{JSON.stringify(x.metrics)}</small></div><button onClick={()=>approve("athlete_statistics",x.id,{approval_status:"approved",approved_by:user.id,approved_at:new Date().toISOString()})}>Approve</button></div>):<Empty title="No statistics awaiting approval" body="Pending statistics will appear here."/>}</Section>
 <Section title="Achievements">{achievements.length?achievements.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.athletes?.full_name||"Athlete")+" · "+x.title}</b><small>{x.description||"Achievement submitted for verification"}</small></div><button onClick={()=>approve("athlete_achievements",x.id,{is_verified:true,verified_by:user.id,verified_at:new Date().toISOString()})}>Verify</button></div>):<Empty title="No achievements awaiting verification" body="Pending achievements will appear here."/>}</Section>
 <Section title="Athlete media">{media.length?media.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.athletes?.full_name||"Athlete")+" · "+(x.title||x.media_type)}</b><small>{x.visibility}</small></div><button onClick={()=>approve("athlete_media",x.id,{approved_by:user.id,approved_at:new Date().toISOString(),visibility:"public"})}>Approve media</button></div>):<Empty title="No media awaiting approval" body="Pending media will appear here."/>}</Section>
 </main></>;
}

function AdminEditorial({roles,user,sports}) {
 const isSuper=roles.includes("super_admin");
 const allowed=isSuper||roles.includes("sport_admin");
 const blankArticle={sport_id:"",title:"",slug:"",excerpt:"",body:"",cover_image_url:"",status:"draft",published_at:null};
 const blankEvent={sport_id:"",title:"",description:"",venue:"",starts_at:"",ends_at:"",published:false,ticketed:false,ticket_price:"",ticket_quantity:""};
 const [articles,setArticles]=useState([]),[events,setEvents]=useState([]),[error,setError]=useState(""),[busy,setBusy]=useState(false),[loading,setLoading]=useState(false);
 const [editingArticle,setEditingArticle]=useState(null),[editingEvent,setEditingEvent]=useState(null);
 const [article,setArticle]=useState(blankArticle),[event,setEvent]=useState(blankEvent);
 async function load(){
  if(!supabase||!allowed)return;
  setLoading(true);setError("");
  const [a,e]=await Promise.all([
   supabase.from("articles").select("id,title,slug,excerpt,body,cover_image_url,status,published_at,author_id,sport_id,sports(name)").order("created_at",{ascending:false}),
   supabase.from("events").select("id,title,description,venue,starts_at,ends_at,ticketed,published,archived_at,sport_id,sports(name)").order("starts_at")
  ]);
  const fail=a.error||e.error;
  if(fail)setError(fail.message);
  else{setArticles(a.data||[]);setEvents(e.data||[]);}
  setLoading(false);
 }
 useEffect(()=>{load()},[allowed]);
 function resetArticle(){setEditingArticle(null);setArticle(blankArticle);setError("");}
 function resetEvent(){setEditingEvent(null);setEvent(blankEvent);setError("");}
 function editArticle(item){
  setEditingArticle(item.id);
  setArticle({sport_id:item.sport_id||"",title:item.title||"",slug:item.slug||"",excerpt:item.excerpt||"",body:item.body||"",cover_image_url:item.cover_image_url||"",status:item.status,published_at:item.published_at});
  setError("");
 }
 function editEvent(item){
  setEditingEvent(item.id);
  setEvent({sport_id:item.sport_id||"",title:item.title||"",description:item.description||"",venue:item.venue||"",starts_at:item.starts_at?new Date(item.starts_at).toISOString().slice(0,16):"",ends_at:item.ends_at?new Date(item.ends_at).toISOString().slice(0,16):"",published:item.published,ticketed:item.ticketed,ticket_price:"",ticket_quantity:""});
  setError("");
 }
 async function saveArticle(e){
  e.preventDefault();if(!allowed||!supabase||!user)return;
  const slug=(article.slug||article.title).toLowerCase().trim().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
  if(!slug){setError("Add a valid headline or URL slug.");return;}
  setBusy(true);setError("");
  const payload={sport_id:article.sport_id||null,title:article.title.trim(),slug,excerpt:article.excerpt.trim()||null,body:article.body.trim()||null,cover_image_url:article.cover_image_url.trim()||null,status:article.status,published_at:article.status==="published"?(article.published_at||new Date().toISOString()):null};
  const response=editingArticle
   ?await supabase.from("articles").update(payload).eq("id",editingArticle).select("id").maybeSingle()
   :await supabase.from("articles").insert({...payload,author_id:user.id}).select("id").single();
  if(response.error)setError(response.error.message);
  else if(!response.data)setError("No article was changed. Check your author and sport assignment permissions.");
  else{resetArticle();await load();}
  setBusy(false);
 }
 async function saveEvent(e){
  e.preventDefault();if(!allowed||!supabase)return;
  if(!event.starts_at){setError("Choose an event start date and time.");return;}
  if(event.ends_at&&new Date(event.ends_at)<new Date(event.starts_at)){setError("Event end time cannot be earlier than its start time.");return;}
  if(!editingEvent&&event.ticketed&&(Number(event.ticket_price)<2||!Number.isInteger(Number(event.ticket_quantity))||Number(event.ticket_quantity)<1)){setError("Ticketed events need a ticket price of at least R2 and a positive whole-number ticket quantity.");return;}
  setBusy(true);setError("");
  const payload={sport_id:event.sport_id||null,title:event.title.trim(),description:event.description.trim()||null,venue:event.venue.trim()||null,starts_at:new Date(event.starts_at).toISOString(),ends_at:event.ends_at?new Date(event.ends_at).toISOString():null,published:Boolean(event.published&&!events.find(item=>item.id===editingEvent)?.archived_at),ticketed:editingEvent?event.ticketed:Boolean(event.ticketed)};
  const response=editingEvent
   ?await supabase.from("events").update(payload).eq("id",editingEvent).select("id").maybeSingle()
   :await supabase.from("events").insert(payload).select("id").single();
  if(response.error)setError(response.error.message);
  else if(!response.data)setError("No event was changed. Check your sport assignment permissions.");
  else{
   let ticketError=null;
   if(!editingEvent&&event.ticketed){
    const created=await supabase.from("event_ticket_types").insert({event_id:response.data.id,name:"General Admission",price_cents:Math.round(Number(event.ticket_price)*100),quantity_available:Number(event.ticket_quantity),max_per_order:6,is_active:true});
    ticketError=created.error;
   }
   resetEvent();await load();
   if(ticketError)setError("Event saved, but the general admission ticket type could not be created: "+ticketError.message);
  }
  setBusy(false);
 }
 async function setArticleStatus(item,status){
  if(!allowed||!supabase)return;
  setBusy(true);setError("");
  const payload={status,published_at:status==="published"?(item.published_at||new Date().toISOString()):null};
  const {error}=await supabase.from("articles").update(payload).eq("id",item.id);
  if(error)setError(error.message);else await load();
  setBusy(false);
 }
 async function setEventPublished(item,published){
  if(!allowed||!supabase||item.archived_at)return;
  setBusy(true);setError("");
  const {error}=await supabase.from("events").update({published}).eq("id",item.id);
  if(error)setError(error.message);else await load();
  setBusy(false);
 }
 async function archiveEvent(item,restore=false){
  if(!allowed||!supabase)return;
  const message=restore?"Restore this event as an unpublished draft?":"Archive this event? It will be unpublished and ticket sales will stop. Existing ticket and order history will be retained.";
  if(!window.confirm(message))return;
  setBusy(true);setError("");
  const {error}=await supabase.from("events").update({archived_at:restore?null:new Date().toISOString(),published:false}).eq("id",item.id);
  if(error)setError(error.message);else await load();
  setBusy(false);
 }
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="Only sport administrators and super administrators can publish news and events."/></main></>;
 const sportOptions=sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>);
 return <><Header title="News & events" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">PUBLISHING WORKSPACE</span><h1>News & events</h1><p>Manage stories and event records. Sport administrators are restricted by assigned sport scope; institution-wide content is reserved for super administrators.</p></div>
  <form className="form-card" onSubmit={saveArticle}><h3>{editingArticle?"Edit story":"New story"}</h3>
   <label>Sport scope<select required={!isSuper} value={article.sport_id} onChange={e=>setArticle({...article,sport_id:e.target.value})}><option value="" disabled={!isSuper}>Institution-wide {isSuper?"(super administrator)": "(super administrator only)"}</option>{sportOptions}</select></label>
   {!isSuper&&!editingArticle&&<p className="muted">Choose a sport assigned to your administrator account. Institution-wide publishing is restricted to the super administrator.</p>}
   <label>Headline<input required maxLength="180" value={article.title} onChange={e=>setArticle({...article,title:e.target.value})}/></label>
   <label>Slug<input maxLength="200" value={article.slug} onChange={e=>setArticle({...article,slug:e.target.value})} placeholder="generated-from-headline"/></label>
   <label>Summary<textarea maxLength="500" value={article.excerpt} onChange={e=>setArticle({...article,excerpt:e.target.value})}/></label>
   <label>Story body<textarea required maxLength="50000" value={article.body} onChange={e=>setArticle({...article,body:e.target.value})}/></label>
   <label>Cover image URL<input type="url" value={article.cover_image_url} onChange={e=>setArticle({...article,cover_image_url:e.target.value})}/></label>
   <label>Workflow<select value={article.status} onChange={e=>setArticle({...article,status:e.target.value})}><option value="draft">Save draft</option><option value="published">Publish now</option><option value="archived">Archive</option></select></label>
   <div className="admin-form-actions"><button className="btn primary" disabled={busy}>{busy?"Saving…":editingArticle?"Save story changes":"Save story"}</button>{editingArticle&&<button type="button" onClick={resetArticle}>Cancel edit</button>}</div>
  </form>
  <form className="form-card" onSubmit={saveEvent}><h3>{editingEvent?"Edit event":"New event"}</h3>
   <label>Sport scope<select required={!isSuper} value={event.sport_id} onChange={e=>setEvent({...event,sport_id:e.target.value})}><option value="" disabled={!isSuper}>Institution-wide {isSuper?"(super administrator)": "(super administrator only)"}</option>{sportOptions}</select></label>
   <label>Event name<input required maxLength="180" value={event.title} onChange={e=>setEvent({...event,title:e.target.value})}/></label>
   <label>Description<textarea maxLength="5000" value={event.description} onChange={e=>setEvent({...event,description:e.target.value})}/></label>
   <label>Venue<input maxLength="240" value={event.venue} onChange={e=>setEvent({...event,venue:e.target.value})}/></label>
   <label>Start<input type="datetime-local" required value={event.starts_at} onChange={e=>setEvent({...event,starts_at:e.target.value})}/></label>
   <label>End<input type="datetime-local" min={event.starts_at||undefined} value={event.ends_at} onChange={e=>setEvent({...event,ends_at:e.target.value})}/></label>
   {editingEvent?<p className="muted">Ticket configuration is preserved while editing event details. Existing ticket inventory and orders are not modified.</p>:<><label className="check-label"><input type="checkbox" checked={event.ticketed} onChange={e=>setEvent({...event,ticketed:e.target.checked})}/> Ticketed event</label>{event.ticketed&&<><label>General admission price (R)<input type="number" min="2" step="0.01" required value={event.ticket_price} onChange={e=>setEvent({...event,ticket_price:e.target.value})}/></label><label>Tickets available<input type="number" min="1" step="1" required value={event.ticket_quantity} onChange={e=>setEvent({...event,ticket_quantity:e.target.value})}/></label></>}</>}
   <label className="check-label"><input type="checkbox" checked={event.published} disabled={Boolean(editingEvent&&events.find(item=>item.id===editingEvent)?.archived_at)} onChange={e=>setEvent({...event,published:e.target.checked})}/> Publish event</label>
   <div className="admin-form-actions"><button className="btn primary" disabled={busy}>{busy?"Saving…":editingEvent?"Save event changes":"Save event"}</button>{editingEvent&&<button type="button" onClick={resetEvent}>Cancel edit</button>}</div>
  </form>
  {error&&<p className="form-error">{error}</p>}
  <Section title="Stories">{loading?<p className="muted">Loading stories…</p>:articles.length?articles.map(item=><div className="sponsor-card admin-sponsor" key={item.id}><div><b>{item.title}</b><small>{item.sports?.name||"Institution-wide"} · {item.status}</small></div>{canEditArticle(item)&&<><button type="button" disabled={busy} onClick={()=>editArticle(item)}>Edit</button>{item.status==="published"?<button type="button" disabled={busy} onClick={()=>setArticleStatus(item,"draft")}>Unpublish</button>:item.status!=="archived"?<button type="button" disabled={busy} onClick={()=>setArticleStatus(item,"published")}>Publish</button>:<button type="button" disabled={busy} onClick={()=>setArticleStatus(item,"draft")}>Restore</button>}{item.status!=="archived"&&<button type="button" disabled={busy} onClick={()=>setArticleStatus(item,"archived")}>Archive</button>}</>}</div>):<Empty title="No stories yet" body="No article records have been created."/>}</Section>
  <Section title="Events">{loading?<p className="muted">Loading events…</p>:events.length?events.map(item=><div className="sponsor-card admin-sponsor" key={item.id}><div><b>{item.title}</b><small>{item.sports?.name||"Institution-wide"} · {dateLabel(item.starts_at)} · {item.archived_at?"Archived":item.published?"Published":"Draft"}</small></div><button type="button" disabled={busy} onClick={()=>editEvent(item)}>Edit</button>{item.archived_at?<button type="button" disabled={busy} onClick={()=>archiveEvent(item,true)}>Restore</button>:<><button type="button" disabled={busy} onClick={()=>setEventPublished(item,!item.published)}>{item.published?"Unpublish":"Publish"}</button><button type="button" disabled={busy} onClick={()=>archiveEvent(item)}>Archive</button></>}</div>):<Empty title="No events yet" body="No event records have been created."/>}</Section>
  <p className="muted">Archiving an event unpublishes it and stops public ticket availability while retaining ticket and order history. Editing an existing event does not change ticket prices or inventory.</p>
 </main></>;
}

function AdminSponsors({user,roles}) {
 const allowed=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const [items,setItems]=useState([]),[busy,setBusy]=useState(false),[error,setError]=useState(""),[editing,setEditing]=useState(null);
 const blank={name:"",slug:"",description:"",logo_url:"",website_url:"",sponsorship_tier:"",display_order:0,is_active:true};
 const [form,setForm]=useState(blank);
 async function load(){if(!supabase||!allowed)return;const {data,error}=await supabase.from("sponsors").select("id,name,slug,description,logo_url,website_url,sponsorship_tier,display_order,is_active").order("display_order");if(error)setError(error.message);else setItems(data||[]);}
 useEffect(()=>{load()},[allowed]);
 function edit(item){setEditing(item.id);setForm({...blank,...item});setError("");}
 function reset(){setEditing(null);setForm(blank);setError("");}
 async function save(e){e.preventDefault();if(!allowed||!supabase)return;setBusy(true);setError("");const payload={name:form.name.trim(),slug:(form.slug||form.name).trim().toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,""),description:form.description||null,logo_url:form.logo_url||null,website_url:form.website_url||null,sponsorship_tier:form.sponsorship_tier||null,display_order:Number(form.display_order)||0,is_active:Boolean(form.is_active)};const result=editing?await supabase.from("sponsors").update(payload).eq("id",editing):await supabase.from("sponsors").insert(payload);if(result.error)setError(result.error.message);else{reset();await load();}setBusy(false);}
 async function archive(id){if(!allowed||!supabase)return;const {error}=await supabase.from("sponsors").update({is_active:false}).eq("id",id);if(error)setError(error.message);else load();}
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="This account does not have a CUT Sport administrator role."/></main></>;
 return <><Header title="Sport admin" back/><main className="page"><div className="page-intro"><span className="eyebrow">ROLE-SECURED MANAGEMENT</span><h1>Sponsor directory</h1><p>Manage active sponsor profiles. Database permissions remain the final authority.</p></div>
 <form className="form-card" onSubmit={save}><h3>{editing?"Edit sponsor":"Add sponsor"}</h3>
 <label>Organisation name<input required value={form.name} onChange={e=>setForm({...form,name:e.target.value})}/></label>
 <label>Slug<input value={form.slug} onChange={e=>setForm({...form,slug:e.target.value})} placeholder="generated-from-name"/></label>
 <label>Description<textarea value={form.description||""} onChange={e=>setForm({...form,description:e.target.value})}/></label>
 <label>Logo URL<input type="url" value={form.logo_url||""} onChange={e=>setForm({...form,logo_url:e.target.value})}/></label>
 <label>Website URL<input type="url" value={form.website_url||""} onChange={e=>setForm({...form,website_url:e.target.value})}/></label>
 <label>Sponsorship tier<input value={form.sponsorship_tier||""} onChange={e=>setForm({...form,sponsorship_tier:e.target.value})}/></label>
 <label>Display order<input type="number" value={form.display_order??0} onChange={e=>setForm({...form,display_order:e.target.value})}/></label>
 <label className="check-label"><input type="checkbox" checked={Boolean(form.is_active)} onChange={e=>setForm({...form,is_active:e.target.checked})}/> Published / active</label>
 <button className="btn primary" disabled={busy}>{busy?"Saving…":editing?"Save changes":"Create sponsor"}</button>{editing&&<button type="button" onClick={reset}>Cancel edit</button>}{error&&<p className="form-error">{error}</p>}</form>
 <Section title="Existing sponsors">{items.length?items.map(item=><div className="sponsor-card admin-sponsor" key={item.id}><div><b>{item.name}</b><small>{item.is_active?"Active":"Archived"} · {item.sponsorship_tier||"No tier"}</small></div><button onClick={()=>edit(item)}>Edit</button>{item.is_active&&<button onClick={()=>archive(item.id)}>Archive</button>}</div>):<Empty title="No sponsor records" body="Add an approved sponsor profile when the details are available."/>}</Section>
 </main></>;
}





function AdminPerformance({roles}) {
 const allowed=roles.some(r=>["sport_admin","super_admin","coach"].includes(r));
 const [records,setRecords]=useState([]),[busy,setBusy]=useState(false),[error,setError]=useState("");
 const [sportId,setSportId]=useState(""),[season,setSeason]=useState(""),[athleteId,setAthleteId]=useState(""),[metricKey,setMetricKey]=useState("");
 async function load(){
  if(!supabase||!allowed)return;
  setBusy(true);setError("");
  const {data,error}=await supabase.from("athlete_statistics")
   .select("id,athlete_id,competition_id,fixture_id,season,period_label,metrics,approval_status,created_at,athletes(id,full_name,preferred_name,position,squad_number,sport_id,team_id,sports(name),teams(name)),competitions(name),fixtures(opponent,starts_at)")
   .eq("approval_status","approved").order("created_at",{ascending:false}).limit(300);
  if(error)setError(error.message);else setRecords(data||[]);
  setBusy(false);
 }
 useEffect(()=>{load()},[allowed]);
 const filtered=records.filter(r=>(!sportId||r.athletes?.sport_id===sportId)&&(!season||r.season===season)&&(!athleteId||r.athlete_id===athleteId));
 const sportOptions=[...new Map(records.filter(r=>r.athletes?.sport_id).map(r=>[r.athletes.sport_id,{id:r.athletes.sport_id,name:r.athletes.sports?.name||"Sport"}])).values()].sort((a,b)=>a.name.localeCompare(b.name));
 const seasonOptions=[...new Set(records.map(r=>r.season).filter(Boolean))].sort().reverse();
 const athleteOptions=[...new Map(records.filter(r=>r.athletes).map(r=>[r.athlete_id,{id:r.athlete_id,name:r.athletes.preferred_name||r.athletes.full_name}])).values()].sort((a,b)=>a.name.localeCompare(b.name));
 const metricKeys=[...new Set(filtered.flatMap(r=>Object.entries(r.metrics||{}).filter(([,v])=>typeof v==="number"&&Number.isFinite(v)).map(([k])=>k)))].sort();
 const selectedMetric=metricKeys.includes(metricKey)?metricKey:(metricKeys[0]||"");
 const metricRows=filtered.filter(r=>typeof r.metrics?.[selectedMetric]==="number").slice(0,12).reverse();
 const values=filtered.map(r=>r.metrics?.[selectedMetric]).filter(v=>typeof v==="number"&&Number.isFinite(v));
 const average=values.length?values.reduce((a,b)=>a+b,0)/values.length:0;
 const topValue=Math.max(1,...metricRows.map(r=>Number(r.metrics[selectedMetric])));
 if(!allowed)return <><Header title="Performance access required" back/><main className="page"><Empty title="Restricted area" body="A coach, assigned sport administrator or super administrator role is required."/></main></>;
 return <><Header title="Athlete performance" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">ATHLETE DEVELOPMENT</span><h1>Performance dashboard.</h1><p>Explore approved performance records within your assigned athlete, team or sport permissions. Pending statistics are excluded until an authorised reviewer approves them.</p></div>
  <div className="performance-filters">
   <label>Sport<select value={sportId} onChange={e=>setSportId(e.target.value)}><option value="">All assigned sports</option>{sportOptions.map(x=><option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
   <label>Season<select value={season} onChange={e=>setSeason(e.target.value)}><option value="">All seasons</option>{seasonOptions.map(x=><option key={x} value={x}>{x}</option>)}</select></label>
   <label>Athlete<select value={athleteId} onChange={e=>setAthleteId(e.target.value)}><option value="">All athletes</option>{athleteOptions.map(x=><option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
  </div>
  {error&&<p className="form-error">{error}</p>}
  <div className="admin-stats"><div><b>{filtered.length}</b><small>Approved records</small></div><div><b>{new Set(filtered.map(r=>r.athlete_id)).size}</b><small>Athletes tracked</small></div><div><b>{metricKeys.length}</b><small>Numeric metrics</small></div><div><b>{selectedMetric?average.toFixed(1):"—"}</b><small>{selectedMetric?selectedMetric.replaceAll("_"," ")+" average":"No metric selected"}</small></div></div>
  <Section title="Metric trend">{metricKeys.length?<><label className="metric-picker">Choose metric<select value={selectedMetric} onChange={e=>setMetricKey(e.target.value)}>{metricKeys.map(k=><option key={k} value={k}>{k.replaceAll("_"," ")}</option>)}</select></label><div className="metric-trend">{metricRows.map(r=><div className="metric-trend-row" key={r.id}><span>{r.athletes?.preferred_name||r.athletes?.full_name||"Athlete"}<small>{r.period_label||r.season||dateLabel(r.created_at)}</small></span><div className="metric-bar"><i style={{width:Math.max(3,Number(r.metrics[selectedMetric])/topValue*100)+"%"}}/></div><b>{r.metrics[selectedMetric]}</b></div>)}</div></>:<Empty title={busy?"Loading performance":"No approved numeric metrics yet"} body={busy?"Approved athlete statistics are being retrieved.":"Once coaches submit performance records and an authorised reviewer approves them, metric trends will appear here."}/>}</Section>
  <Section title="Approved performance records">{filtered.length?filtered.map(r=><article className="performance-record" key={r.id}><div className="performance-record-head"><div><b>{r.athletes?.preferred_name||r.athletes?.full_name||"Athlete"}</b><small>{r.athletes?.sports?.name||"Sport"} · {r.athletes?.teams?.name||"No team"} · {r.season||"Season not set"}</small></div><span>{dateLabel(r.created_at)}</span></div><p>{r.competitions?.name||r.fixtures?.opponent||r.period_label||"Performance entry"}</p><div className="performance-metric-chips">{Object.entries(r.metrics||{}).map(([k,v])=><span key={k}><b>{String(v)}</b> {k.replaceAll("_"," ")}</span>)}</div></article>):<Empty title={busy?"Loading records":"No records match these filters"} body="Try another season, sport or athlete. Only approved performance records are shown."/>}</Section>
  <div className="admin-notice"><ShieldCheck/><div><b>Verified performance data</b><p>Only approved records are included. Coaches and sport staff can view only the athlete records allowed by the existing Supabase row-level security policies.</p></div></div>
 </main></>;
}

function AdminEventReports({roles}) {
 const allowed=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const [events,setEvents]=useState([]),[eventId,setEventId]=useState(""),[report,setReport]=useState(null);
 const [busy,setBusy]=useState(false),[error,setError]=useState("");
 useEffect(()=>{
  let active=true;
  if(!allowed||!supabase)return;
  supabase.functions.invoke("event-report",{body:{}}).then(({data,error})=>{
   if(!active)return;
   if(error||data?.error){setError(data?.error||error?.message||"Unable to load events.");return}
   const rows=data?.events||[];setEvents(rows);if(rows.length)setEventId(rows[0].id);
  });
  return()=>{active=false};
 },[allowed]);
 useEffect(()=>{
  let active=true;
  if(!allowed||!eventId||!supabase){setReport(null);return}
  setBusy(true);setError("");
  supabase.functions.invoke("event-report",{body:{eventId}}).then(({data,error})=>{
   if(!active)return;
   if(error||data?.error){setError(data?.error||error?.message||"Unable to load the event report.");setReport(null)}
   else setReport(data);
   setBusy(false);
  });
  return()=>{active=false};
 },[allowed,eventId]);
 function exportAttendees(){
  if(!report?.attendees?.length)return;
  const rows=[["Attendee","Ticket type","Issued at","Check-in status","Checked in at"],...report.attendees.map(a=>[a.attendee_name,a.ticket_type,a.issued_at,a.redeemed_at?"Checked in":"Not checked in",a.redeemed_at||""])];
  const csv=rows.map(row=>row.map(value=>'"'+String(value??"").replaceAll('"','""')+'"').join(",")).join("\r\n");
  const url=URL.createObjectURL(new Blob([csv],{type:"text/csv;charset=utf-8"}));
  const link=document.createElement("a");link.href=url;link.download="cut-sport-attendees.csv";link.click();URL.revokeObjectURL(url);
 }
 if(!allowed)return <><Header title="Event reports access required" back/><main className="page"><Empty title="Restricted area" body="An assigned sport administrator or super administrator role is required."/></main></>;
 const summary=report?.summary;
 return <><Header title="Event reports" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · EVENT MANAGEMENT</span><h1>Sales & attendance.</h1><p>Ticket sales are counted only from verified successful payments. Attendee names are returned by the protected reporting service only for events within your assigned sport scope.</p></div>
  <div className="form-card"><label>Select event<select value={eventId} onChange={e=>setEventId(e.target.value)}><option value="">Choose event</option>{events.map(e=><option key={e.id} value={e.id}>{e.title} · {dateLabel(e.starts_at)}</option>)}</select></label>{!events.length&&!error&&<p className="muted">No events are available within your assigned scope.</p>}</div>
  {error&&<p className="form-error">{error}</p>}
  {busy&&<div className="admin-notice"><ClipboardList/><div><b>Building event report…</b><p>Retrieving verified ticket sales and the attendee register.</p></div></div>}
  {report&&<>
   <div className="event-report-title"><div><h2>{report.event.title}</h2><p>{dateLabel(report.event.starts_at)} · {report.event.venue||"Venue TBC"} · {report.event.published?"Published":"Unpublished"}</p></div><span>{report.event.ticketed?"Ticketed event":"Non-ticketed event"}</span></div>
   <div className="admin-stats"><div><b>{summary.tickets_sold}</b><small>Paid tickets sold</small></div><div><b>{summary.checked_in}/{summary.tickets_issued}</b><small>Checked in</small></div><div><b>{money(summary.paid_revenue_cents)}</b><small>Verified revenue</small></div><div><b>{summary.remaining_capacity}</b><small>Remaining capacity</small></div></div>
   <Section title="Ticket type performance">{report.ticketTypes.length?<div className="event-report-list">{report.ticketTypes.map(t=><article key={t.id}><div><b>{t.name}</b><small>{t.is_active?"On sale":"Inactive"} · {money(t.price_cents)} each</small></div><div><b>{t.sold} sold</b><small>{money(t.revenue_cents)} · {t.quantity_available} remaining</small></div></article>)}</div>:<Empty title="No ticket types" body="Ticket categories and inventory will appear when configured for this event."/>}</Section>
   <Section title="Attendee register"><div className="attendee-toolbar"><span>{report.attendees.length} ticket(s) issued</span><button type="button" onClick={exportAttendees} disabled={!report.attendees.length}>Export CSV</button></div>{report.attendees.length?<div className="event-report-list">{report.attendees.map(a=><article key={a.id}><div><b>{a.attendee_name}</b><small>{a.ticket_type} · Issued {dateLabel(a.issued_at)}</small></div><span className={"checkin-status "+(a.redeemed_at?"checked-in":"not-checked")}>{a.redeemed_at?"Checked in":"Not checked in"}</span></article>)}</div>:<Empty title="No tickets issued yet" body="Attendee records will appear after successful payments have been confirmed."/>}</Section>
   <p className="muted">This register contains attendee names and ticket/check-in status only. Email addresses, phone numbers, student numbers and payment credentials are not included.</p>
  </>}
 </main></>;
}

function AdminShopOrders({roles}) {
 const allowed=roles.some(r=>["shop_admin","super_admin"].includes(r));
 const [items,setItems]=useState([]),[filter,setFilter]=useState("all"),[busy,setBusy]=useState(false),[busyOrder,setBusyOrder]=useState(""),[error,setError]=useState(""),[notes,setNotes]=useState({});
 async function load(){
  if(!supabase||!allowed)return;
  setBusy(true);setError("");
  const {data,error}=await supabase.from("orders")
   .select("id,order_number,status,payment_status,total_cents,currency,created_at,order_items(id,product_name,quantity,unit_price_cents,item_type)")
   .eq("order_kind","shop").order("created_at",{ascending:false}).limit(100);
  if(error)setError(error.message);else setItems(data||[]);
  setBusy(false);
 }
 useEffect(()=>{load()},[allowed]);
 async function transition(order,newStatus){
  if(!allowed||!supabase||busyOrder)return;
  setBusyOrder(order.id);setError("");
  const {data,error}=await supabase.functions.invoke("manage-shop-order",{body:{orderId:order.id,newStatus,note:notes[order.id]||null}});
  if(error||data?.error){setError(data?.error||error?.message||"Unable to update this order.");setBusyOrder("");return}
  setNotes(old=>({...old,[order.id]:""}));
  await load();
  setBusyOrder("");
 }
 const visible=items.filter(x=>filter==="all"||x.status===filter);
 const paid=items.filter(x=>x.payment_status==="succeeded");
 const paidTotal=paid.reduce((sum,x)=>sum+Number(x.total_cents||0),0);
 if(!allowed)return <><Header title="Shop admin access required" back/><main className="page"><Empty title="Restricted area" body="A shop administrator or super administrator role is required."/></main></>;
 return <><Header title="Shop orders" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">SHOP MANAGEMENT</span><h1>Orders & fulfilment.</h1><p>Review paid shop orders and progress them through fulfilment. Payment confirmation remains controlled by the verified Yoco webhook; customer contact details and payment credentials are not displayed here.</p></div>
  <div className="admin-stats"><div><b>{items.length}</b><small>Orders loaded</small></div><div><b>{paid.length}</b><small>Paid orders</small></div><div><b>{money(paidTotal)}</b><small>Verified paid value</small></div><div><b>{items.filter(x=>x.status==="processing").length}</b><small>Processing</small></div></div>
  <div className="orders-toolbar"><label>Filter orders<select value={filter} onChange={e=>setFilter(e.target.value)}><option value="all">All statuses</option>{["pending","paid","processing","fulfilled","cancelled","refunded"].map(s=><option key={s} value={s}>{s}</option>)}</select></label><button type="button" onClick={load} disabled={busy||Boolean(busyOrder)}>{busy?"Refreshing…":"Refresh orders"}</button></div>
  {error&&<p className="form-error">{error}</p>}
  {visible.length?visible.map(order=><article className="order-admin-card" key={order.id}>
   <div className="order-admin-head"><div><b>Order {order.order_number}</b><small>{dateLabel(order.created_at)}</small></div><span className={"order-status "+(order.payment_status==="succeeded"?"is-paid":"")}>{order.status}</span></div>
   <div className="order-admin-lines">{(order.order_items||[]).filter(line=>line.item_type==="product").map(line=><div key={line.id}><span>{line.product_name} × {line.quantity}</span><b>{money(Number(line.unit_price_cents||0)*Number(line.quantity||0))}</b></div>)}</div>
   <div className="order-admin-foot"><span>Payment: {order.payment_status}</span><b>{money(order.total_cents)} {order.currency||"ZAR"}</b></div>
   {order.payment_status==="succeeded"&&(order.status==="paid"||order.status==="processing")&&<div className="order-fulfilment-controls">
    <label>Internal fulfilment note (optional)<textarea maxLength="500" rows="2" value={notes[order.id]||""} onChange={e=>setNotes(old=>({...old,[order.id]:e.target.value}))} placeholder="e.g. Packed and ready for collection"/></label>
    <button type="button" disabled={busy||Boolean(busyOrder)} onClick={()=>transition(order,order.status==="paid"?"processing":"fulfilled")}>{busyOrder===order.id?"Updating…":order.status==="paid"?"Start processing":"Mark as fulfilled"}</button>
   </div>}
  </article>):<Empty title={busy?"Loading orders":"No orders found"} body={busy?"Shop order records are being retrieved.":filter==="all"?"Paid and pending shop orders will appear here after customers check out.":"No shop orders match this status filter."}/>}
  <p className="muted">Only verified paid orders can enter fulfilment. Permitted transitions are Paid → Processing → Fulfilled. Cancellation and refunds remain outside this workflow and must be handled through the payment provider's authorised process.</p>
 </main></>;
}

function AdminProducts({roles,products,setProducts}) {
 const allowed=roles.some(r=>["shop_admin","super_admin"].includes(r));
 const blank={name:"",slug:"",description:"",category:"",price:"",stock_quantity:"0",image_url:"",is_active:true};
 const [items,setItems]=useState([]),[form,setForm]=useState(blank),[editing,setEditing]=useState(null),[busy,setBusy]=useState(false),[error,setError]=useState("");
 async function load(){
  if(!supabase||!allowed)return;
  const {data,error}=await supabase.from("products").select("id,name,slug,description,category,price_cents,image_url,stock_quantity,is_active,created_at").order("created_at",{ascending:false});
  if(error){setError(error.message);return}
  setItems(data||[]);
  setProducts((data||[]).filter(p=>p.is_active));
 }
 useEffect(()=>{load()},[allowed]);
 function edit(item){
  setEditing(item.id);
  setForm({...blank,...item,price:(Number(item.price_cents||0)/100).toFixed(2),stock_quantity:String(item.stock_quantity??0)});
  setError("");
 }
 function reset(){setEditing(null);setForm(blank);setError("")}
 async function save(e){
  e.preventDefault();
  if(!allowed||!supabase)return;
  const price=Number(form.price),stock=Number(form.stock_quantity);
  if(!Number.isFinite(price)||price<0||!Number.isInteger(stock)||stock<0){setError("Enter a valid non-negative price and whole-number stock quantity.");return}
  const slug=(form.slug||form.name).trim().toLowerCase().replace(/[^a-z0-9]+/g,"-").replace(/(^-|-$)/g,"");
  if(!slug){setError("A product name is required to create its URL slug.");return}
  setBusy(true);setError("");
  const payload={name:form.name.trim(),slug,description:form.description.trim()||null,category:form.category.trim()||null,price_cents:Math.round(price*100),stock_quantity:stock,image_url:form.image_url.trim()||null,is_active:Boolean(form.is_active)};
  const result=editing?await supabase.from("products").update(payload).eq("id",editing):await supabase.from("products").insert(payload);
  if(result.error)setError(result.error.message);
  else{reset();await load()}
  setBusy(false);
 }
 async function archive(id){
  if(!allowed||!supabase)return;
  setBusy(true);setError("");
  const {error}=await supabase.from("products").update({is_active:false}).eq("id",id);
  if(error)setError(error.message);else await load();
  setBusy(false);
 }
 if(!allowed)return <><Header title="Shop admin access required" back/><main className="page"><Empty title="Restricted area" body="A shop administrator or super administrator role is required."/></main></>;
 return <><Header title="Shop catalogue" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">SHOP MANAGEMENT</span><h1>Heritage Collection</h1><p>Create and maintain official CUT Sport products. Prices and stock are stored in Supabase and revalidated by the checkout backend.</p></div>
  <form className="form-card" onSubmit={save}>
   <h3>{editing?"Edit product":"Add product"}</h3>
   <label>Product name<input required maxLength="120" value={form.name} onChange={e=>setForm({...form,name:e.target.value})}/></label>
   <label>URL slug<input maxLength="140" value={form.slug} onChange={e=>setForm({...form,slug:e.target.value})} placeholder="generated-from-name"/></label>
   <label>Category<input value={form.category||""} onChange={e=>setForm({...form,category:e.target.value})} placeholder="Apparel, accessories, equipment…"/></label>
   <label>Description<textarea value={form.description||""} onChange={e=>setForm({...form,description:e.target.value})}/></label>
   <label>Price (R)<input type="number" min="0" step="0.01" required value={form.price} onChange={e=>setForm({...form,price:e.target.value})}/></label>
   <label>Available stock<input type="number" min="0" step="1" required value={form.stock_quantity} onChange={e=>setForm({...form,stock_quantity:e.target.value})}/></label>
   <label>Product image URL<input type="url" value={form.image_url||""} onChange={e=>setForm({...form,image_url:e.target.value})}/></label>
   <label className="check-label"><input type="checkbox" checked={Boolean(form.is_active)} onChange={e=>setForm({...form,is_active:e.target.checked})}/> Publish in the public shop</label>
   <button className="btn primary" disabled={busy}>{busy?"Saving…":editing?"Save product":"Create product"}</button>
   {editing&&<button type="button" onClick={reset}>Cancel edit</button>}
   {error&&<p className="form-error">{error}</p>}
  </form>
  <Section title="Catalogue records">{items.length?items.map(item=><div className="sponsor-card admin-sponsor admin-product-row" key={item.id}><div>{item.image_url&&<img src={item.image_url} alt=""/>}<section><b>{item.name}</b><small>{money(item.price_cents)} · Stock {item.stock_quantity} · {item.is_active?"Published":"Archived"}</small></section></div><button disabled={busy} onClick={()=>edit(item)}>Edit</button>{item.is_active&&<button disabled={busy} onClick={()=>archive(item.id)}>Archive</button>}</div>):<Empty title="No products in the catalogue" body="Create a product when the official item, price and stock quantity are approved."/>}</Section>
 </main></>;
}

export default App;