# UI Flow Proposals

Three alternative designs for the Sittilingi SHG Portal. The current design has a marketing hero banner and a busy side-panel layout that competes for attention. All three proposals below remove the hero and focus on a field-worker-first experience.

---

## Option A — Full-screen steps + home screen (Recommended)

Each step fills the screen. No side panels. Warnings appear inline at the form bottom. Feels like a native tablet app.

### Screen 1: Home

```
┌─────────────────────────────────────────────────┐
│ SOFA SHG Portal                  Priya  Sign out │
├─────────────────────────────────────────────────┤
│                                                 │
│  Good morning, Priya                            │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────┐     │
│  │   + New Entry    │  │   View Reports   │     │
│  └──────────────────┘  └──────────────────┘     │
│                                                 │
│  Pending drafts                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Malar Kalvi  ·  April 2026  ·  Draft  →  │  │
│  │  Thozhi SHG   ·  March 2026  ·  Draft  →  │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  Recent entries                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Malar Kalvi  ·  March 2026  ·  Saved  →  │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Screen 2: New Entry — Step 1 of 3 (Group + Month)

```
┌─────────────────────────────────────────────────┐
│  ← New Entry                             1 of 3 │
├─────────────────────────────────────────────────┤
│                                                 │
│  Which group?                                   │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  ○  Malar Kalvi  ·  Sittilingi            │  │
│  │  ●  Thozhi SHG   ·  Kottai               │  │
│  │  ○  Pon Malar    ·  Vadakadu             │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  Which month?                                   │
│                                                 │
│  ┌───────────────────┐                          │
│  │   May 2026    ▼   │                          │
│  └───────────────────┘                          │
│                                                 │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │               Continue →                  │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Screen 3: New Entry — Step 2 of 3 (Mode selection)

```
┌─────────────────────────────────────────────────┐
│  ← Back                                  2 of 3 │
├─────────────────────────────────────────────────┤
│  Thozhi SHG  ·  May 2026                        │
├─────────────────────────────────────────────────┤
│                                                 │
│  How will you enter the data?                   │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Upload register images                   │  │
│  │  AI reads the register, you verify        │  │
│  │  the numbers before saving.               │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Enter manually                           │  │
│  │  Type the monthly totals directly from    │  │
│  │  your register. No images needed.         │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Screen 4a: New Entry — Image upload (only if prefill chosen)

```
┌─────────────────────────────────────────────────┐
│  ← Back                                  2b of 3│
├─────────────────────────────────────────────────┤
│  Thozhi SHG  ·  May 2026                        │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│       +  Tap to add register images            │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│  Tip: add the date page + ledger page           │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  1  register_page_1.jpg   ·  340 KB       │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ┌─────────────────┐  ┌──────────────────────┐  │
│  │  ← Back         │  │  Continue to form →  │  │
│  └─────────────────┘  └──────────────────────┘  │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Screen 5: New Entry — Step 3 of 3 (Form + inline warnings)

```
┌─────────────────────────────────────────────────┐
│  ← Back                              ⚠ 1 warning│
├─────────────────────────────────────────────────┤
│  Thozhi SHG  ·  May 2026  ·  Image prefill      │
├─────────────────────────────────────────────────┤
│                                                 │
│  Savings collected         [    2,400         ] │
│  Internal loan principal   [                  ] │
│  Internal loan interest    [                  ] │
│  To bank                   [    3,100         ] │
│  From bank                 [                  ] │
│  SOFA loan disbursed       [                  ] │
│  SOFA loan repayment       [                  ] │
│  SOFA loan interest        [                  ] │
│  Notes                     [                  ] │
│                                                 │
├─────────────────────────────────────────────────┤
│  ⚠  To bank exceeds visible collections.        │
│     Check the figures before saving.            │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────┐  ┌───────────────────────┐│
│  │   Save draft     │  │   Save entry →        ││
│  └──────────────────┘  └───────────────────────┘│
└─────────────────────────────────────────────────┘
```

---

## Option B — Left sidebar + content pane

Fixed sidebar shows navigation. Content area on the right updates. Works well in landscape on a tablet. Entry list and entry form are both visible as separate panes.

### Screen 1: Entries list

