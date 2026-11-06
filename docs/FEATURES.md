# CUT Sport feature map

| App area | Route | Current behavior |
|---|---|---|
| Home | `/` | Active sport codes, fixtures, active products, published articles, published events and active sponsors |
| Shop | `/shop` | Active product catalogue |
| Product detail | `/shop/:slug` | Product description and add-to-cart action |
| Cart | `/cart` | Browser-local cart with quantity controls and subtotal |
| Checkout | `/checkout` | Readiness notice only; no payment or order creation |
| Sport updates | `/sport` | Sport-code directory and fixtures/results |
| Sport hubs | `/sport/:slug` | Public competition directory, active team directory, approved public athlete cards, fixtures and published stories |
| News | `/news`, `/news/:slug` | Published article feed and detail |
| Sponsors | `/sponsors` | Active sponsor directory and partner links |
| Profile | `/profile` | Supabase email/password sign-in, sign-up and profile update |
| Notifications | `/notifications` | Signed-in user's notification list |
| My tickets | `/tickets` | Signed-in user's ticket records; no client-generated QR |
| Orders | `/orders` | Signed-in user's order history |
| Sponsor administration | `/admin` | Role-gated sponsor create, edit and archive; database RLS enforces access |
| Athlete administration | `/admin/athletes` | Assigned staff can register/edit athlete profile details; new profiles start pending |

## Important boundaries
- Public athlete cards query only approved, public profiles. RLS is the final access control.
- Athlete administration is limited by the existing `private.can_manage_athlete(sport_id, team_id)` policy. A client-side role check is only a navigation/UI aid.
- Athlete verification/approval, statistics, achievements and media workflows are not yet implemented.
- The cart is local to the browser. It is not a reserved stock quantity and does not create an order.
- Payment, order creation, ticket issuance/redemption and institutional discounts require trusted server-side integrations and approved business rules.
- Empty states are intentional where no verified CUT Sport records have been published.
