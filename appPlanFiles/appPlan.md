# SafeSteps — Full Project Plan & Design Document

**Project name:** SafeSteps
**Tagline:** Small steps. Big peace of mind.
**Document purpose:** Complete, developer-ready plan and design document for building SafeSteps (iOS + Android apps + backend + future wearable). Includes product definition, UX flows, data model, API spec, full repository file/folder layout with file descriptions, CI/CD, testing, privacy/legal, launch plan, and detailed mapping of features to files.

---

## Table of Contents

1. Executive summary
2. Product vision & goals
3. Target audience & positioning
4. Core features (MVP and roadmap)
5. User stories & acceptance criteria
6. UX flows and screen-level wireframes (textual)
7. Technical architecture overview
8. Tech stack decisions & rationale
9. Full repo layout with file/folder names and paths (copy-paste ready)
10. Detailed file descriptions and contents summary
11. Backend API specification (endpoints + examples)
12. Database schema (Postgres + PostGIS)
13. Core algorithms & pseudo-code (geofence, Kalman, hysteresis)
14. Native integration & permissions (iOS / Android manifest details)
15. CI/CD, testing, and deployment
16. Privacy, legal, and security checklist
17. Pilot plan, metrics & KPIs
18. Release plan & marketing assets
19. Roadmap for v1+, hardware & scaling
20. Appendix: copy-paste templates and prompts for AI code generation

---

## 1. Executive summary

SafeSteps is a parent-controlled geofencing and child-safety system that allows parents to draw safe walking boundaries snapped to sidewalks. Children receive calm TTS guidance when nearing boundaries and urgent notifications when crossing them. The system prioritizes low false positives, privacy, and reliable background behavior across iOS and Android. MVP focuses on robust geofencing, TTS escalation, and parental controls; future phases add advanced map-matching, festival/proximity mode, analytics, and a wearable.

---

## 2. Product vision & goals

* Keep children safe during independent outdoor exploration while preserving their dignity.
* Provide parents fast, reliable notifications when children approach or cross boundaries.
* Achieve low false-positive rates via smoothing, hysteresis, and sidewalk snapping.
* Comply with child-data privacy regulations and provide transparent parental controls.

Success metrics (pilot targets):

* False positive alerts < 2%
* Median notification latency < 8s (from device event to parent push)
* App battery impact < 5% daily
* Pilot retention: 60% of parents active after 30 days

---

## 3. Target audience & positioning

Primary: Parents of children aged 6–14 who allow supervised independent mobility (walking to school, parks).
Secondary: Caregivers (grandparents), schools (pilot partnerships), municipalities.

Positioning: A gentle, trustworthy safety product that focuses on walking/sidewalk safety rather than surveillance.

---

## 4. Core features

### MVP (must-have)

* Parent & child account pairing
* Draw-on-map geofence editor (polygon) with optional snap-to-sidewalk
* Device background location monitoring and server-side geofence evaluation
* Child notifications: TTS advisory (near boundary) and urgent TTS (violation)
* Parent notifications: push, SMS fallback, and web/parent map view
* SOS button on child device (notifications to caregivers)
* Privacy & consent flows (COPPA-aware)
* Audit log and device-off alerts

### v1 (post-MVP)

* Server-side map-matching for improved sidewalk snapping
* Sensor fusion (accelerometer + speed) for walking vs vehicle detection
* BLE-based parent proximity for "with parent" suppression
* Temporary dynamic proximity fences (festival mode) — opt-in
* Multi-caregiver escalation logic and scheduling

### v2+ (future)

* Wearable device with LTE-M, SOS, speaker & mic
* Verified emergency call integration via a managed operator
* Advanced analytics and route history export

---

## 5. User stories & acceptance criteria

(Selected; each should be tracked in issue tracker)

### US-001 Parent: Create and pair child

* Given a parent account, when they create a child profile and scan a QR code on the child device, then child is added and pairing confirmed.
* Acceptance: backend records pairing token; parent sees child on dashboard.

### US-002 Parent: Draw boundary and save

