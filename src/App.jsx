import React, { useEffect, useRef, useState } from 'react';
import { Link, Route, Routes, useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { ArrowLeft, Bell, CalendarDays, ChevronRight, ClipboardList, FileText, Handshake, LogOut, MapPin, Newspaper, Package, ShieldCheck, ShoppingBag, Ticket, Trophy, Users, CalendarClock, Settings2, MessageSquare, Send, Reply } from 'lucide-react';
import BottomNav from './components/BottomNav';
import { api, money, dateLabel } from './lib/api';
import { supabase } from './lib/supabase';

const fallback = ['Athletics & Cross Country','Basketball','Cheerleading','Cricket','E-Sport','Football','Golf','Hockey','Netball','Rugby','Volleyball'].map((name,i)=>({id:String(i),name,slug:name.toLowerCase().replaceAll(' ','-')}));
function Empty({title,body}) { return <div className="empty"><Trophy/><b>{title}</b><p>{body}</p></div>; }
function Header({title='CUT Sport',back=false}) {
 const nav=useNavigate();
 const [unreadCount,setUnreadCount]=useState(0);
 useEffect(()=>{
  let active=true;
  if(!supabase){setUnreadCount(0);return()=>{active=false}}
  supabase.auth.getUser().then(async({data})=>{
   if(!active)return;
   if(!data.user){setUnreadCount(0);return}
   const {count,error}=await supabase.from("notifications").select("id",{count:"exact",head:true}).eq("user_id",data.user.id).is("read_at",null);
   if(active)setUnreadCount(error?0:(count||0));
  });
  return()=>{active=false};
 },[]);
 return <header className="topbar">{back?<button className="icon-btn" onClick={()=>nav(-1)}><ArrowLeft/></button>:<Link className="brand-mark" to="/"><b>CUT</b><small>SPORT</small></Link>}<div className="topbar-title"><b>{title}</b><small>HERITAGE · CULTURE · COMMUNITY</small></div><Link className="icon-btn notification-bell" to="/notifications" aria-label={unreadCount?("Notifications, "+unreadCount+" unread"):"Notifications"}><Bell/>{unreadCount>0&&<span className="notification-count">{unreadCount>99?"99+":unreadCount}</span>}</Link></header>;
}
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
 <Route path="/" element={<Home {...common}/>}/><Route path="/shop" element={<Shop {...common}/>}/><Route path="/shop/:slug" element={<Product {...common}/>}/><Route path="/cart" element={<Cart {...common}/>}/><Route path="/checkout" element={<Checkout cart={cart} setCart={setCart} user={user}/>}/><Route path="/payment/:result" element={<PaymentReturn user={user} result="success" cart={cart} setCart={setCart}/>}/><Route path="/events/:id" element={<EventTickets events={events} ticketTypes={ticketTypes} user={user}/>}/><Route path="/calendar" element={<CalendarPage {...common}/>}/><Route path="/sport" element={<Sport {...common}/>}/><Route path="/sport/:slug" element={<Hub {...common}/>}/><Route path="/news" element={<News {...common}/>}/><Route path="/news/:slug" element={<Story {...common}/>}/><Route path="/sponsors" element={<Sponsors {...common}/>}/><Route path="/profile" element={<Profile {...common}/>}/><Route path="/performance" element={<AthletePerformance user={user}/>}/><Route path="/trials" element={<Trials user={user} profile={profile}/>}/><Route path="/admin/recruitment" element={<AdminRecruitment roles={roles} user={user}/>}/><Route path="/admin" element={<AdminDashboard {...common}/>}/><Route path="/admin/sports" element={<AdminSports roles={roles} user={user} setSports={setSports}/>}/><Route path="/admin/sponsors" element={<AdminSponsors user={user} roles={roles}/>}/><Route path="/admin/products" element={<AdminProducts roles={roles} products={products} setProducts={setProducts}/>}/><Route path="/admin/shop-orders" element={<AdminShopOrders roles={roles}/>}/><Route path="/admin/athletes" element={<AdminAthletes roles={roles} user={user}/>}/><Route path="/admin/rosters" element={<AdminRosters roles={roles} user={user}/>}/><Route path="/admin/teams" element={<AdminTeams roles={roles} user={user}/>}/><Route path="/admin/performance" element={<AdminPerformance roles={roles}/>}/><Route path="/admin/calendar" element={<AdminCalendar roles={roles} sports={sports}/>}/><Route path="/admin/operations" element={<AdminOperations roles={roles} user={user}/>}/><Route path="/admin/approvals" element={<AdminApprovals roles={roles} user={user}/>}/><Route path="/admin/messages" element={<AdminMessages roles={roles} user={user}/>}/><Route path="/messages" element={<AthleteMessages user={user}/>}/><Route path="/admin/ticket-gate" element={<AdminTicketGate roles={roles}/>}/><Route path="/admin/event-reports" element={<AdminEventReports roles={roles}/>}/><Route path="/admin/editorial" element={<AdminEditorial roles={roles} user={user} sports={sports}/>}/><Route path="/notifications" element={<Personal title="Notifications" user={user} kind="notifications"/>}/><Route path="/tickets" element={<Personal title="My tickets" user={user} kind="tickets"/>}/><Route path="/orders" element={<Personal title="My orders" user={user} kind="orders"/>}/><Route path="*" element={<Home {...common}/>}/>
 </Routes><BottomNav/><Link className="cart-fab" to="/cart"><ShoppingBag size={18}/>{cart.reduce((n,x)=>n+x.qty,0)>0&&<span>{cart.reduce((n,x)=>n+x.qty,0)}</span>}</Link>{toast&&<div className="toast">{toast}</div>}</div></div>;
}
function Home({sports,products,fixtures,articles,events,sponsors}) {
 const upcoming=fixtures.filter(x=>['scheduled','live'].includes(x.status)).slice(0,3);
 return <><Header/><main className="page"><section className="hero"><span className="eyebrow">THE BLUES · CUT SPORT</span><h1>ONE CAMPUS.<br/><em>ONE TEAM.</em><br/>ONE BLUE.</h1><p>Every athlete. Every story. Every moment.</p><Link className="btn light" to="/sport">Explore CUT Sport <ChevronRight/></Link></section><div className="quick-links"><Link to="/calendar"><CalendarDays/>Calendar</Link><Link to="/sport"><Trophy/>Sport</Link><Link to="/shop"><ShoppingBag/>Shop</Link><Link to="/tickets"><Ticket/>Tickets</Link><Link to="/news"><Newspaper/>News</Link></div>
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
function getCheckoutRequestId(key) {
 try {
  const storageKey="cut-checkout-request";
  const saved=JSON.parse(sessionStorage.getItem(storageKey)||"null");
  if(saved?.key===key&&typeof saved.id==="string"&&saved.id)return saved.id;
  const id=crypto.randomUUID();
  sessionStorage.setItem(storageKey,JSON.stringify({key,id}));
  return id;
 } catch {
  return crypto.randomUUID();
 }
}
function Checkout({cart,setCart,user}) {
 const [busy,setBusy]=useState(false),[error,setError]=useState("");
 const total=cart.reduce((n,x)=>n+x.price_cents*x.qty,0);
 async function pay(){if(!user){setError("Sign in before checkout.");return}if(!cart.length)return;if(!supabase){setError("Payment service is unavailable.");return}setBusy(true);setError("");const {data,error:invokeError}=await supabase.functions.invoke("yoco-checkout",{body:{orderKind:"shop",requestId:getCheckoutRequestId("shop:"+JSON.stringify(cart.map(x=>[x.id,x.qty]).sort((a,b)=>String(a[0]).localeCompare(String(b[0]))))),lines:cart.map(x=>({product_id:x.id,quantity:x.qty}))}});if(invokeError||data?.error){setError(data?.error||invokeError?.message||"Unable to start checkout.");setBusy(false);return}if(!data?.redirectUrl){setError("Yoco did not return a checkout link.");setBusy(false);return}window.location.assign(data.redirectUrl);}
 return <><Header title="Secure checkout" back/><main className="page"><div className="page-intro"><span className="eyebrow">YOCO SECURE CHECKOUT</span><h1>Review your order.</h1><p>Your payment is handled on Yoco’s secure hosted checkout. CUT Sport never receives or stores your card details.</p></div>{!user?<><Empty title="Sign in to continue" body="Your order will be linked to your CUT Sport account."/><Link className="btn primary" to="/profile">Sign in</Link></>:cart.length? <><Section title="Order summary">{cart.map(x=><div className="cart-row" key={x.id}><b>{x.name}</b><span>{x.qty} × {money(x.price_cents)}</span></div>)}</Section><h2>Total {money(total)}</h2><button className="btn primary" disabled={busy||total<200} onClick={pay}>{busy?"Preparing secure checkout…":"Continue to Yoco"}</button>{total<200&&<p className="muted">Yoco card checkout has a minimum payment of R2.00.</p>}</>:<Empty title="Your bag is empty" body="Add items from the Heritage Collection before checking out."/>}{error&&<p className="form-error">{error}</p>}</main></>;
}
function PaymentReturn({user,result,cart,setCart}) {
 const [params]=useSearchParams(),route=useParams(),[order,setOrder]=useState(null),[error,setError]=useState("");
 const orderNumber=params.get("order");
 useEffect(()=>{
  let active=true,attempts=0,timer=null;
  if(!user||!orderNumber||!supabase){setOrder(null);return}
  const load=async()=>{
   const {data,error}=await supabase.from("orders").select("order_number,status,payment_status,total_cents,currency").eq("user_id",user.id).eq("order_number",orderNumber).maybeSingle();
   if(!active)return;
   if(error)setError(error.message);
   else{
    setOrder(data);
    if(data?.payment_status==="succeeded"){setError("");setCart([]);try{sessionStorage.removeItem("cut-checkout-request")}catch{}return}
   }
   attempts+=1;
   if(active&&attempts<24)timer=setTimeout(load,2500);
  };
  load();
  return()=>{active=false;if(timer)clearTimeout(timer)};
 },[user,orderNumber,setCart]);
 const paid=order?.payment_status==="succeeded";
 return <><Header title="Payment status" back/><main className="page"><div className="page-intro"><span className="eyebrow">YOCO PAYMENT</span><h1>{paid?"Payment confirmed":(route.result||result)==="cancelled"?"Checkout cancelled":(route.result||result)==="failed"?"Payment not completed":"Confirming your payment"}</h1><p>{paid?"Your payment has been verified. Your order is now recorded in CUT Sport.":(route.result||result)==="cancelled"?"You left the Yoco checkout. If you completed payment before returning, allow the secure notification to update your order.":(route.result||result)==="failed"?"The checkout did not complete. If your bank shows a debit, do not pay again until the order status has been checked.":"Yoco sends a signed notification to confirm payment. This return page is not itself proof of payment."}</p></div>{order&&<div className="personal-card"><b>Order {order.order_number}</b><p>{money(order.total_cents)} · {order.payment_status||order.status}</p></div>}{!orderNumber&&<p className="muted">No order reference was supplied.</p>}{error&&<p className="form-error">{error}</p>}<Link className="btn primary" to="/orders">View my orders</Link></main></>;
}
function EventTickets({events,ticketTypes,user}) {
 const {id}=useParams(),nav=useNavigate(),[quantity,setQuantity]=useState(1),[typeId,setTypeId]=useState(""),[busy,setBusy]=useState(false),[error,setError]=useState("");
 const event=events.find(x=>x.id===id),options=ticketTypes.filter(x=>x.event_id===id&&x.quantity_available>0),selected=options.find(x=>x.id===(typeId||options[0]?.id));
 useEffect(()=>{if(options.length&&!options.some(x=>x.id===typeId))setTypeId(options[0].id)},[id,options.map(x=>x.id).join("|")]);
 async function buy(){if(!user){nav("/profile");return}if(!selected||!supabase)return;setBusy(true);setError("");const {data,error:invokeError}=await supabase.functions.invoke("yoco-checkout",{body:{orderKind:"event",requestId:getCheckoutRequestId("event:"+id+":"+selected.id+":"+Number(quantity)),lines:[{ticket_type_id:selected.id,quantity:Number(quantity)}]}});if(invokeError||data?.error){setError(data?.error||invokeError?.message||"Unable to start ticket checkout.");setBusy(false);return}if(data?.redirectUrl)window.location.assign(data.redirectUrl);else{setError("Yoco did not return a checkout link.");setBusy(false)}}
 if(!event)return <><Header title="Event tickets" back/><main className="page"><Empty title="Event not found" body="This event may no longer be available."/></main></>;
 return <><Header title="Event tickets" back/><main className="page"><div className="page-intro"><span className="eyebrow">CUT SPORT · EVENT ACCESS</span><h1>{event.title}</h1><p>{dateLabel(event.starts_at)} · {event.venue||"Venue TBC"}</p></div>{options.length? <div className="form-card"><label>Ticket type<select value={selected?.id||""} onChange={e=>setTypeId(e.target.value)}>{options.map(x=><option key={x.id} value={x.id}>{x.name} · {money(x.price_cents)} · {x.quantity_available} available</option>)}</select></label><label>Quantity<input type="number" min="1" max={Math.min(selected?.max_per_order||1,selected?.quantity_available||1)} value={quantity} onChange={e=>setQuantity(Math.max(1,Math.min(Number(e.target.value)||1,selected?.max_per_order||1,selected?.quantity_available||1)))}/></label><h2>Total {money((selected?.price_cents||0)*quantity)}</h2><button className="btn primary" disabled={busy||!selected} onClick={buy}>{busy?"Preparing Yoco checkout…":"Buy tickets with Yoco"}</button>{error&&<p className="form-error">{error}</p>}</div>:<Empty title="Tickets are not on sale" body="Ticket types will appear here once CUT Sport publishes them."/>}</main></>;
}

function CalendarPage({sports,fixtures,competitions,events}) {
 const [trials,setTrials]=useState([]);
 const [trialError,setTrialError]=useState("");
 const [sportFilter,setSportFilter]=useState("all");
 const [typeFilter,setTypeFilter]=useState("all");
 const [search,setSearch]=useState("");
 const [fromDate,setFromDate]=useState("");
 const [toDate,setToDate]=useState("");
 const [busy,setBusy]=useState(true);
 useEffect(()=>{
  let active=true;
  async function loadTrials(){
   if(!supabase){if(active)setBusy(false);return}
   const {data,error}=await supabase.from("recruitment_opportunities")
    .select("id,title,description,venue,starts_at,closes_at,sport_id,team_id,status,sports(name),teams(name)")
    .eq("status","open").order("starts_at",{ascending:true}).limit(100);
   if(!active)return;
   if(error)setTrialError("Open trial dates could not be loaded. Other calendar records remain available.");
   setTrials(data||[]);setBusy(false);
  }
  loadTrials();
  return()=>{active=false};
 },[]);
 const items=[
  ...fixtures.map(f=>({id:"fixture-"+f.id,type:"Fixture",title:(f.teams?.name||"CUT")+" vs "+(f.opponent||"Opponent"),sportId:f.sport_id,sport:f.sports?.name||"CUT Sport",date:f.starts_at,venue:f.venue,status:f.status,detail:f.status==="completed"?(String(f.home_score??0)+" – "+String(f.away_score??0)):""})),
  ...competitions.map(x=>({id:"competition-"+x.id,type:"Competition",title:x.name,sportId:x.sport_id,sport:sports.find(s=>s.id===x.sport_id)?.name||"CUT Sport",date:x.start_date,endDate:x.end_date,venue:x.venue,status:x.status,detail:x.season||""})),
  ...events.map(x=>({id:"event-"+x.id,type:"Event",title:x.title,sportId:x.sport_id,sport:sports.find(s=>s.id===x.sport_id)?.name||"All sports",date:x.starts_at,endDate:x.ends_at,venue:x.venue,status:"Published",detail:x.ticketed?"Ticketed event":"CUT Sport event"})),
  ...trials.map(x=>({id:"trial-"+x.id,type:"Trial",title:x.title,sportId:x.sport_id,sport:x.sports?.name||"CUT Sport",date:x.starts_at,venue:x.venue,status:"Open",detail:x.teams?.name||"Open recruitment"}))
 ];
 const filtered=items.filter(x=>{
  if(sportFilter!=="all"&&x.sportId!==sportFilter)return false;
  if(typeFilter!=="all"&&x.type!==typeFilter)return false;
  if(fromDate&&(!x.date||String(x.date).slice(0,10)<fromDate))return false;
  if(toDate&&(!x.date||String(x.date).slice(0,10)>toDate))return false;
  const q=search.trim().toLowerCase();
  if(q&&!([x.title,x.sport,x.venue,x.detail].filter(Boolean).join(" ").toLowerCase().includes(q)))return false;
  return true;
 }).sort((a,b)=>{
  if(!a.date&&!b.date)return a.title.localeCompare(b.title);
  if(!a.date)return 1;if(!b.date)return -1;
  return new Date(a.date)-new Date(b.date);
 });
 const counts={Fixture:items.filter(x=>x.type==="Fixture").length,Competition:items.filter(x=>x.type==="Competition").length,Trial:items.filter(x=>x.type==="Trial").length,Event:items.filter(x=>x.type==="Event").length};
 return <><Header title="Central calendar"/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · ALL CODES</span><h1>Every date. Every team.</h1><p>Fixtures, competitions, published events and open trials in one place. Information appears here as it is officially entered and made visible by CUT Sport.</p></div>
  <div className="quick-links"><div><b>{counts.Fixture}</b><small>Fixtures</small></div><div><b>{counts.Competition}</b><small>Competitions</small></div><div><b>{counts.Trial}</b><small>Open trials</small></div><div><b>{counts.Event}</b><small>Events</small></div></div>
  <div className="form-card calendar-filters"><h3>Find an activity</h3>
   <label>Search<input type="search" placeholder="Search teams, opponents, venues…" value={search} onChange={e=>setSearch(e.target.value)}/></label>
   <label>Sport code<select value={sportFilter} onChange={e=>setSportFilter(e.target.value)}><option value="all">All sport codes</option>{sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
   <label>Activity type<select value={typeFilter} onChange={e=>setTypeFilter(e.target.value)}><option value="all">All activities</option><option value="Fixture">Fixtures</option><option value="Competition">Competitions</option><option value="Trial">Open trials</option><option value="Event">Events</option></select></label>
   <div className="calendar-date-filters"><label>From<input type="date" value={fromDate} onChange={e=>setFromDate(e.target.value)}/></label><label>To<input type="date" min={fromDate||undefined} value={toDate} onChange={e=>setToDate(e.target.value)}/></label></div>
   <button type="button" className="btn secondary" onClick={()=>{setSearch("");setSportFilter("all");setTypeFilter("all");setFromDate("");setToDate("")}}>Clear filters</button>
  </div>
  {trialError&&<p className="muted">{trialError}</p>}
  <Section title={filtered.length+" calendar entries"}>{filtered.length?filtered.map(x=><article className="fixture-card calendar-entry" key={x.id}>
   <div className="fixture-meta"><span>{x.sport}</span><span>{x.type} · {x.status}</span></div>
   <div className="calendar-entry-title"><b>{x.title}</b><small>{x.date?dateLabel(x.date):"Date to be confirmed"}{x.endDate?" – "+dateLabel(x.endDate):""}</small></div>
   {x.detail&&<p className="muted">{x.detail}</p>}
   <div className="fixture-foot"><span><MapPin size={14}/>{x.venue||"Venue to be confirmed"}</span></div>
  </article>):<Empty title="No matching calendar entries" body={busy?"Loading open trials and calendar records…":"Try widening your date range or clearing one of the filters."}/>}</Section>
  <p className="muted">Trial listings show public opportunity details only. Applicant names, applications and coach evaluation notes are not included in this calendar.</p>
 </main></>;
}

function Sport({sports,fixtures}) {return <><Header title="Sport Updates"/><main className="page"><h1>Follow the action.</h1><div className="sport-grid">{sports.map(s=><Link className="sport-tile" to={'/sport/'+s.slug} key={s.id}>{s.name}<ChevronRight/></Link>)}</div><Section title="Fixtures & results">{fixtures.length?fixtures.map(f=><Fixture f={f} key={f.id}/>):<Empty title="Fixtures coming soon" body="Official match information will appear here when released."/>}</Section></main></>}
function HockeyCompetitionData({competition}) {
 const matches=[...(competition.competition_matches||[])].sort((a,b)=>new Date(a.starts_at)-new Date(b.starts_at));
 const scorers=[...(competition.competition_player_statistics||[])].sort((a,b)=>b.total_goals-a.total_goals||a.player_name.localeCompare(b.player_name));
 const teamStats=(competition.competition_team_statistics||[]).find(x=>x.team_name==="Central University of Technology");
 const competitionId=competition.name.includes("Men C")?155:competition.name.includes("Women C")?156:competition.name.includes("Men B")?264:265;
 const base="https://saha.altiusrt.com/competitions/"+competitionId;
 const matchDate=value=>value?new Intl.DateTimeFormat("en-ZA",{day:"numeric",month:"short",hour:"2-digit",minute:"2-digit",timeZone:"Africa/Johannesburg"}).format(new Date(value)):"Date TBC";
 return <div className="hockey-data">
  <div className="hockey-source-links"><a href={base+"/matches"} target="_blank" rel="noreferrer">Official SAHA fixtures & results ↗</a><a href={base+"/statistics"} target="_blank" rel="noreferrer">Official SAHA statistics ↗</a></div>
  {teamStats&&<div className="hockey-team-stat"><b>CUT team scoring</b><div><span><strong>{teamStats.field_goals}</strong><small>Field goals</small></span><span><strong>{teamStats.penalty_corner_goals}</strong><small>Penalty corners</small></span><span><strong>{teamStats.penalty_stroke_goals}</strong><small>Penalty strokes</small></span><span><strong>{teamStats.total_goals}</strong><small>Total goals</small></span></div></div>}
  <div className="hockey-data-grid">
   <section className="hockey-data-panel"><h3>CUT fixtures & results</h3>{matches.length?<div className="hockey-match-list">{matches.map(m=><article className="hockey-match-row" key={m.id}><div><b>{m.home_team} <span>vs</span> {m.away_team}</b><small>{matchDate(m.starts_at)} · {m.venue||"Venue TBC"} · {m.match_round||m.group_name||"Match"}</small>{/^\d+$/.test(String(m.source_match_id))&&<a className="hockey-match-report" href={"https://saha.altiusrt.com/matches/"+m.source_match_id} target="_blank" rel="noreferrer">Official match report & statistics ↗</a>}</div><strong>{m.home_score} – {m.away_score}</strong></article>)}</div>:<p className="muted">No verified CUT matches are available for this competition.</p>}</section>
   <section className="hockey-data-panel"><h3>CUT player goal statistics</h3>{scorers.length?<div className="hockey-scorer-list"><div className="hockey-scorer-head"><span>Player</span><span>FG</span><span>PC</span><span>PS</span><span>G</span></div>{scorers.map(p=><div className="hockey-scorer-row" key={p.id}><b>{p.player_name}<small>{p.squad_number?"#"+p.squad_number:"CUT"}</small></b><span>{p.field_goals}</span><span>{p.penalty_corner_goals}</span><span>{p.penalty_stroke_goals}</span><strong>{p.total_goals}</strong></div>)}</div>:<p className="muted">No player scoring statistics are published for this competition.</p>}</section>
  </div>
  <small className="hockey-data-note">FG = field goals · PC = penalty-corner goals · PS = penalty-stroke goals · G = total goals. Data sourced from SAHA AltiusRT.</small>
 </div>;
}
function CompetitionData({competition}) {
 const matches=[...(competition.competition_matches||[])].sort((a,b)=>new Date(a.starts_at||0)-new Date(b.starts_at||0));
 const teamStats=competition.competition_team_statistics||[];
 const playerStats=competition.competition_player_statistics||[];
 const fmtDate=value=>value?new Intl.DateTimeFormat("en-ZA",{day:"numeric",month:"short",year:"numeric",timeZone:"Africa/Johannesburg"}).format(new Date(value)):"Date TBC";
 const label=k=>String(k).replaceAll("_"," ").replace(/\b\w/g,x=>x.toUpperCase());
 const metricEntries=row=>Object.entries(row.statistics||{}).filter(([,v])=>v!==null&&v!==undefined&&typeof v!=="object");
 return <div className="competition-data">
  {matches.length>0&&<section className="competition-data-panel"><h3>Fixtures & results</h3><div className="competition-result-list">{matches.map(m=><article className="competition-result" key={m.id}><div><b>{m.home_team} <span>vs</span> {m.away_team}</b><small>{m.match_round||m.group_name||"Match"} · {fmtDate(m.starts_at)}{m.venue?" · "+m.venue:""}</small></div><strong>{m.home_score??"—"} – {m.away_score??"—"}</strong></article>)}</div></section>}
  {teamStats.length>0&&<section className="competition-data-panel"><h3>Team statistics</h3><div className="competition-stat-grid">{teamStats.map(t=><article key={t.id}><b>{t.team_name}</b>{metricEntries(t).map(([k,v])=><span key={k}><small>{label(k)}</small><strong>{v}</strong></span>)}</article>)}</div></section>}
  {playerStats.length>0&&<section className="competition-data-panel"><h3>Player statistics</h3><div className="competition-player-list">{playerStats.map(p=><article key={p.id}><b>{p.player_name}</b><small>{p.team_name}{p.squad_number?" · #"+p.squad_number:""}</small>{metricEntries(p).length>0?<div>{metricEntries(p).map(([k,v])=><span key={k}>{label(k)}: <strong>{v}</strong></span>)}</div>:<div><span>Goals: <strong>{p.total_goals}</strong></span></div>}</article>)}</div></section>}
  <small className="competition-source-note">Competition statistics are displayed as published by the linked source. Player-level figures are shown only where a source provides them.</small>
 </div>;
}
function Hub({sports,teams,competitions,fixtures,articles,athletes}) {
 const {slug}=useParams();
 const s=sports.find(x=>x.slug===slug);
 const ts=teams.filter(t=>t.sport_id===s?.id);
 const cs=competitions.filter(c=>c.sport_id===s?.id);
 const fs=fixtures.filter(f=>f.sport_id===s?.id);
 const as=articles.filter(a=>a.sport_id===s?.id);
 const players=athletes.filter(a=>a.sport_id===s?.id);
 return <><Header title={s?.name||"Sport hub"} back/><main className="page">{s?<><h1>{s.name}</h1><p>{s.description||"Follow teams, fixtures and stories from this CUT Sport code."}</p><Section title="Competitions">{cs.length?cs.map(c=><article className="competition-card" key={c.id}><div><b>{c.name}</b><small>{[c.season,c.status].filter(Boolean).join(" · ")}</small></div><p>{c.description||"Official competition information."}</p><small>{c.start_date?dateLabel(c.start_date):"Dates to be confirmed"}{c.end_date?" – "+dateLabel(c.end_date):""}{c.venue?" · "+c.venue:""}</small>{c.competition_standings?.length>0&&<div className="competition-log"><h3>Competition log</h3>{[...new Set(c.competition_standings.map(x=>x.group_name||"Overall"))].map(group=><div key={group}><b className="competition-group">{group}</b><div className="competition-log-head"><span>Club</span><span>P</span><span>W</span><span>D</span><span>L</span><span>For</span><span>Against</span><span>+/-</span><span>BP</span><span>Pts</span></div>{c.competition_standings.filter(x=>(x.group_name||"Overall")===group).sort((a,b)=>(a.position??999)-(b.position??999)).map(x=><div className="competition-log-row competition-log-row-wide" key={x.id}><span className="competition-log-team"><b>{x.position?x.position+". ":""}{x.team_name}</b></span><span>{group==="Final Standing"?"—":(x.played??"—")}</span><span>{group==="Final Standing"?"—":(x.won??"—")}</span><span>{group==="Final Standing"?"—":(x.drawn??"—")}</span><span>{group==="Final Standing"?"—":(x.lost??"—")}</span><span>{group==="Final Standing"?"—":(x.scored??"—")}</span><span>{group==="Final Standing"?"—":(x.conceded??"—")}</span><span>{group==="Final Standing"?"—":(x.points_difference??"—")}</span><span>{group==="Final Standing"?"—":(x.bonus_points??"—")}</span><b>{group==="Final Standing"?"—":(x.points??"—")}</b></div>)}</div>)}</div>}{s.slug==="hockey"&&(c.competition_matches?.length>0||c.competition_player_statistics?.length>0||c.competition_team_statistics?.length>0)&&<HockeyCompetitionData competition={c}/>} {s.slug!=="hockey"&&(c.competition_matches?.length>0||c.competition_player_statistics?.length>0||c.competition_team_statistics?.length>0)&&<CompetitionData competition={c}/>}</article>):<Empty title="Competition details coming soon" body="Official competition names, dates and venues will appear here when published."/>}</Section><Section title="Teams & squads">{ts.length?<div className="team-grid">{ts.map(t=><article className="team-card" key={t.id}>{t.image_url&&<img src={t.image_url} alt=""/>}<div><b>{t.name}</b><small>{[t.category,t.season].filter(Boolean).join(" · ")||"CUT Sport team"}</small>{t.coach_name&&<small>Coach: {t.coach_name}</small>}<small>{players.filter(a=>a.team_id===t.id).length} approved athlete profiles</small></div></article>)}</div>:<Empty title="Team details coming soon" body="Official team names and squad information will appear here when published by CUT Sport staff."/>}</Section><Section title="Athletes & squads">{players.length?<div className="athlete-grid">{players.map(a=><div className="athlete-card" key={a.id}>{a.photo_url?<img src={a.photo_url} alt={a.full_name}/>:<div className="athlete-avatar">{(a.preferred_name||a.full_name).slice(0,1)}</div>}<div><b>{a.preferred_name||a.full_name}</b><small>{a.position||"CUT athlete"}{a.squad_number?" · #"+a.squad_number:""}</small>{a.teams?.name&&<small>{a.teams.name}</small>}</div></div>)}</div>:<Empty title="Squad information coming soon" body="Approved athlete profiles will appear here once published by CUT Sport staff."/>}</Section><Section title="Fixtures">{fs.length?fs.map(f=><Fixture key={f.id} f={f}/>):<Empty title="No verified fixtures yet" body="Fixture details will be added by CUT Sport staff."/>}</Section><Section title="News & highlights">{as.length?as.map(a=><StoryCard key={a.id} a={a}/>):<Empty title="No stories published" body="New stories will appear here."/>}</Section></>:<Empty title="Sport code not found" body="Choose a sport from the Sport Updates page."/>}</main></>;
}
function News({articles}) {return <><Header title="Articles & news"/><main className="page"><h1>Stories that move us.</h1>{articles.length?articles.map(a=><StoryCard key={a.id} a={a}/>):<Empty title="No stories published yet" body="The latest CUT Sport news will appear here."/>}</main></>}
function Story({articles}) {const {slug}=useParams();const a=articles.find(x=>x.slug===slug);return <><Header title="Article" back/><main className="page">{a?<article><small>{dateLabel(a.published_at)}</small><h1>{a.title}</h1>{a.cover_image_url&&<img className="article-cover" src={a.cover_image_url} alt=""/>}<p>{a.excerpt}</p><div className="article-body">{a.body}</div></article>:<Empty title="Story not found" body="This story is no longer available."/>}</main></>}
function Sponsors({sponsors}) {return <><Header title="Our sponsors" back/><main className="page"><h1>Stronger together.</h1>{sponsors.length?sponsors.map(s=><div className="sponsor-card" key={s.id}><b>{s.name}</b><p>{s.description}</p>{s.website_url&&<a href={s.website_url} target="_blank" rel="noreferrer">Visit partner</a>}</div>):<Empty title="Partner directory coming soon" body="Official sponsor profiles will be published here."/>}</main></>}

function AthletePerformance({user}) {
 const [athlete,setAthlete]=useState(null),[records,setRecords]=useState([]),[achievements,setAchievements]=useState([]);
 const [season,setSeason]=useState(""),[metric,setMetric]=useState(""),[busy,setBusy]=useState(false),[error,setError]=useState("");
 useEffect(()=>{
  let active=true;
  async function load(){
   if(!supabase||!user?.id){setAthlete(null);setRecords([]);setAchievements([]);return;}
   setBusy(true);setError("");
   const {data:a,error:ae}=await supabase.from("athletes").select("id,full_name,preferred_name,position,squad_number,approval_status,sports(name),teams(name)").eq("profile_id",user.id).maybeSingle();
   if(!active)return;
   if(ae){setError(ae.message);setBusy(false);return;}
   if(!a){setAthlete(null);setRecords([]);setAchievements([]);setBusy(false);return;}
   const [stats,awards]=await Promise.all([
    supabase.from("athlete_statistics").select("id,competition_id,fixture_id,season,period_label,metrics,created_at,competitions(name),fixtures(opponent,starts_at)").eq("athlete_id",a.id).eq("approval_status","approved").order("created_at",{ascending:true}).limit(500),
    supabase.from("athlete_achievements").select("id,title,description,category,award_date,competition_id,created_at").eq("athlete_id",a.id).eq("review_status","approved").order("award_date",{ascending:false}).limit(100)
   ]);
   if(!active)return;
   if(stats.error||awards.error)setError(stats.error?.message||awards.error?.message||"Unable to load performance data.");
   setAthlete(a);setRecords(stats.data||[]);setAchievements(awards.data||[]);setBusy(false);
  }
  load();return()=>{active=false;};
 },[user?.id]);
 const seasons=[...new Set(records.map(r=>r.season).filter(Boolean))].sort().reverse();
 const filtered=records.filter(r=>!season||r.season===season);
 const metricKeys=[...new Set(filtered.flatMap(r=>Object.entries(r.metrics||{}).filter(([,v])=>typeof v==="number"&&Number.isFinite(v)).map(([k])=>k)))].sort();
 const selectedMetric=metricKeys.includes(metric)?metric:(metricKeys[0]||"");
 const metricRows=filtered.filter(r=>typeof r.metrics?.[selectedMetric]==="number");
 const competitionCount=new Set(filtered.map(r=>r.competition_id).filter(Boolean)).size;
 if(!user)return <><Header title="My performance" back/><main className="page"><Empty title="Sign in to view performance" body="Sign in to see your approved CUT Sport statistics and achievements."/></main></>;
 return <><Header title="My performance" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">THE BLUES · ATHLETE DEVELOPMENT</span><h1>My performance.</h1><p>Your approved statistics, competition records and achievements in one place.</p></div>
  {error&&<p className="form-error">{error}</p>}
  {busy&&!athlete?<p className="muted">Loading your athlete profile…</p>:!athlete?<Empty title="No athlete profile linked" body="Ask your coach or sport administrator to link your CUT Sport account to your athlete profile."/>:<>
   <div className="admin-notice"><Trophy size={18}/><div><b>{athlete.preferred_name||athlete.full_name}</b><p>{athlete.sports?.name||"CUT Sport"}{athlete.teams?.name?" · "+athlete.teams.name:""}{athlete.position?" · "+athlete.position:""} · Profile {athlete.approval_status}</p></div></div>
   <div className="performance-filters"><label>Season<select value={season} onChange={e=>setSeason(e.target.value)}><option value="">All seasons</option>{seasons.map(x=><option key={x} value={x}>{x}</option>)}</select></label></div>
   <div className="admin-stats"><div><b>{filtered.length}</b><small>Approved stat entries</small></div><div><b>{competitionCount}</b><small>Competitions recorded</small></div><div><b>{achievements.length}</b><small>Verified achievements</small></div><div><b>{metricKeys.length}</b><small>Numeric metrics</small></div></div>
   <Section title="Performance trends">{metricKeys.length?<><label className="metric-picker">Choose a recorded metric<select value={selectedMetric} onChange={e=>setMetric(e.target.value)}>{metricKeys.map(k=><option key={k} value={k}>{k.replaceAll("_"," ")}</option>)}</select></label><div className="metric-trend">{metricRows.slice(-20).map(r=><div className="metric-trend-row" key={r.id}><span>{r.period_label||r.competitions?.name||r.season||dateLabel(r.created_at)}<small>{r.competitions?.name||r.fixtures?.opponent||dateLabel(r.created_at)}</small></span><div className="metric-bar"><i style={{width:Math.max(3,Number(r.metrics[selectedMetric])/Math.max(1,...metricRows.map(x=>Number(x.metrics[selectedMetric])))*100)+"%"}}/></div><b>{r.metrics[selectedMetric]}</b></div>)}</div></>:<Empty title={busy?"Refreshing performance":"No approved numeric metrics yet"} body="Once your statistics have been submitted and approved, recorded metrics will appear here. No sample results are displayed."/>}</Section>
   <Section title="Approved statistics">{filtered.length?filtered.slice().reverse().map(r=><article className="performance-record" key={r.id}><div className="performance-record-head"><div><b>{r.period_label||r.competitions?.name||"Performance entry"}</b><small>{r.season||"Season not set"} · {r.competitions?.name||r.fixtures?.opponent||"Competition not linked"}</small></div><span>{dateLabel(r.created_at)}</span></div><div className="performance-metric-chips">{Object.entries(r.metrics||{}).map(([k,v])=><span key={k}><b>{String(v)}</b> {k.replaceAll("_"," ")}</span>)}</div></article>):<Empty title="No approved statistics yet" body="Approved match and training statistics will be listed here when your sport staff records them."/>}</Section>
   <Section title="Achievements">{achievements.length?achievements.map(a=><article className="performance-record" key={a.id}><div className="performance-record-head"><div><b>{a.title}</b><small>{a.category||"Achievement"}</small></div><span>{a.award_date?dateLabel(a.award_date):dateLabel(a.created_at)}</span></div>{a.description&&<p>{a.description}</p>}</article>):<Empty title="No verified achievements yet" body="Achievements appear here after they have been approved by your sport administrator."/>}</Section>
   <p className="muted">Only approved statistics and achievements are shown. Pending or rejected submissions remain available in your Profile review section.</p>
  </>}
 </main></>;
}

function Profile({user,profile,roles}) {
 const [mode,setMode]=useState("login"),[email,setEmail]=useState(""),[password,setPassword]=useState(""),[newPassword,setNewPassword]=useState(""),[name,setName]=useState(profile?.full_name||""),[message,setMessage]=useState(""),[busy,setBusy]=useState(false);
 const [athleteReview,setAthleteReview]=useState({athlete:null,statistics:[],achievements:[],media:[],history:[],memberships:[]});
 const [reviewLoading,setReviewLoading]=useState(false),[reviewError,setReviewError]=useState("");
 const [reviewDrafts,setReviewDrafts]=useState({}),[reviewSaving,setReviewSaving]=useState("");
 useEffect(()=>setName(profile?.full_name||""),[profile]);
 useEffect(()=>{
  let active=true;
  async function loadAthleteReview(){
   if(!user?.id||!supabase){setAthleteReview({athlete:null,statistics:[],achievements:[],media:[],history:[],memberships:[]});setReviewError("");return;}
   setReviewLoading(true);setReviewError("");
   const athleteResult=await supabase.from("athletes").select("id,full_name,preferred_name,position,gender,nationality,hometown,province,faculty,qualification,year_of_study,student_status,years_representing_cut,previous_clubs,squad_number,bio,photo_url,approval_status,review_note,reviewed_at,sports(name),teams(name)").eq("profile_id",user.id).maybeSingle();
   if(!active)return;
   if(athleteResult.error){setReviewError(athleteResult.error.message);setReviewLoading(false);return;}
   if(!athleteResult.data){setAthleteReview({athlete:null,statistics:[],achievements:[],media:[],history:[],memberships:[]});setReviewLoading(false);return;}
   const athleteId=athleteResult.data.id;
   const [stats,achievements,media,history,memberships]=await Promise.all([
    supabase.from("athlete_statistics").select("id,competition_id,fixture_id,season,period_label,metrics,approval_status,review_note,created_at").eq("athlete_id",athleteId).order("created_at",{ascending:false}),
    supabase.from("athlete_achievements").select("id,title,description,category,award_date,competition_id,review_status,review_note,created_at").eq("athlete_id",athleteId).order("created_at",{ascending:false}),
    supabase.from("athlete_media").select("id,media_type,title,description,external_url,review_status,review_note,created_at").eq("athlete_id",athleteId).order("created_at",{ascending:false}),
    supabase.from("athlete_review_history").select("id,record_type,record_id,from_status,to_status,previous_note,review_note,reviewed_at,changed_at").eq("athlete_id",athleteId).order("changed_at",{ascending:false}).limit(30),
    supabase.from("athlete_team_memberships").select("id,team_id,sport_id,position,squad_number,is_active,joined_at,teams(name),sports(name)").eq("athlete_id",athleteId).eq("is_active",true).order("created_at",{ascending:false})
   ]);
   if(!active)return;
   const failed=[stats,achievements,media,history,memberships].find(x=>x.error);
   if(failed)setReviewError(failed.error.message);
   setAthleteReview({athlete:athleteResult.data,statistics:stats.data||[],achievements:achievements.data||[],media:media.data||[],history:history.data||[],memberships:memberships.data||[]});
   setReviewLoading(false);
  }
  loadAthleteReview();
  return()=>{active=false;};
 },[user?.id]);
 function draftFor(type,row){
  const key=type+":"+row.id;
  if(reviewDrafts[key])return reviewDrafts[key];
  if(type==="athlete")return {...row,previous_clubs:(row.previous_clubs||[]).join(", ")};
  if(type==="statistics")return {...row,metrics:JSON.stringify(row.metrics||{},null,2)};
  return {...row};
 }
 function changeDraft(type,row,patch){
  const key=type+":"+row.id;
  setReviewDrafts(current=>({...current,[key]:{...draftFor(type,row),...patch}}));
 }
 async function resubmitRecord(type,row,e){
  e.preventDefault();
  const key=type+":"+row.id,d=draftFor(type,row);
  let changes={};
  if(type==="athlete"){
   changes={full_name:d.full_name,preferred_name:d.preferred_name||null,position:d.position||null,gender:d.gender||null,nationality:d.nationality||null,hometown:d.hometown||null,province:d.province||null,faculty:d.faculty||null,qualification:d.qualification||null,year_of_study:d.year_of_study===""?null:Number(d.year_of_study),student_status:d.student_status,years_representing_cut:d.years_representing_cut===""?null:Number(d.years_representing_cut),previous_clubs:(d.previous_clubs||"").split(",").map(x=>x.trim()).filter(Boolean),squad_number:d.squad_number===""?null:Number(d.squad_number),bio:d.bio||null,photo_url:d.photo_url||null};
  }else if(type==="statistics"){
   try{changes={competition_id:d.competition_id||null,fixture_id:d.fixture_id||null,season:d.season||null,period_label:d.period_label||null,metrics:JSON.parse(d.metrics||"{}")};}
   catch{setReviewError("Statistics metrics must be valid JSON.");return;}
  }else if(type==="achievement"){
   changes={title:d.title,description:d.description||null,category:d.category||null,award_date:d.award_date||null,competition_id:d.competition_id||null};
  }else if(type==="media"){
   changes={media_type:d.media_type,title:d.title||null,description:d.description||null,external_url:d.external_url||null};
  }
  setReviewSaving(key);setReviewError("");
  const {error}=await supabase.rpc("resubmit_athlete_record",{p_record_type:type,p_record_id:row.id,p_changes:changes});
  if(error){setReviewError(error.message);setReviewSaving("");return;}
  const {data:historyRows}=await supabase.from("athlete_review_history").select("id,record_type,record_id,from_status,to_status,previous_note,review_note,reviewed_at,changed_at").eq("athlete_id",athleteReview.athlete.id).order("changed_at",{ascending:false}).limit(30);
  setReviewDrafts(current=>{const next={...current};delete next[key];return next;});
  setAthleteReview(current=>{
   if(type==="athlete")return {...current,history:historyRows||current.history,athlete:{...current.athlete,...changes,approval_status:"pending",review_note:null}};
   const field=type==="statistics"?"statistics":type==="achievement"?"achievements":"media";
   const statusField=type==="statistics"?"approval_status":"review_status";
   return {...current,history:historyRows||current.history,[field]:current[field].map(item=>item.id===row.id?{...item,...changes,[statusField]:"pending",review_note:null}:item)};
  });
  setReviewSaving("");
 }
 function correctionField(type,row,key,label,inputType="text"){
  const d=draftFor(type,row);
  return <label>{label}<input type={inputType} value={d[key]??""} onChange={e=>changeDraft(type,row,{[key]:e.target.value})}/></label>;
 }
 function correctionArea(type,row,key,label,rows=3){
  const d=draftFor(type,row);
  return <label>{label}<textarea rows={rows} value={d[key]??""} onChange={e=>changeDraft(type,row,{[key]:e.target.value})}/></label>;
 }
 function correctionForm(type,row){
  if((type==="athlete"?row.approval_status:row.review_status)!=="rejected")return null;
  const key=type+":"+row.id,d=draftFor(type,row),saving=reviewSaving===key;
  return <form className="form-card" onSubmit={e=>resubmitRecord(type,row,e)}>
   <h4>Correct and resubmit</h4>
   {type==="athlete"?<>
    {correctionField(type,row,"full_name","Full name")}
    {correctionField(type,row,"preferred_name","Preferred name")}
    {correctionField(type,row,"position","Playing position")}
    <label>Gender<select value={d.gender||""} onChange={e=>changeDraft(type,row,{gender:e.target.value})}><option value="">Not specified</option><option value="female">Female</option><option value="male">Male</option><option value="non_binary">Non-binary</option><option value="prefer_not_to_say">Prefer not to say</option></select></label>
    {correctionField(type,row,"nationality","Nationality")}{correctionField(type,row,"hometown","Hometown")}{correctionField(type,row,"province","Province")}{correctionField(type,row,"faculty","Faculty")}{correctionField(type,row,"qualification","Qualification")}
    {correctionField(type,row,"year_of_study","Year of study","number")}
    <label>Student status<select value={d.student_status||"current"} onChange={e=>changeDraft(type,row,{student_status:e.target.value})}><option value="current">Current student</option><option value="alumni">Alumni</option><option value="former">Former student</option><option value="staff">Staff</option></select></label>
    {correctionField(type,row,"years_representing_cut","Years representing CUT","number")}{correctionField(type,row,"previous_clubs","Previous clubs (comma separated)")}{correctionField(type,row,"squad_number","Squad number","number")}{correctionArea(type,row,"bio","Biography",4)}{correctionField(type,row,"photo_url","Photo URL","url")}
   </>:type==="statistics"?<>
    {correctionField(type,row,"season","Season")}{correctionField(type,row,"period_label","Period label")}
    {correctionField(type,row,"competition_id","Competition ID")}{correctionField(type,row,"fixture_id","Fixture ID")}
    {correctionArea(type,row,"metrics","Statistics metrics (JSON)",5)}
   </>:type==="achievement"?<>
    {correctionField(type,row,"title","Achievement title")}{correctionField(type,row,"category","Category")}{correctionField(type,row,"award_date","Award date","date")}{correctionField(type,row,"competition_id","Competition ID")}{correctionArea(type,row,"description","Description",4)}
   </>:<>
    <label>Media type<select value={d.media_type||"photo"} onChange={e=>changeDraft(type,row,{media_type:e.target.value})}><option value="photo">Photo</option><option value="video">Video</option><option value="certificate">Certificate</option><option value="document">Document</option></select></label>
    {correctionField(type,row,"title","Title")}{correctionField(type,row,"external_url","External media URL","url")}{correctionArea(type,row,"description","Description",3)}
    <p className="muted">Resubmitted media stays private until an administrator approves it.</p>
   </>}
   <button className="btn primary" disabled={saving}>{saving?"Submitting…":"Resubmit for review"}</button>
  </form>;
 }
 async function submit(e){
  e.preventDefault();if(!supabase){setMessage("Connect Supabase environment variables first.");return}
  setBusy(true);setMessage("");
  const r=mode==="login"
   ?await supabase.auth.signInWithPassword({email,password})
   :await supabase.auth.signUp({email,password,options:{data:{full_name:name}}});
  setMessage(r.error?.message||(mode==="signup"?"Account request submitted. Check your email if confirmation is required.":"Signed in successfully."));
  setBusy(false);
 }
 async function requestPasswordReset(){
  if(!supabase||!email.trim()){setMessage("Enter your account email address first.");return}
  setBusy(true);setMessage("");
  const {error}=await supabase.auth.resetPasswordForEmail(email.trim(),{redirectTo:window.location.origin+"/profile"});
  setMessage(error?.message||"If an account exists for that email, a password reset link will be sent.");
  setBusy(false);
 }
 async function updatePassword(e){
  e.preventDefault();if(!supabase||newPassword.length<8){setMessage("Choose a password with at least 8 characters.");return}
  setBusy(true);setMessage("");
  const {error}=await supabase.auth.updateUser({password:newPassword});
  setMessage(error?.message||"Your password has been updated.");
  if(!error)setNewPassword("");
  setBusy(false);
 }
 async function save(e){
  e.preventDefault();if(!supabase||!user)return;
  setBusy(true);const {error}=await supabase.from("profiles").upsert({id:user.id,full_name:name,email:user.email},{onConflict:"id"});
  setMessage(error?.message||"Profile updated.");setBusy(false);
 }
 function reviewStatus(label,status,note,id){
  return <div className="sponsor-card" key={id}><div><b>{label}</b><small>Status: {status||"pending"}</small>{note&&<p className="form-error">Review note: {note}</p>}</div></div>;
 }
 return <><Header title="Profile"/><main className="page">{user?<><h1>{profile?.full_name||user.email}</h1><form className="form-card" onSubmit={save}><label>Full name<input value={name} onChange={e=>setName(e.target.value)}/></label><label>Email<input value={user.email||""} disabled/></label><button className="btn primary" disabled={busy}>{busy?"Saving…":"Save profile"}</button></form><form className="form-card" onSubmit={updatePassword}><h3>Change password</h3><label>New password<input type="password" minLength="8" required value={newPassword} onChange={e=>setNewPassword(e.target.value)} autoComplete="new-password"/></label><button className="btn secondary" disabled={busy||newPassword.length<8}>{busy?"Updating…":"Update password"}</button></form>{message&&<p>{message}</p>}
 <Section title="Athlete submissions & review status">{reviewLoading?<p className="muted">Loading your athlete review information…</p>:reviewError?<p className="form-error">{reviewError}</p>:!athleteReview.athlete?<Empty title="No athlete profile linked yet" body="Your CUT Sport account is not linked to an athlete profile. Ask your coach or sport administrator to link your account before submitting or viewing athlete records."/>:<><div className="admin-notice"><ShieldCheck size={18}/><div><b>{athleteReview.athlete.preferred_name||athleteReview.athlete.full_name}</b><p>{athleteReview.athlete.sports?.name||"CUT Sport"}{athleteReview.athlete.teams?.name?" · "+athleteReview.athlete.teams.name:""} · Profile status: {athleteReview.athlete.approval_status}</p>{athleteReview.athlete.review_note&&<p className="form-error">Review note: {athleteReview.athlete.review_note}</p>}{correctionForm("athlete",athleteReview.athlete)}</div></div>
 {athleteReview.memberships.length>0&&<><h3>Sport & team memberships</h3><div className="performance-grid">{athleteReview.memberships.map(m=><div className="sponsor-card" key={m.id}><b>{m.sports?.name||"Sport"}</b><small>{m.teams?.name||"Team"}{m.position?" · "+m.position:""}{m.squad_number!==null&&m.squad_number!==undefined?" · #"+m.squad_number:""}</small></div>)}</div></>}
 {athleteReview.statistics.length>0&&<><h3>Performance statistics</h3>{athleteReview.statistics.map(x=><React.Fragment key={x.id}>{reviewStatus([x.season,x.period_label].filter(Boolean).join(" · ")||"Statistics submission",x.approval_status,x.review_note,x.id)}{correctionForm("statistics",x)}</React.Fragment>)}</>}
 {athleteReview.achievements.length>0&&<><h3>Achievements</h3>{athleteReview.achievements.map(x=><React.Fragment key={x.id}>{reviewStatus(x.title,x.review_status,x.review_note,x.id)}{correctionForm("achievement",x)}</React.Fragment>)}</>}
 {athleteReview.media.length>0&&<><h3>Media submissions</h3>{athleteReview.media.map(x=><React.Fragment key={x.id}>{reviewStatus(x.title||"Media submission",x.review_status,x.review_note,x.id)}{correctionForm("media",x)}</React.Fragment>)}</>}
 {!athleteReview.statistics.length&&!athleteReview.achievements.length&&!athleteReview.media.length&&<p className="muted">No statistics, achievements or media submissions are linked to this athlete profile yet.</p>}
 {athleteReview.history.length>0&&<><h3>Review history</h3>{athleteReview.history.map(h=><div className="sponsor-card" key={h.id}><b>{h.record_type.charAt(0).toUpperCase()+h.record_type.slice(1)} · {h.from_status||"new"} → {h.to_status}</b><small>{dateLabel(h.changed_at)}</small>{h.previous_note&&<p>Previous feedback: {h.previous_note}</p>}{h.review_note&&<p>Reviewer note: {h.review_note}</p>}</div>)}</>}
 <p className="muted">Rejected submissions can be corrected here and sent back to the assigned sport administrator. Resubmitted records return to pending review; media remains private until approved.</p></>}</Section>
 <div className="account-links"><Link to="/orders"><Package/> My orders</Link><Link to="/tickets"><Ticket/> My tickets</Link><Link to="/notifications"><Bell/> Notifications</Link><Link to="/messages"><MessageSquare/> Messages</Link><Link to="/performance"><Trophy/> My performance</Link><Link to="/trials"><ClipboardList/> Trials & recruitment</Link>{roles.some(r=>["sport_admin","super_admin","coach","shop_admin"].includes(r))&&<Link to="/admin">CUT Sport admin dashboard</Link>}{roles.some(r=>["sport_admin","super_admin","coach"].includes(r))&&<Link to="/admin/athletes">Athlete profiles</Link>}<p>Roles: {roles.join(", ")||"Member"}</p><button onClick={()=>supabase.auth.signOut()}><LogOut/> Sign out</button></div></>:<><h1>Join the Blues.</h1><div className="tabs"><button type="button" onClick={()=>{setMode("login");setMessage("")}}>Log in</button><button type="button" onClick={()=>{setMode("signup");setMessage("")}}>Create account</button></div><form className="form-card" onSubmit={submit}>{mode==="signup"&&<label>Full name<input required value={name} onChange={e=>setName(e.target.value)}/></label>}<label>Email<input type="email" required value={email} onChange={e=>setEmail(e.target.value)} autoComplete="email"/></label><label>Password<input type="password" minLength="8" required value={password} onChange={e=>setPassword(e.target.value)} autoComplete={mode==="login"?"current-password":"new-password"}/></label><button className="btn primary" disabled={busy}>{busy?"Please wait…":"Continue"}</button>{mode==="login"&&<button type="button" className="btn secondary" disabled={busy} onClick={requestPasswordReset}>Forgot password?</button>}{message&&<p>{message}</p>}</form><p className="muted">Student and staff discounts require verified institutional eligibility.</p></>}</main></>;
}
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
  {user&&items.length?items.map(x=>isNotifications?<article className={"personal-card notification-card "+(x.read_at?"is-read":"is-unread")} key={x.id}><div className="notification-card-head"><b>{x.title||"CUT Sport update"}</b><small>{dateLabel(x.created_at)}</small></div><p>{x.body}</p><div className="notification-card-foot"><span>{x.read_at?"Read":"Unread"}</span><div className="notification-actions">{x.action_url?.startsWith("/")&&<Link to={x.action_url} onClick={()=>!x.read_at&&markRead(x.id)}>Open update</Link>}{!x.read_at&&<button type="button" onClick={()=>markRead(x.id)}>Mark as read</button>}</div></div></article>:<div className="personal-card" key={x.id}><b>{x.title||x.event?.title||x.order_number||"CUT Sport update"}</b><p>{x.body||x.payment_status||x.status||dateLabel(x.created_at)}</p>{x.ticket_code&&<><small>Scan this QR code at the event entrance</small><TicketQr value={x.ticket_code}/><small>If scanning is unavailable, staff can enter this secure code manually</small><code className="ticket-code">{x.ticket_code}</code>{x.redeemed_at&&<small>Redeemed · {dateLabel(x.redeemed_at)}</small>}</>}</div>):null}
  {user&&!items.length&&!busy&&<Empty title={isNotifications?"No notifications yet":"Nothing here yet"} body={isNotifications?"Payment confirmations and important CUT Sport updates will appear here.":"Your updates will appear here when available."}/>}
  {busy&&!items.length&&<p className="muted">Loading…</p>}
 </main></>;
}


function AdminMessages({roles,user}) {
 const allowed=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const [athletes,setAthletes]=useState([]),[messages,setMessages]=useState([]);
 const [athleteId,setAthleteId]=useState(""),[subject,setSubject]=useState(""),[body,setBody]=useState(""),[messageType,setMessageType]=useState("general"),[parentId,setParentId]=useState("");
 const [busy,setBusy]=useState(false),[error,setError]=useState(""),[success,setSuccess]=useState("");
 async function load(){
  if(!supabase||!allowed||!user)return;
  setBusy(true);setError("");
  const [a,m]=await Promise.all([
   supabase.from("athletes").select("id,profile_id,full_name,preferred_name,sport_id,sports(name)").not("profile_id","is",null).order("full_name"),
   supabase.from("athlete_messages").select("id,athlete_id,sender_id,recipient_id,parent_message_id,subject,body,message_type,read_at,created_at,athletes(full_name,preferred_name,sports(name))").order("created_at",{ascending:false}).limit(100)
  ]);
  const failure=a.error||m.error;
  if(failure)setError(failure.message);
  else{setAthletes(a.data||[]);setMessages(m.data||[]);}
  setBusy(false);
 }
 useEffect(()=>{load()},[allowed,user?.id]);
 function replyTo(message){
  const athlete=athletes.find(x=>x.id===message.athlete_id);
  if(!athlete)return;
  setAthleteId(athlete.id);
  setSubject(message.subject?.toLowerCase().startsWith("re:")?message.subject:"Re: "+message.subject);
  setParentId(message.id);
  setMessageType(message.message_type==="correction"?"correction":"general");
  setSuccess("");setError("");
  document.getElementById("athlete-message-compose")?.scrollIntoView({behavior:"smooth",block:"start"});
 }
 async function send(e){
  e.preventDefault();
  if(!allowed||!user||!supabase)return;
  const athlete=athletes.find(x=>x.id===athleteId);
  if(!athlete?.profile_id){setError("Choose an athlete with a linked CUT Sport account.");return;}
  if(!subject.trim()||!body.trim()){setError("Enter a subject and message.");return;}
  setBusy(true);setError("");setSuccess("");
  const {error:sendError}=await supabase.from("athlete_messages").insert({
   athlete_id:athlete.id,sender_id:user.id,recipient_id:athlete.profile_id,
   parent_message_id:parentId||null,subject:subject.trim(),body:body.trim(),message_type:messageType
  });
  if(sendError)setError(sendError.message);
  else{setSuccess("Message sent. The athlete will receive an in-app notification.");setSubject("");setBody("");setParentId("");setMessageType("general");await load();}
  setBusy(false);
 }
 async function markRead(message){
  if(!user||message.read_at||message.recipient_id!==user.id)return;
  const now=new Date().toISOString();
  const {error:e}=await supabase.from("athlete_messages").update({read_at:now}).eq("id",message.id).eq("recipient_id",user.id).is("read_at",null);
  if(e)setError(e.message);else setMessages(old=>old.map(x=>x.id===message.id?{...x,read_at:now}:x));
 }
 if(!allowed)return <><Header title="Athlete communication" back/><main className="page"><Empty title="Restricted area" body="Only assigned sport administrators and super administrators can manage athlete messages."/></main></>;
 return <><Header title="Athlete communication" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · ATHLETE SUPPORT</span><h1>Communication centre</h1><p>Send athletes direct guidance, correction instructions and important updates. Messages are visible only to their participants.</p></div>
  <form id="athlete-message-compose" className="message-compose" onSubmit={send}>
   <h2>{parentId?"Reply to athlete":"New message"}</h2>
   <label>Choose athlete<select value={athleteId} onChange={e=>{setAthleteId(e.target.value);setParentId("");}} required><option value="">Select an athlete</option>{athletes.map(x=><option key={x.id} value={x.id}>{x.preferred_name||x.full_name} · {x.sports?.name||"Sport"}</option>)}</select></label>
   <label>Message type<select value={messageType} onChange={e=>setMessageType(e.target.value)}><option value="general">General message</option><option value="correction">Correction guidance</option><option value="announcement">Important announcement</option></select></label>
   <label>Subject<input value={subject} onChange={e=>setSubject(e.target.value)} maxLength={160} placeholder="e.g. Athlete profile corrections required" required/></label>
   <label>Message<textarea value={body} onChange={e=>setBody(e.target.value)} rows={5} maxLength={5000} placeholder="Write clear instructions or guidance for the athlete…" required/></label>
   {error&&<p className="form-error">{error}</p>}{success&&<p className="form-success">{success}</p>}
   <div className="message-compose-actions"><button className="btn primary" type="submit" disabled={busy||!athletes.length}><Send size={16}/>{busy?"Sending…":"Send message"}</button>{parentId&&<button type="button" onClick={()=>{setParentId("");setSubject("");setBody("");}}>Cancel reply</button>}</div>
   {!athletes.length&&!busy&&<p className="muted">No athletes with linked user accounts are currently available to message.</p>}
  </form>
  <section className="section"><div className="section-head"><h2>Recent conversations</h2><button type="button" onClick={load} disabled={busy}>Refresh</button></div>
   {messages.length?messages.map(m=><article className="message-card" key={m.id}>
    <div className="message-card-top"><div><b>{m.athletes?.preferred_name||m.athletes?.full_name||"Athlete"}</b><small>{m.athletes?.sports?.name||"CUT Sport"} · {dateLabel(m.created_at)}</small></div><span className={m.read_at?"message-status":"message-status unread"}>{m.recipient_id===user?.id?(m.read_at?"Read":"Unread"):"Sent"}</span></div>
    <b className="message-subject">{m.subject}</b><p>{m.body}</p>
    <div className="message-card-actions">{m.recipient_id===user?.id&&!m.read_at&&<button type="button" onClick={()=>markRead(m)}>Mark read</button>}<button type="button" onClick={()=>replyTo(m)}><Reply size={14}/> Reply</button></div>
   </article>):<Empty title="No messages yet" body="Messages sent to or received from athletes will appear here."/>}
  </section>
 </main></>;
}

function AthleteMessages({user}) {
 const [messages,setMessages]=useState([]),[busy,setBusy]=useState(false),[error,setError]=useState(""),[replyId,setReplyId]=useState(""),[replyBody,setReplyBody]=useState("");
 async function load(){
  if(!supabase||!user){setMessages([]);return;}
  setBusy(true);setError("");
  const {data,error:e}=await supabase.from("athlete_messages").select("id,athlete_id,sender_id,recipient_id,parent_message_id,subject,body,message_type,read_at,created_at,athletes(full_name,preferred_name,sports(name))").order("created_at",{ascending:false}).limit(100);
  if(e)setError(e.message);else setMessages(data||[]);
  setBusy(false);
 }
 useEffect(()=>{load()},[user?.id]);
 async function markRead(m){
  if(!user||m.read_at||m.recipient_id!==user.id)return;
  const now=new Date().toISOString();
  const {error:e}=await supabase.from("athlete_messages").update({read_at:now}).eq("id",m.id).eq("recipient_id",user.id).is("read_at",null);
  if(e)setError(e.message);else setMessages(old=>old.map(x=>x.id===m.id?{...x,read_at:now}:x));
 }
 async function reply(m){
  if(!user||!supabase||!replyBody.trim())return;
  const {error:e}=await supabase.from("athlete_messages").insert({
   athlete_id:m.athlete_id,sender_id:user.id,recipient_id:m.sender_id,parent_message_id:m.id,
   subject:m.subject.toLowerCase().startsWith("re:")?m.subject:"Re: "+m.subject,
   body:replyBody.trim(),message_type:"general"
  });
  if(e)setError(e.message);else{setReplyBody("");setReplyId("");await load();}
 }
 const unread=messages.filter(m=>m.recipient_id===user?.id&&!m.read_at).length;
 return <><Header title="My messages" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · YOUR ACCOUNT</span><h1>Messages</h1><p>{unread} unread message(s). Read guidance from your sport administrators and reply when needed.</p></div>
  {!user?<Empty title="Sign in to view messages" body="Your athlete messages will appear here after signing in."/>:null}
  {error&&<p className="form-error">{error}</p>}
  {messages.length?messages.map(m=><article className="message-card" key={m.id}>
   <div className="message-card-top"><div><b>{m.subject}</b><small>{m.message_type==="correction"?"Correction guidance":m.message_type==="announcement"?"Important announcement":"CUT Sport message"} · {dateLabel(m.created_at)}</small></div><span className={m.read_at?"message-status":"message-status unread"}>{m.recipient_id===user?.id?(m.read_at?"Read":"Unread"):"Sent"}</span></div>
   <p>{m.body}</p>
   <div className="message-card-actions">{m.recipient_id===user?.id&&!m.read_at&&<button type="button" onClick={()=>markRead(m)}>Mark read</button>}{m.recipient_id===user?.id&&<button type="button" onClick={()=>{setReplyId(replyId===m.id?"":m.id);setReplyBody("");markRead(m);}}><Reply size={14}/> Reply</button>}</div>
   {replyId===m.id&&<div className="message-reply"><textarea rows={3} maxLength={5000} value={replyBody} onChange={e=>setReplyBody(e.target.value)} placeholder="Write your reply…"/><button className="btn primary" type="button" disabled={!replyBody.trim()} onClick={()=>reply(m)}><Send size={15}/> Send reply</button></div>}
  </article>):user&&!busy?<Empty title="No messages yet" body="Messages from your sport administrators will appear here."/>:null}
  {busy&&!messages.length&&<p className="muted">Loading messages…</p>}
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


function AdminCalendar({roles,sports}) {
 const sportAdmin=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const coach=roles.includes("coach");
 const allowed=sportAdmin||coach;
 const [records,setRecords]=useState([]);
 const [sportFilter,setSportFilter]=useState("all");
 const [typeFilter,setTypeFilter]=useState("all");
 const [search,setSearch]=useState("");
 const [loading,setLoading]=useState(false);
 const [error,setError]=useState("");
 async function load(){
  if(!supabase||!allowed)return;
  setLoading(true);setError("");
  const [f,c,e,t]=await Promise.all([
   supabase.from("fixtures").select("id,opponent,venue,starts_at,status,sport_id,teams(name),sports(name)").order("starts_at",{ascending:true}).limit(250),
   supabase.from("competitions").select("id,name,season,start_date,end_date,venue,status,sport_id").order("start_date",{ascending:true}).limit(250),
   supabase.from("events").select("id,title,venue,starts_at,ends_at,published,archived_at,sport_id,sports(name)").order("starts_at",{ascending:true}).limit(250),
   supabase.from("recruitment_opportunities").select("id,title,venue,starts_at,closes_at,status,sport_id,sports(name),teams(name)").order("starts_at",{ascending:true}).limit(250)
  ]);
  const failure=[f,c,e,t].find(x=>x.error);
  if(failure)setError(failure.error.message);
  else{
   setRecords([
    ...(f.data||[]).map(x=>({id:"fixture-"+x.id,sourceId:x.id,type:"Fixture",title:(x.teams?.name||"CUT")+" vs "+x.opponent,sportId:x.sport_id,sport:x.sports?.name||"CUT Sport",date:x.starts_at,venue:x.venue,status:x.status})),
    ...(c.data||[]).map(x=>({id:"competition-"+x.id,sourceId:x.id,type:"Competition",title:x.name,sportId:x.sport_id,sport:sports.find(s=>s.id===x.sport_id)?.name||"CUT Sport",date:x.start_date,endDate:x.end_date,venue:x.venue,status:x.status,season:x.season})),
    ...(e.data||[]).map(x=>({id:"event-"+x.id,sourceId:x.id,type:"Event",title:x.title,sportId:x.sport_id,sport:x.sports?.name||"Institution-wide",date:x.starts_at,endDate:x.ends_at,venue:x.venue,status:x.archived_at?"Archived":x.published?"Published":"Draft"})),
    ...(t.data||[]).map(x=>({id:"trial-"+x.id,sourceId:x.id,type:"Trial",title:x.title,sportId:x.sport_id,sport:x.sports?.name||"CUT Sport",date:x.starts_at,venue:x.venue,status:x.status,team:x.teams?.name}))
   ]);
  }
  setLoading(false);
 }
 useEffect(()=>{load()},[allowed]);
 const filtered=records.filter(x=>{
  if(sportFilter!=="all"&&x.sportId!==sportFilter)return false;
  if(typeFilter!=="all"&&x.type!==typeFilter)return false;
  const q=search.trim().toLowerCase();
  return !q||[x.title,x.sport,x.venue,x.status,x.team].filter(Boolean).join(" ").toLowerCase().includes(q);
 }).sort((a,b)=>{if(!a.date)return 1;if(!b.date)return -1;return new Date(a.date)-new Date(b.date)});
 const counts={Fixture:records.filter(x=>x.type==="Fixture").length,Competition:records.filter(x=>x.type==="Competition").length,Event:records.filter(x=>x.type==="Event").length,Trial:records.filter(x=>x.type==="Trial").length};
 if(!allowed)return <><Header title="Calendar administration access required" back/><main className="page"><Empty title="Restricted area" body="A sport administrator, super administrator or coach role is required."/></main></>;
 return <><Header title="Calendar administration" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · OPERATIONS</span><h1>Calendar control centre.</h1><p>Review the records feeding the public calendar. Create and update each record in its existing secure management workspace.</p></div>
  <div className="admin-stats"><div><b>{counts.Fixture}</b><small>Fixtures</small></div><div><b>{counts.Competition}</b><small>Competitions</small></div><div><b>{counts.Event}</b><small>Events</small></div><div><b>{counts.Trial}</b><small>Trials</small></div></div>
  <Section title="Publishing workspaces"><div className="admin-module-grid">
   <article className="admin-module"><div className="admin-module-icon"><CalendarClock size={20}/></div><div className="admin-module-copy"><b>Fixtures & competitions</b><p>Create fixtures, update match status and manage competition dates.</p></div><Link to="/admin/operations" aria-label="Manage fixtures and competitions"><ChevronRight/></Link></article>
   {sportAdmin&&<article className="admin-module"><div className="admin-module-icon"><FileText size={20}/></div><div className="admin-module-copy"><b>Events & publishing</b><p>Create events, publish or unpublish them, and retain ticket and order history.</p></div><Link to="/admin/editorial" aria-label="Manage events"><ChevronRight/></Link></article>}
   <article className="admin-module"><div className="admin-module-icon"><ClipboardList size={20}/></div><div className="admin-module-copy"><b>Trials & recruitment</b><p>Publish trial opportunities and manage recruitment workflows.</p></div><Link to="/admin/recruitment" aria-label="Manage trials"><ChevronRight/></Link></article>
  </div></Section>
  <div className="form-card"><h3>Calendar records</h3>
   <label>Search<input type="search" value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search title, team, venue or status"/></label>
   <label>Sport code<select value={sportFilter} onChange={e=>setSportFilter(e.target.value)}><option value="all">All sports</option>{sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
   <label>Record type<select value={typeFilter} onChange={e=>setTypeFilter(e.target.value)}><option value="all">All types</option><option value="Fixture">Fixtures</option><option value="Competition">Competitions</option><option value="Event">Events</option><option value="Trial">Trials</option></select></label>
  </div>
  {error&&<p className="form-error" role="alert">{error}</p>}
  <Section title={filtered.length+" records"}>{loading?<p className="muted">Loading calendar records…</p>:filtered.length?filtered.map(x=><article className="sponsor-card admin-sponsor" key={x.id}><div><b>{x.title}</b><small>{x.sport} · {x.type} · {x.status}</small><small>{x.date?dateLabel(x.date):"Date TBC"}{x.endDate?" – "+dateLabel(x.endDate):""}{x.venue?" · "+x.venue:""}</small></div></article>):<Empty title="No calendar records found" body="Try another filter, or create the first record in one of the publishing workspaces above."/>}</Section>
  <p className="muted">This page is a combined operations view, not a second data store. Editing remains in the existing role-scoped modules; Supabase RLS controls which records each staff member can see or change.</p>
 </main></>;
}

function AdminDashboard({sports,teams,competitions,fixtures,articles,events,sponsors,athletes,roles}) {
 const sportAdmin=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const coach=roles.includes("coach");
 const shopAdmin=roles.includes("shop_admin");
 const allowed=sportAdmin||coach||shopAdmin;
 const modules=[
  ...(sportAdmin?[{title:"Sport codes",description:"Manage the official sport directory; create new codes or edit/archive assigned sports.",to:"/admin/sports",icon:Settings2,state:"Available"},{title:"Team management & staff",description:"Create squads, manage seasons and categories, and assign coaches or team managers.",to:"/admin/teams",icon:Users,state:"Available"},{title:"Sponsor directory",description:"Create, update and archive official partner profiles.",to:"/admin/sponsors",icon:Handshake,state:"Available"},{title:"Sport operations",description:"Team, competition and fixture publishing tools.",to:"/admin/operations",icon:CalendarClock,state:"Available"},{title:"News & events",description:"Editorial publishing and event management.",to:"/admin/editorial",icon:FileText,state:"Available"}]:[]),
  ...((sportAdmin||coach)?[{title:"Calendar administration",description:"Review the combined sporting calendar and jump to the correct publishing workspace for fixtures, competitions, events and trials.",to:"/admin/calendar",icon:CalendarDays,state:"Available"},{title:"Athlete profiles",description:"Register and update profiles within your assigned sport or team scope.",to:"/admin/athletes",icon:Users,state:"Available"},{title:"Team rosters",description:"View squads, add approved athletes, update positions and squad numbers, and retain membership history.",to:"/admin/rosters",icon:Users,state:"Available"},{title:"Performance dashboards",description:"Compare approved athlete statistics by sport, athlete, season and metric.",to:"/admin/performance",icon:Trophy,state:"Available"}]:[]),
  ...((sportAdmin||coach)?[{title:"Trials & recruitment",description:"Configure sport-specific evaluation, score applicants, select candidates and allocate squad places.",to:"/admin/recruitment",icon:ClipboardList,state:"Available"}]:[]),
  ...(sportAdmin?[{title:"Athlete approvals",description:"Review athlete profiles before publication.",to:"/admin/approvals",icon:ShieldCheck,state:"Available"},{title:"Athlete communication",description:"Send correction guidance and direct messages to registered athletes.",to:"/admin/messages",icon:MessageSquare,state:"Available"},{title:"Event ticket gate",description:"Validate and redeem paid event tickets at entry.",to:"/admin/ticket-gate",icon:Ticket,state:"Available"},{title:"Event sales & attendees",description:"Review ticket sales, revenue, attendee registers and check-ins.",to:"/admin/event-reports",icon:ClipboardList,state:"Available"}]:[]),
  ...((shopAdmin||roles.includes("super_admin"))?[{title:"Shop catalogue",description:"Create, update and archive products and manage published stock.",to:"/admin/products",icon:ShoppingBag,state:"Available"},{title:"Shop orders",description:"Review paid shop orders, line items and fulfilment status.",to:"/admin/shop-orders",icon:Package,state:"Available"}]:[])
 ];
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="A CUT Sport administrator, coach or shop administrator role is required."/></main></>;
 return <><Header title="Admin dashboard" back/><main className="page"><div className="page-intro"><span className="eyebrow">CUT SPORT · MANAGEMENT</span><h1>Admin dashboard</h1><p>Manage the information published in the CUT Sport app. Access to each record is still enforced by Supabase policies.</p></div><div className="admin-stats"><div><b>{sports.length}</b><small>Sport codes</small></div><div><b>{teams.length}</b><small>Teams</small></div><div><b>{competitions.length}</b><small>Competitions</small></div><div><b>{fixtures.length}</b><small>Fixtures</small></div><div><b>{articles.length}</b><small>Published stories</small></div><div><b>{events.length}</b><small>Events</small></div><div><b>{athletes.length}</b><small>Public athletes</small></div><div><b>{sponsors.length}</b><small>Active sponsors</small></div></div><Section title="Management tools"><div className="admin-module-grid">{modules.map(m=><article className="admin-module" key={m.title}><div className="admin-module-icon"><m.icon size={20}/></div><div className="admin-module-copy"><b>{m.title}</b><p>{m.description}</p><small>{m.state}</small></div>{m.to?<Link to={m.to} aria-label={"Open "+m.title}><ChevronRight/></Link>:<ShieldCheck size={18} className="muted-icon"/>}</article>)}</div></Section><div className="admin-notice"><ShieldCheck size={18}/><div><b>Security-first publishing</b><p>Planned management tools remain read-only or unavailable until their role scopes, Row Level Security policies and server-side workflows are reviewed and tested. This dashboard does not grant new permissions.</p></div></div></main></> ;
}


function Trials({user,profile}) {
 const [opportunities,setOpportunities]=useState([]),[applications,setApplications]=useState([]),[athlete,setAthlete]=useState(null);
 const [selected,setSelected]=useState(""),[applicantName,setApplicantName]=useState(profile?.full_name||""),[position,setPosition]=useState(""),[experience,setExperience]=useState(""),[motivation,setMotivation]=useState("");
 const [busy,setBusy]=useState(false),[error,setError]=useState(""),[notice,setNotice]=useState("");
 useEffect(()=>{
  let active=true;
  async function load(){
   if(!supabase){setError("Recruitment is temporarily unavailable.");return;}
   const {data:o,error:oe}=await supabase.from("recruitment_opportunities").select("id,title,description,venue,starts_at,closes_at,sport_id,team_id,sports(name),teams(name)").eq("status","open").order("starts_at",{ascending:true});
   if(!active)return;
   if(oe){setError(oe.message);return;}
   setOpportunities(o||[]);
   if(user?.id){
    const [a,apps]=await Promise.all([
     supabase.from("athletes").select("id,full_name,preferred_name,position").eq("profile_id",user.id).maybeSingle(),
     supabase.from("trial_applications").select("id,opportunity_id,status,created_at").eq("applicant_user_id",user.id).order("created_at",{ascending:false})
    ]);
    if(!active)return;
    if(a.error||apps.error)setError(a.error?.message||apps.error?.message||"Unable to load your applications.");
    setAthlete(a.data||null);setApplications(apps.data||[]);
   }
  }
  load();return()=>{active=false;};
 },[user?.id]);
 async function apply(e,opportunityId){
  e.preventDefault();if(!user?.id){setError("Please sign in before applying.");return;}
  if(!opportunityId)return;
  setBusy(true);setError("");setNotice("");
  const {error:e1}=await supabase.from("trial_applications").insert({
   opportunity_id:opportunityId,applicant_user_id:user.id,athlete_id:athlete?.id||null,
   full_name:applicantName.trim(),playing_position:position.trim()||athlete?.position||null,
   experience:experience.trim()||null,motivation:motivation.trim()||null
  });
  if(e1)setError(e1.code==="23505"?"You have already applied for this trial.":e1.message);
  else{
   setNotice("Application submitted. You can track its status below.");
   setPosition("");setExperience("");setMotivation("");
   const {data}=await supabase.from("trial_applications").select("id,opportunity_id,status,created_at").eq("applicant_user_id",user.id).order("created_at",{ascending:false});
   setApplications(data||[]);
  }
  setBusy(false);
 }
 useEffect(()=>{if(profile?.full_name)setApplicantName(profile.full_name);else if(athlete?.full_name)setApplicantName(athlete.full_name)},[profile?.full_name,athlete?.full_name]);
 const statusLabel={submitted:"Submitted",shortlisted:"Shortlisted",selected:"Selected",not_selected:"Not selected"};
 return <><Header title="Trials & recruitment" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">YOUR NEXT OPPORTUNITY</span><h1>Earn your blue.</h1><p>Find open CUT Sport trials and put your name forward. Coaches will update your application when decisions are made.</p></div>
  {error&&<p className="form-error" role="alert">{error}</p>}{notice&&<p className="admin-notice">{notice}</p>}
  {!user&&<div className="admin-notice"><ShieldCheck size={18}/><div><b>Sign in to apply</b><p>You can browse open opportunities now. Sign in through your Profile to submit an application.</p><Link to="/profile">Go to Profile</Link></div></div>}
  <Section title="Open trials">{opportunities.length?opportunities.map(o=><article className="performance-record" key={o.id}><div className="performance-record-head"><div><b>{o.title}</b><small>{o.sports?.name||"CUT Sport"}{o.teams?.name?" · "+o.teams.name:" · All teams"}</small></div><span className="status-pill">Open</span></div><p>{o.description||"Trial details will be provided by the coaching staff."}</p><div className="fixture-foot"><span><CalendarDays size={14}/>{o.starts_at?dateLabel(o.starts_at):"Date to be confirmed"}</span><span><MapPin size={14}/>{o.venue||"Venue to be confirmed"}</span></div>{o.closes_at&&<small>Applications close: {dateLabel(o.closes_at)}</small>}
   {user&&<form className="form-card" onSubmit={e=>apply(e,o.id)}><h4>Apply for this trial</h4><label>Your full name<input required minLength="2" maxLength="120" value={applicantName} onChange={e=>setApplicantName(e.target.value)}/></label><label>Playing position / event<input value={selected===o.id?position:athlete?.position||""} onFocus={()=>setSelected(o.id)} onChange={e=>{setSelected(o.id);setPosition(e.target.value)}} placeholder="Your position or event"/></label><label>Previous playing / sporting experience<textarea rows="2" value={selected===o.id?experience:""} onFocus={()=>setSelected(o.id)} onChange={e=>{setSelected(o.id);setExperience(e.target.value)}} placeholder="Teams, clubs, competitions or experience"/></label><label>Why would you like to join? <textarea rows="3" maxLength="3000" value={selected===o.id?motivation:""} onFocus={()=>setSelected(o.id)} onChange={e=>{setSelected(o.id);setMotivation(e.target.value)}}/></label><button className="btn primary" disabled={busy}>{busy&&selected===o.id?"Submitting…":"Submit application"}</button></form>}
  </article>):<Empty title="No open trials at the moment" body="New recruitment opportunities will appear here when CUT Sport coaches publish them."/>}</Section>
  {user&&<Section title="My applications">{applications.length?applications.map(a=><div className="sponsor-card" key={a.id}><div><b>{opportunities.find(o=>o.id===a.opportunity_id)?.title||"CUT Sport trial"}</b><small>{dateLabel(a.created_at)} · {statusLabel[a.status]||a.status}</small></div></div>):<Empty title="No applications yet" body="Your submitted trial applications and selection updates will appear here."/>}</Section>}
 </main></>;
}

function AdminRecruitment({roles,user}) {
 const allowed=roles.some(r=>["sport_admin","super_admin","coach"].includes(r));
 const [sports,setSports]=useState([]),[teams,setTeams]=useState([]),[opportunities,setOpportunities]=useState([]),[applications,setApplications]=useState([]),[criteria,setCriteria]=useState([]),[scores,setScores]=useState([]);
 const [form,setForm]=useState({sport_id:"",team_id:"",title:"",description:"",venue:"",starts_at:"",closes_at:"",status:"draft"});
 const [criteriaDraft,setCriteriaDraft]=useState({title:"",description:"",max_score:"10"});
 const [scoreDrafts,setScoreDrafts]=useState({}),[teamAssignments,setTeamAssignments]=useState({});
 const [busy,setBusy]=useState(false),[error,setError]=useState(""),[notice,setNotice]=useState(""),[notes,setNotes]=useState({});
 async function load(){
  if(!supabase||!allowed)return;
  const [sp,tm,op]=await Promise.all([
   supabase.from("sports").select("id,name").order("name"),
   supabase.from("teams").select("id,name,sport_id,sports(name)").eq("is_active",true).order("name"),
   supabase.from("recruitment_opportunities").select("id,title,sport_id,team_id,status,starts_at,closes_at,venue,sports(name),teams(name)").order("created_at",{ascending:false})
  ]);
  const failure=sp.error||tm.error||op.error;if(failure){setError(failure.message);return;}
  setSports(sp.data||[]);setTeams(tm.data||[]);setOpportunities(op.data||[]);
  const ids=(op.data||[]).map(x=>x.id);
  if(!ids.length){setApplications([]);setCriteria([]);setScores([]);return;}
  const [appResult,criteriaResult]=await Promise.all([
   supabase.from("trial_applications").select("id,opportunity_id,athlete_id,full_name,playing_position,experience,motivation,status,created_at").in("opportunity_id",ids).order("created_at",{ascending:false}),
   supabase.from("trial_evaluation_criteria").select("id,opportunity_id,title,description,max_score,display_order").in("opportunity_id",ids).order("display_order").order("created_at")
  ]);
  if(appResult.error||criteriaResult.error){setError(appResult.error?.message||criteriaResult.error?.message);return;}
  const appRows=appResult.data||[];
  setApplications(appRows);
  setCriteria(criteriaResult.data||[]);
  const {data:reviews,error:reviewError}=appRows.length
   ? await supabase.from("trial_application_reviews").select("application_id,coach_notes").in("application_id",appRows.map(x=>x.id))
   : {data:[],error:null};
  if(reviewError)setError(reviewError.message);
  const byId=new Map((reviews||[]).map(x=>[x.application_id,x.coach_notes]));
  setApplications(appRows.map(x=>({...x,coach_notes:byId.get(x.id)||""})));
  const {data:scoreRows,error:scoreError}=await supabase.from("trial_application_scores").select("id,application_id,opportunity_id,criterion_id,reviewer_id,score,comments").in("opportunity_id",ids);
  if(scoreError)setError(scoreError.message);else setScores(scoreRows||[]);
 }
 useEffect(()=>{load()},[allowed]);
 const availableTeams=teams.filter(t=>!form.sport_id||t.sport_id===form.sport_id);
 async function create(e){
  e.preventDefault();if(!allowed||!user?.id)return;
  setBusy(true);setError("");setNotice("");
  const {error:e1}=await supabase.from("recruitment_opportunities").insert({
   sport_id:form.sport_id,team_id:form.team_id||null,title:form.title.trim(),description:form.description.trim()||null,
   venue:form.venue.trim()||null,starts_at:form.starts_at?new Date(form.starts_at).toISOString():null,
   closes_at:form.closes_at?new Date(form.closes_at).toISOString():null,status:form.status,created_by:user.id
  });
  if(e1)setError(e1.message);else{setForm({sport_id:"",team_id:"",title:"",description:"",venue:"",starts_at:"",closes_at:"",status:"draft"});setNotice("Recruitment opportunity saved.");await load();}
  setBusy(false);
 }
 async function setOpportunityStatus(item,status){
  setError("");const {error:e}=await supabase.from("recruitment_opportunities").update({status,updated_at:new Date().toISOString()}).eq("id",item.id);
  if(e)setError(e.message);else await load();
 }
 async function addCriterion(e,opportunity){
  e.preventDefault();const title=criteriaDraft.title.trim(),max=Number(criteriaDraft.max_score);
  if(!title||!Number.isFinite(max)||max<=0||max>1000){setError("Enter a criterion title and a maximum score greater than 0 and no more than 1,000.");return;}
  setBusy(true);setError("");setNotice("");
  const {error:e1}=await supabase.from("trial_evaluation_criteria").insert({opportunity_id:opportunity.id,title,description:criteriaDraft.description.trim()||null,max_score:max,display_order:criteria.filter(c=>c.opportunity_id===opportunity.id).length,created_by:user.id});
  if(e1)setError(e1.message);else{setCriteriaDraft({title:"",description:"",max_score:"10"});setNotice("Evaluation criterion added.");await load();}
  setBusy(false);
 }
 async function saveScore(application,criterion){
  const key=application.id+":"+criterion.id,raw=scoreDrafts[key];
  const value=Number(raw);
  if(raw===""||raw===undefined||!Number.isFinite(value)||value<0||value>Number(criterion.max_score)){setError("Enter a valid score between 0 and "+criterion.max_score+".");return;}
  setError("");setNotice("");
  const {error:e}=await supabase.from("trial_application_scores").upsert({application_id:application.id,opportunity_id:application.opportunity_id,criterion_id:criterion.id,reviewer_id:user.id,score:value},{onConflict:"application_id,criterion_id,reviewer_id"});
  if(e)setError(e.message);else{setNotice("Evaluation score saved.");await load();}
 }
 async function reviewApplication(item,status){
  setError("");const now=new Date().toISOString();
  const {error:noteError}=await supabase.from("trial_application_reviews").upsert({application_id:item.id,coach_notes:notes[item.id]??item.coach_notes??null,reviewer_id:user.id,updated_at:now},{onConflict:"application_id"});
  if(noteError){setError(noteError.message);return;}
  const {error:e}=await supabase.from("trial_applications").update({status,reviewed_by:user.id,reviewed_at:now,updated_at:now}).eq("id",item.id);
  if(e)setError(e.message);else{setNotice("Application decision saved.");await load();}
 }
 async function allocateTeam(application){
  const opportunity=opportunities.find(o=>o.id===application.opportunity_id),teamId=teamAssignments[application.id];
  if(!application.athlete_id){setError("This application has no linked athlete profile. Link or create the athlete profile before allocating a team.");return;}
  if(!teamId||!opportunity){setError("Choose a team for this selected applicant.");return;}
  const team=teams.find(t=>t.id===teamId);
  if(!team){setError("Choose a valid active team.");return;}
  setError("");setNotice("");
  const {data:existing,error:lookupError}=await supabase.from("athlete_team_memberships").select("id").eq("athlete_id",application.athlete_id).eq("team_id",team.id).maybeSingle();
  if(lookupError){setError(lookupError.message);return;}
  const result=existing
   ? await supabase.from("athlete_team_memberships").update({is_active:true,left_at:null,position:application.playing_position||null,updated_at:new Date().toISOString()}).eq("id",existing.id)
   : await supabase.from("athlete_team_memberships").insert({athlete_id:application.athlete_id,team_id:team.id,sport_id:team.sport_id,position:application.playing_position||null,created_by:user.id});
  if(result.error)setError(result.error.message);else setNotice("Athlete added to "+team.name+" ("+(team.sports?.name||"sport")+") without changing their other team memberships.");
 }
 function exportReport(opportunity){
  const opCriteria=criteria.filter(c=>c.opportunity_id===opportunity.id);
  const rows=[["Applicant","Position","Application status",...opCriteria.map(c=>c.title+" average")]];
  applications.filter(a=>a.opportunity_id===opportunity.id).forEach(a=>{
   rows.push([a.full_name,a.playing_position||"",a.status,...opCriteria.map(c=>{
    const entries=scores.filter(s=>s.application_id===a.id&&s.criterion_id===c.id);
    return entries.length?(entries.reduce((sum,s)=>sum+Number(s.score),0)/entries.length).toFixed(2):"";
   })]);
  });
  const csv=rows.map(row=>row.map(v=>"\""+String(v??"").replaceAll("\"","\"\"")+"\"").join(",")).join("\r\n");
  const url=URL.createObjectURL(new Blob([csv],{type:"text/csv;charset=utf-8"}));
  const link=document.createElement("a");link.href=url;link.download="cut-sport-trial-"+opportunity.id+".csv";link.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
 }
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="An assigned sport administrator, team manager or coach role is required."/></main></>;
 return <><Header title="Recruitment management" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">TALENT IDENTIFICATION</span><h1>Trials, evaluation & squads.</h1><p>Publish opportunities, configure sport-specific assessment criteria, score applicants, select candidates and allocate linked athlete profiles to teams.</p></div>
  {error&&<p className="form-error" role="alert">{error}</p>}{notice&&<p className="admin-notice">{notice}</p>}
  <form className="form-card" onSubmit={create}><h3>Create recruitment opportunity</h3>
   <label>Sport<select required value={form.sport_id} onChange={e=>setForm({...form,sport_id:e.target.value,team_id:""})}><option value="">Choose sport</option>{sports.map(x=><option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
   <label>Team scope<select value={form.team_id} onChange={e=>setForm({...form,team_id:e.target.value})}><option value="">Whole sport</option>{availableTeams.map(x=><option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
   <label>Opportunity title<input required minLength="3" maxLength="140" value={form.title} onChange={e=>setForm({...form,title:e.target.value})} placeholder="e.g. 2027 Varsity squad trials"/></label>
   <label>Trial information<textarea rows="4" value={form.description} onChange={e=>setForm({...form,description:e.target.value})}/></label>
   <label>Venue<input value={form.venue} onChange={e=>setForm({...form,venue:e.target.value})}/></label>
   <label>Trial date and time<input type="datetime-local" value={form.starts_at} onChange={e=>setForm({...form,starts_at:e.target.value})}/></label>
   <label>Application closing date<input type="datetime-local" value={form.closes_at} onChange={e=>setForm({...form,closes_at:e.target.value})}/></label>
   <label>Publication status<select value={form.status} onChange={e=>setForm({...form,status:e.target.value})}><option value="draft">Save as draft</option><option value="open">Publish open trial</option></select></label>
   <button className="btn primary" disabled={busy||!sports.length}>{busy?"Saving…":"Save opportunity"}</button>
  </form>
  <Section title={"Recruitment opportunities · "+opportunities.length}>{opportunities.length?opportunities.map(o=>{
   const opCriteria=criteria.filter(c=>c.opportunity_id===o.id),opApplications=applications.filter(a=>a.opportunity_id===o.id);
   return <article className="performance-record" key={o.id}>
    <div className="performance-record-head"><div><b>{o.title}</b><small>{o.sports?.name||"Sport"}{o.teams?.name?" · "+o.teams.name:" · Whole sport"}</small></div><span>{o.status}</span></div>
    <p>{o.venue||"Venue TBC"} · {o.starts_at?dateLabel(o.starts_at):"Date TBC"}</p>
    <div className="review-actions">{o.status!=="open"&&<button className="btn primary" onClick={()=>setOpportunityStatus(o,"open")}>Open applications</button>}{o.status==="open"&&<button className="btn secondary" onClick={()=>setOpportunityStatus(o,"closed")}>Close applications</button>}{o.status==="closed"&&<button className="btn secondary" onClick={()=>setOpportunityStatus(o,"draft")}>Move to draft</button>}<button className="btn secondary" onClick={()=>exportReport(o)}>Export trial report CSV</button></div>
    <div className="form-card"><h4>Evaluation criteria · {opCriteria.length}</h4>
     {opCriteria.map(c=><div className="sponsor-card" key={c.id}><div><b>{c.title}</b><small>{c.description||"No description"} · scored out of {Number(c.max_score)}</small></div></div>)}
     {!opCriteria.length&&<p className="muted">No criteria yet. Add assessment measures appropriate to this sport and trial.</p>}
     <form onSubmit={e=>addCriterion(e,o)}><label>Criterion title<input required minLength="2" maxLength="120" value={criteriaDraft.title} onChange={e=>setCriteriaDraft({...criteriaDraft,title:e.target.value})} placeholder="e.g. Technical skill"/></label><label>What should coaches assess?<textarea rows="2" maxLength="1000" value={criteriaDraft.description} onChange={e=>setCriteriaDraft({...criteriaDraft,description:e.target.value})}/></label><label>Maximum score<input type="number" min="0.01" max="1000" step="0.01" required value={criteriaDraft.max_score} onChange={e=>setCriteriaDraft({...criteriaDraft,max_score:e.target.value})}/></label><button className="btn secondary" disabled={busy}>Add criterion</button></form>
    </div>
    <h4>Applicants · {opApplications.length}</h4>
    {opApplications.length?opApplications.map(a=>{
     const appCriteria=opCriteria,appScores=scores.filter(s=>s.application_id===a.id);
     const averages=appCriteria.map(c=>{const entries=appScores.filter(s=>s.criterion_id===c.id);return {criterion:c,average:entries.length?entries.reduce((sum,s)=>sum+Number(s.score),0)/entries.length:null,count:entries.length};});
     const complete=averages.length>0&&averages.every(x=>x.average!==null);
     const totalAverage=averages.reduce((sum,x)=>sum+(x.average??0),0),totalMaximum=appCriteria.reduce((sum,c)=>sum+Number(c.max_score),0);
     const linkedTeams=teams;
     return <div className="performance-record" key={a.id}>
      <div className="performance-record-head"><div><b>{a.full_name}</b><small>{a.playing_position||"Position not specified"} · {a.athlete_id?"Linked athlete profile":"No linked athlete profile"}</small></div><span>{a.status.replaceAll("_"," ")}</span></div>
      {a.experience&&<p><b>Experience:</b> {a.experience}</p>}{a.motivation&&<p><b>Motivation:</b> {a.motivation}</p>}
      {appCriteria.length>0?<div className="form-card"><h4>Coach scoring</h4>{appCriteria.map(c=>{
       const key=a.id+":"+c.id,myScore=appScores.find(s=>s.criterion_id===c.id&&s.reviewer_id===user.id),summary=averages.find(x=>x.criterion.id===c.id);
       return <div key={c.id}><label>{c.title} (0–{Number(c.max_score)})<input type="number" min="0" max={Number(c.max_score)} step="0.01" value={scoreDrafts[key]??(myScore?String(myScore.score):"")} onChange={e=>setScoreDrafts(current=>({...current,[key]:e.target.value}))} placeholder="Enter your score"/></label><small>{summary.count} coach score(s) · average {summary.average===null?"Not scored":summary.average.toFixed(2)}</small><button type="button" className="btn secondary" onClick={()=>saveScore(a,c)}>Save score</button></div>;
      })}{complete&&<p className="admin-notice">Average total: {totalAverage.toFixed(2)} / {totalMaximum.toFixed(2)} ({((totalAverage/totalMaximum)*100).toFixed(1)}%)</p>}</div>:<p className="muted">Add evaluation criteria above before scoring applicants.</p>}
      <label>Private coach evaluation notes<textarea rows="2" value={notes[a.id]??a.coach_notes??""} onChange={e=>setNotes(current=>({...current,[a.id]:e.target.value}))} placeholder="Private notes for the selection record"/></label>
      <div className="review-actions"><button className="btn secondary" onClick={()=>reviewApplication(a,"shortlisted")}>Shortlist</button><button className="btn primary" onClick={()=>reviewApplication(a,"selected")}>Select</button><button className="btn secondary" onClick={()=>reviewApplication(a,"not_selected")}>Not selected</button></div>
      {a.status==="selected"&&a.athlete_id&&<div className="form-card"><h4>Squad allocation</h4><label>Assign to an additional team (any sport)<select value={teamAssignments[a.id]||""} onChange={e=>setTeamAssignments(current=>({...current,[a.id]:e.target.value}))}><option value="">Choose team</option>{linkedTeams.map(t=><option key={t.id} value={t.id}>{t.name} — {t.sports?.name||"Sport"}</option>)}</select></label><button type="button" className="btn primary" onClick={()=>allocateTeam(a)}>Save team allocation</button></div>}
      {a.status==="selected"&&!a.athlete_id&&<p className="muted">To allocate this selected applicant, first link their application to an approved athlete profile.</p>}
     </div>;
    }):<Empty title="No applications received" body="Applications submitted to this opportunity will appear here."/>}
   </article>;
  }):<Empty title="No opportunities created" body="Create a trial opportunity above. It will only be visible publicly when published as open."/>}</Section>
 </main></>;
}

function AdminTeams({roles,user}) {
 const sportAdmin=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const superAdmin=roles.includes("super_admin");
 const blank={sport_id:"",name:"",category:"",season:"",coach_name:""};
 const [sports,setSports]=useState([]),[teams,setTeams]=useState([]),[form,setForm]=useState(blank),[editing,setEditing]=useState(null);
 const [assignments,setAssignments]=useState([]),[staff,setStaff]=useState([]),[selectedStaff,setSelectedStaff]=useState(""),[assignmentSport,setAssignmentSport]=useState(""),[assignmentTeam,setAssignmentTeam]=useState(""),[assignmentRole,setAssignmentRole]=useState("coach"),[startsOn,setStartsOn]=useState(""),[endsOn,setEndsOn]=useState("");
 const [busy,setBusy]=useState(false),[error,setError]=useState(""),[notice,setNotice]=useState("");
 async function load(){
  if(!supabase||!sportAdmin)return;
  setBusy(true);setError("");
  const [s,t]=await Promise.all([
   supabase.from("sports").select("id,name,is_active").order("name"),
   supabase.from("teams").select("id,name,sport_id,category,season,coach_name,is_active,created_at,sports(name)").order("name")
  ]);
  if(s.error||t.error){setError(s.error?.message||t.error?.message);setBusy(false);return}
  setSports(s.data||[]);setTeams(t.data||[]);
  if(superAdmin){
   const [a,sp,pr]=await Promise.all([
    supabase.from("sport_admin_assignments").select("id,admin_profile_id,sport_id,team_id,assignment_role,starts_on,ends_on,is_active,created_at").order("created_at",{ascending:false}),
    supabase.from("sport_admin_profiles").select("profile_id,job_title,department,employment_status"),
    supabase.from("profiles").select("id,full_name,email").order("full_name")
   ]);
   if(a.error||sp.error||pr.error)setError(a.error?.message||sp.error?.message||pr.error?.message);
   else{
    const profileMap=Object.fromEntries((pr.data||[]).map(x=>[x.id,x]));
    const staffMap=Object.fromEntries((sp.data||[]).map(x=>[x.profile_id,{...x,profile:profileMap[x.profile_id]}]));
    setStaff(Object.entries(staffMap).filter(([id,x])=>x.profile).map(([id,x])=>({id,...x})));
    setAssignments((a.data||[]).map(x=>({...x,person:staffMap[x.admin_profile_id]?.profile,staff:staffMap[x.admin_profile_id]})));
   }
  }
  setBusy(false);
 }
 useEffect(()=>{load()},[sportAdmin,superAdmin,user?.id]);
 function reset(){setEditing(null);setForm(blank);setError("");}
 function edit(t){setEditing(t.id);setForm({sport_id:t.sport_id,name:t.name,category:t.category||"",season:t.season||"",coach_name:t.coach_name||""});setError("");}
 async function saveTeam(e){
  e.preventDefault();if(!sportAdmin||!supabase)return;
  if(!form.sport_id||!form.name.trim()){setError("Choose a sport and enter a team name.");return}
  setBusy(true);setError("");setNotice("");
  const payload={sport_id:form.sport_id,name:form.name.trim(),category:form.category.trim()||null,season:form.season.trim()||null,coach_name:form.coach_name.trim()||null};
  const result=editing?await supabase.from("teams").update(payload).eq("id",editing).select("id").maybeSingle():await supabase.from("teams").insert(payload).select("id").maybeSingle();
  if(result.error)setError(result.error.message);else if(!result.data)setError("No team change was saved. Confirm your active sport-admin assignment.");else{reset();setNotice(editing?"Team details updated.":"Team created.");await load()}
  setBusy(false);
 }
 async function archiveTeam(t){
  if(!sportAdmin||!supabase)return;
  setBusy(true);setError("");setNotice("");
  const {data,error}=await supabase.from("teams").update({is_active:!t.is_active}).eq("id",t.id).select("id").maybeSingle();
  if(error)setError(error.message);else if(!data)setError("No team status changed. Check your sport-admin assignment.");else{setNotice(t.is_active?"Team archived; its roster and history remain intact.":"Team restored.");await load()}
  setBusy(false);
 }
 async function saveAssignment(e){
  e.preventDefault();if(!superAdmin||!supabase)return;
  if(!selectedStaff||!assignmentSport){setError("Choose a staff profile and sport.");return}
  if(assignmentRole!=="sport_admin"&&!assignmentTeam){setError("Choose a team for coach or team-manager access.");return}
  if(startsOn&&endsOn&&endsOn<startsOn){setError("The end date must be on or after the start date.");return}
  setBusy(true);setError("");setNotice("");
  const {error}=await supabase.from("sport_admin_assignments").insert({admin_profile_id:selectedStaff,sport_id:assignmentSport,team_id:assignmentRole==="sport_admin"?null:assignmentTeam,assignment_role:assignmentRole,starts_on:startsOn||null,ends_on:endsOn||null,is_active:true});
  if(error)setError(error.message);else{setSelectedStaff("");setAssignmentTeam("");setStartsOn("");setEndsOn("");setNotice("Staff assignment created.");await load()}
  setBusy(false);
 }
 async function toggleAssignment(a){
  if(!superAdmin||!supabase)return;
  setBusy(true);setError("");setNotice("");
  const {data,error}=await supabase.from("sport_admin_assignments").update({is_active:!a.is_active}).eq("id",a.id).select("id").maybeSingle();
  if(error)setError(error.message);else if(!data)setError("Assignment was not changed.");else{setNotice(a.is_active?"Staff assignment deactivated.":"Staff assignment reactivated.");await load()}
  setBusy(false);
 }
 if(!sportAdmin)return <><Header title="Team management access required" back/><main className="page"><Empty title="Restricted area" body="A sport administrator or super administrator role is required."/></main></>;
 const availableTeams=teams.filter(t=>t.sport_id===assignmentSport&&t.is_active);
 return <><Header title="Teams & staff" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">CUT SPORT · TEAM OPERATIONS</span><h1>Teams & staff.</h1><p>Create and maintain squads by sport, category and season. Staff access is assigned to a specific sport or team; Supabase Row Level Security remains authoritative.</p></div>
  {error&&<p className="form-error" role="alert">{error}</p>}{notice&&<p className="admin-notice">{notice}</p>}
  <Section title={editing?"Edit team":"Create a team"}>
   <form className="form-card" onSubmit={saveTeam}>
    <label>Sport<select required value={form.sport_id} onChange={e=>setForm({...form,sport_id:e.target.value})}><option value="">Choose sport</option>{sports.filter(s=>s.is_active).map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
    <label>Team / squad name<input required maxLength="120" value={form.name} onChange={e=>setForm({...form,name:e.target.value})} placeholder="e.g. Men's First Team"/></label>
    <label>Category<input maxLength="80" value={form.category} onChange={e=>setForm({...form,category:e.target.value})} placeholder="Men, Women, U21, Open…"/></label>
    <label>Season<input maxLength="40" value={form.season} onChange={e=>setForm({...form,season:e.target.value})} placeholder="2026"/></label>
    <label>Coach display name (optional)<input maxLength="120" value={form.coach_name} onChange={e=>setForm({...form,coach_name:e.target.value})}/></label>
    <div className="review-actions"><button className="btn primary" disabled={busy}>{busy?"Saving…":editing?"Save team":"Create team"}</button>{editing&&<button type="button" onClick={reset}>Cancel</button>}</div>
   </form>
  </Section>
  <Section title="Team directory">{teams.length?teams.map(t=><article className="performance-record" key={t.id}><div className="performance-record-head"><div><b>{t.name}</b><small>{t.sports?.name||"Sport"} · {t.category||"Category not set"} · {t.season||"Season not set"}</small></div><span className={"order-status "+(t.is_active?"is-paid":"")}>{t.is_active?"Active":"Archived"}</span></div>{t.coach_name&&<p className="muted">Coach: {t.coach_name}</p>}<div className="review-actions"><button type="button" disabled={busy} onClick={()=>edit(t)}>Edit</button><button type="button" disabled={busy} onClick={()=>archiveTeam(t)}>{t.is_active?"Archive team":"Restore team"}</button></div></article>):<Empty title={busy?"Loading teams":"No teams created"} body="Create the first squad above. Existing athlete and fixture records are preserved when a team is archived."/>}</Section>
  {superAdmin&&<Section title="Staff assignments">
   <p className="muted">Only existing CUT Sport staff profiles are eligible. Sport administrators receive full-sport management; coaches and team managers receive team-level access.</p>
   <form className="form-card" onSubmit={saveAssignment}>
    <label>Staff member<select required value={selectedStaff} onChange={e=>setSelectedStaff(e.target.value)}><option value="">Choose staff profile</option>{staff.filter(s=>s.employment_status==="active").map(s=><option key={s.id} value={s.id}>{s.profile?.full_name||s.profile?.email||s.id} · {s.job_title}</option>)}</select></label>
    <label>Sport<select required value={assignmentSport} onChange={e=>{setAssignmentSport(e.target.value);setAssignmentTeam("")}}><option value="">Choose sport</option>{sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
    <label>Assignment role<select value={assignmentRole} onChange={e=>setAssignmentRole(e.target.value)}><option value="coach">Coach</option><option value="team_manager">Team manager</option><option value="sport_admin">Sport administrator</option></select></label>
    {assignmentRole!=="sport_admin"&&<label>Team<select required value={assignmentTeam} onChange={e=>setAssignmentTeam(e.target.value)}><option value="">Choose team</option>{availableTeams.map(t=><option key={t.id} value={t.id}>{t.name}{t.category?" · "+t.category:""}</option>)}</select></label>}
    <label>Starts on (optional)<input type="date" value={startsOn} onChange={e=>setStartsOn(e.target.value)}/></label>
    <label>Ends on (optional)<input type="date" min={startsOn||undefined} value={endsOn} onChange={e=>setEndsOn(e.target.value)}/></label>
    <button className="btn primary" disabled={busy||!staff.length}>{busy?"Saving…":"Assign staff access"}</button>
   </form>
   <Section title="Current and historical assignments">{assignments.length?assignments.map(a=><article className="performance-record" key={a.id}><div className="performance-record-head"><div><b>{a.person?.full_name||a.person?.email||"Staff profile"}</b><small>{sports.find(s=>s.id===a.sport_id)?.name||"Sport"} · {a.assignment_role.replaceAll("_"," ")}{a.team_id?" · "+(teams.find(t=>t.id===a.team_id)?.name||"Team"):" · All teams"}</small></div><span className={"order-status "+(a.is_active?"is-paid":"")}>{a.is_active?"Active":"Inactive"}</span></div><small>{a.starts_on||"No start date"} → {a.ends_on||"No end date"}</small><div className="review-actions"><button type="button" disabled={busy} onClick={()=>toggleAssignment(a)}>{a.is_active?"Deactivate":"Reactivate"}</button></div></article>):<Empty title="No staff assignments" body="Staff access assignments will be listed here once created."/>}</Section>
  </Section>}
  <p className="muted">Team archival is non-destructive. Staff access changes are restricted to super administrators and use the existing assignment security policies.</p>
 </main></>;
}

function AdminRosters({roles,user}) {
 const allowed=roles.some(r=>["sport_admin","super_admin","coach"].includes(r));
 const [teams,setTeams]=useState([]),[selectedTeam,setSelectedTeam]=useState("");
 const [members,setMembers]=useState([]),[athletes,setAthletes]=useState([]);
 const [athleteId,setAthleteId]=useState(""),[position,setPosition]=useState(""),[number,setNumber]=useState("");
 const [editing,setEditing]=useState({}),[busy,setBusy]=useState(false),[error,setError]=useState(""),[notice,setNotice]=useState("");
 async function loadTeams(){
  if(!supabase||!allowed)return;
  const {data,error}=await supabase.from("teams").select("id,name,sport_id,category,season,coach_name,sports(name)").eq("is_active",true).order("name");
  if(error){setError(error.message);return}
  setTeams(data||[]);
  if(!selectedTeam&&data?.length)setSelectedTeam(data[0].id);
 }
 async function loadRoster(teamId=selectedTeam){
  if(!supabase||!teamId){setMembers([]);return}
  const {data,error}=await supabase.from("athlete_team_memberships").select("id,athlete_id,team_id,sport_id,position,squad_number,is_active,joined_at,left_at,athletes(id,full_name,preferred_name,approval_status,profile_visibility),sports(name),teams(name)").eq("team_id",teamId).order("is_active",{ascending:false}).order("joined_at",{ascending:false});
  if(error){setError(error.message);return}
  setMembers(data||[]);
  setEditing(Object.fromEntries((data||[]).map(m=>[m.id,{position:m.position||"",squad_number:m.squad_number??""}])));
 }
 async function loadAthletes(){
  if(!supabase||!allowed)return;
  const {data,error}=await supabase.from("athletes").select("id,full_name,preferred_name,approval_status").eq("approval_status","approved").order("full_name");
  if(error)setError(error.message);else setAthletes(data||[]);
 }
 useEffect(()=>{loadTeams();loadAthletes()},[allowed]);
 useEffect(()=>{if(selectedTeam)loadRoster(selectedTeam);else setMembers([])},[selectedTeam]);
 const team=teams.find(t=>t.id===selectedTeam);
 async function addAthlete(e){
  e.preventDefault();if(!user?.id||!team||!athleteId||busy)return;
  setBusy(true);setError("");setNotice("");
  const existing=members.find(m=>m.athlete_id===athleteId);
  const values={position:position.trim()||null,squad_number:number===""?null:Number(number)};
  if(values.squad_number!==null&&(!Number.isInteger(values.squad_number)||values.squad_number<0||values.squad_number>999)){setError("Squad number must be a whole number from 0 to 999.");setBusy(false);return}
  let result;
  if(existing)result=await supabase.from("athlete_team_memberships").update({...values,is_active:true,left_at:null,joined_at:existing.is_active?existing.joined_at:new Date().toISOString().slice(0,10),updated_at:new Date().toISOString()}).eq("id",existing.id).select("id").maybeSingle();
  else result=await supabase.from("athlete_team_memberships").insert({athlete_id:athleteId,team_id:team.id,sport_id:team.sport_id,created_by:user.id,...values}).select("id").maybeSingle();
  if(result.error)setError(result.error.message);
  else if(!result.data)setError("No roster change was made. Confirm that you have management permission for this team.");
  else{setAthleteId("");setPosition("");setNumber("");setNotice("Athlete added to "+team.name+".");await loadRoster(team.id)}
  setBusy(false);
 }
 async function saveMember(m){
  const value=editing[m.id]||{};
  const squad=value.squad_number===""?null:Number(value.squad_number);
  if(squad!==null&&(!Number.isInteger(squad)||squad<0||squad>999)){setError("Squad number must be a whole number from 0 to 999.");return}
  if((value.position||"").trim().length>120){setError("Position must be 120 characters or fewer.");return}
  setBusy(true);setError("");setNotice("");
  const {data,error}=await supabase.from("athlete_team_memberships").update({position:(value.position||"").trim()||null,squad_number:squad,updated_at:new Date().toISOString()}).eq("id",m.id).select("id").maybeSingle();
  if(error)setError(error.message);else if(!data)setError("Membership was not updated. Check team-level permissions.");else{setNotice("Roster details saved.");await loadRoster()}
  setBusy(false);
 }
 async function endMember(m){
  if(!window.confirm("End this athlete's membership of "+(team?.name||"this team")+"? The membership history will be kept."))return;
  setBusy(true);setError("");setNotice("");
  const {data,error}=await supabase.from("athlete_team_memberships").update({is_active:false,left_at:new Date().toISOString().slice(0,10),updated_at:new Date().toISOString()}).eq("id",m.id).eq("is_active",true).select("id").maybeSingle();
  if(error)setError(error.message);else if(!data)setError("Membership was not changed. Check team-level permissions.");else{setNotice("Membership ended; its history has been retained.");await loadRoster()}
  setBusy(false);
 }
 if(!allowed)return <><Header title="Roster access required" back/><main className="page"><Empty title="Restricted area" body="An assigned sport administrator, coach or team manager role is required."/></main></>;
 return <><Header title="Team roster management" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">SQUAD MANAGEMENT</span><h1>Team rosters.</h1><p>View and maintain athlete lists by team. Memberships are managed independently, so an athlete can represent multiple CUT sport codes.</p></div>
  {error&&<p className="form-error" role="alert">{error}</p>}{notice&&<p className="admin-notice">{notice}</p>}
  <div className="form-card"><label>Select team<select value={selectedTeam} onChange={e=>setSelectedTeam(e.target.value)}><option value="">Choose an active team</option>{teams.map(t=><option key={t.id} value={t.id}>{t.sports?.name||"Sport"} · {t.name}{t.category?" · "+t.category:""}</option>)}</select></label>
   {team&&<p className="muted">{team.season||"Current squad"}{team.coach_name?" · Coach: "+team.coach_name:""} · {members.filter(m=>m.is_active).length} active athlete(s)</p>}
  </div>
  {team&&<Section title="Add athlete to this squad"><form className="form-card" onSubmit={addAthlete}>
   <label>Approved athlete<select required value={athleteId} onChange={e=>setAthleteId(e.target.value)}><option value="">Choose athlete</option>{athletes.filter(a=>!members.some(m=>m.athlete_id===a.id&&m.is_active)).map(a=><option key={a.id} value={a.id}>{a.preferred_name||a.full_name}</option>)}</select></label>
   <label>Position / event<input maxLength="120" value={position} onChange={e=>setPosition(e.target.value)}/></label>
   <label>Squad number<input type="number" min="0" max="999" step="1" value={number} onChange={e=>setNumber(e.target.value)}/></label>
   <button className="btn primary" disabled={busy||!athleteId}>{busy?"Saving…":"Add to roster"}</button>
  </form></Section>}
  <Section title={team?"Squad members · "+team.name:"Squad members"}>
   {members.length?members.map(m=><article className="performance-record" key={m.id}>
    <div className="performance-record-head"><div><b>{m.athletes?.preferred_name||m.athletes?.full_name||"Athlete record"}</b><small>{m.sports?.name||"Sport"} · {m.athletes?.approval_status||"Profile status unavailable"} · Joined {dateLabel(m.joined_at)}</small></div><span className={"order-status "+(m.is_active?"is-paid":"")}>{m.is_active?"Active":"Inactive"}</span></div>
    {m.is_active?<><label>Position / event<input maxLength="120" value={editing[m.id]?.position??""} onChange={e=>setEditing(v=>({...v,[m.id]:{...v[m.id],position:e.target.value}}))}/></label><label>Squad number<input type="number" min="0" max="999" step="1" value={editing[m.id]?.squad_number??""} onChange={e=>setEditing(v=>({...v,[m.id]:{...v[m.id],squad_number:e.target.value}}))}/></label><div className="review-actions"><button type="button" className="btn secondary" disabled={busy} onClick={()=>saveMember(m)}>Save details</button><button type="button" disabled={busy} onClick={()=>endMember(m)}>End membership</button></div></>:<p className="muted">Membership ended {m.left_at?dateLabel(m.left_at):"on an unspecified date"}. Historical record retained.</p>}
   </article>):<Empty title="No athletes in this roster" body="Add approved athlete profiles to build this team's squad. You will only be able to save changes where your team assignment permits it."/>}
  </Section>
  <p className="muted">Need to create or approve an athlete profile? <Link to="/admin/athletes">Open Athlete Management</Link>.</p>
 </main></>;
}

function AdminAthletes({roles,user}) {
 const allowed=roles.some(r=>["sport_admin","super_admin","coach"].includes(r));
 const superAdmin=roles.includes("super_admin");
 const [sports,setSports]=useState([]),[teams,setTeams]=useState([]),[items,setItems]=useState([]),[profiles,setProfiles]=useState([]);
 const [busy,setBusy]=useState(false),[error,setError]=useState(""),[editing,setEditing]=useState(null);
 const [membershipAthlete,setMembershipAthlete]=useState(null),[memberships,setMemberships]=useState([]),[membershipTeam,setMembershipTeam]=useState(""),[membershipPosition,setMembershipPosition]=useState(""),[membershipNumber,setMembershipNumber]=useState(""),[membershipBusy,setMembershipBusy]=useState(false),[membershipError,setMembershipError]=useState("");
 const blank={sport_id:"",team_id:"",profile_id:"",full_name:"",preferred_name:"",position:"",gender:"",nationality:"",hometown:"",province:"",faculty:"",qualification:"",year_of_study:"",student_status:"current",years_representing_cut:"",previous_clubs:"",squad_number:"",bio:"",photo_url:"",is_featured:false,profile_visibility:"public"};
 const [form,setForm]=useState(blank);
 async function load(){
  if(!supabase||!allowed)return;
  const [s,t,a,p]=await Promise.all([
   supabase.from("sports").select("id,name").eq("is_active",true).order("display_order"),
   supabase.from("teams").select("id,name,sport_id,sports(name)").eq("is_active",true).order("name"),
   supabase.from("athletes").select("id,profile_id,sport_id,team_id,full_name,preferred_name,position,gender,nationality,hometown,province,faculty,qualification,year_of_study,student_status,years_representing_cut,previous_clubs,squad_number,bio,photo_url,is_featured,approval_status,profile_visibility,sports(name),teams(name)").order("full_name"),
   superAdmin?supabase.from("profiles").select("id,full_name,email,student_number").order("full_name"):Promise.resolve({data:[],error:null})
  ]);
  const failure=s.error||t.error||a.error||p.error;
  if(failure)setError(failure.message);
  else{setSports(s.data||[]);setTeams(t.data||[]);setItems(a.data||[]);setProfiles(p.data||[]);}
 }
 useEffect(()=>{load()},[allowed,superAdmin]);
 const availableTeams=teams.filter(t=>!form.sport_id||t.sport_id===form.sport_id);
 async function openMemberships(item){
  setMembershipAthlete(item);setMembershipError("");setMembershipTeam("");setMembershipPosition("");setMembershipNumber("");setMemberships([]);
  if(!supabase)return;
  const {data,error}=await supabase.from("athlete_team_memberships").select("id,athlete_id,team_id,sport_id,position,squad_number,is_active,joined_at,left_at,teams(name),sports(name)").eq("athlete_id",item.id).order("joined_at",{ascending:false});
  if(error)setMembershipError(error.message);else setMemberships(data||[]);
 }
 function edit(item){setEditing(item.id);setForm({...blank,...item,year_of_study:item.year_of_study??"",years_representing_cut:item.years_representing_cut??"",previous_clubs:(item.previous_clubs||[]).join(", "),squad_number:item.squad_number??"",team_id:item.team_id||""});setError("");}
 function reset(){setEditing(null);setForm(blank);setError("");}
 async function save(e){
  e.preventDefault();if(!allowed||!supabase)return;
  setBusy(true);setError("");
  const payload={profile_id:superAdmin?(form.profile_id||null):undefined,sport_id:form.sport_id,team_id:form.team_id||null,full_name:form.full_name.trim(),preferred_name:form.preferred_name.trim()||null,position:form.position.trim()||null,gender:form.gender||null,nationality:form.nationality.trim()||null,hometown:form.hometown.trim()||null,province:form.province.trim()||null,faculty:form.faculty.trim()||null,qualification:form.qualification.trim()||null,year_of_study:form.year_of_study===""?null:Number(form.year_of_study),student_status:form.student_status,years_representing_cut:form.years_representing_cut===""?null:Number(form.years_representing_cut),previous_clubs:form.previous_clubs.split(",").map(x=>x.trim()).filter(Boolean),squad_number:form.squad_number===""?null:Number(form.squad_number),bio:form.bio.trim()||null,photo_url:form.photo_url.trim()||null,is_featured:Boolean(form.is_featured),profile_visibility:form.profile_visibility};
  const result=editing
   ?await supabase.from("athletes").update(payload).eq("id",editing).select("id").maybeSingle()
   :await supabase.from("athletes").insert({...payload,approval_status:"pending"}).select("id").single();
  if(result.error)setError(result.error.message);
  else if(!result.data)setError("No athlete record was changed. Check your assigned sport permissions.");
  else{
   let membershipFailure=null;
   if(form.team_id){
    const {data:existing,error:lookupError}=await supabase.from("athlete_team_memberships").select("id,is_active,joined_at").eq("athlete_id",result.data.id).eq("team_id",form.team_id).maybeSingle();
    if(lookupError)membershipFailure=lookupError.message;
    else{
     const team=teams.find(t=>t.id===form.team_id);
     const values={position:form.position.trim()||null,squad_number:form.squad_number===""?null:Number(form.squad_number)};
     const membershipResult=existing
      ?await supabase.from("athlete_team_memberships").update({...values,is_active:true,joined_at:existing.is_active?existing.joined_at:new Date().toISOString().slice(0,10),left_at:null,updated_at:new Date().toISOString()}).eq("id",existing.id).select("id").maybeSingle()
      :await supabase.from("athlete_team_memberships").insert({athlete_id:result.data.id,team_id:form.team_id,sport_id:team?.sport_id||form.sport_id,created_by:user.id,...values}).select("id").maybeSingle();
     if(membershipResult.error)membershipFailure=membershipResult.error.message;
     else if(!membershipResult.data)membershipFailure="Your account may not have permission to manage the selected team.";
    }
   }
   reset();await load();
   if(membershipFailure)setError("Athlete profile saved, but the primary-team membership could not be saved: "+membershipFailure);
  }
  setBusy(false);
 }
 async function saveMembership(e){
  e.preventDefault();
  if(!membershipAthlete||!membershipTeam||!user||!supabase||membershipBusy)return;
  const team=teams.find(t=>t.id===membershipTeam);
  if(!team){setMembershipError("Choose an active team.");return}
  const number=membershipNumber===""?null:Number(membershipNumber);
  if(number!==null&&(!Number.isInteger(number)||number<0||number>999)){setMembershipError("Squad number must be a whole number from 0 to 999.");return}
  if(membershipPosition.trim().length>120){setMembershipError("Position must be 120 characters or fewer.");return}
  setMembershipBusy(true);setMembershipError("");
  const existing=memberships.find(m=>m.team_id===team.id);
  const values={position:membershipPosition.trim()||null,squad_number:number};
  let result;
  if(existing){
   result=await supabase.from("athlete_team_memberships").update({...values,is_active:true,joined_at:existing.is_active?existing.joined_at:new Date().toISOString().slice(0,10),left_at:null,updated_at:new Date().toISOString()}).eq("id",existing.id).select("id").maybeSingle();
  }else{
   result=await supabase.from("athlete_team_memberships").insert({athlete_id:membershipAthlete.id,team_id:team.id,sport_id:team.sport_id,created_by:user.id,...values}).select("id").maybeSingle();
  }
  if(result.error)setMembershipError(result.error.message);
  else if(!result.data)setMembershipError("No membership was changed. Your account may not have management permission for that team.");
  else{setMembershipTeam("");setMembershipPosition("");setMembershipNumber("");await openMemberships(membershipAthlete);}
  setMembershipBusy(false);
 }
 async function deactivateMembership(membership){
  if(!supabase||membershipBusy)return;
  setMembershipBusy(true);setMembershipError("");
  const {data,error}=await supabase.from("athlete_team_memberships").update({is_active:false,left_at:new Date().toISOString().slice(0,10),updated_at:new Date().toISOString()}).eq("id",membership.id).eq("is_active",true).select("id").maybeSingle();
  if(error)setMembershipError(error.message);else if(!data)setMembershipError("This membership was not changed. Check your team-level permissions.");
  else await openMemberships(membershipAthlete);
  setMembershipBusy(false);
 }
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="An assigned sport administrator, coach or super administrator role is required."/></main></>;
 return <><Header title="Athlete management" back/><main className="page"><div className="page-intro"><span className="eyebrow">ASSIGNED SPORT ACCESS</span><h1>Athlete profiles</h1><p>Manage athlete records and their memberships across multiple CUT sport codes. Team-level permissions determine which squads you can manage.</p></div>
 <form className="form-card" onSubmit={save}><h3>{editing?"Update athlete profile":"Register athlete profile"}</h3>
 <label>Sport code<select required value={form.sport_id} onChange={e=>setForm({...form,sport_id:e.target.value,team_id:""})}><option value="">Choose sport</option>{sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
 <label>Primary team<select value={form.team_id} onChange={e=>setForm({...form,team_id:e.target.value})}><option value="">No primary team selected</option>{availableTeams.map(t=><option key={t.id} value={t.id}>{t.name}</option>)}</select></label>{superAdmin&&<label>Link CUT Sport account<select value={form.profile_id||""} onChange={e=>setForm({...form,profile_id:e.target.value})}><option value="">No account linked</option>{profiles.map(p=><option key={p.id} value={p.id}>{p.full_name||p.email||p.id}{p.student_number?" · "+p.student_number:""}</option>)}</select><small>Only a super administrator can link an athlete record to a member account.</small></label>}
 <label>Full name<input required value={form.full_name} onChange={e=>setForm({...form,full_name:e.target.value})}/></label>
 <label>Preferred name<input value={form.preferred_name||""} onChange={e=>setForm({...form,preferred_name:e.target.value})}/></label>
 <label>Playing position / event<input value={form.position||""} onChange={e=>setForm({...form,position:e.target.value})}/></label>
 <label>Gender<select value={form.gender||""} onChange={e=>setForm({...form,gender:e.target.value})}><option value="">Not specified</option><option value="female">Female</option><option value="male">Male</option><option value="non_binary">Non-binary</option><option value="prefer_not_to_say">Prefer not to say</option></select></label>
 <label>Nationality<input value={form.nationality} onChange={e=>setForm({...form,nationality:e.target.value})}/></label>
 <label>Hometown<input value={form.hometown} onChange={e=>setForm({...form,hometown:e.target.value})}/></label>
 <label>Province<input value={form.province} onChange={e=>setForm({...form,province:e.target.value})}/></label>
 <label>Faculty<input value={form.faculty} onChange={e=>setForm({...form,faculty:e.target.value})}/></label>
 <label>Qualification<input value={form.qualification} onChange={e=>setForm({...form,qualification:e.target.value})}/></label>
 <label>Year of study<input type="number" min="1" max="12" value={form.year_of_study} onChange={e=>setForm({...form,year_of_study:e.target.value})}/></label>
 <label>Student status<select value={form.student_status} onChange={e=>setForm({...form,student_status:e.target.value})}><option value="current">Current student</option><option value="alumni">Alumni</option><option value="former">Former student</option><option value="staff">Staff</option></select></label>
 <label>Years representing CUT<input type="number" min="0" value={form.years_representing_cut} onChange={e=>setForm({...form,years_representing_cut:e.target.value})}/></label>
 <label>Previous clubs (comma separated)<input value={form.previous_clubs} onChange={e=>setForm({...form,previous_clubs:e.target.value})}/></label>
 <label>Squad number (primary team)<input type="number" min="0" max="999" value={form.squad_number} onChange={e=>setForm({...form,squad_number:e.target.value})}/></label>
 <label>Short biography<textarea value={form.bio||""} onChange={e=>setForm({...form,bio:e.target.value})}/></label>
 <label>Photo URL<input type="url" value={form.photo_url||""} onChange={e=>setForm({...form,photo_url:e.target.value})}/></label>
 <label>Profile visibility<select value={form.profile_visibility} onChange={e=>setForm({...form,profile_visibility:e.target.value})}><option value="public">Public after approval</option><option value="private">Private</option></select></label>
 <label className="check-label"><input type="checkbox" checked={Boolean(form.is_featured)} onChange={e=>setForm({...form,is_featured:e.target.checked})}/> Feature on sport profile</label>
 <button className="btn primary" disabled={busy||!sports.length}>{busy?"Saving…":editing?"Save athlete":"Register athlete"}</button>{editing&&<button type="button" onClick={reset}>Cancel edit</button>}{error&&<p className="form-error">{error}</p>}</form>
 <Section title="Athlete records">{items.length?items.map(a=><div className="sponsor-card admin-sponsor" key={a.id}><div><b>{a.preferred_name||a.full_name}</b><small>{a.sports?.name||"Sport not set"} · {a.teams?.name||"No primary team"} · {a.approval_status}</small></div><button onClick={()=>edit(a)}>Edit</button><button disabled={membershipBusy} onClick={()=>openMemberships(a)}>Manage teams</button></div>):<Empty title="No athlete records" body="No athlete profiles are currently available within your assigned sport or team permissions."/>}</Section>
 {membershipAthlete&&<Section title={"Team memberships · "+(membershipAthlete.preferred_name||membershipAthlete.full_name)}>
  <div className="form-card"><p className="muted">Add this athlete to another active team without changing their primary sport or existing memberships. Your account must have management permission for the destination team.</p>
   <form onSubmit={saveMembership}>
    <label>Sport team<select required value={membershipTeam} onChange={e=>{setMembershipTeam(e.target.value);const existing=memberships.find(m=>m.team_id===e.target.value);setMembershipPosition(existing?.position||"");setMembershipNumber(existing?.squad_number??"")}}><option value="">Choose a team across all sports</option>{teams.map(t=><option key={t.id} value={t.id}>{t.sports?.name||"Sport"} · {t.name}{memberships.some(m=>m.team_id===t.id&&m.is_active)?" · Active membership":memberships.some(m=>m.team_id===t.id)?" · Reactivate":""}</option>)}</select></label>
    <label>Position / event<input maxLength="120" value={membershipPosition} onChange={e=>setMembershipPosition(e.target.value)}/></label>
    <label>Squad number<input type="number" min="0" max="999" step="1" value={membershipNumber} onChange={e=>setMembershipNumber(e.target.value)}/></label>
    <button className="btn primary" disabled={membershipBusy||!membershipTeam}>{membershipBusy?"Saving…":memberships.some(m=>m.team_id===membershipTeam)?"Save / reactivate membership":"Add team membership"}</button>
    <button type="button" disabled={membershipBusy} onClick={()=>{setMembershipAthlete(null);setMemberships([]);setMembershipError("")}}>Close</button>
   </form>
  </div>
  {membershipError&&<p className="form-error">{membershipError}</p>}
  {memberships.length?memberships.map(m=><article className="performance-record" key={m.id}><div className="performance-record-head"><div><b>{m.sports?.name||"Sport"} · {m.teams?.name||"Team"}</b><small>{m.position||"Position not set"}{m.squad_number!==null?" · #"+m.squad_number:""} · Joined {dateLabel(m.joined_at)}</small></div><span className={"order-status "+(m.is_active?"is-paid":"")}>{m.is_active?"Active":"Inactive"}</span></div>{!m.is_active&&m.left_at&&<p className="muted">Membership ended {dateLabel(m.left_at)}. You can reactivate it using the team selector.</p>}{m.is_active&&<button type="button" disabled={membershipBusy} onClick={()=>deactivateMembership(m)}>End membership</button>}</article>):<Empty title="No team memberships recorded" body="Add the athlete to one or more active teams. Existing primary-team details remain unchanged until separately edited."/ >}
 </Section>}
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
 const [seasonFilter,setSeasonFilter]=useState("all"),[sportFilter,setSportFilter]=useState("all"),[fixtureStatusFilter,setFixtureStatusFilter]=useState("all");
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
 const seasonOptions=[...new Set([...teams.map(t=>t.season),...competitions.map(c=>c.season)].filter(Boolean))].sort((a,b)=>b.localeCompare(a));
 const visibleTeams=teams.filter(t=>(sportFilter==="all"||t.sport_id===sportFilter)&&(seasonFilter==="all"||t.season===seasonFilter));
 const visibleCompetitions=competitions.filter(c=>(sportFilter==="all"||c.sport_id===sportFilter)&&(seasonFilter==="all"||c.season===seasonFilter));
 const visibleFixtures=fixtures.filter(f=>(sportFilter==="all"||f.sport_id===sportFilter)&&(fixtureStatusFilter==="all"||f.status===fixtureStatusFilter)&&((seasonFilter==="all")||visibleCompetitions.some(c=>c.id===f.competition_id)||visibleTeams.some(t=>t.id===f.team_id)));

 const teamForm=editing?.kind==="team",compForm=editing?.kind==="competition",fixtureForm=editing?.kind==="fixture";
 return <><Header title="Sport operations" back/><main className="page"><div className="page-intro"><span className="eyebrow">ASSIGNED SPORT SCOPE</span><h1>Sport operations</h1><p>Administrators can create, edit and archive teams, competitions and fixtures within their assigned sport scope. Coaches can submit scores for review; submissions do not overwrite published results.</p></div>
 {admin&&<>{editing&&<div className="admin-notice"><ShieldCheck/><div><b>Editing {editing.kind}</b><p>Changes are checked by Supabase row-level security against your active sport assignment.</p></div><button type="button" onClick={resetEditor}>Cancel</button></div>}
 <form className="form-card" onSubmit={e=>{e.preventDefault();saveRecord("team",{sport_id:team.sport_id,name:team.name.trim(),category:team.category.trim()||null,season:team.season.trim()||null},()=>{setEditing(null);setTeam(blankTeam);});}}><h3>{teamForm?"Edit team":"Create team"}</h3><label>Sport<select required value={team.sport_id} onChange={e=>setTeam({...team,sport_id:e.target.value})}><option value="">Choose sport</option>{sportOptions}</select></label><label>Team name<input required maxLength="120" value={team.name} onChange={e=>setTeam({...team,name:e.target.value})}/></label><label>Category<input maxLength="100" value={team.category} onChange={e=>setTeam({...team,category:e.target.value})}/></label><label>Season<input maxLength="40" value={team.season} onChange={e=>setTeam({...team,season:e.target.value})}/></label><button className="btn primary" disabled={busy}>{busy?"Saving…":teamForm?"Save team":"Create team"}</button>{teamForm&&<button type="button" onClick={resetEditor}>Cancel edit</button>}</form>
 <form className="form-card" onSubmit={e=>{e.preventDefault();if(comp.start_date&&comp.end_date&&comp.end_date<comp.start_date){setError("Competition end date cannot be earlier than its start date.");return;}saveRecord("competition",{sport_id:comp.sport_id,name:comp.name.trim(),season:comp.season.trim()||null,start_date:comp.start_date||null,end_date:comp.end_date||null,venue:comp.venue.trim()||null,description:comp.description.trim()||null},()=>{setEditing(null);setComp(blankComp);});}}><h3>{compForm?"Edit competition":"Create competition"}</h3><label>Sport<select required value={comp.sport_id} onChange={e=>setComp({...comp,sport_id:e.target.value})}><option value="">Choose sport</option>{sportOptions}</select></label><label>Name<input required maxLength="160" value={comp.name} onChange={e=>setComp({...comp,name:e.target.value})}/></label><label>Season<input maxLength="40" value={comp.season} onChange={e=>setComp({...comp,season:e.target.value})}/></label><label>Start date<input type="date" value={comp.start_date} onChange={e=>setComp({...comp,start_date:e.target.value})}/></label><label>End date<input type="date" min={comp.start_date||undefined} value={comp.end_date} onChange={e=>setComp({...comp,end_date:e.target.value})}/></label><label>Venue<input maxLength="160" value={comp.venue} onChange={e=>setComp({...comp,venue:e.target.value})}/></label><label>Description<textarea maxLength="2000" value={comp.description} onChange={e=>setComp({...comp,description:e.target.value})}/></label><button className="btn primary" disabled={busy}>{busy?"Saving…":compForm?"Save competition":"Create competition"}</button>{compForm&&<button type="button" onClick={resetEditor}>Cancel edit</button>}</form>
 <form className="form-card" onSubmit={e=>{e.preventDefault();if(!fixture.starts_at){setError("Choose a fixture date and time.");return;}saveRecord("fixture",{sport_id:fixture.sport_id,team_id:fixture.team_id||null,competition_id:fixture.competition_id||null,opponent:fixture.opponent.trim(),venue:fixture.venue.trim()||null,starts_at:new Date(fixture.starts_at).toISOString(),status:fixture.status},()=>{setEditing(null);setFixture(blankFixture);});}}><h3>{fixtureForm?"Edit fixture":"Create fixture"}</h3><label>Sport<select required value={fixture.sport_id} onChange={e=>setFixture({...fixture,sport_id:e.target.value,team_id:"",competition_id:""})}><option value="">Choose sport</option>{sportOptions}</select></label><label>Team<select value={fixture.team_id} onChange={e=>setFixture({...fixture,team_id:e.target.value})}><option value="">No team</option>{teams.filter(t=>t.sport_id===fixture.sport_id&&t.is_active).map(t=><option key={t.id} value={t.id}>{t.name}</option>)}</select></label><label>Competition<select value={fixture.competition_id} onChange={e=>setFixture({...fixture,competition_id:e.target.value})}><option value="">No competition</option>{competitions.filter(c=>c.sport_id===fixture.sport_id&&c.status!=="archived").map(c=><option key={c.id} value={c.id}>{c.name}</option>)}</select></label><label>Opponent<input required maxLength="160" value={fixture.opponent} onChange={e=>setFixture({...fixture,opponent:e.target.value})}/></label><label>Venue<input maxLength="160" value={fixture.venue} onChange={e=>setFixture({...fixture,venue:e.target.value})}/></label><label>Date/time<input type="datetime-local" required value={fixture.starts_at} onChange={e=>setFixture({...fixture,starts_at:e.target.value})}/></label><label>Status<select value={fixture.status} onChange={e=>setFixture({...fixture,status:e.target.value})}>{["scheduled","live","completed","postponed","cancelled"].map(x=><option key={x} value={x}>{x}</option>)}</select></label><button className="btn primary" disabled={busy}>{busy?"Saving…":fixtureForm?"Save fixture":"Publish fixture"}</button>{fixtureForm&&<button type="button" onClick={resetEditor}>Cancel edit</button>}</form></>}
 <form className="form-card" onSubmit={e=>{e.preventDefault();if(!supabase||!user)return;saveRecord("fixture_result_submission",{fixture_id:result.fixture_id,submitted_by:user.id,home_score:Number(result.home_score),away_score:Number(result.away_score),result_summary:result.result_summary||null},()=>setResult({fixture_id:"",home_score:"",away_score:"",result_summary:""}));}}><h3>Submit result for review</h3><label>Fixture<select required value={result.fixture_id} onChange={e=>setResult({...result,fixture_id:e.target.value})}><option value="">Choose fixture</option>{fixtures.filter(f=>f.team_id&&f.status!=="cancelled").map(f=><option key={f.id} value={f.id}>{(f.teams?.name||"CUT")+" vs "+f.opponent+" · "+dateLabel(f.starts_at)}</option>)}</select></label><label>CUT score<input type="number" min="0" required value={result.home_score} onChange={e=>setResult({...result,home_score:e.target.value})}/></label><label>Opponent score<input type="number" min="0" required value={result.away_score} onChange={e=>setResult({...result,away_score:e.target.value})}/></label><label>Notes<textarea maxLength="1000" value={result.result_summary} onChange={e=>setResult({...result,result_summary:e.target.value})}/></label><button className="btn primary" disabled={busy}>Submit result</button></form>
 {error&&<p className="form-error">{error}</p>}
 <Section title="Season & fixture filters"><div className="form-card">
 <label>Sport<select value={sportFilter} onChange={e=>setSportFilter(e.target.value)}><option value="all">All sports</option>{sports.map(s=><option key={s.id} value={s.id}>{s.name}</option>)}</select></label>
 <label>Season<select value={seasonFilter} onChange={e=>setSeasonFilter(e.target.value)}><option value="all">All seasons</option>{seasonOptions.map(s=><option key={s} value={s}>{s}</option>)}</select></label>
 <label>Fixture status<select value={fixtureStatusFilter} onChange={e=>setFixtureStatusFilter(e.target.value)}><option value="all">All statuses</option>{["scheduled","live","completed","postponed","cancelled"].map(s=><option key={s} value={s}>{s}</option>)}</select></label>
 <div className="admin-stats"><div><b>{visibleTeams.length}</b><small>Teams</small></div><div><b>{visibleCompetitions.length}</b><small>Competitions</small></div><div><b>{visibleFixtures.length}</b><small>Fixtures</small></div><div><b>{visibleFixtures.filter(f=>f.status==="completed").length}</b><small>Completed</small></div></div>
 </div></Section>
 <Section title={"Official teams · "+visibleTeams.length}>{visibleTeams.length?visibleTeams.map(t=><div className="sponsor-card admin-sponsor" key={t.id}><div><b>{t.name}</b><small>{sports.find(s=>s.id===t.sport_id)?.name||"Sport"} · {t.category||"Category not set"} · {t.season||"Season not set"} · {t.is_active?"Active":"Archived"}</small></div>{admin&&<><button type="button" disabled={busy||!t.is_active} onClick={()=>editRecord("team",t)}>Edit</button>{t.is_active&&<button type="button" disabled={busy} onClick={()=>archiveRecord("team",t)}>Archive</button>}</>}</div>):<Empty title="No teams yet" body="No official team records have been entered."/>}</Section>
 <Section title={"Competitions · "+visibleCompetitions.length}>{visibleCompetitions.length?visibleCompetitions.map(c=><div className="sponsor-card admin-sponsor" key={c.id}><div><b>{c.name}</b><small>{sports.find(s=>s.id===c.sport_id)?.name||"Sport"} · {c.season||c.status} · {c.status}</small></div>{admin&&<><button type="button" disabled={busy||c.status==="archived"} onClick={()=>editRecord("competition",c)}>Edit</button>{c.status!=="archived"&&<button type="button" disabled={busy} onClick={()=>archiveRecord("competition",c)}>Archive</button>}</>}</div>):<Empty title="No competitions yet" body="No official competitions have been entered."/>}</Section>
 <Section title={"Fixtures · "+visibleFixtures.length}>{visibleFixtures.length?visibleFixtures.map(f=><div className="sponsor-card admin-sponsor" key={f.id}><div><b>{(f.teams?.name||"CUT")+" vs "+f.opponent}</b><small>{dateLabel(f.starts_at)} · {f.status}{f.home_score!==null&&f.away_score!==null?" · "+f.home_score+"–"+f.away_score:""}</small></div>{admin&&<><button type="button" disabled={busy||f.status==="cancelled"} onClick={()=>editRecord("fixture",f)}>Edit</button>{f.status!=="cancelled"&&<button type="button" disabled={busy} onClick={()=>archiveRecord("fixture",f)}>Cancel fixture</button>}</>}</div>):<Empty title="No fixtures yet" body="No fixtures have been entered."/>}</Section>
 <Section title="Submitted results">{submissions.length?submissions.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.fixtures?.teams?.name||"CUT")+" vs "+x.fixtures?.opponent+" · "+x.home_score+"–"+x.away_score}</b><small>{x.review_status}</small></div>{admin&&x.review_status==="pending"&&<><button disabled={busy} onClick={()=>review(x,"accepted")}>Accept</button><button disabled={busy} onClick={()=>review(x,"rejected")}>Reject</button></>}</div>):<Empty title="No submissions" body="Coach result submissions will appear here."/>}</Section>
 <p className="muted">Archiving is non-destructive: teams are deactivated, competitions are marked archived, and fixtures are cancelled. Published results remain in the fixture record. Coaches can submit results only; administrators review and publish them through the atomic database workflow.</p>
 </main></>;
}

function AdminApprovals({roles,user}) {
 const allowed=roles.some(r=>["sport_admin","super_admin"].includes(r));
 const [items,setItems]=useState([]),[stats,setStats]=useState([]),[achievements,setAchievements]=useState([]),[media,setMedia]=useState([]),[history,setHistory]=useState([]);
 const [error,setError]=useState(""),[loading,setLoading]=useState(false),[busyKey,setBusyKey]=useState("");
 const [notes,setNotes]=useState({});
 async function load(){
  if(!supabase||!allowed)return;
  setLoading(true);setError("");
  const [a,s,g,m]=await Promise.all([
   supabase.from("athletes").select("id,full_name,preferred_name,approval_status,review_note,sports(name),teams(name)").eq("approval_status","pending").order("created_at",{ascending:false}),
   supabase.from("athlete_statistics").select("id,athlete_id,season,period_label,metrics,approval_status,review_note,athletes(full_name)").eq("approval_status","pending").order("created_at",{ascending:false}),
   supabase.from("athlete_achievements").select("id,athlete_id,title,description,is_verified,review_status,review_note,athletes(full_name)").eq("review_status","pending").order("created_at",{ascending:false}),
   supabase.from("athlete_media").select("id,athlete_id,title,media_type,visibility,approved_at,external_url,storage_path,review_status,review_note,athletes(full_name)").eq("review_status","pending").order("created_at",{ascending:false})
  ]);
  const fail=[a,s,g,m].find(x=>x.error);
  if(fail)setError(fail.error.message);
  else{
   setItems(a.data||[]);setStats(s.data||[]);setAchievements(g.data||[]);setMedia(m.data||[]);
   const pendingIds=[...(a.data||[]),...(s.data||[]),...(g.data||[]),...(m.data||[])].map(x=>x.id);
   if(pendingIds.length){
    const h=await supabase.from("athlete_review_history").select("id,record_type,record_id,from_status,to_status,previous_note,review_note,changed_at").in("record_id",pendingIds).order("changed_at",{ascending:false}).limit(100);
    if(h.error)setError(h.error.message);else setHistory(h.data||[]);
   }else setHistory([]);
  }
  setLoading(false);
 }
 useEffect(()=>{load()},[allowed]);
 async function review(kind,item,decision){
  if(!allowed||!supabase||!user?.id)return;
  const key=kind+":"+item.id;
  const note=(notes[key]||"").trim();
  if(decision==="rejected"&&!note){setError("Add a short reason before rejecting this submission.");return;}
  setBusyKey(key);setError("");
  const now=new Date().toISOString();
  const audit={review_note:note||null,reviewed_by:user.id,reviewed_at:now};
  let table="",payload={...audit};
  if(kind==="athlete"){
   table="athletes";
   payload={...payload,approval_status:decision,verified_by:decision==="approved"?user.id:null,verified_at:decision==="approved"?now:null};
  }else if(kind==="statistics"){
   table="athlete_statistics";
   payload={...payload,approval_status:decision,approved_by:decision==="approved"?user.id:null,approved_at:decision==="approved"?now:null};
  }else if(kind==="achievement"){
   table="athlete_achievements";
   payload={...payload,review_status:decision,is_verified:decision==="approved",verified_by:decision==="approved"?user.id:null,verified_at:decision==="approved"?now:null};
  }else if(kind==="media"){
   table="athlete_media";
   payload={...payload,review_status:decision,approved_by:decision==="approved"?user.id:null,approved_at:decision==="approved"?now:null,visibility:decision==="rejected"?"private":item.visibility};
  }
  const result=await supabase.from(table).update(payload).eq("id",item.id).select("id").maybeSingle();
  if(result.error)setError(result.error.message);
  else if(!result.data)setError("No review action was saved. Your sport assignment may not allow this record.");
  else{setNotes(current=>{const next={...current};delete next[key];return next;});await load();}
  setBusyKey("");
 }
 function reviewHistory(kind,item){
  const rows=history.filter(h=>h.record_type===kind&&h.record_id===item.id);
  if(!rows.length)return null;
  return <div className="review-history"><b>Previous review activity</b>{rows.slice(0,3).map(h=><div key={h.id}><small>{h.from_status||"New"} → {h.to_status} · {dateLabel(h.changed_at)}</small>{h.previous_note&&<p>Previous feedback: {h.previous_note}</p>}{h.review_note&&<p>Reviewer note: {h.review_note}</p>}</div>)}</div>;
 }
 function reviewNote(kind,item){
  const key=kind+":"+item.id;
  return <>{reviewHistory(kind,item)}<label className="review-note-field">Rejection reason<textarea rows="2" placeholder="Explain what needs to be corrected before resubmission" value={notes[key]||""} onChange={e=>setNotes(current=>({...current,[key]:e.target.value}))}/></label></>;
 }
 function actions(kind,item){
  const key=kind+":"+item.id,working=busyKey===key;
  return <div className="review-actions"><button className="btn primary" disabled={Boolean(busyKey)} onClick={()=>review(kind,item,"approved")}>{working?"Saving…":"Approve"}</button><button className="btn secondary" disabled={Boolean(busyKey)} onClick={()=>review(kind,item,"rejected")}>{working?"Saving…":"Reject"}</button></div>;
 }
 if(!allowed)return <><Header title="Admin access required" back/><main className="page"><Empty title="Restricted area" body="Only sport administrators and super administrators can approve records."/></main></>;
 const total=items.length+stats.length+achievements.length+media.length;
 return <><Header title="Athlete approvals" back/><main className="page">
  <div className="page-intro"><span className="eyebrow">VERIFICATION QUEUE</span><h1>Athlete approvals</h1><p>Review athlete profiles, performance records, achievements and media. Rejections require a reason, and review actions are recorded against the signed-in administrator.</p></div>
  <div className="admin-notice"><ShieldCheck size={18}/><div><b>{loading?"Refreshing review queue…":total+" submissions awaiting review"}</b><p>Only pending submissions are shown. Rejected media is kept private until it is reviewed and approved again.</p></div><button className="btn secondary" disabled={loading||Boolean(busyKey)} onClick={load}>Refresh</button></div>
  {error&&<p className="form-error" role="alert">{error}</p>}
  {loading?<div className="loading-state">Loading review queue…</div>:<>
   <Section title={"Athlete profiles · "+items.length}>{items.length?items.map(a=><div className="sponsor-card admin-sponsor" key={a.id}><div><b>{a.preferred_name||a.full_name}</b><small>{a.sports?.name||"Sport"} · {a.teams?.name||"No team"} · Pending profile verification</small>{reviewNote("athlete",a)}{actions("athlete",a)}</div></div>):<Empty title="No athlete profiles awaiting approval" body="New registrations will appear here."/>}</Section>
   <Section title={"Performance statistics · "+stats.length}>{stats.length?stats.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.athletes?.full_name||"Athlete")+" · "+(x.season||x.period_label||"Statistics")}</b><small>{JSON.stringify(x.metrics)}</small>{reviewNote("statistics",x)}{actions("statistics",x)}</div></div>):<Empty title="No statistics awaiting approval" body="Pending statistics will appear here."/>}</Section>
   <Section title={"Achievements · "+achievements.length}>{achievements.length?achievements.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.athletes?.full_name||"Athlete")+" · "+x.title}</b><small>{x.description||"Achievement submitted for verification"}</small>{reviewNote("achievement",x)}{actions("achievement",x)}</div></div>):<Empty title="No achievements awaiting approval" body="Pending achievements will appear here."/>}</Section>
   <Section title={"Athlete media · "+media.length}>{media.length?media.map(x=><div className="sponsor-card admin-sponsor" key={x.id}><div><b>{(x.athletes?.full_name||"Athlete")+" · "+(x.title||x.media_type)}</b><small>{x.media_type} · Submitted visibility: {x.visibility}</small>{x.external_url&&<a href={x.external_url} target="_blank" rel="noreferrer">Open submitted media</a>}{reviewNote("media",x)}{actions("media",x)}</div></div>):<Empty title="No media awaiting approval" body="Pending media will appear here."/>}</Section>
  </>}
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
 const [sportId,setSportId]=useState(""),[season,setSeason]=useState(""),[athleteId,setAthleteId]=useState(""),[competitionId,setCompetitionId]=useState(""),[metricKey,setMetricKey]=useState("");
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
 const filtered=records.filter(r=>(!sportId||r.athletes?.sport_id===sportId)&&(!season||r.season===season)&&(!athleteId||r.athlete_id===athleteId)&&(!competitionId||r.competition_id===competitionId));
 const sportOptions=[...new Map(records.filter(r=>r.athletes?.sport_id).map(r=>[r.athletes.sport_id,{id:r.athletes.sport_id,name:r.athletes.sports?.name||"Sport"}])).values()].sort((a,b)=>a.name.localeCompare(b.name));
 const seasonOptions=[...new Set(records.map(r=>r.season).filter(Boolean))].sort().reverse();
 const athleteOptions=[...new Map(records.filter(r=>r.athletes).map(r=>[r.athlete_id,{id:r.athlete_id,name:r.athletes.preferred_name||r.athletes.full_name}])).values()].sort((a,b)=>a.name.localeCompare(b.name));
 const competitionOptions=[...new Map(records.filter(r=>r.competition_id).map(r=>[r.competition_id,{id:r.competition_id,name:r.competitions?.name||"Competition"}])).values()].sort((a,b)=>a.name.localeCompare(b.name));
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
   <label>Competition<select value={competitionId} onChange={e=>setCompetitionId(e.target.value)}><option value="">All competitions</option>{competitionOptions.map(x=><option key={x.id} value={x.id}>{x.name}</option>)}</select></label>
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