
export const fixtures = {
  "GET /test": {
    status: 200,
    body: {
      message: "UniPath API adapter is working!",
    },
  },
  "POST /test-submit": {
    status: 200,
    expectedBody: {
      major: "Computer Science",
      budget: 20000,
    },
    body: {
      success: true,
    },
  },

  "GET /test-error": {
    status: 500,
    body: {
      error: "Simulated server error",
    },
  },
};