* Given a parent on the fence editor, when they draw polygon and press Save with snap-to-sidewalk on, the backend returns snapped polygon and confidence; parent sees overlay.
* Acceptance: snapped polygon displayed; confidence >= 0.0.

### US-003 Child: Receive warning near boundary

* When child's device enters Warning buffer for >2 consecutive samples, child hears calm TTS advisory and parent receives push.
* Acceptance: TTS plays; event recorded; parent push arrives.

### US-004 Child: Violation and escalation

* When child's device is outside Violation buffer for >=3 samples, urgent TTS runs and backend triggers high-priority push + SMS fallback.
* Acceptance: urgent audio + push + SMS fallback (if configured) and event logged.

### US-005 System: Device offline handling

* When device hasn't posted location for > OFFLINE\_THRESHOLD, send device-off alert to parent.
* Acceptance: parent receives device-off message with last-known timestamp.

---

## 6. UX flows and screen-level wireframes (textual)

All screens referenced by path in repo layout below.

### Onboarding (Parent)

1. Welcome screen -> Create account / Sign in
2. Add child -> Enter child name + DOB -> Generate pairing QR/code
3. Draw safe zone tutorial (one-minute interactive) -> Confirm
4. Set caregivers & fallback numbers -> Finish

### Onboarding (Child device)

1. Welcome screen for child -> Pair with parent via QR/code
2. Brief TTS tutorial: "If you hear SafeSteps say..."
3. Accept permissions: location always, notifications, bluetooth (optional)
4. Child map with SOS button and simple status

### Parent Dashboard

* Map with live child marker, breadcrumb trail, active fences overlay
* Controls: Edit Fence, Add Fence, View History, Settings, Contact Child
* List view of children (battery, connection, latest event)

### Fence Editor

* Map center on location; tap to add vertices; drag to edit; toggle Snap-to-Sidewalk; Save/Cancel
* Visual overlays: dashed original polygon, solid snapped polygon, confidence label

### Child Map / View

* Centered child location, fence overlay, status banner (SAFE / WARNING / OUTSIDE)
* SOS button (big, colored), small help button— "What to do"
* Settings: Max-priority audio opt-in (parent-only editable)

### Notifications flow

* Parent push: brief alert with child name + event type + last-known location preview
* TTS content: friendly, actionable lines (stored in resources for localization)

---

## 7. Technical architecture overview

* Mobile Apps (React Native) for iOS & Android. Native modules for reliable background geolocation and BLE.
* Backend (Node.js/TypeScript) with Express or NestJS, responsible for pairing, fences persistence, evaluation, notifications, and map-matching calls.
* Database: Postgres + PostGIS (store fence polygons, location samples, events).
* Cache & realtime: Redis for device-state, dedupe keys, and presence; WebSockets or server-sent events for real-time parent dashboards.
* External services: Mapbox (map tiles + map matching), FCM/APNs for push, Twilio for SMS fallback.

Flow summary:

* Device -> native location -> RN JS bridge -> local GeofenceEngine for immediate TTS; device posts location to backend -> backend evaluates events and notifies caregivers -> parent devices receive push & web updates.

Note: Evaluate whether geofence checks happen on-device, server-side, or both. For low-latency child TTS, perform initial classification on-device; for authoritative audit and multi-caretaker notifications, backend should also process posted locations.

---

## 8. Tech stack decisions & rationale

* React Native + TypeScript: cross-platform speed with native capability via modules.
* Native modules for background geolocation (iOS Swift CoreLocation, Android foreground service + FusedLocationProvider) for reliability.
* Postgres + PostGIS: robust geospatial queries and storage.
* Mapbox: good pedestrian network and map-matching; fallback to OSM/OSRM if needed.
* Redis: fast dedupe & ephemeral device state.
* Fastlane + GitHub Actions: standardized mobile CI/CD.

---

## 9. Full repo layout (copy-paste ready)

