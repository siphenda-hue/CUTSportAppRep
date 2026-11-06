# CUT Sport feature map

| App area | Route | Current behavior |
|---|---|---|
| Home | `/` | Active sport codes, fixtures, active products, published articles, published events and active sponsors |
| Shop | `/shop` | Active product catalogue |
| Product detail | `/shop/:slug` | Product description and add-to-cart action |
| Cart | `/cart` | Browser-local cart with quantity controls and subtotal |
| Checkout | `/checkout` | Authenticated Yoco hosted checkout; server recalculates prices and reserves stock |
| Sport updates | `/sport` | Sport-code directory and fixtures/results |
| Sport hubs | `/sport/:slug` | Public competition directory, active team directory, approved public athlete cards, fixtures and published stories |
| News | `/news`, `/news/:slug` | Published article feed and detail |
| Sponsors | `/sponsors` | Active sponsor directory and partner links |
| Profile | `/profile` | Supabase email/password sign-in, sign-up and profile update |
| Notifications | `/notifications` | Signed-in user's notification list |
| My tickets | `/tickets` | Signed ticket codes returned by an authenticated Edge Function only to the ticket owner |
| Orders | `/orders` | Signed-in user's order history including payment status |
| Sponsor administration | `/admin/sponsors` | Role-gated sponsor create, edit and archive; database RLS enforces access |
| Athlete administration | `/admin/athletes` | Assigned staff can register/edit athlete profile details; new profiles start pending |
| Admin dashboard | `/admin` | Role-aware management landing page |
| Sport operations | `/admin/operations` | Scoped team/competition/fixture creation; coach result submissions; admin review and official score publication |
| Athlete approvals | `/admin/approvals` | Sport admins approve athlete profiles, statistics, achievements and media |
| News & events administration | `/admin/editorial` | Scoped article and event publishing; ticketed events can create a General Admission ticket type |
| Event ticket purchase | `/events/:id` | Ticket-type selection and authenticated Yoco checkout |
| Staff ticket gate | `/admin/ticket-gate` | Staff-authorised one-time ticket redemption |
| Payment return | `/payment/:result` | Displays order status; does not trust the redirect as payment proof |

## Important boundaries
- Public athlete cards query only approved, public profiles. RLS is the final access control.
- Athlete administration is limited by the existing `private.can_manage_athlete(sport_id, team_id)` policy. A client-side role check is only a navigation/UI aid.
- Athlete profile, statistics, achievement and media approval are available; database triggers reserve verification fields for authorised approvers. Coaches/team managers cannot change approval fields because database triggers enforce approver authority.
- The cart is local to the browser. It is not a reserved stock quantity and does not create an order.
- Yoco checkout and ticket issuance/redemption are implemented server-side; they remain gated on merchant keys, webhook registration and sandbox verification. Student/staff discounts and refunds need approved business rules.
- Empty states are intentional where no verified CUT Sport records have been published.
