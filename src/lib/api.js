import { supabase, isSupabaseConfigured } from './supabase';

const empty = (data = []) => ({ data, error: null });
async function query(table, select = '*', options = {}) {
  if (!isSupabaseConfigured) return empty([]);
  let q = supabase.from(table).select(select);
  if (options.eq) Object.entries(options.eq).forEach(([k, v]) => { q = q.eq(k, v); });
  if (options.order) q = q.order(options.order, { ascending: options.ascending ?? true });
  if (options.limit) q = q.limit(options.limit);
  const { data, error } = await q;
  if (error) console.warn(`CUT Sport ${table}:`, error.message);
  return { data: data || [], error };
}
export const api = {
  sports: () => query('sports', 'id,name,slug,description,image_url,display_order', { eq: { is_active: true }, order: 'display_order' }),
  teams: (sportId) => query('teams', 'id,name,category,season,coach_name,image_url,sport_id', { eq: { is_active: true, ...(sportId ? { sport_id: sportId } : {}) }, order: 'name' }),
  competitions: (sportId) => query('competitions', 'id,sport_id,name,season,start_date,end_date,venue,description,status,competition_standings(id,team_name,team_logo_url,group_name,position,played,won,drawn,lost,scored,conceded,points_difference,bonus_points,points,source_url,source_checked_at),competition_matches(id,source_match_id,starts_at,home_team,away_team,home_score,away_score,match_status,match_round,group_name,venue,source_url),competition_player_statistics(id,player_name,team_name,squad_number,field_goals,penalty_corner_goals,penalty_stroke_goals,total_goals,source_url)', { eq: sportId ? { sport_id: sportId } : {}, order: 'start_date', ascending: true, limit: 200 }),
  athletes: (sportId) => query('athletes', 'id,full_name,preferred_name,position,squad_number,bio,photo_url,is_featured,sport_id,team_id,sports(name),teams(name)', { eq: { approval_status: 'approved', profile_visibility: 'public', ...(sportId ? { sport_id: sportId } : {}) }, order: 'full_name', limit: 100 }),
  fixtures: (sportId) => query('fixtures', 'id,opponent,venue,starts_at,status,home_score,away_score,result_summary,sport_id,team_id,competition_id,teams(name),sports(name)', { eq: sportId ? { sport_id: sportId } : {}, order: 'starts_at', ascending: true, limit: 200 }),
  articles: () => query('articles', 'id,title,slug,excerpt,body,cover_image_url,published_at,sport_id,sports(name)', { eq: { status: 'published' }, order: 'published_at', ascending: false, limit: 12 }),
  products: () => query('products', 'id,name,slug,description,category,price_cents,image_url,stock_quantity', { eq: { is_active: true }, order: 'created_at', ascending: false, limit: 30 }),
  events: () => query('events', 'id,title,description,venue,starts_at,ends_at,ticketed,published,sport_id', { eq: { published: true, archived_at: null }, order: 'starts_at', limit: 100 }),
  sponsors: () => query('sponsors', 'id,name,slug,description,logo_url,website_url,sponsorship_tier,display_order', { eq: { is_active: true }, order: 'display_order' }),
  profile: async (userId) => {
    if (!supabase) return { data: null, error: null };
    return supabase.from('profiles').select('*').eq('id', userId).maybeSingle();
  },
  roles: async (userId) => {
    if (!supabase) return empty([]);
    return supabase.from('user_roles').select('role').eq('user_id', userId);
  },
  notifications: async (userId) => {
    if (!supabase) return empty([]);
    return supabase.from('notifications').select('id,title,body,read_at,created_at,category,action_url,related_record_type,related_record_id').eq('user_id', userId).order('created_at', { ascending: false }).limit(30);
  },
  messages: async (userId) => {
    if (!supabase || !userId) return empty([]);
    return supabase.from('athlete_messages').select('id,athlete_id,sender_id,recipient_id,parent_message_id,subject,body,message_type,read_at,created_at').or('sender_id.eq.' + userId + ',recipient_id.eq.' + userId).order('created_at', { ascending: false }).limit(100);
  },
  tickets: async () => {
    if (!supabase) return empty([]);
    const { data, error } = await supabase.functions.invoke('my-tickets', { body: {} });
    return { data: data?.tickets || [], error };
  },
  ticketTypes: () => query('event_ticket_types', 'id,event_id,name,description,price_cents,quantity_available,max_per_order,events!inner(published,ticketed)', { eq: { is_active: true, 'events.published': true, 'events.ticketed': true }, order: 'price_cents', ascending: true, limit: 100 }),
  orders: async (userId) => {
    if (!supabase) return empty([]);
    return supabase.from('orders').select('id,order_number,status,payment_status,total_cents,currency,created_at').eq('user_id', userId).order('created_at', { ascending: false });
  }
};
export const money = (cents = 0) => new Intl.NumberFormat('en-ZA', { style: 'currency', currency: 'ZAR', maximumFractionDigits: 2 }).format(Number(cents) / 100);
export const dateLabel = (value) => value ? new Intl.DateTimeFormat('en-ZA', { day: 'numeric', month: 'short', year: 'numeric' }).format(new Date(value)) : 'Date to be confirmed';