```
/ren-safesteps
├── README.md
├── plan.md                      # this document (short pointer)
├── LICENSE
├── mobile/
│   ├── README.md
│   ├── package.json
│   ├── tsconfig.json
│   ├── android/
│   ├── ios/
│   ├── src/
│   │   ├── App.tsx
│   │   ├── index.tsx
│   │   ├── assets/
│   │   ├── components/
│   │   │   ├── MapView.tsx
│   │   │   ├── SOSButton.tsx
│   │   │   └── FenceDrawer.tsx
│   │   ├── screens/
│   │   │   ├── Auth/
│   │   │   │   ├── LoginScreen.tsx
│   │   │   │   └── RegisterScreen.tsx
│   │   │   ├── Parent/
│   │   │   │   ├── ParentDashboardScreen.tsx
│   │   │   │   └── FenceEditorScreen.tsx
│   │   │   └── Child/
│   │   │       └── ChildMapScreen.tsx
│   │   ├── services/
│   │   │   ├── api.ts
│   │   │   ├── auth.ts
│   │   │   ├── locationBridge.ts
│   │   │   ├── geofenceEngine.ts
│   │   │   ├── kalman.ts
│   │   │   └── notifications.ts
│   │   ├── native-modules/
│   │   │   ├── ios/
│   │   │   │   └── SafeStepsLocationModule.swift
│   │   │   └── android/
│   │   │       └── SafeStepsLocationModule.kt
│   │   ├── types/
│   │   │   └── index.ts
│   │   └── utils/
│   │       └── geo.ts
│   └── e2e/
│       └── detox.config.js
├── backend/
│   ├── README.md
│   ├── package.json
│   ├── tsconfig.json
│   ├── Dockerfile
│   ├── docker-compose.yml
│   ├── prisma/ (or migrations/ if TypeORM)
│   │   └── schema.prisma
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── controllers/
│   │   │   ├── auth.controller.ts
│   │   │   ├── fence.controller.ts
│   │   │   ├── event.controller.ts
│   │   │   └── pairing.controller.ts
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   ├── fence.service.ts
│   │   │   ├── mapbox.service.ts
│   │   │   └── notification.service.ts
│   │   ├── models/
│   │   │   ├── user.model.ts
│   │   │   ├── child.model.ts
│   │   │   └── fence.model.ts
│   │   ├── jobs/
│   │   │   └── cleanup.job.ts
│   │   └── utils/
│   │       └── geo.utils.ts
│   └── scripts/
│       └── mapbox_snapping_spike.ts
├── infrastructure/
│   ├── fastlane/
│   ├── github-actions/
│   │   └── ci.yml
│   └── terraform/ (optional)
├── docs/
│   ├── privacy-policy.md
│   ├── coppa-consent.md
│   └── design/
│       └── branding.md
└── tests/
    ├── unit/
    └── integration/
```

---

## 10. Detailed file descriptions and contents summary

Below are concise descriptions for the most important files. Use these as the basis for AI generation prompts or developer implementation.

### Top-level

* `README.md`: Project overview, local dev quickstart.
* `plan.md`: This document.

### Mobile

* `mobile/package.json`: RN deps & scripts.
* `mobile/src/App.tsx`: Root app with navigation providers and auth gating.
* `mobile/src/screens/Parent/FenceEditorScreen.tsx`: Mapbox-based fence drawing UI; toggles snap-to-sidewalk; POST to `/api/v1/fence`.
* `mobile/src/services/locationBridge.ts`: JS wrapper that listens to native modules for background location and emits events.
* `mobile/src/services/geofenceEngine.ts`: Kalman smoothing, point-in-polygon classification, hysteresis logic (warning/violation), exports event emitter.
* `mobile/src/native-modules/ios/SafeStepsLocationModule.swift`: iOS native module bridging CoreLocation & notifications to RN.
* `mobile/src/native-modules/android/SafeStepsLocationModule.kt`: Android native module with foreground service and fused provider.

### Backend

* `backend/src/controllers/fence.controller.ts`: Endpoint to accept polygon GeoJSON and call mapbox.service to snap and store.
* `backend/src/services/mapbox.service.ts`: MapMatching call, polygon sampling, confidence scoring.
* `backend/src/services/notification.service.ts`: FCM/APNs + Twilio SMS logic & Redis dedupe.
* `backend/prisma/schema.prisma`: Database schema including PostGIS geometry fields.

---

## 11. Backend API specification (endpoints + payloads)

