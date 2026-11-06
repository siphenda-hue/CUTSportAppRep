# CUT Sport feature map

| Mockup screen | Frontend route | Data source / behavior |
|---|---|---|
| Home | `/` | Active sports, fixtures, products, published articles, events and sponsors |
| Shop | `/shop` | Active product catalogue and category filters |
| Sport Updates | `/sport` | Fixture/result list with sport filter |
| Product Detail | `/shop/:slug` | Product description, size/colour options, add to bag |
| Cart | `/cart` | Persistent local cart and quantity controls |
| Checkout | `/checkout` | Delivery choice and order summary; payment intentionally gated |
| Profile | `/profile` | Supabase email/password auth, profile update, role display |
| Sponsors | `/sponsors` | Active sponsor directory and external websites |
| Articles & News | `/news`, `/news/:slug` | Published article feed and detail |
| Order Status | `/orders` | Signed-in user's order history |
| Launch Screen | App shell | Branded app header/home experience; native splash is deployment-specific |
| Notifications | `/notifications` | Signed-in user's notifications and mark-as-read |
| My Tickets | `/tickets` | Signed-in user's event tickets; no client-generated QR |
| Sport Hubs | `/sport/:slug` | Sport overview, fixtures, stories and honest empty states for unpopulated squads/media |