
import { fixtures } from "../fixtures/responses.js";

const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "";
const USE_FIXTURES = import.meta.env.VITE_USE_FIXTURES === "true";

export async function apiRequest(path, options = {}) {
  const method = (options.method || "GET").toUpperCase();
  const fixtureKey = `${method} ${path}`;

  if (USE_FIXTURES) {
    if (!Object.hasOwn(fixtures, fixtureKey)) {
      throw new Error(`No fixture defined for: ${fixtureKey}`);
    }

    const fixture = fixtures[fixtureKey];
    if (Object.hasOwn(fixture, "expectedBody")) {
  let submittedBody;

  try {
    submittedBody = JSON.parse(options.body);
  } catch {
    throw new Error(`Invalid JSON request body for: ${fixtureKey}`);
  }

  if (
    JSON.stringify(submittedBody) !==
    JSON.stringify(fixture.expectedBody)
  ) {
    throw new Error(`Unexpected request body for: ${fixtureKey}`);
  }
}

    if (fixture.status < 200 || fixture.status >= 300) {
      throw new Error(`API request failed: ${fixture.status}`);
    }

    if (fixture.status === 204) {
      return null;
    }

    return structuredClone(fixture.body);
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...options,
    headers: {
      Accept: "application/json",
      ...options.headers,
    },
  });

  if (!response.ok) {
    throw new Error(`API request failed: ${response.status}`);
  }

  if (response.status === 204) {
    return null;
  }

  return response.json();
}
