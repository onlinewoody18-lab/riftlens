# RiftLens

A League of Legends companion you can run on your own PC as a desktop app, or put online as a website.

- **Player lookup**: rank, last 15 games, KDA, CS/min, champion and role breakdown.
- **Live game**: ranks and mastery for all 10 players, plus a 0-100 matchup score against each enemy. Your lane opponent is highlighted and every score has a breakdown.
- **Tier list**: win, pick and ban rates by role.
- **Champion builds**: every build players went, ranked by win rate, KDA, games played or damage. Also rune pages, boots, summoner spells and best/worst matchups.
- **Build planner**: pick a champion, role and keystone. RiftLens builds the rune page and item path with the best record, and you can lock or swap any item to re-optimise around it. Includes side-by-side comparisons of every keystone, rune row, secondary tree and stat shard.
- **Build maker**: make your own build. Pick any items (search or filter by stat), runes, stat shards and summoner spells, then:
  - see the build's stats at any level (1-18) and its gold cost
  - compare it stat by stat with a saved build, the best-record build or the champion with no items
  - check how your items, keystone, runes and spells have done in collected games
  - save it, or start from the best-record build or any ranked build and edit from there
- **Every rank**: games are collected from Iron to Challenger. The rank menu at the top switches the tier list, builds, planner and build maker between all ranks, Iron to Silver, Gold to Platinum, Emerald to Diamond, and Master and above.

## Run it on your PC (Windows)

