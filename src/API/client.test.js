import {
  describe,
  it,
  expect,
  vi,
  beforeEach,
  afterEach,
} from "vitest";

describe("UniPath HTTP adapter", () => {
  beforeEach(() => {
    vi.resetModules();
    vi.stubEnv("VITE_USE_FIXTURES", "true");
  });

  afterEach(() => {
    vi.unstubAllEnvs();
    vi.unstubAllGlobals();
  });

  // TEST 1
  it("returns a simulated API response", async () => {
    const { apiRequest } = await import("./client.js");

    const result = await apiRequest("/test");

    expect(result).toEqual({
      message: "UniPath API adapter is working!",
    });
  });

  // TEST 2
  it("throws an error when a fixture is missing", async () => {
    const { apiRequest } = await import("./client.js");

    await expect(
      apiRequest("/nonexistent")
    ).rejects.toThrow(
      "No fixture defined for: GET /nonexistent"
    );
  });

  // TEST 3
  it("sends a real HTTP request when fixtures are disabled", async () => {
    vi.stubEnv("VITE_USE_FIXTURES", "false");
    vi.stubEnv("VITE_API_BASE_URL", "http://localhost:5000");

    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({
        message: "Response from Flask",
      }),
    });

    vi.stubGlobal("fetch", mockFetch);

    const { apiRequest } = await import("./client.js");
    const result = await apiRequest("/test");

    expect(mockFetch).toHaveBeenCalledWith(
      "http://localhost:5000/test",
      expect.objectContaining({
        headers: expect.objectContaining({
          Accept: "application/json",
        }),
      })
    );

    expect(result).toEqual({
      message: "Response from Flask",
    });
  });

  // TEST 4 
  it("reports backend errors without falling back to fixtures", async () => {
    vi.stubEnv("VITE_USE_FIXTURES", "false");
    vi.stubEnv("VITE_API_BASE_URL", "http://localhost:5000");

    const mockFetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 500,
    });

    vi.stubGlobal("fetch", mockFetch);

    const { apiRequest } = await import("./client.js");

    await expect(
      apiRequest("/test")
    ).rejects.toThrow("API request failed: 500");

    expect(mockFetch).toHaveBeenCalledOnce();
  });

  // test 5
  it("handles HTTP 204 responses", async () => {
    vi.stubEnv("VITE_USE_FIXTURES", "false");
    vi.stubEnv("VITE_API_BASE_URL", "http://localhost:5000");

    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      status: 204,
    });

    vi.stubGlobal("fetch", mockFetch);

    const { apiRequest } = await import("./client.js");

    const result = await apiRequest("/test");

    expect(result).toBeNull();
    expect(mockFetch).toHaveBeenCalledOnce();
  });

  // TEST 6
  it("sends POST requests with the correct JSON payload", async () => {
    vi.stubEnv("VITE_USE_FIXTURES", "false");
    vi.stubEnv("VITE_API_BASE_URL", "http://localhost:5000");

    const mockFetch = vi.fn().mockResolvedValue({
      ok: true,
      status: 200,
      json: async () => ({ success: true }),
    });

    vi.stubGlobal("fetch", mockFetch);

    const { apiRequest } = await import("./client.js");

    const studentData = {
      major: "Computer Science",
      budget: 20000,
    };

    const result = await apiRequest("/test", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(studentData),
    });

    expect(mockFetch).toHaveBeenCalledWith(
      "http://localhost:5000/test",
      expect.objectContaining({
        method: "POST",
        headers: expect.objectContaining({
          "Content-Type": "application/json",
        }),
        body: JSON.stringify(studentData),
      })
    );

    expect(result).toEqual({ success: true });
  });

  // TEST 7
  it("handles simulated HTTP errors in fixture mode", async () => {
    const { apiRequest } = await import("./client.js");

    await expect(
      apiRequest("/test-error")
    ).rejects.toThrow("API request failed: 500");
  });

  // TEST 8: Verify submitted JSON in fixture mode.
  it("validates submitted data against the fixture", async () => {
    const { apiRequest } = await import("./client.js");

    const studentData = {
      major: "Computer Science",
      budget: 20000,
    };

    const result = await apiRequest("/test-submit", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(studentData),
    });

    expect(result).toEqual({ success: true });

    await expect(
      apiRequest("/test-submit", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          major: "Computer Science",
          budget: 50000,
        }),
      })
    ).rejects.toThrow(
      "Unexpected request body for: POST /test-submit"
    );
  });
});
