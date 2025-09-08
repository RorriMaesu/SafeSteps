// Minimal placeholder implementing the hysteresis API from the plan
export type Zone = 'SAFE' | 'WARNING' | 'VIOLATION';

const WARN_RADIUS = 15; // meters
const WARN_CONSECUTIVE = 2;
const VIOLATION_CONSECUTIVE = 3;

export type Point = { lat: number; lon: number };

export type State = { consecutiveWarning: number; consecutiveViolation: number };

export function pointInPolygon(point: Point, polygon: Point[]): boolean {
  let inside = false;
  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const xi = polygon[i].lon, yi = polygon[i].lat;
    const xj = polygon[j].lon, yj = polygon[j].lat;
    const intersect = ((yi > point.lat) !== (yj > point.lat)) &&
      (point.lon < (xj - xi) * (point.lat - yi) / (yj - yi + 1e-9) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

export function classify(point: Point, polygon: Point[]): Zone {
  if (!polygon || polygon.length < 3) return 'SAFE';
  if (pointInPolygon(point, polygon)) {
    // TODO: implement distance to boundary; for now simple inside=SAFE
    return 'SAFE';
  }
  return 'VIOLATION';
}

export function nextState(state: State, zone: Zone) {
  if (zone === 'WARNING') {
    return { consecutiveWarning: state.consecutiveWarning + 1, consecutiveViolation: 0 };
  }
  if (zone === 'VIOLATION') {
    return { consecutiveWarning: 0, consecutiveViolation: state.consecutiveViolation + 1 };
  }
  return { consecutiveWarning: 0, consecutiveViolation: 0 };
}

export function shouldEmit(state: State, zone: Zone) {
  if (zone === 'WARNING' && state.consecutiveWarning >= WARN_CONSECUTIVE) return 'WARNING';
  if (zone === 'VIOLATION' && state.consecutiveViolation >= VIOLATION_CONSECUTIVE) return 'VIOLATION';
  return null;
}