```
┌──────────────────────────────────────────────────────┐
│ ┌────────────┐ ┌────────────────────────────────────┐ │
│ │ SHG        │ │  Entries                           │ │
│ │ Portal     │ ├────────────────────────────────────┤ │
│ │            │ │  + New entry                       │ │
│ │ ──────     │ │                                    │ │
│ │ Entries ●  │ │  Drafts                            │ │
│ │            │ │  ┌────────────────────────────┐    │ │
│ │ Groups     │ │  │ Malar Kalvi  Apr 2026  →   │    │ │
│ │            │ │  │ Thozhi SHG  Mar 2026   →   │    │ │
│ │ Reports    │ │  └────────────────────────────┘    │ │
│ │            │ │                                    │ │
│ │ ──────     │ │  Saved                             │ │
│ │ Priya      │ │  ┌────────────────────────────┐    │ │
│ │ Sign out   │ │  │ Malar Kalvi  Mar 2026  →   │    │ │
│ └────────────┘ │  └────────────────────────────┘    │ │
│                └────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

### Screen 2: Entry form (right pane replaces list)

```
┌──────────────────────────────────────────────────────┐
│ ┌────────────┐ ┌────────────────────────────────────┐ │
│ │ Entries ●  │ │  ← Entries                         │ │
│ │ Groups     │ │  Malar Kalvi  ·  May 2026          │ │
│ │ Reports    │ ├────────────────────────────────────┤ │
│ │            │ │ Savings collected    [    2,400  ] │ │
│ │ Priya      │ │ Int. loan principal  [           ] │ │
│ └────────────┘ │ Int. loan interest   [           ] │ │
│                │ To bank              [    3,100  ] │ │
│                │ From bank            [           ] │ │
│                │ SOFA disbursed       [           ] │ │
│                │ SOFA repayment       [           ] │ │
│                │ SOFA interest        [           ] │ │
│                │ Notes                [           ] │ │
│                ├────────────────────────────────────┤ │
│                │ ⚠  To bank exceeds collections     │ │
│                ├────────────────────────────────────┤ │
│                │ [Save draft]    [Save entry →]     │ │
│                └────────────────────────────────────┘ │
└──────────────────────────────────────────────────────┘
```

---

## Option C — Bottom tab nav (single-page form, no wizard)

Bottom tabs: Home · New Entry · Reports. The New Entry tab is one scrollable page — group, month, mode, upload, and all fields on one screen. No steps, no navigation between sub-screens.

### Screen 1: Home tab

```
┌─────────────────────────────────────────────────┐
│ SOFA SHG Portal                                 │
├─────────────────────────────────────────────────┤
│                                                 │
│  Pending (2)                                    │
│  ┌───────────────────────────────────────────┐  │
│  │  Malar Kalvi  ·  April 2026  ·  Draft  →  │  │
│  │  Thozhi SHG   ·  March 2026 ·  Draft  →  │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  This month across all groups                   │
│  ┌──────────────────┐  ┌──────────────────┐     │
│  │  Savings         │  │  Warnings        │     │
│  │  ₹1,24,000       │  │       3          │     │
│  └──────────────────┘  └──────────────────┘     │
│                                                 │
├─────────────────────────────────────────────────┤
│   🏠 Home    │   + New Entry   │   📊 Reports   │
└─────────────────────────────────────────────────┘
```

### Screen 2: New Entry tab (single scrollable form)

```
┌─────────────────────────────────────────────────┐
│ New Entry                                       │
├─────────────────────────────────────────────────┤
│                                                 │
│  Group   [ Thozhi SHG · Kottai             ▼ ] │
│  Month   [ May 2026                         ▼ ] │
│  Mode    [ ● Image prefill   ○ Manual         ] │
│                                                 │
│  ┌ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┐  │
│       +  Tap to add register images            │
│  └ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┘  │
│                                                 │
│  Savings collected         [                 ] │
│  Internal loan principal   [                 ] │
│  Internal loan interest    [                 ] │
│  To bank                   [                 ] │
│  From bank                 [                 ] │
│  SOFA loan disbursed       [                 ] │
│  SOFA loan repayment       [                 ] │
│  SOFA loan interest        [                 ] │
│  Notes                     [                 ] │
│                                                 │
├─────────────────────────────────────────────────┤
│  [ Save draft ]        [ Save entry →         ]│
├─────────────────────────────────────────────────┤
│   🏠 Home    │   + New Entry   │   📊 Reports   │
└─────────────────────────────────────────────────┘
```

---

## Comparison

| | Option A | Option B | Option C |
|---|---|---|---|
| Navigation | Top bar + back buttons | Left sidebar | Bottom tabs |
| Entry flow | 3 separate screens | Single right pane | Single scrollable form |
| Best for | Portrait tablet | Landscape tablet | Either orientation |
| Complexity to build | Medium | Medium | Low |
| Wizard steps | Yes (1→2→3) | No | No |

All three options share the same changes vs. the current design:
- Hero banner removed
- Side warnings panel removed — warnings appear inline below the form fields
- Home screen with pending drafts added
- Dashboard stats simplified to 2–3 numbers
