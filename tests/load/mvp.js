import http from 'k6/http';
import { check, sleep } from 'k6';
import exec from 'k6/execution';

const baseUrl = __ENV.BASE_URL || 'http://host.docker.internal:5121';

export const options = {
  scenarios: {
    spatial_reads: {
      executor: 'constant-arrival-rate',
      exec: 'spatialReads',
      rate: 20,
      timeUnit: '1s',
      duration: '30s',
      preAllocatedVUs: 10,
      maxVUs: 40,
      tags: { flow: 'spatial' },
    },
    recommendation_acceptance: {
      executor: 'constant-arrival-rate',
      exec: 'recommendationAcceptance',
      rate: 1,
      timeUnit: '2s',
      duration: '30s',
      preAllocatedVUs: 2,
      maxVUs: 10,
      startTime: '2s',
      tags: { flow: 'recommendation' },
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<2000'],
    'http_req_duration{flow:spatial}': ['p(95)<500'],
    'http_req_duration{flow:recommendation}': ['p(95)<2000'],
    checks: ['rate>0.99'],
    dropped_iterations: ['count==0'],
  },
};

export function setup() {
  const unique = `${Date.now()}-${Math.floor(Math.random() * 100000)}`;
  const response = http.post(`${baseUrl}/api/identity/register`, JSON.stringify({
    email: `load-${unique}@example.com`,
    password: 'LoadTest123!',
    firstName: 'Load',
    lastName: 'Test',
  }), { headers: { 'Content-Type': 'application/json' }, tags: { flow: 'setup' } });

  const valid = check(response, { 'load user registered': (result) => result.status === 201 });
  if (!valid) exec.test.abort(`Load setup failed: HTTP ${response.status}`);
  return { token: response.json('accessToken') };
}

export function spatialReads() {
  const response = http.get(
    `${baseUrl}/api/discovery/places/nearest?longitude=29.026&latitude=40.985&limit=20`,
    { tags: { flow: 'spatial' } },
  );
  check(response, {
    'spatial returns 200': (result) => result.status === 200,
    'spatial returns places': (result) => Array.isArray(result.json()) && result.json().length > 0,
  });
}

export function recommendationAcceptance(data) {
  const response = http.post(`${baseUrl}/api/recommendations/generate`, JSON.stringify({
    tripDate: new Date(Date.now() + 86400000).toISOString().slice(0, 10),
    availableMinutes: 240,
    startLongitude: 29.026,
    startLatitude: 40.985,
  }), {
    headers: {
      Authorization: `Bearer ${data.token}`,
      'Content-Type': 'application/json',
    },
    tags: { flow: 'recommendation' },
  });
  check(response, {
    'recommendation accepted': (result) => result.status === 202,
    'run id returned': (result) => Boolean(result.json('runId')),
  });
  sleep(0.1);
}