All endpoints require Bearer token authentication unless device token-specified in header.

### POST /api/v1/auth/login

* Request: `{ email, password }`
* Response: `{ accessToken, refreshToken, user }`

### POST /api/v1/pair

* Request: `{ parentId, childId, pairingCode }`
* Response: `{ success: true }`

### POST /api/v1/fence

* Request: `{ childId, geojson: GeoJSON.Polygon, snapToSidewalk: boolean }`
* Response: `{ fenceId, originalGeoJSON, snappedGeoJSON, confidence }`

### GET /api/v1/children/\:id/location

* Response: `{ deviceId, lat, lon, accuracy, timestamp, confidence }`

### POST /api/v1/events

* Request: `{ deviceId, eventType: 'WARNING'|'VIOLATION'|'SOS'|'OFFLINE', lat, lon, accuracy }`
* Response: `{ status: 'ok' }`

### GET /api/v1/audit/\:userId

* Response: `[{ action, target, timestamp, ip }]`

---

## 12. Database schema (Postgres + PostGIS)

Use Prisma or TypeORM. Key tables (columns abbreviated):

* `users` (id PK, email, password\_hash, role, created\_at)
* `children` (id PK, name, dob, owner\_user\_id FK, data\_retention\_days int)
* `devices` (id PK, child\_id FK, device\_token, last\_seen timestamptz, battery\_level int, os text, last\_lat numeric, last\_lon numeric)
* `fences` (id PK, child\_id FK, geojson jsonb, geom geometry(Polygon,4326), snapped\_geojson jsonb, snap\_confidence float, created\_by, created\_at)
* `location_samples` (id PK, device\_id FK, recorded\_at timestamptz, geom geometry(Point,4326), accuracy float, speed float)
* `events` (id PK, device\_id FK, event\_type text, metadata jsonb, created\_at)
* `audit_log` (id PK, user\_id FK, action text, ip text, created\_at)

Indexes:

* GIST index on `fences.geom` and `location_samples.geom`.

---

## 13. Core algorithms & pseudo-code

### Geofence classification + hysteresis

Pseudocode (production-ready):

```
# Constants
WARN_RADIUS = 15  # meters
WARN_CONSECUTIVE = 2
VIOLATION_CONSECUTIVE = 3

# For each device, maintain state
state = {
  consecutiveWarning: 0,
  consecutiveViolation: 0,
}

function classifyPoint(point, fencePolygon):
  if pointInPolygon(point, fencePolygon):
    dist = distanceToBoundary(point, fencePolygon)
    if dist <= WARN_RADIUS: return 'WARNING'
    return 'SAFE'
  else:
    return 'VIOLATION'

function onSample(sample):
  smoothed = kalmanFilter.update(sample)
  zone = classifyPoint(smoothed, fence)
  if zone == 'WARNING':
    state.consecutiveWarning += 1
    state.consecutiveViolation = 0
    if state.consecutiveWarning >= WARN_CONSECUTIVE:
      emitWarning()
  elif zone == 'VIOLATION':
    state.consecutiveViolation += 1
    state.consecutiveWarning = 0
    if state.consecutiveViolation >= VIOLATION_CONSECUTIVE:
      emitViolation()
  else:
    state.consecutiveWarning = 0
    state.consecutiveViolation = 0
```

### Kalman smoothing notes

* Use separate 1D Kalman filters for latitude and longitude, or use a 2D Kalman if needed.
* Keep process and measurement noise conservative to avoid over smoothing fast motion.

### Map snapping confidence algorithm (server-side)

