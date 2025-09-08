export function toGeoJSONPolygon(coords: { latitude: number; longitude: number }[]) {
  const coordinates = coords.map(c => [c.longitude, c.latitude]);
  if (coordinates.length && (coordinates[0][0] !== coordinates[coordinates.length - 1][0] || coordinates[0][1] !== coordinates[coordinates.length - 1][1])) {
    coordinates.push(coordinates[0]);
  }
  return {
    type: 'Polygon',
    coordinates: [coordinates],
  } as const;
}