1. Install **Node.js LTS** from https://nodejs.org (version 18 or newer).
2. Unzip this folder anywhere, for example your Documents folder.
3. Double-click **Create desktop shortcut.bat** once. It puts a RiftLens icon on your desktop and in the Start menu.
4. Open RiftLens from that icon (or double-click **Start RiftLens.bat**). It opens in its own app window. A small console window stays minimised in the taskbar; closing it stops RiftLens.
5. Go to https://developer.riotgames.com, log in with your League account, and copy your API key (it starts with `RGAPI-`).
6. In RiftLens, open **Settings**, paste the key, choose your region, add your Riot ID (Name#TAG) and save.

There's nothing to install with npm; the app has no dependencies. Chrome and Edge can also install it as an app: use the **Install app** button in the top bar.

A **Development key** expires every 24 hours; RiftLens shows a banner when it does, and you paste a fresh one in Settings. A **Personal key** (register a Personal API Key product on the developer portal) doesn't expire.

## Put it online

The same code runs as a website in "online mode". In online mode:

- the Riot key and region come from environment variables and are never written to disk or sent to browsers
- Settings is locked; each visitor's Riot ID, region and saved builds are kept in their own browser
- lookups are limited per visitor (40 per 10 minutes by default), so one person can't use up the shared key
- the server only answers to your own domain name(s)

**Before you make it public you need a Riot Production API key.** Riot doesn't allow a public site on a development or personal key. Apply at developer.riotgames.com with **Register Product → Production API Key**, give your site's address as the product URL, and use an App Note to ask about the matchup score (see below). The site needs to be up and working when you apply, so deploy it privately first (for example, don't share the link yet) and switch to the production key once approved.

### Deploying on Render (simplest)

1. Put this folder in a GitHub repository. `data/` is git-ignored, so no key or collected games go up.
2. On render.com choose **New → Blueprint** and pick the repository. It reads `render.yaml`.
3. When asked, set `RIOT_API_KEY` to your key and `PUBLIC_HOSTS` to your site's hostname (for example `riftlens.onrender.com`, or your own domain).
4. Render builds the Dockerfile and gives you the address. Collected games are kept on a 2 GB disk (persistent disks need one of Render's paid plans).

### Deploying anywhere else

Any host that runs Docker works (Railway, Fly.io, a VPS). Build the `Dockerfile` and set:

| Variable | Required | What it does |
|---|---|---|
| `RIOT_API_KEY` | yes | Your production key |
| `PUBLIC_HOSTS` | yes | Your hostname(s), comma separated |
| `RIOT_PLATFORM` | no | Region to collect games from (`euw1` default; `na1`, `kr`, `eun1`...) |
| `TRUST_PROXY` | behind a host's proxy | Set to `1` so per-visitor limits see the real visitor address |
| `LOOKUPS_PER_10MIN` | no | Per-visitor lookup limit (default 40) |
| `RIFTLENS_CRAWLER` | no | `0` turns off game collection |

Mount a persistent volume at `/data` so collected games survive restarts. Put the site behind HTTPS (Render, Railway and Fly do this for you).

## How the data works

- Player lookups and live games ask Riot directly. Each lookup uses about 20 requests.
- The tier list, builds, planner and build maker come from ranked solo games collected in the background. RiftLens takes turns between Iron-Silver, Gold-Platinum, Emerald-Diamond and Master+ players so every rank fills in evenly. Each game is filed under the rank of the player it was found through; matchmaking keeps the other nine close to that.
- A personal key allows about 100 requests every 2 minutes, roughly 2,500 games an hour while RiftLens is open (about 600 per rank bracket). Popular champions fill in within 15-30 minutes; give it a few hours for a solid tier list at every rank. Collection always yields to your own searches.
- Everything is saved in the `data` folder, so collected games build up across sessions. Games collected by older versions (Challenger and Grandmaster only) are kept as "Master and above".
- Champion select isn't visible to Riot's API, so the live game only appears once the game has loaded.

## How the matchup score works

Four factors, each scored from "they're far ahead" to "you're far ahead", combined into 0-100 (50 = even):

| Factor | Weight | Source |
|---|---|---|
| Champion matchup | 30% (15% under 15 games) | Win rate of your champion vs theirs in that lane, from collected games |
| Rank | 30% | Your solo queue rank vs theirs |
| Champion experience | 20% | Your mastery on your pick vs theirs on their pick |
| Season form | 20% | Your ranked win rate vs theirs |

Missing factors (unranked players, matchups with no data yet) are left out and the rest re-weighted. It's an estimate, not a prediction.

## How the build planner and rankings work

- **Highest win rate** ranks options by win rate, pulling small samples toward the average so a 3-game 100% item doesn't beat a 200-game 54% one. **Most played** ranks by popularity instead.
- Items are chosen one slot at a time. Each slot looks only at games that already contain the items picked before it, so the build is a real path players took, not five individually strong items.
- **All builds, ranked** groups games by their first three completed items (in any order) and shows the order, boots, keystone and spells players used most with that set. Builds with too few games to mean anything are hidden.

## How the build maker's stats work

Stats are the champion's base stats at the chosen level (using Riot's per-level growth), plus the stats listed on each item, plus stat shards. Adaptive shards count as AD or AP, whichever your items give more of. Item passives, rune effects, abilities and percentage-of-stat effects aren't included. Effective HP is health × (1 + resist ÷ 100).

## Riot's developer policies

RiftLens is built to stay inside them:

- Uses only documented sources: the Riot API (account, summoner, league, champion mastery, match, spectator and status endpoints) and Data Dragon. It doesn't scrape other sites, read the League client or connect to League chat.
- The API key stays on the server. Locally the server only accepts requests from your own browser; online it only answers to your domain, and the key comes from an environment variable. `data/` (where a local key is saved) is git-ignored.
- Has its own visual design and logo. It doesn't use Riot logos or imitate the League client. Champion, item and rune icons come from Data Dragon, which Riot provides for this.
- Is free with no paid or exclusive features, isn't affiliated with Riot, and doesn't label or shame players. It shows ranks and stats as Riot reports them, with no custom MMR or skill rating.
- Builds can't be pushed into the League client, because that would need the client's own interface, which isn't part of Riot's third-party tools.

**Gray area to raise with Riot before publishing:** the live game matchup score combines rank, mastery and season win rate into one 0-100 number. Riot forbids alternatives to ranked leagues and evaluating players. The score is framed as a lane matchup estimate, not a player rating, but describe it in an App Note on your production application and ask. Riot's policy page invites this.

RiftLens isn't endorsed by Riot Games and doesn't reflect the views or opinions of Riot Games or anyone officially involved in producing or managing Riot Games properties.