1. Sample points along polygon edges every N meters.
2. Call Mapbox Map Matching for each sample; ensure returned matched edge is footway or pedestrian.
3. Confidence = (#samples matched to pedestrian edges) / (#samples)
4. If confidence < 0.5, return fallback and show parent a warning "No sidewalk data — freeform boundary applied."

---

## 14. Native integration & permissions

### iOS

* Info.plist keys:

  * NSLocationWhenInUseUsageDescription
  * NSLocationAlwaysAndWhenInUseUsageDescription
  * UIBackgroundModes: location, audio
  * NSBluetoothAlwaysUsageDescription
* Implement a Swift module exposing start/stop monitoring, onLocation(callback), onGeofenceEvent(callback). Use AVAudioSession for TTS audio focus where allowed.

### Android

* AndroidManifest permissions:

  * ACCESS\_FINE\_LOCATION
  * ACCESS\_COARSE\_LOCATION
  * ACCESS\_BACKGROUND\_LOCATION
  * FOREGROUND\_SERVICE
* Implement a Kotlin foreground service using FusedLocationProvider with high-accuracy mode when moving. Expose JS bridge via React Native.

Notes: Request background location permission via a two-step UX (first request foreground, explain need, then request background with a separate dialog) as required on modern Android.

---

## 15. CI/CD, testing, and deployment

### CI

* GitHub Actions workflow `infrastructure/github-actions/ci.yml` runs lint, unit tests, and builds debug Android/iOS artifacts.
* Unit tests with Jest for TS code; instrument backend endpoints with Supertest.

### CD

* Fastlane lanes for iOS TestFlight upload and Android internal track.
* On merge to `release` branch: run integration tests and then upload artifacts to internal testing.

### Tests

* Unit tests: algorithms (kalman, geofenceEngine), API controllers.
* Integration tests: backend endpoints + DB migrations.
* E2E: Detox for RN flows (limited for background location); extensive on-device manual testing required for background behavior, BLE, and TTS.

---

## 16. Privacy, legal, and security checklist

* Parental consent captured and stored for each child (COPPA-style).
* Data retention default 30 days; parent-configurable.
* Data minimization: only store what’s necessary.
* Encryption: TLS for transport; encrypt sensitive fields at rest.
* Audit log showing who accessed child location.
* Terms of Service and Privacy Policy drafted and linked in Onboarding.
* Consult counsel before calling emergency services or selling to schools.

---

## 17. Pilot plan, metrics & KPIs

### Pilot scope

* City-level pilot (50–200 families) in a location with decent sidewalk data.
* Duration: 6–8 weeks

### Metrics to collect

* Alerts per family/day (false positive ratio)
* Median time from event to parent push
* Battery consumption estimate per device
* Uptime & offline events
* SOS usage & response time

### Pilot success criteria

* False positive < 2% of alerts
* Median notification latency < 8s
* App battery impact < 5% daily

---

## 18. Release plan & marketing assets

### App Store / Play Store

* App title: `SafeSteps: Kid GPS`
* Subtitle: `Geofence, TTS alerts & SOS`
* Short description: `Set safe walking zones, get real-time alerts, and talk to your child with clear TTS.`
* Privacy blurb: `Collects location data only with parental consent; data retained 30 days by default.`

### Marketing assets

* One-page landing site (hero, features, testimonials, CTA to join pilot)
* Short explainer video (30s) showing fence draw + child TTS + parent notification
* Brand kit: color palette, logo sketches, typeface recommendations (Inter/Nunito)

---

## 19. Roadmap for v1+, hardware & scaling

* v1+: add BLE proximity, map-matching improvements, multi-caregiver scheduling
* v2+: hardware wearable (LTE-M, SOS) with partner for emergency call routing
* Scale: multi-region mapbox or self-hosted OSRM for map-matching; sharded Postgres and message queues

---

## 20. Appendix: copy-paste templates & AI prompts

(Short selection — many more prompts available in plan.md)

### Example prompt: POST /api/v1/fence endpoint

```
Implement POST /api/v1/fence:
- Accept GeoJSON polygon and snapToSidewalk boolean.
- If snap true: call Mapbox Map Matching using MAPBOX_TOKEN env var; compute confidence.
- Save original & snapped polygon in DB; return { fenceId, snappedGeoJSON, confidence }.
```

### Example prompt: GeofenceEngine (TypeScript)

(Paste the geofenceEngine.ts pseudocode provided earlier.)

---

# Final notes

This document is intentionally detailed and mapped to files and developer artifacts so you can hand it directly to engineers or an AI code generator. Treat the Discovery Spikes (map coverage and TTS background) as gating items before building large features. Prioritize robust field testing.
